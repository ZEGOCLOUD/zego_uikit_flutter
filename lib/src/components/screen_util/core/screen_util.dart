// Dart imports:
import 'dart:io';
import 'dart:math' show min, max;
import 'dart:ui' as ui show FlutterView;

// Flutter imports:
import 'package:flutter/widgets.dart';

typedef ZegoFontSizeResolver = double Function(
    num fontSize, ZegoScreenUtil instance);

/// @nodoc
class ZegoScreenUtil {
  static const Size defaultSize = Size(360, 690);
  static final ZegoScreenUtil _instance = ZegoScreenUtil._();

  /// Phone size in UI design, dp
  /// Size of the phone in UI Design , dp
  late Size _uiSize;

  /// Screen orientation
  late Orientation _orientation;

  late bool _minTextAdapt;
  late MediaQueryData _data;
  late bool _splitScreenMode;
  ZegoFontSizeResolver? fontSizeResolver;

  ZegoScreenUtil._();

  factory ZegoScreenUtil() => _instance;

  /// Manually wait for window size to be initialized
  ///
  /// `Recommended` to use before you need access window size
  /// or in custom splash/bootstrap screen [FutureBuilder]
  ///
  /// example:
  /// ```dart
  /// ...
  /// ZegoScreenUtil.init(context, ...);
  /// ...
  ///   FutureBuilder(
  ///     future: Future.wait([..., ensureScreenSize(), ...]),
  ///     builder: (context, snapshot) {
  ///       if (snapshot.hasData) return const HomeScreen();
  ///       return Material(
  ///         child: LayoutBuilder(
  ///           ...
  ///         ),
  ///       );
  ///     },
  ///   )
  /// ```
  static Future<void> ensureScreenSize([
    ui.FlutterView? window,
    Duration duration = const Duration(milliseconds: 10),
  ]) async {
    final binding = WidgetsFlutterBinding.ensureInitialized();
    binding.deferFirstFrame();

    await Future.doWhile(() {
      window ??= binding.platformDispatcher.implicitView;

      if (window == null || window!.physicalSize.isEmpty) {
        return Future.delayed(duration, () => true);
      }

      return false;
    });

    binding.allowFirstFrame();
  }

  Set<Element>? _elementsToRebuild;

  /// ### Experimental
  /// Register current page and all its descendants to rebuild.
  /// Helpful when building for web and desktop
  static void registerToBuild(
    BuildContext context, [
    bool withDescendants = false,
  ]) {
    (_instance._elementsToRebuild ??= {}).add(context as Element);

    if (withDescendants) {
      context.visitChildren((element) {
        registerToBuild(element, true);
      });
    }
  }

  static void configure({
    MediaQueryData? data,
    Size? designSize,
    bool? splitScreenMode,
    bool? minTextAdapt,
    ZegoFontSizeResolver? fontSizeResolver,
  }) {
    try {
      if (data != null) {
        _instance._data = data;
      } else {
        data = _instance._data;
      }

      if (designSize != null) {
        _instance._uiSize = designSize;
      } else {
        designSize = _instance._uiSize;
      }
    } catch (_) {
      throw Exception(
          'You must either use ZegoScreenUtil.init or ScreenUtilInit first');
    }

    final MediaQueryData? deviceData = data.nonEmptySizeOrNull();
    final Size deviceSize = deviceData?.size ?? designSize;

    final orientation = deviceData?.orientation ??
        (deviceSize.width > deviceSize.height
            ? Orientation.landscape
            : Orientation.portrait);

    _instance
      ..fontSizeResolver = fontSizeResolver ?? _instance.fontSizeResolver
      .._minTextAdapt = minTextAdapt ?? _instance._minTextAdapt
      .._splitScreenMode = splitScreenMode ?? _instance._splitScreenMode
      .._orientation = orientation;

    _instance._elementsToRebuild?.forEach((el) => el.markNeedsBuild());
  }

  /// Initializing the library.
  static void init(
    BuildContext context, {
    Size designSize = defaultSize,
    bool splitScreenMode = false,
    bool minTextAdapt = false,
    ZegoFontSizeResolver? fontSizeResolver,
  }) {
    return configure(
      data: MediaQuery.maybeOf(context),
      designSize: designSize,
      splitScreenMode: splitScreenMode,
      minTextAdapt: minTextAdapt,
      fontSizeResolver: fontSizeResolver,
    );
  }

  static Future<void> ensureScreenSizeAndInit(
    BuildContext context, {
    Size designSize = defaultSize,
    bool splitScreenMode = false,
    bool minTextAdapt = false,
    ZegoFontSizeResolver? fontSizeResolver,
  }) {
    // Capture the MediaQuery data before the async operation
    final mediaQueryData = MediaQuery.maybeOf(context);
    return ZegoScreenUtil.ensureScreenSize().then((_) {
      return configure(
        data: mediaQueryData,
        designSize: designSize,
        minTextAdapt: minTextAdapt,
        splitScreenMode: splitScreenMode,
        fontSizeResolver: fontSizeResolver,
      );
    });
  }

