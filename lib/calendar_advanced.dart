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
export 'src/ui/default_components/default_calendar_cell.dart';
export 'src/ui/default_components/default_calendar_header.dart';
export 'src/ui/default_components/default_calendar_day_header.dart';

enum CalendarMode {
  day,
  dayWithTimetable,
  week,
  weekWithTimetable,
  month,
  year,
  multiYear,
}

/// Specifies content to show in a [CalendarAdvanced]'s cell, above the widget
/// returned by the `calendarCellBuilder` builder.
class CalendarCellContent {
  /// In case of timetable [CalendarMode], the `content` will be placed
  /// starting at `startHour`, if provided.
  final double? startHour;

  /// In case of timetable [CalendarMode], the `content` will be placed
  /// ending at `endHour`, if provided.
  final double? endHour;

  /// The content to show above the widget returned by the `calendarCellBuilder` builder.
  final Widget content;

  /// [CalendarCellContent]s are placed in a [Row], `flex` defines the relative space
  /// that every content should take in the [Row]. Defaults to 1.
  final int flex;

  /// Specifies content to show in a [CalendarAdvanced]'s cell, above the widget
  /// returned by the `calendarCellBuilder` builder.
  ///
  /// This is useful in case of use of daily or weekly timetable [CalendarMode],
  /// to specify hours range in which the content should be placed.
  CalendarCellContent({
    this.startHour,
    this.endHour,
    this.flex = 1,
    required this.content,
  });
}

/// A scrolling calendar with monthly, weekly or daily view and eventually picker mode.
class CalendarAdvanced extends StatefulWidget {
  /// Use the controller to specify calendar properties and actions, such as
  /// initial and last date to be visibile, allow date selection or date-range selection,
  /// set a callback when the dates shown in calendar changes and different others.
  ///
  /// NOTE: Remind to correctly `dispose` the controller if provided.
  final CalendarAdvancedController? controller;

  /// This builder is used to create single day cells for a given date. If not specified,
  /// a default builder will be used.
  ///
  /// Using the `controller` you can retrieve:
  /// * `mode` to return different widgets depending on calendar view.
  /// * `isDateSelected()` to know if the cell has been selected by the user
  /// (note that selection will be enabled only if the `onDateSelected` callback of [CalendarAdvancedController] is provided).
  ///
  /// If not provided, a default cell builder will be used.
  final Widget Function(DateTime date, CalendarAdvancedController controller)?
      calendarCellBuilder;

  /// The builder for the content of a single calendar cell for a given date.
  /// It returns a list of [CalendarCellContent] for cases like timetables
  /// where for a single cell (i.e. a day), could be shown different widgets,
  /// or to specify hours range in which content should be shown.
  ///
  /// If you want a unique cell view, use `calendarCellBuilder`.
  ///
  /// If not provider, no content will be shown.
  final List<CalendarCellContent> Function(
          DateTime date, CalendarAdvancedController controller)?
      calendarCellContentBuilder;

  /// The builder for day column headers. Usually, this should display the name
  /// of the day (i.e. monday, tuesday).
  ///
  ///  If not provided, a default day header builder will be used.
  final Widget Function(DateTime date, CalendarAdvancedController controller)?
      calendarDayHeaderBuilder;

  /// The builder for calendar header. Usually, this should display the month
  /// or buttons to execute actions on the calendar (i.e. scrolling dates).
  ///
  /// If not provided, a default calendar header will be used.
  final Widget Function(DateTime date, CalendarAdvancedController controller)?
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
                      context.read<CalendarAdvancedController>()) ??
                  DefaultCalendarHeader.builder(
                      context.watch<CalendarAdvancedController>()),
              child,
            ],
          );
        });
  }
}
