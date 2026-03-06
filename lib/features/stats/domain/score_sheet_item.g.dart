// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'score_sheet_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ScoreSheetItem _$ScoreSheetItemFromJson(Map<String, dynamic> json) =>
    ScoreSheetItem(
      trialNumber: (json['trialNumber'] as num).toInt(),
      positionIndex: (json['positionIndex'] as num).toInt(),
      audioLetter: json['audioLetter'] as String,
      isPositionMatch: json['isPositionMatch'] as bool,
      isAudioMatch: json['isAudioMatch'] as bool,
      userPositionPressed: json['userPositionPressed'] as bool,
      userAudioPressed: json['userAudioPressed'] as bool,
      positionScore: (json['positionScore'] as num).toInt(),
      audioScore: (json['audioScore'] as num).toInt(),
      totalScore: (json['totalScore'] as num).toInt(),
    );

Map<String, dynamic> _$ScoreSheetItemToJson(ScoreSheetItem instance) =>
    <String, dynamic>{
      'trialNumber': instance.trialNumber,
      'positionIndex': instance.positionIndex,
      'audioLetter': instance.audioLetter,
      'isPositionMatch': instance.isPositionMatch,
      'isAudioMatch': instance.isAudioMatch,
      'userPositionPressed': instance.userPositionPressed,
      'userAudioPressed': instance.userAudioPressed,
      'positionScore': instance.positionScore,
      'audioScore': instance.audioScore,
      'totalScore': instance.totalScore,
    };
