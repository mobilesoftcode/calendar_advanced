This package contains a calendar for Flutter projects.
<br>
The calendar can be shown either in monthly, weekly or daily view, and there are several properties that can be modified.
<br>
The package can be also used for a date picker or a date range picker, in multi-year, year, month or week view.
<br>
<br>
This package provides a date helper to manage operations between dates, too.

## Features

This package contains the following widgets ready to use out of the box, after setting appropriately the properties as shown in _Usage_ paragraph:
* `CalendarAdvanced`: A scrolling calendar with monthly, weekly or daily view and eventually picker mode with also a multi-year and a yearly view. Furthermore, it provides weekly or daily view with timetable.

Furthermore, the package implements a `DateHelper` class and an extension of `DateTime` class to provide access to some operations among dates. For further informations about the exposed methods, refer to the documentation of the class.

## Usage
The calendar can be shown either in monthly, weekly or daily view. There are methods to know if the user changed the date interval (such as scrolling months or weeks) or if the user selected a date. 

If you do not provide builders for cells and header, default UI will be used. The cell appearance will change according to the screen size.

To initialize the calendar with default appearance and only in view mode (by the default weekly mode), simply use the widget:

``` dart
return CalendarAdvanced();
```

To customize the calendar UI you can use the provided builders. Note that `calendarCellContentBuilder` should be used to place content in the timetable depending on hours, and it will be shown in a stacked view above the `calendarCellBuilder`.

``` dart
return CalendarAdvanced(
    calendarCellBuilder: (date, isSelected, mode) {

        // You can change appearance depending on mode
        if (mode == CalendarMode.month) {
            return Text(date.toString());
        }

        /// You can change appearance depending on cell selection, if enabled
        return Container(
            color: isSelected ? Colors.blue : Colors.red,
            child: Text(date.toString());
        )
    }
);
```

To enable date selection, change initial mode, set initial date or dates that must be visible in the calendar, you can pass a controller to the calendar widget. You can also use the controller to take actions on the calendar. Check the class documentation for all the properties of the calendar.

``` dart
return CalendarAdvanced(
    controller: CalendarAdvancedController(
    initialMode: CalendarMode.month,
    onSelectDate: (date) { // If provided, enables date selection
        print(date);
    },
    onSelectTimeSlot: (initialDateHour, lastDateHour) {}, // If provided, enables timeslot selecion in timetables
    onSelectDateRange: (startDate, endDate) {}, // If provided, enables date range selection (and overrides `onSelectDate` logic)
    ),
    onScrollCalendar: (startDate, endDate) async {}, // When the calendar is scolled, this callback is await before showing the new dates. This can be useful to load data from API and showing it in the calendar when needed
);
```

You can take actions on the calendar thanks to the controller, such as changing mode or moving between dates.

``` dart
var controller = CalendarAdvancedController();
// ...
controller.setMode(CalendarMode.month);
controller.goBackward();
```

## Additional information

This package is mantained by the Competence Center Flutter of Mobilesoft Srl.
