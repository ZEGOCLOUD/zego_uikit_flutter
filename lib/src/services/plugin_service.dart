part of 'uikit_service.dart';

/// @nodoc
// see IZegoUIKitPlugin
mixin ZegoPluginService {
  ValueNotifier<List<ZegoUIKitPluginType>> pluginsInstallNotifier() {
    return ZegoPluginAdapter().pluginsInstallNotifier;
  }

  /// install plugins
  void installPlugins(List<IZegoUIKitPlugin> plugins) {
    ZegoPluginAdapter().installPlugins(plugins);
  }

  /// uninstall plugins
  void uninstallPlugins(List<IZegoUIKitPlugin> plugins) {
    ZegoPluginAdapter().uninstallPlugins(plugins);
  }

  /// adapter service
  ZegoPluginAdapterService adapterService() {
    return ZegoPluginAdapter().service();
  }

  /// get plugin object
  IZegoUIKitPlugin? getPlugin(ZegoUIKitPluginType type) {
    return ZegoPluginAdapter().getPlugin(type);
  }

  /// signal plugin
  ZegoUIKitSignalingPluginImpl getSignalingPlugin() {
    /// make sure core data's stream had created
    ZegoSignalingPluginCore.shared.coreData.initData();

    if (ZegoPluginAdapter().signalingPlugin == null) {
      ZegoLoggerService.logError(
        'ZegoUIKitSignalingPluginImpl: ZegoUIKitPluginType.signaling is null, '
        'plugins should contain ZegoUIKitSignalingPlugin',
        tag: 'uikit.service.event-handler',
        subTag: 'onRoomStreamUpdate',
      );

      assert(false);
    }

    return ZegoUIKitSignalingPluginImpl.shared;
  }

  ZegoUIKitBeautyPluginImpl getBeautyPlugin() {
    if (ZegoPluginAdapter().getPlugin(ZegoUIKitPluginType.beauty) != null) {
      ZegoLoggerService.logError(
        'ZegoUIKitBeautyPluginImpl: ZegoUIKitPluginType.beauty is null',
        tag: 'uikit.service.event-handler',
        subTag: 'onRoomStreamUpdate',
      );

      assert(false);
    }

    return ZegoUIKitBeautyPluginImpl.shared;
  }
}
