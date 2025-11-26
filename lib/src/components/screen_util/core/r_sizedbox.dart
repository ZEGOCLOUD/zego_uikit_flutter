// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

// Project imports:
import 'package:zego_uikit/src/components/screen_util/core/size_extension.dart';

/// @nodoc
class ZegoRSizedBox extends SizedBox {
  const ZegoRSizedBox({
    super.key,
    super.height,
    super.width,
    super.child,
  }) : _square = false;

  const ZegoRSizedBox.zVertical(
    double? height, {
    super.key,
    super.child,
  })  : _square = false,
        super(height: height);

  const ZegoRSizedBox.zHorizontal(
    double? width, {
    super.key,
    super.child,
  })  : _square = false,
        super(width: width);

  const ZegoRSizedBox.zSquare({
    super.key,
    double? height,
    super.dimension,
    super.child,
  })  : _square = true,
        super.square();

  ZegoRSizedBox.fromSize({
    super.key,
    super.size,
    super.child,
  })  : _square = false,
        super.fromSize();

  @override
  RenderConstrainedBox createRenderObject(BuildContext context) {
    return RenderConstrainedBox(
      additionalConstraints: _additionalConstraints,
    );
  }

  final bool _square;

  BoxConstraints get _additionalConstraints {
    final boxConstraints =
        BoxConstraints.tightFor(width: width, height: height);
    return _square ? boxConstraints.zR : boxConstraints.zHW;
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderConstrainedBox renderObject) {
    renderObject.additionalConstraints = _additionalConstraints;
  }
}
