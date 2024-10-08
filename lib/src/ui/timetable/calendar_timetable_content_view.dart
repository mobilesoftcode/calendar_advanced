import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../calendar_advanced.dart';

class CalendarTimetableContentView extends StatelessWidget {
  final CalendarCellContent content;
  final double timetableRowHeight;
  const CalendarTimetableContentView({
    super.key,
    required this.content,
    required this.timetableRowHeight,
  });

  double _evaluateOffsetForContent({required DateTime initialHour}) {
    var dayOffset = initialHour.copyWith(
        year: content.startHour?.year,
        month: content.startHour?.month,
        day: content.startHour?.day);
    var hourOffset =
        (content.startHour ?? initialHour).difference(dayOffset).inHours;
    var minutesOffset =
        (content.startHour ?? initialHour).difference(dayOffset).inMinutes;
    if (hourOffset < 0) {
      hourOffset = 0;
    }
    return timetableRowHeight * hourOffset +
        (minutesOffset * 100 / 60) / timetableRowHeight;
  }

  double _evaluateHeightForContent() {
    var duration = (content.endHour ?? content.startHour ?? DateTime.now())
        .difference(content.startHour ?? DateTime.now())
        .inMinutes;
    return timetableRowHeight * (duration / 60);
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: content.flex,
      child: Container(
          margin: EdgeInsets.only(
            top: _evaluateOffsetForContent(
              initialHour:
                  context.read<CalendarAdvancedController>().startHour ??
                      DateTime.now().copyWith(hour: 9),
            ),
          ),
          height: _evaluateHeightForContent(),
          child: content.content),
    );
  }
}