  /// Get screen orientation
  ///Get screen orientation
  Orientation get orientation => _orientation;

  /// Number of font pixels per logical pixel, font scaling ratio
  /// The number of font pixels for each logical pixel.
  double get textScaleFactor => _data.textScaler.scale(1.0);

  /// Device pixel density
  /// The size of the media in logical pixels (e.g, the size of the screen).
  double? get pixelRatio => _data.devicePixelRatio;

  /// Current device width dp
  /// The horizontal extent of this size.
  double get screenWidth => _data.size.width;

  /// Current device height dp
  ///The vertical extent of this size. dp
  double get screenHeight => _data.size.height;

  /// Status bar height dp, notch screen will be higher
  /// The offset from the top, in dp
  double get statusBarHeight => _data.padding.top;

  /// Bottom safe area distance dp
  /// The offset from the bottom, in dp
  double get bottomBarHeight => _data.padding.bottom;

  /// Ratio of actual size to UI design
  /// The ratio of actual width to UI design
  double get scaleWidth => screenWidth / _uiSize.width;

  /// The ratio of actual height to UI design
  double get scaleHeight =>
      (_splitScreenMode ? max(screenHeight, 700) : screenHeight) /
      _uiSize.height;

  double get scaleText =>
      _minTextAdapt ? min(scaleWidth, scaleHeight) : scaleWidth;

  /// Adapt according to device width of UI design
  /// Height can also be adapted according to this to ensure no deformation, for example when you want a square
  /// Adapted to the device width of the UI Design.
  /// Height can also be adapted according to this to ensure no deformation ,
  /// if you want a square
  double setWidth(num width) => width * scaleWidth;

  /// Adapt according to device height of UI design
  /// When it is found that one screen display in UI design does not match current style effect,
  /// or when there is shape difference, it is recommended to use this method for height adaptation
  /// Height adaptation is mainly for achieving the same one-screen display effect as UI design
  /// Highly adaptable to the device according to UI Design
  /// It is recommended to use this method to achieve a high degree of adaptation
  /// when it is found that one screen in the UI design
  /// does not match the current style effect, or if there is a difference in shape.
  double setHeight(num height) => height * scaleHeight;

  /// Adapt according to the smaller of width or height
  ///Adapt according to the smaller of width or height
  double radius(num r) => r * min(scaleWidth, scaleHeight);

  /// Adapt according to the both width and height
  double diagonal(num d) => d * scaleHeight * scaleWidth;

  /// Adapt according to the maximum value of scale width and scale height
  double diameter(num d) => d * max(scaleWidth, scaleHeight);

  /// Font size adaptation method
  ///- [fontSize] Font size on UI design, unit dp
  ///Font size adaptation method
  ///- [fontSize] The size of the font on the UI design, in dp.
  double setSp(num fontSize) =>
      fontSizeResolver?.call(fontSize, _instance) ?? fontSize * scaleText;

  ZegoDeviceType deviceType() {
    ZegoDeviceType deviceType;
    switch (Platform.operatingSystem) {
      case 'android':
      case 'ios':
        deviceType = ZegoDeviceType.mobile;
        if ((orientation == Orientation.portrait && screenWidth < 600) ||
            (orientation == Orientation.landscape && screenHeight < 600)) {
          deviceType = ZegoDeviceType.mobile;
        } else {
          deviceType = ZegoDeviceType.tablet;
        }
        break;
      case 'linux':
        deviceType = ZegoDeviceType.linux;
        break;
      case 'macos':
        deviceType = ZegoDeviceType.mac;
        break;
      case 'windows':
        deviceType = ZegoDeviceType.windows;
        break;
      case 'fuchsia':
        deviceType = ZegoDeviceType.fuchsia;
        break;
      default:
        deviceType = ZegoDeviceType.web;
    }
    return deviceType;
  }

  SizedBox setVerticalSpacing(num height) =>
      SizedBox(height: setHeight(height));

  SizedBox setVerticalSpacingFromWidth(num height) =>
      SizedBox(height: setWidth(height));

  SizedBox setHorizontalSpacing(num width) => SizedBox(width: setWidth(width));

  SizedBox setHorizontalSpacingRadius(num width) =>
      SizedBox(width: radius(width));

  SizedBox setVerticalSpacingRadius(num height) =>
      SizedBox(height: radius(height));

  SizedBox setHorizontalSpacingDiameter(num width) =>
      SizedBox(width: diameter(width));

  SizedBox setVerticalSpacingDiameter(num height) =>
      SizedBox(height: diameter(height));

  SizedBox setHorizontalSpacingDiagonal(num width) =>
      SizedBox(width: diagonal(width));

  SizedBox setVerticalSpacingDiagonal(num height) =>
      SizedBox(height: diagonal(height));
}

extension on MediaQueryData? {
  MediaQueryData? nonEmptySizeOrNull() {
    if (this?.size.isEmpty ?? true) {
      return null;
    } else {
      return this;
    }
  }
}

enum ZegoDeviceType { mobile, tablet, web, mac, windows, linux, fuchsia }
