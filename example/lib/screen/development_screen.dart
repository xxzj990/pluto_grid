import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../dummy_data/development.dart';
import 'empty_screen.dart';
import 'home_screen.dart';

class DevelopmentScreen extends StatefulWidget {
  static const routeName = 'development';

  @override
  _DevelopmentScreenState createState() => _DevelopmentScreenState();
}

class _DevelopmentScreenState extends State<DevelopmentScreen> {
  List<PlutoColumn>? columns;

  List<PlutoRow>? rows;

  List<PlutoColumnGroup>? columnGroups;

  PlutoGridStateManager? stateManager;

  PlutoGridSelectingMode? gridSelectingMode = PlutoGridSelectingMode.cell;

  @override
  void initState() {
    super.initState();

    columns = [
      PlutoColumn(
        title: 'column1',
        field: 'column1',
        type: PlutoColumnType.text(),
        enableRowDrag: true,
        enableRowChecked: true,
        enableContextMenu: false,
        enableDropToResize: true,
        enableAutoEditing: true,
        titleTextAlign: PlutoColumnTextAlign.right,
        titleSpan: const TextSpan(
          children: [
            WidgetSpan(
              child: Text(
                '* ',
                style: TextStyle(color: Colors.red),
              ),
              alignment: PlaceholderAlignment.bottom,
            ),
            TextSpan(text: 'column1'),
          ],
        ),
        width: 250,
        minWidth: 175,
        renderer: (rendererContext) {
          return Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.add_circle,
                ),
                onPressed: () {
                  rendererContext.stateManager!.insertRows(
                    rendererContext.rowIdx!,
                    rendererContext.stateManager!.getNewRows(count: 1),
                  );
                },
                iconSize: 18,
                color: Colors.green,
                padding: const EdgeInsets.all(0),
              ),
              IconButton(
                icon: const Icon(
                  Icons.remove_circle_outlined,
                ),
                onPressed: () {
                  rendererContext.stateManager!
                      .removeRows([rendererContext.row]);
                },
                iconSize: 18,
                color: Colors.red,
                padding: const EdgeInsets.all(0),
              ),
              Expanded(
                child: Text(
                  '${rendererContext.row!.sortIdx.toString()}(${rendererContext.row!.cells[rendererContext.column!.field]!.value.toString()})',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );
        },
      ),
      PlutoColumn(
        title: 'column2',
        field: 'column2',
        enableContextMenu: false,
        textAlign: PlutoColumnTextAlign.right,
        titleTextAlign: PlutoColumnTextAlign.right,
        type: PlutoColumnType.select(
          <String>['red', 'blue', 'green'],
          enableColumnFilter: true,
        ),
        renderer: (rendererContext) {
          Color textColor = Colors.black;

          if (rendererContext.cell!.value == 'red') {
            textColor = Colors.red;
          } else if (rendererContext.cell!.value == 'blue') {
            textColor = Colors.blue;
          } else if (rendererContext.cell!.value == 'green') {
            textColor = Colors.green;
          }

          return Text(
            rendererContext.cell!.value.toString(),
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
            textAlign: rendererContext.column!.textAlign.value,
          );
        },
      ),
      PlutoColumn(
        title: 'column3',
        field: 'column3',
        textAlign: PlutoColumnTextAlign.left,
        titleTextAlign: PlutoColumnTextAlign.center,
        enableAutoEditing: true,
        type: PlutoColumnType.date(),
      ),
      PlutoColumn(
        title: 'column4',
        field: 'column4',
        textAlign: PlutoColumnTextAlign.center,
        titleTextAlign: PlutoColumnTextAlign.right,
        type: PlutoColumnType.time(),
      ),
      PlutoColumn(
        title: 'column5',
        field: 'column5',
        textAlign: PlutoColumnTextAlign.center,
        titleTextAlign: PlutoColumnTextAlign.left,
        type: PlutoColumnType.number(
          negative: true,
        ),
      ),
      PlutoColumn(
        title: 'column6',
        field: 'column6',
        type: PlutoColumnType.text(),
        enableFilterMenuItem: false,
        enableEditingMode: false,
        renderer: (rendererContext) {
          return Image.asset(
            'assets/images/cat.jpg',
            fit: BoxFit.fitWidth,
          );
        },
      ),
      PlutoColumn(
        title: 'column7',
        field: 'column7',
        type: PlutoColumnType.number(),
        enableFilterMenuItem: false,
        enableEditingMode: false,
        // NEW Custom cellPadding
        cellPadding: 0,
        width: 80,
        renderer: (rendererContext) {
          return Container(
            color: rendererContext.cell!.value % 2 == 0
                ? Colors.yellow
                : Colors.teal,
          );
        },
      ),
    ];

    columnGroups = [
      PlutoColumnGroup(
        title: 'Group A',
        fields: ['column1', 'column2', 'column3'],
      ),
      PlutoColumnGroup(
        title: 'Group B',
        fields: ['column4', 'column5', 'column6'],
      ),
      PlutoColumnGroup(
        title: 'Group C',
        fields: ['column7'],
      ),
    ];

