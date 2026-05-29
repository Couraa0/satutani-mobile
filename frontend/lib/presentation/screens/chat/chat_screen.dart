import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';

class _ChatMessage {
  final String text;
  final bool isUser;
  _ChatMessage({required this.text, required this.isUser});
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showChips = true;

  final List<_ChatMessage> _messages = [
    _ChatMessage(text: 'Halo! Saya asisten AI SatuTani 🌾 Saya siap membantu Anda. Ada yang bisa saya bantu?', isUser: false),
  ];

  final _quickReplies = [
    'Rekomendasi sayur segar',
    'Cek status pesanan',
    'Tips penyimpanan buah',
    'Promosi hari ini',
  ];

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _showChips = false;
      _messages.add(_ChatMessage(text: text, isUser: true));
      _controller.clear();
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      setState(() {
        _messages.add(_ChatMessage(text: _generateBotReply(text), isUser: false));
      });
      _scrollToBottom();
    });
  }

  String _generateBotReply(String msg) {
    final lower = msg.toLowerCase();
    if (lower.contains('segar') || lower.contains('sayur')) {
      return '🌱 Hari ini tersedia: **Bayam Organik** dari Bu Sari (Bandung), **Tomat Cherry** dari Bu Rina (Batu), dan **Mangga Harum Manis** dari Pak Hartono (Indramayu). Semua segar dipanen hari ini!';
    } else if (lower.contains('pesanan') || lower.contains('status')) {
      return '📦 Pesanan terbaru Anda **ORD-001** (Beras Premium 5kg) sedang dalam pengiriman. Estimasi tiba: besok pukul 10:00. Suhu cold chain: 4°C ✅';
    }
    return 'Terima kasih atas pertanyaannya! Saya sedang mencari informasi terbaik untuk Anda. Apakah ada hal lain yang bisa saya bantu terkait produk pertanian?';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
              child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Asisten AI', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                Row(children: [
                  Container(width: 7, height: 7, decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle)),
                  const SizedBox(width: 4),
                  Text('Online', style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.85))),
                ]),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_showChips ? 1 : 0),
              itemBuilder: (context, index) {
                if (_showChips && index == _messages.length) return _buildQuickReplies();
                return _buildChatBubble(_messages[index]);
              },
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildChatBubble(_ChatMessage msg) {
    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: msg.isUser ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(msg.isUser ? 16 : 4),
            bottomRight: Radius.circular(msg.isUser ? 4 : 16),
          ),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 1))],
        ),
        child: Text(
          msg.text,
          style: TextStyle(color: msg.isUser ? Colors.white : AppColors.textPrimary, fontSize: 14, height: 1.4),
        ),
      ),
    );
  }

  Widget _buildQuickReplies() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Wrap(
        spacing: 8, runSpacing: 8,
        children: _quickReplies.map((chip) => GestureDetector(
          onTap: () => _sendMessage(chip),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surface, borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
            ),
            child: Text(chip, style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w500)),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, -2))],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Tulis pesan...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
                  filled: true, fillColor: AppColors.background,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), isDense: true,
                ),
                onSubmitted: _sendMessage,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _sendMessage(_controller.text),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
