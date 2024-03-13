import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../calendar_advanced.dart';

class DefaultCalendarCell extends StatelessWidget {
  final DateTime date;
  final CalendarAdvancedController controller;
  const DefaultCalendarCell({
    super.key,
    required this.date,
    required this.controller,
  });

  static Widget builder(DateTime date, CalendarAdvancedController controller) {
    return DefaultCalendarCell(
      date: date,
      controller: controller,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (context.read<CalendarAdvancedController>().isWithTimetables) {
      return const SizedBox.shrink();
    }

    late String dateLabel;
    switch (controller.mode) {
      case CalendarMode.day:
      case CalendarMode.dayWithTimetable:
      case CalendarMode.week:
      case CalendarMode.weekWithTimetable:
      case CalendarMode.month:
        dateLabel = date.day.toString();
      case CalendarMode.year:
        dateLabel = DateFormat("MMM").format(date);
      case CalendarMode.multiYear:
        dateLabel = date.year.toString();
    }

    final selected = controller.isDateSelected(date);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      height: 50,
      width: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: context.read<CalendarAdvancedController>().initialDate ==
                    date &&
                context.read<CalendarAdvancedController>().highlightInitialDate
            ? Border.all(color: Theme.of(context).primaryColor)
            : null,
        color: selected
            ? Theme.of(context).primaryColor
            : context
                    .read<CalendarAdvancedController>()
                    .isDateInSelectionRange(date)
                ? Theme.of(context).primaryColor.withOpacity(0.2)
                : null,
      ),
      child: Center(
        child: Text(
          dateLabel,
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: selected ? Colors.white : null),
        ),
      ),
    );
  }
}
