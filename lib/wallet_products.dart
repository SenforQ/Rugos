class WalletCoinProduct {
  const WalletCoinProduct({
    required this.productId,
    required this.coins,
    required this.price,
    required this.priceText,
  });

  final String productId;
  final int coins;
  final double price;
  final String priceText;
}

const List<WalletCoinProduct> kWalletCoinProducts = <WalletCoinProduct>[
  WalletCoinProduct(productId: 'Coin_Rugos_0', coins: 32, price: 0.99, priceText: '\$0.99'),
  WalletCoinProduct(productId: 'Coin_Rugos_1', coins: 60, price: 1.99, priceText: '\$1.99'),
  WalletCoinProduct(productId: 'Coin_Rugos_2', coins: 96, price: 2.99, priceText: '\$2.99'),
  WalletCoinProduct(productId: 'Coin_Rugos_4', coins: 155, price: 4.99, priceText: '\$4.99'),
  WalletCoinProduct(productId: 'Coin_Rugos_5', coins: 189, price: 5.99, priceText: '\$5.99'),
  WalletCoinProduct(productId: 'Coin_Rugos_9', coins: 359, price: 9.99, priceText: '\$9.99'),
  WalletCoinProduct(productId: 'Coin_Rugos_19', coins: 729, price: 19.99, priceText: '\$19.99'),
  WalletCoinProduct(productId: 'Coin_Rugos_49', coins: 1869, price: 49.99, priceText: '\$49.99'),
  WalletCoinProduct(productId: 'Coin_Rugos_99', coins: 3799, price: 99.99, priceText: '\$99.99'),
];
