import 'package:json_annotation/json_annotation.dart';

part 'score_sheet_item.g.dart';

@JsonSerializable()
class ScoreSheetItem {
  final int trialNumber;
  final int positionIndex;
  final String audioLetter;
  final bool isPositionMatch;
  final bool isAudioMatch;
  final bool userPositionPressed;
  final bool userAudioPressed;
  final int positionScore;
  final int audioScore;
  final int totalScore;

  ScoreSheetItem({
    required this.trialNumber,
    required this.positionIndex,
    required this.audioLetter,
    required this.isPositionMatch,
    required this.isAudioMatch,
    required this.userPositionPressed,
    required this.userAudioPressed,
    required this.positionScore,
    required this.audioScore,
    required this.totalScore,
  });

  factory ScoreSheetItem.fromJson(Map<String, dynamic> json) =>
      _$ScoreSheetItemFromJson(json);
  Map<String, dynamic> toJson() => _$ScoreSheetItemToJson(this);
}
