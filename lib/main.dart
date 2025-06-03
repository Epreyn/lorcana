import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/routes/app_pages.dart';
import 'app/bindings/initial_binding.dart';
import 'app/themes/app_theme.dart';

void main() {
  runApp(const LorcanaApp());
}

class LorcanaApp extends StatelessWidget {
  const LorcanaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Lorcana Price Comparator',
      initialBinding: InitialBinding(),
      getPages: AppPages.routes,
      initialRoute: AppRoutes.HOME,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
    );
  }
}
