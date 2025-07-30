// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:zego_uikit/src/components/defines.dart';
import 'package:zego_uikit/src/components/internal/internal.dart';
import 'package:zego_uikit/src/components/screen_util/screen_util.dart';

/// more button of menu bar
class ZegoMoreButton extends StatefulWidget {
  const ZegoMoreButton({
    Key? key,
    required this.menuButtonListFunc,
    this.icon,
    this.menuItemSize = const Size(60.0, 60.0),
    this.menuItemCountPerRow = 5,
    this.menuRowHeight = 80.0,
    this.menuBackgroundColor = const Color(0xff262A2D),
    this.iconSize,
    this.buttonSize,
    this.onSheetPopUp,
    this.onSheetPop,
  }) : super(key: key);

  final ButtonIcon? icon;

  /// bottom list of menu
  final List<Widget> Function() menuButtonListFunc;

  /// the number of buttons per row
  final int menuItemCountPerRow;

  final double menuRowHeight;
  final Size menuItemSize;
  final Color menuBackgroundColor;

  /// the size of button's icon
  final Size? iconSize;

  /// the size of button
  final Size? buttonSize;

  final Function(int)? onSheetPopUp;
  final Function(int)? onSheetPop;

  @override
  State<ZegoMoreButton> createState() => _ZegoMoreButtonState();
}

class _ZegoMoreButtonState extends State<ZegoMoreButton> {
  @override
  Widget build(BuildContext context) {
    // Size containerSize = widget.buttonSize ?? Size(96.r, 96.r);
    final sizeBoxSize = widget.iconSize ?? Size(56.zR, 56.zR);

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 96.zR,
        height: 96.zR,
        decoration: BoxDecoration(
          color: widget.icon?.backgroundColor ??
              controlBarButtonCheckedBackgroundColor,
          shape: BoxShape.circle,
        ),
        child: SizedBox.fromSize(
          size: sizeBoxSize,
          child: widget.icon?.icon ??
              UIKitImage.asset(StyleIconUrls.iconS1ControlBarMore),
        ),
      ),
    );
  }

  void onPressed() {
    final key = DateTime.now().millisecondsSinceEpoch;
    widget.onSheetPopUp?.call(key);

    showModalBottomSheet(
      backgroundColor: widget.menuBackgroundColor,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32.0),
          topRight: Radius.circular(32.0),
        ),
      ),
      isDismissible: true,
      builder: (BuildContext context) {
        final menuButtonList = widget.menuButtonListFunc.call();
        var rowCount = 1 + menuButtonList.length ~/ widget.menuItemCountPerRow;
        if (rowCount > 2) {
          /// at most two rows are displayed
          rowCount = 2;
        }
        return AnimatedPadding(
          padding: MediaQuery.of(context).viewInsets,
          duration: const Duration(milliseconds: 50),
          child: SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              height: rowCount * widget.menuRowHeight,
              child: menu(
                context,
                // List.from is for copy list，otherwise will lose items in next build
                splitButtonFromListsToRows(List.from(menuButtonList)),
              ),
            ),
          ),
        );
      },
    ).then((value) {
      widget.onSheetPop?.call(key);
    });
  }

  ///
  Widget menu(BuildContext context, List<List<Widget>> rowButtonList) {
    if (rowButtonList.length > 1) {
      /// in order to align each row of buttons,
      /// if the last row of buttons is not filled,
      /// add some hidden buttons to fill the row
      if (rowButtonList.first.length != rowButtonList.last.length) {
        final lastShortList = rowButtonList.last;
        rowButtonList.removeLast();

        final copyWidget = rowButtonList.first.first;
        final diffCount = rowButtonList.first.length - lastShortList.length;
        for (var i = 0; i < diffCount; i++) {
          /// fill the vacant position
          lastShortList.add(Stack(
            fit: StackFit.passthrough,
            children: [
              copyWidget,
              Container(
                width: widget.menuItemSize.width,
                height: widget.menuItemSize.height,
                color: widget.menuBackgroundColor,
              ),
            ],
          ));
        }
        rowButtonList.add(lastShortList);
      }
    }

    /// scrollable
    return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ...rowButtonList.map(
              (List<Widget> columnButtonList) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: columnButtonList
                    .map((Widget child) => SizedBox(
                          width: widget.menuItemSize.width,
                          height: widget.menuItemSize.height,
                          child: child,
                        ))
                    .toList(),
              ),
            )
          ],
        ));
  }

  /// split all buttons into multiple lines
  List<List<Widget>> splitButtonFromListsToRows(List<Widget> buttonList) {
    final listOfList = <List<Widget>>[];
    while (buttonList.length >= widget.menuItemCountPerRow) {
      listOfList.add(buttonList.sublist(0, widget.menuItemCountPerRow));
      buttonList.removeRange(0, widget.menuItemCountPerRow);
    }
    if (buttonList.isNotEmpty) {
      listOfList.add(buttonList);
    }
    return listOfList;
  }
}
