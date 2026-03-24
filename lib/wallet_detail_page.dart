import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:intl/intl.dart';

import 'wallet_balance_store.dart';
import 'wallet_economy.dart';
import 'wallet_products.dart';

class WalletDetailPage extends StatefulWidget {
  const WalletDetailPage({super.key});

  @override
  State<WalletDetailPage> createState() => _WalletDetailPageState();
}

class _WalletDetailPageState extends State<WalletDetailPage> {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  final Map<String, Timer> _timeoutTimers = <String, Timer>{};
  final NumberFormat _coinsFormat = NumberFormat.decimalPattern();

  StreamSubscription<List<PurchaseDetails>>? _subscription;
  Map<String, ProductDetails> _products = <String, ProductDetails>{};

  int _currentCoins = 0;
  int _selectedIndex = 0;
  bool _isPurchasing = false;
  bool _isAvailable = false;
  int _retryCount = 0;

  static const int _maxRetries = 3;
  static const int _timeoutDurationSeconds = 30;

  @override
  void initState() {
    super.initState();
    unawaited(_loadCoins());
    unawaited(_checkConnectivityAndInit());
  }

  @override
  void dispose() {
    _subscription?.cancel();
    for (final Timer t in _timeoutTimers.values) {
      t.cancel();
    }
    _timeoutTimers.clear();
    super.dispose();
  }

  Future<void> _loadCoins() async {
    final int coins = await WalletBalanceStore.getBalance();
    if (!mounted) {
      return;
    }
    setState(() {
      _currentCoins = coins;
    });
  }

  Future<void> _checkConnectivityAndInit() async {
    try {
      final List<ConnectivityResult> results = await Connectivity().checkConnectivity();
      final bool hasConnection = results.isNotEmpty &&
          !(results.length == 1 && results.contains(ConnectivityResult.none));
      if (!hasConnection) {
        _showMessage('No internet connection. Check your network and try again.');
        return;
      }
    } catch (e) {
      debugPrint('Connectivity check failed: $e');
    }
    await _initIap();
  }

