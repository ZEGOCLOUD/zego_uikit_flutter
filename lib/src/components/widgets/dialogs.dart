// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Project imports:
import 'package:zego_uikit/src/components/screen_util/screen_util.dart';
import 'package:zego_uikit/src/services/services.dart';

Future<bool> showAlertDialog(
  BuildContext? context,
  String title,
  String content,
  List<Widget> actions, {
  TextStyle? titleStyle,
  TextStyle? contentStyle,
  MainAxisAlignment? actionsAlignment,
  Color? backgroundColor,
  Brightness? backgroundBrightness,
}) async {
  if (!(context?.mounted ?? false)) {
    ZegoLoggerService.logInfo(
      'show dialog error, context is not mounted, '
      'context:$context, '
      'title:$title, '
      'content:$content, '
      'actions:$actions, ',
      tag: 'uikit.component',
      subTag: 'dialogs',
    );

    return false;
  }

  var result = false;

  try {
    result = await showDialog(
          context: context!,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return CupertinoTheme(
              data: CupertinoThemeData(
                brightness: backgroundBrightness ?? Brightness.dark,
              ),
              child: CupertinoAlertDialog(
                title: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: titleStyle ??
                      TextStyle(
                        fontSize: 30.0.zR,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xff2A2A2A),
                      ),
                ),
                content: Text(
                  content,
                  textAlign: TextAlign.center,
                  style: contentStyle ??
                      TextStyle(
                        fontSize: 28.0.zR,
                        color: const Color(0xff2A2A2A),
                      ),
                ),
                actions: actions,
              ),
            );
          },
        ) ??
        false;
  } catch (e) {
    ZegoLoggerService.logError(
      'show dialog error, $e, '
      'context;$context, ',
      tag: 'uikit.component',
      subTag: 'dialogs',
    );
  }

  return result;
}

Future<bool> showTopModalSheet<T>(
  BuildContext? context,
  Widget widget, {
  bool barrierDismissible = true,
}) async {
  if (!(context?.mounted ?? false)) {
    ZegoLoggerService.logInfo(
      'show dialog error, context is not mounted, '
      'context:$context, ',
      tag: 'uikit.component',
      subTag: 'dialogs',
    );

    return false;
  }

  bool result = false;

  try {
    result = await showGeneralDialog<bool>(
          context: context!,
          barrierDismissible: barrierDismissible,
          transitionDuration: const Duration(milliseconds: 250),
          barrierLabel: MaterialLocalizations.of(context).dialogLabel,
          barrierColor: Colors.black.withValues(alpha: 0.5),
          pageBuilder: (context, _, __) => ZegoScreenUtilInit(
            designSize: const Size(750, 1334),
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (context, child) {
              return SafeArea(
                  child: Column(
                children: [
                  SizedBox(height: 16.zH),
                  widget,
                ],
              ));
            },
          ),
          transitionBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position:
                  CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)
                      .drive(Tween<Offset>(
                          begin: const Offset(0, -1.0), end: Offset.zero)),
              child: child,
            );
          },
        ) ??
        false;
  } catch (e) {
    ZegoLoggerService.logError(
      'showTopModalSheet, $e, '
      'context:$context, ',
      tag: 'uikit.component',
      subTag: 'dialogs',
    );
  }

  return result;
}
