import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/localization/app_copy.dart';
import '../../../core/widgets/adaptive_content.dart';
import '../domain/package_group.dart';

class ClosureState {
  const ClosureState({
    this.inputs = const {},
    this.checked = const {},
    this.packages = const [],
  });
  final Map<String, String> inputs;
  final Set<String> checked;
  final List<PackageInput> packages;
  String value(String key) => inputs[key]?.trim() ?? '';
}

class ClosureCubit extends Cubit<ClosureState> {
  ClosureCubit() : super(const ClosureState());
  void edit(String key, String value) => emit(
    ClosureState(
      inputs: Map.unmodifiable({...state.inputs, key: value}),
      checked: state.checked,
      packages: state.packages,
    ),
  );
  void check(String key, bool value) {
    final next = {...state.checked};
    if (value) {
      next.add(key);
    } else {
      next.remove(key);
    }
    emit(
      ClosureState(
        inputs: state.inputs,
        checked: Set.unmodifiable(next),
        packages: state.packages,
      ),
    );
  }

  void packages(List<PackageInput> packages) => emit(
    ClosureState(
      inputs: state.inputs,
      checked: state.checked,
      packages: List.unmodifiable(packages),
    ),
  );
}

class ClosureForm extends StatelessWidget {
  const ClosureForm({super.key, required this.builder});
  final Widget Function(BuildContext, ClosureState, ClosureCubit) builder;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => ClosureCubit(),
    child: BlocBuilder<ClosureCubit, ClosureState>(
      builder: (context, state) =>
          builder(context, state, context.read<ClosureCubit>()),
    ),
  );
}

Widget closureFields(
  ClosureState state,
  ClosureCubit cubit,
  List<({String id, String label})> fields,
) => AdaptiveGrid(
  children: [
    for (final field in fields)
      TextFormField(
        key: ValueKey(field.id),
        initialValue: state.inputs[field.id],
        decoration: InputDecoration(labelText: field.label),
        onChanged: (value) => cubit.edit(field.id, value),
      ),
  ],
);

Widget closureChecklist(
  ClosureState state,
  ClosureCubit cubit,
  Map<String, String> options,
  AppCopy copy,
) => ContentPanel(
  children: [
    for (final entry in options.entries)
      CheckboxListTile(
        title: Text(entry.value),
        value: state.checked.contains(entry.key),
        onChanged: (value) => cubit.check(entry.key, value == true),
      ),
  ],
);
