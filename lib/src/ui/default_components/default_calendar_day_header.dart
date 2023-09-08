import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../calendar_advanced.dart';

class DefaultCalendarDayHeader extends StatelessWidget {
  final DateTime date;
  final CalendarMode mode;
  const DefaultCalendarDayHeader({
    super.key,
    required this.date,
    required this.mode,
  });

  static Widget builder(DateTime date, CalendarMode mode) {
    return DefaultCalendarDayHeader(date: date, mode: mode);
  }

  @override
  Widget build(BuildContext context) {
    var title = DateFormat.EEEE().format(date);
    if (context.read<CalendarAdvancedController>().isWithTimetables) {
      title = DateFormat("EEEE dd").format(date);
    }
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        title,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
