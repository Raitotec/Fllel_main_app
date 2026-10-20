import 'dart:io';

import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import 'Localization/ScopeModelWrapper.dart';
import 'Localization/TranslationsDelegate.dart';

void main() {
  HttpOverrides.global = new MyHttpOverrides();
  runApp(new ScopeModelWrapper());
}

class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}