import 'dart:async';
import 'package:get/get.dart';
import '../screens/home_dashboard.dart';

class SplashController extends GetxController {
  final RxDouble progress = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    _startTimer();
  }

  void _startTimer() {
    const totalDuration = Duration(seconds: 3);
    const stepDuration = Duration(milliseconds: 30);
    final totalSteps = totalDuration.inMilliseconds / stepDuration.inMilliseconds;
    int currentStep = 0;

    Timer.periodic(stepDuration, (timer) {
      currentStep++;
      progress.value = currentStep / totalSteps;

      if (currentStep >= totalSteps) {
        timer.cancel();
        // Transition to HomeDashboard
        Get.off(
          () => const HomeDashboard(),
          transition: Transition.fadeIn,
          duration: const Duration(milliseconds: 800),
        );
      }
    });
  }
}
