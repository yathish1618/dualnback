// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GameSignal {

 int get positionIndex;// 0-8 for 3x3 grid
 String get audioLetter;
/// Create a copy of GameSignal
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GameSignalCopyWith<GameSignal> get copyWith => _$GameSignalCopyWithImpl<GameSignal>(this as GameSignal, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GameSignal&&(identical(other.positionIndex, positionIndex) || other.positionIndex == positionIndex)&&(identical(other.audioLetter, audioLetter) || other.audioLetter == audioLetter));
}


@override
int get hashCode => Object.hash(runtimeType,positionIndex,audioLetter);

@override
String toString() {
  return 'GameSignal(positionIndex: $positionIndex, audioLetter: $audioLetter)';
}


}

/// @nodoc
abstract mixin class $GameSignalCopyWith<$Res>  {
  factory $GameSignalCopyWith(GameSignal value, $Res Function(GameSignal) _then) = _$GameSignalCopyWithImpl;
@useResult
$Res call({
 int positionIndex, String audioLetter
});




}
/// @nodoc
class _$GameSignalCopyWithImpl<$Res>
    implements $GameSignalCopyWith<$Res> {
  _$GameSignalCopyWithImpl(this._self, this._then);

  final GameSignal _self;
  final $Res Function(GameSignal) _then;

/// Create a copy of GameSignal
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? positionIndex = null,Object? audioLetter = null,}) {
  return _then(_self.copyWith(
positionIndex: null == positionIndex ? _self.positionIndex : positionIndex // ignore: cast_nullable_to_non_nullable
as int,audioLetter: null == audioLetter ? _self.audioLetter : audioLetter // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [GameSignal].
extension GameSignalPatterns on GameSignal {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GameSignal value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GameSignal() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GameSignal value)  $default,){
final _that = this;
switch (_that) {
case _GameSignal():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GameSignal value)?  $default,){
final _that = this;
switch (_that) {
case _GameSignal() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int positionIndex,  String audioLetter)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GameSignal() when $default != null:
return $default(_that.positionIndex,_that.audioLetter);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int positionIndex,  String audioLetter)  $default,) {final _that = this;
switch (_that) {
case _GameSignal():
return $default(_that.positionIndex,_that.audioLetter);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int positionIndex,  String audioLetter)?  $default,) {final _that = this;
switch (_that) {
case _GameSignal() when $default != null:
return $default(_that.positionIndex,_that.audioLetter);case _:
  return null;

}
}

}

/// @nodoc


class _GameSignal implements GameSignal {
  const _GameSignal({required this.positionIndex, required this.audioLetter});
  

@override final  int positionIndex;
// 0-8 for 3x3 grid
@override final  String audioLetter;

/// Create a copy of GameSignal
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GameSignalCopyWith<_GameSignal> get copyWith => __$GameSignalCopyWithImpl<_GameSignal>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GameSignal&&(identical(other.positionIndex, positionIndex) || other.positionIndex == positionIndex)&&(identical(other.audioLetter, audioLetter) || other.audioLetter == audioLetter));
}


@override
int get hashCode => Object.hash(runtimeType,positionIndex,audioLetter);

@override
String toString() {
  return 'GameSignal(positionIndex: $positionIndex, audioLetter: $audioLetter)';
}


}

