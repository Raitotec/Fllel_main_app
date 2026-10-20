import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Shared_View/FalDesign.dart';
import 'Evaluation/QrScannerView.dart';

class ServicesReviewsPage extends StatefulWidget {
  const ServicesReviewsPage({super.key});
  @override
  State<ServicesReviewsPage> createState() => _ScannerState();
}
class _ScannerState extends State<ServicesReviewsPage> {
  final _controller = MobileScannerController();
  bool _opening = false;
  String? _result;
  Future<void> _detect(BarcodeCapture capture) async {
    if (_opening || _result != null) return;
    final raw = capture.barcodes.map((item) => item.rawValue).whereType<String>().where((item) => item.trim().isNotEmpty).firstOrNull;
    if (raw == null) return;
    setState(() { _opening = true; _result = raw; });
    try {
      await _controller.stop();
      final uri = Uri.tryParse(raw.trim());
      if (uri == null || !['http', 'https'].contains(uri.scheme) || uri.host.isEmpty) throw const FormatException();
      if (!await launchUrl(uri, mode: LaunchMode.inAppBrowserView)) throw const FormatException();
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(falText('تعذّر فتح رابط الرمز', 'Unable to open this code’s link'))));
    } finally { if (mounted) setState(() => _opening = false); }
  }
  Future<void> _restart() async {
    if (_opening) return;
    setState(() => _result = null);
    try { await _controller.start(); } catch (_) { }
  }
  @override
  void dispose() { _controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => FalPage(title: falText('مسح رمز QR', 'Scan QR code'), loading: _opening,
    body: QrScannerView(controller: _controller, onDetect: _detect, scannedResult: _result, onRestart: _restart));
}
