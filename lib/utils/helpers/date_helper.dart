extension DateExtension on DateTime {
  //
  // ATTRIBUTES
  //

  /// Check if `this` is a day in the weekend (saturday or sunday)
  bool get isWeekend =>
      weekday == DateTime.saturday || weekday == DateTime.sunday;

  /// Check if `this` is same day as today
  bool get isToday {
    var now = DateTime.now();
    return day == now.day && month == now.month && year == now.year;
  }

  /// Chech if `this` is a day in the past (before today)
  bool get isPastDay => isBefore(DateTime.now().getDateOnly());

  /// Chech if `this` is a day in the future (after today)
  bool get isFutureDay => isAfter(DateTime.now().getDateOnly());

  /// Chech if `this` is yesterday (one day in the past)
  bool get isYesterday =>
      DateTime.now().getDateOnly().subtract(const Duration(days: 1)) ==
      getDateOnly();

  /// Chech if `this` is tomorrow (one day in the future)
  bool get isTomorrow =>
      DateTime.now().getDateOnly().add(const Duration(days: 1)) ==
      getDateOnly();

  /// Chech if `this` month is the current month
  bool get isCurrentMonth {
    var now = DateTime.now();
    return month == now.month && year == now.year;
  }

  //
  // METHODS
  //

  /// Returns a [DateTime] with the same date as `this`
  /// but no reference to time
  DateTime getDateOnly({bool withDay = true}) =>
      DateTime.utc(year, month, withDay ? day : 1);

  /// Check if `this` is before than `date` (without reference to Time)
  bool isDateBefore(DateTime date) =>
      getDateOnly().isBefore(date.getDateOnly());

  /// Chech if `this` is the same date then `other` (without reference to Time)
  bool isSameDay(DateTime date) =>
      day == date.day && month == date.month && year == date.year;

  /// Check if `this` is after than `date` (without reference to Time)
  bool isDateAfter(DateTime date) => getDateOnly().isAfter(date.getDateOnly());

  /// Calculates the difference in months between `this` date and `other`.
  ///
  /// If the returned int is a positive number, `this` is before `other`, and vice-versa.
  int monthsDiffrenceTo(DateTime date) =>
      12 * (date.year - year) + date.month - month;
}

class DateHelper {
  /// Returns a date with the same month and year of the specified date,
  /// and the first day of that month.
  ///
  /// If [month] is not specified, return the first day of the current month.
  static DateTime getFirstDayOfMonth({DateTime? month}) => (month != null)
      ? DateTime(month.year, month.month)
      : getFirstDayOfMonth(month: DateTime.now());

  /// Returns a date with the same month and year of the current date,
  /// and the first day of the current month.
  ///
  /// If [month] is not specified, return the first day of the current month's next month.
  static DateTime getFirstDayOfNextMonth({DateTime? month}) {
    var dateTime = getFirstDayOfMonth(month: month);
    dateTime = dateTime.add(const Duration(days: 32));
    dateTime = getFirstDayOfMonth(month: dateTime);
    return dateTime.getDateOnly();
  }

  /// Returns a date with the same month and year of the specified date,
  /// and the last day of that month.
  ///
  /// If [month] is not specified, return the last day of the current month.
  static DateTime getLastDayOfMonth({DateTime? month}) {
    DateTime firstDayOfNextMonth = getFirstDayOfNextMonth(month: month);
    return firstDayOfNextMonth.subtract(const Duration(days: 1)).getDateOnly();
  }

  /// Returns a date with the specified months added or subtracted
  /// to the specified month.
  ///
  /// If [toMonth] is not specified, the current month is taken.
  static DateTime addMonths(int months, {DateTime? toMonth}) {
    DateTime firstDayOfCurrentMonth = toMonth ?? DateTime.now();

    if (months > 0) {
      for (int i = 0; i < months; i++) {
        firstDayOfCurrentMonth =
            getLastDayOfMonth(month: firstDayOfCurrentMonth)
                .add(const Duration(days: 1));
      }
    } else {
      for (int i = 0; i > months; i--) {
        firstDayOfCurrentMonth =
            getFirstDayOfMonth(month: firstDayOfCurrentMonth)
                .subtract(const Duration(days: 1));
      }
    }

    return firstDayOfCurrentMonth;
  }

  /// Calculate the max number of weeks in a date interval between
  /// [monthStartDate] and [monthEndDate] which have the same month.
  static double calculateWeeksNumber(DateTime startDate, DateTime endDate) {
    var daysBetweenDates = endDate.difference(startDate);

    return daysBetweenDates.inDays / DateTime.daysPerWeek;
  }

  /// This method returns a list of [int] values representing the days
  /// of the specified `inMonth` that are in the weekend.
  static List<int> retrieveWeekendDates({required DateTime inMonth}) {
    var daysInMonth = retrieveDaysInMonth(inMonth);
    var listOfDates = List<int>.generate(daysInMonth, (i) => i + 1);
    var filterDates = listOfDates
        .where((element) =>
            DateTime(inMonth.year, inMonth.month, element).isWeekend)
        .toList();
    return filterDates;
  }

  /// Calculate the number of days in the specified `month`
  static int retrieveDaysInMonth(DateTime month) {
    var firstDayThisMonth = DateHelper.getFirstDayOfMonth(month: month);
    var firstDayNextMonth = DateHelper.getFirstDayOfNextMonth(month: month);
    return firstDayNextMonth.difference(firstDayThisMonth).inDays;
  }
}