/// @nodoc
abstract mixin class _$GameSignalCopyWith<$Res> implements $GameSignalCopyWith<$Res> {
  factory _$GameSignalCopyWith(_GameSignal value, $Res Function(_GameSignal) _then) = __$GameSignalCopyWithImpl;
@override @useResult
$Res call({
 int positionIndex, String audioLetter
});




}
/// @nodoc
class __$GameSignalCopyWithImpl<$Res>
    implements _$GameSignalCopyWith<$Res> {
  __$GameSignalCopyWithImpl(this._self, this._then);

  final _GameSignal _self;
  final $Res Function(_GameSignal) _then;

/// Create a copy of GameSignal
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? positionIndex = null,Object? audioLetter = null,}) {
  return _then(_GameSignal(
positionIndex: null == positionIndex ? _self.positionIndex : positionIndex // ignore: cast_nullable_to_non_nullable
as int,audioLetter: null == audioLetter ? _self.audioLetter : audioLetter // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$GameState {

 GameStatus get status; bool get isPaused; int get currentNLevel; int get currentTrial; int get totalTrials; int get score; int get lives;// Optional, maybe not needed per specs, but useful
// The history of signals in this session
 List<GameSignal> get history;// The current signal being presented (null if in between or not started)
 GameSignal? get currentSignal;// User feedback for the current trial
 bool? get visualMatchPressed; bool? get audioMatchPressed;// Result of the current trial
 bool? get lastTrialCorrect;// For UI feedback (green/red flash)
// Detailed stats
 int get correctPositionMatches; int get correctAudioMatches; int get missedPositionMatches; int get missedAudioMatches; int get falsePositionMatches; int get falseAudioMatches;// Countdown
// Countdown
 int get countdownValue;// Debug Data
 List<TrialResult> get trialResults;// Pending row: set when a trial begins (before evaluation)
 int? get pendingTrialNumber; GameSignal? get pendingSignal;
/// Create a copy of GameState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GameStateCopyWith<GameState> get copyWith => _$GameStateCopyWithImpl<GameState>(this as GameState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GameState&&(identical(other.status, status) || other.status == status)&&(identical(other.isPaused, isPaused) || other.isPaused == isPaused)&&(identical(other.currentNLevel, currentNLevel) || other.currentNLevel == currentNLevel)&&(identical(other.currentTrial, currentTrial) || other.currentTrial == currentTrial)&&(identical(other.totalTrials, totalTrials) || other.totalTrials == totalTrials)&&(identical(other.score, score) || other.score == score)&&(identical(other.lives, lives) || other.lives == lives)&&const DeepCollectionEquality().equals(other.history, history)&&(identical(other.currentSignal, currentSignal) || other.currentSignal == currentSignal)&&(identical(other.visualMatchPressed, visualMatchPressed) || other.visualMatchPressed == visualMatchPressed)&&(identical(other.audioMatchPressed, audioMatchPressed) || other.audioMatchPressed == audioMatchPressed)&&(identical(other.lastTrialCorrect, lastTrialCorrect) || other.lastTrialCorrect == lastTrialCorrect)&&(identical(other.correctPositionMatches, correctPositionMatches) || other.correctPositionMatches == correctPositionMatches)&&(identical(other.correctAudioMatches, correctAudioMatches) || other.correctAudioMatches == correctAudioMatches)&&(identical(other.missedPositionMatches, missedPositionMatches) || other.missedPositionMatches == missedPositionMatches)&&(identical(other.missedAudioMatches, missedAudioMatches) || other.missedAudioMatches == missedAudioMatches)&&(identical(other.falsePositionMatches, falsePositionMatches) || other.falsePositionMatches == falsePositionMatches)&&(identical(other.falseAudioMatches, falseAudioMatches) || other.falseAudioMatches == falseAudioMatches)&&(identical(other.countdownValue, countdownValue) || other.countdownValue == countdownValue)&&const DeepCollectionEquality().equals(other.trialResults, trialResults)&&(identical(other.pendingTrialNumber, pendingTrialNumber) || other.pendingTrialNumber == pendingTrialNumber)&&(identical(other.pendingSignal, pendingSignal) || other.pendingSignal == pendingSignal));
}


@override
int get hashCode => Object.hashAll([runtimeType,status,isPaused,currentNLevel,currentTrial,totalTrials,score,lives,const DeepCollectionEquality().hash(history),currentSignal,visualMatchPressed,audioMatchPressed,lastTrialCorrect,correctPositionMatches,correctAudioMatches,missedPositionMatches,missedAudioMatches,falsePositionMatches,falseAudioMatches,countdownValue,const DeepCollectionEquality().hash(trialResults),pendingTrialNumber,pendingSignal]);

@override
String toString() {
  return 'GameState(status: $status, isPaused: $isPaused, currentNLevel: $currentNLevel, currentTrial: $currentTrial, totalTrials: $totalTrials, score: $score, lives: $lives, history: $history, currentSignal: $currentSignal, visualMatchPressed: $visualMatchPressed, audioMatchPressed: $audioMatchPressed, lastTrialCorrect: $lastTrialCorrect, correctPositionMatches: $correctPositionMatches, correctAudioMatches: $correctAudioMatches, missedPositionMatches: $missedPositionMatches, missedAudioMatches: $missedAudioMatches, falsePositionMatches: $falsePositionMatches, falseAudioMatches: $falseAudioMatches, countdownValue: $countdownValue, trialResults: $trialResults, pendingTrialNumber: $pendingTrialNumber, pendingSignal: $pendingSignal)';
}


}

/// @nodoc
abstract mixin class $GameStateCopyWith<$Res>  {
  factory $GameStateCopyWith(GameState value, $Res Function(GameState) _then) = _$GameStateCopyWithImpl;
@useResult
$Res call({
 GameStatus status, bool isPaused, int currentNLevel, int currentTrial, int totalTrials, int score, int lives, List<GameSignal> history, GameSignal? currentSignal, bool? visualMatchPressed, bool? audioMatchPressed, bool? lastTrialCorrect, int correctPositionMatches, int correctAudioMatches, int missedPositionMatches, int missedAudioMatches, int falsePositionMatches, int falseAudioMatches, int countdownValue, List<TrialResult> trialResults, int? pendingTrialNumber, GameSignal? pendingSignal
});


$GameSignalCopyWith<$Res>? get currentSignal;$GameSignalCopyWith<$Res>? get pendingSignal;

}
/// @nodoc
class _$GameStateCopyWithImpl<$Res>
    implements $GameStateCopyWith<$Res> {
  _$GameStateCopyWithImpl(this._self, this._then);

  final GameState _self;
  final $Res Function(GameState) _then;

/// Create a copy of GameState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? isPaused = null,Object? currentNLevel = null,Object? currentTrial = null,Object? totalTrials = null,Object? score = null,Object? lives = null,Object? history = null,Object? currentSignal = freezed,Object? visualMatchPressed = freezed,Object? audioMatchPressed = freezed,Object? lastTrialCorrect = freezed,Object? correctPositionMatches = null,Object? correctAudioMatches = null,Object? missedPositionMatches = null,Object? missedAudioMatches = null,Object? falsePositionMatches = null,Object? falseAudioMatches = null,Object? countdownValue = null,Object? trialResults = null,Object? pendingTrialNumber = freezed,Object? pendingSignal = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as GameStatus,isPaused: null == isPaused ? _self.isPaused : isPaused // ignore: cast_nullable_to_non_nullable
as bool,currentNLevel: null == currentNLevel ? _self.currentNLevel : currentNLevel // ignore: cast_nullable_to_non_nullable
as int,currentTrial: null == currentTrial ? _self.currentTrial : currentTrial // ignore: cast_nullable_to_non_nullable
as int,totalTrials: null == totalTrials ? _self.totalTrials : totalTrials // ignore: cast_nullable_to_non_nullable
as int,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as int,lives: null == lives ? _self.lives : lives // ignore: cast_nullable_to_non_nullable
as int,history: null == history ? _self.history : history // ignore: cast_nullable_to_non_nullable
as List<GameSignal>,currentSignal: freezed == currentSignal ? _self.currentSignal : currentSignal // ignore: cast_nullable_to_non_nullable
as GameSignal?,visualMatchPressed: freezed == visualMatchPressed ? _self.visualMatchPressed : visualMatchPressed // ignore: cast_nullable_to_non_nullable
as bool?,audioMatchPressed: freezed == audioMatchPressed ? _self.audioMatchPressed : audioMatchPressed // ignore: cast_nullable_to_non_nullable
as bool?,lastTrialCorrect: freezed == lastTrialCorrect ? _self.lastTrialCorrect : lastTrialCorrect // ignore: cast_nullable_to_non_nullable
as bool?,correctPositionMatches: null == correctPositionMatches ? _self.correctPositionMatches : correctPositionMatches // ignore: cast_nullable_to_non_nullable
as int,correctAudioMatches: null == correctAudioMatches ? _self.correctAudioMatches : correctAudioMatches // ignore: cast_nullable_to_non_nullable
as int,missedPositionMatches: null == missedPositionMatches ? _self.missedPositionMatches : missedPositionMatches // ignore: cast_nullable_to_non_nullable
as int,missedAudioMatches: null == missedAudioMatches ? _self.missedAudioMatches : missedAudioMatches // ignore: cast_nullable_to_non_nullable
as int,falsePositionMatches: null == falsePositionMatches ? _self.falsePositionMatches : falsePositionMatches // ignore: cast_nullable_to_non_nullable
as int,falseAudioMatches: null == falseAudioMatches ? _self.falseAudioMatches : falseAudioMatches // ignore: cast_nullable_to_non_nullable
as int,countdownValue: null == countdownValue ? _self.countdownValue : countdownValue // ignore: cast_nullable_to_non_nullable
as int,trialResults: null == trialResults ? _self.trialResults : trialResults // ignore: cast_nullable_to_non_nullable
as List<TrialResult>,pendingTrialNumber: freezed == pendingTrialNumber ? _self.pendingTrialNumber : pendingTrialNumber // ignore: cast_nullable_to_non_nullable
as int?,pendingSignal: freezed == pendingSignal ? _self.pendingSignal : pendingSignal // ignore: cast_nullable_to_non_nullable
as GameSignal?,
  ));
}
/// Create a copy of GameState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GameSignalCopyWith<$Res>? get currentSignal {
    if (_self.currentSignal == null) {
    return null;
  }

  return $GameSignalCopyWith<$Res>(_self.currentSignal!, (value) {
    return _then(_self.copyWith(currentSignal: value));
  });
}/// Create a copy of GameState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GameSignalCopyWith<$Res>? get pendingSignal {
    if (_self.pendingSignal == null) {
    return null;
  }

  return $GameSignalCopyWith<$Res>(_self.pendingSignal!, (value) {
    return _then(_self.copyWith(pendingSignal: value));
  });
}
}


