import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:pluto_grid/pluto_grid.dart';

typedef PlutoOnLoadedEventCallback = void Function(
    PlutoGridOnLoadedEvent event);

typedef PlutoOnChangedEventCallback = void Function(
    PlutoGridOnChangedEvent event);

typedef PlutoOnSelectedEventCallback = void Function(
    PlutoGridOnSelectedEvent event);

typedef PlutoOnRowCheckedEventCallback = void Function(
    PlutoGridOnRowCheckedEvent event);

typedef PlutoOnRowDoubleTapEventCallback = void Function(
    PlutoGridOnRowDoubleTapEvent event);

typedef PlutoOnRowSecondaryTapEventCallback = void Function(
    PlutoGridOnRowSecondaryTapEvent event);

typedef PlutoOnRowsMovedEventCallback = void Function(
    PlutoGridOnRowsMovedEvent event);

typedef CreateHeaderCallBack = Widget Function(
    PlutoGridStateManager stateManager);

typedef CreateFooterCallBack = Widget Function(
    PlutoGridStateManager stateManager);

typedef PlutoRowColorCallback = Color Function(
    PlutoRowColorContext rowColorContext);

class PlutoGrid extends StatefulWidget {
  final List<PlutoColumn>? columns;

  final List<PlutoRow?>? rows;

  final PlutoOnLoadedEventCallback? onLoaded;

  final PlutoOnChangedEventCallback? onChanged;

  final PlutoOnSelectedEventCallback? onSelected;

  final PlutoOnRowCheckedEventCallback? onRowChecked;

  final PlutoOnRowDoubleTapEventCallback? onRowDoubleTap;

  final PlutoOnRowSecondaryTapEventCallback? onRowSecondaryTap;

  final PlutoOnRowsMovedEventCallback? onRowsMoved;

  final CreateHeaderCallBack? createHeader;

  final CreateFooterCallBack? createFooter;

  final PlutoRowColorCallback? rowColorCallback;

  final PlutoGridConfiguration? configuration;

  /// [PlutoGridMode.normal]
  /// Normal grid with cell editing.
  ///
  /// [PlutoGridMode.select]
  /// Editing is not possible, and if you press enter or tap on the list,
  /// you can receive the selected row and cell from the onSelected callback.
  final PlutoGridMode? mode;

  const PlutoGrid({
    Key? key,
    required this.columns,
    required this.rows,
    this.onLoaded,
    this.onChanged,
    this.onSelected,
    this.onRowChecked,
    this.onRowDoubleTap,
    this.onRowSecondaryTap,
    this.onRowsMoved,
    this.createHeader,
    this.createFooter,
    this.rowColorCallback,
    this.configuration,
    this.mode = PlutoGridMode.normal,
  }) : super(key: key);

  @override
  _PlutoGridState createState() => _PlutoGridState();
}

class _PlutoGridState extends State<PlutoGrid> {
  FocusNode? gridFocusNode;

  LinkedScrollControllerGroup verticalScroll = LinkedScrollControllerGroup();

  LinkedScrollControllerGroup horizontalScroll = LinkedScrollControllerGroup();

  late PlutoGridStateManager stateManager;

  PlutoGridKeyManager? keyManager;

  PlutoGridEventManager? eventManager;

  bool? _showFrozenColumn;

  bool? _hasLeftFrozenColumns;

  double? _bodyLeftOffset;

  double? _bodyRightOffset;

  bool? _hasRightFrozenColumns;

  double? _rightFrozenLeftOffset;

  bool? _showColumnFilter;

  bool? _showLoading;

  Widget? _header;

  Widget? _footer;

  List<Function()> disposeList = [];

  @override
  void dispose() {
    disposeList.forEach((dispose) {
      dispose();
    });

    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    initProperties();

    initStateManager();

    initKeyManager();

    initEventManager();

    initOnLoadedEvent();

    initSelectMode();

    initHeaderFooter();
  }

