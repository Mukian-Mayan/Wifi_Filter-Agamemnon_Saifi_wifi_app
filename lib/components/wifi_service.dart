import 'dart:io';
import 'package:wifi_scan/wifi_scan.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'models.dart';

enum ScanSource { live, connectedOnly, demo }

class ScanOutcome {
  final List<WifiNetwork> networks;
  final ScanSource source;
  final String message;
  const ScanOutcome(this.networks, this.source, this.message);
}

class WifiService {
  final NetworkInfo _info = NetworkInfo();
  final Connectivity _conn = Connectivity();

  Future<bool> get isOnline async {
    final r = await _conn.checkConnectivity();
    return !r.contains(ConnectivityResult.none);
  }

  Stream<bool> onlineStream() => _conn.onConnectivityChanged.map((r) => !r.contains(ConnectivityResult.none));

  Future<ScanOutcome> scan({required bool forceDemo}) async {
    if (forceDemo) {
      return ScanOutcome(demoNetworks(), ScanSource.demo, 'Demo data is on. Showing sample networks.');
    }
    if (!(Platform.isAndroid)) {
      final one = await _connectedAsList();
      if (one.isNotEmpty) {
        return ScanOutcome(one, ScanSource.connectedOnly, 'This platform only exposes the connected network. Showing it plus sample data.');
      }
      return ScanOutcome(demoNetworks(), ScanSource.demo, 'Nearby scanning is not allowed here. Showing sample networks.');
    }

    final granted = await _ensureLocation();
    if (!granted) {
      return ScanOutcome(demoNetworks(), ScanSource.demo, 'Location permission denied. Showing sample networks instead.');
    }

    final can = await WiFiScan.instance.canStartScan();
    if (can != CanStartScan.yes) {
      final fallback = await _connectedAsList();
      if (fallback.isNotEmpty) {
        return ScanOutcome(fallback, ScanSource.connectedOnly, 'Scan was blocked by the system. Showing the connected network.');
      }
      return ScanOutcome(demoNetworks(), ScanSource.demo, 'Scanning is throttled by the system. Showing sample networks.');
    }

    await WiFiScan.instance.startScan();
    await Future.delayed(const Duration(milliseconds: 1400));

    final canGet = await WiFiScan.instance.canGetScannedResults();
    if (canGet != CanGetScannedResults.yes) {
      return ScanOutcome(demoNetworks(), ScanSource.demo, 'Could not read results. Showing sample networks.');
    }

    final results = await WiFiScan.instance.getScannedResults();
    if (results.isEmpty) {
      return ScanOutcome(demoNetworks(), ScanSource.demo, 'No networks returned. Showing sample networks.');
    }

    final connectedBssid = (await _safe(() => _info.getWifiBSSID()))?.toUpperCase();
    final pos = await _maybeLocation();
    final mapped = results.map((a) {
      final bssid = a.bssid.toUpperCase();
      return WifiNetwork(
        ssid: a.ssid,
        bssid: bssid,
        rssi: a.level,
        frequency: a.frequency,
        capabilities: a.capabilities,
        isConnected: connectedBssid != null && connectedBssid == bssid,
        isHidden: a.ssid.trim().isEmpty,
        latitude: pos?.latitude,
        longitude: pos?.longitude,
      );
    }).toList();
    mapped.sort((x, y) => y.rssi.compareTo(x.rssi));
    return ScanOutcome(mapped, ScanSource.live, 'Live scan complete. ${mapped.length} networks found.');
  }

  Future<List<WifiNetwork>> _connectedAsList() async {
    final ssid = (await _safe(() => _info.getWifiName()))?.replaceAll('"', '');
    final bssid = await _safe(() => _info.getWifiBSSID());
    if (ssid == null || ssid.isEmpty) return [];
    final connected = WifiNetwork(
      ssid: ssid,
      bssid: (bssid ?? '00:00:00:00:00:00').toUpperCase(),
      rssi: -50,
      frequency: 5180,
      capabilities: '[WPA2-PSK-CCMP][ESS]',
      isConnected: true,
    );
    return [connected, ...demoNetworks().where((d) => !d.isConnected).take(5)];
  }

  Future<bool> _ensureLocation() async {
    final status = await Permission.locationWhenInUse.request();
    return status.isGranted;
  }

  Future<Position?> _maybeLocation() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) return null;
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );
    } catch (_) {
      return null;
    }
  }

  Future<bool> vpnActive() async {
    try {
      final interfaces = await NetworkInterface.list();
      return interfaces.any((i) {
        final n = i.name.toLowerCase();
        return n.contains('tun') || n.contains('ppp') || n.contains('ipsec') || n.contains('utun') || n.contains('wg');
      });
    } catch (_) {
      return false;
    }
  }

  Future<String?> localIp() => _safe(() => _info.getWifiIP());
  Future<String?> gatewayIp() => _safe(() => _info.getWifiGatewayIP());

  Future<T?> _safe<T>(Future<T?> Function() fn) async {
    try {
      return await fn();
    } catch (_) {
      return null;
    }
  }
}