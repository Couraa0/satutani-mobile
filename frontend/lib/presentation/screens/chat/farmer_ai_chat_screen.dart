import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/services/ai_chat_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Model
// ─────────────────────────────────────────────────────────────────────────────

enum _Sender { user, ai }

class _Message {
  final String text;
  final _Sender sender;
  final DateTime time;
  final bool isError;

  _Message({
    required this.text,
    required this.sender,
    DateTime? time,
    this.isError = false,
  }) : time = time ?? DateTime.now();
}

// ─────────────────────────────────────────────────────────────────────────────
// Quick Prompts — konteks pertanian untuk petani
// ─────────────────────────────────────────────────────────────────────────────

const _kQuickPrompts = [
  ('🌱', 'Komoditas apa yang cocok ditanam bulan ini?'),
  ('🌤️', 'Bagaimana kondisi cuaca untuk lahan saya?'),
  ('💰', 'Cek harga pasar komoditas saya'),
  ('📅', 'Kapan waktu terbaik mulai tanam cabai?'),
  ('🐛', 'Hama apa yang perlu diwaspadai musim ini?'),
  ('📊', 'Estimasi hasil panen jagung 1 hektar'),
];

// ─────────────────────────────────────────────────────────────────────────────
// Widget Utama
// ─────────────────────────────────────────────────────────────────────────────

class FarmerAiChatScreen extends StatefulWidget {
  const FarmerAiChatScreen({super.key});

  @override
  State<FarmerAiChatScreen> createState() => _FarmerAiChatScreenState();
}

