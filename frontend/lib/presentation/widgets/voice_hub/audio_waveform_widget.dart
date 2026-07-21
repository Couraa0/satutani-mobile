import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../providers/farmer_voice_provider.dart';

class AudioWaveformWidget extends StatefulWidget {
  final VoiceState state;
  final double height;
  final Color primaryColor;

  const AudioWaveformWidget({
    super.key,
    required this.state,
    this.height = 48,
    this.primaryColor = AppColors.primary,
  });

  @override
  State<AudioWaveformWidget> createState() => _AudioWaveformWidgetState();
}

class _AudioWaveformWidgetState extends State<AudioWaveformWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isListening = widget.state == VoiceState.listening;
    final isProcessing = widget.state == VoiceState.processing;
    final isSpeaking = widget.state == VoiceState.speaking;

    return AnimatedBuilder(
      animation: _animCtrl,
      builder: (context, child) {
        return SizedBox(
          height: widget.height,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(14, (i) {
              double barHeight = 8.0;

              if (isListening) {
                // Dynamic listening audio bar heights based on sine phase
                final phase = (_animCtrl.value * 2 * math.pi) + (i * 0.45);
                barHeight = 12.0 + (math.sin(phase).abs() * (widget.height - 16));
              } else if (isProcessing) {
                // Gentle pulse cycle for processing state
                final phase = (_animCtrl.value * 2 * math.pi) + (i * 0.2);
                barHeight = 10.0 + (math.cos(phase).abs() * 16);
              } else if (isSpeaking) {
                // Smooth TTS speech frequency wave pattern
                final phase = (_animCtrl.value * 3 * math.pi) - (i * 0.35);
                barHeight = 10.0 + (math.sin(phase).abs() * (widget.height - 12));
              } else {
                // Idle static low frequency dots
                barHeight = (i % 2 == 0) ? 10.0 : 6.0;
              }

              final Color color = isListening
                  ? Colors.redAccent
                  : isSpeaking
                      ? AppColors.secondary
                      : isProcessing
                          ? AppColors.info
                          : AppColors.primary.withValues(alpha: 0.4);

              return AnimatedContainer(
                duration: const Duration(milliseconds: 80),
                margin: const EdgeInsets.symmetric(horizontal: 2.5),
                width: 4.0,
                height: barHeight,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: isListening || isSpeaking
                      ? [
                          BoxShadow(
                            color: color.withValues(alpha: 0.5),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
