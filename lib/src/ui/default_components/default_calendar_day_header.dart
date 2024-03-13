import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../calendar_advanced.dart';

class DefaultCalendarDayHeader extends StatelessWidget {
  final DateTime date;
  final CalendarAdvancedController controller;
  const DefaultCalendarDayHeader({
    super.key,
    required this.date,
    required this.controller,
  });

  static Widget builder(DateTime date, CalendarAdvancedController controller) {
    return DefaultCalendarDayHeader(
      date: date,
      controller: controller,
    );
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
