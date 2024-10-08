import 'package:intl/intl.dart';

extension DoubleExtension on double {
  String convertToTime() {
    String getMinuteString(double decimalValue) {
      return '${(decimalValue * 60).toInt()}'.padLeft(2, '0');
    }

    String getHourString(int flooredValue) {
      return '${flooredValue % 24}'.padLeft(2, '0');
    }

    if (this < 0) return 'Invalid Value';
    int flooredValue = floor();
    double decimalValue = this - flooredValue;
    String hourValue = getHourString(flooredValue);
    String minuteString = getMinuteString(decimalValue);

    return '$hourValue:$minuteString';
  }
}

extension DateTimeExtension on DateTime {
  String format({DateFormat? format}) {
    var df = format ?? DateFormat("dd MMM yyyy");
    return df.format(this);
  }

  String toTime() {
    var df = DateFormat("HH:mm");
    return df.format(this);
  }
}
