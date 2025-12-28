import 'package:shared_preferences/shared_preferences.dart';

class HighScoreService {
  static const String _keyPrefix = 'highscore_';

  /// Saves a score for a specific level if it's higher than the current high score.
  /// Returns true if a new high score was set.
  static Future<bool> saveScore(String level, int score) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyPrefix$level';
    final currentHighScore = prefs.getInt(key) ?? 0;

    if (score > currentHighScore) {
      await prefs.setInt(key, score);
      return true;
    }
    return false;
  }

  /// Gets the high score for a specific level.
  static Future<int> getHighScore(String level) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyPrefix$level';
    return prefs.getInt(key) ?? 0;
  }

  /// Gets high scores for all levels.
  static Future<Map<String, int>> getAllHighScores(List<String> levels) async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, int> scores = {};
    
    for (final level in levels) {
      final key = '$_keyPrefix$level';
      scores[level] = prefs.getInt(key) ?? 0;
    }
    
    return scores;
  }
}
