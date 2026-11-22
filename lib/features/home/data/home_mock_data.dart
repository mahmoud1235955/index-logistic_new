import 'package:flutter/material.dart';

import '../../directory/domain/company.dart';
import '../domain/home_repository.dart';
import '../domain/sector.dart';

/// Local preview fixtures exposed through [HomeRepository].
class HomeMockData implements HomeRepository {
  static const sectors = <Sector>[
    Sector(
      id: 'freight',
      titleEn: 'Freight & customs',
      titleAr: 'الشحن والتخليص',
      icon: Icons.local_shipping_outlined,
      tint: Color(0xFFE9F0F7),
    ),
    Sector(
      id: 'manufacturing',
      titleEn: 'Manufacturing',
      titleAr: 'الصناعة والتصنيع',
      icon: Icons.factory_outlined,
      tint: Color(0xFFF1EEE8),
    ),
    Sector(
      id: 'sourcing',
      titleEn: 'Sourcing & supply',
      titleAr: 'التوريد والمشتريات',
      icon: Icons.inventory_2_outlined,
      tint: Color(0xFFEAF3EF),
    ),
    Sector(
      id: 'trade',
      titleEn: 'Trade services',
      titleAr: 'خدمات التجارة',
      icon: Icons.description_outlined,
      tint: Color(0xFFF2ECF4),
    ),
    Sector(
      id: 'food',
      titleEn: 'Food & agriculture',
      titleAr: 'الغذاء والزراعة',
      icon: Icons.grass_outlined,
      tint: Color(0xFFEEF3E7),
    ),
    Sector(
      id: 'technology',
      titleEn: 'Technology',
      titleAr: 'التقنية',
      icon: Icons.memory_outlined,
      tint: Color(0xFFE9EFF6),
    ),
    Sector(
      id: 'healthcare',
      titleEn: 'Healthcare',
      titleAr: 'الرعاية الصحية',
      icon: Icons.health_and_safety_outlined,
      tint: Color(0xFFF7ECEA),
    ),
    Sector(
      id: 'finance',
      titleEn: 'Finance & insurance',
      titleAr: 'التمويل والتأمين',
      icon: Icons.account_balance_outlined,
      tint: Color(0xFFF4F0E6),
    ),
  ];

  static const companies = <Company>[
    Company(
      name: 'Northstar Freight',
      category: 'Freight forwarding',
      location: 'Rotterdam, Netherlands',
      initials: 'NF',
      accent: 0xFF1D5B8F,
    ),
    Company(
      name: 'Meridian Foods Co.',
      category: 'Food exporter',
      location: 'Alexandria, Egypt',
      initials: 'MF',
      accent: 0xFF21856A,
    ),
    Company(
      name: 'Atlas Components',
      category: 'Industrial manufacturer',
      location: 'Shenzhen, China',
      initials: 'AC',
      accent: 0xFF8A6A48,
    ),
  ];

  @override
  Future<List<Sector>> getSectors() async => sectors;

  @override
  Future<List<Company>> getFeaturedCompanies() async => companies;
}
