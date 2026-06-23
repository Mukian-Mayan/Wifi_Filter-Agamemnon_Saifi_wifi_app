import 'package:flutter/material.dart';
import 'models.dart';
import 'storage.dart';
import 'wifi_service.dart';
import 'speed_service.dart';
import 'theme.dart';

enum ScanPhase { idle, scanning, ready }

class WifiFilter {
  bool safeOnly;
  bool fiveGhzOnly;
  int minStrength;
  Set<SecurityLevel> security;

  WifiFilter({
    this.safeOnly = false,
    this.fiveGhzOnly = false,
    this.minStrength = 0,
    Set<SecurityLevel>? security,
  }) : security = security ?? {...SecurityLevel.values};

  bool matches(WifiNetwork n) {
    if (fiveGhzOnly && n.band != '5 GHz') return false;
    if (n.strength < minStrength) return false;
    if (!security.contains(n.securityLevel)) return false;
    if (safeOnly && (n.securityLevel == SecurityLevel.open || n.securityLevel == SecurityLevel.weak)) return false;
    return true;
  }

  bool get isActive =>
      safeOnly || fiveGhzOnly || minStrength > 0 || security.length != SecurityLevel.values.length;
}

class AppState extends ChangeNotifier {
  final WifiService wifi = WifiService();
  final SpeedService speed = SpeedService();

  bool dark = true;
  bool demoMode = false;
  bool online = true;
  bool vpnOn = false;

  ScanPhase phase = ScanPhase.idle;
  ScanSource source = ScanSource.demo;
  String statusMessage = 'Ready to scan';

  List<WifiNetwork> networks = [];
  List<SavedNetwork> saved = [];
  List<double> speedHistory = [];
  String query = '';
  WifiFilter filter = WifiFilter();

  String? localIp;
  String? gatewayIp;

  ThemeMode get themeMode => dark ? ThemeMode.dark : ThemeMode.light;

  Future<void> init() async {
    dark = Storage.dark;
    demoMode = Storage.demo;
    saved = Storage.loadSaved();
    speedHistory = Storage.loadHistory();
    online = await wifi.isOnline;
    wifi.onlineStream().listen((v) {
      online = v;
      notifyListeners();
    });
    notifyListeners();
  }

  List<WifiNetwork> get visibleNetworks {
    final q = query.trim().toLowerCase();
    return networks.where((n) {
      if (!filter.matches(n)) return false;
      if (q.isEmpty) return true;
      return n.ssid.toLowerCase().contains(q) || n.bssid.toLowerCase().contains(q) || n.vendor.toLowerCase().contains(q);
    }).toList();
  }

  WifiNetwork? get connected {
    for (final n in networks) {
      if (n.isConnected) return n;
    }
    return null;
  }

  int get safeCount => networks.where((n) => assessRisk(n, networks).level == RiskLevel.safe).length;
  int get riskyCount => networks.where((n) => assessRisk(n, networks).level == RiskLevel.danger).length;

  Future<void> toggleDark() async {
    dark = !dark;
    await Storage.setDark(dark);
    notifyListeners();
  }

  Future<void> setDemo(bool v) async {
    demoMode = v;
    await Storage.setDemo(v);
    notifyListeners();
  }

  void setQuery(String q) {
    query = q;
    notifyListeners();
  }

  void applyFilter(WifiFilter f) {
    filter = f;
    notifyListeners();
  }

  Future<void> runScan() async {
    phase = ScanPhase.scanning;
    statusMessage = 'Scanning the airwaves...';
    notifyListeners();

    final outcome = await wifi.scan(forceDemo: demoMode);
    networks = outcome.networks;
    source = outcome.source;
    statusMessage = outcome.message;
    vpnOn = await wifi.vpnActive();
    localIp = await wifi.localIp();
    gatewayIp = await wifi.gatewayIp();

    _recordSeen();
    phase = ScanPhase.ready;
    notifyListeners();
  }

  void _recordSeen() {
    for (final n in networks) {
      final m = computeMetrics(n, networks);
      final risk = assessRisk(n, networks).level;
      final idx = saved.indexWhere((s) => s.bssid == n.bssid);
      if (idx >= 0) {
        final s = saved[idx];
        s.timesSeen += 1;
        s.avgStrength = ((s.avgStrength + n.strength) / 2).round();
        s.securityScore = n.securityScore;
        s.rating = autoRating(m, risk);
        s.comment = autoComment(m, risk);
        s.lastSeen = DateTime.now();
        s.recommendation = autoRecommendation(s);
      } else {
        final s = SavedNetwork(
          bssid: n.bssid,
          ssid: n.displayName,
          avgStrength: n.strength,
          securityScore: n.securityScore,
          rating: autoRating(m, risk),
          comment: autoComment(m, risk),
        );
        s.recommendation = autoRecommendation(s);
        saved.add(s);
      }
    }
    Storage.saveAll(saved);
  }

  Future<void> recordSpeed(SpeedResult r, WifiNetwork? net) async {
    speedHistory.add(r.download);
    while (speedHistory.length > 20) {
      speedHistory.removeAt(0);
    }
    await Storage.pushHistory(r.download);
    if (net != null) {
      final idx = saved.indexWhere((s) => s.bssid == net.bssid);
      if (idx >= 0) {
        saved[idx].lastSpeed = r.download;
        if (r.download > saved[idx].bestSpeed) saved[idx].bestSpeed = r.download;
        final m = computeMetrics(net, networks, measuredMbps: r.download);
        saved[idx].rating = autoRating(m, assessRisk(net, networks).level);
        saved[idx].recommendation = autoRecommendation(saved[idx]);
        await Storage.saveAll(saved);
      }
    }
    notifyListeners();
  }

  Future<void> clearData() async {
    saved = [];
    speedHistory = [];
    await Storage.clearAll();
    notifyListeners();
  }

  Color colorForScore(int score) => riskColor(score);
}
