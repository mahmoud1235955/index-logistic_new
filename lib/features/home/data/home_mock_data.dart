import 'package:flutter/material.dart';

import '../../directory/domain/company.dart';
import '../domain/home_repository.dart';
import '../domain/sector.dart';

enum HomeMockScenario {
  available,
  empty,
  error,
  offline,
  expired,
  permissionDenied,
}

/// Local preview fixtures exposed through [HomeRepository].
class HomeMockData implements HomeRepository {
  const HomeMockData({this.scenario = HomeMockScenario.available});

  final HomeMockScenario scenario;

  static const sectors = <Sector>[
    Sector(
      id: 'SEC-01',
      titleEn: 'Food & agricultural produce',
      descriptionEn: 'Agricultural produce and food products for trade.',
      descriptionAr: 'الحاصلات الزراعية والمنتجات الغذائية المخصصة للتجارة.',
      titleAr: 'الأغذية والحاصلات الزراعية',
      icon: Icons.local_shipping_outlined,
      tint: Color(0xFFEEF3E7),
    ),
    Sector(
      id: 'SEC-02',
      titleEn: 'Textiles, clothing & leather',
      descriptionEn: 'Textile materials, clothing, and leather goods.',
      descriptionAr: 'المنسوجات والملابس والمنتجات الجلدية.',
      titleAr: 'المنسوجات والملابس والجلود',
      icon: Icons.factory_outlined,
      tint: Color(0xFFF1EEE8),
    ),
    Sector(
      id: 'SEC-03',
      titleEn: 'Chemicals & fertilizers',
      descriptionEn: 'Chemical products and fertilizers for commercial supply.',
      descriptionAr: 'المنتجات الكيميائية والأسمدة للتوريد التجاري.',
      titleAr: 'الكيماويات والأسمدة',
      icon: Icons.science_outlined,
      tint: Color(0xFFEAF3EF),
    ),
    Sector(
      id: 'SEC-04',
      titleEn: 'Building materials & metals',
      descriptionEn: 'Construction materials and metal products.',
      descriptionAr: 'مواد البناء والمنتجات المعدنية.',
      titleAr: 'مواد البناء والمعادن',
      icon: Icons.construction_outlined,
      tint: Color(0xFFF2ECF4),
    ),
    Sector(
      id: 'SEC-05',
      titleEn: 'Engineering, electronics & household appliances',
      descriptionEn: 'Engineering goods, electronics, and home appliances.',
      descriptionAr: 'المنتجات الهندسية والإلكترونية والأجهزة المنزلية.',
      titleAr: 'الصناعات الهندسية والإلكترونية والأجهزة المنزلية',
      icon: Icons.precision_manufacturing_outlined,
      tint: Color(0xFFE9F0F7),
    ),
    Sector(
      id: 'SEC-06',
      titleEn: 'Medicines & medical supplies',
      descriptionEn: 'Medicines and supplies intended for medical use.',
      descriptionAr: 'الأدوية والمستلزمات المخصصة للاستخدام الطبي.',
      titleAr: 'الأدوية والمستلزمات الطبية',
      icon: Icons.medical_services_outlined,
      tint: Color(0xFFF7ECEA),
    ),
    Sector(
      id: 'SEC-07',
      titleEn: 'Handicrafts & heritage products',
      descriptionEn:
          'Handmade crafts and products connected to cultural heritage.',
      descriptionAr: 'الحرف اليدوية والمنتجات المرتبطة بالتراث الثقافي.',
      titleAr: 'الحرف اليدوية والمنتجات التراثية',
      icon: Icons.palette_outlined,
      tint: Color(0xFFF2ECF4),
    ),
    Sector(
      id: 'SEC-08',
      titleEn: 'Furniture & wood products',
      descriptionEn: 'Furniture and goods made from wood.',
      descriptionAr: 'الأثاث والمنتجات المصنوعة من الخشب.',
      titleAr: 'الأثاث والصناعات الخشبية',
      icon: Icons.chair_alt_outlined,
      tint: Color(0xFFF4F0E6),
    ),
  ];

  static const companies = <Company>[
    Company(
      name: 'Northstar Freight',
      category: 'Freight forwarding',
      businessActivityAr: 'خدمات الشحن',
      country: 'Netherlands',
      countryAr: 'هولندا',
      location: 'Rotterdam, Netherlands',
      initials: 'NF',
      accent: 0xFF1D5B8F,
    ),
    Company(
      name: 'Meridian Foods Co.',
      category: 'Food exporter',
      businessActivityAr: 'تصدير الأغذية',
      country: 'Egypt',
      countryAr: 'مصر',
      location: 'Alexandria, Egypt',
      initials: 'MF',
      accent: 0xFF17806A,
      sectorId: 'SEC-01',
    ),
    Company(
      name: 'Atlas Components',
      category: 'Industrial manufacturer',
      businessActivityAr: 'تصنيع صناعي',
      country: 'China',
      countryAr: 'الصين',
      location: 'Shenzhen, China',
      initials: 'AC',
      accent: 0xFF8A6A48,
    ),
  ];

  @override
  Future<List<Sector>> getSectors() async {
    _throwForScenario();
    return scenario == HomeMockScenario.empty ? const [] : sectors;
  }

  @override
  Future<List<Company>> getFeaturedCompanies() async {
    _throwForScenario();
    return scenario == HomeMockScenario.empty ? const [] : companies;
  }

  void _throwForScenario() {
    final failure = switch (scenario) {
      HomeMockScenario.available || HomeMockScenario.empty => null,
      HomeMockScenario.error => HomeRepositoryFailureKind.error,
      HomeMockScenario.offline => HomeRepositoryFailureKind.offline,
      HomeMockScenario.expired => HomeRepositoryFailureKind.expired,
      HomeMockScenario.permissionDenied =>
        HomeRepositoryFailureKind.permissionDenied,
    };
    if (failure != null) throw HomeRepositoryException(failure);
  }
}
