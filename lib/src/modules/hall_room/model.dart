// Flutter imports:
import 'package:flutter/cupertino.dart';

// Project imports:
import 'package:zego_uikit/src/services/uikit_service.dart';
import 'defines.dart';

/// Context for adjacent room data in room sliding scenarios
///
/// Encapsulates information about the "previous" and "next" rooms adjacent to the current room
/// when sliding to switch between rooms. Supports interactive scenarios such as room list sliding
/// and vertical sliding to switch rooms, providing data support for sliding functionality.
///
/// Works in conjunction with the current room (typically named currentLiveRoom) to form a "previous-current-next"
/// data chain for sliding, facilitating quick access to target room information during sliding and reducing
/// data request delays in the sliding process.
class ZegoUIKitHallRoomListSlideContext {
  /// Information of the previous (previous one) room relative to the active room
  ZegoUIKitHallRoomListStreamUser previous;

  /// Information of the next (next one) room relative to the active room
  ZegoUIKitHallRoomListStreamUser next;

  ZegoUIKitHallRoomListSlideContext({
    required this.previous,
    required this.next,
  });

  @override
  String toString() {
    return '{'
        'previous:$previous, '
        'next:$next, '
        '}';
  }
}

/// Model for managing the hall room list and sliding interactions
///
/// This class manages the state of rooms in the hall, including the currently active room
/// and its adjacent rooms (previous and next). It provides functionality for sliding between
/// rooms in the hall list, supporting vertical sliding scenarios where users can switch
/// between different rooms seamlessly.
///
/// The model maintains an internal list of all available stream users and tracks the current
/// position/index. When sliding occurs, it automatically calculates the previous and next rooms
/// based on the current position, with circular navigation support (wrapping around at the
/// beginning and end of the list).
///
/// Example usage:
/// ```dart
/// final model = ZegoUIKitHallRoomListModel(
///   activeStreamUsers: allStreamUsers,
/// );
///
/// // Slide to next room
/// final nextContext = model.next();
///
/// // Slide to previous room
/// final prevContext = model.previous();
/// ```
class ZegoUIKitHallRoomListModel {
  /// The currently active/selected room in the hall
  ///
  /// Represents the room that is currently being viewed or focused on in the hall list,
  /// serving as the anchor point for sliding interactions.
  ZegoUIKitHallRoomListStreamUser? activeRoom;

  /// Adjacent room data context relative to [activeRoom]
  ///
  /// Contains information about the previous and next rooms adjacent to [activeRoom],
  /// supporting sliding switching functionality in the hall list.
  ZegoUIKitHallRoomListSlideContext? activeContext;

  /// Creates a new hall room list model
  ///
  /// [activeStreamUsers] is the complete list of all available stream users in the hall.
  /// Here, [activeRoom] and [activeContext] will be automatically initialized
  ZegoUIKitHallRoomListModel.fromActiveStreamUsers({
    required List<ZegoUIKitHallRoomListStreamUser> activeStreamUsers,
  }) {
    updateStreamUsers(activeStreamUsers);
  }

  /// Creates a new hall room list model with a specific active room and context
  ///
  /// [activeRoom] is the currently active/selected room in the hall
  /// [activeContext] is the adjacent room data context relative to [activeRoom]
  ZegoUIKitHallRoomListModel.fromActiveRoomAndContext({
    this.activeRoom,
    this.activeContext,
  }) {
    _currentPageIndex = 0;
  }

  /// Updates the list of stream users in the hall
  ///
  /// Replaces the current list of stream users with a new list and resets the current
  /// page index to 0. This method should be called when the hall room list changes,
  /// such as when new rooms are added or existing rooms are removed.
  ///
  /// [streamUsers] is the new complete list of stream users to replace the existing list.
  void updateStreamUsers(List<ZegoUIKitHallRoomListStreamUser> streamUsers) {
    _currentPageIndex = 0;

    _activeStreamUsersNotifier.value = List.from(streamUsers);
    if (_activeStreamUsersNotifier.value.isNotEmpty) {
      activeRoom = _activeStreamUsersNotifier.value[0];

      if (_activeStreamUsersNotifier.value.length > 1) {
        activeContext = ZegoUIKitHallRoomListSlideContext(
          previous: _activeStreamUsersNotifier
              .value[_activeStreamUsersNotifier.value.length - 1],
          next: _activeStreamUsersNotifier.value[1],
        );
      } else {
        activeContext = ZegoUIKitHallRoomListSlideContext(
          previous: _activeStreamUsersNotifier.value[0],
          next: _activeStreamUsersNotifier.value[0],
        );
      }
    }

    ZegoLoggerService.logInfo(
      'active room:$activeRoom, '
      'active context:$activeContext, '
      'active stream users:${_activeStreamUsersNotifier.value.map((e) => '$e')}',
      tag: 'hall model',
      subTag: 'update stream users',
    );
  }

