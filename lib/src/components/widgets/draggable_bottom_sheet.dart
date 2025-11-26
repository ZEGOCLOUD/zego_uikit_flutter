// Dart imports:
import 'dart:ui';

// Flutter imports:
import 'package:flutter/material.dart';

/// Partially visible bottom sheet that can be dragged into the screen. Provides different views for expanded and collapsed states
class ZegoDraggableBottomSheet extends StatefulWidget {
  /// Alignment of the sheet
  final Alignment alignment;

  /// This widget will hide behind the sheet when expanded.
  final Widget? backgroundWidget;

  /// Whether to blur the background while sheet expnasion (true: modal-sheet false: persistent-sheet)
  final bool blurBackground;

  /// Child of expended sheet
  final Widget? expandedChild;

  /// Extent from the min-height to change from previewChild to expandedChild
  final double expansionExtent;

  /// Max-extent for sheet expansion
  final double maxExtent;

  /// Min-extent for the sheet, also the original height of the sheet
  final double minExtent;

  /// Child to be displayed when sheet is not expended
  final Widget? previewChild;

  /// Scroll direction of the sheet
  final Axis scrollDirection;

  const ZegoDraggableBottomSheet({
    super.key,
    this.alignment = Alignment.bottomLeft,
    this.backgroundWidget,
    this.blurBackground = true,
    this.expandedChild,
    this.expansionExtent = 10,
    this.maxExtent = double.infinity,
    this.minExtent = 10,
    this.previewChild,
    this.scrollDirection = Axis.vertical,
  });

  @override
  State<ZegoDraggableBottomSheet> createState() =>
      _ZegoDraggableBottomSheetState();
}

class _ZegoDraggableBottomSheetState extends State<ZegoDraggableBottomSheet> {
  late double currentHeight;
  late double newHeight;

  @override
  void initState() {
    currentHeight = widget.minExtent;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        widget.backgroundWidget ?? const SizedBox(),
        if (currentHeight - widget.minExtent < 10 || !widget.blurBackground)
          const SizedBox()
        else
          Positioned.fill(
              child: GestureDetector(
            onTap: () => setState(() => currentHeight = widget.minExtent),
            child: Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
              ),
            ),
          )),
        Align(
          alignment: widget.alignment,
          child: GestureDetector(
            onVerticalDragUpdate: (details) {
              if (widget.scrollDirection == Axis.horizontal) return;
              newHeight = currentHeight - details.delta.dy;
              if (newHeight > widget.minExtent &&
                  newHeight < widget.maxExtent) {
                setState(() => currentHeight = newHeight);
              }
            },
            onHorizontalDragUpdate: (details) {
              if (widget.scrollDirection == Axis.vertical) return;
              newHeight = currentHeight + details.delta.dx;
              if (newHeight > widget.minExtent &&
                  newHeight < widget.maxExtent) {
                setState(() => currentHeight = newHeight);
              }
            },
            child: SizedBox(
              width: (widget.scrollDirection == Axis.vertical)
                  ? double.infinity
                  : currentHeight,
              height: (widget.scrollDirection == Axis.horizontal)
                  ? double.infinity
                  : currentHeight,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: (widget.scrollDirection == Axis.vertical)
                      ? double.infinity
                      : currentHeight,
                  maxHeight: (widget.scrollDirection == Axis.horizontal)
                      ? double.infinity
                      : currentHeight,
                ),
                child:
                    (currentHeight - widget.minExtent < widget.expansionExtent)
                        ? ((widget.previewChild) ??
                            Container(
                              color: Theme.of(context).primaryColor,
                            ))
                        : ((widget.expandedChild) ??
                            Container(
                              color: Theme.of(context).primaryColor,
                            )),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
/*
// usage: 
ZegoDraggableBottomSheet(
  previewChild: Container(
    padding: const EdgeInsets.all(16),
    decoration: const BoxDecoration(
      color: Colors.pink,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
    ),
    child: Column(
      children: <Widget>[
        Container(
          width: 40,
          height: 6,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        const SizedBox(
          height: 16,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: icons.map((icon) {
            return Container(
              width: 50,
              height: 50,
              margin: const EdgeInsets.only(right: 16),
              child: Icon(
                icon,
                color: Colors.pink,
                size: 40,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
            );
          }).toList(),
        )
      ],
    ),
  ),
  expandedChild: Container(
    padding: const EdgeInsets.all(16),
    decoration: const BoxDecoration(
      color: Colors.pink,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
    ),
    child: Column(
      children: <Widget>[
        const Icon(
          Icons.keyboard_arrow_down,
          size: 30,
          color: Colors.white,
        ),
        const SizedBox(
          height: 8,
        ),
        const SizedBox(
          height: 16,
        ),
        Expanded(
          child: GridView.builder(
            itemCount: icons.length,
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemBuilder: (context, index) => Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icons[index],
                color: Colors.pink,
                size: 40,
              ),
            ),
          ),
        )
      ],
    ),
  ),
  minExtent: 150,
  maxExtent: MediaQuery.of(context).size.height * 0.8,
)
*/
