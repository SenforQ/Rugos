/// Coin rules and costs (aligned with wallet info and [WalletBalanceStore.initialCoins]).
class WalletEconomy {
  WalletEconomy._();

  static const int newUserGiftCoins = 20;
  static const int freeCustomTeacherSlots = 3;
  static const int extraTeacherOverFreeCost = 30;
  static const int chatPerMessageCost = 1;
  static const int imageGenerationCost = 10;
  static const int videoGenerationCost = 50;

  static const String infoRule1 = 'New users receive 20 coins.';
  static const String infoRule2 =
      'After 3 custom robots, each additional robot costs 30 coins (the first 3 are free).';
  static const String infoRule3 = 'Each message you send in a robot chat costs 1 coin.';
  static const String infoRule4 = 'Each image generation costs 10 coins.';
  static const String infoRule5 = 'Each video generation costs 50 coins.';

  static const List<String> infoRules = <String>[
    infoRule1,
    infoRule2,
    infoRule3,
    infoRule4,
    infoRule5,
  ];
}
