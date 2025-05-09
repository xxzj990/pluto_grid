import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import 'mixin_popup_cell.dart';

class PlutoSelectCell extends StatefulWidget implements AbstractMixinPopupCell {
  final PlutoGridStateManager? stateManager;
  final PlutoCell? cell;
  final PlutoColumn? column;
  final PlutoRow? row;

  PlutoSelectCell({
    this.stateManager,
    this.cell,
    this.column,
    this.row,
  });

  @override
  _PlutoSelectCellState createState() => _PlutoSelectCellState();
}

class _PlutoSelectCellState extends State<PlutoSelectCell>
    with MixinPopupCell<PlutoSelectCell> {
  List<PlutoColumn>? popupColumns;

  List<PlutoRow>? popupRows;

  Icon? icon = const Icon(
    Icons.arrow_drop_down,
  );

  late bool enableColumnFilter;

  @override
  void initState() {
    super.initState();

    enableColumnFilter =
        widget.column!.type.select!.enableColumnFilter ?? false;

    final columnFilterHeight = enableColumnFilter
        ? widget.stateManager!.configuration!.columnFilterHeight
        : 0;

    final rowsHeight = widget.column!.type.select!.items!.length *
        widget.stateManager!.rowTotalHeight;

    popupHeight = widget.stateManager!.columnHeight +
        columnFilterHeight +
        rowsHeight +
        PlutoGridSettings.gridInnerSpacing;

    fieldOnSelected = widget.column!.title;

    popupColumns = [
      PlutoColumn(
        title: widget.column!.title,
        field: widget.column!.title,
        readOnly: true,
        type: PlutoColumnType.text(),
        formatter: widget.column!.formatter,
        enableFilterMenuItem: enableColumnFilter,
        enableHideColumnMenuItem: false,
        enableSetColumnsMenuItem: false,
      )
    ];

    popupRows = widget.column!.type.select!.items!.map((dynamic item) {
      return PlutoRow(
        cells: {
          widget.column!.title: PlutoCell(value: item),
        },
      );
    }).toList();
  }

  @override
  void onLoaded(PlutoGridOnLoadedEvent event) {
    super.onLoaded(event);

    if (enableColumnFilter) {
      event.stateManager!.setShowColumnFilter(true, notify: false);
    }

    event.stateManager!.setSelectingMode(PlutoGridSelectingMode.none);
  }
}
