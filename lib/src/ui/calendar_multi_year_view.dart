import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../calendar_advanced.dart';

class CalendarMultiYearView extends StatelessWidget {
  final Widget Function(DateTime date, bool isSelected, CalendarMode mode)
      calendarCellBuilder;

  const CalendarMultiYearView({
    super.key,
    required this.calendarCellBuilder,
  });

  @override
  Widget build(BuildContext context) {
    var dates = context.read<CalendarAdvancedController>().getVisibleDates();
    return Column(
      children: [
        const Divider(
          height: 0,
        ),
        _calendarDates(dates: dates),
      ],
    );
  }

  Widget _calendarDates({required List<DateTime> dates}) {
    return Builder(builder: (context) {
      var numberOfYearsPerRow = dates.length ~/ 5;

      return Column(
        children: List.generate(
          5,
          (index) => Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(
              numberOfYearsPerRow,
              (rowIndex) => Expanded(
                child: _cellBuilder(
                  dates[numberOfYearsPerRow * index + rowIndex],
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
      return InkWell(
        customBorder: const CircleBorder(),
        onTap: context
                .read<CalendarAdvancedController>()
                .shouldAllowSelection(date)
            ? () {
                context.read<CalendarAdvancedController>().selectDate(date);
              }
            : null,
        child: calendarCellBuilder(
            date,
            context.read<CalendarAdvancedController>().isDateSelected(date),
            context.read<CalendarAdvancedController>().mode),
      );
    });
  }
}
