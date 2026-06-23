import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

class Storage {
  static const _kOnboard = 'saifi_onboarded';
  static const _kDark = 'saifi_dark';
  static const _kDemo = 'saifi_demo';
  static const _kSaved = 'saifi_saved';
  static const _kHistory = 'saifi_speed_history';

  static late SharedPreferences _p;

  static Future<void> init() async {
    _p = await SharedPreferences.getInstance();
  }

  static bool get onboarded => _p.getBool(_kOnboard) ?? false;
  static Future<void> setOnboarded(bool v) => _p.setBool(_kOnboard, v);

  static bool get dark => _p.getBool(_kDark) ?? true;
  static Future<void> setDark(bool v) => _p.setBool(_kDark, v);

  static bool get demo => _p.getBool(_kDemo) ?? false;
  static Future<void> setDemo(bool v) => _p.setBool(_kDemo, v);

  static List<SavedNetwork> loadSaved() {
    final raw = _p.getString(_kSaved);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list.map((e) => SavedNetwork.fromJson(e)).toList();
  }

  static Future<void> saveAll(List<SavedNetwork> nets) {
    return _p.setString(_kSaved, jsonEncode(nets.map((e) => e.toJson()).toList()));
  }

  static List<double> loadHistory() {
    final raw = _p.getStringList(_kHistory) ?? [];
    return raw.map((e) => double.tryParse(e) ?? 0).toList();
  }

  static Future<void> pushHistory(double mbps) {
    final list = loadHistory();
    list.add(mbps);
    while (list.length > 20) {
      list.removeAt(0);
    }
    return _p.setStringList(_kHistory, list.map((e) => e.toStringAsFixed(2)).toList());
  }

  static Future<void> clearAll() async {
    await _p.remove(_kSaved);
    await _p.remove(_kHistory);
  }
}
