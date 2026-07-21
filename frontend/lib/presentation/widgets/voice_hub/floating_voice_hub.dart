import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/colors.dart';
import '../../providers/farmer_voice_provider.dart';
import 'audio_waveform_widget.dart';

class FloatingVoiceHub extends ConsumerStatefulWidget {
  const FloatingVoiceHub({super.key});

  @override
  ConsumerState<FloatingVoiceHub> createState() => _FloatingVoiceHubState();
}

class _FloatingVoiceHubState extends ConsumerState<FloatingVoiceHub>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;
  final TextEditingController _customVoiceInputCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 1.0, end: 1.22).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _customVoiceInputCtrl.dispose();
    super.dispose();
  }

  void _onMicPressed() {
    final voiceState = ref.read(farmerVoiceProvider).voiceState;

    if (voiceState == VoiceState.idle) {
      ref.read(farmerVoiceProvider.notifier).startListening();
      _showVoiceSheet();
    } else {
      ref.read(farmerVoiceProvider.notifier).stopListening();
    }
  }

  void _showVoiceSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _VoiceSheetOverlay(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vState = ref.watch(farmerVoiceProvider).voiceState;
    final isListening = vState == VoiceState.listening;
    final isProcessing = vState == VoiceState.processing;
    final isSpeaking = vState == VoiceState.speaking;

    Color orbColor = AppColors.primary;
    IconData iconData = Icons.mic_rounded;

    if (isListening) {
      orbColor = Colors.redAccent;
      iconData = Icons.graphic_eq_rounded;
    } else if (isProcessing) {
      orbColor = AppColors.info;
      iconData = Icons.hourglass_top_rounded;
    } else if (isSpeaking) {
      orbColor = AppColors.secondary;
      iconData = Icons.volume_up_rounded;
    }

    return GestureDetector(
      onTap: _onMicPressed,
      child: AnimatedBuilder(
        animation: _pulseAnim,
        builder: (context, child) {
          final scale = (isListening || isSpeaking) ? _pulseAnim.value : 1.0;
          return Transform.scale(
            scale: scale,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer Pulse Ring
                if (isListening || isSpeaking)
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: orbColor.withValues(alpha: 0.25),
                    ),
                  ),

                // Main Voice Orb
                Container(
                  width: 66,
                  height: 66,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        orbColor,
                        orbColor.withValues(alpha: 0.85),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: orbColor.withValues(alpha: 0.45),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                        spreadRadius: 2,
                      ),
                    ],
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: Center(
                    child: Icon(
                      iconData,
                      color: Colors.white,
                      size: 32,
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

class _VoiceSheetOverlay extends ConsumerStatefulWidget {
  const _VoiceSheetOverlay();

  @override
  ConsumerState<_VoiceSheetOverlay> createState() => _VoiceSheetOverlayState();
}

class _VoiceSheetOverlayState extends ConsumerState<_VoiceSheetOverlay> {
  final TextEditingController _inputCtrl = TextEditingController();

  final List<String> _voicePresets = [
    "Tolong saya ingin memasukan wortel 70 kg ke produk saya.",
    "Cek riwayat penjualan saya minggu ini",
    "Berapa total wortel yang laku?",
    "Hama apa yang perlu diwaspadai musim ini?",
    "Rekomendasi pupuk terbaik untuk tanaman cabai",
  ];

  void _sendPreset(String text) {
    ref.read(farmerVoiceProvider.notifier).processSpeech(text);
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vState = ref.watch(farmerVoiceProvider);
    final voiceStatus = vState.voiceState;

    String headerStatus = "🎤 Katakan Perintah Anda";
    if (voiceStatus == VoiceState.listening) headerStatus = "🔴 Mendengarkan Suara Petani...";
    if (voiceStatus == VoiceState.processing) headerStatus = "⏳ Memproses Maksud & Exec API...";
    if (voiceStatus == VoiceState.speaking) headerStatus = "🔊 AI Membalas Suara Anda";

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 20,
        right: 20,
        top: 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 24, offset: Offset(0, -6)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                headerStatus,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
              IconButton(
                onPressed: () {
                  ref.read(farmerVoiceProvider.notifier).stopListening();
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.close_rounded, color: Colors.grey),
              ),
            ],
          ),

          // Dynamic Audio Waveform Visualizer
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: AudioWaveformWidget(state: voiceStatus, height: 44),
          ),

          // Recognized Text Display Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.record_voice_over_rounded, size: 16, color: AppColors.primary),
                    SizedBox(width: 6),
                    Text(
                      'Suara Terdeteksi:',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  vState.recognizedText.isEmpty ? 'Katakan sesuatu...' : '"${vState.recognizedText}"',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),

          // Speech Response / Action Card
          if (vState.speechResponse.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.smart_toy_rounded, size: 16, color: AppColors.primary),
                      SizedBox(width: 6),
                      Text(
                        'Respon AI (TTS Audio Output):',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    vState.speechResponse,
                    style: const TextStyle(fontSize: 13, height: 1.4, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),
          const Text(
            'Atau pilih simulasi perintah suara cepat:',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),

          // Preset Voice Shortcuts Chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _voicePresets.map((preset) {
              return ActionChip(
                avatar: const Icon(Icons.mic_none_rounded, size: 16, color: AppColors.primary),
                label: Text(
                  preset,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary),
                ),
                backgroundColor: AppColors.surface,
                side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
                onPressed: () => _sendPreset(preset),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Direct Custom Voice Prompt Simulator Input
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _inputCtrl,
                  decoration: InputDecoration(
                    hintText: 'Ketik perintah suara langsung...',
                    hintStyle: const TextStyle(fontSize: 12),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(fontSize: 13),
                  onSubmitted: (val) {
                    if (val.trim().isNotEmpty) {
                      _sendPreset(val.trim());
                      _inputCtrl.clear();
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: () {
                  if (_inputCtrl.text.trim().isNotEmpty) {
                    _sendPreset(_inputCtrl.text.trim());
                    _inputCtrl.clear();
                  }
                },
                icon: const Icon(Icons.send_rounded, size: 18),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
