import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Flutter mark in a white tile with an amber "Firebase" badge (as in Figma).
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 80});

  final double size;

  @override
  Widget build(BuildContext context) {
    final badgeSize = size * 0.34;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(size * 0.28),
              border: Border.all(color: AppColors.border),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x140F172A),
                  blurRadius: 16,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: FlutterLogo(size: size * 0.5),
          ),
          Positioned(
            right: -badgeSize * 0.2,
            bottom: -badgeSize * 0.2,
            child: Container(
              width: badgeSize,
              height: badgeSize,
              decoration: BoxDecoration(
                color: AppColors.badge,
                borderRadius: BorderRadius.circular(badgeSize * 0.3),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Icon(
                Icons.local_fire_department_outlined,
                color: Colors.white,
                size: badgeSize * 0.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}