import 'dart:math';
import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/collisions.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

// Target configurations with icons and colors
class TargetConfig {
  final IconData icon;
  final Color color;
  final int value;
  final double duration;
  final bool isPositive;
  final double size; // Icon size
  final int timeBonus; // Seconds to add/subtract from time (0 = no time effect)
  final String name; // Display name for the target

  const TargetConfig({
    required this.icon,
    required this.color,
    required this.value,
    required this.duration,
    required this.isPositive,
    required this.size,
    this.timeBonus = 0,
    required this.name,
  });
}

// All available targets
class TargetConfigs {
  // Pre-cached lists by value for performance (avoid repeated .where().toList())
  static final List<TargetConfig> _positive5 = positive.where((t) => t.value == 5).toList();
  static final List<TargetConfig> _positive10 = positive.where((t) => t.value == 10).toList();
  static final List<TargetConfig> _positive20 = positive.where((t) => t.value == 20).toList();
  static final List<TargetConfig> _positive30 = positive.where((t) => t.value == 30).toList();
  static final List<TargetConfig> _positive40 = positive.where((t) => t.value == 40).toList();
  static final List<TargetConfig> _positive50 = positive.where((t) => t.value == 50).toList();
  static final List<TargetConfig> _positiveTimeBonus = positive.where((t) => t.timeBonus > 0).toList();
  
  static final List<TargetConfig> _negative10 = negative.where((t) => t.value == -10).toList();
  static final List<TargetConfig> _negative30 = negative.where((t) => t.value == -30).toList();
  static final List<TargetConfig> _negative50 = negative.where((t) => t.value == -50).toList();
  static final List<TargetConfig> _negative100 = negative.where((t) => t.value == -100).toList();
  static final List<TargetConfig> _negativeTimePenalty = negative.where((t) => t.timeBonus < 0).toList();

  // Positive targets (sorted by value) - Higher value = bigger
  static const List<TargetConfig> positive = [
    // Low value (5 pts)
    TargetConfig(
      icon: Icons.eco,
      color: Color(0xFF8BC34A),
      value: 5,
      duration: 2.2,
      isPositive: true,
      size: 64,
      name: 'Fruits',
    ),
    TargetConfig(
      icon: Icons.sports_bar,
      color: Color(0xFFFFB300),
      value: 5,
      duration: 2.2,
      isPositive: true,
      size: 64,
      name: 'Beer',
    ),
    // Medium-low value (10 pts)
    TargetConfig(
      icon: Icons.favorite,
      color: Color(0xFFE91E63),
      value: 10,
      duration: 2.0,
      isPositive: true,
      size: 68,
      name: 'Heart',
    ),
    TargetConfig(
      icon: Icons.baby_changing_station,
      color: Color(0xFF81D4FA),
      value: 10,
      duration: 2.0,
      isPositive: true,
      size: 68,
      name: 'Baby Bottle',
    ),
    TargetConfig(
      icon: Icons.apple,
      color: Color(0xFFE53935),
      value: 10,
      duration: 2.0,
      isPositive: true,
      size: 68,
      name: 'Apple',
    ),
    // Medium value (20 pts)
    TargetConfig(
      icon: Icons.star,
      color: Color(0xFFFFEB3B),
      value: 20,
      duration: 1.7,
      isPositive: true,
      size: 76,
      name: 'Star',
    ),
    TargetConfig(
      icon: Icons.water_drop,
      color: Color(0xFF29B6F6),
      value: 20,
      duration: 1.7,
      isPositive: true,
      size: 76,
      name: 'Water',
    ),
    TargetConfig(
      icon: Icons.cruelty_free,
      color: Color(0xFFFFB6C1),
      value: 20,
      duration: 1.7,
      isPositive: true,
      size: 76,
      name: 'Bunny',
    ),
    // Medium-high value (30-40 pts)
    TargetConfig(
      icon: Icons.auto_awesome,
      color: Color(0xFF00BCD4),
      value: 30,
      duration: 1.4,
      isPositive: true,
      size: 84,
      name: 'Sparkle',
    ),
    TargetConfig(
      icon: Icons.emoji_events,
      color: Color(0xFFFF9800),
      value: 40,
      duration: 1.1,
      isPositive: true,
      size: 92,
      name: 'Trophy',
    ),
    // High value (50 pts)
    TargetConfig(
      icon: Icons.diamond,
      color: Color(0xFF9C27B0),
      value: 50,
      duration: 0.8,
      isPositive: true,
      size: 100,
      name: 'Diamond',
    ),
    // Time bonus targets
    TargetConfig(
      icon: Icons.schedule,
      color: Color(0xFF4CAF50),
      value: 0,
      duration: 1.5,
      isPositive: true,
      size: 80,
      timeBonus: 10,
      name: 'Clock +10s',
    ),
  ];

