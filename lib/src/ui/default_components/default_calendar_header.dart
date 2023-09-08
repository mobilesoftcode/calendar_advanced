import 'package:flutter/material.dart';
import '../../../calendar_advanced.dart';

/// The calendar header with icon buttons to take actions and a title.
class DefaultCalendarHeader extends StatelessWidget {
  final CalendarAdvancedController controller;

  /// The calendar header with icon buttons to take actions and a title.
  /// It's a container with a 50px height and infinite width.
  const DefaultCalendarHeader({
    Key? key,
    required this.controller,
  }) : super(key: key);

  static Widget builder(CalendarAdvancedController controller) {
    return DefaultCalendarHeader(controller: controller);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            children: [
              _todayIconWidget(),
              const Spacer(),
              _leftIconWidget(),
              _rightIconWidget(),
              controller.mode == CalendarMode.month
                  ? _weekIconWidget()
                  : _monthIconWidget(),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Material(
              child: InkWell(
                onTap: () {
                  controller.setMode(
                      controller.mode == CalendarMode.year
                          ? CalendarMode.multiYear
                          : CalendarMode.year,
                      changedByPicker: true);
                },
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    controller.headerTitleForVisibleDate(),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// The widget to indicate the "select today" action.
  /// If tapped, fires appropriate actions, and select current day in calendar.
  Widget _todayIconWidget() {
    return MergeSemantics(
      child: Semantics(
        value: "Seleziona giorno corrente",
        hint: "Tocca due volte per selezionare il giorno corrente",
        onTap: () {
          controller.goToToday();
        },
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: Material(
            child: InkWell(
              borderRadius: BorderRadius.circular(5),
              child: const Padding(
                padding: EdgeInsets.fromLTRB(17, 12, 17, 12),
                child: Icon(Icons.today_outlined),
              ),
              onTap: () {
                controller.goToToday();
              },
            ),
          ),
        ),
      ),
    );
  }

  /// The widget to indicate the "show weekly view" action.
  /// If tapped, fires appropriate actions, and change calendar view mode to weekly.
  Widget _weekIconWidget() {
    return MergeSemantics(
      child: Semantics(
        value: "Riduci vista a settimana",
        hint: "Tocca due volte per ridurre la visualizzazione",
        onTap: () {
          controller.setMode(CalendarMode.week);
        },
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: Material(
            child: InkWell(
              borderRadius: BorderRadius.circular(5),
              child: const Padding(
                padding: EdgeInsets.fromLTRB(17, 12, 17, 12),
                child: Icon(Icons.calendar_view_week),
              ),
              onTap: () {
                controller.setMode(CalendarMode.week);
              },
            ),
          ),
        ),
      ),
    );
  }

  /// The widget to indicate the "show month view" action.
  /// If tapped, fires appropriate actions, and change calendar view mode to monthly.
  Widget _monthIconWidget() {
    return MergeSemantics(
      child: Semantics(
        value: "Espandi vista a mese intero",
        hint: "Tocca due volte per espandere la visualizzazione",
        onTap: () {
          controller.setMode(CalendarMode.month);
        },
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: Material(
            child: InkWell(
              borderRadius: BorderRadius.circular(5),
              child: const Padding(
                padding: EdgeInsets.fromLTRB(17, 12, 17, 12),
                child: Icon(Icons.calendar_month),
              ),
              onTap: () {
                controller.setMode(CalendarMode.month);
              },
            ),
          ),
        ),
      ),
    );
  }

  /// The widget to indicate the "scroll backward" action.
  /// If tapped, fires appropriate actions, and scroll calendar dates backward.
  Widget _leftIconWidget() {
    return Opacity(
        opacity: controller.canGoBackward() ? 1 : 0.5,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(3, 3, 1, 3),
          child: Material(
            child: InkWell(
              borderRadius: BorderRadius.circular(5),
              onTap: controller.canGoBackward() ? controller.goBackward : null,
              child: const Padding(
                padding: EdgeInsets.fromLTRB(17, 12, 15, 12),
                child: Icon(Icons.chevron_left),
              ),
            ),
          ),
        ));
  }

  /// The widget to indicate the "scroll forward" action.
  /// If tapped, fires appropriate actions, and scroll calendar dates forward.
  Widget _rightIconWidget() {
    return Opacity(
      opacity: controller.canGoForkward() ? 1 : 0.5,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(1, 3, 3, 3),
        child: Material(
          child: InkWell(
            borderRadius: BorderRadius.circular(5),
            onTap: controller.canGoForkward() ? controller.goForward : null,
            child: const Padding(
              padding: EdgeInsets.fromLTRB(15, 12, 17, 12),
              child: Icon(Icons.chevron_right),
            ),
          ),
        ),
      ),
    );
  }
}
