// Dart imports:
import 'dart:async';
import 'dart:collection';

// Flutter imports:
import 'package:flutter/widgets.dart';

// Project imports:
import 'package:zego_uikit/src/components/screen_util/core/_flutter_widgets.dart';
import 'package:zego_uikit/src/components/screen_util/core/screen_util.dart';
import 'package:zego_uikit/src/components/screen_util/core/screenutil_mixin.dart';

typedef ZegoRebuildFactor = bool Function(
    MediaQueryData old, MediaQueryData data);

typedef ZegoScreenUtilInitBuilder = Widget Function(
  BuildContext context,
  Widget? child,
);

/// @nodoc
abstract class ZegoRebuildFactors {
  static bool size(MediaQueryData old, MediaQueryData data) {
    return old.size != data.size;
  }

  static bool orientation(MediaQueryData old, MediaQueryData data) {
    return old.orientation != data.orientation;
  }

  static bool sizeAndViewInsets(MediaQueryData old, MediaQueryData data) {
    return old.viewInsets != data.viewInsets;
  }

  static bool change(MediaQueryData old, MediaQueryData data) {
    return old != data;
  }

  static bool always(MediaQueryData _, MediaQueryData __) {
    return true;
  }

  static bool none(MediaQueryData _, MediaQueryData __) {
    return false;
  }
}

abstract class ZegoFontSizeResolvers {
  static double width(num fontSize, ZegoScreenUtil instance) {
    return instance.setWidth(fontSize);
  }

  static double height(num fontSize, ZegoScreenUtil instance) {
    return instance.setHeight(fontSize);
  }

  static double radius(num fontSize, ZegoScreenUtil instance) {
    return instance.radius(fontSize);
  }

  static double diameter(num fontSize, ZegoScreenUtil instance) {
    return instance.diameter(fontSize);
  }

  static double diagonal(num fontSize, ZegoScreenUtil instance) {
    return instance.diagonal(fontSize);
  }
}

/// @nodoc
class ZegoScreenUtilInit extends StatefulWidget {
  /// A helper widget that initializes [ZegoScreenUtil]
  const ZegoScreenUtilInit({
    super.key,
    this.builder,
    this.child,
    this.rebuildFactor = ZegoRebuildFactors.size,
    this.designSize = ZegoScreenUtil.defaultSize,
    this.splitScreenMode = false,
    this.minTextAdapt = false,
    this.useInheritedMediaQuery = false,
    this.ensureScreenSize,
    this.responsiveWidgets,
    this.fontSizeResolver = ZegoFontSizeResolvers.width,
  });

  final ZegoScreenUtilInitBuilder? builder;
  final Widget? child;
  final bool splitScreenMode;
  final bool minTextAdapt;
  final bool useInheritedMediaQuery;
  final bool? ensureScreenSize;
  final ZegoRebuildFactor rebuildFactor;
  final ZegoFontSizeResolver fontSizeResolver;

  /// The [Size] of the device in the design draft, in dp
  final Size designSize;
  final Iterable<String>? responsiveWidgets;

  @override
  State<ZegoScreenUtilInit> createState() => _ZegoScreenUtilInitState();
}

class _ZegoScreenUtilInitState extends State<ZegoScreenUtilInit>
    with WidgetsBindingObserver {
  final _canMarkedToBuild = HashSet<String>();
  MediaQueryData? _mediaQueryData;
  final _binding = WidgetsBinding.instance;
  final _screenSizeCompleter = Completer<void>();

  @override
  void initState() {
    if (widget.responsiveWidgets != null) {
      _canMarkedToBuild.addAll(widget.responsiveWidgets!);
    }
    _validateSize().then(_screenSizeCompleter.complete);

    super.initState();
    _binding.addObserver(this);
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    _revalidate();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _revalidate();
  }

  MediaQueryData? _newData() {
    MediaQueryData? mq = MediaQuery.maybeOf(context);
    mq ??= MediaQueryData.fromView(View.of(context));

    return mq;
  }

  Future<void> _validateSize() async {
    if (widget.ensureScreenSize ?? false) {
      return ZegoScreenUtil.ensureScreenSize();
    }
  }

  void _markNeedsBuildIfAllowed(Element el) {
    final widgetName = el.widget.runtimeType.toString();
    final allowed = widget is ZegoSU ||
        _canMarkedToBuild.contains(widgetName) ||
        !(widgetName.startsWith('_') || zFlutterWidgets.contains(widgetName));

    if (allowed) el.markNeedsBuild();
  }

  void _updateTree(Element el) {
    _markNeedsBuildIfAllowed(el);
    el.visitChildren(_updateTree);
  }

  void _revalidate([void Function()? callback]) {
    final oldData = _mediaQueryData;
    final newData = _newData();

    if (newData == null) return;

    if (oldData == null || widget.rebuildFactor(oldData, newData)) {
      setState(() {
        _mediaQueryData = newData;
        _updateTree(context as Element);
        callback?.call();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = _mediaQueryData;

    if (mq == null) return const SizedBox.shrink();

    return FutureBuilder<void>(
      future: _screenSizeCompleter.future,
      builder: (c, snapshot) {
        ZegoScreenUtil.configure(
          data: mq,
          designSize: widget.designSize,
          splitScreenMode: widget.splitScreenMode,
          minTextAdapt: widget.minTextAdapt,
          fontSizeResolver: widget.fontSizeResolver,
        );

        if (snapshot.connectionState == ConnectionState.done) {
          return widget.builder?.call(context, widget.child) ?? widget.child!;
        }

        return const SizedBox.shrink();
      },
    );
  }

  @override
  void dispose() {
    _binding.removeObserver(this);
    super.dispose();
  }
}
