import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../Shared_View/FalDesign.dart';

class QrScannerView extends StatelessWidget {
  const QrScannerView({super.key, required this.controller, required this.onDetect, this.scannedResult, required this.onRestart});
  final MobileScannerController controller;
  final void Function(BarcodeCapture) onDetect;
  final String? scannedResult;
  final VoidCallback onRestart;
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 20), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    Text(falText('وجّه الكاميرا نحو الرمز', 'Point the camera at the code'), textAlign: TextAlign.center, style: falStyle(18, weight: FontWeight.w800)),
    const SizedBox(height: 8), Text(falText('استخدم رمز المحطة أو الخدمة لفتح نموذج التقييم', 'Scan the station or service code to open its evaluation'), textAlign: TextAlign.center, style: falStyle(12, weight: FontWeight.w400)),
    const SizedBox(height: 18), Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(18), child: Stack(fit: StackFit.expand, children: [
      MobileScanner(controller: controller, onDetect: onDetect, errorBuilder: (context, error) => ColoredBox(color: const Color(0xFF123D63), child: Center(child: Padding(padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.no_photography_outlined, color: Colors.white, size: 48), const SizedBox(height: 16),
          Text(falText('تعذّر تشغيل الكاميرا', 'Unable to start the camera'), style: falStyle(18, color: Colors.white)), const SizedBox(height: 10),
          Text(falText('تحقق من السماح للتطبيق باستخدام الكاميرا ثم أعد المحاولة', 'Allow camera access in app settings and try again'), textAlign: TextAlign.center, style: falStyle(13, color: Colors.white, weight: FontWeight.w400))]))))),
      const IgnorePointer(child: CustomPaint(painter: _ScanFrame())),
      Positioned(left: 14, bottom: 14, child: IconButton.filled(tooltip: falText('الإضاءة', 'Flashlight'), style: IconButton.styleFrom(backgroundColor: const Color(0xAA123D63)),
        onPressed: () async { try { await controller.toggleTorch(); } catch (_) { if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(falText('الإضاءة غير متاحة على هذا الجهاز', 'Flashlight is unavailable on this device')))); } },
        icon: const Icon(Icons.flash_on, color: Colors.white))),
    ]))),
    const SizedBox(height: 14), Text(falText(scannedResult == null ? 'مسح الرمز يفتح رابط التقييم' : 'تم التقاط الرمز', scannedResult == null ? 'Scanning opens the evaluation link' : 'Code captured'), textAlign: TextAlign.center, style: falStyle(12)),
    const SizedBox(height: 10), OutlinedButton.icon(onPressed: onRestart, icon: const Icon(Icons.refresh), label: Text(falText('إعادة المسح', 'Scan again'))),
  ]));
}
class _ScanFrame extends CustomPainter {
  const _ScanFrame();
  @override
  void paint(Canvas canvas, Size size) {
    final side = size.shortestSide * .7;
    final rect = Rect.fromCenter(center: size.center(Offset.zero), width: side, height: side);
    final paint = Paint()..color = falGold..strokeWidth = 4..strokeCap = StrokeCap.round..style = PaintingStyle.stroke;
    const length = 28.0;
    for (final point in [rect.topLeft, rect.topRight, rect.bottomLeft, rect.bottomRight]) {
      final x = point.dx < size.width / 2 ? length : -length;
      final y = point.dy < size.height / 2 ? length : -length;
      canvas.drawPath(Path()..moveTo(point.dx + x, point.dy)..lineTo(point.dx, point.dy)..lineTo(point.dx, point.dy + y), paint);
    }
    canvas.drawLine(rect.centerLeft, rect.centerRight, Paint()..color = falBlue..strokeWidth = 2);
  }
  @override
  bool shouldRepaint(covariant _ScanFrame oldDelegate) => false;
}
