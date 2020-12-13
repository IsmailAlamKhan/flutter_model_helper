import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:model_help/home.dart';
import 'package:model_help/model_controller.dart';

Future<void> main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Model Helper',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      darkTheme: ThemeData(
        // primaryColor: Color(0xFF8BE9FD),
        accentColor: Color(0xFFffa65c),
        textTheme: GoogleFonts.poppinsTextTheme(),
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Color(0xFF241e30),
        appBarTheme: AppBarTheme(
          elevation: 6,
        ),
      ),
      initialBinding: BindingsBuilder.put(() => Get.put(ModelController())),
      themeMode: ThemeMode.dark,
      home: Home(),
    );
  }
}
