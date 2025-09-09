import 'package:shared_preferences/shared_preferences.dart';

Bus bus = Bus.sh;

class Bus {
  static Bus sh = Bus._();

  Bus._();

  DateTime? startTime;

  bool isBMode = false; //进入到B面后设置为true

  bool get isFirstAppLaunch {
    return getAppLaunchCount <= 1;
  }

  int get getAppLaunchCount {
    final count = museSp.getInt('KeyAppLaunchCount');
    return count;
  }

  void setAppLaunchCount() {
    museSp.setInt('KeyAppLaunchCount', getAppLaunchCount + 1);
  }
}

MuseSP get museSp => MuseSP.instance;

class MuseSP {
  static final MuseSP instance = MuseSP._();

  MuseSP._();

  late SharedPreferences _museSp;


  init() async {
    _museSp = await SharedPreferences.getInstance();
  }

  Future<bool> setInt(String key, int value) async {
    return await _museSp.setInt(key, value);
  }

  int getInt(String key) {
    int? value = _museSp.getInt(key);
    return value ?? 0;
  }

  Future<bool> setString(String key, String value) async {
    return await _museSp.setString(key, value);
  }

  String? getString(String key) {
    String? value = _museSp.getString(key);
    return value;
  }
}
