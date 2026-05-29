import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/storage_service.dart';
import '../main.dart' show SettingsProvider;

class AyarlarScreen extends StatefulWidget {
  const AyarlarScreen({super.key});

  @override
  State<AyarlarScreen> createState() => _AyarlarScreenState();
}

class _AyarlarScreenState extends State<AyarlarScreen> {
  final _storage = StorageService();
  AppSettings? _settings;
  bool _loading = true;

  // Saat dilimi ekleme controller'ları
  String? _newSlotStart;
  String? _newSlotEnd;

  // Kategori ekleme controller'ları
  final _hobiController = TextEditingController();
  final _yaziController = TextEditingController();
  final _dilController = TextEditingController();
  final _gelisimController = TextEditingController();

  // Rutin ekleme controller'ları
  final _rutinTextController = TextEditingController();
  final _rutinFreqController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _hobiController.dispose();
    _yaziController.dispose();
    _dilController.dispose();
    _gelisimController.dispose();
    _rutinTextController.dispose();
    _rutinFreqController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final settings = await _storage.loadSettings();
    setState(() {
      _settings = settings;
      _loading = false;
    });
  }

  Future<void> _saveAndNotify(AppSettings updated) async {
    await _storage.saveSettings(updated);
    setState(() => _settings = updated);
    if (mounted) {
      context.read<SettingsProvider>().update(updated);
    }
  }

  // -------------------------------------------------------------------------
  // Tema
  // -------------------------------------------------------------------------
  void _setTheme(String theme) {
    if (_settings == null) return;
    _saveAndNotify(_settings!.copyWith(theme: theme));
  }

  // -------------------------------------------------------------------------
  // Saat dilimi işlemleri
  // -------------------------------------------------------------------------
  Future<String?> _pickTime(BuildContext ctx, String label,
      {TimeOfDay? initial}) async {
    final picked = await showTimePicker(
      context: ctx,
      initialTime: initial ?? TimeOfDay.now(),
      helpText: label,
    );
    if (picked == null) return null;
    return '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _addTimeSlot() async {
    final start = await _pickTime(context, 'Başlangıç saati');
    if (start == null || !mounted) return;
    final end = await _pickTime(context, 'Bitiş saati',
        initial: TimeOfDay(
          hour: int.parse(start.split(':')[0]),
          minute: int.parse(start.split(':')[1]),
        ));
    if (end == null || !mounted) return;
    if (_settings == null) return;

    final newSlot = TimeSlot(
      id: 'ts_${DateTime.now().millisecondsSinceEpoch}',
      startTime: start,
      endTime: end,
    );

    // Sırala
    final slots = [..._settings!.defaultTimeSlots, newSlot]
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    _saveAndNotify(_settings!.copyWith(defaultTimeSlots: slots));
  }

  void _deleteTimeSlot(String id) {
    if (_settings == null) return;
    final slots =
        _settings!.defaultTimeSlots.where((s) => s.id != id).toList();
    _saveAndNotify(_settings!.copyWith(defaultTimeSlots: slots));
  }

  // -------------------------------------------------------------------------
  // Kategori işlemleri
  // -------------------------------------------------------------------------
  void _addHobi() {
    final text = _hobiController.text.trim();
    if (text.isEmpty || _settings == null) return;
    _hobiController.clear();
    _saveAndNotify(
        _settings!.copyWith(hobiler: [..._settings!.hobiler, text]));
  }

  void _removeHobi(String item) {
    if (_settings == null) return;
    _saveAndNotify(
        _settings!.copyWith(
            hobiler: _settings!.hobiler.where((h) => h != item).toList()));
  }

  void _addYazi() {
    final text = _yaziController.text.trim();
    if (text.isEmpty || _settings == null) return;
    _yaziController.clear();
    _saveAndNotify(
        _settings!.copyWith(yazilar: [..._settings!.yazilar, text]));
  }

  void _removeYazi(String item) {
    if (_settings == null) return;
    _saveAndNotify(
        _settings!.copyWith(
            yazilar: _settings!.yazilar.where((y) => y != item).toList()));
  }

  void _addDil() {
    final text = _dilController.text.trim();
    if (text.isEmpty || _settings == null) return;
    _dilController.clear();
    _saveAndNotify(_settings!.copyWith(
        yabanciDiller: [..._settings!.yabanciDiller, text]));
  }

  void _removeDil(String item) {
    if (_settings == null) return;
    _saveAndNotify(_settings!.copyWith(
        yabanciDiller:
            _settings!.yabanciDiller.where((d) => d != item).toList()));
  }

  void _addGelisim() {
    final text = _gelisimController.text.trim();
    if (text.isEmpty || _settings == null) return;
    _gelisimController.clear();
    _saveAndNotify(
        _settings!.copyWith(gelisimler: [..._settings!.gelisimler, text]));
  }

  void _removeGelisim(String item) {
    if (_settings == null) return;
    _saveAndNotify(_settings!.copyWith(
        gelisimler:
            _settings!.gelisimler.where((g) => g != item).toList()));
  }

  // -------------------------------------------------------------------------
  // Rutin işlemleri
  // -------------------------------------------------------------------------
  void _addRoutine() {
    final text = _rutinTextController.text.trim();
    final freq = _rutinFreqController.text.trim();
    if (text.isEmpty || _settings == null) return;
    _rutinTextController.clear();
    _rutinFreqController.clear();
    final routine = Routine(
      id: 'r_${DateTime.now().millisecondsSinceEpoch}',
      text: text,
      frequency: freq.isEmpty ? 'günlük' : freq,
    );
    _saveAndNotify(
        _settings!.copyWith(routines: [..._settings!.routines, routine]));
  }

  void _deleteRoutine(String id) {
    if (_settings == null) return;
    _saveAndNotify(_settings!.copyWith(
        routines: _settings!.routines.where((r) => r.id != id).toList()));
  }

  // -------------------------------------------------------------------------
  // BUILD
  // -------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('AYARLAR')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(12),
              children: [
                // 1. Tema
                _buildThemeSection(theme),
                const SizedBox(height: 12),
                // 2. Saat Aralıkları
                _buildTimeSlotsSection(theme),
                const SizedBox(height: 12),
                // 3. Kategoriler
                _buildCategoriesSection(theme),
                const SizedBox(height: 12),
                // 4. Rutinler
                _buildRoutinesSection(theme),
                const SizedBox(height: 40),
              ],
            ),
    );
  }

  // ---------------------------------------------------------------------------
  // Tema kartı
  // ---------------------------------------------------------------------------
  Widget _buildThemeSection(ThemeData theme) {
    final currentTheme = _settings?.theme ?? 'light';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(context, Icons.palette_outlined, 'TEMA'),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _themeButton(
                    context,
                    label: 'Açık Tema',
                    icon: Icons.light_mode,
                    selected: currentTheme == 'light',
                    onTap: () => _setTheme('light'),
                    color: const Color(0xFFf0f4f7),
                    iconColor: const Color(0xFFc9a227),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _themeButton(
                    context,
                    label: 'Koyu Tema',
                    icon: Icons.dark_mode,
                    selected: currentTheme == 'dark',
                    onTap: () => _setTheme('dark'),
                    color: const Color(0xFF1a2a3a),
                    iconColor: const Color(0xFF4bbfcc),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _themeButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
    required Color color,
    required Color iconColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            width: 2.5,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                color: color.computeLuminance() > 0.4
                    ? const Color(0xFF1a2a3a)
                    : Colors.white,
              ),
            ),
            if (selected)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Icon(Icons.check_circle,
                    color: Theme.of(context).colorScheme.primary, size: 16),
              ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Saat aralıkları kartı
  // ---------------------------------------------------------------------------
  Widget _buildTimeSlotsSection(ThemeData theme) {
    return Card(
      child: ExpansionTile(
        title: _sectionTitle(context, Icons.access_time, 'SAAT ARALIĞI'),
        initiallyExpanded: true,
        children: [
          if (_settings != null && _settings!.defaultTimeSlots.isNotEmpty)
            ..._settings!.defaultTimeSlots.map((slot) {
              return ListTile(
                dense: true,
                leading: Icon(Icons.schedule,
                    size: 18, color: theme.colorScheme.primary),
                title: Text(
                  '${slot.startTime} – ${slot.endTime}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: Colors.redAccent, size: 20),
                  onPressed: () => _deleteTimeSlot(slot.id),
                ),
              );
            }),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Saat Aralığı Ekle'),
                onPressed: _addTimeSlot,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Kategoriler kartı
  // ---------------------------------------------------------------------------
  Widget _buildCategoriesSection(ThemeData theme) {
    return Card(
      child: ExpansionTile(
        title: _sectionTitle(context, Icons.category_outlined, 'KATEGORİLER'),
        initiallyExpanded: false,
        children: [
          _categorySubSection(
            context,
            title: 'HOBİ',
            color: const Color(0xFF7b5ea7),
            items: _settings?.hobiler ?? [],
            controller: _hobiController,
            onAdd: _addHobi,
            onRemove: _removeHobi,
          ),
          const Divider(height: 1),
          _categorySubSection(
            context,
            title: 'YAZI',
            color: const Color(0xFF2e8b57),
            items: _settings?.yazilar ?? [],
            controller: _yaziController,
            onAdd: _addYazi,
            onRemove: _removeYazi,
          ),
          const Divider(height: 1),
          _categorySubSection(
            context,
            title: 'YABANCI DİL',
            color: const Color(0xFFc9a227),
            items: _settings?.yabanciDiller ?? [],
            controller: _dilController,
            onAdd: _addDil,
            onRemove: _removeDil,
          ),
          const Divider(height: 1),
          _categorySubSection(
            context,
            title: 'GELİŞİM',
            color: const Color(0xFF4a7fa5),
            items: _settings?.gelisimler ?? [],
            controller: _gelisimController,
            onAdd: _addGelisim,
            onRemove: _removeGelisim,
          ),
        ],
      ),
    );
  }

  Widget _categorySubSection(
    BuildContext context, {
    required String title,
    required Color color,
    required List<String> items,
    required TextEditingController controller,
    required VoidCallback onAdd,
    required void Function(String) onRemove,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: color,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          if (items.isNotEmpty)
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: items.map((item) {
                return Chip(
                  label: Text(item),
                  backgroundColor: color.withOpacity(0.12),
                  labelStyle: TextStyle(color: color, fontSize: 12),
                  side: BorderSide(color: color.withOpacity(0.3)),
                  deleteIcon: Icon(Icons.close, size: 14, color: color),
                  onDeleted: () => onRemove(item),
                );
              }).toList(),
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: '${title.toLowerCase()} ekle…',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 8),
                  ),
                  onSubmitted: (_) => onAdd(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.add_circle, color: color),
                onPressed: onAdd,
                tooltip: 'Ekle',
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Rutinler kartı
  // ---------------------------------------------------------------------------
  Widget _buildRoutinesSection(ThemeData theme) {
    return Card(
      child: ExpansionTile(
        title: _sectionTitle(
            context, Icons.check_circle_outline, 'RUTİNLER'),
        initiallyExpanded: false,
        children: [
          if (_settings != null && _settings!.routines.isNotEmpty)
            ..._settings!.routines.map((routine) {
              return ListTile(
                dense: true,
                leading: Icon(Icons.repeat,
                    size: 18, color: theme.colorScheme.primary),
                title: Text(routine.text),
                subtitle: Text(routine.frequency,
                    style: TextStyle(
                        fontSize: 11,
                        color: theme.colorScheme.secondary)),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: Colors.redAccent, size: 20),
                  onPressed: () => _deleteRoutine(routine.id),
                ),
              );
            }),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Yeni Rutin',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _rutinTextController,
                  decoration: const InputDecoration(
                    hintText: 'Rutin adı (ör: Kitap okuma)',
                    labelText: 'Rutin adı',
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _rutinFreqController,
                  decoration: const InputDecoration(
                    hintText: 'günlük / 3 günde 1 / 10 dk',
                    labelText: 'Frekans',
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Rutin Ekle'),
                    onPressed: _addRoutine,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Yardımcı: Bölüm başlığı
  // ---------------------------------------------------------------------------
  Widget _sectionTitle(BuildContext context, IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon,
            size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            letterSpacing: 1.2,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }
}
