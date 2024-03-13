import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../calendar_advanced.dart';

class CalendarYearView extends StatelessWidget {
  final Widget Function(DateTime date, CalendarAdvancedController controller)
      calendarCellBuilder;

  const CalendarYearView({
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
      var numberOfMonthsPerRow = dates.length ~/ 4;

      return Column(
        children: List.generate(
          4,
          (index) => Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(
              numberOfMonthsPerRow,
              (rowIndex) => Expanded(
                child: _cellBuilder(
                  dates[numberOfMonthsPerRow * index + rowIndex],
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
            date, context.read<CalendarAdvancedController>()),
      );
    });
  }
}
