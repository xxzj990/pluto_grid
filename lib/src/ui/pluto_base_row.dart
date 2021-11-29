import 'package:flutter/material.dart';
import 'package:hovering/hovering.dart';
import 'package:pluto_grid/pluto_grid.dart';

class PlutoBaseRow extends StatelessWidget {
  final PlutoGridStateManager? stateManager;
  final int? rowIdx;
  final PlutoRow? row;
  final List<PlutoColumn>? columns;

  PlutoBaseRow({
    Key? key,
    this.stateManager,
    this.rowIdx,
    this.row,
    this.columns,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _RowContainerWidget(
      stateManager: stateManager!,
      rowIdx: rowIdx,
      row: row,
      columns: columns,
      child: Row(
        children: columns!.map((column) {
          return PlutoBaseCell(
            key: row!.cells[column.field]!.key,
            stateManager: stateManager!,
            cell: row!.cells[column.field],
            width: column.width,
            height: stateManager!.rowHeight,
            column: column,
            rowIdx: rowIdx,
          );
        }).toList(growable: false),
      ),
    );
  }
}

class _RowContainerWidget extends PlutoStatefulWidget {
  final PlutoGridStateManager stateManager;
  final int? rowIdx;
  final PlutoRow? row;
  final List<PlutoColumn>? columns;
  final Widget? child;

  _RowContainerWidget({
    required this.stateManager,
    this.rowIdx,
    this.row,
    this.columns,
    this.child,
  });

  @override
  __RowContainerWidgetState createState() => __RowContainerWidgetState();
}

abstract class __RowContainerWidgetStateWithChangeKeepAlive extends PlutoStateWithChangeKeepAlive<_RowContainerWidget> {
  bool? isCurrentRow;

  bool? isSelectedRow;

  bool? isSelecting;

  bool? isCheckedRow;

  bool? isDragTarget;

  bool? isTopDragTarget;

  bool? isBottomDragTarget;

  bool? hasCurrentSelectingPosition;

  bool? hasFocus;

  @override
  void onChange() {
    resetState((update) {
      isCurrentRow = update<bool?>(
        isCurrentRow,
        widget.stateManager.currentRowIdx == widget.rowIdx,
      );

      isSelectedRow = update<bool?>(
        isSelectedRow,
        widget.stateManager.isSelectedRow(widget.row!.key),
      );

      isSelecting = update<bool?>(isSelecting, widget.stateManager.isSelecting);

      isCheckedRow = update<bool?>(isCheckedRow, widget.row!.checked);

      isDragTarget = update<bool?>(
        isDragTarget,
        widget.stateManager.isRowIdxDragTarget(widget.rowIdx),
      );

      isTopDragTarget = update<bool?>(
        isTopDragTarget,
        widget.stateManager.isRowIdxTopDragTarget(widget.rowIdx),
      );

      isBottomDragTarget = update<bool?>(
        isBottomDragTarget,
        widget.stateManager.isRowIdxBottomDragTarget(widget.rowIdx),
      );

      hasCurrentSelectingPosition = update<bool?>(
        hasCurrentSelectingPosition,
        widget.stateManager.hasCurrentSelectingPosition,
      );

      hasFocus = update<bool?>(
        hasFocus,
        isCurrentRow! && widget.stateManager.hasFocus,
      );

      if (widget.stateManager.mode.isNormal) {
        setKeepAlive(widget.stateManager.isRowBeingDragged(widget.row!.key));
      }
    });
  }
}

class __RowContainerWidgetState extends __RowContainerWidgetStateWithChangeKeepAlive {
  Color getDefaultRowColor() {
    if (widget.stateManager.rowColorCallback == null) {
      return Colors.transparent;
    }

    return widget.stateManager.rowColorCallback!(
      PlutoRowColorContext(
        rowIdx: widget.rowIdx!,
        row: widget.row!,
        stateManager: widget.stateManager,
      ),
    );
  }

  Color rowColor() {
    final Color defaultColor = getDefaultRowColor();

    if (isDragTarget!) return widget.stateManager.configuration!.checkedColor;

    final bool checkCurrentRow = isCurrentRow! && (!isSelecting! && !hasCurrentSelectingPosition!);

    final bool checkSelectedRow = widget.stateManager.isSelectedRow(widget.row!.key);

    if (!checkCurrentRow && !checkSelectedRow) {
      return defaultColor;
    }

    if (widget.stateManager.selectingMode.isRow) {
      return checkSelectedRow ? widget.stateManager.configuration!.activatedColor : defaultColor;
    }

    if (!hasFocus!) {
      return defaultColor;
    }

    return checkCurrentRow ? widget.stateManager.configuration!.activatedColor : defaultColor;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final Color _rowColor = rowColor();

    return Container(
      decoration: BoxDecoration(
        color: isCheckedRow! ? Color.alphaBlend(const Color(0x11757575), _rowColor) : _rowColor,
      ),
      child: HoverContainer(
        color: Colors.transparent,
        hoverColor: widget.stateManager.configuration!.hoverColor,
        child: Column(
          children: [
            isDragTarget! && isTopDragTarget!
                ? Container(
                    height: PlutoGridSettings.rowBorderWidth,
                    color: widget.stateManager.configuration!.activatedBorderColor,
                  )
                : Container(),
            widget.child!,
            Container(
              height: PlutoGridSettings.rowBorderWidth,
              color: isDragTarget! && isBottomDragTarget! ? widget.stateManager.configuration!.activatedBorderColor : widget.stateManager.configuration!.borderColor,
            ),
          ],
        ),
      ),
    );
  }
}
