import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/colors.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _minOrderCtrl = TextEditingController(text: '5');

  String _selectedCategory = 'Sayuran';
  String _selectedUnit = 'kg';
  int _stock = 50;
  bool _preOrderEnabled = false;
  DateTime _harvestDate = DateTime.now().add(const Duration(days: 5));

  // Simulates photos selected (0 = empty slot, used for demo)
  final List<String?> _photos = [null, null, null, null, null];

  static const _categories = [
    'Sayuran', 'Buah', 'Beras & Biji', 'Rempah', 'Umbi', 'Kacang-kacangan', 'Lainnya',
  ];

  static const _units = ['kg', 'gram', 'ikat', 'buah', 'liter', 'karung'];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _minOrderCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickHarvestDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _harvestDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _harvestDate = picked);
  }

  void _saveProduct() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(children: [
            Icon(Icons.check_circle_rounded, color: Colors.white),
            SizedBox(width: 10),
            Text('Produk berhasil disimpan!', style: TextStyle(fontWeight: FontWeight.w600)),
          ]),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Tambah Produk',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _saveProduct,
            child: const Text(
              'Simpan',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            _buildPhotoSection(),
            const SizedBox(height: 12),
            _buildSectionLabel('INFORMASI PRODUK'),
            _buildInfoCard(),
            const SizedBox(height: 12),
            _buildSectionLabel('HARGA & STOK'),
            _buildPriceStockCard(),
            const SizedBox(height: 12),
            _buildSectionLabel('JADWAL PANEN'),
            _buildHarvestCard(),
            const SizedBox(height: 24),
            _buildBottomButtons(),
          ],
        ),
      ),
    );
  }

  // ── Section label ──────────────────────────────────────────────────────────

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildCard(Widget child) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: child,
    );
  }

  // ── Photo section ──────────────────────────────────────────────────────────

  Widget _buildPhotoSection() {
    final hasPhotos = _photos.any((p) => p != null);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionLabel('FOTO PRODUK'),
          // Main upload area
          if (!hasPhotos)
            GestureDetector(
              onTap: () => _addPhoto(0),
              child: Container(
                height: 160,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    width: 2,
                    strokeAlign: BorderSide.strokeAlignInside,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt_rounded, color: AppColors.primary, size: 30),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Tap untuk upload foto',
                      style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Maks. 5 foto · JPG, PNG',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
          // Thumbnail row
          const SizedBox(height: 10),
          SizedBox(
            height: 72,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) => _buildPhotoThumb(i),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Foto pertama jadi foto utama produk',
            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoThumb(int index) {
    final isFirst = index == 0 && _photos[0] != null;
    return GestureDetector(
      onTap: () => _addPhoto(index),
      child: Container(
        width: 72,
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isFirst ? AppColors.primary : AppColors.border,
            width: isFirst ? 2 : 1,
          ),
        ),
        child: _photos[index] != null
            ? Stack(children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(11),
                  child: Container(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    child: const Center(child: Icon(Icons.eco_rounded, color: AppColors.primary, size: 28)),
                  ),
                ),
                if (isFirst)
                  Positioned(
                    bottom: 4, left: 0, right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('Utama', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
              ])
            : const Icon(Icons.add_rounded, color: AppColors.primary, size: 24),
      ),
    );
  }

  void _addPhoto(int index) {
    setState(() => _photos[index] = 'mock_photo_$index');
  }

  // ── Info Card ──────────────────────────────────────────────────────────────

  Widget _buildInfoCard() {
    return _buildCard(Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInputLabel('Nama Produk'),
        _buildTextField(
          controller: _nameCtrl,
          hint: 'cth. Tomat Segar Organik Grade A',
          validator: (v) => (v == null || v.isEmpty) ? 'Nama produk wajib diisi' : null,
        ),
        const SizedBox(height: 16),
        _buildInputLabel('Kategori'),
        _buildCategorySelector(),
        const SizedBox(height: 16),
        _buildInputLabel('Deskripsi Produk'),
        _buildTextField(
          controller: _descCtrl,
          hint: 'Ceritakan tentang produkmu: cara tanam, keunggulan, dll...',
          maxLines: 4,
        ),
      ],
    ));
  }

  // ── Price & Stock Card ─────────────────────────────────────────────────────

  Widget _buildPriceStockCard() {
    return _buildCard(Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInputLabel('Harga Jual'),
        _buildPriceField(),
        const SizedBox(height: 16),
        _buildInputLabel('Stok Tersedia'),
        _buildStockStepper(),
        const SizedBox(height: 16),
        _buildInputLabel('Min. Pembelian'),
        _buildTextField(
          controller: _minOrderCtrl,
          hint: '5',
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          suffix: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(_selectedUnit, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary)),
          ),
        ),
        const SizedBox(height: 12),
        // AI price hint banner
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFE3F2FD),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF1976D2).withValues(alpha: 0.3)),
          ),
          child: Row(children: [
            const Icon(Icons.auto_awesome_rounded, color: Color(0xFF1976D2), size: 18),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Harga AI menyarankan Rp 7.500–9.000/kg untuk Tomat saat ini',
                style: TextStyle(fontSize: 12, color: Color(0xFF1976D2), fontWeight: FontWeight.w500),
              ),
            ),
          ]),
        ),
      ],
    ));
  }

  // ── Harvest Card ───────────────────────────────────────────────────────────

  Widget _buildHarvestCard() {
    return _buildCard(Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInputLabel('Estimasi Tanggal Panen'),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickHarvestDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(children: [
              const Icon(Icons.calendar_month_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 10),
              Text(
                '${_harvestDate.day} ${_monthName(_harvestDate.month)} ${_harvestDate.year}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              const Spacer(),
              const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
            ]),
          ),
        ),
        const SizedBox(height: 20),
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Aktifkan Pre-Order', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 2),
            const Text(
              'Pembeli bisa pesan sebelum panen',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ])),
          Switch.adaptive(
            value: _preOrderEnabled,
            activeColor: AppColors.primary,
            onChanged: (v) => setState(() => _preOrderEnabled = v),
          ),
        ]),
        if (_preOrderEnabled) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.secondaryLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
            ),
            child: const Row(children: [
              Text('🌾', style: TextStyle(fontSize: 18)),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Pre-Order aktif: Pembeli bisa reservasi hingga 3 hari sebelum panen',
                  style: TextStyle(fontSize: 12, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                ),
              ),
            ]),
          ),
        ],
      ],
    ));
  }

  // ── Bottom Buttons ─────────────────────────────────────────────────────────

  Widget _buildBottomButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(children: [
        // Preview button
        OutlinedButton.icon(
          onPressed: _showPreview,
          icon: const Icon(Icons.visibility_outlined, size: 18),
          label: const Text('Pratinjau Produk', style: TextStyle(fontWeight: FontWeight.w600)),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary, width: 1.5),
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        const SizedBox(height: 12),
        // Save button
        ElevatedButton.icon(
          onPressed: _saveProduct,
          icon: const Icon(Icons.check_rounded, color: Colors.white, size: 20),
          label: const Text(
            'Simpan Produk',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 2,
            shadowColor: AppColors.primary.withValues(alpha: 0.4),
          ),
        ),
      ]),
    );
  }

  // ── Helper Widgets ─────────────────────────────────────────────────────────

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    Widget? suffix,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        suffixIcon: suffix,
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _categories.map((cat) {
        final sel = _selectedCategory == cat;
        return GestureDetector(
          onTap: () => setState(() => _selectedCategory = cat),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: sel ? AppColors.primary : AppColors.background,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: sel ? AppColors.primary : AppColors.border,
                width: sel ? 1.5 : 1,
              ),
            ),
            child: Text(
              cat,
              style: TextStyle(
                fontSize: 13,
                fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                color: sel ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPriceField() {
    return Row(children: [
      Expanded(
        child: TextFormField(
          controller: _priceCtrl,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (v) => (v == null || v.isEmpty) ? 'Harga wajib diisi' : null,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            prefixText: 'Rp ',
            prefixStyle: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 14),
            hintText: '8.000',
            hintStyle: const TextStyle(color: AppColors.textSecondary),
            filled: true,
            fillColor: AppColors.background,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.danger)),
          ),
        ),
      ),
      const SizedBox(width: 10),
      // Unit selector
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedUnit,
            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary, size: 18),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary),
            dropdownColor: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            items: _units.map((u) => DropdownMenuItem(value: u, child: Text('/$u'))).toList(),
            onChanged: (v) => setState(() => _selectedUnit = v!),
          ),
        ),
      ),
    ]);
  }

  Widget _buildStockStepper() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(children: [
        // Minus
        _stepperBtn(Icons.remove_rounded, () {
          if (_stock > 0) setState(() => _stock--);
        }),
        Expanded(
          child: Center(
            child: Text(
              '$_stock $_selectedUnit',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textPrimary),
            ),
          ),
        ),
        // Plus
        _stepperBtn(Icons.add_rounded, () => setState(() => _stock++)),
      ]),
    );
  }

  Widget _stepperBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 22),
      ),
    );
  }

  // ── Preview Bottom Sheet ───────────────────────────────────────────────────

  void _showPreview() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, ctrl) => Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(children: [
            const SizedBox(height: 8),
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),
            const Text(
              'Pratinjau Produk',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
            Expanded(
              child: ListView(controller: ctrl, padding: const EdgeInsets.all(20), children: [
                // Mock product preview card
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(child: Icon(Icons.eco_rounded, color: AppColors.primary, size: 60)),
                ),
                const SizedBox(height: 16),
                Text(
                  _nameCtrl.text.isEmpty ? 'Nama Produk' : _nameCtrl.text,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
                ),
                const SizedBox(height: 6),
                Text(
                  _priceCtrl.text.isEmpty
                      ? 'Rp –/$_selectedUnit'
                      : 'Rp ${_priceCtrl.text}/$_selectedUnit',
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 18),
                ),
                const SizedBox(height: 8),
                Row(children: [
                  _previewChip(Icons.category_rounded, _selectedCategory),
                  const SizedBox(width: 8),
                  _previewChip(Icons.inventory_2_outlined, '$_stock $_selectedUnit'),
                  if (_preOrderEnabled) ...[
                    const SizedBox(width: 8),
                    _previewChip(Icons.pending_actions_rounded, 'Pre-Order'),
                  ],
                ]),
                const SizedBox(height: 12),
                Text(
                  _descCtrl.text.isEmpty ? 'Deskripsi produk akan ditampilkan di sini.' : _descCtrl.text,
                  style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.6),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(children: [
                    const Icon(Icons.calendar_today_rounded, color: AppColors.warning, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Estimasi Panen: ${_harvestDate.day} ${_monthName(_harvestDate.month)} ${_harvestDate.year}',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ]),
                ),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Kembali & Edit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _previewChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 13, color: AppColors.primary),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
      ]),
    );
  }

  String _monthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return months[month - 1];
  }
}
