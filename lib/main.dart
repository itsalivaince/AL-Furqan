import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'services/storage_service.dart';
import 'controllers/progress_controller.dart';
import 'controllers/quran_controller.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize persistent storage
  await Get.putAsync(() => StorageService().init());

  // 2. Inject reactive controllers
  Get.put(ProgressController());
  Get.put(QuranController());

  runApp(const QuranApp());
}

class QuranApp extends StatelessWidget {
  const QuranApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'QuranApp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF070B16),
        primaryColor: const Color(0xFF0A2B4E),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF0A2B4E),
          secondary: Color(0xFFFFD700),
          surface: Color(0xFF0C1327),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}


