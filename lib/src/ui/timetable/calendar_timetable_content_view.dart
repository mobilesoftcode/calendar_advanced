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

  double _evaluateOffsetForContent({required double initialHour}) {
    var hourOffset = (content.startHour ?? 0) - initialHour + 0.5;
    if (hourOffset < 0) {
      hourOffset = 0;
    }
    return timetableRowHeight * hourOffset;
  }

  double _evaluateHeightForContent() {
    var duration = (content.endHour ?? 0) - (content.startHour ?? 0);
    return timetableRowHeight * duration;
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: content.flex,
      child: Container(
          margin: EdgeInsets.only(
            top: _evaluateOffsetForContent(
              initialHour: context.read<CalendarAdvancedController>().startHour,
            ),
          ),
          height: _evaluateHeightForContent(),
          child: content.content),
    );
  }
}