/// Adds pattern-matching-related methods to [GameState].
extension GameStatePatterns on GameState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GameState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GameState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GameState value)  $default,){
final _that = this;
switch (_that) {
case _GameState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GameState value)?  $default,){
final _that = this;
switch (_that) {
case _GameState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( GameStatus status,  bool isPaused,  int currentNLevel,  int currentTrial,  int totalTrials,  int score,  int lives,  List<GameSignal> history,  GameSignal? currentSignal,  bool? visualMatchPressed,  bool? audioMatchPressed,  bool? lastTrialCorrect,  int correctPositionMatches,  int correctAudioMatches,  int missedPositionMatches,  int missedAudioMatches,  int falsePositionMatches,  int falseAudioMatches,  int countdownValue,  List<TrialResult> trialResults,  int? pendingTrialNumber,  GameSignal? pendingSignal)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GameState() when $default != null:
return $default(_that.status,_that.isPaused,_that.currentNLevel,_that.currentTrial,_that.totalTrials,_that.score,_that.lives,_that.history,_that.currentSignal,_that.visualMatchPressed,_that.audioMatchPressed,_that.lastTrialCorrect,_that.correctPositionMatches,_that.correctAudioMatches,_that.missedPositionMatches,_that.missedAudioMatches,_that.falsePositionMatches,_that.falseAudioMatches,_that.countdownValue,_that.trialResults,_that.pendingTrialNumber,_that.pendingSignal);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( GameStatus status,  bool isPaused,  int currentNLevel,  int currentTrial,  int totalTrials,  int score,  int lives,  List<GameSignal> history,  GameSignal? currentSignal,  bool? visualMatchPressed,  bool? audioMatchPressed,  bool? lastTrialCorrect,  int correctPositionMatches,  int correctAudioMatches,  int missedPositionMatches,  int missedAudioMatches,  int falsePositionMatches,  int falseAudioMatches,  int countdownValue,  List<TrialResult> trialResults,  int? pendingTrialNumber,  GameSignal? pendingSignal)  $default,) {final _that = this;
switch (_that) {
case _GameState():
return $default(_that.status,_that.isPaused,_that.currentNLevel,_that.currentTrial,_that.totalTrials,_that.score,_that.lives,_that.history,_that.currentSignal,_that.visualMatchPressed,_that.audioMatchPressed,_that.lastTrialCorrect,_that.correctPositionMatches,_that.correctAudioMatches,_that.missedPositionMatches,_that.missedAudioMatches,_that.falsePositionMatches,_that.falseAudioMatches,_that.countdownValue,_that.trialResults,_that.pendingTrialNumber,_that.pendingSignal);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( GameStatus status,  bool isPaused,  int currentNLevel,  int currentTrial,  int totalTrials,  int score,  int lives,  List<GameSignal> history,  GameSignal? currentSignal,  bool? visualMatchPressed,  bool? audioMatchPressed,  bool? lastTrialCorrect,  int correctPositionMatches,  int correctAudioMatches,  int missedPositionMatches,  int missedAudioMatches,  int falsePositionMatches,  int falseAudioMatches,  int countdownValue,  List<TrialResult> trialResults,  int? pendingTrialNumber,  GameSignal? pendingSignal)?  $default,) {final _that = this;
switch (_that) {
case _GameState() when $default != null:
return $default(_that.status,_that.isPaused,_that.currentNLevel,_that.currentTrial,_that.totalTrials,_that.score,_that.lives,_that.history,_that.currentSignal,_that.visualMatchPressed,_that.audioMatchPressed,_that.lastTrialCorrect,_that.correctPositionMatches,_that.correctAudioMatches,_that.missedPositionMatches,_that.missedAudioMatches,_that.falsePositionMatches,_that.falseAudioMatches,_that.countdownValue,_that.trialResults,_that.pendingTrialNumber,_that.pendingSignal);case _:
  return null;

}
}

}

/// @nodoc


class _GameState implements GameState {
  const _GameState({this.status = GameStatus.initial, this.isPaused = false, this.currentNLevel = 0, this.currentTrial = 0, this.totalTrials = 0, this.score = 0, this.lives = 0, final  List<GameSignal> history = const [], this.currentSignal, this.visualMatchPressed, this.audioMatchPressed, this.lastTrialCorrect, this.correctPositionMatches = 0, this.correctAudioMatches = 0, this.missedPositionMatches = 0, this.missedAudioMatches = 0, this.falsePositionMatches = 0, this.falseAudioMatches = 0, this.countdownValue = 3, final  List<TrialResult> trialResults = const [], this.pendingTrialNumber, this.pendingSignal}): _history = history,_trialResults = trialResults;
  

@override@JsonKey() final  GameStatus status;
@override@JsonKey() final  bool isPaused;
@override@JsonKey() final  int currentNLevel;
@override@JsonKey() final  int currentTrial;
@override@JsonKey() final  int totalTrials;
@override@JsonKey() final  int score;
@override@JsonKey() final  int lives;
// Optional, maybe not needed per specs, but useful
// The history of signals in this session
 final  List<GameSignal> _history;
// Optional, maybe not needed per specs, but useful
// The history of signals in this session
@override@JsonKey() List<GameSignal> get history {
  if (_history is EqualUnmodifiableListView) return _history;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_history);
}

// The current signal being presented (null if in between or not started)
@override final  GameSignal? currentSignal;
// User feedback for the current trial
@override final  bool? visualMatchPressed;
@override final  bool? audioMatchPressed;
// Result of the current trial
@override final  bool? lastTrialCorrect;
// For UI feedback (green/red flash)
// Detailed stats
@override@JsonKey() final  int correctPositionMatches;
@override@JsonKey() final  int correctAudioMatches;
@override@JsonKey() final  int missedPositionMatches;
@override@JsonKey() final  int missedAudioMatches;
@override@JsonKey() final  int falsePositionMatches;
@override@JsonKey() final  int falseAudioMatches;
// Countdown
// Countdown
@override@JsonKey() final  int countdownValue;
// Debug Data
 final  List<TrialResult> _trialResults;
// Debug Data
@override@JsonKey() List<TrialResult> get trialResults {
  if (_trialResults is EqualUnmodifiableListView) return _trialResults;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_trialResults);
}

