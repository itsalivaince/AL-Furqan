import 'package:get/get.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import 'package:http/http.dart' as http;
import '../models/ayah_model.dart';
import '../services/storage_service.dart';
import '../services/quran_audio_handler.dart';
import 'package:audio_service/audio_service.dart';
import 'progress_controller.dart';

class AudioController extends GetxController {
  final QuranAudioHandler _audioHandler = Get.find<QuranAudioHandler>();
  
  // Available reciters mapping
  final List<Map<String, String>> availableReciters = [
    {'name': 'Qari Syed Sadaqat Ali', 'id': 'ar.syedsadaqatali'},
    {'name': 'Mishary Rashid Alafasy', 'id': 'ar.alafasy'},
    {'name': 'Abdul Basit Murattal', 'id': 'ar.abdulbasitmurattal'},
    {'name': 'Abdurrahmaan As-Sudais', 'id': 'ar.abdurrahmaansudais'},
    {'name': 'Mahmoud Khalil Al-Husary', 'id': 'ar.husary'},
  ];

  final RxString selectedReciterId = 'ar.syedsadaqatali'.obs;
  final RxString selectedReciterName = 'Qari Syed Sadaqat Ali'.obs;
  
  final RxBool isPlaying = false.obs;
  final RxInt currentPlayingAyahIndex = (-1).obs;
  final RxBool isBuffering = false.obs;

  List<AyahModel> _currentAyahs = [];

  @override
  void onInit() {
    super.onInit();
    _initAudioSession();
    
    final storage = Get.find<StorageService>();
    String savedId = storage.selectedReciterId;
    
    // FIX: Catch the glitch where an old integer like "2" or "0" is saved in memory
    if (savedId.isEmpty || savedId.length < 5) {
      savedId = 'ar.syedsadaqatali'; 
    }
    
    selectedReciterId.value = savedId;
    selectedReciterName.value = availableReciters.firstWhere(
      (r) => r['id'] == selectedReciterId.value,
      orElse: () => availableReciters.first,
    )['name']!;
    
    // Listen to player state changes
    _audioHandler.player.playerStateStream.listen((state) {
      isPlaying.value = state.playing;
      isBuffering.value = state.processingState == ProcessingState.buffering || 
                          state.processingState == ProcessingState.loading;
    });

    // Listen to current index changes to sync playing index and trigger last read updates
    _audioHandler.player.currentIndexStream.listen((index) {
      if (index != null && _currentAyahs.isNotEmpty) {
        // Interleaved layout: even index = Arabic, odd index = Urdu translation
        final ayahIndex = index ~/ 2;
        currentPlayingAyahIndex.value = ayahIndex;

        // Auto-update last read when moving to a new Ayah
        if (index % 2 == 0 && ayahIndex < _currentAyahs.length) {
          try {
             final ayah = _currentAyahs[ayahIndex];
             
             // Map current Ayah to background media notification
             _audioHandler.mediaItem.add(
               MediaItem(
                 id: '${selectedReciterId.value}_${ayah.number}',
                 title: 'Ayah ${ayah.numberInSurah}',
                 album: ayah.surahName,
                 artist: selectedReciterName.value,
                 artUri: Uri.parse('asset:///assets/images/app_icon.png'),
               )
             );

             // Ensure ProgressController is active before updating
             if (Get.isRegistered<ProgressController>()) {
               final progressController = Get.find<ProgressController>();
               progressController.updateLastRead(ayah.surahNumber, ayah.surahName, ayah.numberInSurah);
             }
          } catch (e) {
             print("Error updating resume dashboard: $e");
          }
        }
      } else {
        currentPlayingAyahIndex.value = -1;
      }
    });
  }