    rows = DummyData.rowsByColumns(length: 100, columns: columns);
  }

  void handleAddRowButton({int? count}) {
    final List<PlutoRow> rows = count == null
        ? [DummyData.rowByColumns(columns!)]
        : DummyData.rowsByColumns(length: count, columns: columns);

    stateManager!.prependRows(rows);
  }

  void handleRemoveCurrentRowButton() {
    stateManager!.removeCurrentRow();
  }

  void handleRemoveSelectedRowsButton() {
    stateManager!.removeRows(stateManager!.currentSelectingRows);
  }

  void handleToggleColumnFilter() {
    stateManager!.setShowColumnFilter(!stateManager!.showColumnFilter);
  }

  void handleOnRowChecked(PlutoGridOnRowCheckedEvent event) {
    if (event.isRow) {
      print('Toggled A Row.');
      print(event.row?.cells['column1']?.value);
    } else {
      print('Toggled All Rows.');
      print(stateManager?.checkedRows.length);
    }
  }

  void setGridSelectingMode(PlutoGridSelectingMode? mode) {
    if (gridSelectingMode == mode) {
      return;
    }

    setState(() {
      gridSelectingMode = mode;
      stateManager!.setSelectingMode(mode!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(15),
        child: PlutoGrid(
          columns: columns,
          rows: rows,
          columnGroups: columnGroups,
          // mode: PlutoGridMode.selectWithOneTap,
          onChanged: (PlutoGridOnChangedEvent event) {
            print(event);
          },
          onLoaded: (PlutoGridOnLoadedEvent event) {
            stateManager = event.stateManager;

            stateManager!.setShowColumnFilter(true, notify: false);

            // stateManager!.setAutoEditing(true, notify: false);

            stateManager!.setSelectingMode(gridSelectingMode!);
          },
          // onSelected: (event) {
          //   print(event.cell!.value);
          // },
          onRowChecked: handleOnRowChecked,
          onRowsMoved: (event) {
            print(event.idx);
            print(event.rows);
          },
          // onRowDoubleTap: (e) {
          //   print('Double click A Row.');
          //   print(e.row?.cells['column1']?.value);
          // },
          // onRowSecondaryTap: (e) {
          //   print('Secondary click A Row.(${e.offset})');
          //   print(e.row?.cells['column1']?.value);
          // },
          createHeader: (PlutoGridStateManager stateManager) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                height: stateManager.headerHeight,
                child: Wrap(
                  spacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    ElevatedButton(
                      child: const Text('Go Home'),
                      onPressed: () {
                        Navigator.pushNamed(context, HomeScreen.routeName);
                      },
                    ),
                    ElevatedButton(
                      child: const Text('Go Empty'),
                      onPressed: () {
                        Navigator.pushNamed(context, EmptyScreen.routeName);
                      },
                    ),
                    ElevatedButton(
                      child: const Text('Add 10'),
                      onPressed: () {
                        handleAddRowButton(count: 10);
                      },
                    ),
                    ElevatedButton(
                      child: const Text('Add 100 Rows'),
                      onPressed: () => handleAddRowButton(count: 100),
                    ),
                    ElevatedButton(
                      child: const Text('Add 100,000 Rows'),
                      onPressed: () => handleAddRowButton(count: 100000),
                    ),
                    ElevatedButton(
                      child: const Text('Remove Current Row'),
                      onPressed: handleRemoveCurrentRowButton,
                    ),
                    ElevatedButton(
                      child: const Text('Remove Selected Rows'),
                      onPressed: handleRemoveSelectedRowsButton,
                    ),
                    DropdownButtonHideUnderline(
                      child: DropdownButton(
                        value: gridSelectingMode,
                        items: PlutoGridStateManager.selectingModes
                            .map<DropdownMenuItem<PlutoGridSelectingMode>>(
                                (PlutoGridSelectingMode item) {
                          final color =
                              gridSelectingMode == item ? Colors.blue : null;

                          return DropdownMenuItem<PlutoGridSelectingMode>(
                            value: item,
                            child: Text(
                              item.toShortString(),
                              style: TextStyle(color: color),
                            ),
                          );
                        }).toList(),
                        onChanged: (PlutoGridSelectingMode? mode) {
                          setGridSelectingMode(mode);
                        },
                      ),
                    ),
                    ElevatedButton(
                      child: const Text('Toggle filter'),
                      onPressed: handleToggleColumnFilter,
                    ),
                  ],
                ),
              ),
            );
          },
          createFooter: (stateManager) {
            stateManager.setPageSize(10, notify: false);
            return PlutoPagination(stateManager);
          },
          rowColorCallback: (rowColorContext) {
            return rowColorContext.row.cells['column2']!.value == 'red'
                ? const Color(0xFFFFB0B0)
                : Colors.transparent;
          },
          configuration: PlutoGridConfiguration(
            // columnHeight: 30.0,
            // columnFilterHeight: 30.0,
            // rowHeight: 30.0,
            // defaultCellPadding: 15,
            // defaultColumnTitlePadding: 15,
            // iconSize: 15,
            enableColumnBorder: true,
            // enableGridBorderShadow: true,
            enableMoveHorizontalInEditing: true,
            gridBorderRadius: BorderRadius.circular(10),
            gridPopupBorderRadius: BorderRadius.circular(7),
            scrollbarConfig: const PlutoGridScrollbarConfig(
              isAlwaysShown: false,
              scrollbarThickness: 8,
              scrollbarThicknessWhileDragging: 10,
            ),
            // localeText: const PlutoGridLocaleText.korean(),
            // columnFilterConfig: PlutoGridColumnFilterConfig(
            //   filters: const [
            //     ...FilterHelper.defaultFilters,
            //     ClassYouImplemented(),
            //   ],
            //   resolveDefaultColumnFilter: (column, resolver) {
            //     if (column.field == 'column3') {
            //       return resolver<PlutoFilterTypeGreaterThan>()
            //           as PlutoFilterType;
            //     }
            //
            //     return resolver<PlutoFilterTypeContains>() as PlutoFilterType;
            //   },
            // ),
          ),
        ),
      ),
    );
  }
}

class ClassYouImplemented implements PlutoFilterType {
  String get title => 'Custom contains';

  get compare => ({
        required String? base,
        required String? search,
        required PlutoColumn? column,
      }) {
        var keys = search!.split(',');

        return keys.contains(base);
      };

  const ClassYouImplemented();
}
