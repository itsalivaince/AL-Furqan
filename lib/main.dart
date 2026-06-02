import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:audio_service/audio_service.dart';
import 'services/storage_service.dart';
import 'services/notification_service.dart';
import 'services/quran_audio_handler.dart';
import 'controllers/progress_controller.dart';
import 'controllers/quran_controller.dart';
import 'controllers/bookmark_controller.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 1. Initialize background services
    await NotificationService().init();
    final audioHandler = await AudioService.init(
      builder: () => QuranAudioHandler(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.antigravity.quranapp.channel.audio',
        androidNotificationChannelName: 'Quran Audio Playback',
        androidNotificationOngoing: true,
        androidStopForegroundOnPause: true,
        androidNotificationIcon: 'mipmap/launcher_icon',
        notificationColor: Color(0xFF070B16),
      ),
    );
    Get.put<QuranAudioHandler>(audioHandler as QuranAudioHandler);

    // 2. Initialize persistent storage
    await Get.putAsync(() => StorageService().init());

    // 3. Inject reactive controllers
    Get.put(ProgressController());
    Get.put(QuranController());
    Get.put(BookmarkController());
  } catch (e, stack) {
    debugPrint("Initialization error: $e\n$stack");
  }

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


