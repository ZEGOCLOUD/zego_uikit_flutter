// Dart imports:
import 'dart:math' as math;

// Flutter imports:
import 'package:flutter/cupertino.dart';

/// A delegate class for a grid layout with two layout modes: auto fill mode and sized mode.
class GridLayoutDelegate extends MultiChildLayoutDelegate {
  /// List of sized items
  List<GridLayoutSizedItem> sizedItems = [];

  /// List of auto fill items (should be initialized in time)
  List<LayoutId> autoFillItems = [];

  /// The number of columns in the grid layout.
  int columnCount;

  /// The padding around the entire layout.
  final EdgeInsetsGeometry layoutPadding;

  /// The padding around each item in the layout.
  final Size itemPadding;

  /// The alignment of the last row in the layout.
  final GridLayoutAlignment lastRowAlignment;

  /// Positions of items
  List<Offset> itemsPosition = [];

  /// Auto fill mode:
  ///
  /// In this mode, all items will auto fill the available space, and the layout will have the SAME height as the screen.
  /// Make sure to wrap CustomMultiChildLayout with a Container with a specific height.
  ///
  /// |I|
  ///  or
  /// |I I|
  /// |I I|
  ///  or
  /// |I I I|
  /// |I I I|
  /// |I I  |
  ///
  /// example:
  ///
  ///  final items = List.generate(5, (index) {
  ///    return LayoutId(
  ///      id: index,
  ///      child: Container(color: Colors.red[100 * (index % 8 + 1)]),
  ///    );
  ///  });
  ///
  ///  return SingleChildScrollView(
  ///    child: SizedBox(
  ///      //  you must wrap CustomMultiChildLayout with Container with height
  ///      height: MediaQuery.of(context).size.height,
  ///      child: CustomMultiChildLayout(
  ///        delegate: GridLayoutDelegate.autoFill(
  ///          normalItems: items,
  ///          columnCount: 3,
  ///          lastRowAlignment: GridLayoutAlignment.center,
  ///        ),
  ///      children: items,
  ///      ),
  ///    ),
  ///  );
  GridLayoutDelegate.autoFill({
    required this.autoFillItems,
    required this.columnCount,
    this.layoutPadding = const EdgeInsets.all(2.0),
    this.itemPadding = const Size(2.0, 2.0),
    this.lastRowAlignment = GridLayoutAlignment.start,
  }) : assert(columnCount > 0) {
    if (autoFillItems.length < columnCount) {
      columnCount = autoFillItems.length;
    }
  }

  /// Sized mode:
  ///
  /// In this mode, all items will be laid out according to the specified width and height, and may exceed the screen height.
  ///
  ///  I I I
  ///  I I I
  /// |I I I|
  /// |I I I|
  /// |I I I|
  ///  I I I
  ///  I I I
  ///
  /// example:
  ///
  ///  var columnCount = 3;
  ///  var screenSize = MediaQuery.of(context).size;
  ///
  ///  final items = List.generate(20, (index) {
  ///    var width = screenSize.width / columnCount - 2.0;
  ///    var height = 120.0;
  ///    return GridLayoutSizedItem(
  ///      width: width,
  ///      height: height,
  ///      id: index,
  ///      child: Container(
  ///        width: width,
  ///        height: height,
  ///        color: Colors.red[100 * (index % 8 + 1)],
  ///      ),
  ///    );
  ///  });
  ///
  ///  return SingleChildScrollView(
  ///    child: CustomMultiChildLayout(
  ///      delegate: GridLayoutDelegate.sized(
  ///        sizedItems: items,
  ///        columnCount: columnCount,
  ///        lastRowAlignment: GridLayoutAlignment.center,
  ///      ),
  ///      children: items,
  ///    ),
  ///  );
  GridLayoutDelegate.sized({
    required this.sizedItems,
    required this.columnCount,
    this.layoutPadding = const EdgeInsets.all(2.0),
    this.itemPadding = const Size(2.0, 2.0),
    this.lastRowAlignment = GridLayoutAlignment.start,
  }) : assert(columnCount > 0);

