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
