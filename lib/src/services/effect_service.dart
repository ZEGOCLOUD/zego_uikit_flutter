part of 'uikit_service.dart';

mixin ZegoEffectService {
  /// enable beauty
  Future<void> enableBeauty(bool isOn) async {
    ZegoUIKitCore.shared.enableBeauty(isOn);
  }

  /// start effects env
  Future<void> startEffectsEnv() async {
    ZegoUIKitCore.shared.startEffectsEnv();
  }

  /// stop effects env
  Future<void> stopEffectsEnv() async {
    ZegoUIKitCore.shared.stopEffectsEnv();
  }

  /// Set the intensity of the specific face beautify feature
  /// Description: After the face beautify feature is enabled, you can specify the parameters to set the intensity of the specific feature as needed.
  ///
  /// Call this method at: After enabling the face beautify feature.
  ///
  /// @param value refers to the range value of the specific face beautification feature or face shape retouch feature.
  /// @param type  refers to the specific face beautification feature or face shape retouch feature.
  void setBeautifyValue(int value, BeautyEffectType type) {
    if (BeautyEffectType.none == type) {
      return;
    }

    switch (type) {
      case BeautyEffectType.whiten:
        ZegoUIKitCore.shared.coreData.beautyParam.whitenIntensity = value;
        break;
      case BeautyEffectType.rosy:
        ZegoUIKitCore.shared.coreData.beautyParam.rosyIntensity = value;
        break;
      case BeautyEffectType.smooth:
        ZegoUIKitCore.shared.coreData.beautyParam.smoothIntensity = value;
        break;
      case BeautyEffectType.sharpen:
        ZegoUIKitCore.shared.coreData.beautyParam.sharpenIntensity = value;
        break;
      case BeautyEffectType.none:
        break;
    }

    ZegoLoggerService.logInfo(
      'set beauty $type value: $value',
      tag: 'uikit',
      subTag: 'effect service',
    );

    ZegoExpressEngine.instance.setEffectsBeautyParam(
      ZegoUIKitCore.shared.coreData.beautyParam,
    );
  }

  /// get beauty value
  ZegoEffectsBeautyParam getBeautyValue() {
    return ZegoUIKitCore.shared.coreData.beautyParam;
  }

  /// Set voice changing
  /// Description: This method can be used to change the voice with voice effects.
  ///
  /// Call this method at: After joining a room
  ///
  /// @param voicePreset refers to the voice type you want to changed to.
  void setVoiceChangerType(ZegoVoiceChangerPreset voicePreset) {
    ZegoLoggerService.logInfo(
      'set voice changing type: $voicePreset',
      tag: 'uikit',
      subTag: 'effect service',
    );
    ZegoExpressEngine.instance.setVoiceChangerPreset(voicePreset);
  }

  /// Set reverb
  /// Description: This method can be used to use the reverb effect in the room.
  ///
  /// Call this method at: After joining a room
  ///
  /// @param reverbPreset refers to the reverb type you want to select.
  void setReverbType(ZegoReverbPreset reverbPreset) {
    ZegoLoggerService.logInfo(
      'set reverb type: $reverbPreset',
      tag: 'uikit',
      subTag: 'effect service',
    );
    ZegoExpressEngine.instance.setReverbPreset(reverbPreset);
  }

  /// reset sound effect
  Future<void> resetSoundEffect() async {
    await ZegoExpressEngine.instance.setReverbPreset(ZegoReverbPreset.None);
    await ZegoExpressEngine.instance.setVoiceChangerPreset(
      ZegoVoiceChangerPreset.None,
    );
  }

  /// reset beauty effect
  Future<void> resetBeautyEffect() async {
    ZegoUIKitCore.shared.coreData.beautyParam =
        ZegoEffectsBeautyParam.defaultParam();
    await ZegoExpressEngine.instance.setEffectsBeautyParam(
      ZegoEffectsBeautyParam.defaultParam(),
    );
  }
}
