import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../calendar_advanced.dart';
import 'timetable/calendar_timetable_background_view.dart';
import 'timetable/calendar_timetable_content_view.dart';

class CalendarDayView extends StatelessWidget {
  final List<CalendarCellContent> Function(
          DateTime date, CalendarAdvancedController controller)
      calendarCellContentBuilder;
  final Widget Function(DateTime date, CalendarAdvancedController controller)
      calendarDayHeaderBuilder;
  final Widget Function(DateTime date, CalendarAdvancedController controller)
      calendarCellBuilder;
  final bool withTimetable;

  const CalendarDayView({
    super.key,
    required this.calendarCellContentBuilder,
    required this.calendarDayHeaderBuilder,
    required this.calendarCellBuilder,
    this.withTimetable = false,
  });

  final double _timetableRowHeight = 150;

  @override
  Widget build(BuildContext context) {
    var date =
        context.read<CalendarAdvancedController>().getVisibleDates().first;
    return Column(
      children: [
        _calendarHeader(date: date),
        const Divider(
          height: 0,
        ),
        const SizedBox(
          height: 30,
        ),
        _calendarDate(date: date),
      ],
    );
  }

  Widget _calendarHeader({required DateTime date}) {
    return Builder(builder: (context) {
      return calendarDayHeaderBuilder(
          date, context.read<CalendarAdvancedController>());
    });
  }

  Widget _calendarDate({required DateTime date}) {
    return Stack(
      children: [
        if (withTimetable)
          CalendarTimetableBackgroundView(
              timetableRowHeight: _timetableRowHeight),
        Padding(
          padding: EdgeInsets.all(withTimetable ? 50 : 0),
          child: _cellBuilder(date),
        ),
      ],
    );
  }

  Widget _cellBuilder(DateTime date) {
    return Builder(builder: (context) {
      final cellContent = calendarCellContentBuilder(
          date, context.read<CalendarAdvancedController>());

      return Stack(
        alignment: Alignment.center,
        children: [
          InkWell(
            customBorder: const CircleBorder(),
            onTap: context
                    .read<CalendarAdvancedController>()
                    .shouldAllowSelection(date)
                ? () {
                    context.read<CalendarAdvancedController>().selectDate(date);
                  }
                : null,
            child: calendarCellBuilder(
                date, context.read<CalendarAdvancedController>()),
          ),
          Row(
            children: List.generate(
              cellContent.length,
              (index) {
                if (withTimetable) {
                  return CalendarTimetableContentView(
                    content: cellContent[index],
                    timetableRowHeight: _timetableRowHeight,
                  );
                }

                return Expanded(
                    flex: cellContent[index].flex,
                    child: cellContent[index].content);
              },
            ),
          ),
        ],
      );
    });
  }
}
