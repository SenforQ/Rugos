import 'package:shared_preferences/shared_preferences.dart';

import 'wallet_economy.dart';

class WalletBalanceStore {
  static const String _key = 'wallet_coin_balance';
  static const int initialCoins = WalletEconomy.newUserGiftCoins;

  static Future<int> getBalance() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_key)) {
      await prefs.setInt(_key, initialCoins);
      return initialCoins;
    }
    return prefs.getInt(_key) ?? initialCoins;
  }

  static Future<void> setBalance(int value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, value < 0 ? 0 : value);
  }

  static Future<bool> addCoins(int amount) async {
    if (amount <= 0) {
      return false;
    }
    final int current = await getBalance();
    await setBalance(current + amount);
    return true;
  }

  static Future<bool> deductCoins(int amount) async {
    if (amount <= 0) {
      return false;
    }
    final int current = await getBalance();
    if (current < amount) {
      return false;
    }
    await setBalance(current - amount);
    return true;
  }
}
