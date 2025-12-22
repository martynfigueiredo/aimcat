import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/collisions.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

// Types of targets
enum TargetType { positive, negative }

class AimCatGame extends FlameGame with PanDetector, MouseMovementDetector, HasCollisionDetection {
  late SpriteComponent paw;
  late TimerComponent gameTimer;
  int score = 0;
  double timeLeft = 60; // Default, can be set
  final void Function(int, double, bool) onGameUpdate;
  final int gameDuration;
  final List<Target> targets = [];
  final Random _rand = Random();

  AimCatGame({required this.onGameUpdate, this.gameDuration = 60});

  @override
  Future<void> onLoad() async {
    paw = SpriteComponent()
      ..sprite = await loadSprite('paw.png')
      ..size = Vector2(64, 64)
      ..position = size / 2;
    add(paw);

    gameTimer = TimerComponent(
      period: gameDuration.toDouble(),
      removeOnFinish: true,
      onTick: () => onGameUpdate(score, 0, true),
    );
    add(gameTimer);
    timeLeft = gameDuration.toDouble();
    add(TimerComponent(
      period: 1,
      repeat: true,
      onTick: () {
        timeLeft--;
        onGameUpdate(score, timeLeft, false);
      },
    ));

    // Spawn a new target every 0.7 seconds (adjust for difficulty if needed)
    add(TimerComponent(
      period: 0.7,
      repeat: true,
      onTick: () {
        if (timeLeft > 0) {
          _spawnTarget();
        }
      },
    ));
  }

  void _spawnTarget() {
    if (timeLeft <= 0) return;
    final type = _rand.nextDouble() < 0.7 ? TargetType.positive : TargetType.negative;
    final value = type == TargetType.positive ? (_rand.nextInt(3) + 1) * 10 : -(_rand.nextInt(2) + 1) * 10;
    // Shorter duration for harder targets
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
    // Remove target after its duration
    add(TimerComponent(
      period: duration,
      removeOnFinish: true,
      onTick: () {
        if (targets.contains(target)) {
          target.removeFromParent();
          targets.remove(target);
        }
      },
    ));
  }

  void _onTargetHit(Target target) {
    score += target.value;
    onGameUpdate(score, timeLeft, false);
    target.removeFromParent();
    targets.remove(target);
  }

  void endGame() {
    // Remove all targets
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
  void onMouseMove(PointerHoverInfo info) {
    paw.position = info.eventPosition.global;
  }

  @override
  void onMouseHover(PointerHoverInfo info) {
    paw.position = info.eventPosition.global;
  }
}

class Target extends SpriteComponent with TapCallbacks {
  final TargetType type;
  final int value;
  final double duration;
  final void Function(Target) onHit;

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
  }

  @override
  void update(double dt) {
    super.update(dt);
    // On desktop/web, trigger hit if paw overlaps target (hover)
    final parentGame = findGame() as AimCatGame?;
    if (parentGame != null && parentGame.paw.toRect().overlaps(toRect())) {
      onHit(this);
    }
  }

  @override
  @override
  void onTapDown(TapDownEvent event) {
    onHit(this);
  }
}