  // Negative targets (sorted by value) - Higher penalty = bigger (easier to accidentally hit!)
  static const List<TargetConfig> negative = [
    // Low penalty (-10 pts)
    TargetConfig(
      icon: Icons.push_pin,
      color: Color(0xFFE53935),
      value: -10,
      duration: 2.5,
      isPositive: false,
      size: 72,
      name: 'Thumbtack',
    ),
    // Medium penalty (-30 pts)
    TargetConfig(
      icon: Icons.cancel,
      color: Color(0xFFE53935),
      value: -30,
      duration: 2.2,
      isPositive: false,
      size: 80,
      name: 'Cancel',
    ),
    TargetConfig(
      icon: Icons.coronavirus,
      color: Color(0xFF7B1FA2),
      value: -30,
      duration: 2.2,
      isPositive: false,
      size: 80,
      name: 'Poison',
    ),
    TargetConfig(
      icon: Icons.dangerous,
      color: Color(0xFFFF5722),
      value: -30,
      duration: 2.0,
      isPositive: false,
      size: 84,
      name: 'Bomb',
    ),
    TargetConfig(
      icon: Icons.warning,
      color: Color(0xFFD32F2F), // Red
      value: -30,
      duration: 2.0,
      isPositive: false,
      size: 84,
      name: 'Hazard',
    ),
    // High penalty (-50 pts)
    TargetConfig(
      icon: Icons.smoking_rooms,
      color: Color(0xFF757575),
      value: -50,
      duration: 1.8,
      isPositive: false,
      size: 88,
      name: 'Cigarette',
    ),
    TargetConfig(
      icon: Icons.pest_control,
      color: Color(0xFF795548),
      value: -50,
      duration: 1.8,
      isPositive: false,
      size: 88,
      name: 'Rat',
    ),
    TargetConfig(
      icon: Icons.local_fire_department,
      color: Color(0xFFD32F2F),
      value: -50,
      duration: 1.8,
      isPositive: false,
      size: 88,
      name: 'Fire',
    ),
    // Very high penalty (-100 pts)
    TargetConfig(
      icon: Icons.no_food,
      color: Color(0xFF5D4037),
      value: -100,
      duration: 1.5,
      isPositive: false,
      size: 96,
      name: 'Rotten Food',
    ),
    // Time penalty targets
    TargetConfig(
      icon: Icons.timer_off,
      color: Color(0xFFD32F2F),
      value: 0,
      duration: 2.0,
      isPositive: false,
      size: 80,
      timeBonus: -10,
      name: 'Clock -10s',
    ),
  ];
}

// Component that renders a Material Icon in Flame
class IconComponent extends PositionComponent {
  final IconData icon;
  final Color color;
  final double iconSize;
  ui.Picture? _cachedPicture;

  IconComponent({
    required this.icon,
    required this.color,
    this.iconSize = 48,
    super.position,
    super.anchor,
    super.priority,
  }) : super(size: Vector2.all(iconSize));

  @override
  Future<void> onLoad() async {
    // Pre-render the icon to a picture for better performance
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final textPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: iconSize,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          color: color,
          shadows: [
            Shadow(
              color: Colors.black.withOpacity(0.3),
              offset: const Offset(2, 2),
              blurRadius: 4,
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset.zero);

    _cachedPicture = recorder.endRecording();
  }

  @override
  void render(Canvas canvas) {
    if (_cachedPicture != null) {
      canvas.drawPicture(_cachedPicture!);
    }
  }
}

// Types of targets
enum TargetType { positive, negative }

// Simple Material-style tappable button with icon
class TappableButton extends PositionComponent with TapCallbacks {
  final void Function() onTap;
  final Color bgColor;
  final IconData icon;
  final Color iconColor;
  final double buttonSize;
  bool _isPressed = false;
  ui.Picture? _cachedIcon;

  TappableButton({
    required Vector2 position,
    required this.onTap,
    required this.bgColor,
    required this.icon,
    required this.iconColor,
    this.buttonSize = 44,
  }) : super(
         position: position,
         size: Vector2.all(buttonSize),
         anchor: Anchor.topLeft,
         priority: 10,
       );

  @override
  Future<void> onLoad() async {
    // Pre-render the icon to a picture for better performance
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final iconSize = buttonSize * 0.6;

    final textPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: iconSize,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          color: iconColor,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset.zero);

    _cachedIcon = recorder.endRecording();
    
    // Pre-cache paints and geometry
    _buttonRect = Rect.fromLTWH(0, 0, buttonSize, buttonSize);
    _buttonRRect = RRect.fromRectAndRadius(_buttonRect!, Radius.circular(buttonSize / 2));
    _bgPaint = Paint()..color = bgColor;
    _bgPaintPressed = Paint()..color = bgColor.withOpacity(0.7);
    _borderPaint = Paint()
      ..color = iconColor.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    _iconOffset = (buttonSize - buttonSize * 0.6) / 2;
  }

  // Cached render objects
  Rect? _buttonRect;
  RRect? _buttonRRect;
  Paint? _bgPaint;
  Paint? _bgPaintPressed;
  Paint? _borderPaint;
  double _iconOffset = 0;

  @override
  void render(Canvas canvas) {
    if (_buttonRRect == null) return;
    
    // Draw circular background using cached paint
    canvas.drawRRect(_buttonRRect!, _isPressed ? _bgPaintPressed! : _bgPaint!);

    // Draw border using cached paint
    canvas.drawRRect(_buttonRRect!, _borderPaint!);

    // Draw icon centered
    if (_cachedIcon != null) {
      canvas.save();
      canvas.translate(_iconOffset, _iconOffset);
      canvas.drawPicture(_cachedIcon!);
      canvas.restore();
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    _isPressed = true;
  }

  @override
  void onTapUp(TapUpEvent event) {
    _isPressed = false;
    onTap();
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    _isPressed = false;
  }
}

// Score panel background component
class ScorePanel extends PositionComponent {
  final Color bgColor;
  final double panelWidth;
  final double panelHeight;
  final double borderRadius;

  ScorePanel({
    required Vector2 position,
    required this.bgColor,
    required this.panelWidth,
    required this.panelHeight,
    this.borderRadius = 12,
  }) : super(
         position: position,
         size: Vector2(panelWidth, panelHeight),
         anchor: Anchor.topLeft,
         priority: 5,
       );