// Pending row: set when a trial begins (before evaluation)
@override final  int? pendingTrialNumber;
@override final  GameSignal? pendingSignal;

/// Create a copy of GameState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GameStateCopyWith<_GameState> get copyWith => __$GameStateCopyWithImpl<_GameState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GameState&&(identical(other.status, status) || other.status == status)&&(identical(other.isPaused, isPaused) || other.isPaused == isPaused)&&(identical(other.currentNLevel, currentNLevel) || other.currentNLevel == currentNLevel)&&(identical(other.currentTrial, currentTrial) || other.currentTrial == currentTrial)&&(identical(other.totalTrials, totalTrials) || other.totalTrials == totalTrials)&&(identical(other.score, score) || other.score == score)&&(identical(other.lives, lives) || other.lives == lives)&&const DeepCollectionEquality().equals(other._history, _history)&&(identical(other.currentSignal, currentSignal) || other.currentSignal == currentSignal)&&(identical(other.visualMatchPressed, visualMatchPressed) || other.visualMatchPressed == visualMatchPressed)&&(identical(other.audioMatchPressed, audioMatchPressed) || other.audioMatchPressed == audioMatchPressed)&&(identical(other.lastTrialCorrect, lastTrialCorrect) || other.lastTrialCorrect == lastTrialCorrect)&&(identical(other.correctPositionMatches, correctPositionMatches) || other.correctPositionMatches == correctPositionMatches)&&(identical(other.correctAudioMatches, correctAudioMatches) || other.correctAudioMatches == correctAudioMatches)&&(identical(other.missedPositionMatches, missedPositionMatches) || other.missedPositionMatches == missedPositionMatches)&&(identical(other.missedAudioMatches, missedAudioMatches) || other.missedAudioMatches == missedAudioMatches)&&(identical(other.falsePositionMatches, falsePositionMatches) || other.falsePositionMatches == falsePositionMatches)&&(identical(other.falseAudioMatches, falseAudioMatches) || other.falseAudioMatches == falseAudioMatches)&&(identical(other.countdownValue, countdownValue) || other.countdownValue == countdownValue)&&const DeepCollectionEquality().equals(other._trialResults, _trialResults)&&(identical(other.pendingTrialNumber, pendingTrialNumber) || other.pendingTrialNumber == pendingTrialNumber)&&(identical(other.pendingSignal, pendingSignal) || other.pendingSignal == pendingSignal));
}


