import 'dart:math';

enum SecurityLevel { open, weak, secure, strong }

enum RiskLevel { safe, caution, danger }

const Map<String, String> ouiVendors = {
  '00:1A:11': 'Google',
  'F4:F5:E8': 'Google',
  '3C:5A:B4': 'Google',
  '00:0C:42': 'MikroTik',
  '48:8F:5A': 'Tenda',
  'C0:25:E9': 'TP-Link',
  '50:C7:BF': 'TP-Link',
  'AC:84:C6': 'TP-Link',
  '00:1D:0F': 'D-Link',
  '90:94:E4': 'Huawei',
  '24:DF:6A': 'Huawei',
  '08:00:27': 'Virtual',
  '00:50:56': 'Virtual',
};

class WifiNetwork {
  final String ssid;
  final String bssid;
  final int rssi;
  final int frequency;
  final String capabilities;
  final bool isConnected;
  final bool isHidden;
  final double? latitude;
  final double? longitude;
  final DateTime seen;

  WifiNetwork({
    required this.ssid,
    required this.bssid,
    required this.rssi,
    required this.frequency,
    required this.capabilities,
    this.isConnected = false,
    this.isHidden = false,
    this.latitude,
    this.longitude,
    DateTime? seen,
  }) : seen = seen ?? DateTime.now();

  String get displayName => isHidden || ssid.trim().isEmpty ? 'Hidden network' : ssid;

  int get strength {
    final clamped = rssi.clamp(-92, -30);
    return (((clamped + 92) / 62) * 100).round().clamp(0, 100);
  }

  SecurityLevel get securityLevel {
    final c = capabilities.toUpperCase();
    if (c.contains('WPA3') || c.contains('SAE')) return SecurityLevel.strong;
    if (c.contains('WPA2') || c.contains('RSN')) return SecurityLevel.secure;
    if (c.contains('WPA') || c.contains('WEP')) return SecurityLevel.weak;
    return SecurityLevel.open;
  }

  String get securityLabel {
    switch (securityLevel) {
      case SecurityLevel.strong:
        return 'WPA3';
      case SecurityLevel.secure:
        return 'WPA2';
      case SecurityLevel.weak:
        return 'WEP / WPA';
      case SecurityLevel.open:
        return 'Open';
    }
  }

  int get securityScore {
    switch (securityLevel) {
      case SecurityLevel.strong:
        return 100;
      case SecurityLevel.secure:
        return 80;
      case SecurityLevel.weak:
        return 38;
      case SecurityLevel.open:
        return 10;
    }
  }

  String get band => frequency > 4000 ? '5 GHz' : '2.4 GHz';

  int get channel {
    if (frequency >= 2412 && frequency <= 2484) {
      if (frequency == 2484) return 14;
      return ((frequency - 2412) ~/ 5) + 1;
    }
    if (frequency >= 5170 && frequency <= 5825) {
      return ((frequency - 5170) ~/ 5) + 34;
    }
    return 0;
  }

  String get vendor {
    final norm = bssid.toUpperCase();
    final oui = norm.length >= 8 ? norm.substring(0, 8) : '';
    return ouiVendors[oui] ?? 'Unknown vendor';
  }

  Map<String, dynamic> toJson() => {
        'ssid': ssid,
        'bssid': bssid,
        'rssi': rssi,
        'frequency': frequency,
        'capabilities': capabilities,
        'isHidden': isHidden,
        'lat': latitude,
        'lng': longitude,
        'seen': seen.toIso8601String(),
      };

  factory WifiNetwork.fromJson(Map<String, dynamic> j) => WifiNetwork(
        ssid: j['ssid'] ?? '',
        bssid: j['bssid'] ?? '',
        rssi: j['rssi'] ?? -70,
        frequency: j['frequency'] ?? 2412,
        capabilities: j['capabilities'] ?? '',
        isHidden: j['isHidden'] ?? false,
        latitude: (j['lat'] as num?)?.toDouble(),
        longitude: (j['lng'] as num?)?.toDouble(),
        seen: DateTime.tryParse(j['seen'] ?? '') ?? DateTime.now(),
      );
}

class MetricSet {
  final int speed;
  final int strength;
  final int safety;
  final int reliability;
  final int usability;
  final int traffic;

  const MetricSet({
    required this.speed,
    required this.strength,
    required this.safety,
    required this.reliability,
    required this.usability,
    required this.traffic,
  });

  double get overall => (speed + strength + safety + reliability + usability + traffic) / 6;

