import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Data model for a detailed high score entry
class HighScoreData {
  final int score;
  final double accuracy; // Points per second
  final int timeUsed; // Seconds
  final String characterName;
  final DateTime date;

  HighScoreData({
    required this.score,
    required this.accuracy,
    required this.timeUsed,
    required this.characterName,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'score': score,
        'accuracy': accuracy,
        'timeUsed': timeUsed,
        'characterName': characterName,
        'date': date.toIso8601String(),
      };

  factory HighScoreData.fromJson(Map<String, dynamic> json) {
    return HighScoreData(
      score: json['score'] as int,
      accuracy: (json['accuracy'] as num).toDouble(),
      timeUsed: json['timeUsed'] as int,
      characterName: json['characterName'] as String,
      date: DateTime.parse(json['date'] as String),
    );
  }
}

class HighScoreService {
  static const String _keyPrefix = 'highscore_v2_';
  // Legacy key prefix for backward compatibility check
  static const String _legacyKeyPrefix = 'highscore_';

  /// Saves a detailed score for a specific level if it's higher than the current high score.
  /// Returns true if a new high score was set.
  static Future<bool> saveScore({
    required String level,
    required int score,
    required double accuracy,
    required int timeUsed,
    required String characterName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyPrefix$level';
    
    // Check current high score
    final currentData = await getHighScoreData(level);
    final currentScore = currentData?.score ?? 0;

    // Check legacy score if new format doesn't exist
    int legacyScore = 0;
    if (currentData == null) {
      legacyScore = prefs.getInt('$_legacyKeyPrefix$level') ?? 0;
    }

    final bestPreviousScore = currentScore > legacyScore ? currentScore : legacyScore;

    if (score > bestPreviousScore) {
      final newData = HighScoreData(
        score: score,
        accuracy: accuracy,
        timeUsed: timeUsed,
        characterName: characterName,
        date: DateTime.now(),
      );
      
      await prefs.setString(key, jsonEncode(newData.toJson()));
      return true;
    }
    return false;
  }

  /// Gets the detailed high score data for a specific level.
  static Future<HighScoreData?> getHighScoreData(String level) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyPrefix$level';
    final jsonString = prefs.getString(key);
    
    if (jsonString != null) {
      try {
        return HighScoreData.fromJson(jsonDecode(jsonString));
      } catch (e) {
        // Fallback or error handling if JSON is corrupt
        return null;
      }
    }
    
    // Fallback: Check for legacy int score and convert it to a basic data object
    final legacyKey = '$_legacyKeyPrefix$level';
    final legacyScore = prefs.getInt(legacyKey);
    if (legacyScore != null && legacyScore > 0) {
      return HighScoreData(
        score: legacyScore,
        accuracy: 0,
        timeUsed: 0,
        characterName: 'Unknown',
        date: DateTime.now(), // Estimate
      );
    }

    return null;
  }

  /// Gets just the score integer (for backward compatibility / quick access).
  static Future<int> getHighScore(String level) async {
    final data = await getHighScoreData(level);
    return data?.score ?? 0;
  }

  /// Gets full high score data for all levels.
  static Future<Map<String, HighScoreData?>> getAllHighScores(List<String> levels) async {
    final Map<String, HighScoreData?> scores = {};
    for (final level in levels) {
      scores[level] = await getHighScoreData(level);
    }
    return scores;
  }
}
