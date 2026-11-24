import 'package:flutter/material.dart';

class Sector {
  const Sector({
    required this.id,
    required this.titleEn,
    required this.titleAr,
    required this.icon,
    required this.tint,
    this.descriptionEn = '',
    this.descriptionAr = '',
  });

  final String id;
  final String titleEn;
  final String titleAr;
  final String descriptionEn;
  final String descriptionAr;
  final IconData icon;
  final Color tint;
}
