import 'package:timezone/data/latest.dart' as data;
import 'package:timezone/timezone.dart' as tz;

const meetingZones = [
  'Etc/UTC',
  'Africa/Cairo',
  'Europe/London',
  'Europe/Paris',
  'America/New_York',
  'Asia/Dubai',
  'Asia/Singapore',
];

class MeetingTime {
  static final bool _ready = (() {
    data.initializeTimeZones();
    return true;
  })();
  static tz.Location location(String name) {
    if (!_ready) throw StateError('Timezone initialization failed');
    return tz.getLocation(name);
  }

  static tz.TZDateTime at(DateTime instant, String zone) =>
      tz.TZDateTime.from(instant, location(zone));

  /// Returns both instants for a repeated wall time and no instant for a DST gap.
  static List<DateTime> resolve(String wallTime, String zone) {
    final raw = wallTime.trim().replaceAll(' ', 'T');
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}$').hasMatch(raw)) return [];
    final civil = DateTime.tryParse('${raw}Z');
    if (civil == null || civil.toIso8601String().substring(0, 16) != raw) {
      return [];
    }
    final place = location(zone);
    final offsets = {
      for (final hours in [-48, -24, 0, 24, 48])
        tz.TZDateTime.from(
          civil.add(Duration(hours: hours)),
          place,
        ).timeZoneOffset,
    };
    final valid = <DateTime>[];
    for (final offset in offsets) {
      final candidate = civil.subtract(offset);
      final shown = tz.TZDateTime.from(candidate, place);
      if (shown.year == civil.year &&
          shown.month == civil.month &&
          shown.day == civil.day &&
          shown.hour == civil.hour &&
          shown.minute == civil.minute) {
        valid.add(candidate);
      }
    }
    return valid..sort();
  }

  static String display(DateTime instant, String zone) {
    final stamp = at(instant, zone);
    final local = stamp
        .toIso8601String()
        .substring(0, 16)
        .replaceFirst('T', ' ');
    final mins = stamp.timeZoneOffset.inMinutes;
    final hours = (mins.abs() ~/ 60).toString().padLeft(2, '0');
    final minutes = (mins.abs() % 60).toString().padLeft(2, '0');
    return '$local · UTC${mins < 0 ? '-' : '+'}$hours:$minutes';
  }
}
