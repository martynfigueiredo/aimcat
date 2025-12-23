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

  const TargetConfig({
    required this.icon,
    required this.color,
    required this.value,
    required this.duration,
    required this.isPositive,
    required this.size,
  });
}

// All available targets
class TargetConfigs {
  // Positive targets (sorted by value) - Higher value = bigger
  static const List<TargetConfig> positive = [
    TargetConfig(icon: Icons.favorite, color: Color(0xFFE91E63), value: 10, duration: 2.0, isPositive: true, size: 36),       // Heart - Small
    TargetConfig(icon: Icons.star, color: Color(0xFFFFEB3B), value: 20, duration: 1.7, isPositive: true, size: 44),           // Star
    TargetConfig(icon: Icons.auto_awesome, color: Color(0xFF00BCD4), value: 30, duration: 1.4, isPositive: true, size: 52),   // Sparkle
    TargetConfig(icon: Icons.emoji_events, color: Color(0xFFFF9800), value: 40, duration: 1.1, isPositive: true, size: 60),   // Trophy
    TargetConfig(icon: Icons.diamond, color: Color(0xFF9C27B0), value: 50, duration: 0.8, isPositive: true, size: 68),        // Diamond - Big
  ];

  // Negative targets (sorted by value) - Higher penalty = bigger (easier to accidentally hit!)
  static const List<TargetConfig> negative = [
    TargetConfig(icon: Icons.cancel, color: Color(0xFFE53935), value: -10, duration: 2.5, isPositive: false, size: 40),                  // Red X - Small
    TargetConfig(icon: Icons.dangerous, color: Color(0xFFFF5722), value: -20, duration: 2.2, isPositive: false, size: 52),               // Skull/Danger
    TargetConfig(icon: Icons.local_fire_department, color: Color(0xFFD32F2F), value: -30, duration: 1.9, isPositive: false, size: 64),   // Fire - Big
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

// Tappable button component (whole area is clickable)
class TappableButton extends PositionComponent with TapCallbacks {
  final void Function() onTap;
  final Color bgColor;
  final String label;
  final Color textColor;

  TappableButton({
    required Vector2 position,
    required this.onTap,
    required this.bgColor,
    required this.label,
    required this.textColor,
  }) : super(
    position: position,
    size: Vector2(100, 40),
    anchor: Anchor.topLeft,
    priority: 10,
  );

  @override
  Future<void> onLoad() async {
    add(RectangleComponent(
      size: size,
      paint: Paint()..color = bgColor,
    ));
    add(TextComponent(
      text: label,
      anchor: Anchor.center,
      position: size / 2,
      textRenderer: TextPaint(style: TextStyle(fontSize: 18, color: textColor)),
    ));
  }

  @override
  void onTapDown(TapDownEvent event) {
    onTap();
  }
}

class AimCatGame extends FlameGame with TapCallbacks, PanDetector, MouseMovementDetector, HasCollisionDetection {
  late TextComponent scoreText;
  late TextComponent timerText;
  late TappableButton finishButton;
  late TappableButton restartButton;
  bool stopped = false;

  // Helper to check if a point is over a UI overlay (e.g., buttons)
  bool isOverUI(Vector2 pos) {
    final double overlayTop = 16;
    final double overlayRight = size.x - 16;
    final double overlayWidth = 220;
    final double overlayHeight = 56;
    if (pos.x > overlayRight - overlayWidth && pos.x < overlayRight && pos.y > overlayTop && pos.y < overlayTop + overlayHeight) {
      return true;
    }
    final double backLeft = 16;
    final double backTop = 16;
    final double backSize = 48;
    if (pos.x > backLeft && pos.x < backLeft + backSize && pos.y > backTop && pos.y < backTop + backSize) {
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
  final int gameDuration;
  final List<Target> targets = [];
  final Random _rand = Random();

  AimCatGame({required this.onGameUpdate, required this.onResetRequest, required this.onFinishRequest, this.gameDuration = 60});

  @override
  Future<void> onLoad() async {
    // Invisible paw hitbox for collision detection only (Flutter overlay shows the visual paw)
    paw = PositionComponent(
      size: Vector2(64, 64),
      position: size / 2,
      priority: -100,
    );
    add(paw);

    // Score Text
    scoreText = TextComponent(
      text: 'Score: 0',
      position: Vector2(20, 20),
      anchor: Anchor.topLeft,
      priority: 10,
      textRenderer: TextPaint(style: const TextStyle(fontSize: 24, color: Colors.amber, fontWeight: FontWeight.bold)),
    );
    add(scoreText);

    // Combo Text
    comboText = TextComponent(
      text: '',
      position: Vector2(20, 88),
      anchor: Anchor.topLeft,
      priority: 10,
      textRenderer: TextPaint(style: const TextStyle(fontSize: 20, color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
    );
    add(comboText);

    // Timer Text
    timerText = TextComponent(
      text: 'Time: $gameDuration',
      position: Vector2(20, 54),
      anchor: Anchor.topLeft,
      priority: 10,
      textRenderer: TextPaint(style: const TextStyle(fontSize: 22, color: Colors.white)),
    );
    add(timerText);

    // Finish Button
    finishButton = TappableButton(
      position: Vector2(size.x - 230, 20),
      bgColor: const Color(0xFF7C3AED),
      label: 'Finish',
      textColor: Colors.white,
      onTap: () {
        endGame();
        onFinishRequest(score, timeLeft);
      },
    );
    add(finishButton);

    // Reset Button
    restartButton = TappableButton(
      position: Vector2(size.x - 120, 20),
      bgColor: const Color(0xFFFFB300),
      label: 'Reset',
      textColor: Colors.black,
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
    add(TimerComponent(
      period: 1,
      repeat: true,
      onTick: () {
        if (!stopped) {
          timeLeft--;
          timerText.text = 'Time: ${timeLeft.toInt()}';
          onGameUpdate(score, timeLeft, false);
        }
      },
    ));

    // Spawn a new target every 0.7 seconds
    add(TimerComponent(
      period: 0.7,
      repeat: true,
      onTick: () {
        if (!stopped && timeLeft > 0) {
          _spawnTarget();
        }
      },
    ));
  }

  void resetGame() {
    stopped = false;
    score = 0;
    combo = 0;
    timeLeft = gameDuration.toDouble();
    scoreText.text = 'Score: 0';
    timerText.text = 'Time: $gameDuration';
    comboText.text = '';
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
    add(TimerComponent(
      period: 1,
      repeat: true,
      onTick: () {
        if (!stopped) {
          timeLeft--;
          timerText.text = 'Time: ${timeLeft.toInt()}';
          onGameUpdate(score, timeLeft, false);
        }
      },
    ));
    add(TimerComponent(
      period: 0.7,
      repeat: true,
      onTick: () {
        if (!stopped && timeLeft > 0) {
          _spawnTarget();
        }
      },
    ));
  }

  void _spawnTarget() {
    if (stopped || timeLeft <= 0) return;
    
    // 70% chance for positive, 30% for negative
    final isPositive = _rand.nextDouble() < 0.7;
    
    TargetConfig config;
    if (isPositive) {
      // Weighted random: lower values more common
      // 40% +10, 25% +20, 18% +30, 12% +40, 5% +50
      final roll = _rand.nextDouble();
      if (roll < 0.40) {
        config = TargetConfigs.positive[0]; // +10 Heart
      } else if (roll < 0.65) {
        config = TargetConfigs.positive[1]; // +20 Star
      } else if (roll < 0.83) {
        config = TargetConfigs.positive[2]; // +30 Sparkle
      } else if (roll < 0.95) {
        config = TargetConfigs.positive[3]; // +40 Trophy
      } else {
        config = TargetConfigs.positive[4]; // +50 Diamond (rare!)
      }
    } else {
      // Weighted random for negative: -10 most common
      // 50% -10, 35% -20, 15% -30
      final roll = _rand.nextDouble();
      if (roll < 0.50) {
        config = TargetConfigs.negative[0]; // -10 Water
      } else if (roll < 0.85) {
        config = TargetConfigs.negative[1]; // -20 Bug
      } else {
        config = TargetConfigs.negative[2]; // -30 Lightning
      }
    }
    
    final target = Target(
      config: config,
      position: Vector2(
        _rand.nextDouble() * (size.x - config.size),
        _rand.nextDouble() * (size.y - config.size),
      ),
      onHit: _onTargetHit,
    );
    add(target);
    targets.add(target);
    add(TimerComponent(
      period: config.duration,
      removeOnFinish: true,
      onTick: () {
        if (!stopped && targets.contains(target) && !target.isHit) {
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
    ));
  }

  void _onTargetHit(Target target) {
    if (target.isHit) return; // Prevent multiple hits
    target.isHit = true;
    
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
    onGameUpdate(score, timeLeft, false);
    
    // Use target's color for particles, or default Material colors
    final particleColor = target.config.color;
    final scoreColor = isPositive
        ? const Color(0xFF81C784)  // Light Green
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
  
  void _spawnHitParticles(Vector2 position, Color color) {
    final random = Random();
    add(
      ParticleSystemComponent(
        position: position,
        particle: Particle.generate(
          count: 12,
          lifespan: 0.4,
          generator: (i) {
            final angle = (i / 12) * 2 * pi + random.nextDouble() * 0.5;
            final speed = 80 + random.nextDouble() * 60;
            return AcceleratedParticle(
              acceleration: Vector2(0, 300), // Gravity
              speed: Vector2(cos(angle) * speed, sin(angle) * speed),
              child: ComputedParticle(
                renderer: (canvas, particle) {
                  final opacity = (1 - particle.progress).clamp(0.0, 1.0);
                  final size = 4 * (1 - particle.progress * 0.5);
                  canvas.drawCircle(
                    Offset.zero,
                    size,
                    Paint()
                      ..color = color.withOpacity(opacity)
                      ..style = PaintingStyle.fill,
                  );
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
          count: 8,
          lifespan: 0.3,
          generator: (i) {
            final angle = (i / 8) * 2 * pi;
            return MovingParticle(
              from: Vector2.zero(),
              to: Vector2(cos(angle) * 40, sin(angle) * 40),
              child: ComputedParticle(
                renderer: (canvas, particle) {
                  final opacity = (1 - particle.progress).clamp(0.0, 1.0);
                  final size = 3 * (1 - particle.progress);
                  canvas.drawCircle(
                    Offset.zero,
                    size,
                    Paint()
                      ..color = Colors.white.withOpacity(opacity * 0.8)
                      ..style = PaintingStyle.fill,
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
  
  void _spawnFloatingScore(Vector2 position, int value, Color color, [int bonus = 0]) {
    final scoreSign = value >= 0 ? '+' : '';
    String text = '$scoreSign$value';
    if (bonus > 0) {
      text += ' +$bonus';
    }
    final floatingText = TextComponent(
      text: text,
      position: position.clone(),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: TextStyle(
          fontSize: bonus > 0 ? 28 : 24,
          fontWeight: FontWeight.bold,
          color: bonus > 0 ? Colors.orange : color,
          shadows: [
            Shadow(
              color: Colors.black.withOpacity(0.5),
              offset: const Offset(1, 1),
              blurRadius: 2,
            ),
          ],
        ),
      ),
      priority: 100,
    );
    
    add(floatingText);
    
    // Float up with fade (Material motion)
    floatingText.add(
      MoveByEffect(
        Vector2(0, -50),
        EffectController(
          duration: 0.6,
          curve: Curves.easeOutCubic,
        ),
      ),
    );
    floatingText.add(
      ScaleEffect.to(
        Vector2.all(1.3),
        EffectController(
          duration: 0.15,
          curve: Curves.easeOut,
          reverseDuration: 0.45,
          reverseCurve: Curves.easeIn,
        ),
      ),
    );
    // Remove after animation completes
    floatingText.add(
      RemoveEffect(
        delay: 0.6,
      ),
    );
  }
  
  void _spawnComboLostText(Vector2 position) {
    final lostText = TextComponent(
      text: 'COMBO LOST!',
      position: position.clone(),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: Colors.red.shade300,
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
    
    add(lostText);
    
    // Float up with shake effect
    lostText.add(
      MoveByEffect(
        Vector2(0, -60),
        EffectController(
          duration: 0.8,
          curve: Curves.easeOutCubic,
        ),
      ),
    );
    lostText.add(
      ScaleEffect.to(
        Vector2.all(1.5),
        EffectController(
          duration: 0.2,
          curve: Curves.elasticOut,
          reverseDuration: 0.6,
          reverseCurve: Curves.easeIn,
        ),
      ),
    );
    lostText.add(
      RemoveEffect(
        delay: 0.8,
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
        (Random().nextDouble() - 0.5) * intensity,
        (Random().nextDouble() - 0.5) * intensity,
      );
      camera.viewfinder.position = _shakeOffset;
    } else if (_shakeOffset != Vector2.zero()) {
      _shakeOffset = Vector2.zero();
      camera.viewfinder.position = Vector2.zero();
    }
  }

  void endGame() {
    stopped = true;
    for (final t in List<Target>.from(targets)) {
      t.removeFromParent();
    }
    targets.clear();
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
  bool isHit = false; // Prevent multiple hits during animation
  bool _isHovered = false;

  Target({
    required this.config,
    required Vector2 position,
    required this.onHit,
  }) : super(
    position: position,
    size: Vector2.all(config.size),
  );

  @override
  Future<void> onLoad() async {
    // Add the icon component with size from config
    add(IconComponent(
      icon: config.icon,
      color: config.color,
      iconSize: config.size,
      position: Vector2.zero(),
    ));
    
    add(RectangleHitbox());
    
    // Add idle floating animation (Material subtle motion)
    add(
      MoveByEffect(
        Vector2(0, -4),
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
        EffectController(
          duration: 0.2,
          curve: Curves.easeOutBack,
        ),
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isHit) return; // Don't check collision if already hit
    
    final parentGame = findGame() as AimCatGame?;
    if (parentGame != null) {
      final pawRect = parentGame.paw.toRect();
      final targetRect = toRect();
      final isOverlapping = pawRect.overlaps(targetRect);
      
      // Handle hover state for visual feedback
      if (isOverlapping && !_isHovered && !parentGame.isOverUI(parentGame.paw.position)) {
        _isHovered = true;
        _onHoverStart();
      } else if (!isOverlapping && _isHovered) {
        _isHovered = false;
        _onHoverEnd();
      }
      
      // Trigger hit
      if (isOverlapping && !parentGame.isOverUI(parentGame.paw.position)) {
        onHit(this);
      }
    }
  }
  
  void _onHoverStart() {
    // Quick scale up on hover (Material touch feedback)
    add(
      ScaleEffect.to(
        Vector2.all(1.15),
        EffectController(
          duration: 0.1,
          curve: Curves.easeOut,
        ),
      ),
    );
  }
  
  void _onHoverEnd() {
    // Return to normal size
    add(
      ScaleEffect.to(
        Vector2.all(1.0),
        EffectController(
          duration: 0.1,
          curve: Curves.easeIn,
        ),
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
