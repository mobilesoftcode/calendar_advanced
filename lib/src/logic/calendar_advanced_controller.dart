import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../calendar_advanced.dart';
import '../../utils/utility.dart';

import '../../utils/helpers/date_helper.dart';

/// This controller manages the [CalendarAdvanced] widget properties and actions.
class CalendarAdvancedController extends ChangeNotifier {
  /// The initial date of the calendar, before which calendar cannot be scrolled.
  final DateTime? startDate;

  /// The last date of the calendar, after which calendar cannot be scrolled.
  final DateTime? endDate;

  /// The initial hour of the calendar timetable. Defaults to 9.
  final double startHour;

  /// The last hour of the calendar timetable. Defaults to 18.
  final double endHour;

  /// Used to specify days to hide in the calendar (i.e. weekends).
  ///
  /// Days to hide must be provided as [int]. You can use [DateTime.sunday] for example.
  final List<int> hiddenWeekdays;

  /// The date that should be visible and highlighted in calendar once initialized. Defaults to today.
  late final DateTime initialDate;

  /// The initial mode of the calendar. Defaults to [CalendarMode.week].
  final CalendarMode initialMode;

  /// When the user selects a date, this method is called
  /// to take appropriate actions.
  ///
  /// If this is not provided, the calendar will be only in read mode.
  final void Function(DateTime date)? onSelectDate;

  /// When the user selects a date range, this method is called
  /// to take appropriate actions.
  ///
  /// If both this and `onSelectDate` are provided, this will be always used.
  final void Function(DateTime startDate, DateTime endDate)? onSelectDateRange;

  /// The date that should be selected once the calendar is initialized.
  ///
  /// This will be considered only if `onSelectDate` or `onSelectDateRange` is not _null_.
  DateTime? selectedDate;

  /// The date that should be selected as last date of range once the calendar is initialized.
  ///
  /// This will be considered only if `onSelectDateRange` is not _null_.
  DateTime? selectedEndDate;

  /// When the user selects a time range from calendar in timetable mode, this method is called
  /// to take appropriate actions.
  ///
  /// If this is not provided, the timetable will be only in read mode.
  final void Function(DateTime initialDateHour, DateTime lastDateHour)?
      onSelectTimeSlot;

  /// When the controller fires a scrolling event (so dates shown in the calendar change),
  /// this method is called to take appropriate actions (i.e. updating content shown in the calendar
  /// after calling an API).
  final Future<void> Function(
          CalendarMode mode, DateTime startDate, DateTime endDate)?
      onScrollCalendar;

  /// This controller manages the [CalendarAdvanced] widget properties and actions.
  ///
  /// You can specify dates to be visibile in the calendar, callbacks for date selection,
  /// date-range selections and calendar scrolling, as well as use it to make actions
  /// on the calendar such as changing [CalendarMode] or visible date.
  CalendarAdvancedController({
    this.startDate,
    this.endDate,
    this.selectedDate,
    this.selectedEndDate,
    DateTime? initialDate,
    this.hiddenWeekdays = const [],
    this.startHour = 9,
    this.endHour = 18,
    this.initialMode = CalendarMode.week,
    this.onScrollCalendar,
    this.onSelectTimeSlot,
    this.onSelectDate,
    this.onSelectDateRange,
  })  : assert((startDate != null &&
                endDate != null &&
                startDate.isDateBefore((endDate))) ||
            startDate == null ||
            endDate == null),
        assert(hiddenWeekdays.length < 7),
        assert(hiddenWeekdays.every((element) => element <= 7)),
        assert(startHour < endHour) {
    this.initialDate = initialDate ?? DateTime.now().getDateOnly();
    mode = initialMode;
    _evaluateInitialVisibleDates(this.initialDate);
  }

  late DateTime _firstVisibleDate;
  late DateTime _lastVisibleDate;

  /// The [CalendarMode] actually used by the [CalendarAdvanced].
  late CalendarMode mode;

  /// The date or month visible in the [CalendarAdvanced].
  late DateTime visibleDate;

  /// If _true_, the current [CalendarMode] is with timetable.
  bool get isWithTimetables =>
      mode == CalendarMode.dayWithTimetable ||
      mode == CalendarMode.weekWithTimetable;