@override
int get hashCode => Object.hashAll([runtimeType,status,isPaused,currentNLevel,currentTrial,totalTrials,score,lives,const DeepCollectionEquality().hash(_history),currentSignal,visualMatchPressed,audioMatchPressed,lastTrialCorrect,correctPositionMatches,correctAudioMatches,missedPositionMatches,missedAudioMatches,falsePositionMatches,falseAudioMatches,countdownValue,const DeepCollectionEquality().hash(_trialResults),pendingTrialNumber,pendingSignal]);

@override
String toString() {
  return 'GameState(status: $status, isPaused: $isPaused, currentNLevel: $currentNLevel, currentTrial: $currentTrial, totalTrials: $totalTrials, score: $score, lives: $lives, history: $history, currentSignal: $currentSignal, visualMatchPressed: $visualMatchPressed, audioMatchPressed: $audioMatchPressed, lastTrialCorrect: $lastTrialCorrect, correctPositionMatches: $correctPositionMatches, correctAudioMatches: $correctAudioMatches, missedPositionMatches: $missedPositionMatches, missedAudioMatches: $missedAudioMatches, falsePositionMatches: $falsePositionMatches, falseAudioMatches: $falseAudioMatches, countdownValue: $countdownValue, trialResults: $trialResults, pendingTrialNumber: $pendingTrialNumber, pendingSignal: $pendingSignal)';
}


}

