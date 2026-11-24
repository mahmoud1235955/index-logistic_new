import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/package_group.dart';

/// Explicitly stores only valid anonymous package metrics and unit codes.
class PackagePreferences {
  const PackagePreferences();
  static const key = 'index.rfq.package-template.v1';

  Future<bool> save(List<PackageInput> inputs) async {
    final value = encode(inputs);
    if (value == null) return false;
    try {
      await SharedPreferencesAsync().setString(key, value);
      return true;
    } catch (_) {
      return false;
    }
  }

  static String? encode(List<PackageInput> inputs) {
    if (inputs.length > 40 || CargoTotals.fromInputs(inputs) == null) {
      return null;
    }
    return jsonEncode([
      for (final input in inputs)
        {
          'type': input.type.name,
          'lengthUnit': input.measure.name,
          'massUnit': input.mass.name,
          'values': {
            for (final field in PackageField.values)
              field.name: input.value(field)!.format(6),
          },
        },
    ]);
  }

  Future<List<PackageInput>?> load() async {
    try {
      return decode(await SharedPreferencesAsync().getString(key));
    } catch (_) {
      return null;
    }
  }

  static List<PackageInput>? decode(String? value) {
    if (value == null || value.length > 12000) return null;
    try {
      final rows = jsonDecode(value);
      if (rows is! List || rows.isEmpty || rows.length > 40) return null;
      final groups = <PackageInput>[
        for (final row in rows)
          PackageInput(
            type: PackageType.values.byName(row['type'] as String),
            measure: MeasureUnit.values.byName(row['lengthUnit'] as String),
            mass: MassUnit.values.byName(row['massUnit'] as String),
            values: Map.unmodifiable({
              for (final field in PackageField.values)
                field: row['values'][field.name] as String,
            }),
          ),
      ];
      return CargoTotals.fromInputs(groups) != null
          ? List.unmodifiable(groups)
          : null;
    } catch (_) {
      return null;
    }
  }

  Future<bool> clear() async {
    try {
      await SharedPreferencesAsync().remove(key);
      return true;
    } catch (_) {
      return false;
    }
  }
}
