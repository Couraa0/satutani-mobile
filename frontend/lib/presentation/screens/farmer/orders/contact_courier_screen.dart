import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../data/mock/orders_mock.dart';

// ── Simple courier data model ─────────────────────────────────────────────────

class CourierModel {
  final String id, name, service, phone, vehicle;
  final double rating;
  final int deliveries;
  final String eta, price;
  final bool available;
  const CourierModel({
    required this.id,
    required this.name,
    required this.service,
    required this.phone,
    required this.vehicle,
    required this.rating,
    required this.deliveries,
    required this.eta,
    required this.price,
    this.available = true,
  });
}

const _mockCouriers = [
  CourierModel(
    id: 'k1', name: 'Joko Susilo', service: 'SatuTani Express',
    phone: '085712345678', vehicle: 'Motor Box',
    rating: 4.9, deliveries: 312, eta: '45–60 mnt', price: 'Rp 15.000',
  ),
  CourierModel(
    id: 'k2', name: 'Rahmat Hidayat', service: 'Agri Kurir',
    phone: '081234567890', vehicle: 'Pick-up',
    rating: 4.7, deliveries: 187, eta: '60–90 mnt', price: 'Rp 25.000',
  ),
  CourierModel(
    id: 'k3', name: 'Soni Permadi', service: 'SatuTani Express',
    phone: '082198765432', vehicle: 'Motor Box',
    rating: 4.8, deliveries: 254, eta: '30–45 mnt', price: 'Rp 15.000',
    available: false,
  ),
  CourierModel(
    id: 'k4', name: 'Mitra Logistik', service: 'Cold Chain Delivery',
    phone: '021-55667788', vehicle: 'Truk Berpendingin',
    rating: 4.6, deliveries: 98, eta: '2–3 jam', price: 'Rp 75.000',
  ),
];

// ── Main Screen ───────────────────────────────────────────────────────────────

class ContactCourierScreen extends StatefulWidget {
  final OrderModel order;
  const ContactCourierScreen({super.key, required this.order});

  @override
  State<ContactCourierScreen> createState() => _ContactCourierScreenState();
}