class _FarmerAiChatScreenState extends State<FarmerAiChatScreen>
    with TickerProviderStateMixin {
  final TextEditingController _ctrl = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final FocusNode _focusNode = FocusNode();

  final List<_Message> _messages = [];
  bool _isLoading = false;
  bool _showPrompts = true;
  bool _isAiOnline = true;

  String _selectedWilayah = 'Lembang';
  List<String> _wilayahList = AiChatService.defaultWilayah;

  // Animasi typing dots
  late AnimationController _dotController;
  late Animation<double> _dotAnim;

  @override
  void initState() {
    super.initState();
    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
    _dotAnim = CurvedAnimation(parent: _dotController, curve: Curves.easeInOut);

    _addWelcomeMessage();
    _loadWilayah();
    _checkStatus();
  }

  void _addWelcomeMessage() {
    _messages.add(_Message(
      text:
          'Halo Pak/Bu Petani! 👋\n\nSaya **SatuTani AI** — asisten pertanian cerdas Anda.\n\nSaya bisa membantu:\n• 🌱 Rekomendasi komoditas berdasarkan cuaca\n• 📅 Jadwal tanam optimal 8 minggu ke depan\n• 💰 Estimasi hasil panen & pendapatan\n• 🐛 Info hama & penyakit tanaman\n• 📊 Harga pasar terkini\n\nSilakan pilih topik di bawah atau ketik pertanyaan Anda!',
      sender: _Sender.ai,
    ));
  }

  Future<void> _loadWilayah() async {
    final list = await AiChatService.getWilayah();
    if (mounted && list.isNotEmpty) {
      setState(() => _wilayahList = list);
    }
  }

  Future<void> _checkStatus() async {
    final online = await AiChatService.isAiServiceOnline();
    if (mounted) setState(() => _isAiOnline = online);
  }

  // ── Send Logic ───────────────────────────────────────────────────────────

  void _send([String? text]) {
    final msg = (text ?? _ctrl.text).trim();
    if (msg.isEmpty || _isLoading) return;

    _ctrl.clear();
    _focusNode.unfocus();
    setState(() {
      _showPrompts = false;
      _messages.add(_Message(text: msg, sender: _Sender.user));
      _isLoading = true;
    });
    _scrollToBottom();

    AiChatService.sendMessage(message: msg, wilayah: _selectedWilayah)
        .then((res) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _messages.add(_Message(text: res.reply, sender: _Sender.ai));
      });
      _scrollToBottom();
    }).catchError((e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _messages.add(_Message(
          text: e.toString().replaceFirst('Exception: ', ''),
          sender: _Sender.ai,
          isError: true,
        ));
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildWilayahSelector(),
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              itemCount: _messages.length +
                  (_isLoading ? 1 : 0) +
                  (_showPrompts && !_isLoading ? 1 : 0),
              itemBuilder: (ctx, i) {
                // Typing indicator
                if (_isLoading && i == _messages.length) {
                  return _buildTypingIndicator();
                }
                // Quick prompts setelah welcome message
                if (_showPrompts && !_isLoading && i == _messages.length) {
                  return _buildQuickPrompts();
                }
                return _buildBubble(_messages[i]);
              },
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primaryDark, AppColors.primary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
            ),
            child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'SatuTani AI',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: _isAiOnline ? AppColors.success : Colors.orange,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _isAiOnline ? 'Online' : 'Menghubungkan...',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.85),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      actions: [
        // Badge eksklusif petani
        Container(
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.secondary.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            '🌾 Petani',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  // ── Wilayah Selector ─────────────────────────────────────────────────────

  Widget _buildWilayahSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on_rounded, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          const Text(
            'Wilayah:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedWilayah,
                isDense: true,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
                icon: const Icon(Icons.keyboard_arrow_down_rounded,
                    size: 18, color: AppColors.primary),
                items: _wilayahList
                    .map((w) => DropdownMenuItem(value: w, child: Text(w)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedWilayah = val);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Chat Bubble ───────────────────────────────────────────────────────────

  Widget _buildBubble(_Message msg) {
    final isUser = msg.sender == _Sender.user;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            _buildAiAvatar(),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.78,
              ),
              decoration: BoxDecoration(
                color: msg.isError
                    ? const Color(0xFFFFEBEE)
                    : isUser
                        ? AppColors.primary
                        : AppColors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: msg.isError
                    ? Border.all(color: AppColors.danger.withOpacity(0.3))
                    : !isUser
                        ? Border.all(color: AppColors.border, width: 0.5)
                        : null,
              ),
              child: _buildBubbleText(msg, isUser),
            ),
          ),
          if (isUser) const SizedBox(width: 4),
        ],
      ),
    );
  }

  Widget _buildBubbleText(_Message msg, bool isUser) {
    // Parse **bold** sederhana
    final spans = _parseBoldText(
      msg.text,
      baseStyle: TextStyle(
        color: msg.isError
            ? AppColors.danger
            : isUser
                ? Colors.white
                : AppColors.textPrimary,
        fontSize: 14,
        height: 1.5,
      ),
      boldColor: msg.isError
          ? AppColors.danger
          : isUser
              ? Colors.white
              : AppColors.primary,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (msg.isError)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: const [
                Icon(Icons.error_outline_rounded, size: 14, color: AppColors.danger),
                SizedBox(width: 4),
                Text(
                  'Terjadi Kesalahan',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.danger,
                  ),
                ),
              ],
            ),
          ),
        RichText(text: TextSpan(children: spans)),
        const SizedBox(height: 4),
        Text(
          _formatTime(msg.time),
          style: TextStyle(
            fontSize: 10,
            color: isUser
                ? Colors.white.withOpacity(0.65)
                : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  List<TextSpan> _parseBoldText(
    String text, {
    required TextStyle baseStyle,
    required Color boldColor,
  }) {
    final spans = <TextSpan>[];
    final regex = RegExp(r'\*\*(.*?)\*\*');
    int lastEnd = 0;
    for (final match in regex.allMatches(text)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: text.substring(lastEnd, match.start),
          style: baseStyle,
        ));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: baseStyle.copyWith(
          fontWeight: FontWeight.bold,
          color: boldColor,
        ),
      ));
      lastEnd = match.end;
    }
    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd), style: baseStyle));
    }
    return spans.isEmpty ? [TextSpan(text: text, style: baseStyle)] : spans;
  }

  Widget _buildAiAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(Icons.eco_rounded, color: Colors.white, size: 16),
    );
  }

  // ── Typing Indicator ──────────────────────────────────────────────────────

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildAiAvatar(),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
              ),
              border: Border.all(color: AppColors.border, width: 0.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: AnimatedBuilder(
              animation: _dotAnim,
              builder: (_, __) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (i) {
                    final delay = i * 0.33;
                    final val = (((_dotAnim.value + delay) % 1.0));
                    final scale = 0.6 + 0.4 * (val < 0.5 ? val * 2 : (1 - val) * 2);
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Transform.scale(
                        scale: scale,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.6 + 0.4 * scale),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'AI sedang berpikir...',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  // ── Quick Prompts ─────────────────────────────────────────────────────────

  Widget _buildQuickPrompts() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 40, bottom: 8),
            child: Text(
              'Pilih topik untuk mulai:',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _kQuickPrompts.map((item) {
              return GestureDetector(
                onTap: () => _send(item.$2),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.35),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.08),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(item.$1, style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 6),
                      Text(
                        item.$2,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── Input Bar ─────────────────────────────────────────────────────────────

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _ctrl,
                focusNode: _focusNode,
                maxLines: 4,
                minLines: 1,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  hintText: 'Tanya soal komoditas, cuaca, hama...',
                  hintStyle: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary.withOpacity(0.7),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  isDense: true,
                ),
                style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                onSubmitted: (_) => _send(),
              ),
            ),
            const SizedBox(width: 8),
            AnimatedBuilder(
              animation: _ctrl,
              builder: (_, __) {
                final hasText = _ctrl.text.trim().isNotEmpty;
                return GestureDetector(
                  onTap: _send,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: hasText && !_isLoading
                          ? const LinearGradient(
                              colors: [AppColors.primary, AppColors.primaryDark],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: hasText && !_isLoading ? null : AppColors.border,
                      shape: BoxShape.circle,
                      boxShadow: hasText && !_isLoading
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      _isLoading
                          ? Icons.hourglass_top_rounded
                          : Icons.send_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    _focusNode.dispose();
    _dotController.dispose();
    super.dispose();
  }
}
