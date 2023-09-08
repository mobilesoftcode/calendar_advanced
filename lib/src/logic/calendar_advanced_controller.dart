import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../calendar_advanced.dart';
import '../../utils/utility.dart';

import '../../utils/helpers/date_helper.dart';

class CalendarAdvancedController extends ChangeNotifier {
  final DateTime? startDate;
  final DateTime? endDate;
  final double startHour;
  final double endHour;
  final List<int> hiddenWeekdays;
  late final DateTime initialDate;
  final CalendarMode initialMode;

  /// When the user selects a date, this method is called
  /// to take appropriate actions.
  ///
  /// If this is not provided, the calendar will be only in read mode.
  final void Function(DateTime date)? onSelectDate;
  final void Function(DateTime startDate, DateTime endDate)? onSelectDateRange;

  /// If not `null`, the calendar will open with this date selected.
  /// It defaults to `null`, so the calendar will open with the current date selected.
  DateTime? selectedDate;
  DateTime? selectedEndDate;

  final void Function(DateTime initialDateHour, DateTime lastDateHour)?
      onSelectTimeSlot;
  final Future<void> Function(
          CalendarMode mode, DateTime startDate, DateTime endDate)?
      onScrollCalendar;

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
  })  : assert((startDate ?? DateTime.now()).isDateBefore(
            (endDate ?? DateTime.now().add(const Duration(days: 1))))),
        assert(hiddenWeekdays.length < 7),
        assert(hiddenWeekdays.every((element) => element <= 7)),
        assert(startHour < endHour) {
    this.initialDate = initialDate ?? DateTime.now().getDateOnly();
    mode = initialMode;
    _evaluateInitialVisibleDates(this.initialDate);
  }

  late DateTime _firstVisibleDate;
  late DateTime _lastVisibleDate;
  late CalendarMode mode;
  late DateTime visibleDate;

  bool get isWithTimetables =>
      mode == CalendarMode.dayWithTimetable ||
      mode == CalendarMode.weekWithTimetable;

  bool _modeChangedByPicker = false;

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

  bool isDateInSelectionRange(DateTime date) {
    if (selectedDate == null || selectedEndDate == null) {
      return false;
    }
    return date.isDateAfter(selectedDate!) &&
        date.isDateBefore(selectedEndDate!);
  }

  bool shouldAllowSelection() =>
      onSelectDate != null || onSelectDateRange != null;

  void selectDate(DateTime date) {
    if (_modeChangedByPicker) {
      selectedDate = date;
      switch (mode) {
        case CalendarMode.day:
        case CalendarMode.dayWithTimetable:
        case CalendarMode.week:
        case CalendarMode.weekWithTimetable:
        case CalendarMode.month:
          _modeChangedByPicker = false;
        case CalendarMode.year:
          _modeChangedByPicker = initialMode != CalendarMode.month;
          setMode(CalendarMode.month, changedByPicker: _modeChangedByPicker);
        case CalendarMode.multiYear:
          _modeChangedByPicker = initialMode != CalendarMode.year;
          setMode(CalendarMode.year, changedByPicker: _modeChangedByPicker);
      }
      notifyListeners();
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

  void setMode(
    CalendarMode mode, {
    bool changedByPicker = false,
  }) {
    _modeChangedByPicker = changedByPicker;
    this.mode = mode;
    _makeDateVisible(selectedDate ?? initialDate);
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

  bool canGoBackward() {
    if (startDate == null) {
      return true;
    }
    var newDate = _evaluateNewDateToBeVisible(forward: false);
    return newDate.isDateAfter(startDate ?? DateTime.now());
  }

  bool canGoForkward() {
    if (endDate == null) {
      return true;
    }
    var newDate = _evaluateNewDateToBeVisible(forward: true);
    return newDate.isDateBefore(endDate ?? DateTime.now());
  }

  void goBackward() {
    _makeDateVisible(_evaluateNewDateToBeVisible(forward: false));
  }

  void goForward() {
    _makeDateVisible(_evaluateNewDateToBeVisible(forward: true));
  }

  void goToToday() {
    goToDate(DateTime.now());
  }

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

  List<String> getTimetableHours() {
    List<String> hours = [];
    int index = 0;
    while (!hours.contains(endHour.convertToTime())) {
      hours.add((startHour + index).convertToTime());
      index++;
    }

    return hours;
  }

  Future<void> reloadCurrentDates() async {
    await onScrollCalendar?.call(mode, _firstVisibleDate, _lastVisibleDate);
    notifyListeners();
  }
}
