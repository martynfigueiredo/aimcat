import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/collisions.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

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

  late SpriteComponent paw;
  late TimerComponent gameTimer;
  int score = 0;
  double timeLeft = 60;
  final void Function(int, double, bool) onGameUpdate;
  final void Function() onResetRequest;
  final void Function(int score, double timeLeft) onFinishRequest;
  final int gameDuration;
  final List<Target> targets = [];
  final Random _rand = Random();

  AimCatGame({required this.onGameUpdate, required this.onResetRequest, required this.onFinishRequest, this.gameDuration = 60});

  @override
  Future<void> onLoad() async {
    // Paw is invisible in game but used for collision detection
    paw = SpriteComponent()
      ..sprite = await loadSprite('paw.png')
      ..size = Vector2(64, 64)
      ..position = size / 2
      ..priority = -1; // Hidden - visual paw is rendered by Flutter overlay
    paw.opacity = 0; // Make invisible since Flutter overlay handles visual
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
    timeLeft = gameDuration.toDouble();
    scoreText.text = 'Score: 0';
    timerText.text = 'Time: $gameDuration';
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
    final type = _rand.nextDouble() < 0.7 ? TargetType.positive : TargetType.negative;
    final value = type == TargetType.positive ? (_rand.nextInt(3) + 1) * 10 : -(_rand.nextInt(2) + 1) * 10;
    double duration;
    if (type == TargetType.positive) {
      if (value == 10) {
        duration = 2.0;
      } else if (value == 20) {
        duration = 1.5;
      } else {
        duration = 1.0;
      }
    } else {
      duration = 2.5;
    }
    final target = Target(
      type: type,
      value: value,
      duration: duration,
      position: Vector2(
        _rand.nextDouble() * (size.x - 48),
        _rand.nextDouble() * (size.y - 48),
      ),
      onHit: _onTargetHit,
    );
    add(target);
    targets.add(target);
    add(TimerComponent(
      period: duration,
      removeOnFinish: true,
      onTick: () {
        if (!stopped && targets.contains(target)) {
          target.removeFromParent();
          targets.remove(target);
        }
      },
    ));
  }

  void _onTargetHit(Target target) {
    if (target.isHit) return; // Prevent multiple hits
    target.isHit = true;
    
    final hitPosition = target.position + target.size / 2;
    final isPositive = target.type == TargetType.positive;
    
    score += target.value;
    scoreText.text = 'Score: $score';
    onGameUpdate(score, timeLeft, false);
    
    // Material Design color scheme
    final particleColor = isPositive 
        ? const Color(0xFF4CAF50)  // Material Green
        : const Color(0xFFF44336); // Material Red
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
    
    // 3. Floating score text
    _spawnFloatingScore(hitPosition, target.value, scoreColor);
    
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
  
  void _spawnFloatingScore(Vector2 position, int value, Color color) {
    final scoreSign = value >= 0 ? '+' : '';
    final floatingText = TextComponent(
      text: '$scoreSign$value',
      position: position.clone(),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: color,
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

class Target extends SpriteComponent with TapCallbacks {
  final TargetType type;
  final int value;
  final double duration;
  final void Function(Target) onHit;
  bool isHit = false; // Prevent multiple hits during animation
  bool _isHovered = false;

  Target({
    required this.type,
    required this.value,
    required this.duration,
    required Vector2 position,
    required this.onHit,
  }) : super(
    position: position,
    size: Vector2(48, 48),
  );

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load(type == TargetType.positive ? 'target_good.png' : 'target_bad.png');
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
