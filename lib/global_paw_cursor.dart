import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';

/// A global wrapper that overlays the Cat Paw cursor on the entire application.
class GlobalPawCursor extends StatefulWidget {
  final Widget child;
  const GlobalPawCursor({super.key, required this.child});

  static _GlobalPawCursorState? of(BuildContext context) {
    return context.findAncestorStateOfType<_GlobalPawCursorState>();
  }

  @override
  State<GlobalPawCursor> createState() => _GlobalPawCursorState();
}

class _GlobalPawCursorState extends State<GlobalPawCursor> with SingleTickerProviderStateMixin {
  Offset _cursorPos = Offset.zero;
  bool _isTouchDevice = false;
  
  bool get isTouchDevice => _isTouchDevice;

  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    
    // Proactive detection for mobile platforms
    _isTouchDevice = defaultTargetPlatform == TargetPlatform.android || 
                    defaultTargetPlatform == TargetPlatform.iOS;
    
    _pulseController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.8), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 0.8, end: 1.0), weight: 50),
    ]).animate(_pulseController);

    _rotationAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -0.1), weight: 50),
      TweenSequenceItem(tween: Tween(begin: -0.1, end: 0.0), weight: 50),
    ]).animate(_pulseController);
  }

  @override
  void dispose() {
    _pulseController.dispose();
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
        _cursorPos = position;
      });
    } else {
      setState(() {
        _cursorPos = position;
      });
    }
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
              Positioned(
                left: _cursorPos.dx - 24,
                top: _cursorPos.dy - 24,
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
                                blurRadius: 4,
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
          ],
        ),
      ),
    );
  }
}