  List<int> get asList => [speed, strength, safety, reliability, usability, traffic];
  static const List<String> labels = ['Speed', 'Strength', 'Safety', 'Reliable', 'Usable', 'Traffic'];
}

MetricSet computeMetrics(WifiNetwork n, List<WifiNetwork> all, {double? measuredMbps}) {
  final strength = n.strength;
  final safety = n.securityScore;
  final coChannel = all.where((x) => x.channel == n.channel && x.bssid != n.bssid).length;
  final traffic = (100 - coChannel * 12).clamp(8, 100);
  final bandBonus = n.band == '5 GHz' ? 18 : 0;
  final reliability = (strength * 0.5 + traffic * 0.3 + bandBonus + safety * 0.1).round().clamp(0, 100);
  int speed;
  if (measuredMbps != null) {
    speed = ((measuredMbps / 200) * 100).round().clamp(0, 100);
  } else {
    speed = (strength * 0.6 + bandBonus + traffic * 0.2).round().clamp(0, 100);
  }
  final usability = (strength * 0.4 + safety * 0.3 + speed * 0.3).round().clamp(0, 100);
  return MetricSet(
    speed: speed,
    strength: strength,
    safety: safety,
    reliability: reliability,
    usability: usability,
    traffic: traffic,
  );
}

class RiskIssue {
  final String title;
  final String detail;
  final RiskLevel severity;
  const RiskIssue(this.title, this.detail, this.severity);
}

class RiskReport {
  final RiskLevel level;
  final int score;
  final List<RiskIssue> issues;
  const RiskReport(this.level, this.score, this.issues);

  String get headline {
    switch (level) {
      case RiskLevel.safe:
        return 'This network looks safe';
      case RiskLevel.caution:
        return 'Handle this one with care';
      case RiskLevel.danger:
        return 'Avoid sensitive activity here';
    }
  }
}

RiskReport assessRisk(WifiNetwork n, List<WifiNetwork> all) {
  final issues = <RiskIssue>[];
  if (n.securityLevel == SecurityLevel.open) {
    issues.add(const RiskIssue('Open network', 'No encryption at all. Anyone nearby can read what you send.', RiskLevel.danger));
  }
  if (n.securityLevel == SecurityLevel.weak) {
    issues.add(const RiskIssue('Weak security', 'WEP and old WPA are broken in minutes by common tools.', RiskLevel.danger));
  }
  if (n.isHidden) {
    issues.add(const RiskIssue('Hidden name', 'Hidden networks can be used to quietly trick devices into joining.', RiskLevel.caution));
  }
  final twins = all.where((x) => x.ssid == n.ssid && x.bssid != n.bssid && n.ssid.trim().isNotEmpty).toList();
  if (twins.isNotEmpty) {
    issues.add(const RiskIssue('Possible evil twin', 'Another router broadcasts the same name. One of them may be an impostor.', RiskLevel.danger));
  }
  final name = n.ssid.toLowerCase();
  if (name.contains('free') || name.contains('public') || name.contains('guest')) {
    issues.add(const RiskIssue('Open invite name', 'Names like free, public or guest are common bait for fake hotspots.', RiskLevel.caution));
  }
  if (n.vendor == 'Virtual') {
    issues.add(const RiskIssue('Virtual radio', 'This MAC looks like a software access point, sometimes used to relay traffic.', RiskLevel.caution));
  }

  var score = n.securityScore;
  for (final i in issues) {
    score -= i.severity == RiskLevel.danger ? 26 : 11;
  }
  score = score.clamp(0, 100);

  RiskLevel level;
  final hasDanger = issues.any((i) => i.severity == RiskLevel.danger);
  if (score >= 70 && !hasDanger) {
    level = RiskLevel.safe;
  } else if (score >= 40 && !hasDanger) {
    level = RiskLevel.caution;
  } else {
    level = hasDanger ? RiskLevel.danger : RiskLevel.caution;
  }

  if (issues.isEmpty) {
    issues.add(const RiskIssue('No red flags', 'Nothing suspicious from what we can read about this network.', RiskLevel.safe));
  }
  return RiskReport(level, score, issues);
}

class SavedNetwork {
  String bssid;
  String ssid;
  int timesSeen;
  double bestSpeed;
  double lastSpeed;
  int avgStrength;
  int securityScore;
  double rating;
  String comment;
  String recommendation;
  DateTime lastSeen;