  // Cached render objects
  RRect? _cachedRRect;
  Paint? _cachedBgPaint;
  Paint? _cachedBorderPaint;

  @override
  Future<void> onLoad() async {
    // Pre-cache all render objects
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    _cachedRRect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));
    _cachedBgPaint = Paint()..color = bgColor;
    _cachedBorderPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
  }

  @override
  void render(Canvas canvas) {
    if (_cachedRRect == null) return;
    
    // Draw using cached objects
    canvas.drawRRect(_cachedRRect!, _cachedBgPaint!);
    canvas.drawRRect(_cachedRRect!, _cachedBorderPaint!);
  }
}

class AimCatGame extends FlameGame
    with
        TapCallbacks,
        PanDetector,
        MouseMovementDetector,
        HasCollisionDetection {
  late TextComponent scoreText;
  late TextComponent timerText;
  late TextComponent lastHitText;
  late TappableButton finishButton;
  late TappableButton restartButton;
  bool stopped = false;

  // Make the game background transparent so the background image shows through
  @override
  Color backgroundColor() => Colors.transparent;

  // Scale factor for responsive sizing (based on screen width)
  double get scaleFactor {
    // Base size is 600px width, scale proportionally
    final scale = (size.x / 600).clamp(0.6, 1.5);
    return scale;
  }

  // Scaled padding for UI elements
  double get uiPadding => 12 * scaleFactor;

  // Check if this is a small/mobile screen
  bool get isMobile => size.x < 500;

  // Helper to check if a point is over a UI overlay (e.g., buttons)
  bool isOverUI(Vector2 pos) {
    final double overlayTop = uiPadding;
    final double overlayRight = size.x - uiPadding;
    final double overlayWidth = 200 * scaleFactor;
    final double overlayHeight = 50 * scaleFactor;
    if (pos.x > overlayRight - overlayWidth &&
        pos.x < overlayRight &&
        pos.y > overlayTop &&
        pos.y < overlayTop + overlayHeight) {
      return true;
    }
    final double backLeft = uiPadding;
    final double backTop = uiPadding;
    final double backSize = 40 * scaleFactor;
    if (pos.x > backLeft &&
        pos.x < backLeft + backSize &&
        pos.y > backTop &&
        pos.y < backTop + backSize) {
      return true;
    }
    return false;
  }

  late PositionComponent paw;
  late TimerComponent gameTimer;
  late TextComponent comboText;
  int score = 0;
  double timeLeft = 60;
  int combo = 0; // Consecutive positive hits
  final void Function(int, double, bool) onGameUpdate;
  final void Function() onResetRequest;
  final void Function(int score, double timeLeft) onFinishRequest;
  final void Function()? onTargetHit; // Callback when a target is hit
  final int gameDuration;
  final List<Target> targets = [];
  final Random _rand = Random();

  AimCatGame({
    required this.onGameUpdate,
    required this.onResetRequest,
    required this.onFinishRequest,
    this.onTargetHit,
    this.gameDuration = 60,
  });

  @override
  Future<void> onLoad() async {
    // Scaled sizes for responsive UI
    final double fontSize = 24 * scaleFactor;
    final double smallFontSize = 16 * scaleFactor;
    final double pawSize = 56 * scaleFactor;

    // Pre-cache emoji text to avoid first-render delay
    final emojiPreloader = TextComponent(
      text: '💔',
      position: Vector2(-100, -100), // Off-screen
      textRenderer: TextPaint(style: const TextStyle(fontSize: 32)),
    );
    add(emojiPreloader);
    emojiPreloader.removeFromParent();

    // Invisible paw hitbox for collision detection only (Flutter overlay shows the visual paw)
    paw = PositionComponent(
      size: Vector2.all(pawSize),
      position: size / 2,
      priority: -100,
    );
    add(paw);

    // Score panel background
    final panelPadding = 8.0 * scaleFactor;
    final panelWidth = isMobile ? 180.0 * scaleFactor : 220.0 * scaleFactor;
    final panelHeight = fontSize * 5.5;
    add(
      ScorePanel(
        position: Vector2(uiPadding - panelPadding, uiPadding - panelPadding),
        bgColor: Colors.black.withOpacity(0.5),
        panelWidth: panelWidth,
        panelHeight: panelHeight,
        borderRadius: 12 * scaleFactor,
      ),
    );

    // Score Text (Line 1)
    scoreText = TextComponent(
      text: 'Score: 0',
      position: Vector2(uiPadding, uiPadding),
      anchor: Anchor.topLeft,
      priority: 10,
      textRenderer: TextPaint(
        style: TextStyle(
          fontSize: fontSize,
          color: const Color(0xFFFFD700),
          fontWeight: FontWeight.w900,
          shadows: [
            Shadow(color: Colors.black, blurRadius: 4, offset: Offset(1, 1)),
            Shadow(color: Colors.black, blurRadius: 2, offset: Offset(-1, -1)),
          ],
        ),
      ),
    );
    add(scoreText);

    // Timer Text (Line 2)
    timerText = TextComponent(
      text: 'Time: $gameDuration',
      position: Vector2(uiPadding, uiPadding + fontSize * 1.4),
      anchor: Anchor.topLeft,
      priority: 10,
      textRenderer: TextPaint(
        style: TextStyle(
          fontSize: fontSize,
          color: Colors.white,
          fontWeight: FontWeight.w900,
          shadows: [
            Shadow(color: Colors.black, blurRadius: 4, offset: Offset(1, 1)),
            Shadow(color: Colors.black, blurRadius: 2, offset: Offset(-1, -1)),
          ],
        ),
      ),
    );
    add(timerText);

    // Last Hit Text (Line 3)
    lastHitText = TextComponent(
      text: '',
      position: Vector2(uiPadding, uiPadding + fontSize * 2.8),
      anchor: Anchor.topLeft,
      priority: 10,
      textRenderer: TextPaint(
        style: TextStyle(
          fontSize: fontSize,
          color: Colors.white,
          fontWeight: FontWeight.w900,
          shadows: [
            Shadow(color: Colors.black, blurRadius: 4, offset: Offset(1, 1)),
            Shadow(color: Colors.black, blurRadius: 2, offset: Offset(-1, -1)),
          ],
        ),
      ),
    );
    add(lastHitText);

    // Combo Text (Line 4 - temporary info)
    comboText = TextComponent(
      text: '',
      position: Vector2(uiPadding, uiPadding + fontSize * 4.2),
      anchor: Anchor.topLeft,
      priority: 10,
      textRenderer: TextPaint(
        style: TextStyle(
          fontSize: fontSize,
          color: const Color(0xFFFF6D00),
          fontWeight: FontWeight.w900,
          shadows: [
            Shadow(color: Colors.black, blurRadius: 4, offset: Offset(1, 1)),
            Shadow(color: Colors.black, blurRadius: 2, offset: Offset(-1, -1)),
          ],
        ),
      ),
    );
    add(comboText);

    // Button size
    final buttonSize = 48.0 * scaleFactor;
    final buttonSpacing = 10.0 * scaleFactor;

    // Finish Button (checkmark icon)
    finishButton = TappableButton(
      position: Vector2(
        size.x - (buttonSize * 2 + buttonSpacing + uiPadding),
        uiPadding,
      ),
      bgColor: const Color(0xFF5E35B1), // Deep Purple 600
      icon: Icons.check,
      iconColor: Colors.white,
      buttonSize: buttonSize,
      onTap: () {
        endGame();
        onFinishRequest(score, timeLeft);
      },
    );
    add(finishButton);

    // Reset Button (refresh icon)
    restartButton = TappableButton(
      position: Vector2(size.x - (buttonSize + uiPadding), uiPadding),
      bgColor: const Color(0xFF78909C), // Blue Grey 400
      icon: Icons.refresh,
      iconColor: Colors.white,
      buttonSize: buttonSize,
      onTap: () {
        onResetRequest();
      },
    );
    add(restartButton);

    gameTimer = TimerComponent(
      period: gameDuration.toDouble(),
      removeOnFinish: true,
      onTick: () {
        if (!stopped) onGameUpdate(score, 0, true);
      },
    );
    add(gameTimer);
    timeLeft = gameDuration.toDouble();
    add(
      TimerComponent(
        period: 1,
        repeat: true,
        onTick: () {
          if (!stopped && timeLeft > 0) {
            timeLeft--;
            if (timeLeft < 0) timeLeft = 0;
            timerText.text = 'Time: ${timeLeft.toInt()}';
            onGameUpdate(score, timeLeft, false);
          }
        },
      ),
    );

    // Spawn a new target every 0.7 seconds
    add(
      TimerComponent(
        period: 0.7,
        repeat: true,
        onTick: () {
          if (!stopped && timeLeft > 0) {
            _spawnTarget();
          }
        },
      ),
    );
  }

  void resetGame() {
    stopped = false;
    score = 0;
    combo = 0;
    timeLeft = gameDuration.toDouble();
    scoreText.text = 'Score: 0';
    timerText.text = 'Time: $gameDuration';
    comboText.text = '';
    lastHitText.text = '';
    for (final t in List<Target>.from(targets)) {
      t.removeFromParent();
    }
    targets.clear();
    children.whereType<TimerComponent>().forEach(remove);
    gameTimer = TimerComponent(
      period: gameDuration.toDouble(),
      removeOnFinish: true,
      onTick: () {
        if (!stopped) onGameUpdate(score, 0, true);
      },
    );
    add(gameTimer);
    add(
      TimerComponent(
        period: 1,
        repeat: true,
        onTick: () {
          if (!stopped && timeLeft > 0) {
            timeLeft--;
            if (timeLeft < 0) timeLeft = 0;
            timerText.text = 'Time: ${timeLeft.toInt()}';
            onGameUpdate(score, timeLeft, false);
          }
        },
      ),
    );
    add(
      TimerComponent(
        period: 0.7,
        repeat: true,
        onTick: () {
          if (!stopped && timeLeft > 0) {
            _spawnTarget();
          }
        },
      ),
    );
  }

  void _spawnTarget() {
    if (stopped || timeLeft <= 0) return;

    // 70% chance for positive, 30% for negative
    final isPositive = _rand.nextDouble() < 0.7;

    TargetConfig config;
    if (isPositive) {
      // Use pre-cached lists for performance
      // 5 pts: 25%, 10 pts: 25%, 20 pts: 20%, 30 pts: 12%, 40 pts: 8%, 50 pts: 5%, Time bonus: 5%
      final roll = _rand.nextDouble();
      if (roll < 0.25) {
        config = TargetConfigs._positive5[_rand.nextInt(TargetConfigs._positive5.length)];
      } else if (roll < 0.50) {
        config = TargetConfigs._positive10[_rand.nextInt(TargetConfigs._positive10.length)];
      } else if (roll < 0.70) {
        config = TargetConfigs._positive20[_rand.nextInt(TargetConfigs._positive20.length)];
      } else if (roll < 0.82) {
        config = TargetConfigs._positive30[_rand.nextInt(TargetConfigs._positive30.length)];
      } else if (roll < 0.90) {
        config = TargetConfigs._positive40[_rand.nextInt(TargetConfigs._positive40.length)];
      } else if (roll < 0.95) {
        config = TargetConfigs._positive50[_rand.nextInt(TargetConfigs._positive50.length)];
      } else {
        config = TargetConfigs._positiveTimeBonus[_rand.nextInt(TargetConfigs._positiveTimeBonus.length)];
      }
    } else {
      // Use pre-cached lists for performance
      // -10 pts: 30%, -30 pts: 40%, -50 pts: 20%, -100 pts: 5%, Time penalty: 5%
      final roll = _rand.nextDouble();
      if (roll < 0.30) {
        config = TargetConfigs._negative10[_rand.nextInt(TargetConfigs._negative10.length)];
      } else if (roll < 0.70) {
        config = TargetConfigs._negative30[_rand.nextInt(TargetConfigs._negative30.length)];
      } else if (roll < 0.90) {
        config = TargetConfigs._negative50[_rand.nextInt(TargetConfigs._negative50.length)];
      } else if (roll < 0.95) {
        config = TargetConfigs._negative100[_rand.nextInt(TargetConfigs._negative100.length)];
      } else {
        config = TargetConfigs._negativeTimePenalty[_rand.nextInt(TargetConfigs._negativeTimePenalty.length)];
      }
    }

    // Scale target size based on screen size (minimum 0.7x for small screens)
    final targetScale = scaleFactor.clamp(0.7, 1.2);
    final scaledSize = config.size * targetScale;

    // Keep targets within bounds with padding from edges
    final padding = uiPadding + scaledSize / 2;
    final spawnAreaTop = uiPadding + 50 * scaleFactor; // Below UI elements

    final target = Target(
      config: config,
      position: Vector2(
        padding + _rand.nextDouble() * (size.x - scaledSize - padding * 2),
        spawnAreaTop +
            _rand.nextDouble() * (size.y - scaledSize - spawnAreaTop - padding),
      ),
      onHit: _onTargetHit,
      sizeScale: targetScale,
    );
    add(target);
    targets.add(target);
    add(
      TimerComponent(
        period: config.duration,
        removeOnFinish: true,
        onTick: () {
          if (!stopped && targets.contains(target) && !target.isHit) {
            // If a positive target expires without being hit, break the combo
            if (target.config.isPositive && combo > 0) {
              if (combo >= 5) {
                _spawnComboLostText(target.position + target.size / 2);
              }
              combo = 0;
              comboText.text = '';
            }

            // Fade out animation when time expires
            target.add(
              ScaleEffect.to(
                Vector2.all(0.3),
                EffectController(duration: 0.2, curve: Curves.easeIn),
                onComplete: () {
                  target.removeFromParent();
                  targets.remove(target);
                },
              ),
            );
          }
        },
      ),
    );
  }

  void _onTargetHit(Target target) {
    if (target.isHit) return; // Prevent multiple hits
    target.isHit = true;

    // Notify Flutter to animate paw
    onTargetHit?.call();

    final hitPosition = target.position + target.size / 2;
    final isPositive = target.config.isPositive;

    // Calculate combo bonus
    int bonus = 0;
    int totalValue = target.config.value;

    if (isPositive) {
      combo++;
      // Apply combo bonus: 5+ hits = +10, 10+ hits = +50
      if (combo >= 10) {
        bonus = 50;
      } else if (combo >= 5) {
        bonus = 10;
      }
      totalValue += bonus;

      // Update combo display
      if (combo >= 5) {
        final comboLevel = combo >= 10 ? '🔥 SUPER COMBO' : '⭐ COMBO';
        comboText.text = '$comboLevel x$combo (+$bonus)';
        comboText.textRenderer = TextPaint(
          style: TextStyle(
            fontSize: combo >= 10 ? 22 : 20,
            color: combo >= 10 ? Colors.deepOrange : Colors.orangeAccent,
            fontWeight: FontWeight.bold,
          ),
        );
      } else {
        comboText.text = combo > 1 ? 'x$combo' : '';
      }
    } else {
      // Negative target breaks the combo
      if (combo >= 5) {
        _spawnComboLostText(hitPosition);
      }
      combo = 0;
      comboText.text = '';
    }

    score += totalValue;
    scoreText.text = 'Score: $score';

    // Update last hit text
    final valueText = target.config.value >= 0
        ? '+${target.config.value}'
        : '${target.config.value}';
    lastHitText.text = 'Last: ${target.config.name} ($valueText)';
    lastHitText.textRenderer = TextPaint(
      style: TextStyle(
        fontSize: 20 * scaleFactor,
        color: isPositive ? const Color(0xFF81C784) : const Color(0xFFE57373),
        fontWeight: FontWeight.bold,
      ),
    );

    // Apply time bonus/penalty
    if (target.config.timeBonus != 0) {
      timeLeft += target.config.timeBonus;
      if (timeLeft < 0) timeLeft = 0;
      timerText.text = 'Time: ${timeLeft.toInt()}';
      // Spawn time indicator
      final timeColor = target.config.timeBonus > 0
          ? const Color(0xFF4CAF50)
          : const Color(0xFFE53935);
      final timeText = target.config.timeBonus > 0
          ? '+${target.config.timeBonus}s'
          : '${target.config.timeBonus}s';
      _spawnFloatingText(hitPosition + Vector2(0, -30), timeText, timeColor);
    }

    onGameUpdate(score, timeLeft, false);

    // Use target's color for particles, or default Material colors
    final particleColor = target.config.color;
    final scoreColor = isPositive
        ? const Color(0xFF81C784) // Light Green
        : const Color(0xFFE57373); // Light Red

    // 1. Target squish effect (Material motion: emphasized decelerate)
    target.add(
      ScaleEffect.to(
        Vector2.all(0.2),
        EffectController(
          duration: 0.15,
          curve: Curves.easeOutCubic, // Material decelerate curve
        ),
        onComplete: () {
          target.removeFromParent();
          targets.remove(target);
        },
      ),
    );

    // 2. Particle burst effect
    _spawnHitParticles(hitPosition, particleColor);

    // 3. Floating score text with combo bonus
    _spawnFloatingScore(hitPosition, target.config.value, scoreColor, bonus);

    // 4. Screen shake for negative hits (subtle feedback)
    if (!isPositive) {
      _triggerShake();
    }
  }

  // Pre-cached paints for particle rendering performance
  static final Paint _particlePaint = Paint()..style = PaintingStyle.fill;
  static final Paint _bgPaint = Paint();
  static final Paint _borderPaint = Paint()..style = PaintingStyle.stroke..strokeWidth = 2;
  
  // Pre-allocated vectors for calculations (reused to avoid GC)
  static final Vector2 _tempVector = Vector2.zero();

  void _spawnHitParticles(Vector2 position, Color color) {
    // Pre-calculate color components for opacity interpolation
    final colorR = color.red;
    final colorG = color.green;
    final colorB = color.blue;
    
    add(
      ParticleSystemComponent(
        position: position,
        particle: Particle.generate(
          count: 8, // Reduced from 12 for better performance
          lifespan: 0.35, // Slightly shorter lifespan
          generator: (i) {
            final angle = (i / 8) * 2 * pi + _rand.nextDouble() * 0.5;
            final speed = 80 + _rand.nextDouble() * 60;
            return AcceleratedParticle(
              acceleration: Vector2(0, 300), // Gravity
              speed: Vector2(cos(angle) * speed, sin(angle) * speed),
              child: ComputedParticle(
                renderer: (canvas, particle) {
                  final opacity = (1 - particle.progress).clamp(0.0, 1.0);
                  final size = 4 * (1 - particle.progress * 0.5);
                  _particlePaint.color = Color.fromRGBO(colorR, colorG, colorB, opacity);
                  canvas.drawCircle(Offset.zero, size, _particlePaint);
                },
              ),
            );
          },
        ),
      ),
    );

    // Add sparkle ring effect
    add(
      ParticleSystemComponent(
        position: position,
        particle: Particle.generate(
          count: 6, // Reduced from 8
          lifespan: 0.25, // Shorter lifespan
          generator: (i) {
            final angle = (i / 6) * 2 * pi;
            return MovingParticle(
              from: Vector2.zero(),
              to: Vector2(cos(angle) * 40, sin(angle) * 40),
              child: ComputedParticle(
                renderer: (canvas, particle) {
                  final opacity = (1 - particle.progress).clamp(0.0, 1.0);
                  final size = 3 * (1 - particle.progress);
                  _particlePaint.color = Color.fromRGBO(255, 255, 255, opacity * 0.8);
                  canvas.drawCircle(Offset.zero, size, _particlePaint);
                },
              ),
            );
          },
        ),
      ),
    );
  }

  void _spawnFloatingScore(
    Vector2 position,
    int value,
    Color color, [
    int bonus = 0,
  ]) {
    final scoreSign = value >= 0 ? '+' : '';
    String text = '$scoreSign$value';
    if (bonus > 0) {
      text += ' +$bonus';
    }

    // Determine size based on value/bonus
    double fontSize = 24;
    if (bonus >= 50) {
      fontSize = 36;
    } else if (bonus >= 10) {
      fontSize = 32;
    } else if (value.abs() >= 40) {
      fontSize = 30;
    } else if (value.abs() >= 20) {
      fontSize = 26;
    }

    // Enhanced color for combos
    Color textColor = color;
    if (bonus >= 50) {
      textColor = const Color(0xFFFF6D00); // Deep orange for super combo
    } else if (bonus >= 10) {
      textColor = const Color(0xFFFFAB00); // Amber accent for combo
    }

    final floatingText = TextComponent(
      text: text,
      position: position.clone(),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: textColor,
          shadows: [
            Shadow(
              color: Colors.black.withOpacity(0.7),
              offset: const Offset(2, 2),
              blurRadius: 4,
            ),
            Shadow(
              color: textColor.withOpacity(0.8),
              offset: Offset.zero,
              blurRadius: 10,
            ),
            Shadow(
              color: Colors.white.withOpacity(0.5),
              offset: const Offset(-1, -1),
              blurRadius: 2,
            ),
          ],
        ),
      ),
      priority: 100,
    );

    add(floatingText);

    // Random horizontal drift for variety
    final random = Random();
    final drift = (random.nextDouble() - 0.5) * 40;

    // Float up with curve and drift
    floatingText.add(
      MoveByEffect(
        Vector2(drift, -80),
        EffectController(duration: 0.8, curve: Curves.easeOutQuart),
      ),
    );

    // Pop scale effect
    floatingText.add(
      ScaleEffect.to(
        Vector2.all(bonus >= 10 ? 1.6 : 1.4),
        EffectController(duration: 0.12, curve: Curves.easeOut),
      ),
    );
    floatingText.add(
      SequenceEffect([
        ScaleEffect.to(
          Vector2.all(bonus >= 10 ? 1.6 : 1.4),
          EffectController(duration: 0.12),
        ),
        ScaleEffect.to(
          Vector2.all(0.0),
          EffectController(duration: 0.68, curve: Curves.easeInQuart),
        ),
      ]),
    );

    // Remove after animation
    floatingText.add(RemoveEffect(delay: 0.8));

    // Spawn mini sparkles around the score for combos
    if (bonus > 0) {
      _spawnScoreSparkles(position, textColor);
    }
  }

  void _spawnScoreSparkles(Vector2 position, Color color) {
    final random = Random();
    add(
      ParticleSystemComponent(
        position: position,
        particle: Particle.generate(
          count: 6,
          lifespan: 0.5,
          generator: (i) {
            final angle = (i / 6) * 2 * pi + random.nextDouble() * 0.5;
            final speed = 50 + random.nextDouble() * 30;
            return AcceleratedParticle(
              acceleration: Vector2(0, 100),
              speed: Vector2(cos(angle) * speed, sin(angle) * speed - 40),
              child: ComputedParticle(
                renderer: (canvas, particle) {
                  final opacity = (1 - particle.progress).clamp(0.0, 1.0);
                  final size = 5 * (1 - particle.progress * 0.5);
                  // Draw star shape
                  final paint = Paint()
                    ..color = color.withOpacity(opacity)
                    ..style = PaintingStyle.fill;
                  canvas.drawCircle(Offset.zero, size, paint);
                  // Inner glow
                  canvas.drawCircle(
                    Offset.zero,
                    size * 0.5,
                    Paint()..color = Colors.white.withOpacity(opacity * 0.8),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  void _spawnFloatingText(Vector2 position, String text, Color color) {
    final floatingText = TextComponent(
      text: text,
      position: position.clone(),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: color,
          shadows: [
            Shadow(
              color: Colors.black.withOpacity(0.7),
              offset: const Offset(2, 2),
              blurRadius: 4,
            ),
          ],
        ),
      ),
      priority: 100,
    );

    add(floatingText);

    // Float up
    floatingText.add(
      MoveByEffect(
        Vector2(0, -60),
        EffectController(duration: 0.6, curve: Curves.easeOutQuart),
      ),
    );

    // Fade out
    floatingText.add(
      SequenceEffect([
        ScaleEffect.to(Vector2.all(1.3), EffectController(duration: 0.1)),
        ScaleEffect.to(
          Vector2.all(0.0),
          EffectController(duration: 0.5, curve: Curves.easeInQuart),
        ),
      ]),
    );

    // Remove after animation
    floatingText.add(RemoveEffect(delay: 0.6));
  }

  void _spawnComboLostText(Vector2 position) {
    final lostText = TextComponent(
      text: '💔 COMBO LOST!',
      position: position.clone(),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: const Color(0xFFFF5252),
          shadows: [
            Shadow(
              color: Colors.black.withOpacity(0.8),
              offset: const Offset(3, 3),
              blurRadius: 6,
            ),
            Shadow(
              color: const Color(0xFFFF5252).withOpacity(0.6),
              offset: Offset.zero,
              blurRadius: 15,
            ),
          ],
        ),
      ),
      priority: 100,
    );

    add(lostText);

    // Shake horizontally while floating up
    lostText.add(
      MoveByEffect(
        Vector2(0, -80),
        EffectController(duration: 1.0, curve: Curves.easeOutQuart),
      ),
    );

    // Pop in and shake
    lostText.add(
      SequenceEffect([
        ScaleEffect.to(
          Vector2.all(1.8),
          EffectController(duration: 0.15, curve: Curves.easeOutBack),
        ),
        ScaleEffect.to(Vector2.all(1.4), EffectController(duration: 0.1)),
        ScaleEffect.to(
          Vector2.all(0.0),
          EffectController(duration: 0.75, curve: Curves.easeInQuart),
        ),
      ]),
    );

    // Rotation shake effect
    lostText.add(
      SequenceEffect([
        RotateEffect.by(0.1, EffectController(duration: 0.05)),
        RotateEffect.by(-0.2, EffectController(duration: 0.05)),
        RotateEffect.by(0.15, EffectController(duration: 0.05)),
        RotateEffect.by(-0.05, EffectController(duration: 0.05)),
      ]),
    );

    lostText.add(RemoveEffect(delay: 1.0));

    // Spawn broken heart particles
    _spawnComboLostParticles(position);
  }

  void _spawnComboLostParticles(Vector2 position) {
    add(
      ParticleSystemComponent(
        position: position,
        particle: Particle.generate(
          count: 6, // Reduced from 10
          lifespan: 0.6, // Shorter lifespan
          generator: (i) {
            final angle = (_rand.nextDouble() - 0.5) * pi;
            final speed = 60 + _rand.nextDouble() * 80;
            return AcceleratedParticle(
              acceleration: Vector2(0, 200),
              speed: Vector2(cos(angle) * speed, sin(angle) * speed - 80),
              child: ComputedParticle(
                renderer: (canvas, particle) {
                  final opacity = (1 - particle.progress).clamp(0.0, 1.0);
                  final size = 8 * (1 - particle.progress * 0.3);
                  // Draw red shards - reuse static paint
                  _particlePaint.color = Color.fromRGBO(244, 67, 54, opacity);
                  canvas.save();
                  canvas.rotate(particle.progress * pi);
                  canvas.drawRect(
                    Rect.fromCenter(
                      center: Offset.zero,
                      width: size,
                      height: size * 0.4,
                    ),
                    _particlePaint,
                  );
                  canvas.restore();
                },
              ),
            );
          },
        ),
      ),
    );
  }

  // Subtle screen shake for feedback
  Vector2 _shakeOffset = Vector2.zero();
  double _shakeTime = 0;

  void _triggerShake() {
    _shakeTime = 0.15;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_shakeTime > 0) {
      _shakeTime -= dt;
      final intensity = (_shakeTime / 0.15) * 3;
      _shakeOffset = Vector2(
        (_rand.nextDouble() - 0.5) * intensity,
        (_rand.nextDouble() - 0.5) * intensity,
      );
      camera.viewfinder.position = _shakeOffset;
    } else if (_shakeOffset != Vector2.zero()) {
      _shakeOffset = Vector2.zero();
      camera.viewfinder.position = Vector2.zero();
    }
  }

  void endGame() {
    stopped = true;
    // Clean up all targets
    for (final t in List<Target>.from(targets)) {
      t.removeFromParent();
    }
    targets.clear();
    
    // Remove all timer components to stop spawning
    children.whereType<TimerComponent>().toList().forEach((timer) {
      timer.removeFromParent();
    });
    
    // Remove any lingering particle systems
    children.whereType<ParticleSystemComponent>().toList().forEach((particle) {
      particle.removeFromParent();
    });
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    paw.position += info.delta.global;
  }

  @override
  void onTapDown(TapDownEvent event) {
    final tapPos = event.localPosition;
    // Check if tap is on Finish button
    if (finishButton.toRect().contains(tapPos.toOffset())) {
      finishButton.onTap();
      return;
    }
    // Check if tap is on Restart button
    if (restartButton.toRect().contains(tapPos.toOffset())) {
      restartButton.onTap();
      return;
    }
  }

  @override
  void onMouseMove(PointerHoverInfo info) {
    paw.position = info.eventPosition.global;
  }

  @override
  void onMouseHover(PointerHoverInfo info) {
    paw.position = info.eventPosition.global;
  }

  // Update paw position from Flutter (for overlay sync)
  void updatePawPosition(double x, double y) {
    paw.position = Vector2(x, y);
  }
}

class Target extends PositionComponent with TapCallbacks {
  final TargetConfig config;
  final void Function(Target) onHit;
  final double sizeScale;
  bool isHit = false; // Prevent multiple hits during animation
  bool _isHovered = false;
  // Cache game reference to avoid findGame() every frame
  AimCatGame? _cachedGame;
  // Pre-cached values for collision detection
  late final double _collisionRadiusSq;
  late final Vector2 _halfSize;

  Target({
    required this.config,
    required Vector2 position,
    required this.onHit,
    this.sizeScale = 1.0,
  }) : super(position: position, size: Vector2.all(config.size * sizeScale));

  @override
  Future<void> onLoad() async {
    // Cache game reference once on load
    _cachedGame = findGame() as AimCatGame?;
    // Pre-calculate collision values
    _halfSize = size / 2;
    if (_cachedGame != null) {
      final collisionRadius = (size.x + _cachedGame!.paw.size.x) / 2;
      _collisionRadiusSq = collisionRadius * collisionRadius;
    } else {
      _collisionRadiusSq = size.x * size.x;
    }
    
    final scaledIconSize = config.size * sizeScale;

    // Add the icon component with scaled size
    add(
      IconComponent(
        icon: config.icon,
        color: config.color,
        iconSize: scaledIconSize,
        position: Vector2.zero(),
      ),
    );

    add(RectangleHitbox());

    // Add idle floating animation (Material subtle motion) - scale float distance
    add(
      MoveByEffect(
        Vector2(0, -3 * sizeScale),
        EffectController(
          duration: 0.8,
          curve: Curves.easeInOut,
          infinite: true,
          alternate: true,
        ),
      ),
    );

    // Entry animation - scale in
    scale = Vector2.all(0);
    add(
      ScaleEffect.to(
        Vector2.all(1.0),
        EffectController(duration: 0.2, curve: Curves.easeOutBack),
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isHit) return; // Don't check collision if already hit

    final parentGame = _cachedGame;
    if (parentGame != null) {
      // Use cached values and avoid allocations
      final pawPos = parentGame.paw.position;
      // Inline center calculation to avoid Vector2 allocation
      final centerX = position.x + _halfSize.x;
      final centerY = position.y + _halfSize.y;
      final dx = pawPos.x - centerX;
      final dy = pawPos.y - centerY;
      final distSq = dx * dx + dy * dy;
      final isOverlapping = distSq < _collisionRadiusSq;

      // Handle hover state for visual feedback
      if (isOverlapping && !_isHovered && !parentGame.isOverUI(pawPos)) {
        _isHovered = true;
        _onHoverStart();
      } else if (!isOverlapping && _isHovered) {
        _isHovered = false;
        _onHoverEnd();
      }

      // Trigger hit
      if (isOverlapping && !parentGame.isOverUI(pawPos)) {
        onHit(this);
      }
    }
  }

  void _onHoverStart() {
    // Quick scale up on hover (Material touch feedback)
    add(
      ScaleEffect.to(
        Vector2.all(1.15),
        EffectController(duration: 0.1, curve: Curves.easeOut),
      ),
    );
  }

  void _onHoverEnd() {
    // Return to normal size
    add(
      ScaleEffect.to(
        Vector2.all(1.0),
        EffectController(duration: 0.1, curve: Curves.easeIn),
      ),
    );
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (!isHit) {
      onHit(this);
    }
  }
}
