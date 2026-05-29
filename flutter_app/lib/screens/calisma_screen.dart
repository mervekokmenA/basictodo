import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/storage_service.dart';
import '../widgets/date_navigator_widget.dart';
import '../widgets/category_chip_widget.dart';

class CalismaScreen extends StatefulWidget {
  const CalismaScreen({super.key});

  @override
  State<CalismaScreen> createState() => _CalismaScreenState();
}

class _CalismaScreenState extends State<CalismaScreen> {
  final _storage = StorageService();

  late String _currentDateKey;
  DailyStudy? _study;
  AppSettings? _settings;
  bool _loading = true;

  final _notesController = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _currentDateKey = _storage.formatDateKey(DateTime.now());
    _loadData();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final settings = await _storage.loadSettings();
    final study = await _storage.loadStudy(_currentDateKey);
    setState(() {
      _settings = settings;
      _study = study ??
          DailyStudy(
            date: _currentDateKey,
          );
      _notesController.text = _study?.notes ?? '';
      _loading = false;
    });
  }

  void _onDateChanged(String newKey) {
    setState(() => _currentDateKey = newKey);
    _loadData();
  }

  Future<void> _saveStudy() async {
    if (_study == null) return;
    setState(() => _saving = true);
    await _storage.saveStudy(_study!.copyWith(notes: _notesController.text));
    if (mounted) setState(() => _saving = false);
  }

  // -------------------------------------------------------------------------
  // Seçim toggleları
  // -------------------------------------------------------------------------
  void _toggleHobi(String item) {
    if (_study == null) return;
    final selected = List<String>.from(_study!.selectedHobi);
    if (selected.contains(item)) {
      selected.remove(item);
    } else {
      if (selected.length >= 2) {
        // max 2 seçim
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('En fazla 2 hobi seçebilirsiniz.'),
              duration: Duration(seconds: 1)),
        );
        return;
      }
      selected.add(item);
    }
    setState(() {
      _study = _study!.copyWith(selectedHobi: selected);
    });
    _saveStudy();
  }

  void _toggleYazi(String item) {
    if (_study == null) return;
    final selected = List<String>.from(_study!.selectedYazi);
    if (selected.contains(item)) {
      selected.remove(item);
    } else {
      selected.add(item);
    }
    setState(() {
      _study = _study!.copyWith(selectedYazi: selected);
    });
    _saveStudy();
  }

  void _toggleYabanciDil(String item) {
    if (_study == null) return;
    final selected = List<String>.from(_study!.selectedYabanciDil);
    if (selected.contains(item)) {
      selected.remove(item);
    } else {
      if (selected.length >= 1) {
        // max 1 seçim
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('En fazla 1 yabancı dil seçebilirsiniz.'),
              duration: Duration(seconds: 1)),
        );
        return;
      }
      selected.add(item);
    }
    setState(() {
      _study = _study!.copyWith(selectedYabanciDil: selected);
    });
    _saveStudy();
  }

  void _toggleGelisim(String item) {
    if (_study == null) return;
    final selected = List<String>.from(_study!.selectedGelisim);
    if (selected.contains(item)) {
      selected.remove(item);
    } else {
      selected.add(item);
    }
    setState(() {
      _study = _study!.copyWith(selectedGelisim: selected);
    });
    _saveStudy();
  }

  // -------------------------------------------------------------------------
  // BUILD
  // -------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('ÇALIŞMALAR'),
            if (_saving)
              Text(
                'Kaydediliyor…',
                style: TextStyle(
                    fontSize: 11,
                    color: theme.colorScheme.secondary),
              ),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                DateNavigatorWidget(
                  currentDateKey: _currentDateKey,
                  onDateChanged: _onDateChanged,
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // HOBİ
                      _buildCategorySection(
                        context,
                        title: 'HOBİ',
                        subtitle: 'Max 2 seçim',
                        color: const Color(0xFF7b5ea7),
                        items: _settings?.hobiler ?? [],
                        selected: _study?.selectedHobi ?? [],
                        onTap: _toggleHobi,
                      ),
                      const SizedBox(height: 16),
                      // YAZI
                      _buildCategorySection(
                        context,
                        title: 'YAZI',
                        color: const Color(0xFF2e8b57),
                        items: _settings?.yazilar ?? [],
                        selected: _study?.selectedYazi ?? [],
                        onTap: _toggleYazi,
                      ),
                      const SizedBox(height: 16),
                      // YABANCI DİL
                      _buildCategorySection(
                        context,
                        title: 'YABANCI DİL',
                        subtitle: 'Max 1 seçim',
                        color: const Color(0xFFc9a227),
                        items: _settings?.yabanciDiller ?? [],
                        selected: _study?.selectedYabanciDil ?? [],
                        onTap: _toggleYabanciDil,
                      ),
                      const SizedBox(height: 16),
                      // GELİŞİM
                      _buildCategorySection(
                        context,
                        title: 'GELİŞİM',
                        color: const Color(0xFF4a7fa5),
                        items: _settings?.gelisimler ?? [],
                        selected: _study?.selectedGelisim ?? [],
                        onTap: _toggleGelisim,
                      ),
                      const SizedBox(height: 24),
                      // Not Günlüğü
                      _buildNotesSection(context, theme),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildCategorySection(
    BuildContext context, {
    required String title,
    String? subtitle,
    required Color color,
    required List<String> items,
    required List<String> selected,
    required void Function(String) onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF162030) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: color,
                  letterSpacing: 1.2,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(width: 8),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: color.withOpacity(0.7),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          items.isEmpty
              ? Text(
                  'Henüz öğe yok. Ayarlar\'dan ekleyebilirsiniz.',
                  style: TextStyle(
                      color: Colors.grey, fontSize: 12),
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: items.map((item) {
                    return CategoryChipWidget(
                      label: item,
                      selected: selected.contains(item),
                      onTap: () => onTap(item),
                      selectedColor: color,
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildNotesSection(BuildContext context, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF162030) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'DÜŞÜNCE / NOT GÜNLÜĞÜ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: theme.colorScheme.primary,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesController,
            maxLines: null,
            minLines: 5,
            keyboardType: TextInputType.multiline,
            decoration: const InputDecoration(
              hintText:
                  'Bugün ne düşündünüz? Neler öğrendiniz? Duygularınız…',
              border: InputBorder.none,
              filled: false,
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: (_) => _saveStudy(),
            textCapitalization: TextCapitalization.sentences,
          ),
        ],
      ),
    );
  }
}
