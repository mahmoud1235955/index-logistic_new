# Index Logistics — Phase 1 foundation

## Framework decision

The inspected project is a clean Flutter 3.41 / Dart 3.11 application with Android, iOS, desktop, and web targets. Phase 1 therefore keeps Flutter and Dart. Replacing it with a separate web stack would split the existing cross-platform project without helping the requested first deliverable.

The implementation is feature-oriented: shared design and localization live under `lib/core`, while home and directory types and fixtures live under `lib/features`. `HomeRepository` is the seam for a future REST-backed implementation; `HomeMockData` supplies only local preview content.

## Visual foundation

- Navy is the primary brand color, white is the main surface, and green is a restrained auxiliary accent.
- Colors, spacing, radii, content width, and text styles are centralized in `AppTokens` and `IndexTheme`.
- Arabic and English copy is centralized in `AppCopy`. The app sets the matching locale and text direction; the language control switches between Arabic RTL and English LTR.
- Arabic currently uses the platform's Arabic font fallback. No remote font download or bundled font has been added.
- The locale list is prepared for French, Italian, Hindi, and Chinese. Their translated copy is not part of this phase.

## Responsive layout

- Below 760 logical pixels, the page uses a compact brand bar, search sheet, and dedicated bottom navigation. Content becomes a single column and sector cards use a two-column grid.
- From 760 to 1079 pixels, the compact desktop header and narrower content gutters are used.
- At 1080 pixels and wider, the full navigation and wider content grid are used, within a 1320-pixel maximum content width.
- The landing page is a layout foundation and visual preview, not the complete set of application screens.

## Mock content and integration boundary

Company and sector content in `HomeMockData` is local sample data and is labeled as preview content in the UI. There is no authentication, payment, messaging, production API, or backend connection in this foundation. Future repositories can implement `HomeRepository` and map API responses to the same domain types without embedding transport details in presentation widgets.

## Specification dependency and phase boundary

The approved V4 specification was not present in this workspace or in the adjacent project documentation during implementation. The UI foundation is based on the Phase 1 brief supplied in the conversation. Review it against the complete V4 before expanding to later product screens. This phase does not implement the 35 product sections.

## Preview status

The local Flutter web server can be run with:

```powershell
flutter run -d web-server --web-hostname 127.0.0.1 --web-port 7357
```

The server was started at `http://127.0.0.1:7357`. A headless Chrome capture returned a blank image while Flutter's debug module loader was still loading. A second capture was not authorized, so the owner should review the running page in a browser before Phase 2.