/// @nodoc
abstract mixin class _$GameStateCopyWith<$Res> implements $GameStateCopyWith<$Res> {
  factory _$GameStateCopyWith(_GameState value, $Res Function(_GameState) _then) = __$GameStateCopyWithImpl;
@override @useResult
$Res call({
 GameStatus status, bool isPaused, int currentNLevel, int currentTrial, int totalTrials, int score, int lives, List<GameSignal> history, GameSignal? currentSignal, bool? visualMatchPressed, bool? audioMatchPressed, bool? lastTrialCorrect, int correctPositionMatches, int correctAudioMatches, int missedPositionMatches, int missedAudioMatches, int falsePositionMatches, int falseAudioMatches, int countdownValue, List<TrialResult> trialResults, int? pendingTrialNumber, GameSignal? pendingSignal
});


@override $GameSignalCopyWith<$Res>? get currentSignal;@override $GameSignalCopyWith<$Res>? get pendingSignal;

}
/// @nodoc
class __$GameStateCopyWithImpl<$Res>
    implements _$GameStateCopyWith<$Res> {
  __$GameStateCopyWithImpl(this._self, this._then);

  final _GameState _self;
  final $Res Function(_GameState) _then;

/// Create a copy of GameState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? isPaused = null,Object? currentNLevel = null,Object? currentTrial = null,Object? totalTrials = null,Object? score = null,Object? lives = null,Object? history = null,Object? currentSignal = freezed,Object? visualMatchPressed = freezed,Object? audioMatchPressed = freezed,Object? lastTrialCorrect = freezed,Object? correctPositionMatches = null,Object? correctAudioMatches = null,Object? missedPositionMatches = null,Object? missedAudioMatches = null,Object? falsePositionMatches = null,Object? falseAudioMatches = null,Object? countdownValue = null,Object? trialResults = null,Object? pendingTrialNumber = freezed,Object? pendingSignal = freezed,}) {
  return _then(_GameState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as GameStatus,isPaused: null == isPaused ? _self.isPaused : isPaused // ignore: cast_nullable_to_non_nullable
as bool,currentNLevel: null == currentNLevel ? _self.currentNLevel : currentNLevel // ignore: cast_nullable_to_non_nullable
as int,currentTrial: null == currentTrial ? _self.currentTrial : currentTrial // ignore: cast_nullable_to_non_nullable
as int,totalTrials: null == totalTrials ? _self.totalTrials : totalTrials // ignore: cast_nullable_to_non_nullable
as int,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as int,lives: null == lives ? _self.lives : lives // ignore: cast_nullable_to_non_nullable
as int,history: null == history ? _self._history : history // ignore: cast_nullable_to_non_nullable
as List<GameSignal>,currentSignal: freezed == currentSignal ? _self.currentSignal : currentSignal // ignore: cast_nullable_to_non_nullable
as GameSignal?,visualMatchPressed: freezed == visualMatchPressed ? _self.visualMatchPressed : visualMatchPressed // ignore: cast_nullable_to_non_nullable
as bool?,audioMatchPressed: freezed == audioMatchPressed ? _self.audioMatchPressed : audioMatchPressed // ignore: cast_nullable_to_non_nullable
as bool?,lastTrialCorrect: freezed == lastTrialCorrect ? _self.lastTrialCorrect : lastTrialCorrect // ignore: cast_nullable_to_non_nullable
as bool?,correctPositionMatches: null == correctPositionMatches ? _self.correctPositionMatches : correctPositionMatches // ignore: cast_nullable_to_non_nullable
as int,correctAudioMatches: null == correctAudioMatches ? _self.correctAudioMatches : correctAudioMatches // ignore: cast_nullable_to_non_nullable
as int,missedPositionMatches: null == missedPositionMatches ? _self.missedPositionMatches : missedPositionMatches // ignore: cast_nullable_to_non_nullable
as int,missedAudioMatches: null == missedAudioMatches ? _self.missedAudioMatches : missedAudioMatches // ignore: cast_nullable_to_non_nullable
as int,falsePositionMatches: null == falsePositionMatches ? _self.falsePositionMatches : falsePositionMatches // ignore: cast_nullable_to_non_nullable
as int,falseAudioMatches: null == falseAudioMatches ? _self.falseAudioMatches : falseAudioMatches // ignore: cast_nullable_to_non_nullable
as int,countdownValue: null == countdownValue ? _self.countdownValue : countdownValue // ignore: cast_nullable_to_non_nullable
as int,trialResults: null == trialResults ? _self._trialResults : trialResults // ignore: cast_nullable_to_non_nullable
as List<TrialResult>,pendingTrialNumber: freezed == pendingTrialNumber ? _self.pendingTrialNumber : pendingTrialNumber // ignore: cast_nullable_to_non_nullable
as int?,pendingSignal: freezed == pendingSignal ? _self.pendingSignal : pendingSignal // ignore: cast_nullable_to_non_nullable
as GameSignal?,
  ));
}

/// Create a copy of GameState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GameSignalCopyWith<$Res>? get currentSignal {
    if (_self.currentSignal == null) {
    return null;
  }

  return $GameSignalCopyWith<$Res>(_self.currentSignal!, (value) {
    return _then(_self.copyWith(currentSignal: value));
  });
}/// Create a copy of GameState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GameSignalCopyWith<$Res>? get pendingSignal {
    if (_self.pendingSignal == null) {
    return null;
  }

  return $GameSignalCopyWith<$Res>(_self.pendingSignal!, (value) {
    return _then(_self.copyWith(pendingSignal: value));
  });
}
}

/// @nodoc
mixin _$TrialResult {

 int get trialNumber;// 1-based
 int get positionIndex; String get audioLetter; bool get isPositionMatch; bool get isAudioMatch; bool get userPositionPressed; bool get userAudioPressed; int get positionScore;// 1, 0, -1
 int get audioScore;// 1, 0, -1
 int get totalScore;
/// Create a copy of TrialResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrialResultCopyWith<TrialResult> get copyWith => _$TrialResultCopyWithImpl<TrialResult>(this as TrialResult, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrialResult&&(identical(other.trialNumber, trialNumber) || other.trialNumber == trialNumber)&&(identical(other.positionIndex, positionIndex) || other.positionIndex == positionIndex)&&(identical(other.audioLetter, audioLetter) || other.audioLetter == audioLetter)&&(identical(other.isPositionMatch, isPositionMatch) || other.isPositionMatch == isPositionMatch)&&(identical(other.isAudioMatch, isAudioMatch) || other.isAudioMatch == isAudioMatch)&&(identical(other.userPositionPressed, userPositionPressed) || other.userPositionPressed == userPositionPressed)&&(identical(other.userAudioPressed, userAudioPressed) || other.userAudioPressed == userAudioPressed)&&(identical(other.positionScore, positionScore) || other.positionScore == positionScore)&&(identical(other.audioScore, audioScore) || other.audioScore == audioScore)&&(identical(other.totalScore, totalScore) || other.totalScore == totalScore));
}


