import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/quran_controller.dart';
import '../controllers/audio_controller.dart';
import '../controllers/progress_controller.dart';
import '../models/ayah_model.dart';

class SurahReaderScreen extends StatefulWidget {
  final int? surahNumber;
  final String? surahName;
  final int? juzNumber;
  final int? initialAyahNumber;

  const SurahReaderScreen({
    super.key,
    this.surahNumber,
    this.surahName,
    this.juzNumber,
    this.initialAyahNumber,
  }) : assert(surahNumber != null || juzNumber != null);

  @override
  State<SurahReaderScreen> createState() => _SurahReaderScreenState();
}

class _SurahReaderScreenState extends State<SurahReaderScreen> {
  final QuranController quranController = Get.find<QuranController>();
  final AudioController audioController = Get.put(AudioController());
  final ProgressController progressController = Get.find<ProgressController>();

  final ScrollController _scrollController = ScrollController();
  final GlobalKey _listViewKey = GlobalKey();
  List<GlobalKey> _itemKeys = [];
  int _lastTrackedAyah = -1;
  final Set<int> _readAyahsThisSession = {};
  late final Worker _audioIndexWorker;

  @override
  void initState() {
    super.initState();
    _loadData();
    _scrollController.addListener(_onScroll);

    // Auto-scroll to the playing Ayah card when audio moves to a new verse
    _audioIndexWorker = ever(audioController.currentPlayingAyahIndex, (int index) {
      if (index >= 0 && index < quranController.loadedAyahs.length && audioController.isPlaying.value) {
        _scrollToIndex(index);
      }
    });
  }

