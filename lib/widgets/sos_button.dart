import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Big glowing SOS button. Long-press for 3 seconds to trigger,
/// with a visible progress ring so the user knows it's registering.
class SosButton extends StatefulWidget {
  final VoidCallback onTriggered;
  final Duration holdDuration;

  const SosButton({
    super.key,
    required this.onTriggered,
    this.holdDuration = const Duration(seconds: 3),
  });

  @override
  State<SosButton> createState() => _SosButtonState();
}

class _SosButtonState extends State<SosButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isHolding = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.holdDuration);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onTriggered();
        _resetHold();
      }
    });
  }

  void _startHold() {
    setState(() => _isHolding = true);
    _controller.forward(from: 0);
  }

  void _resetHold() {
    setState(() => _isHolding = false);
    _controller.stop();
    _controller.reset();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (_) => _startHold(),
      onLongPressEnd: (_) => _resetHold(),
      onLongPressCancel: () => _resetHold(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return SizedBox(
            width: 220,
            height: 220,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer glow ripple
                Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.sosRed.withOpacity(0.15),
                  ),
                ),
                // Progress ring while holding
                SizedBox(
                  width: 190,
                  height: 190,
                  child: CircularProgressIndicator(
                    value: _isHolding ? _controller.value : 0,
                    strokeWidth: 6,
                    backgroundColor: Colors.transparent,
                    valueColor: const AlwaysStoppedAnimation(AppColors.warmOrange),
                  ),
                ),
                // Core button
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.sosRed,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.sosRed.withOpacity(0.5),
                        blurRadius: _isHolding ? 30 : 16,
                        spreadRadius: _isHolding ? 6 : 2,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'SOS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