  Future<void> _initIap() async {
    try {
      final bool available = await _inAppPurchase.isAvailable();
      if (!mounted) {
        return;
      }
      setState(() {
        _isAvailable = available;
      });
      if (!available) {
        _showMessage('In-app purchases are not available on this device.');
        return;
      }

      final Set<String> ids = kWalletCoinProducts.map((WalletCoinProduct e) => e.productId).toSet();
      final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(ids);

      if (response.error != null) {
        if (_retryCount < _maxRetries) {
          _retryCount++;
          await Future<void>.delayed(const Duration(seconds: 2));
          await _initIap();
          return;
        }
        _showMessage('Could not load products: ${response.error!.message}');
      }

      if (!mounted) {
        return;
      }
      setState(() {
        _products = <String, ProductDetails>{for (final ProductDetails p in response.productDetails) p.id: p};
      });

      _subscription ??= _inAppPurchase.purchaseStream.listen(
        _onPurchaseUpdate,
        onError: (Object error) => _showMessage('Purchase error: $error'),
        onDone: () => _subscription?.cancel(),
      );
    } catch (e) {
      if (_retryCount < _maxRetries) {
        _retryCount++;
        await Future<void>.delayed(const Duration(seconds: 2));
        await _initIap();
      } else {
        _showMessage('Could not start the App Store billing service.');
      }
    }
  }

  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (final PurchaseDetails purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await _inAppPurchase.completePurchase(purchase);
          final WalletCoinProduct product = kWalletCoinProducts.firstWhere(
            (WalletCoinProduct p) => p.productId == purchase.productID,
            orElse: () => const WalletCoinProduct(productId: '', coins: 0, price: 0, priceText: ''),
          );
          if (product.coins > 0) {
            final bool success = await WalletBalanceStore.addCoins(product.coins);
            if (success) {
              await _loadCoins();
              if (mounted) {
                _showMessage('Added ${product.coins} coins to your wallet.');
              }
            } else {
              _showMessage('Could not update your balance. Please try again.');
            }
          }
          break;
        case PurchaseStatus.error:
          _showMessage('Purchase failed: ${purchase.error?.message ?? 'Unknown error'}');
          break;
        case PurchaseStatus.canceled:
          _showMessage('Purchase canceled.');
          break;
        case PurchaseStatus.pending:
          break;
      }
    }
    _clearPurchaseState();
  }

  void _clearPurchaseState() {
    if (!mounted) {
      return;
    }
    setState(() {
      _isPurchasing = false;
    });
    for (final Timer t in _timeoutTimers.values) {
      t.cancel();
    }
    _timeoutTimers.clear();
  }

  Future<void> _handleConfirmPurchase() async {
    if (!_isAvailable) {
      _showMessage('The store is not available right now.');
      return;
    }
    final WalletCoinProduct selectedProduct = kWalletCoinProducts[_selectedIndex];
    final ProductDetails? productDetails = _products[selectedProduct.productId];
    if (productDetails == null) {
      _showMessage(
        'This pack is not available yet. Create matching products in App Store Connect (ID: ${selectedProduct.productId}).',
      );
      return;
    }

    setState(() {
      _isPurchasing = true;
    });

    _timeoutTimers['purchase'] = Timer(
      const Duration(seconds: _timeoutDurationSeconds),
      _handlePurchaseTimeout,
    );

    try {
      final PurchaseParam param = PurchaseParam(productDetails: productDetails);
      await _inAppPurchase.buyConsumable(purchaseParam: param);
    } catch (e) {
      _timeoutTimers['purchase']?.cancel();
      _timeoutTimers.remove('purchase');
      _showMessage('Purchase could not start: $e');
      if (mounted) {
        setState(() {
          _isPurchasing = false;
        });
      }
    }
  }

  void _handlePurchaseTimeout() {
    if (!mounted) {
      return;
    }
    setState(() {
      _isPurchasing = false;
    });
    _timeoutTimers['purchase']?.cancel();
    _timeoutTimers.remove('purchase');
    _showMessage('Payment timed out. Please try again.');
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _priceLabel(WalletCoinProduct product) {
    final ProductDetails? productDetails = _products[product.productId];
    if (productDetails != null && productDetails.price.isNotEmpty) {
      return productDetails.price;
    }
    return product.priceText;
  }

  void _onProductSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });

    final WalletCoinProduct product = kWalletCoinProducts[index];
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Confirm purchase',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          content: Text(
            'Buy ${product.coins} coins for ${_priceLabel(product)}?',
            style: const TextStyle(fontSize: 16),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                if (mounted) {
                  unawaited(_handleConfirmPurchase());
                }
              },
              child: const Text('Purchase'),
            ),
          ],
        );
      },
    );
  }

  void _showCoinInfoDialog() {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Coin rules',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const _WalletCoinRule(number: '1', text: WalletEconomy.infoRule1),
                const SizedBox(height: 14),
                const _WalletCoinRule(number: '2', text: WalletEconomy.infoRule2),
                const SizedBox(height: 14),
                const _WalletCoinRule(number: '3', text: WalletEconomy.infoRule3),
                const SizedBox(height: 14),
                const _WalletCoinRule(number: '4', text: WalletEconomy.infoRule4),
                const SizedBox(height: 14),
                const _WalletCoinRule(number: '5', text: WalletEconomy.infoRule5),
              ],
            ),
          ),
          actions: <Widget>[
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Got it'),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;
    const Color pageBackground = Color(0xFFF2F2F2);
    return Scaffold(
      backgroundColor: pageBackground,
      appBar: AppBar(
        backgroundColor: pageBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text('Wallet'),
        actions: <Widget>[
          IconButton(
            onPressed: _showCoinInfoDialog,
            icon: const Icon(Icons.info_outline_rounded),
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.86),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
                  ),
                  child: Column(
                    children: <Widget>[
                      Text(
                        _coinsFormat.format(_currentCoins),
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w800,
                          color: primary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Balance',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Top up',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.88,
                  ),
                  itemCount: kWalletCoinProducts.length,
                  itemBuilder: (BuildContext context, int index) {
                    return _WalletProductCard(
                      product: kWalletCoinProducts[index],
                      priceLabel: _priceLabel(kWalletCoinProducts[index]),
                      selected: _selectedIndex == index,
                      primary: primary,
                      enabled: !_isPurchasing,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        _onProductSelected(index);
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          if (_isPurchasing)
            ColoredBox(
              color: Colors.black.withValues(alpha: 0.35),
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 3),
              ),
            ),
        ],
      ),
    );
  }
}

class _WalletProductCard extends StatelessWidget {
  const _WalletProductCard({
    required this.product,
    required this.priceLabel,
    required this.selected,
    required this.primary,
    required this.enabled,
    required this.onTap,
  });

  final WalletCoinProduct product;
  final String priceLabel;
  final bool selected;
  final Color primary;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: enabled ? onTap : null,
        child: Container(
          decoration: BoxDecoration(
            color: selected ? primary.withValues(alpha: 0.18) : Colors.white.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? primary : Colors.black.withValues(alpha: 0.08),
              width: selected ? 2 : 1,
            ),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.monetization_on_rounded, size: 40, color: primary),
              const SizedBox(height: 10),
              Text(
                '${product.coins} coins',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: selected ? primary : primary.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  priceLabel,
                  style: TextStyle(
                    color: selected ? Colors.white : Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WalletCoinRule extends StatelessWidget {
  const _WalletCoinRule({required this.number, required this.text});

  final String number;
  final String text;

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: primary,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 15, height: 1.4, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}
