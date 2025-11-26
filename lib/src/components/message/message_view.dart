// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:zego_uikit/src/components/message/defines.dart';
import 'package:zego_uikit/src/services/services.dart';

class ZegoInRoomMessageView extends StatefulWidget {
  final Stream<List<ZegoInRoomMessage>> stream;

  /// messages before stream broadcast
  final List<ZegoInRoomMessage> historyMessages;

  final ZegoInRoomMessageItemBuilder itemBuilder;

  final bool scrollable;
  final ScrollController? scrollController;

  const ZegoInRoomMessageView({
    super.key,
    required this.stream,
    required this.itemBuilder,
    this.scrollable = true,
    this.scrollController,
    this.historyMessages = const [],
  });

  @override
  State<ZegoInRoomMessageView> createState() => _ZegoInRoomMessageViewState();
}

class _ZegoInRoomMessageViewState extends State<ZegoInRoomMessageView> {
  late ScrollController _scrollController;

  StreamSubscription<dynamic>? streamSubscription;
  var messagesNotifier = ValueNotifier<List<ZegoInRoomMessage>>([]);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });

    messagesNotifier.value = widget.historyMessages;

    _scrollController = widget.scrollController ?? ScrollController();
    streamSubscription = widget.stream.listen(onMessageUpdate);
  }

  @override
  void dispose() {
    super.dispose();

    messagesNotifier.value = [];
    streamSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<ZegoInRoomMessage>>(
      valueListenable: messagesNotifier,
      builder: (context, messageList, child) {
        return MediaQuery.removePadding(
          context: context,
          removeTop: true,
          removeBottom: true,
          child: ListView.builder(
            shrinkWrap: true,
            controller: _scrollController,
            physics:
                widget.scrollable ? null : const NeverScrollableScrollPhysics(),
            itemCount: messageList.length,
            itemBuilder: (context, index) {
              final message = messageList[index];

              return widget.itemBuilder.call(context, message, {});
            },
          ),
        );
      },
    );
  }

  void onMessageUpdate(List<ZegoInRoomMessage> messages) {
    messagesNotifier.value = messages;

    Future.delayed(const Duration(milliseconds: 100), () {
      if (messagesNotifier.value.isEmpty) {
        return;
      }

      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }
}