  SavedNetwork({
    required this.bssid,
    required this.ssid,
    this.timesSeen = 1,
    this.bestSpeed = 0,
    this.lastSpeed = 0,
    this.avgStrength = 0,
    this.securityScore = 0,
    this.rating = 0,
    this.comment = '',
    this.recommendation = '',
    DateTime? lastSeen,
  }) : lastSeen = lastSeen ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'bssid': bssid,
        'ssid': ssid,
        'timesSeen': timesSeen,
        'bestSpeed': bestSpeed,
        'lastSpeed': lastSpeed,
        'avgStrength': avgStrength,
        'securityScore': securityScore,
        'rating': rating,
        'comment': comment,
        'recommendation': recommendation,
        'lastSeen': lastSeen.toIso8601String(),
      };

  factory SavedNetwork.fromJson(Map<String, dynamic> j) => SavedNetwork(
        bssid: j['bssid'] ?? '',
        ssid: j['ssid'] ?? '',
        timesSeen: j['timesSeen'] ?? 1,
        bestSpeed: (j['bestSpeed'] as num?)?.toDouble() ?? 0,
        lastSpeed: (j['lastSpeed'] as num?)?.toDouble() ?? 0,
        avgStrength: j['avgStrength'] ?? 0,
        securityScore: j['securityScore'] ?? 0,
        rating: (j['rating'] as num?)?.toDouble() ?? 0,
        comment: j['comment'] ?? '',
        recommendation: j['recommendation'] ?? '',
        lastSeen: DateTime.tryParse(j['lastSeen'] ?? '') ?? DateTime.now(),
      );
}

double autoRating(MetricSet m, RiskLevel risk) {
  var base = m.overall / 20;
  if (risk == RiskLevel.danger) base -= 1.4;
  if (risk == RiskLevel.caution) base -= 0.5;
  return double.parse(base.clamp(0, 5).toStringAsFixed(1));
}

String autoComment(MetricSet m, RiskLevel risk) {
  if (risk == RiskLevel.danger) return 'Risky connection. Keep logins and payments off this one.';
  if (m.overall >= 82) return 'Excellent all round. Fast, strong and well secured.';
  if (m.overall >= 64) return 'Solid everyday network with a good balance of speed and safety.';
  if (m.overall >= 45) return 'Usable, but check the signal and security before you trust it.';
  return 'Below par. A better network is probably within reach.';
}

String autoRecommendation(SavedNetwork s) {
  if (s.timesSeen >= 3 && s.rating >= 4) {
    return 'You connect here often and it holds up well. Safe to keep as a favourite.';
  }
  if (s.rating < 2.5) {
    return 'Seen ${s.timesSeen} time(s) and performance stays weak. Consider another network.';
  }
  if (s.timesSeen < 3) {
    return 'Not enough history yet. Keep using it a few more times before fully trusting it.';
  }
  return 'Decent and familiar. Fine for general browsing, stay alert on sensitive tasks.';
}

class SpeedResult {
  final double download;
  final double upload;
  final int ping;
  final int jitter;
  final List<double> samples;
  const SpeedResult(this.download, this.upload, this.ping, this.jitter, this.samples);
}

final Random _rng = Random();

List<WifiNetwork> demoNetworks() {
  final caps = ['[WPA3-SAE][ESS]', '[WPA2-PSK-CCMP][ESS]', '[WPA2-PSK][ESS]', '[WEP][ESS]', '[ESS]'];
  final names = ['Saifi_Home', 'JinjaFiber_5G', 'TRIUMPH_Office', 'Free_Public_WiFi', 'MTN_HotSpot', 'Airtel_4G_Box', 'Campus_Lab', 'Guest_Lounge', 'NetGear_2.4', 'DarkRouter'];
  final out = <WifiNetwork>[];
  for (var i = 0; i < names.length; i++) {
    final f = _rng.nextBool() ? 2412 + _rng.nextInt(11) * 5 : 5180 + _rng.nextInt(8) * 5;
    out.add(WifiNetwork(
      ssid: names[i],
      bssid: _fakeMac(i),
      rssi: -38 - _rng.nextInt(52),
      frequency: f,
      capabilities: caps[i % caps.length],
      isConnected: i == 0,
      isHidden: names[i] == 'DarkRouter',
      latitude: 0.4478 + _rng.nextDouble() * 0.01,
      longitude: 33.2026 + _rng.nextDouble() * 0.01,
    ));
  }
  return out;
}

String _fakeMac(int seed) {
  final base = ['00:1A:11', 'C0:25:E9', '48:8F:5A', '08:00:27', '90:94:E4'];
  final prefix = base[seed % base.length];
  final tail = List.generate(3, (_) => _rng.nextInt(256).toRadixString(16).padLeft(2, '0').toUpperCase()).join(':');
  return '$prefix:$tail';
}
