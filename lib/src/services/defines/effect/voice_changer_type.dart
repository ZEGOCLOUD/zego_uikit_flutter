import 'package:zego_express_engine/zego_express_engine.dart';

/// Enumeration of voice changer types.
enum VoiceChangerType {
  /// No voice changer.
  none,

  /// Little boy voice.
  littleBoy,

  /// Little girl voice.
  littleGirl,

  /// Ethereal voice.
  ethereal,

  /// Female voice.
  female,

  /// Male voice.
  male,

  /// Robot voice.
  robot,

  /// Optimus Prime voice.
  optimusPrime,

  /// Deep voice.
  deep,

  /// Crystal clear voice.
  crystalClear,

  /// C major male voice.
  cMajor,

  /// A major male voice.
  aMajor,

  /// Harmonic minor voice.
  harmonicMinor,
}

extension VoiceChangerTypeExtension on VoiceChangerType {
  String get text {
    final mapValues = {
      VoiceChangerType.none: 'None',
      VoiceChangerType.littleBoy: 'Little boy',
      VoiceChangerType.littleGirl: 'Little girl',
      VoiceChangerType.deep: 'Deep',
      VoiceChangerType.crystalClear: 'Crystal-clear',
      VoiceChangerType.robot: 'Robot',
      VoiceChangerType.ethereal: 'Ethereal',
      VoiceChangerType.female: 'Female',
      VoiceChangerType.male: 'Male',
      VoiceChangerType.optimusPrime: 'Optimus Prime',
      VoiceChangerType.cMajor: 'C major',
      VoiceChangerType.aMajor: 'A major',
      VoiceChangerType.harmonicMinor: 'Harmonic minor',
    };

    return mapValues[this]!;
  }

  ZegoVoiceChangerPreset get key {
    final mapValues = {
      VoiceChangerType.none: ZegoVoiceChangerPreset.None,
      VoiceChangerType.littleBoy: ZegoVoiceChangerPreset.MenToChild,
      VoiceChangerType.littleGirl: ZegoVoiceChangerPreset.WomenToChild,
      VoiceChangerType.deep: ZegoVoiceChangerPreset.MaleMagnetic,
      VoiceChangerType.crystalClear: ZegoVoiceChangerPreset.FemaleFresh,
      VoiceChangerType.robot: ZegoVoiceChangerPreset.Android,
      VoiceChangerType.ethereal: ZegoVoiceChangerPreset.Ethereal,
      VoiceChangerType.female: ZegoVoiceChangerPreset.MenToWomen,
      VoiceChangerType.male: ZegoVoiceChangerPreset.WomenToMen,
      VoiceChangerType.optimusPrime: ZegoVoiceChangerPreset.OptimusPrime,
      VoiceChangerType.cMajor: ZegoVoiceChangerPreset.MajorC,
      VoiceChangerType.aMajor: ZegoVoiceChangerPreset.MinorA,
      VoiceChangerType.harmonicMinor: ZegoVoiceChangerPreset.HarmonicMinor,
    };

    return mapValues[this]!;
  }
}
