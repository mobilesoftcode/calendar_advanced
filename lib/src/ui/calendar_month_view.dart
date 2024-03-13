import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../calendar_advanced.dart';

class CalendarMonthView extends StatelessWidget {
  final List<CalendarCellContent> Function(
          DateTime date, CalendarAdvancedController controller)
      calendarCellContentBuilder;
  final Widget Function(DateTime date, CalendarAdvancedController controller)
      calendarDayHeaderBuilder;
  final Widget Function(DateTime date, CalendarAdvancedController controller)
      calendarCellBuilder;

  const CalendarMonthView({
    super.key,
    required this.calendarCellContentBuilder,
    required this.calendarDayHeaderBuilder,
    required this.calendarCellBuilder,
  });

  @override
  Widget build(BuildContext context) {
    var dates = context.read<CalendarAdvancedController>().getVisibleDates();
    return Column(
      children: [
        _calendarHeader(dates: dates),
        const Divider(
          height: 0,
        ),
        _calendarDates(dates: dates),
      ],
    );
  }

  Widget _calendarHeader({required List<DateTime> dates}) {
    return Builder(builder: (context) {
      final daysInWeek = DateTime.daysPerWeek -
          context.read<CalendarAdvancedController>().hiddenWeekdays.length;
      final headerDates = List.generate(daysInWeek, (index) => dates[index]);

      return Row(
        children: List.generate(
          headerDates.length,
          (index) => Expanded(
            child: calendarDayHeaderBuilder(
                headerDates[index], context.read<CalendarAdvancedController>()),
          ),
        ),
      );
    });
  }

  Widget _calendarDates({required List<DateTime> dates}) {
    return Builder(builder: (context) {
      final daysInWeek = DateTime.daysPerWeek -
          context.read<CalendarAdvancedController>().hiddenWeekdays.length;
      var numberOfWeeks = dates.length / daysInWeek;

      return Column(
        children: List.generate(
          numberOfWeeks.ceil(),
          (index) => Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(
              daysInWeek,
              (rowIndex) => Expanded(
                child: _cellBuilder(
                  dates[daysInWeek * index + rowIndex],
                ),
              ),
            ),
          ),
        ),
      );
    });
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
                (index) => Expanded(
                    flex: cellContent[index].flex,
                    child: cellContent[index].content)),
          ),
        ],
      );
    });
  }
}