  bool _modeChangedByPicker = false;

  /// Returns a [String] representing the current `visibleDate`.
  String headerTitleForVisibleDate() {
    switch (mode) {
      case CalendarMode.day:
      case CalendarMode.dayWithTimetable:
        return DateFormat('EEEE dd MMMM yyyy').format(visibleDate);
      case CalendarMode.week:
      case CalendarMode.weekWithTimetable:
        if (_firstVisibleDate.month == _lastVisibleDate.month) {
          return DateFormat('MMMM yyyy').format(visibleDate);
        }
        var initialMonth = DateFormat('MMMM').format(_firstVisibleDate);
        var finalMonth = DateFormat('MMMM').format(_lastVisibleDate);
        if (_firstVisibleDate.year == _lastVisibleDate.year) {
          return "$initialMonth/$finalMonth ${_lastVisibleDate.year}";
        }
        return "$initialMonth ${_firstVisibleDate.year}/$finalMonth ${_lastVisibleDate.year}";
      case CalendarMode.month:
        return DateFormat('MMMM yyyy').format(visibleDate);
      case CalendarMode.year:
        return visibleDate.year.toString();
      case CalendarMode.multiYear:
        return "${_firstVisibleDate.year} - ${_lastVisibleDate.year}";
    }
  }

  void _evaluateInitialVisibleDates(DateTime dateToBeVisible) {
    var currentDate = dateToBeVisible;
    if (startDate != null) {
      if (currentDate.isDateBefore(
          startDate ?? DateTime.now().subtract(const Duration(days: 1)))) {
        currentDate = startDate ?? DateTime.now();
      }
    }
    if (endDate != null) {
      if (currentDate.isDateAfter(
          endDate ?? DateTime.now().add(const Duration(days: 1)))) {
        currentDate = endDate ?? DateTime.now();
      }
    }

    _makeDateVisible(currentDate);
  }

  /// Returns _true_ if the provided date has been selected by the user.
  ///
  /// This can be useful for cell styling purposes.
  bool isDateSelected(DateTime date) {
    switch (mode) {
      case CalendarMode.day:
      case CalendarMode.dayWithTimetable:
      case CalendarMode.week:
      case CalendarMode.weekWithTimetable:
      case CalendarMode.month:
        return date.getDateOnly() == selectedDate?.getDateOnly() ||
            date.getDateOnly() == selectedEndDate?.getDateOnly();
      case CalendarMode.year:
        return date.getDateOnly(withDay: false) ==
                selectedDate?.getDateOnly(withDay: false) ||
            date.getDateOnly(withDay: false) ==
                selectedEndDate?.getDateOnly(withDay: false);
      case CalendarMode.multiYear:
        return date.year == selectedDate?.year ||
            date.year == selectedEndDate?.year;
    }
  }

  /// Returns _true_ if the provided date is between initial date and last date
  /// selected by the user when picking a date range.
  ///
  /// This can be useful for cell styling purposes.
  bool isDateInSelectionRange(DateTime date) {
    if (selectedDate == null || selectedEndDate == null) {
      return false;
    }
    return date.isDateAfter(selectedDate!) &&
        date.isDateBefore(selectedEndDate!);
  }

  /// Returns _true_ if cells should be selectable.
  bool shouldAllowSelection(DateTime date) =>
      (onSelectDate != null || onSelectDateRange != null) &&
      (startDate == null || date.isAfter(startDate!)) &&
      (endDate == null || date.isBefore(endDate!));