  void initProperties() {
    gridFocusNode = FocusNode();

    // Dispose
    disposeList.add(() {
      gridFocusNode!.dispose();
    });
  }

  void initStateManager() {
    stateManager = PlutoGridStateManager(
      columns: widget.columns,
      rows: widget.rows,
      gridFocusNode: gridFocusNode,
      scroll: PlutoGridScrollController(
        vertical: verticalScroll,
        horizontal: horizontalScroll,
      ),
      mode: widget.mode,
      onChangedEventCallback: widget.onChanged,
      onSelectedEventCallback: widget.onSelected,
      onRowCheckedEventCallback: widget.onRowChecked,
      onRowDoubleTapEventCallback: widget.onRowDoubleTap,
      onRowSecondaryTapEventCallback: widget.onRowSecondaryTap,
      onRowsMovedEventCallback: widget.onRowsMoved,
      createHeader: widget.createHeader,
      createFooter: widget.createFooter,
      configuration: widget.configuration,
    );

    stateManager.addListener(changeStateListener);

    stateManager.setRowColorCallback(widget.rowColorCallback);

    // Dispose
    disposeList.add(() {
      stateManager.removeListener(changeStateListener);
      stateManager.dispose();
    });
  }

  void initKeyManager() {
    keyManager = PlutoGridKeyManager(
      stateManager: stateManager,
    );

    keyManager!.init();

    stateManager.setKeyManager(keyManager);

    // Dispose
    disposeList.add(() {
      keyManager!.dispose();
    });
  }

  void initEventManager() {
    eventManager = PlutoGridEventManager(
      stateManager: stateManager,
    );

    eventManager!.init();

    stateManager.setEventManager(eventManager);

    // Dispose
    disposeList.add(() {
      eventManager!.dispose();
    });
  }