@override
int get hashCode => Object.hash(runtimeType,trialNumber,positionIndex,audioLetter,isPositionMatch,isAudioMatch,userPositionPressed,userAudioPressed,positionScore,audioScore,totalScore);

@override
String toString() {
  return 'TrialResult(trialNumber: $trialNumber, positionIndex: $positionIndex, audioLetter: $audioLetter, isPositionMatch: $isPositionMatch, isAudioMatch: $isAudioMatch, userPositionPressed: $userPositionPressed, userAudioPressed: $userAudioPressed, positionScore: $positionScore, audioScore: $audioScore, totalScore: $totalScore)';
}


}

/// @nodoc
abstract mixin class $TrialResultCopyWith<$Res>  {
  factory $TrialResultCopyWith(TrialResult value, $Res Function(TrialResult) _then) = _$TrialResultCopyWithImpl;
@useResult
$Res call({
 int trialNumber, int positionIndex, String audioLetter, bool isPositionMatch, bool isAudioMatch, bool userPositionPressed, bool userAudioPressed, int positionScore, int audioScore, int totalScore
});




}
/// @nodoc
class _$TrialResultCopyWithImpl<$Res>
    implements $TrialResultCopyWith<$Res> {
  _$TrialResultCopyWithImpl(this._self, this._then);

  final TrialResult _self;
  final $Res Function(TrialResult) _then;

/// Create a copy of TrialResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? trialNumber = null,Object? positionIndex = null,Object? audioLetter = null,Object? isPositionMatch = null,Object? isAudioMatch = null,Object? userPositionPressed = null,Object? userAudioPressed = null,Object? positionScore = null,Object? audioScore = null,Object? totalScore = null,}) {
  return _then(_self.copyWith(
trialNumber: null == trialNumber ? _self.trialNumber : trialNumber // ignore: cast_nullable_to_non_nullable
as int,positionIndex: null == positionIndex ? _self.positionIndex : positionIndex // ignore: cast_nullable_to_non_nullable
as int,audioLetter: null == audioLetter ? _self.audioLetter : audioLetter // ignore: cast_nullable_to_non_nullable
as String,isPositionMatch: null == isPositionMatch ? _self.isPositionMatch : isPositionMatch // ignore: cast_nullable_to_non_nullable
as bool,isAudioMatch: null == isAudioMatch ? _self.isAudioMatch : isAudioMatch // ignore: cast_nullable_to_non_nullable
as bool,userPositionPressed: null == userPositionPressed ? _self.userPositionPressed : userPositionPressed // ignore: cast_nullable_to_non_nullable
as bool,userAudioPressed: null == userAudioPressed ? _self.userAudioPressed : userAudioPressed // ignore: cast_nullable_to_non_nullable
as bool,positionScore: null == positionScore ? _self.positionScore : positionScore // ignore: cast_nullable_to_non_nullable
as int,audioScore: null == audioScore ? _self.audioScore : audioScore // ignore: cast_nullable_to_non_nullable
as int,totalScore: null == totalScore ? _self.totalScore : totalScore // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [TrialResult].
extension TrialResultPatterns on TrialResult {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrialResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrialResult() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrialResult value)  $default,){
final _that = this;
switch (_that) {
case _TrialResult():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrialResult value)?  $default,){
final _that = this;
switch (_that) {
case _TrialResult() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int trialNumber,  int positionIndex,  String audioLetter,  bool isPositionMatch,  bool isAudioMatch,  bool userPositionPressed,  bool userAudioPressed,  int positionScore,  int audioScore,  int totalScore)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrialResult() when $default != null:
return $default(_that.trialNumber,_that.positionIndex,_that.audioLetter,_that.isPositionMatch,_that.isAudioMatch,_that.userPositionPressed,_that.userAudioPressed,_that.positionScore,_that.audioScore,_that.totalScore);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int trialNumber,  int positionIndex,  String audioLetter,  bool isPositionMatch,  bool isAudioMatch,  bool userPositionPressed,  bool userAudioPressed,  int positionScore,  int audioScore,  int totalScore)  $default,) {final _that = this;
switch (_that) {
case _TrialResult():
return $default(_that.trialNumber,_that.positionIndex,_that.audioLetter,_that.isPositionMatch,_that.isAudioMatch,_that.userPositionPressed,_that.userAudioPressed,_that.positionScore,_that.audioScore,_that.totalScore);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int trialNumber,  int positionIndex,  String audioLetter,  bool isPositionMatch,  bool isAudioMatch,  bool userPositionPressed,  bool userAudioPressed,  int positionScore,  int audioScore,  int totalScore)?  $default,) {final _that = this;
switch (_that) {
case _TrialResult() when $default != null:
return $default(_that.trialNumber,_that.positionIndex,_that.audioLetter,_that.isPositionMatch,_that.isAudioMatch,_that.userPositionPressed,_that.userAudioPressed,_that.positionScore,_that.audioScore,_that.totalScore);case _:
  return null;

}
}

}

