import 'package:flutter_bloc/flutter_bloc.dart';
import 'commercial_models.dart';

enum SavedKind { company, product }

typedef SavedItem = ({
  SavedKind kind,
  String id,
  String english,
  String arabic,
});

class WorkspaceState {
  const WorkspaceState({
    this.saved = const [],
    this.blocked = const {},
    this.reports = const [],
    this.quote,
    this.preferences = const {},
    this.drafts = const {},
  });
  final List<SavedItem> saved;
  final Set<String> blocked;
  final List<LocalReport> reports;
  final QuoteDraft? quote;
  final Map<String, bool> preferences;
  final Map<String, String> drafts;
}

class LocalWorkspace extends Cubit<WorkspaceState> {
  LocalWorkspace() : super(const WorkspaceState());

  void _update({
    List<SavedItem>? saved,
    Set<String>? blocked,
    List<LocalReport>? reports,
    QuoteDraft? quote,
    Map<String, bool>? preferences,
    Map<String, String>? drafts,
  }) => emit(
    WorkspaceState(
      saved: saved ?? state.saved,
      blocked: blocked ?? state.blocked,
      reports: reports ?? state.reports,
      quote: quote ?? state.quote,
      preferences: preferences ?? state.preferences,
      drafts: drafts ?? state.drafts,
    ),
  );

  void toggleSaved(SavedItem item) {
    final index = state.saved.indexWhere(
      (saved) => saved.kind == item.kind && saved.id == item.id,
    );
    final next = [...state.saved];
    if (index < 0) {
      next.add(item);
    } else {
      next.removeAt(index);
    }
    _update(saved: List.unmodifiable(next));
  }

  bool saved(SavedItem item) => state.saved.any(
    (saved) => saved.kind == item.kind && saved.id == item.id,
  );

  void toggleBlocked(String id) {
    final next = {...state.blocked};
    if (!next.remove(id)) next.add(id);
    _update(blocked: Set.unmodifiable(next));
  }

  void report(LocalReport report) =>
      _update(reports: List.unmodifiable([...state.reports, report]));
  void saveQuote(QuoteDraft quote) => _update(quote: quote);
  void preference(String id, bool value) =>
      _update(preferences: Map.unmodifiable({...state.preferences, id: value}));
  void draft(String id, String text) =>
      _update(drafts: Map.unmodifiable({...state.drafts, id: text}));
}
