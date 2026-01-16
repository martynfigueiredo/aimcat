import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

/// A global wrapper that overlays the Cat Paw cursor on the entire application.
/// Uses smooth interpolation for a cozy, organic cursor feel.
class GlobalPawCursor extends StatefulWidget {
  final Widget child;
  const GlobalPawCursor({super.key, required this.child});

  static _GlobalPawCursorState? of(BuildContext context) {
    return context.findAncestorStateOfType<_GlobalPawCursorState>();
  }

  @override
  State<GlobalPawCursor> createState() => _GlobalPawCursorState();
}

class _GlobalPawCursorState extends State<GlobalPawCursor> with TickerProviderStateMixin {
  // Use ValueNotifier to avoid full widget rebuilds on cursor movement
  final ValueNotifier<Offset> _targetPos = ValueNotifier(Offset.zero);
  final ValueNotifier<Offset> _currentPos = ValueNotifier(Offset.zero);
  
  bool _isTouchDevice = false;
  
  bool get isTouchDevice => _isTouchDevice;

  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  
  // Ticker for smooth cursor interpolation
  Ticker? _ticker;
  
  // Smoothing factor - lower = smoother/slower, higher = snappier
  // 0.85 gives an almost instant, high-performance feel
  static const double _smoothingFactor = 0.85;

  @override
  void initState() {
    super.initState();
    
    // Proactive detection for mobile platforms
    _isTouchDevice = defaultTargetPlatform == TargetPlatform.android || 
                    defaultTargetPlatform == TargetPlatform.iOS;
    
    _pulseController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.85), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 0.85, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeOutCubic,
    ));

    _rotationAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -0.12), weight: 50),
      TweenSequenceItem(tween: Tween(begin: -0.12, end: 0.0), weight: 50),
    ]).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeOutCubic,
    ));
    
    // Start the smooth cursor interpolation ticker
    _ticker = createTicker(_onTick);
    _ticker?.start();
  }
  
  void _onTick(Duration elapsed) {
    if (_isTouchDevice) return;
    
    final current = _currentPos.value;
    final target = _targetPos.value;
    
    // Lerp (linear interpolation) towards target for smooth movement
    final dx = current.dx + (target.dx - current.dx) * _smoothingFactor;
    final dy = current.dy + (target.dy - current.dy) * _smoothingFactor;
    
    // Only update if there's meaningful movement (optimization)
    if ((dx - current.dx).abs() > 0.1 || (dy - current.dy).abs() > 0.1) {
      _currentPos.value = Offset(dx, dy);
    }
  }

  @override
  void dispose() {
    _ticker?.dispose();
    _pulseController.dispose();
    _targetPos.dispose();
    _currentPos.dispose();
    super.dispose();
  }

  void triggerPulse() {
    if (!_isTouchDevice) {
      _pulseController.forward(from: 0);
    }
  }

  void updatePosition(Offset position) {
    if (_isTouchDevice) {
      setState(() {
        _isTouchDevice = false;
      });
    }
    // Update target position - the ticker will smoothly interpolate
    _targetPos.value = position;
  }

  void setTouchMode(bool isTouch) {
    if (_isTouchDevice != isTouch) {
      setState(() {
        _isTouchDevice = isTouch;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: _isTouchDevice ? SystemMouseCursors.basic : SystemMouseCursors.none,
      onHover: (event) {
        if (event.kind != PointerDeviceKind.touch) {
          updatePosition(event.position);
        }
      },
      child: Listener(
        onPointerDown: (event) {
          if (event.kind == PointerDeviceKind.touch) {
            setTouchMode(true);
          } else {
            setTouchMode(false);
            triggerPulse();
          }
        },
        onPointerMove: (event) {
          if (event.kind == PointerDeviceKind.touch) {
            setTouchMode(true);
          } else {
            updatePosition(event.position);
          }
        },
        child: Stack(
          children: [
            widget.child,
            if (!_isTouchDevice)
              // Use RepaintBoundary to isolate cursor repaints
              RepaintBoundary(
                child: ValueListenableBuilder<Offset>(
                  valueListenable: _currentPos,
                  builder: (context, pos, child) {
                    return Transform.translate(
                      offset: pos.translate(-24, -24), // Center the cursor
                      child: child!,
                    );
                  },
                  child: IgnorePointer(
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Transform.rotate(
                            angle: _rotationAnimation.value,
                            child: const Icon(
                              Icons.pets,
                              size: 48,
                              color: Color(0xFFFFC107),
                              shadows: [
                                Shadow(
                                  color: Colors.black26,
                                  blurRadius: 6,
                                  offset: Offset(2, 2),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
