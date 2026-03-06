// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GameSession _$GameSessionFromJson(Map<String, dynamic> json) => GameSession(
  id: json['id'] as String,
  date: DateTime.parse(json['date'] as String),
  nLevel: (json['nLevel'] as num).toInt(),
  score: (json['score'] as num).toInt(),
  totalTrials: (json['totalTrials'] as num).toInt(),
  correctPosition: (json['correctPosition'] as num).toInt(),
  correctAudio: (json['correctAudio'] as num).toInt(),
  mistakes: (json['mistakes'] as num).toInt(),
  scoreSheet:
      (json['scoreSheet'] as List<dynamic>?)
          ?.map((e) => ScoreSheetItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  debugMode: json['debugMode'] as bool? ?? false,
  gameMode: json['gameMode'] as String? ?? 'practice',
);

Map<String, dynamic> _$GameSessionToJson(GameSession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date.toIso8601String(),
      'nLevel': instance.nLevel,
      'score': instance.score,
      'totalTrials': instance.totalTrials,
      'correctPosition': instance.correctPosition,
      'correctAudio': instance.correctAudio,
      'mistakes': instance.mistakes,
      'scoreSheet': instance.scoreSheet.map((e) => e.toJson()).toList(),
      'debugMode': instance.debugMode,
      'gameMode': instance.gameMode,
    };
