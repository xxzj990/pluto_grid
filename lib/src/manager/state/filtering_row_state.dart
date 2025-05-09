import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

abstract class IFilteringRowState {
  List<PlutoRow?> get filterRows;

  bool get hasFilter;

  void setFilter(FilteredListFilter<PlutoRow?>? filter, {bool notify = true});

  void setFilterWithFilterRows(List<PlutoRow?> rows, {bool notify = true});

  void setFilterRows(List<PlutoRow> rows);

  List<PlutoRow?> filterRowsByField(String columnField);

  bool isFilteredColumn(PlutoColumn column);

  void showFilterPopup(
    BuildContext context, {
    PlutoColumn? calledColumn,
  });
}

mixin FilteringRowState implements IPlutoGridState {
  List<PlutoRow?> get filterRows => _filterRows;

  List<PlutoRow?> _filterRows = [];

  bool get hasFilter => refRows!.hasFilter;

  void setFilter(FilteredListFilter<PlutoRow?>? filter, {bool notify = true}) {
    for (var row in refRows!.originalList) {
      row!.setState(PlutoRowState.none);
    }

    var _filter = filter;

    if (filter == null) {
      setFilterRows([]);
    } else {
      _filter = (PlutoRow? row) {
        return !row!.state.isNone || filter(row);
      };
    }

    refRows!.setFilter(_filter);

    resetCurrentState(notify: false);

    if (notify) {
      notifyListeners();
    }
  }

  void setFilterWithFilterRows(List<PlutoRow?> rows, {bool notify = true}) {
    setFilterRows(rows);

    var enabledFilterColumnFields =
        refColumns!.where((element) => element.enableFilterMenuItem).toList();

    setFilter(
      FilterHelper.convertRowsToFilter(_filterRows, enabledFilterColumnFields),
      notify: isPaginated ? false : notify,
    );

    if (isPaginated) {
      resetPage();
    }
  }

  void setFilterRows(List<PlutoRow?> rows) {
    _filterRows = rows
        .where(
          (element) => element!.cells[FilterHelper.filterFieldValue]!.value
              .toString()
              .isNotEmpty,
        )
        .toList();
  }

  List<PlutoRow?> filterRowsByField(String columnField) {
    return _filterRows
        .where(
          (element) =>
              element!.cells[FilterHelper.filterFieldColumn]!.value ==
              columnField,
        )
        .toList();
  }

  bool isFilteredColumn(PlutoColumn? column) {
    return hasFilter &&
        _filterRows.isNotEmpty &&
        FilterHelper.isFilteredColumn(column!, _filterRows);
  }

  void showFilterPopup(
    BuildContext context, {
    PlutoColumn? calledColumn,
  }) {
    var shouldProvideDefaultFilterRow =
        _filterRows.isEmpty && calledColumn != null;

    var rows = shouldProvideDefaultFilterRow
        ? [
            FilterHelper.createFilterRow(
              columnField: calledColumn!.field,
              filterType: calledColumn.defaultFilter,
            ),
          ]
        : _filterRows;

    FilterHelper.filterPopup(
      FilterPopupState(
        context: context,
        configuration: configuration!,
        handleAddNewFilter: (filterState) {
          filterState!.appendRows([FilterHelper.createFilterRow()]);
        },
        handleApplyFilter: (filterState) {
          setFilterWithFilterRows(filterState!.rows);
        },
        columns: columns,
        filterRows: rows,
        focusFirstFilterValue: shouldProvideDefaultFilterRow,
      ),
    );
  }
}
