import 'package:zego_express_engine/zego_express_engine.dart';

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