  /// Gets the context for sliding to the next room
  ///
  /// Advances the current position to the next room in the list and returns a context
  /// containing the updated previous and next room information. If the current room is
  /// the last in the list, it wraps around to the first room (circular navigation).
  ///
  /// Returns a [ZegoUIKitHallRoomListSlideContext] with the previous and next rooms relative
  /// to the new current position.
  ZegoUIKitHallRoomListSlideContext next() {
    return _querySliderContext(true);
  }

  /// Gets the context for sliding to the previous room
  ///
  /// Moves the current position to the previous room in the list and returns a context
  /// containing the updated previous and next room information. If the current room is
  /// the first in the list, it wraps around to the last room (circular navigation).
  ///
  /// Returns a [ZegoUIKitHallRoomListSlideContext] with the previous and next rooms relative
  /// to the new current position.
  ZegoUIKitHallRoomListSlideContext previous() {
    return _querySliderContext(false);
  }

  ZegoUIKitHallRoomListSlideContext _querySliderContext(bool toNext) {
    var oldCurrentPageIndex = _currentPageIndex;
    _currentPageIndex += toNext ? 1 : -1;
    if (_currentPageIndex < 0) {
      ///  Cycle through the pages to get back to the bottom
      _currentPageIndex = _activeStreamUsersNotifier.value.length - 1;
    }
    if (_currentPageIndex > _activeStreamUsersNotifier.value.length - 1) {
      ///  Cycle through the pages to get back to the top
      _currentPageIndex = 0;
    }

    var previousIndex = _currentPageIndex - 1;
    if (previousIndex < 0) {
      ///  Cycle through the pages to get back to the bottom
      previousIndex = _activeStreamUsersNotifier.value.length - 1;
    }

    var nextIndex = _currentPageIndex + 1;
    if (nextIndex > _activeStreamUsersNotifier.value.length - 1) {
      ///  Cycle through the pages to get back to the top
      nextIndex = 0;
    }

    activeRoom = _activeStreamUsersNotifier.value[_currentPageIndex];
    activeContext = ZegoUIKitHallRoomListSlideContext(
      previous: _activeStreamUsersNotifier.value[previousIndex],
      next: _activeStreamUsersNotifier.value[nextIndex],
    );
    ZegoLoggerService.logInfo(
      'old current index:$oldCurrentPageIndex, '
      'to next:$toNext, '
      'now:{'
      'previous:{index:$previousIndex, user:${activeContext?.previous}, '
      'current:{index:$_currentPageIndex, user:$activeRoom}, '
      'next:{index:$nextIndex, user:${activeContext?.next}}, '
      '}',
      tag: 'hall model',
      subTag: 'get stream users',
    );

    return ZegoUIKitHallRoomListSlideContext(
      previous: _activeStreamUsersNotifier.value[previousIndex],
      next: _activeStreamUsersNotifier.value[nextIndex],
    );
  }

  var _currentPageIndex = 0;
  final _activeStreamUsersNotifier =
      ValueNotifier<List<ZegoUIKitHallRoomListStreamUser>>([]);
}

/// manage data by yourself
class ZegoUIKitHallRoomListModelDelegate {
  ZegoUIKitHallRoomListModelDelegate({
    required this.activeRoom,
    required this.activeContext,
    required this.delegate,
  });

  /// The currently active/selected room in the hall
  ///
  /// Represents the room that is currently being viewed or focused on in the hall list,
  /// serving as the anchor point for sliding interactions.
  ///
  /// The active host information of the initial state, which is '0' in [0,1,2,...]
  final ZegoUIKitHallRoomListStreamUser activeRoom;

  /// Adjacent room data context relative to [activeRoom]
  ///
  /// Contains information about the previous and next rooms adjacent to [activeRoom],
  /// supporting sliding switching functionality in the hall list.
  ///
  /// The **next** host information and the **previous** host information of the [activeRoom],
  /// which **next** is '9' and **previous** is '2' in [0,1,2,...,9] and '0' is [activeRoom]
  final ZegoUIKitHallRoomListSlideContext activeContext;

  ///  When the sliding page is updated, the **next** and **previous** host information of the current page will be obtained through this
  final ZegoUIKitHallRoomListSlideContext Function(
    /// Is it a downward (backward) swipe, otherwise it's an upward (forward) swipe
    bool toNext,
  )? delegate;
}
