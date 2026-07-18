import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

/// Simulates an incoming call screen so the user has a discreet
/// excuse to leave an uncomfortable/dangerous situation.
class FakeCallScreen extends StatefulWidget {
  const FakeCallScreen({super.key});

  @override
  State<FakeCallScreen> createState() => _FakeCallScreenState();
}

class _FakeCallScreenState extends State<FakeCallScreen> {
  bool _isRinging = true;
  Timer? _callTimer;
  int _callSeconds = 0;
  final _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _startRinging();
  }

  Future<void> _startRinging() async {
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    await _audioPlayer.play(AssetSource('sounds/ringtone.wav'));
  }

  Future<void> _stopRinging() async {
    await _audioPlayer.stop();
  }

  void _acceptCall() {
    _stopRinging();
    setState(() => _isRinging = false);
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _callSeconds++);
    });
  }

  void _declineCall() {
    _stopRinging();
    Navigator.of(context).pop();
  }

  void _endCall() {
    _stopRinging();
    _callTimer?.cancel();
    Navigator.of(context).pop();
  }

  String get _formattedDuration {
    final minutes = (_callSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_callSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _callTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: Colors.white12),
                child:
                    const Icon(Icons.person, size: 64, color: Colors.white70),
              ),
              const SizedBox(height: 28),
              const Text(
                'Mom',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 10),
              Text(
                _isRinging ? 'Incoming call…' : _formattedDuration,
                style: const TextStyle(color: Colors.white54, fontSize: 16),
              ),
              const Spacer(),
              if (_isRinging)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _CallButton(
                        icon: Icons.call_end,
                        color: const Color(0xFFE53935),
                        onTap: _declineCall),
                    _CallButton(
                        icon: Icons.call,
                        color: const Color(0xFF43A047),
                        onTap: _acceptCall),
                  ],
                )
              else
                _CallButton(
                    icon: Icons.call_end,
                    color: const Color(0xFFE53935),
                    onTap: _endCall),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _CallButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CallButton(
      {required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        child: Icon(icon, color: Colors.white, size: 30),
      ),
    );
  }
}
