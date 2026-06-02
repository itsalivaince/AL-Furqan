import 'dart:math' as math;
import 'package:flutter/material.dart';

class AyahMarker extends StatelessWidget {
  final int number;

  const AyahMarker({super.key, required this.number});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      width: 36,
      height: 36,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer rotated square 1 (0 degrees)
          Transform.rotate(
            angle: 0,
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFFFD700), width: 1.5), // Gold accent
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          // Outer rotated square 2 (45 degrees)
          Transform.rotate(
            angle: 45 * math.pi / 180,
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFFFD700), width: 1.5), // Gold accent
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          // Inner circle
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFFD700).withOpacity(0.1),
            ),
          ),
          // Ayah Number
          Text(
            '$number',
            style: const TextStyle(
              color: Color(0xFFFFD700),
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