/// @nodoc


class _TrialResult implements TrialResult {
  const _TrialResult({required this.trialNumber, required this.positionIndex, required this.audioLetter, required this.isPositionMatch, required this.isAudioMatch, required this.userPositionPressed, required this.userAudioPressed, required this.positionScore, required this.audioScore, required this.totalScore});
  

@override final  int trialNumber;
// 1-based
@override final  int positionIndex;
@override final  String audioLetter;
@override final  bool isPositionMatch;
@override final  bool isAudioMatch;
@override final  bool userPositionPressed;
@override final  bool userAudioPressed;
@override final  int positionScore;
// 1, 0, -1
@override final  int audioScore;
// 1, 0, -1
@override final  int totalScore;

/// Create a copy of TrialResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrialResultCopyWith<_TrialResult> get copyWith => __$TrialResultCopyWithImpl<_TrialResult>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrialResult&&(identical(other.trialNumber, trialNumber) || other.trialNumber == trialNumber)&&(identical(other.positionIndex, positionIndex) || other.positionIndex == positionIndex)&&(identical(other.audioLetter, audioLetter) || other.audioLetter == audioLetter)&&(identical(other.isPositionMatch, isPositionMatch) || other.isPositionMatch == isPositionMatch)&&(identical(other.isAudioMatch, isAudioMatch) || other.isAudioMatch == isAudioMatch)&&(identical(other.userPositionPressed, userPositionPressed) || other.userPositionPressed == userPositionPressed)&&(identical(other.userAudioPressed, userAudioPressed) || other.userAudioPressed == userAudioPressed)&&(identical(other.positionScore, positionScore) || other.positionScore == positionScore)&&(identical(other.audioScore, audioScore) || other.audioScore == audioScore)&&(identical(other.totalScore, totalScore) || other.totalScore == totalScore));
}


@override
int get hashCode => Object.hash(runtimeType,trialNumber,positionIndex,audioLetter,isPositionMatch,isAudioMatch,userPositionPressed,userAudioPressed,positionScore,audioScore,totalScore);

@override
String toString() {
  return 'TrialResult(trialNumber: $trialNumber, positionIndex: $positionIndex, audioLetter: $audioLetter, isPositionMatch: $isPositionMatch, isAudioMatch: $isAudioMatch, userPositionPressed: $userPositionPressed, userAudioPressed: $userAudioPressed, positionScore: $positionScore, audioScore: $audioScore, totalScore: $totalScore)';
}


}

/// @nodoc
abstract mixin class _$TrialResultCopyWith<$Res> implements $TrialResultCopyWith<$Res> {
  factory _$TrialResultCopyWith(_TrialResult value, $Res Function(_TrialResult) _then) = __$TrialResultCopyWithImpl;
@override @useResult
$Res call({
 int trialNumber, int positionIndex, String audioLetter, bool isPositionMatch, bool isAudioMatch, bool userPositionPressed, bool userAudioPressed, int positionScore, int audioScore, int totalScore
});




}
/// @nodoc
class __$TrialResultCopyWithImpl<$Res>
    implements _$TrialResultCopyWith<$Res> {
  __$TrialResultCopyWithImpl(this._self, this._then);

  final _TrialResult _self;
  final $Res Function(_TrialResult) _then;

/// Create a copy of TrialResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? trialNumber = null,Object? positionIndex = null,Object? audioLetter = null,Object? isPositionMatch = null,Object? isAudioMatch = null,Object? userPositionPressed = null,Object? userAudioPressed = null,Object? positionScore = null,Object? audioScore = null,Object? totalScore = null,}) {
  return _then(_TrialResult(
trialNumber: null == trialNumber ? _self.trialNumber : trialNumber // ignore: cast_nullable_to_non_nullable
as int,positionIndex: null == positionIndex ? _self.positionIndex : positionIndex // ignore: cast_nullable_to_non_nullable
as int,audioLetter: null == audioLetter ? _self.audioLetter : audioLetter // ignore: cast_nullable_to_non_nullable
as String,isPositionMatch: null == isPositionMatch ? _self.isPositionMatch : isPositionMatch // ignore: cast_nullable_to_non_nullable
as bool,isAudioMatch: null == isAudioMatch ? _self.isAudioMatch : isAudioMatch // ignore: cast_nullable_to_non_nullable
as bool,userPositionPressed: null == userPositionPressed ? _self.userPositionPressed : userPositionPressed // ignore: cast_nullable_to_non_nullable
as bool,userAudioPressed: null == userAudioPressed ? _self.userAudioPressed : userAudioPressed // ignore: cast_nullable_to_non_nullable
as bool,positionScore: null == positionScore ? _self.positionScore : positionScore // ignore: cast_nullable_to_non_nullable
as int,audioScore: null == audioScore ? _self.audioScore : audioScore // ignore: cast_nullable_to_non_nullable
as int,totalScore: null == totalScore ? _self.totalScore : totalScore // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
