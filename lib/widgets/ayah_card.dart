import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../models/ayah_model.dart';
import '../controllers/audio_controller.dart';
import '../controllers/bookmark_controller.dart';
import 'ayah_marker.dart';

class AyahCard extends StatelessWidget {
  final AyahModel ayah;
  final int index;
  final bool showSurahName;
  final VoidCallback onTap;

  const AyahCard({
    super.key,
    required this.ayah,
    required this.index,
    this.showSurahName = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final AudioController audioController = Get.find<AudioController>();
    final BookmarkController bookmarkController = Get.find<BookmarkController>();

    return Obx(() {
      final isPlaying = audioController.currentPlayingAyahIndex.value == index;
      return GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(bottom: 24),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isPlaying
                ? const Color(0xFFFFD700).withOpacity(0.1)
                : Colors.white.withOpacity(0.02),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isPlaying
                  ? const Color(0xFFFFD700).withOpacity(0.5)
                  : Colors.white.withOpacity(0.05),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Ayah Number Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      showSurahName
                          ? '${ayah.surahName} • Ayah ${ayah.numberInSurah}'
                          : '${ayah.numberInSurah}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  if (isPlaying)
                    const Icon(Icons.volume_up_rounded, color: Color(0xFFFFD700), size: 18),
                ],
              ),
              const SizedBox(height: 20),
              // Arabic Text with Inline Ayah Marker
              RichText(
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${ayah.text} ',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontFamily: 'Amiri',
                        height: 1.8,
                      ),
                    ),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: AyahMarker(number: ayah.numberInSurah),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Divider
              Divider(color: Colors.white.withOpacity(0.1)),
              const SizedBox(height: 16),
              // Translation
              Text(
                ayah.urduTranslation,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 18,
                  height: 1.6,
                  fontFamily: 'Jameel Noori Nastaleeq',
                ),
              ),
              const SizedBox(height: 16),
              // Action Bar: Play, Bookmark, Copy
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    icon: Icon(
                      bookmarkController.isBookmarked(ayah)
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      color: const Color(0xFFFFD700),
                    ),
                    onPressed: () => bookmarkController.toggleBookmark(ayah),
                    tooltip: 'Bookmark Ayah',
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.copy_rounded,
                      color: Colors.white60,
                    ),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(
                        text: '${ayah.text}\n\n${ayah.urduTranslation}',
                      ));
                      Get.snackbar(
                        'Copied',
                        'Ayah copied to clipboard',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: const Color(0xFF10B981), // Emerald/Green background
                        colorText: Colors.white,
                        duration: const Duration(seconds: 2),
                        margin: const EdgeInsets.all(16),
                      );
                    },
                    tooltip: 'Copy Ayah',
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}
