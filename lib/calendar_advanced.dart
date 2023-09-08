import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'src/ui/calendar_year_view.dart';
import 'src/ui/default_components/default_calendar_cell.dart';
import 'src/ui/default_components/default_calendar_day_header.dart';
import 'src/ui/default_components/default_calendar_header.dart';
import 'src/logic/calendar_advanced_controller.dart';
import 'src/ui/calendar_multi_year_view.dart';
import 'src/ui/calendar_week_view.dart';
import 'src/ui/calendar_day_view.dart';
import 'src/ui/calendar_month_view.dart';

export 'src/logic/calendar_advanced_controller.dart';

enum CalendarMode {
  day,
  dayWithTimetable,
  week,
  weekWithTimetable,
  month,
  year,
  multiYear,
}

class CalendarCellContent {
  final double? startHour;
  final double? endHour;
  final Widget content;
  final int flex;
  CalendarCellContent({
    this.startHour,
    this.endHour,
    this.flex = 1,
    required this.content,
  });
}

/// A scrolling calendar with selectable squared cells.
class CalendarAdvanced extends StatefulWidget {
  final CalendarAdvancedController? controller;

  /// This builder is used to create single day cells for a given date. If not specified,
  /// a default builder will be used.
  ///
  /// Use the `mode` argument to return different widgets depending on calendar view.
  ///
  /// Use `isSelected` to know if the cell has been selected by the user
  /// (note that it will be enabled only if the `onDateSelected` callback is provided)
  final Widget Function(DateTime date, bool isSelected, CalendarMode mode)?
      calendarCellBuilder;

  /// The builder for the content of a single calendar cell for a given date.
  /// It returns a list of [CalendarCellContent] for cases like timetables
  /// where for a single cell (i.e. a day), could be shown different widgets.
  ///
  /// If you want a unique cell view, use `calendarCellBuilder` instead,
  /// or simply return a list containing one [CalendarCellContent]
  /// without passing any value for _startHour_ or _endHour_.
  final List<CalendarCellContent> Function(DateTime date, CalendarMode mode)?
      calendarCellContentBuilder;

  final Widget Function(DateTime date, CalendarMode mode)?
      calendarDayHeaderBuilder;

  final Widget Function(DateTime date, CalendarMode mode)?
      calendarHeaderBuilder;

  /// A scrolling calendar with eventually selectable cells.
  ///
  /// The calendar can be shown either in monthly, weekly or daily view.
  /// There are methods to know if the user changed the date interval
  /// (such as scrolling months or weeks) or if the user selected a date.
  ///
  /// The cell appearance will change according to the screen size.
  const CalendarAdvanced({
    Key? key,
    this.controller,
    this.calendarCellBuilder,
    this.calendarCellContentBuilder,
    this.calendarDayHeaderBuilder,
    this.calendarHeaderBuilder,
  }) : super(key: key);

  @override
  State<CalendarAdvanced> createState() => _CalendarAdvancedState();
}

class _CalendarAdvancedState extends State<CalendarAdvanced>
    with TickerProviderStateMixin {
  late final CalendarAdvancedController _controller =
      widget.controller ?? CalendarAdvancedController();

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: _controller,
        builder: (context, child) {
          var mode = context.watch<CalendarAdvancedController>().mode;

          late Widget child;
          switch (mode) {
            case CalendarMode.day:
            case CalendarMode.dayWithTimetable:
              child = CalendarDayView(
                calendarCellBuilder:
                    widget.calendarCellBuilder ?? DefaultCalendarCell.builder,
                calendarCellContentBuilder: widget.calendarCellContentBuilder ??
                    (_, __) => List.empty(),
                calendarDayHeaderBuilder: widget.calendarDayHeaderBuilder ??
                    DefaultCalendarDayHeader.builder,
                withTimetable: mode == CalendarMode.dayWithTimetable,
              );
            case CalendarMode.week:
            case CalendarMode.weekWithTimetable:
              child = CalendarWeekView(
                calendarCellBuilder:
                    widget.calendarCellBuilder ?? DefaultCalendarCell.builder,
                calendarCellContentBuilder: widget.calendarCellContentBuilder ??
                    (_, __) => List.empty(),
                calendarDayHeaderBuilder: widget.calendarDayHeaderBuilder ??
                    DefaultCalendarDayHeader.builder,
                withTimetable: mode == CalendarMode.weekWithTimetable,
              );
            case CalendarMode.month:
              child = CalendarMonthView(
                calendarCellBuilder:
                    widget.calendarCellBuilder ?? DefaultCalendarCell.builder,
                calendarCellContentBuilder: widget.calendarCellContentBuilder ??
                    (_, __) => List.empty(),
                calendarDayHeaderBuilder: widget.calendarDayHeaderBuilder ??
                    DefaultCalendarDayHeader.builder,
              );
            case CalendarMode.year:
              child = CalendarYearView(
                calendarCellBuilder:
                    widget.calendarCellBuilder ?? DefaultCalendarCell.builder,
              );
            case CalendarMode.multiYear:
              child = CalendarMultiYearView(
                calendarCellBuilder:
                    widget.calendarCellBuilder ?? DefaultCalendarCell.builder,
              );
          }
          return Column(
            children: [
              widget.calendarHeaderBuilder?.call(
                      context.read<CalendarAdvancedController>().visibleDate,
                      mode) ??
                  DefaultCalendarHeader.builder(
                      context.watch<CalendarAdvancedController>()),
              child,
            ],
          );
        });
  }
}