class _ContactCourierScreenState extends State<ContactCourierScreen>
    with SingleTickerProviderStateMixin {
  String? _selectedCourierId;
  bool _confirmed = false;
  late AnimationController _checkAnim;
  late Animation<double> _checkScale;

  @override
  void initState() {
    super.initState();
    _checkAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _checkScale = CurvedAnimation(parent: _checkAnim, curve: Curves.elasticOut);
  }

  @override
  void dispose() {
    _checkAnim.dispose();
    super.dispose();
  }

  CourierModel? get _selected =>
      _selectedCourierId == null ? null : _mockCouriers.firstWhere((c) => c.id == _selectedCourierId);

  void _confirmCourier() {
    if (_selectedCourierId == null) return;
    setState(() => _confirmed = true);
    _checkAnim.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Hubungi Kurir', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _confirmed ? _buildSuccessView() : _buildFormView(),
    );
  }

  // ── Success state ───────────────────────────────────────────────────────────

  Widget _buildSuccessView() {
    final c = _selected!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ScaleTransition(
            scale: _checkScale,
            child: Container(
              width: 96, height: 96,
              decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 52),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Kurir Dihubungi!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(
            '${c.name} dari ${c.service} sedang dalam perjalanan menuju lahan Anda.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 28),
          _infoRow(Icons.schedule_rounded, 'Estimasi tiba', c.eta),
          const SizedBox(height: 10),
          _infoRow(Icons.directions_car_rounded, 'Kendaraan', c.vehicle),
          const SizedBox(height: 10),
          _infoRow(Icons.phone_rounded, 'Nomor kurir', c.phone),
          const SizedBox(height: 32),
          Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showCallDialog(c),
                icon: const Icon(Icons.phone_rounded, size: 18),
                label: const Text('Telepon', style: TextStyle(fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary, width: 1.5),
                  minimumSize: const Size(0, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _showChatSheet(c),
                icon: const Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 18),
                label: const Text('Chat', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(0, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Kembali ke Pesanan', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface, borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)],
      ),
      child: Row(children: [
        Icon(icon, color: AppColors.primary, size: 18),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        const Spacer(),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
      ]),
    );
  }

  // ── Form state ──────────────────────────────────────────────────────────────

  Widget _buildFormView() {
    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        _buildOrderSummary(),
        _buildPickupInfo(),
        _buildCourierList(),
      ],
    );
  }

  // Order summary card at top
  Widget _buildOrderSummary() {
    final o = widget.order;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF1B5E20)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.receipt_long_rounded, color: Colors.white70, size: 16),
          const SizedBox(width: 6),
          Text('#${o.id}', style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('Siap Dikirim', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
          ),
        ]),
        const SizedBox(height: 12),
        Text(
          o.items.map((i) => '${i.productName} ×${i.quantity}${i.unit}').join('\n'),
          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700, height: 1.5),
        ),
        const SizedBox(height: 10),
        const Divider(color: Colors.white24, height: 1),
        const SizedBox(height: 10),
        Row(children: [
          const Icon(Icons.location_on_rounded, color: Colors.white70, size: 15),
          const SizedBox(width: 6),
          Expanded(
            child: Text(o.address, style: const TextStyle(color: Colors.white70, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
          ),
        ]),
        const SizedBox(height: 6),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Total Pesanan', style: TextStyle(color: Colors.white70, fontSize: 12)),
          Text(
            'Rp ${o.total.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15),
          ),
        ]),
      ]),
    );
  }

  // Pickup info
  Widget _buildPickupInfo() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.secondaryLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.35)),
      ),
      child: Row(children: [
        const Text('🌾', style: TextStyle(fontSize: 22)),
        const SizedBox(width: 10),
        const Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Lokasi Penjemputan', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            SizedBox(height: 2),
            Text('Lahan Anda · Jl. Raya Bogor KM 25, Bogor', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ]),
        ),
        TextButton(
          onPressed: () {},
          child: const Text('Ubah', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w700)),
        ),
      ]),
    );
  }

  // Courier list
  Widget _buildCourierList() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Padding(
        padding: EdgeInsets.fromLTRB(16, 20, 16, 10),
        child: Text(
          'PILIH KURIR',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 1.2),
        ),
      ),
      ..._mockCouriers.map((c) => _CourierCard(
        courier: c,
        isSelected: _selectedCourierId == c.id,
        onTap: c.available ? () => setState(() => _selectedCourierId = c.id) : null,
        onCall: () => _showCallDialog(c),
        onChat: () => _showChatSheet(c),
      )),
      const SizedBox(height: 20),
      // Confirm button (sticky bottom feel via extra padding)
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ElevatedButton.icon(
          onPressed: _selectedCourierId != null ? _confirmCourier : null,
          icon: const Icon(Icons.local_shipping_rounded, color: Colors.white, size: 20),
          label: const Text('Konfirmasi & Hubungi Kurir',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            disabledBackgroundColor: AppColors.border,
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: _selectedCourierId != null ? 3 : 0,
            shadowColor: AppColors.primary.withValues(alpha: 0.4),
          ),
        ),
      ),
    ]);
  }

  // ── Dialogs / Sheets ────────────────────────────────────────────────────────

  void _showCallDialog(CourierModel c) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hubungi via Telepon', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const CircleAvatar(radius: 30, backgroundColor: AppColors.primaryLight,
            child: Icon(Icons.person_rounded, color: AppColors.primary, size: 32)),
          const SizedBox(height: 12),
          Text(c.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 4),
          Text(c.phone, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        ]),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('Batal'),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: () { Navigator.pop(context); _showSnackbar('Menghubungi ${c.name}...'); },
            icon: const Icon(Icons.phone_rounded, color: Colors.white, size: 18),
            label: const Text('Telepon', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  void _showChatSheet(CourierModel c) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ChatSheet(courier: c, order: widget.order),
    );
  }

  void _showSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.success,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }
}

// ── Courier Card ──────────────────────────────────────────────────────────────

class _CourierCard extends StatelessWidget {
  final CourierModel courier;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback onCall;
  final VoidCallback onChat;

  const _CourierCard({
    required this.courier,
    required this.isSelected,
    required this.onTap,
    required this.onCall,
    required this.onChat,
  });

  @override
  Widget build(BuildContext context) {
    final c = courier;
    final unavailable = !c.available;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: unavailable ? AppColors.background : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : (unavailable ? AppColors.border : AppColors.border),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.15), blurRadius: 12, offset: const Offset(0, 4))]
              : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            // Avatar
            Stack(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: isSelected ? AppColors.primary : AppColors.primaryLight,
                  child: Icon(Icons.person_rounded,
                      color: isSelected ? Colors.white : AppColors.primary, size: 24),
                ),
                if (isSelected)
                  Positioned(
                    bottom: 0, right: 0,
                    child: Container(
                      width: 16, height: 16,
                      decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
                      child: const Icon(Icons.check, color: Colors.white, size: 10),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Flexible(
                  child: Text(c.name,
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14,
                          color: unavailable ? AppColors.textSecondary : AppColors.textPrimary)),
                ),
                if (unavailable) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(6)),
                    child: const Text('Tidak Tersedia', style: TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                  ),
                ],
              ]),
              const SizedBox(height: 2),
              Text(c.service, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ])),
            // Radio / selection indicator
            if (!unavailable)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 22, height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: isSelected ? AppColors.primary : AppColors.border, width: 2),
                  color: isSelected ? AppColors.primary : Colors.transparent,
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 14)
                    : null,
              ),
          ]),
          const SizedBox(height: 12),
          // Details row
          Wrap(spacing: 8, runSpacing: 6, children: [
            _chip(Icons.star_rounded, '${c.rating}', AppColors.secondary),
            _chip(Icons.local_shipping_rounded, '${c.deliveries}× pengiriman', AppColors.info),
            _chip(Icons.directions_car_rounded, c.vehicle, AppColors.primary),
            _chip(Icons.schedule_rounded, c.eta, AppColors.success),
            _chip(Icons.payments_outlined, c.price, AppColors.warning),
          ]),
          if (!unavailable) ...[
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onCall,
                  icon: const Icon(Icons.phone_rounded, size: 15),
                  label: const Text('Telepon', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.success,
                    side: const BorderSide(color: AppColors.success),
                    minimumSize: const Size(0, 36),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onChat,
                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 15),
                  label: const Text('Chat', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.info,
                    side: const BorderSide(color: AppColors.info),
                    minimumSize: const Size(0, 36),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                ),
              ),
            ]),
          ],
        ]),
      ),
    );
  }

  Widget _chip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
      ]),
    );
  }
}

