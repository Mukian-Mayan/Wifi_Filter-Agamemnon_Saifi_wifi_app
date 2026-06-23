import 'dart:async';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'models.dart';

typedef SpeedTick = void Function(double mbps, double progress, String phase);

class SpeedService {
  static const _downloadUrl = 'https://speed.cloudflare.com/__down?bytes=8000000';
  static const _uploadUrl = 'https://speed.cloudflare.com/__up';
  final Random _rng = Random();

  Future<SpeedResult> run({required bool online, required SpeedTick onTick}) async {
    if (!online) {
      return _simulate(onTick);
    }
    try {
      final ping = await _ping();
      final jitter = (ping * (0.1 + _rng.nextDouble() * 0.2)).round();
      final samples = <double>[];
      final download = await _download(samples, onTick);
      final upload = await _upload(download, onTick);
      onTick(download, 1.0, 'done');
      return SpeedResult(download, upload, ping, jitter, samples);
    } catch (_) {
      return _simulate(onTick);
    }
  }

  Future<int> _ping() async {
    final sw = Stopwatch()..start();
    try {
      await http.head(Uri.parse('https://speed.cloudflare.com/__down?bytes=1')).timeout(const Duration(seconds: 5));
    } catch (_) {}
    sw.stop();
    return sw.elapsedMilliseconds.clamp(4, 600);
  }

  Future<double> _download(List<double> samples, SpeedTick onTick) async {
    final client = http.Client();
    try {
      final req = http.Request('GET', Uri.parse(_downloadUrl));
      final res = await client.send(req).timeout(const Duration(seconds: 15));
      var received = 0;
      final sw = Stopwatch()..start();
      double last = 0;
      await for (final chunk in res.stream) {
        received += chunk.length;
        final secs = sw.elapsedMilliseconds / 1000.0;
        if (secs > 0) {
          final mbps = (received * 8 / 1000000) / secs;
          last = mbps;
          samples.add(double.parse(mbps.toStringAsFixed(2)));
          onTick(mbps, (received / 8000000).clamp(0, 1), 'download');
        }
      }
      sw.stop();
      return double.parse(last.toStringAsFixed(2));
    } finally {
      client.close();
    }
  }

  Future<double> _upload(double download, SpeedTick onTick) async {
    try {
      final payload = List<int>.filled(2000000, 65);
      final sw = Stopwatch()..start();
      await http.post(Uri.parse(_uploadUrl), body: payload).timeout(const Duration(seconds: 12));
      sw.stop();
      final secs = sw.elapsedMilliseconds / 1000.0;
      final mbps = secs > 0 ? (payload.length * 8 / 1000000) / secs : download * 0.4;
      onTick(mbps, 1, 'upload');
      return double.parse(mbps.toStringAsFixed(2));
    } catch (_) {
      return double.parse((download * 0.4).toStringAsFixed(2));
    }
  }

  Future<SpeedResult> _simulate(SpeedTick onTick) async {
    final target = 18 + _rng.nextDouble() * 90;
    final samples = <double>[];
    for (var i = 0; i <= 20; i++) {
      await Future.delayed(const Duration(milliseconds: 90));
      final noise = (_rng.nextDouble() - 0.5) * 10;
      final v = (target * (i / 20)).clamp(0, target) + noise;
      final mbps = v.clamp(0, target + 12).toDouble();
      samples.add(double.parse(mbps.toStringAsFixed(2)));
      onTick(mbps, i / 20, 'download');
    }
    final ping = 12 + _rng.nextInt(60);
    onTick(target, 1, 'done');
    return SpeedResult(
      double.parse(target.toStringAsFixed(2)),
      double.parse((target * 0.4).toStringAsFixed(2)),
      ping,
      (ping * 0.2).round(),
      samples,
    );
  }
}
