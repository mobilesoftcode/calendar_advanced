import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../calendar_advanced.dart';
import 'timetable/calendar_timetable_background_view.dart';
import 'timetable/calendar_timetable_content_view.dart';

class CalendarWeekView extends StatelessWidget {
  final List<CalendarCellContent> Function(DateTime date, CalendarMode mode)
      calendarCellContentBuilder;
  final Widget Function(DateTime date, CalendarMode mode)
      calendarDayHeaderBuilder;
  final Widget Function(DateTime date, bool isSelected, CalendarMode mode)
      calendarCellBuilder;
  final bool withTimetable;

  const CalendarWeekView({
    super.key,
    required this.calendarCellContentBuilder,
    required this.calendarDayHeaderBuilder,
    required this.calendarCellBuilder,
    this.withTimetable = false,
  });

  final double _timetableRowHeight = 100;

  @override
  Widget build(BuildContext context) {
    var dates = context.read<CalendarAdvancedController>().getVisibleDates();
    return Column(
      children: [
        _calendarHeader(dates: dates),
        const Divider(
          height: 0,
        ),
        const SizedBox(
          height: 10,
        ),
        _calendarDates(dates: dates),
      ],
    );
  }

  Widget _calendarHeader({required List<DateTime> dates}) {
    return Builder(builder: (context) {
      return Row(
        children: [
          if (withTimetable)
            const SizedBox(
              width: 50,
            ),
          ...List.generate(
          dates.length,
          (index) => Expanded(
            child: calendarDayHeaderBuilder(
                dates[index],
                  context.read<CalendarAdvancedController>().mode),
          ),
          ),
        ],
      );
    });
  }

  Widget _calendarDates({required List<DateTime> dates}) {
    return Stack(
      children: [
        if (withTimetable)
          CalendarTimetableBackgroundView(
              timetableRowHeight: _timetableRowHeight),
        Padding(
          padding: EdgeInsets.all(withTimetable ? 50 : 0),
          child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(
            dates.length,
            (index) => Expanded(
              child: _cellBuilder(dates[index]),
            ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _cellBuilder(DateTime date) {
    return Builder(builder: (context) {
      final cellContent = calendarCellContentBuilder(
          date, context.read<CalendarAdvancedController>().mode);

      return Stack(
        alignment: Alignment.center,
        children: [
          InkWell(
            customBorder: const CircleBorder(),
            onTap: context
                    .read<CalendarAdvancedController>()
                    .shouldAllowSelection()
                ? () {
                    context.read<CalendarAdvancedController>().selectDate(date);
                  }
                : null,
            child: calendarCellBuilder(
                date,
                context.read<CalendarAdvancedController>().isDateSelected(date),
                context.read<CalendarAdvancedController>().mode),
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
