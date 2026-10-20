import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:scoped_model/scoped_model.dart';

import 'Localization/ScopeModelWrapper.dart';
import 'Localization/TranslationsDelegate.dart';
import 'Routes/custom_router.dart';
import 'package:sizer/sizer.dart';

import 'Routes/route_constants.dart';
import 'Shared_Data/CompanyData.dart';
import 'Shared_Data/DelegateData.dart';

import 'package:flutter_localizations/flutter_localizations.dart';

import 'ViewModels/LoginViewModel/LoginViewModel.dart';

final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();



class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  MaterialColor MainColor = const MaterialColor(
    0xff0b4c6c, // 0% comes in here, this will be color picked if no shade is selected when defining a Color property which doesn’t require a swatch.
    const <int, Color>{
      50: const Color(0xff0b4c6c ),//10%
      100: const Color(0xff0b4c6c),//20%
      200: const Color(0xff0b4c6c),//30%
      300: const Color(0xff0b4c6c),//40%
      400: const Color(0xff0b4c6c),//50%
      500: const Color(0xff0b4c6c),//60%
      600: const Color(0xff0b4c6c),//70%
      700: const Color(0xff0b4c6c),//80%
      800: const Color(0xff0b4c6c),//90%
      900: const Color(0xff0b4c6c),//100%
    },
  );
  @override
  void didChangeDependencies() {

    try {
      getDelegateData();
      getCompanyData();
    }
    catch(e){
      print("*eeee"+e.toString());
      return null;
    }


    super.didChangeDependencies();
  }
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<AppModel>(
        builder: (context, child, model) =>
            MultiProvider(
                providers: [
                  ChangeNotifierProvider(create: (_)=> LoginViewModel()),
                 ],
                child:
            Sizer(
                builder: (context, orientation, deviceType) {
                  return
                    MaterialApp(
                      locale: model.appLocal,
                      localizationsDelegates: const [
                        TranslationsDelegate(),
                        GlobalMaterialLocalizations.delegate,
                        GlobalWidgetsLocalizations.delegate,
                        GlobalCupertinoLocalizations.delegate
                      ],
                      supportedLocales: const [
                        Locale('ar', ''), // Arabic
                        Locale('en', ''), // English
                      ],
                      debugShowCheckedModeBanner: false,
                      color: Colors.white,
                      theme: ThemeData(fontFamily: 'Cairo', colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1C6096)), scaffoldBackgroundColor: Colors.white),
                      title: "خدمات الوقود",
                      navigatorObservers: [routeObserver],
                      onGenerateRoute: CustomRouter.generatedRoute,
                      initialRoute: splashRoute,
                    );
                }
            )

            )    );
  }
}