// ── In-app Chat Bottom Sheet ──────────────────────────────────────────────────

class _ChatSheet extends StatefulWidget {
  final CourierModel courier;
  final OrderModel order;
  const _ChatSheet({required this.courier, required this.order});

  @override
  State<_ChatSheet> createState() => _ChatSheetState();
}

class _ChatSheetState extends State<_ChatSheet> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  final List<_ChatMessage> _messages = [
    _ChatMessage(text: 'Halo, saya siap menjemput pesanan Anda.', isMe: false, time: '20:01'),
    _ChatMessage(text: 'Berapa lama estimasi sampai ke lahan saya?', isMe: true, time: '20:03'),
    _ChatMessage(text: 'Sekitar 30–45 menit dari lokasi saya sekarang.', isMe: false, time: '20:04'),
  ];

  final _quickReplies = [
    'Oke, ditunggu ya 👍',
    'Tolong hati-hati di jalan',
    'Saya sudah siapkan barangnya',
    'Pakai pintu belakang lahan ya',
  ];

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _send(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add(_ChatMessage(text: text.trim(), isMe: true, time: _nowTime()));
    });
    _msgCtrl.clear();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  String _nowTime() {
    final n = DateTime.now();
    return '${n.hour.toString().padLeft(2, '0')}:${n.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.courier;
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, sheetCtrl) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(children: [
          // Handle
          const SizedBox(height: 8),
          Container(width: 40, height: 4,
            decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
          // Chat header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
            child: Row(children: [
              const CircleAvatar(radius: 22, backgroundColor: AppColors.primaryLight,
                child: Icon(Icons.person_rounded, color: AppColors.primary, size: 24)),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(c.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                const Text('Kurir SatuTani · Online', style: TextStyle(fontSize: 12, color: AppColors.success)),
              ])),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
              ),
            ]),
          ),
          // Order info banner
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(children: [
              const Icon(Icons.inventory_2_outlined, color: AppColors.primary, size: 16),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Pesanan #${widget.order.id}: ${widget.order.items.first.productName}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ]),
          ),
          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _messages.length,
              itemBuilder: (_, i) => _buildBubble(_messages[i]),
            ),
          ),
          // Quick replies
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
              itemCount: _quickReplies.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) => GestureDetector(
                onTap: () => _send(_quickReplies[i]),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: Text(_quickReplies[i],
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.primary)),
                ),
              ),
            ),
          ),
          // Input bar
          Container(
            padding: EdgeInsets.fromLTRB(16, 8, 16, MediaQuery.of(context).viewInsets.bottom + 12),
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.border))),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: _msgCtrl,
                  decoration: InputDecoration(
                    hintText: 'Tulis pesan...',
                    hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    filled: true, fillColor: AppColors.background,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                  ),
                  onSubmitted: _send,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _send(_msgCtrl.text),
                child: Container(
                  width: 44, height: 44,
                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _buildBubble(_ChatMessage msg) {
    return Align(
      alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
        decoration: BoxDecoration(
          color: msg.isMe ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(msg.isMe ? 18 : 4),
            bottomRight: Radius.circular(msg.isMe ? 4 : 18),
          ),
        ),
        child: Column(crossAxisAlignment: msg.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start, children: [
          Text(msg.text, style: TextStyle(fontSize: 13, color: msg.isMe ? Colors.white : AppColors.textPrimary, height: 1.4)),
          const SizedBox(height: 3),
          Text(msg.time, style: TextStyle(fontSize: 10, color: msg.isMe ? Colors.white60 : AppColors.textSecondary)),
        ]),
      ),
    );
  }
}

class _ChatMessage {
  final String text, time;
  final bool isMe;
  const _ChatMessage({required this.text, required this.isMe, required this.time});
}