  @override
  Size getSize(BoxConstraints constraints) {
    final height = _initItemsPosition(constraints);
    return Size(constraints.maxWidth, height);
  }

  @override
  void performLayout(Size size) {
    for (var itemIndex = 0; itemIndex < sizedItems.length;) {
      final item = sizedItems.elementAt(itemIndex);
      final itemPos = itemsPosition.elementAt(itemIndex);
      layoutChild(item.id, BoxConstraints.tight(Size(item.width, item.height)));
      positionChild(item.id, itemPos);

      itemIndex++;
    }
  }

  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) {
    return true;
  }

  /// return layout height
  double _initItemsPosition(BoxConstraints constraints) {
    convertSizedItemByAutoFill(constraints);

    itemsPosition.clear();
    var dx = layoutPadding.horizontal / 2.0;
    var dy = layoutPadding.vertical / 2.0;
    var currentRowMaxItemHeight = 0.0;
    for (var itemIndex = 0; itemIndex < sizedItems.length;) {
      for (var columnIndex = 0; columnIndex < columnCount; columnIndex++) {
        final item = sizedItems.elementAt(itemIndex);

        itemsPosition.add(Offset(dx, dy));

        dx += item.width + itemPadding.width;
        currentRowMaxItemHeight =
            math.max(currentRowMaxItemHeight, item.height);

        itemIndex++;
        if (itemIndex == sizedItems.length) {
          break;
        }
      }

      final leftItemCount = sizedItems.length - itemIndex;
      if (leftItemCount < columnCount) {
        //  last row
        var itemsWidth = 0.0;
        sizedItems
            .getRange(itemIndex, sizedItems.length)
            .map((e) => e.width)
            .toList()
            .forEach((double itemWidth) {
          itemsWidth += itemWidth;
        });
        itemsWidth = leftItemCount * itemPadding.width + itemsWidth;
        switch (lastRowAlignment) {
          case GridLayoutAlignment.start:
            dx = layoutPadding.horizontal / 2.0;
            break;
          case GridLayoutAlignment.center:
            dx = (constraints.maxWidth - itemsWidth) / 2.0;
            break;
          case GridLayoutAlignment.end:
            dx = constraints.maxWidth - itemsWidth;
            break;
        }
      } else {
        //  new row
        dx = layoutPadding.horizontal / 2.0;
      }
      dy += currentRowMaxItemHeight + itemPadding.height;
    }

    return dy;
  }

  void convertSizedItemByAutoFill(BoxConstraints constraints) {
    if (autoFillItems.isEmpty) {
      return;
    }

    final itemWidth = (constraints.maxWidth -
            (columnCount - 1) * itemPadding.width -
            layoutPadding.horizontal) /
        columnCount;
    final rowCount = (autoFillItems.length / columnCount).ceil();
    final itemHeight = (constraints.maxHeight -
            (rowCount - 1) * itemPadding.height -
            layoutPadding.vertical) /
        rowCount;

    sizedItems.clear();
    for (final item in autoFillItems) {
      sizedItems.add(
        GridLayoutSizedItem(
          id: item.id,
          width: itemWidth,
          height: itemHeight,
          child: item.child,
        ),
      );
    }
  }
}

class GridLayoutSizedItem extends LayoutId {
  final double width;
  final double height;

  GridLayoutSizedItem({
    super.key,
    required super.id,
    required super.child,
    required this.width,
    required this.height,
  })  : assert(width > 0),
        assert(height > 0);
}

enum GridLayoutAlignment {
  /// I I I I
  /// I I I I
  /// I I
  start,

  /// I I I I
  /// I I I I
  ///   I I
  center,

  /// I I I I
  /// I I I I
  ///     I I
  end,
}
