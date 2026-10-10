// Package imports:
import 'package:zego_express_engine_for_uikit/zego_express_engine.dart';

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

/// Enumeration of reverb types.
enum ReverbType {
  /// No reverb.
  none,

  /// KTV reverb.
  ktv,

  /// Hall reverb.
  hall,

  /// Concert reverb.
  concert,

  /// Rock reverb.
  rock,

  /// Small room reverb.
  smallRoom,

  /// Large room reverb.
  largeRoom,

  /// Valley reverb.
  valley,

  /// Recording studio reverb.
  recordingStudio,

  /// Basement reverb.
  basement,

  /// Popular reverb.
  popular,

  /// Gramophone reverb.
  gramophone,
}

extension ReverbTypeExtension on ReverbType {
  String get text {
    final mapValues = {
      ReverbType.none: 'None',
      ReverbType.ktv: 'Karaoke',
      ReverbType.hall: 'Hall',
      ReverbType.concert: 'Concert',
      ReverbType.rock: 'Rock',
      ReverbType.smallRoom: 'Small room',
      ReverbType.largeRoom: 'Large room',
      ReverbType.valley: 'Valley',
      ReverbType.recordingStudio: 'Recording studio',
      ReverbType.basement: 'Basement',
      ReverbType.popular: 'Pop',
      ReverbType.gramophone: 'Gramophone',
    };

    return mapValues[this]!;
  }

  ZegoReverbPreset get key {
    final mapValues = {
      ReverbType.ktv: ZegoReverbPreset.KTV,
      ReverbType.hall: ZegoReverbPreset.ConcertHall,
      ReverbType.concert: ZegoReverbPreset.VocalConcert,
      ReverbType.rock: ZegoReverbPreset.Rock,
      ReverbType.none: ZegoReverbPreset.None,
      ReverbType.smallRoom: ZegoReverbPreset.SoftRoom,
      ReverbType.largeRoom: ZegoReverbPreset.LargeRoom,
      ReverbType.valley: ZegoReverbPreset.Valley,
      ReverbType.recordingStudio: ZegoReverbPreset.RecordingStudio,
      ReverbType.basement: ZegoReverbPreset.Basement,
      ReverbType.popular: ZegoReverbPreset.Popular,
      ReverbType.gramophone: ZegoReverbPreset.GramoPhone,
    };

    return mapValues[this]!;
  }
}