  Future<void> _initAudioSession() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
    } catch (e) {
      print('Error initializing AudioSession: $e');
    }
  }

  void changeReciter(String id, String name) async {
    selectedReciterId.value = id;
    selectedReciterName.value = name;
    await Get.find<StorageService>().setSelectedReciterId(id);
    
    bool wasPlaying = isPlaying.value;
    int resumeIndex = currentPlayingAyahIndex.value;
    
    await stopAudio();
    if (_currentAyahs.isNotEmpty) {
      isBuffering.value = true;
      await loadAyahs(_currentAyahs);
      isBuffering.value = false;
      
      // Auto-resume playback with the new reciter
      if (wasPlaying && resumeIndex != -1) {
        await playAudio(resumeIndex);
      }
    }
  }

  String _getAudioIdentifier(String id) {
    if (id == 'ar.syedsadaqatali') {
      return 'ar.alafasy'; // Fallback to Alafasy for CDN
    }
    return id;
  }

  Future<void> loadAyahs(List<AyahModel> ayahs) async {
    _currentAyahs = ayahs;
    await stopAudio();

    // FIX: Removed the illegal `setAudioSource(null)` that was crashing the app!

    final List<AudioSource> sources = [];
    final reciterId = _getAudioIdentifier(selectedReciterId.value);

    for (var ayah in _currentAyahs) {
      if (ayah.number <= 0) continue;

      final arabicUrl = 'https://cdn.islamic.network/quran/audio/64/$reciterId/${ayah.number}.mp3';
      final urduUrl = 'https://cdn.islamic.network/quran/audio/64/ur.khan/${ayah.number}.mp3';

      // FIX: Safely re-implemented LockCachingAudioSource for offline capability
      sources.add(LockCachingAudioSource(Uri.parse(arabicUrl)));
      sources.add(LockCachingAudioSource(Uri.parse(urduUrl)));
    }

    try {
      if (_currentAyahs.isNotEmpty) {
      try {
        final firstUrl = 'https://cdn.islamic.network/quran/audio/64/$reciterId/${_currentAyahs[0].number}.mp3';
        final response = await http.head(Uri.parse(firstUrl));
        final contentType = response.headers['content-type'] ?? 'unknown';
        print('PAYLOAD INTEGRITY CHECK - URL: $firstUrl, Status: ${response.statusCode}, Content-Type: $contentType');
        if (contentType.contains('text/html')) {
          print('WARNING: Content-Type is text/html. Rate limit or invalid response detected!');
        }
      } catch (e) {
        print('PAYLOAD INTEGRITY CHECK ERROR: $e');
      }
    }
      await _audioHandler.player.setAudioSource(
        ConcatenatingAudioSource(children: sources),
        initialIndex: 0,
        initialPosition: Duration.zero,
      );
      print('Audio source set successfully with ${sources.length} queued items.');
    } catch (e) {
      print('Error setting audio source: $e');
    }
  }

  Future<void> playAudio(int index) async {
    if (_currentAyahs.isEmpty || index < 0 || index >= _currentAyahs.length) return;

    try {
      final playlistIndex = index * 2;
      print('Playing Audio at playlist index: $playlistIndex');

      await _audioHandler.player.setVolume(1.0);
      await _audioHandler.player.setSpeed(1.0);
      await _audioHandler.player.setLoopMode(LoopMode.off);

      final session = await AudioSession.instance;
      await session.setActive(true);

      await _audioHandler.player.seek(Duration.zero, index: playlistIndex);
      await _audioHandler.play();
    } catch (e) {
      print('Error playing audio: $e');
      stopAudio();
    }
  }

  Future<void> togglePlayPause() async {
    if (isPlaying.value) {
      await _audioHandler.pause();
    } else {
      if (currentPlayingAyahIndex.value == -1 && _currentAyahs.isNotEmpty) {
        await playAudio(0);
      } else {
        await _audioHandler.player.setVolume(1.0);
        await _audioHandler.player.setSpeed(1.0);
        await _audioHandler.player.setLoopMode(LoopMode.off);

        final session = await AudioSession.instance;
        await session.setActive(true);

        await _audioHandler.play();
      }
    }
  }

  Future<void> stopAudio() async {
    await _audioHandler.stop();
  }

  @override
  void onClose() {
    super.onClose();
  }
}