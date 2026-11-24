import 'package:flutter/material.dart';

import '../../../core/localization/app_copy.dart';
import '../../../core/widgets/adaptive_content.dart';
import '../domain/package_group.dart';
import 'workspace_widgets.dart';

class PackageEditor extends StatelessWidget {
  const PackageEditor({
    super.key,
    required this.copy,
    required this.inputs,
    required this.onChanged,
    this.showErrors = false,
  });
  final AppCopy copy;
  final List<PackageInput> inputs;
  final ValueChanged<List<PackageInput>> onChanged;
  final bool showErrors;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (final (index, input) in inputs.indexed)
        Padding(
          key: ValueKey(input.identity),
          padding: const EdgeInsets.only(bottom: 12),
          child: ContentPanel(
            title: copy.local(
              'Package group ${index + 1}',
              'مجموعة الطرود ${index + 1}',
            ),
            children: [
              AdaptiveGrid(
                children: [
                  WorkspaceSelect(
                    title: copy.local('Package type', 'نوع العبوة'),
                    options: PackageType.values,
                    selected: input.type,
                    label: _type,
                    copy: copy,
                    onChanged: (value) =>
                        _update(index, input.edit(type: value)),
                  ),
                  WorkspaceSelect(
                    title: copy.local('Dimension unit', 'وحدة الأبعاد'),
                    options: MeasureUnit.values,
                    selected: input.measure,
                    label: (value) => switch (value) {
                      MeasureUnit.centimetre => 'cm',
                      MeasureUnit.metre => 'm',
                      MeasureUnit.inch => 'in',
                    },
                    copy: copy,
                    onChanged: (value) =>
                        _update(index, input.edit(measure: value)),
                  ),
                  WorkspaceSelect(
                    title: copy.local('Weight unit', 'وحدة الوزن'),
                    options: MassUnit.values,
                    selected: input.mass,
                    label: (value) => value == MassUnit.kilogram ? 'kg' : 'lb',
                    copy: copy,
                    onChanged: (value) =>
                        _update(index, input.edit(mass: value)),
                  ),
                  for (final field in PackageField.values)
                    TextFormField(
                      key: ValueKey((index, field)),
                      initialValue: input.values[field],
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: field != PackageField.count,
                      ),
                      decoration: InputDecoration(
                        labelText: _label(field),
                        errorText: showErrors && input.value(field) == null
                            ? copy.local(
                                'Enter a positive value in the selected unit.',
                                'أدخل قيمة موجبة بالوحدة المحددة.',
                              )
                            : null,
                      ),
                      onChanged: (value) => _update(
                        index,
                        input.edit(field: field, value: value),
                      ),
                    ),
                ],
              ),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton(
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    // The keyed group subtree is rebuilt when a group is removed.
                    onChanged([...inputs]..removeAt(index));
                  },
                  child: Text(copy.local('Remove group', 'احذف المجموعة')),
                ),
              ),
            ],
          ),
        ),
      if (inputs.length < 40)
        WorkspaceLink(
          label: copy.local('Add package group', 'أضف مجموعة طرود'),
          onTap: () => onChanged([...inputs, PackageInput()]),
        ),
      if (CargoTotals.fromInputs(inputs) case final totals?)
        ContentPanel(
          children: [
            LabelValue(
              copy.local('Total gross weight', 'الوزن الإجمالي'),
              '${totals.kg.format(3)} kg',
            ),
            LabelValue(
              copy.local('Total cargo volume', 'إجمالي حجم الشحنة'),
              '${totals.cbm.format(6)} m³',
            ),
          ],
        ),
    ],
  );

  void _update(int index, PackageInput input) =>
      onChanged([...inputs]..[index] = input);

  String _type(PackageType type) => switch (type) {
    PackageType.carton => copy.local('Carton', 'كرتونة'),
    PackageType.pallet => copy.local('Pallet', 'منصة نقالة'),
    PackageType.crate => copy.local('Crate', 'صندوق شحن'),
    PackageType.other => copy.local('Other package', 'عبوة أخرى'),
  };
  String _label(PackageField field) => switch (field) {
    PackageField.count => copy.local(
      'Quantity of identical packages',
      'عدد العبوات المتطابقة',
    ),
    PackageField.length => copy.local('Length per package', 'طول العبوة'),
    PackageField.width => copy.local('Width per package', 'عرض العبوة'),
    PackageField.height => copy.local('Height per package', 'ارتفاع العبوة'),
    PackageField.gross => copy.local(
      'Gross weight per package',
      'الوزن الإجمالي للعبوة',
    ),
  };
}
