/// Enumeration of beauty effect types.
enum BeautyEffectType {
  /// Whitening effect.
  whiten,

  /// Rosy effect.
  rosy,

  /// Smoothing effect.
  smooth,

  /// Sharpening effect.
  sharpen,

  /// No beauty effect.
  none,
}

extension BeautyEffectTypeExtension on BeautyEffectType {
  String get text {
    final mapValues = {
      BeautyEffectType.whiten: 'Skin Tone',
      BeautyEffectType.rosy: 'Blusher',
      BeautyEffectType.smooth: 'Smoothing',
      BeautyEffectType.sharpen: 'Sharpening',
      BeautyEffectType.none: 'None',
    };

    return mapValues[this]!;
  }
}
