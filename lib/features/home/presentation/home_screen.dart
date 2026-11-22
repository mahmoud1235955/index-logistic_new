import 'package:flutter/material.dart';

import '../../../core/localization/app_copy.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/index_button.dart';
import '../../../core/widgets/index_search_field.dart';
import '../../../core/widgets/section_heading.dart';
import '../../../features/directory/domain/company.dart';
import '../data/home_mock_data.dart';
import '../domain/sector.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.language, required this.onToggleLanguage});
  final AppLanguage language;
  final VoidCallback onToggleLanguage;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final copy = AppCopy(widget.language);
    return LayoutBuilder(builder: (context, constraints) {
      final mobile = constraints.maxWidth < 760;
      final tablet = constraints.maxWidth < 1080;
      return Scaffold(
        appBar: mobile ? _mobileBar(context, copy) : null,
        body: Column(children: [
          if (!mobile) _desktopHeader(context, copy, tablet),
          Expanded(child: CustomScrollView(slivers: [
            SliverToBoxAdapter(child: Center(child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: AppTokens.maxContentWidth),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: mobile ? 18 : tablet ? 28 : 48),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  const SizedBox(height: 26),
                  _hero(context, copy, mobile),
                  const SizedBox(height: 40),
                  _sectors(context, copy, mobile),
                  const SizedBox(height: 44),
                  _companies(context, copy, mobile),
                  const SizedBox(height: 48),
                ]),
              ),
            ))),
            SliverToBoxAdapter(child: _footer(context, copy)),
          ])),
        ]),
        bottomNavigationBar: mobile ? _mobileNav(context, copy) : null,
      );
    });
  }

  PreferredSizeWidget _mobileBar(BuildContext context, AppCopy copy) => AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 18,
        title: _brand(copy, compact: true),
        actions: [
          IconButton(tooltip: copy.searchHint, onPressed: () => _showSearch(context, copy), icon: const Icon(Icons.search_rounded)),
          IconButton(tooltip: copy.languageButton, onPressed: widget.onToggleLanguage, icon: const Icon(Icons.language_rounded)),
          const SizedBox(width: 8),
        ],
      );

  Widget _desktopHeader(BuildContext context, AppCopy copy, bool tablet) => Container(
        color: AppTokens.white,
        child: SafeArea(bottom: false, child: Center(child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppTokens.maxContentWidth),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: tablet ? 28 : 48, vertical: 15),
            child: Row(children: [
              _brand(copy),
              const SizedBox(width: 36),
              if (!tablet) Expanded(child: IndexSearchField(hint: copy.searchHint, compact: true)) else const Spacer(),
              const SizedBox(width: 28),
              _navLink(copy.network, true),
              _navLink(copy.directory, false),
              if (!tablet) _navLink(copy.opportunities, false),
              if (!tablet) _navLink(copy.insights, false),
              const SizedBox(width: 12),
              TextButton(onPressed: widget.onToggleLanguage, child: Text(copy.languageButton)),
              TextButton(onPressed: () {}, child: Text(copy.signIn)),
              const SizedBox(width: 4),
              IndexButton(label: copy.join, onPressed: () {}),
            ]),
          ),
        ))),
      );

  Widget _brand(AppCopy copy, {bool compact = false}) => Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: compact ? 36 : 40, height: compact ? 36 : 40, decoration: BoxDecoration(color: AppTokens.navy, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.route_rounded, color: Colors.white, size: 22)),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Text(copy.brand, style: const TextStyle(fontSize: 15, letterSpacing: 1.7, height: 1.1, fontWeight: FontWeight.w800, color: AppTokens.navy)),
          Text(copy.brandSub, style: const TextStyle(fontSize: 8, letterSpacing: 2.1, height: 1.45, fontWeight: FontWeight.w700, color: AppTokens.muted)),
        ]),
      ]);

  Widget _navLink(String label, bool selected) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 11),
        child: TextButton(onPressed: () {}, style: TextButton.styleFrom(foregroundColor: selected ? AppTokens.navy : AppTokens.muted), child: Text(label, style: TextStyle(fontWeight: selected ? FontWeight.w700 : FontWeight.w500))),
      );

  Widget _hero(BuildContext context, AppCopy copy, bool mobile) {
    final titleSize = mobile ? 34.0 : 49.0;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: AppTokens.navyDeep, borderRadius: BorderRadius.circular(mobile ? 20 : 28)),
      child: Stack(children: [
        Positioned(top: -95, right: -60, child: Container(width: 330, height: 330, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white.withValues(alpha: .07), width: 1)))),
        Positioned(bottom: -165, right: 165, child: Container(width: 390, height: 390, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white.withValues(alpha: .06), width: 1)))),
        Padding(
          padding: EdgeInsets.all(mobile ? 24 : 54),
          child: mobile
              ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _eyebrow(copy),
                  const SizedBox(height: 24),
                  Text(copy.heroTitle, style: TextStyle(color: Colors.white, fontSize: titleSize, height: 1.14, fontWeight: FontWeight.w700, letterSpacing: -.7)),
                  const SizedBox(height: 16),
                  Text(copy.heroBody, style: const TextStyle(color: Color(0xFFCBD7E1), fontSize: 15, height: 1.75)),
                  const SizedBox(height: 24),
                  Wrap(spacing: 10, runSpacing: 10, children: [IndexButton(label: copy.explore, onPressed: () {}, icon: Icons.arrow_forward_rounded), IndexButton(label: copy.becomePartner, secondary: true, onPressed: () {})]),
                  const SizedBox(height: 30),
                  _routeArtwork(compact: true),
                ])
              : Row(children: [
                  Expanded(flex: 6, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _eyebrow(copy),
                    const SizedBox(height: 25),
                    Text(copy.heroTitle, style: TextStyle(color: Colors.white, fontSize: titleSize, height: 1.12, fontWeight: FontWeight.w700, letterSpacing: -.8)),
                    const SizedBox(height: 18),
                    ConstrainedBox(constraints: const BoxConstraints(maxWidth: 500), child: Text(copy.heroBody, style: const TextStyle(color: Color(0xFFCBD7E1), fontSize: 16, height: 1.8))),
                    const SizedBox(height: 28),
                    Wrap(spacing: 12, runSpacing: 10, children: [IndexButton(label: copy.explore, onPressed: () {}, icon: Icons.arrow_forward_rounded), IndexButton(label: copy.becomePartner, secondary: true, onPressed: () {})]),
                  ])),
                  const SizedBox(width: 28),
                  Expanded(flex: 5, child: _routeArtwork()),
                ]),
        ),
      ]),
    );
  }

  Widget _eyebrow(AppCopy copy) => Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 7, height: 7, decoration: const BoxDecoration(color: Color(0xFF5CC49E), shape: BoxShape.circle)),
        const SizedBox(width: 10),
        Flexible(child: Text(copy.eyebrow, style: const TextStyle(color: Color(0xFFB5C8D8), fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.05))),
      ]);

  Widget _routeArtwork({bool compact = false}) => AspectRatio(
        aspectRatio: compact ? 1.65 : 1.35,
        child: Stack(alignment: Alignment.center, children: [
          Container(decoration: BoxDecoration(gradient: RadialGradient(colors: [const Color(0xFF264B66).withValues(alpha: .85), AppTokens.navyDeep.withValues(alpha: .1)]))),
          CustomPaint(painter: _RoutePainter(), size: Size.infinite),
          _routeNode(Alignment.centerLeft, Icons.factory_outlined, 'ORIGIN', 'Shanghai'),
          _routeNode(Alignment.centerRight, Icons.apartment_rounded, 'DESTINATION', 'Rotterdam'),
          Align(alignment: const Alignment(0, -.03), child: Container(width: 64, height: 64, decoration: BoxDecoration(color: const Color(0xFF1B3B54), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withValues(alpha: .14)), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .16), blurRadius: 24)]), child: const Icon(Icons.public_rounded, color: Color(0xFFB8D9D0), size: 32))),
          Positioned(top: 16, right: 20, child: _floatingTag(Icons.south_rounded, '12,850 km')),
          Positioned(bottom: 18, left: 25, child: _floatingTag(Icons.inventory_2_outlined, 'GLOBAL TRADE')),
        ]),
      );

  Widget _routeNode(Alignment alignment, IconData icon, String eyebrow, String place) => Align(alignment: alignment, child: Container(margin: const EdgeInsets.symmetric(horizontal: 4), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFF18364E), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white.withValues(alpha: .14))), child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: const Color(0xFFB8D9D0), size: 19),
        const SizedBox(width: 9),
        Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text(eyebrow, style: const TextStyle(color: Color(0xFF9CB0BF), fontSize: 8, letterSpacing: 1)), Text(place, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600))]),
      ])));

  Widget _floatingTag(IconData icon, String label) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7), decoration: BoxDecoration(color: const Color(0xFF18364E), borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.white.withValues(alpha: .12))), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 12, color: const Color(0xFF93CDB8)), const SizedBox(width: 6), Text(label, style: const TextStyle(color: Color(0xFFDAE5EC), fontSize: 9, letterSpacing: .5))]));

  Widget _sectors(BuildContext context, AppCopy copy, bool mobile) {
    final sectors = HomeMockData.sectors;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      SectionHeading(title: copy.sectorsTitle, subtitle: copy.sectorsSubtitle, action: copy.seeAll),
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: sectors.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: mobile ? 2 : 4, mainAxisExtent: mobile ? 82 : 92, crossAxisSpacing: 12, mainAxisSpacing: 12),
        itemBuilder: (context, index) => _sectorCard(context, sectors[index], copy.isArabic),
      ),
    ]);
  }

  Widget _sectorCard(BuildContext context, Sector sector, bool arabic) => Material(
        color: AppTokens.white,
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        child: InkWell(onTap: () {}, borderRadius: BorderRadius.circular(AppTokens.radiusMd), child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(border: Border.all(color: AppTokens.line), borderRadius: BorderRadius.circular(AppTokens.radiusMd)),
          child: Row(children: [
            Container(width: 44, height: 44, decoration: BoxDecoration(color: sector.tint, borderRadius: BorderRadius.circular(13)), child: Icon(sector.icon, color: AppTokens.navy, size: 22)),
            const SizedBox(width: 12),
            Expanded(child: Text(arabic ? sector.titleAr : sector.titleEn, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 13))),
            Icon(arabic ? Icons.arrow_back_ios_new_rounded : Icons.arrow_forward_ios_rounded, size: 13, color: AppTokens.muted),
          ]),
        )),
      );

  Widget _companies(BuildContext context, AppCopy copy, bool mobile) {
    final companies = HomeMockData.companies;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      SectionHeading(title: copy.featuredTitle, subtitle: copy.featuredSubtitle, action: copy.seeAll),
      Wrap(spacing: 14, runSpacing: 14, children: companies.map((company) => SizedBox(width: mobile ? double.infinity : 330, child: _companyCard(context, company, copy))).toList()),
    ]);
  }

  Widget _companyCard(BuildContext context, Company company, AppCopy copy) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: AppTokens.white, border: Border.all(color: AppTokens.line), borderRadius: BorderRadius.circular(AppTokens.radiusMd)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(width: 48, height: 48, decoration: BoxDecoration(color: Color(company.accent).withValues(alpha: .1), borderRadius: BorderRadius.circular(14)), child: Center(child: Text(company.initials, style: TextStyle(color: Color(company.accent), fontWeight: FontWeight.w800)))),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(company.name, style: Theme.of(context).textTheme.titleMedium), Text(company.category, style: Theme.of(context).textTheme.bodyMedium)])),
            Icon(Icons.bookmark_border_rounded, color: AppTokens.muted, size: 20),
          ]),
          const SizedBox(height: 18),
          Row(children: [const Icon(Icons.location_on_outlined, size: 16, color: AppTokens.muted), const SizedBox(width: 5), Expanded(child: Text(company.location, style: Theme.of(context).textTheme.bodyMedium)), const SizedBox(width: 8), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: AppTokens.greenSoft, borderRadius: BorderRadius.circular(AppTokens.radiusPill)), child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.verified_rounded, size: 12, color: AppTokens.green), const SizedBox(width: 4), Text(copy.verified, style: const TextStyle(color: AppTokens.green, fontSize: 10, fontWeight: FontWeight.w700))]))]),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Text(copy.mockLabel, style: const TextStyle(fontSize: 10, color: AppTokens.muted)),
        ]),
      );

  Widget _footer(BuildContext context, AppCopy copy) => Container(color: AppTokens.navyDeep, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26), child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: AppTokens.maxContentWidth), child: Row(children: [_brand(copy), const Spacer(), Flexible(child: Text(copy.footer, textAlign: TextAlign.end, style: const TextStyle(color: Color(0xFFB8C7D2), fontSize: 12)))]))));

  Widget _mobileNav(BuildContext context, AppCopy copy) => NavigationBar(
        selectedIndex: _selectedTab,
        onDestinationSelected: (index) => setState(() => _selectedTab = index),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.hub_outlined), selectedIcon: const Icon(Icons.hub_rounded), label: copy.network),
          NavigationDestination(icon: const Icon(Icons.business_outlined), selectedIcon: const Icon(Icons.business_rounded), label: copy.directory),
          NavigationDestination(icon: const Icon(Icons.work_outline_rounded), selectedIcon: const Icon(Icons.work_rounded), label: copy.opportunities),
          NavigationDestination(icon: const Icon(Icons.person_outline_rounded), selectedIcon: const Icon(Icons.person_rounded), label: copy.profile),
        ],
      );

  void _showSearch(BuildContext context, AppCopy copy) => showModalBottomSheet<void>(context: context, isScrollControlled: true, builder: (context) => Padding(padding: EdgeInsets.fromLTRB(20, 24, 20, MediaQuery.viewInsetsOf(context).bottom + 24), child: IndexSearchField(hint: copy.searchHint)));
}

class _RoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * .12, size.height * .54)
      ..cubicTo(size.width * .37, size.height * .34, size.width * .57, size.height * .77, size.width * .88, size.height * .45);
    final line = Paint()..color = const Color(0xFF77BCA4)..strokeWidth = 2..style = PaintingStyle.stroke;
    canvas.drawPath(path, line);
    final dots = Paint()..color = const Color(0xFFA3D4C2);
    for (final t in [.12, .27, .42, .58, .73, .88]) {
      final metric = path.computeMetrics().first;
      final tangent = metric.getTangentForOffset(metric.length * t);
      if (tangent != null) canvas.drawCircle(tangent.position, t == .58 ? 4 : 2.5, dots);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
