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
  @pragma('vm:entry-point')
  ZegoUIKitSignalingPluginImpl getSignalingPlugin() {
    /// make sure core data's stream had created
    ZegoSignalingPluginCore.shared.coreData.initData();

    assert(
        ZegoPluginAdapter().signalingPlugin != null,
        'ZegoUIKitSignalingPluginImpl: ZegoUIKitPluginType.signaling is null, '
        'plugins should contain ZegoUIKitSignalingPlugin');

    return ZegoUIKitSignalingPluginImpl.shared;
  }

  ZegoUIKitBeautyPluginImpl getBeautyPlugin() {
    assert(ZegoPluginAdapter().getPlugin(ZegoUIKitPluginType.beauty) != null,
        'ZegoUIKitBeautyPluginImpl: ZegoUIKitPluginType.beauty is null');

    return ZegoUIKitBeautyPluginImpl.shared;
  }
}
