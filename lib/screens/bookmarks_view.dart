import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/ayah_model.dart';
import '../controllers/bookmark_controller.dart';
import '../controllers/audio_controller.dart';
import '../widgets/ayah_card.dart';
import '../widgets/islamic_pattern_painter.dart';

class BookmarksView extends StatefulWidget {
  const BookmarksView({super.key});

  @override
  State<BookmarksView> createState() => _BookmarksViewState();
}

class _BookmarksViewState extends State<BookmarksView> {
  final BookmarkController bookmarkController = Get.find<BookmarkController>();
  final AudioController audioController = Get.find<AudioController>();
  late final StreamSubscription _bookmarkSubscription;

  @override
  void initState() {
    super.initState();
    
    // 1. Initial load of bookmarks into the audio player playlist
    if (bookmarkController.bookmarkedAyahs.isNotEmpty) {
      audioController.loadAyahs(bookmarkController.bookmarkedAyahs);
    }

    // 2. Keep the audio player playlist reactive to changes (e.g. if a user deletes a bookmark)
    _bookmarkSubscription = bookmarkController.bookmarkedAyahs.listen((List<AyahModel> list) {
      if (list.isNotEmpty) {
        audioController.loadAyahs(list);
      } else {
        audioController.stopAudio();
      }
    });
  }

  @override
  void dispose() {
    _bookmarkSubscription.cancel();
    audioController.stopAudio();
    super.dispose();
  }

  void _showReciterSelectionDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111827),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Reciter',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              ...audioController.availableReciters.map((reciter) {
                return ListTile(
                  title: Text(
                    reciter['name']!,
                    style: const TextStyle(color: Colors.white),
                  ),
                  trailing: Obx(() => audioController.selectedReciterId.value == reciter['id']
                      ? const Icon(Icons.check_circle, color: Color(0xFFFFD700))
                      : const SizedBox()),
                  onTap: () {
                    audioController.changeReciter(reciter['id']!, reciter['name']!);
                    Get.back();
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070B16), // Dark premium background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Saved Bookmarks',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.mic, color: Color(0xFFFFD700)),
            onPressed: () => _showReciterSelectionDialog(context),
            tooltip: 'Change Reciter',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background lattice overlay
          Positioned.fill(
            child: CustomPaint(
              painter: IslamicPatternPainter(
                color: const Color(0xFFFFD700),
                strokeWidth: 0.8,
              ),
            ),
          ),
          
          Column(
            children: [
              Expanded(
                child: Obx(() {
                  final bookmarks = bookmarkController.bookmarkedAyahs;
                  
                  if (bookmarks.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFFFD700).withOpacity(0.05),
                              border: Border.all(
                                color: const Color(0xFFFFD700).withOpacity(0.2),
                                width: 1.5,
                              ),
                            ),
                            child: const Icon(
                              Icons.bookmark_border_rounded,
                              color: Color(0xFFFFD700),
                              size: 48,
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'No Bookmarks Saved',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap the bookmark icon on any Ayah card\nto save it here.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    itemCount: bookmarks.length,
                    itemBuilder: (context, index) {
                      final ayah = bookmarks[index];
                      return AyahCard(
                        ayah: ayah,
                        index: index,
                        showSurahName: true,
                        onTap: () {
                          audioController.playAudio(index);
                        },
                      );
                    },
                  );
                }),
              ),
              
              // Audio control panel overlay if playing
              Obx(() {
                final isPlaying = audioController.isPlaying.value;
                final currentIdx = audioController.currentPlayingAyahIndex.value;
                
                if (!isPlaying && currentIdx == -1) {
                  return const SizedBox.shrink();
                }

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 20,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                audioController.selectedReciterName.value,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                currentIdx >= 0 && currentIdx < bookmarkController.bookmarkedAyahs.length
                                    ? 'Playing: ${bookmarkController.bookmarkedAyahs[currentIdx].surahName} • Ayah ${bookmarkController.bookmarkedAyahs[currentIdx].numberInSurah}'
                                    : 'Playing Bookmark',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.skip_previous_rounded),
                              color: Colors.white,
                              onPressed: () {
                                final idx = audioController.currentPlayingAyahIndex.value;
                                if (idx > 0) audioController.playAudio(idx - 1);
                              },
                            ),
                            GestureDetector(
                              onTap: () => audioController.togglePlayPause(),
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [Color(0xFFFFD700), Color(0xFFF59E0B)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: Icon(
                                  isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                  color: const Color(0xFF070B16),
                                  size: 24,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.skip_next_rounded),
                              color: Colors.white,
                              onPressed: () {
                                final idx = audioController.currentPlayingAyahIndex.value;
                                final total = bookmarkController.bookmarkedAyahs.length;
                                if (idx >= 0 && idx < total - 1) {
                                  audioController.playAudio(idx + 1);
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }
}
