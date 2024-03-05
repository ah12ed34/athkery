import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'constrant.dart';
import 'screens/home.dart';
import 'package:get/get.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: kPrimaryColor, // لون خلفية الشريط السفلي
      systemNavigationBarIconBrightness: Brightness.light, // لون الأيقونات
    ));

    return GetMaterialApp(
      //  debugShowCheckedModeBanner: false,
      title: 'Elcterc Store',
      theme: ThemeData(
        //  textTheme: GoogleFonts.almaraiTextTheme(Theme.of(context).textTheme),
        primaryColor: kPrimaryColor,
        accentColor: kPrimaryColor,
      ),
      localizationsDelegates: const {
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      },
      supportedLocales: {
        const Locale('ar'),
        const Locale('en'),
      },
      locale: const Locale('ar'),
      home: const Home(),
    );
  }
}