  /// Select the provided date, updating the calendar UI. Furthermore,
  /// fires the callback set by the user (either single date or date ragne).
  ///
  /// If previously the method [CalendarAdvancedController.setMode] was called with
  /// the parameter `changedByPicker` set to _true_, this method will not call
  /// the callback for selected date, but will updated the calendar mode accordingly.
  void selectDate(DateTime date) {
    if (_modeChangedByPicker) {
      switch (mode) {
        case CalendarMode.day:
        case CalendarMode.dayWithTimetable:
        case CalendarMode.week:
        case CalendarMode.weekWithTimetable:
        case CalendarMode.month:
          _modeChangedByPicker = false;
          _makeDateVisible(date);
        case CalendarMode.year:
          _modeChangedByPicker = initialMode != CalendarMode.month;
          setMode(CalendarMode.month,
              changedByPicker: _modeChangedByPicker, dateToBeVisible: date);
        case CalendarMode.multiYear:
          _modeChangedByPicker = initialMode != CalendarMode.year;
          setMode(CalendarMode.year,
              changedByPicker: _modeChangedByPicker, dateToBeVisible: date);
      }
      return;
    }

    if (onSelectDateRange == null) {
      selectedDate = date;
      onSelectDate?.call(date);
    } else {
      if (selectedDate == null) {
        selectedDate = date;
      } else {
        if (selectedEndDate != null ||
            date.isDateBefore(selectedDate ?? DateTime.now())) {
          selectedDate = date;
          selectedEndDate = null;
        } else {
          selectedEndDate = date;
          onSelectDateRange?.call(selectedDate ?? DateTime.now(), date);
        }
      }
    }

    notifyListeners();
  }

  /// Sets the [CalendarMode] and updates the calendar UI accordingly.
  ///
  /// If `changedByPicker` is set to _true_, when selecting a date in year or multi-year view,
  /// the calendar will behave like a picker and will cange the [CalendarMode] to select
  /// a specific date.
  void setMode(
    CalendarMode mode, {
    bool changedByPicker = false,
    DateTime? dateToBeVisible,
  }) {
    _modeChangedByPicker = changedByPicker;
    this.mode = mode;
    _makeDateVisible(dateToBeVisible ?? selectedDate ?? initialDate);
  }

  DateTime _evaluateNewDateToBeVisible({bool forward = true}) {
    switch (mode) {
      case CalendarMode.day:
      case CalendarMode.dayWithTimetable:
        if (forward) {
          var newDate = _firstVisibleDate.add(const Duration(days: 1));
          while (hiddenWeekdays.contains(newDate.weekday)) {
            newDate = newDate.add(const Duration(days: 1));
          }
          return newDate;
        } else {
          var newDate = _firstVisibleDate.subtract(const Duration(days: 1));
          while (hiddenWeekdays.contains(newDate.weekday)) {
            newDate = newDate.subtract(const Duration(days: 1));
          }
          return newDate;
        }
      case CalendarMode.week:
      case CalendarMode.weekWithTimetable:
        if (forward) {
          return _firstVisibleDate
              .add(Duration(days: 8 - _firstVisibleDate.weekday));
        } else {
          return _firstVisibleDate
              .subtract(Duration(days: _firstVisibleDate.weekday));
        }
      case CalendarMode.month:
        if (forward) {
          final dateToEvaluate = _firstVisibleDate.add(const Duration(days: 7));
          return DateHelper.addMonths(1, toMonth: dateToEvaluate);
        } else {
          final dateToEvaluate = _firstVisibleDate.add(const Duration(days: 7));
          return DateHelper.addMonths(-1, toMonth: dateToEvaluate);
        }
      case CalendarMode.year:
        if (forward) {
          return DateTime(_firstVisibleDate.year + 1, 12, 31);
        } else {
          return DateTime(_firstVisibleDate.year - 1, 12, 31);
        }
      case CalendarMode.multiYear:
        var initialYear =
            _firstVisibleDate.year - (_firstVisibleDate.year % 10) + 1;
        if (forward) {
          return DateTime(initialYear + 10);
        } else {
          return DateTime(initialYear - 2);
        }
    }
  }

  /// Evaluate if the calendar can be scrolled to show more dates backward depending
  /// on calendar `startDate`.
  bool canGoBackward() {
    if (startDate == null) {
      return true;
    }
    var newDate = _evaluateNewDateToBeVisible(forward: false);
    return newDate.isDateAfter(startDate ?? DateTime.now());
  }

  /// Evaluate if the calendar can be scrolled to show more dates forward depending
  /// on calendar `endDate`.
  bool canGoForkward() {
    if (endDate == null) {
      return true;
    }
    var newDate = _evaluateNewDateToBeVisible(forward: true);
    return newDate.isDateBefore(endDate ?? DateTime.now());
  }

