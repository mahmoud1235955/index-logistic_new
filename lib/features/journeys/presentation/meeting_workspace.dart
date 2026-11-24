import 'package:flutter/material.dart';

import '../../../core/localization/app_copy.dart';
import '../../../core/widgets/adaptive_content.dart';
import '../domain/meeting_time.dart';
import 'closure_widgets.dart';
import 'workspace_widgets.dart';

class MeetingWorkspace extends StatelessWidget {
  const MeetingWorkspace({super.key, required this.copy});
  final AppCopy copy;

  @override
  Widget build(BuildContext context) => ClosureForm(
    builder: (context, state, cubit) {
      final from = state.inputs['from'] ?? 'Africa/Cairo';
      final to = state.inputs['to'] ?? 'Europe/London';
      final time = state.value('wall');
      final candidates = MeetingTime.resolve(time, from);
      return WorkspacePage(
        title: copy.local('Time and meetings', 'التوقيت والاجتماعات'),
        children: [
          _WorldClock(copy: copy),
          ContentPanel(
            title: copy.local(
              'Compare a local meeting time',
              'قارن موعد اجتماع محلي',
            ),
            children: [
              AdaptiveGrid(
                children: [
                  for (final (id, name, zone) in [
                    (
                      'from',
                      copy.local('Source timezone', 'المنطقة الزمنية الأصلية'),
                      from,
                    ),
                    (
                      'to',
                      copy.local(
                        'Comparison timezone',
                        'المنطقة الزمنية للمقارنة',
                      ),
                      to,
                    ),
                  ])
                    WorkspaceSelect(
                      title: name,
                      options: meetingZones,
                      selected: zone,
                      label: (zone) => zone,
                      copy: copy,
                      onChanged: (value) => cubit.edit(id, value!),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              closureFields(state, cubit, [
                (
                  id: 'wall',
                  label: copy.local(
                    'Source wall time (YYYY-MM-DD HH:mm)',
                    'التوقيت المحلي الأصلي (YYYY-MM-DD HH:mm)',
                  ),
                ),
              ]),
              if (time.isNotEmpty && candidates.isEmpty)
                Text(
                  copy.local(
                    'Invalid time or clock-change gap. Check the date, format and source zone.',
                    'التوقيت غير صالح أو يقع ضمن فترة مفقودة بسبب تغيير الساعة. تحقق من التاريخ والصيغة والمنطقة الأصلية.',
                  ),
                ),
              if (candidates.length > 1)
                Text(
                  copy.local(
                    'This time occurs twice. Confirm which UTC instant the participants intend.',
                    'يحدث هذا التوقيت مرتين. أكّد مع المشاركين توقيت UTC المقصود.',
                  ),
                ),
              for (final instant in candidates)
                LabelValue(
                  '${instant.toIso8601String().substring(0, 16).replaceFirst('T', ' ')} UTC',
                  MeetingTime.display(instant, to),
                ),
            ],
          ),
          ContentPanel(
            title: copy.local('Local meeting preparation', 'تجهيز اجتماع محلي'),
            children: [
              closureFields(state, cubit, [
                (
                  id: 'topic',
                  label: copy.local(
                    'Topic or agenda',
                    'الموضوع أو جدول الأعمال',
                  ),
                ),
                (
                  id: 'duration',
                  label: copy.local(
                    'Proposed duration (minutes)',
                    'المدة المقترحة (دقائق)',
                  ),
                ),
              ]),
              Text(
                copy.local(
                  'Notes remain in this view. Confirm the date with participants before sharing.',
                  'تبقى الملاحظات في هذه الشاشة. أكد التاريخ مع المشاركين قبل المشاركة.',
                ),
              ),
            ],
          ),
        ],
      );
    },
  );
}

class _WorldClock extends StatefulWidget {
  const _WorldClock({required this.copy});
  final AppCopy copy;

  @override
  State<_WorldClock> createState() => _WorldClockState();
}

class _WorldClockState extends State<_WorldClock> {
  final _ticks = Stream<DateTime>.periodic(
    const Duration(seconds: 15),
    (_) => DateTime.now().toUtc(),
  );

  @override
  Widget build(BuildContext context) => StreamBuilder(
    stream: _ticks,
    initialData: DateTime.now().toUtc(),
    builder: (context, snapshot) => ContentPanel(
      title: widget.copy.local('World clock', 'الساعة العالمية'),
      children: [
        for (final zone in meetingZones)
          LabelValue(zone, MeetingTime.display(snapshot.data!, zone)),
        Text(
          widget.copy.local(
            'Offsets use bundled IANA timezone data (2025c).',
            'تستخدم الفروق بيانات المناطق الزمنية المضمّنة من IANA (2025c).',
          ),
        ),
      ],
    ),
  );
}
