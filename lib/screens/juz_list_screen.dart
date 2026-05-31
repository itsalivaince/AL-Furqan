import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'surah_reader_screen.dart';

class JuzListScreen extends StatelessWidget {
  const JuzListScreen({super.key});

  static const List<String> juzNames = [
    'Alif Lam Mim',
    'Sayaqool',
    'Tilkal Rusul',
    'Lan Tanaloo',
    'Wal Muhsanat',
    'La Yuhibbullah',
    'Wa Iza Samiu',
    'Wa Lau Annana',
    'Qal Al-Mala\'u',
    'Wa\'la Mu',
    'Ya\'taziroon',
    'Wa Ma Min Dabbah',
    'Wa Ma Ubarri\'u',
    'Rubama',
    'Subhana Alladhi',
    'Qal Alam',
    'Aqtaraba',
    'Qad Aflaha',
    'Wa Qal Alladhina',
    'Amman Khalaqa',
    'Otlu Ma Oohiya',
    'Wa Manyaqnut',
    'Wa Maliya',
    'Faman Azlam',
    'Ilaehi Yuraddu',
    'Ha\'meem',
    'Qala Fama Khatbukum',
    'Qad Sami\'a Allah',
    'Tabaraka Alladhi',
    'Amma Yatasa\'aloon',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070B16), // Dark premium background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Juz Index',
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
      ),
      body: ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        itemCount: 30,
        itemBuilder: (context, index) {
          final juzNumber = index + 1;
          final juzName = juzNames[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.08),
                width: 1,
              ),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              onTap: () {
                Get.to(() => SurahReaderScreen(
                      juzNumber: juzNumber,
                    ));
              },
              leading: Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$juzNumber',
                  style: const TextStyle(
                    color: Color(0xFFFFD700),
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
              title: Text(
                'Juz $juzNumber',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                juzName.toUpperCase(),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                  letterSpacing: 1.0,
                ),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white.withOpacity(0.2),
                size: 16,
              ),
            ),
          );
        },
      ),
    );
  }
}