  /// Scrolls the calendar backward depending on [CalendarMode]
  void goBackward() {
    _makeDateVisible(_evaluateNewDateToBeVisible(forward: false));
  }

  /// Scrolls the calendar forward depending on [CalendarMode]
  void goForward() {
    _makeDateVisible(_evaluateNewDateToBeVisible(forward: true));
  }

  /// Scrolls the calendar to show today and updates dates accordingly.
  void goToToday({bool selectDay = false}) {
    final now = DateTime.now();
    if (selectDay && shouldAllowSelection(now)) {
      selectDate(now);
    } else {
      goToDate(now);
    }
  }

  /// Scrolls the calendar to show the specified date and updates dates accordingly.
  void goToDate(DateTime date) {
    _makeDateVisible(date);
  }

  void _makeDateVisible(DateTime date) async {
    visibleDate = date;

    switch (mode) {
      case CalendarMode.day:
      case CalendarMode.dayWithTimetable:
        _firstVisibleDate = date;
        _lastVisibleDate = date;
        break;

      case CalendarMode.week:
      case CalendarMode.weekWithTimetable:
        final currentWeekday = date.weekday;

        _firstVisibleDate = date.subtract(Duration(days: currentWeekday - 1));
        _lastVisibleDate = date.add(Duration(days: 7 - currentWeekday));
        break;
      case CalendarMode.month:
        final DateTime firstMonthDay =
            DateHelper.getFirstDayOfMonth(month: date);
        final DateTime lastMonthDay = DateHelper.getLastDayOfMonth(month: date);
        _firstVisibleDate =
            firstMonthDay.subtract(Duration(days: firstMonthDay.weekday - 1));
        _lastVisibleDate =
            lastMonthDay.add(Duration(days: 7 - lastMonthDay.weekday));
      case CalendarMode.year:
        _firstVisibleDate = DateTime(date.year);
        _lastVisibleDate = DateTime(date.year, 12);
      case CalendarMode.multiYear:
        var initialYear = date.year - (date.year % 10) + 1;
        _firstVisibleDate = DateTime(initialYear);
        _lastVisibleDate = DateTime(initialYear + 9);
    }

    await onScrollCalendar?.call(mode, _firstVisibleDate, _lastVisibleDate);

    notifyListeners();
  }

  /// Returns the list of visible dates in the calendar for the current [CalendarMode].
  List<DateTime> getVisibleDates() {
    List<DateTime> dates = [];

    switch (mode) {
      case CalendarMode.day:
      case CalendarMode.dayWithTimetable:
      case CalendarMode.week:
      case CalendarMode.weekWithTimetable:
      case CalendarMode.month:
        while (!dates.contains(_lastVisibleDate.getDateOnly())) {
          if (dates.isEmpty) {
            dates.add(_firstVisibleDate);
          } else {
            dates.add(dates.last.add(const Duration(days: 1)).getDateOnly());
          }
        }

        for (var hiddenWeekday in hiddenWeekdays) {
          dates.removeWhere((date) => date.weekday == hiddenWeekday);
        }
      case CalendarMode.year:
        while (!dates.contains(_lastVisibleDate.getDateOnly())) {
          if (dates.isEmpty) {
            dates.add(_firstVisibleDate);
          } else {
            dates.add(
                DateTime(dates.last.year, dates.last.month + 1).getDateOnly());
          }
        }
      case CalendarMode.multiYear:
        while (!dates.contains(_lastVisibleDate.getDateOnly())) {
          if (dates.isEmpty) {
            dates.add(_firstVisibleDate);
          } else {
            dates.add(DateTime(dates.last.year + 1).getDateOnly());
          }
        }
    }

    return dates;
  }

  /// Returns the list of visible hours in the calendar timetable for the current [CalendarMode].
  List<String> getTimetableHours() {
    List<String> hours = [];
    int index = 0;
    while (!hours.contains(endHour.convertToTime())) {
      hours.add((startHour + index).convertToTime());
      index++;
    }

    return hours;
  }

  /// Reload the calendar builder and `onScrollCalendar` callback for the current dates.
  Future<void> reloadCurrentDates() async {
    await onScrollCalendar?.call(mode, _firstVisibleDate, _lastVisibleDate);
    notifyListeners();
  }
}