  void _loadData() async {
    if (widget.juzNumber != null) {
      await quranController.loadJuzDetail(widget.juzNumber!);
    } else {
      await quranController.loadSurahDetail(widget.surahNumber!);
    }

    if (quranController.loadedAyahs.isNotEmpty) {
      await audioController.loadAyahs(quranController.loadedAyahs);
      setState(() {
        _itemKeys = List.generate(quranController.loadedAyahs.length, (index) => GlobalKey());
      });

      // Scroll to initial read position if requested
      if (widget.initialAyahNumber != null && widget.initialAyahNumber! > 1 && widget.juzNumber == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToAyah(widget.initialAyahNumber!);
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _audioIndexWorker.dispose();
    audioController.stopAudio();
    super.dispose();
  }

  void _onScroll() {
    if (!mounted || quranController.loadedAyahs.isEmpty || _itemKeys.length != quranController.loadedAyahs.length) return;

    for (int i = 0; i < quranController.loadedAyahs.length; i++) {
      final key = _itemKeys[i];
      final context = key.currentContext;
      if (context != null) {
        final renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox != null && renderBox.hasSize) {
          final position = renderBox.localToGlobal(Offset.zero);
          final viewportRenderBox = _listViewKey.currentContext?.findRenderObject() as RenderBox?;
          if (viewportRenderBox != null) {
            final localPos = viewportRenderBox.globalToLocal(position);
            // If the bottom of the item is below the top of the viewport (with a safety threshold of 50px)
            if (localPos.dy + renderBox.size.height > 50) {
              final ayah = quranController.loadedAyahs[i];
              if (_lastTrackedAyah != ayah.number) {
                _lastTrackedAyah = ayah.number;
                _markAyahAsRead(ayah);
              }
              break;
            }
          }
        }
      }
    }
  }

  void _markAyahAsRead(AyahModel ayah) {
    progressController.updateLastRead(ayah.surahNumber, ayah.surahName, ayah.numberInSurah);
    
    // Prevent duplicate progress increments within the same session
    if (!_readAyahsThisSession.contains(ayah.number)) {
      _readAyahsThisSession.add(ayah.number);
      progressController.incrementProgress(1);
    }
  }

  void _scrollToAyah(int ayahNum) {
    if (quranController.loadedAyahs.isEmpty) return;

    final targetIndex = quranController.loadedAyahs.indexWhere((a) => a.numberInSurah == ayahNum);
    _scrollToIndex(targetIndex);
  }

  void _scrollToIndex(int targetIndex) {
    if (targetIndex <= 0 || targetIndex >= quranController.loadedAyahs.length) return;

    double offset = 0;
    for (int i = 0; i < targetIndex; i++) {
      offset += _estimateItemHeight(quranController.loadedAyahs[i]);
    }

    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
      );
    }
  }

  double _estimateItemHeight(AyahModel ayah) {
    // Base layout padding, margins, and borders (card wrapper)
    double baseHeight = 120.0;
    
    // Arabic text lines estimation (approx 28 chars per line on average screen width)
    int arabicLines = (ayah.text.length / 28).ceil();
    double arabicHeight = arabicLines * 48.0; // ~48px height per line with font size 26
    
    // Urdu text lines estimation (approx 32 chars per line)
    int urduLines = (ayah.urduTranslation.length / 32).ceil();
    double urduHeight = urduLines * 30.0; // ~30px height per line with font size 18
    
    return baseHeight + arabicHeight + urduHeight;
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
        title: Text(
          widget.juzNumber != null ? 'Juz ${widget.juzNumber}' : (widget.surahName ?? ''),
          style: const TextStyle(
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
            icon: const Icon(Icons.settings_voice_rounded, color: Color(0xFFFFD700)),
            onPressed: () => _showReciterSelectionDialog(context),
            tooltip: 'Change Reciter',
          ),
        ],
      ),
      body: Column(
        children: [
          // Content
          Expanded(
            child: Obx(() {
              if (quranController.isLoadingDetail.value) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
                  ),
                );
              }

              if (quranController.errorMessage.isNotEmpty) {
                return Center(
                  child: Text(
                    'Error: ${quranController.errorMessage.value}',
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                );
              }

              final ayahs = quranController.loadedAyahs;
              if (ayahs.isEmpty) {
                return const Center(
                  child: Text(
                    'No Ayahs available.',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }

              return ListView.builder(
                key: _listViewKey,
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                itemCount: ayahs.length,
                itemBuilder: (context, index) {
                  final ayah = ayahs[index];
                  return Obx(() {
                    final isPlaying = audioController.currentPlayingAyahIndex.value == index;
                    return GestureDetector(
                       key: _itemKeys.length > index ? _itemKeys[index] : null,
                      onTap: () {
                        audioController.playAudio(index);
                        _markAyahAsRead(ayah);
                      },
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
                                    widget.juzNumber != null
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
                            // Arabic Text
                            Text(
                              ayah.text,
                              textAlign: TextAlign.right,
                              textDirection: TextDirection.rtl,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontFamily: 'Amiri',
                                height: 1.8,
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
                          ],
                        ),
                      ),
                    );
                  });
                },
              );
            }),
          ),
          
          // Sticky Audio Player Control Bar
          Container(
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
                  // Currently Playing Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Obx(() => Text(
                              audioController.selectedReciterName.value,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )),
                        const SizedBox(height: 4),
                        Obx(() {
                          final idx = audioController.currentPlayingAyahIndex.value;
                          final text = idx >= 0 ? 'Playing Ayah ${idx + 1}' : 'Not Playing';
                          return Text(
                            text,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 10,
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  
                  // Controls
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
                      Obx(() {
                        final isBuffering = audioController.isBuffering.value;
                        final isPlaying = audioController.isPlaying.value;
                        return GestureDetector(
                          onTap: isBuffering ? null : () => audioController.togglePlayPause(),
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [Color(0xFFFFD700), Color(0xFFF59E0B)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: isBuffering
                                ? const Padding(
                                    padding: EdgeInsets.all(14.0),
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : Icon(
                                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                    color: const Color(0xFF070B16),
                                    size: 28,
                                  ),
                          ),
                        );
                      }),
                      IconButton(
                        icon: const Icon(Icons.skip_next_rounded),
                        color: Colors.white,
                        onPressed: () {
                          final idx = audioController.currentPlayingAyahIndex.value;
                          final total = quranController.loadedAyahs.length;
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
          ),
        ],
      ),
    );
  }
}
