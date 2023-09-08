import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../calendar_advanced.dart';
import '../../logic/calendar_advanced_controller.dart';

class CalendarTimetableBackgroundView extends StatefulWidget {
  final double timetableRowHeight;
  const CalendarTimetableBackgroundView({
    super.key,
    this.timetableRowHeight = 150,
  });

  @override
  State<CalendarTimetableBackgroundView> createState() =>
      _CalendarTimetableBackgroundViewState();
}

class _CalendarTimetableBackgroundViewState
    extends State<CalendarTimetableBackgroundView> {
  final key = GlobalKey();
  final Set<CellRenderProxy> _trackedCells = {};
  DateTime? _initialHourSelected;
  DateTime? _lastHourSelected;
  bool get shouldAllowSelectDates {
    return context.read<CalendarAdvancedController>().onSelectTimeSlot !=
            null &&
        context.read<CalendarAdvancedController>().isWithTimetables;
  }

  void _detectTapedItem(PointerEvent event, {bool isPointerDownEvent = false}) {
    if (isPointerDownEvent) {
      _clearSelection();
    }

    final RenderBox? box =
        key.currentContext?.findAncestorRenderObjectOfType<RenderBox>();
    if (box == null) {
      return;
    }
    final result = BoxHitTestResult();
    Offset local = box.globalToLocal(event.position);
    if (box.hitTest(result, position: local)) {
      for (final hit in result.path) {
        /// temporary variable so that the [is] allows access of [index]
        final target = hit.target;
        if (target is CellRenderProxy) {
          _selectCell(target);
        }
      }
    }
  }

  void _selectCell(CellRenderProxy target) {
    // Avoid selecting cells from another column (day is unique)
    if (_trackedCells
        .where((element) => element.columnIndex != target.columnIndex)
        .isNotEmpty) {
      return;
    }

    // Avoid selecting cells before the first selected cell in a column (initial hour is fixed)
    if (_trackedCells
        .where((element) =>
            (element.rowIndex > target.rowIndex) ||
            (element.rowIndex == target.rowIndex &&
                (element.innerIndex ?? 0) > (target.innerIndex ?? 0)))
        .isNotEmpty) {
      if (_trackedCells.length == 1) {
        return;
      }
      // Deselect cells if pointer is going up
      if (_trackedCells.lastOrNull?.rowIndex == target.rowIndex &&
          (_trackedCells.lastOrNull?.innerIndex ?? 0) >
              (target.innerIndex ?? 0)) {
        _trackedCells.remove(_trackedCells.last);
      } else if ((_trackedCells.lastOrNull?.rowIndex ?? 0) > target.rowIndex) {
        _trackedCells.remove(_trackedCells.last);
      }
      _lastHourSelected = _convertCellToDate(target);

      setState(() {});
      return;
    }

    // Avoid selecting same target
    if (_trackedCells
        .where((element) =>
            element.rowIndex == target.rowIndex &&
            element.columnIndex == target.columnIndex &&
            element.innerIndex == target.innerIndex)
        .isNotEmpty) {
      return;
    }

    // Set initial date
    if (_trackedCells.isEmpty) {
      _initialHourSelected = _convertCellToDate(target, isInitialDate: true);
    }

    _lastHourSelected = _convertCellToDate(target);

    // Select missing cells among first and last to avoid inconsistency
    var initialInnerIndex =
        _trackedCells.firstOrNull?.innerIndex ?? target.innerIndex;
    var lastInnerIndex = target.innerIndex;
    var initialRowIndex =
        _trackedCells.firstOrNull?.rowIndex ?? target.rowIndex;
    var lastRowIndex = target.rowIndex;
    for (int i = initialRowIndex; i <= lastRowIndex; i++) {
      if (_trackedCells
              .where(
                  (element) => element.rowIndex == i && element.innerIndex == 0)
              .isEmpty &&
          (initialInnerIndex != 1 || i != initialRowIndex)) {
        _trackedCells.add(CellRenderProxy(
            rowIndex: i, columnIndex: target.columnIndex, innerIndex: 0));
      }
      if (_trackedCells
              .where(
                  (element) => element.rowIndex == i && element.innerIndex == 1)
              .isEmpty &&
          (lastInnerIndex != 0 || i != lastRowIndex)) {
        _trackedCells.add(CellRenderProxy(
            rowIndex: i, columnIndex: target.columnIndex, innerIndex: 1));
      }
    }

    setState(() {
      // _trackedCells.add(target);
    });
  }

  void _clearSelection() {
    setState(() {
      _trackedCells.clear();
    });
  }

  DateTime _convertCellToDate(CellRenderProxy cell,
      {bool isInitialDate = false}) {
    var hours = context.read<CalendarAdvancedController>().getTimetableHours();
    var visibleDates =
        context.read<CalendarAdvancedController>().getVisibleDates();

    var hour = int.tryParse(hours[cell.rowIndex].substring(0, 2)) ?? 0;
    if (cell.innerIndex == 0 && isInitialDate) {
      hour -= 1;
    }
    var minutes = int.tryParse(hours[cell.rowIndex].substring(3)) ?? 0;
    if ((cell.innerIndex == 0 && isInitialDate) ||
        (cell.innerIndex == 1 && !isInitialDate)) {
      minutes += 30;
    }

    context.read<CalendarAdvancedController>().getVisibleDates();

    return DateTime(
        visibleDates[cell.columnIndex].year,
        visibleDates[cell.columnIndex].month,
        visibleDates[cell.columnIndex].day,
        hour,
        minutes);
  }

  String _getTimeSlotFromDate(
      {required DateTime? initialDateSelected,
      required DateTime? lastDateSelected}) {
    if (initialDateSelected == null || lastDateSelected == null) {
      return "";
    }
    var dateFormat = DateFormat("HH:mm");
    return "${dateFormat.format(initialDateSelected)}-${dateFormat.format(lastDateSelected)}";
  }

  void _callbackWithSelectedTimeSlot(PointerEvent event) {
    context.read<CalendarAdvancedController>().onSelectTimeSlot?.call(
        _initialHourSelected ?? DateTime.now(),
        _lastHourSelected ?? DateTime.now());
    _clearSelection();
  }

  @override
  Widget build(BuildContext context) {
    var hours = context.read<CalendarAdvancedController>().getTimetableHours();
    var columnNumber =
        context.read<CalendarAdvancedController>().getVisibleDates().length;

    return MouseRegion(
      cursor:
          shouldAllowSelectDates ? SystemMouseCursors.click : MouseCursor.defer,
      child: Listener(
        onPointerDown: shouldAllowSelectDates
            ? (event) => _detectTapedItem(event, isPointerDownEvent: true)
            : null,
        onPointerMove: shouldAllowSelectDates ? _detectTapedItem : null,
        onPointerUp:
            shouldAllowSelectDates ? _callbackWithSelectedTimeSlot : null,
        child: ListView.separated(
          padding: EdgeInsets.zero,
          key: key,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: hours.length,
          separatorBuilder: (context, index) {
            return const Divider(
              height: 0,
            );
          },
          itemBuilder: (context, index) => Row(
            children: [
              SizedBox(width: 50, child: Center(child: Text(hours[index]))),
              ...List.generate(columnNumber, (columnIndex) {
                return Expanded(
                  child: Column(
                    children: [
                      _cell(
                          index: index,
                          columnIndex: columnIndex,
                          innerIndex: 0),
                      const Divider(
                        height: 0,
                      ),
                      _cell(
                          index: index,
                          columnIndex: columnIndex,
                          innerIndex: 1),
                    ],
                  ),
                );
              }),
              // const SizedBox(
              //   width: 50,
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cell({
    required int index,
    required int columnIndex,
    required innerIndex,
  }) {
    bool isFirstSelectedCell = _trackedCells.firstOrNull?.rowIndex == index &&
        _trackedCells.firstOrNull?.columnIndex == columnIndex &&
        _trackedCells.firstOrNull?.innerIndex == innerIndex;
    return Stack(
      children: [
        CellRenderObject(
          rowIndex: index,
          columnIndex: columnIndex,
          innerIndex: innerIndex,
          child: Container(
            color: _trackedCells.singleWhereOrNull((cell) =>
                        cell.rowIndex == index &&
                        cell.columnIndex == columnIndex &&
                        cell.innerIndex == innerIndex) !=
                    null
                ? Theme.of(context).primaryColor.withOpacity(0.8)
                : Colors.transparent,
            height: widget.timetableRowHeight.toDouble() / 2,
          ),
        ),
        if (isFirstSelectedCell)
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 10),
            child: Text(
              _getTimeSlotFromDate(
                  initialDateSelected: _initialHourSelected,
                  lastDateSelected: _lastHourSelected),
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(color: Colors.white),
            ),
          ),
      ],
    );
  }
}

class CellRenderObject extends SingleChildRenderObjectWidget {
  final int rowIndex;
  final int columnIndex;
  final int? innerIndex;

  const CellRenderObject(
      {required Widget child,
      required this.rowIndex,
      required this.columnIndex,
      this.innerIndex,
      Key? key})
      : super(child: child, key: key);

  @override
  CellRenderProxy createRenderObject(BuildContext context) {
    return CellRenderProxy(
        rowIndex: rowIndex, columnIndex: columnIndex, innerIndex: innerIndex);
  }

  @override
  void updateRenderObject(BuildContext context, CellRenderProxy renderObject) {
    renderObject.rowIndex = rowIndex;
    renderObject.columnIndex = columnIndex;
    renderObject.innerIndex = innerIndex;
  }
}

class CellRenderProxy extends RenderProxyBox {
  int rowIndex;
  int columnIndex;
  int? innerIndex;
  CellRenderProxy({
    required this.rowIndex,
    required this.columnIndex,
    this.innerIndex,
  });
}