  void initOnLoadedEvent() {
    if (widget.onLoaded == null) {
      return;
    }

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      widget.onLoaded!(PlutoGridOnLoadedEvent(
        stateManager: stateManager,
      ));
    });
  }

  void initSelectMode() {
    if (widget.mode.isSelect != true) {
      return;
    }

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (stateManager.currentCell == null && widget.rows!.isNotEmpty) {
        stateManager.setCurrentCell(
            widget.rows!.first!.cells.entries.first.value, 0);
      }

      stateManager.gridFocusNode!.requestFocus();
    });
  }

  void initHeaderFooter() {
    if (stateManager.showHeader) {
      _header = stateManager.createHeader!(stateManager);
    }

    if (stateManager.showFooter) {
      _footer = stateManager.createFooter!(stateManager);
    }

    if (_header is PlutoPagination || _footer is PlutoPagination) {
      stateManager.setPage(1, notify: false);
    }
  }

  void changeStateListener() {
    if (_showFrozenColumn != stateManager.showFrozenColumn ||
        _hasLeftFrozenColumns != stateManager.hasLeftFrozenColumns ||
        _bodyLeftOffset != stateManager.bodyLeftOffset ||
        _bodyRightOffset != stateManager.bodyRightOffset ||
        _hasRightFrozenColumns != stateManager.hasRightFrozenColumns ||
        _rightFrozenLeftOffset != stateManager.rightFrozenLeftOffset ||
        _showColumnFilter != stateManager.showColumnFilter ||
        _showLoading != stateManager.showLoading) {
      setState(resetState);
    }
  }

  KeyEventResult handleGridFocusOnKey(FocusNode focusNode, RawKeyEvent event) {
    /// 2021-11-19
    /// KeyEventResult.skipRemainingHandlers 동작 오류로 인한 임시 코드
    /// 이슈 해결 후 :
    /// ```dart
    /// keyManager!.subject.add(PlutoKeyManagerEvent(
    ///   focusNode: focusNode,
    ///   event: event,
    /// ));
    /// ```
    if (keyManager!.eventResult.isSkip == false) {
      keyManager!.subject.add(PlutoKeyManagerEvent(
        focusNode: focusNode,
        event: event,
      ));
    }

    /// 2021-11-19
    /// KeyEventResult.skipRemainingHandlers 동작 오류로 인한 임시 코드
    /// 이슈 해결 후 :
    /// ```dart
    /// return KeyEventResult.handled;
    /// ```
    return keyManager!.eventResult.consume(KeyEventResult.handled);
  }

  void setLayout(BoxConstraints size) {
    stateManager.setLayout(size);

    resetState();
  }

  void resetState() {
    _showFrozenColumn = stateManager.showFrozenColumn;

    _hasLeftFrozenColumns = stateManager.hasLeftFrozenColumns;

    _bodyLeftOffset = stateManager.bodyLeftOffset;

    _bodyRightOffset = stateManager.bodyRightOffset;

    _hasRightFrozenColumns = stateManager.hasRightFrozenColumns;

    _rightFrozenLeftOffset = stateManager.rightFrozenLeftOffset;

    _showColumnFilter = stateManager.showColumnFilter;

    _showLoading = stateManager.showLoading;
  }

  @override
  Widget build(BuildContext context) {
    return FocusScope(
      onFocusChange: (hasFocus) {
        stateManager.setKeepFocus(hasFocus);
      },
      onKey: handleGridFocusOnKey,
      child: SafeArea(
        child: LayoutBuilder(
            key: stateManager.gridKey,
            builder: (ctx, size) {
              setLayout(size);

              if (stateManager.keepFocus) {
                FocusScope.of(ctx).requestFocus(gridFocusNode);
              }

              return Focus(
                focusNode: stateManager.gridFocusNode,
                child: ScrollConfiguration(
                  behavior: const PlutoScrollBehavior().copyWith(
                    scrollbars: false,
                  ),
                  child: Container(
                    padding:
                        const EdgeInsets.all(PlutoGridSettings.gridPadding),
                    decoration: BoxDecoration(
                      color: stateManager.configuration!.gridBackgroundColor,
                      borderRadius: widget.mode.isNormal
                          ? stateManager.configuration!.gridBorderRadius
                          : BorderRadius.zero,
                      border: Border.all(
                        color: stateManager.configuration!.gridBorderColor,
                        width: PlutoGridSettings.gridBorderWidth,
                      ),
                    ),
                    child: Stack(
                      children: [
                        if (stateManager.showHeader) ...[
                          Positioned.fill(
                            top: 0,
                            bottom: stateManager.headerBottomOffset,
                            child: _header!,
                          ),
                          Positioned(
                            top: stateManager.headerHeight,
                            left: 0,
                            right: 0,
                            child: PlutoShadowLine(
                              axis: Axis.horizontal,
                              color:
                                  stateManager.configuration!.gridBorderColor,
                              shadow: stateManager
                                  .configuration!.enableGridBorderShadow,
                            ),
                          ),
                        ],
                        if (_showFrozenColumn! && _hasLeftFrozenColumns!) ...[
                          Positioned.fill(
                            top: stateManager.headerHeight,
                            left: 0,
                            child: PlutoLeftFrozenColumns(stateManager),
                          ),
                          Positioned.fill(
                            top: stateManager.rowsTopOffset,
                            left: 0,
                            bottom: stateManager.footerHeight,
                            child: PlutoLeftFrozenRows(stateManager),
                          ),
                        ],
                        Positioned.fill(
                          top: stateManager.headerHeight,
                          left: _bodyLeftOffset,
                          right: _bodyRightOffset,
                          child: PlutoBodyColumns(stateManager),
                        ),
                        Positioned.fill(
                          top: stateManager.rowsTopOffset,
                          left: _bodyLeftOffset,
                          right: _bodyRightOffset,
                          bottom: stateManager.footerHeight,
                          child: PlutoBodyRows(stateManager),
                        ),
                        if (_showFrozenColumn! && _hasRightFrozenColumns!) ...[
                          Positioned.fill(
                            top: stateManager.headerHeight,
                            left: _rightFrozenLeftOffset,
                            child: PlutoRightFrozenColumns(stateManager),
                          ),
                          Positioned.fill(
                            top: stateManager.rowsTopOffset,
                            left: _rightFrozenLeftOffset,
                            bottom: stateManager.footerHeight,
                            child: PlutoRightFrozenRows(stateManager),
                          ),
                        ],
                        if (_showFrozenColumn! && _hasLeftFrozenColumns!)
                          Positioned(
                            top: stateManager.headerHeight,
                            left: _bodyLeftOffset! - 1,
                            bottom: stateManager.footerHeight,
                            child: PlutoShadowLine(
                              axis: Axis.vertical,
                              color:
                                  stateManager.configuration!.gridBorderColor,
                              shadow: stateManager
                                  .configuration!.enableGridBorderShadow,
                            ),
                          ),
                        if (_showFrozenColumn! && _hasRightFrozenColumns!)
                          Positioned(
                            top: stateManager.headerHeight,
                            left: _rightFrozenLeftOffset! - 1,
                            bottom: stateManager.footerHeight,
                            child: PlutoShadowLine(
                              axis: Axis.vertical,
                              reverse: true,
                              color:
                                  stateManager.configuration!.gridBorderColor,
                              shadow: stateManager
                                  .configuration!.enableGridBorderShadow,
                            ),
                          ),
                        Positioned(
                          top: stateManager.rowsTopOffset - 1,
                          left: 0,
                          right: 0,
                          child: PlutoShadowLine(
                            axis: Axis.horizontal,
                            color: stateManager.configuration!.gridBorderColor,
                            shadow: stateManager
                                .configuration!.enableGridBorderShadow,
                          ),
                        ),
                        if (stateManager.showFooter) ...[
                          Positioned(
                            top: stateManager.footerTopOffset,
                            left: 0,
                            right: 0,
                            child: PlutoShadowLine(
                              axis: Axis.horizontal,
                              reverse: true,
                              color:
                                  stateManager.configuration!.gridBorderColor,
                              shadow: stateManager
                                  .configuration!.enableGridBorderShadow,
                            ),
                          ),
                          Positioned.fill(
                            top: stateManager.footerTopOffset,
                            bottom: 0,
                            child: _footer!,
                          ),
                        ],
                        if (_showColumnFilter!)
                          Positioned(
                            top: stateManager.headerHeight +
                                stateManager.columnHeight,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 1,
                              decoration: BoxDecoration(
                                color:
                                    stateManager.configuration!.gridBorderColor,
                              ),
                            ),
                          ),
                        if (stateManager.showLoading)
                          Positioned.fill(
                            child: PlutoLoading(
                              backgroundColor: stateManager
                                  .configuration!.gridBackgroundColor,
                              indicatorColor: stateManager
                                  .configuration!.cellTextStyle.color,
                              indicatorText: stateManager
                                  .configuration!.localeText.loadingText,
                              indicatorSize: stateManager
                                  .configuration!.cellTextStyle.fontSize,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
      ),
    );
  }
}

class PlutoGridOnLoadedEvent {
  final PlutoGridStateManager? stateManager;

  PlutoGridOnLoadedEvent({
    this.stateManager,
  });
}

/// Caution
///
/// [columnIdx] and [rowIdx] are values in the currently displayed state.
class PlutoGridOnChangedEvent {
  final int? columnIdx;
  final PlutoColumn? column;
  final int? rowIdx;
  final PlutoRow? row;
  final dynamic value;
  final dynamic oldValue;

  PlutoGridOnChangedEvent({
    this.columnIdx,
    this.column,
    this.rowIdx,
    this.row,
    this.value,
    this.oldValue,
  });

  @override
  String toString() {
    String out = '[PlutoOnChangedEvent] ';
    out += 'ColumnIndex : $columnIdx, RowIndex : $rowIdx\n';
    out += '::: oldValue : $oldValue\n';
    out += '::: newValue : $value';
    return out;
  }
}

class PlutoGridOnSelectedEvent {
  final PlutoRow? row;
  final PlutoCell? cell;

  PlutoGridOnSelectedEvent({
    this.row,
    this.cell,
  });
}

abstract class PlutoGridOnRowCheckedEvent {
  bool get isAll => runtimeType == PlutoGridOnRowCheckedAllEvent;
  bool get isRow => runtimeType == PlutoGridOnRowCheckedOneEvent;

  final PlutoRow? row;
  final bool? isChecked;

  PlutoGridOnRowCheckedEvent({
    this.row,
    this.isChecked,
  });
}

class PlutoGridOnRowDoubleTapEvent {
  final PlutoRow? row;
  final PlutoCell? cell;

  PlutoGridOnRowDoubleTapEvent({
    this.row,
    this.cell,
  });
}

class PlutoGridOnRowSecondaryTapEvent {
  final PlutoRow? row;
  final PlutoCell? cell;
  final Offset? offset;

  PlutoGridOnRowSecondaryTapEvent({
    this.row,
    this.cell,
    this.offset,
  });
}

class PlutoGridOnRowsMovedEvent {
  final int? idx;
  final List<PlutoRow?>? rows;

  PlutoGridOnRowsMovedEvent({
    required this.idx,
    required this.rows,
  });
}

class PlutoGridOnRowCheckedOneEvent extends PlutoGridOnRowCheckedEvent {
  PlutoGridOnRowCheckedOneEvent({
    PlutoRow? row,
    bool? isChecked,
  }) : super(row: row, isChecked: isChecked);
}

class PlutoGridOnRowCheckedAllEvent extends PlutoGridOnRowCheckedEvent {
  PlutoGridOnRowCheckedAllEvent({
    bool? isChecked,
  }) : super(row: null, isChecked: isChecked);
}

class PlutoGridSettings {
  /// If there is a frozen column, the minimum width of the body
  /// (if it is less than the value, the frozen column is released)
  static const double bodyMinWidth = 200.0;

  /// Default column width
  static const double columnWidth = 200.0;

  /// Column width
  static const double minColumnWidth = 80.0;

  /// Frozen column division line (ShadowLine) size
  static const double shadowLineSize = 3.0;

  /// Sum of frozen column division line width
  static const double totalShadowLineWidth =
      PlutoGridSettings.shadowLineSize * 2;

  /// Grid - padding
  static const double gridPadding = 2.0;

  /// Grid - border width
  static const double gridBorderWidth = 1.0;

  static const double gridInnerSpacing =
      (gridPadding * 2) + (gridBorderWidth * 2);

  /// Row - Default row height
  static const double rowHeight = 45.0;

  /// Row - border width
  static const double rowBorderWidth = 1.0;

  /// Row - total height
  static const double rowTotalHeight = rowHeight + rowBorderWidth;

  /// Cell - padding
  static const double cellPadding = 10;

  /// Cell - fontSize
  static const double cellFontSize = 14;

  /// Scroll when multi-selection is as close as that value from the edge
  static const double offsetScrollingFromEdge = 10.0;

  /// Size that scrolls from the edge at once when selecting multiple
  static const double offsetScrollingFromEdgeAtOnce = 200.0;

  static const int debounceMillisecondsForColumnFilter = 300;
}

class PlutoScrollBehavior extends MaterialScrollBehavior {
  const PlutoScrollBehavior() : super();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

class PlutoRowColorContext {
  final PlutoRow row;

  final int rowIdx;

  final PlutoGridStateManager stateManager;

  PlutoRowColorContext({
    required this.row,
    required this.rowIdx,
    required this.stateManager,
  });
}

enum PlutoGridMode {
  normal,
  select,
  selectWithOneTap,
  popup,
}

extension PlutoGridModeExtension on PlutoGridMode? {
  bool get isNormal => this == PlutoGridMode.normal;

  bool get isSelect =>
      this == PlutoGridMode.select || this == PlutoGridMode.selectWithOneTap;

  bool get isSelectModeWithOneTap => this == PlutoGridMode.selectWithOneTap;

  bool get isPopup => this == PlutoGridMode.popup;
}
