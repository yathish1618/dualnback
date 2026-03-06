import 'package:json_annotation/json_annotation.dart';
import 'score_sheet_item.dart';

part 'game_session.g.dart';

@JsonSerializable(explicitToJson: true)
class GameSession {
  final String id;
  final DateTime date;
  final int nLevel;
  final int score;
  final int totalTrials;
  final int correctPosition; // Storing raw counts for accuracy recalc if needed
  final int correctAudio;
  final int mistakes;
  final List<ScoreSheetItem> scoreSheet;

  /// True when the session was played with Debug Mode enabled.
  /// Treated as "assisted" / unofficial score.
  final bool debugMode;

  /// 'training' | 'practice' — distinguishes daily training blocks from free practice.
  final String gameMode;

  GameSession({
    required this.id,
    required this.date,
    required this.nLevel,
    required this.score,
    required this.totalTrials,
    required this.correctPosition,
    required this.correctAudio,
    required this.mistakes,
    this.scoreSheet = const [],
    this.debugMode = false,
    this.gameMode = 'practice',
  });

  factory GameSession.fromJson(Map<String, dynamic> json) =>
      _$GameSessionFromJson(json);
  Map<String, dynamic> toJson() => _$GameSessionToJson(this);
}
