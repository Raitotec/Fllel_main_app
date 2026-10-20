
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:babco/Routes/route_constants.dart';

import '../Api/DataApi.dart';
import '../Api/Login/LoginCompanyApi.dart';
import '../Constans/Base_Url.dart';
import '../Shared_Data/CompanyScope.dart';
import '../Shared_Data/CompanyData.dart';
import '../Shared_Data/DelegateData.dart';
import '../Shared_Data/ServicesData.dart';


class SplashPage extends StatefulWidget {
  const SplashPage({super.key});
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(backgroundColor: Colors.white,
        body: LayoutBuilder(builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;
          return Stack(children: [
            Positioned.fill(child: CustomPaint(painter: _SplashBrandPainter())),
            Positioned(top: height * .30, left: 0, right: 0,
              child: Column(children: [
                Image.asset('lib/assets/fal_brand.png',
                  width: (width * .58).clamp(180.0, 340.0),
                  height: (width * .58).clamp(180.0, 340.0),
                  fit: BoxFit.contain),
                const Text('خدمات الوقود', textDirection: TextDirection.rtl,
                  style: TextStyle(fontFamily: 'Cairo', color: Color(0xFF1C6096),
                    fontSize: 24, fontWeight: FontWeight.w600)),
              ])),
            Positioned(top: height * .68, left: width * .39, right: width * .39,
              child: ClipRRect(borderRadius: BorderRadius.circular(8),
                child: const LinearProgressIndicator(minHeight: 3,
                  color: Color(0xFFFFCB22), backgroundColor: Color(0xFF1C6096)))),
            if (_failed) Positioned(top: height * .74, left: 24, right: 24, child: Column(children: [
              const Text('تعذّر تحميل إعدادات الشركة', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Cairo', color: Color(0xFF123D63))),
              TextButton(onPressed: _loadData, child: const Text('إعادة المحاولة', style: TextStyle(fontFamily: 'Cairo', color: Color(0xFF1C6096)))),
            ])),
          ]);
        })),
    );
  }

  Future<void> _loadData() async {
    if (mounted) setState(() => _failed = false);
    //5500
    try {
     // if(CompanyData.companyData != null && CompanyData.companyData!.petrolstation_base_url !=null)
      await selectCompanyScope(activeCompanyCode);
      if (!mounted) return;
      final xx = await StartToLogin(context, activeCompanyCode);
      if (!mounted) return;
      if (xx == null || (xx.petrolstation_base_url ?? '').isEmpty) {
        setState(() => _failed = true);
        return;
      }
      setState(() {
        CompanyData.companyData = xx;
      });
      var x = await getDelegateData();
      if (!mounted) return;
      setState(() {
        DelegateData.delegateData = x;
      });
      try
      {
        var x= await GetServices(context);
        if (!mounted) return;
        setState(() {
          NewServicesData.serviceData=x;
        });

      }
      catch(e)
      {
        // Optional services should not block entry to the home screen.
      }
      //4300
        Future.delayed(const Duration(milliseconds: 1), () {
       if (!mounted) return;
       Navigator.pushNamedAndRemoveUntil(context, homeRoute,(Route<dynamic> r)=>false);
      });
    }
    catch(e)
    {
      debugPrint('Splash initialization failed: $e');
      if (mounted) setState(() => _failed = true);
    }
  }

}

class _SplashBrandPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final ring = Paint()..color = const Color(0xFFF5F7F9)
      ..style = PaintingStyle.stroke..strokeWidth = 1.5;
    canvas.drawCircle(Offset(size.width * .5, size.height * .405),
      size.width * .43, ring);
    final yellow = Path()
      ..moveTo(0, size.height * .817)
      ..cubicTo(size.width * .24, size.height * .80,
        size.width * .43, size.height * .86, size.width * .65, size.height)
      ..lineTo(size.width * .39, size.height)
      ..cubicTo(size.width * .27, size.height * .895,
        size.width * .13, size.height * .876, 0, size.height * .88)
      ..close();
    canvas.drawPath(yellow, Paint()..color = const Color(0xFFFFCB22));
    final blue = Path()
      ..moveTo(size.width * .22, size.height)
      ..cubicTo(size.width * .46, size.height * .83,
        size.width * .71, size.height * .758, size.width, size.height * .735)
      ..lineTo(size.width, size.height * .85)
      ..cubicTo(size.width * .72, size.height * .89,
        size.width * .65, size.height * .94, size.width * .58, size.height)
      ..close();
    canvas.drawPath(blue, Paint()..color = const Color(0xFF1C6096));
  }
  @override
  bool shouldRepaint(covariant _SplashBrandPainter oldDelegate) => false;
}
