import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/storage_service.dart';
import '../widgets/date_navigator_widget.dart';
import '../widgets/checklist_item_widget.dart';

class RutinlerScreen extends StatefulWidget {
  const RutinlerScreen({super.key});

  @override
  State<RutinlerScreen> createState() => _RutinlerScreenState();
}

class _RutinlerScreenState extends State<RutinlerScreen> {
  final _storage = StorageService();

  late String _currentDateKey;
  DailyStudy? _study;
  AppSettings? _settings;
  bool _loading = true;

  // streak ve recentlyDone önbellek
  final Map<String, int> _streakCache = {};
  final Map<String, bool> _recentlyDoneCache = {};

  @override
  void initState() {
    super.initState();
    _currentDateKey = _storage.formatDateKey(DateTime.now());
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final settings = await _storage.loadSettings();
    final study = await _storage.loadStudy(_currentDateKey);

    // Streak ve recentlyDone değerlerini hesapla
    final streakMap = <String, int>{};
    final recentMap = <String, bool>{};
    for (final routine in settings.routines) {
      streakMap[routine.id] =
          await _storage.getRoutineStreak(routine.id, _currentDateKey);
      if (routine.frequency == '3 günde 1') {
        recentMap[routine.id] = await _storage.isRoutineDoneRecently(
            routine.id, 3, _currentDateKey);
      } else {
        recentMap[routine.id] = false;
      }
    }

    setState(() {
      _settings = settings;
      _study = study ??
          DailyStudy(
            date: _currentDateKey,
            routinesDone: [],
          );
      _streakCache.addAll(streakMap);
      _recentlyDoneCache.addAll(recentMap);
      _loading = false;
    });
  }

  void _onDateChanged(String newKey) {
    setState(() => _currentDateKey = newKey);
    _loadData();
  }

  Future<void> _toggleRoutine(Routine routine) async {
    if (_study == null) return;
    final done = List<String>.from(_study!.routinesDone);
    if (done.contains(routine.id)) {
      done.remove(routine.id);
    } else {
      done.add(routine.id);
    }
    final updated = _study!.copyWith(routinesDone: done);
    await _storage.saveStudy(updated);

    // Streak ve recentlyDone'ı güncelle
    final streak =
        await _storage.getRoutineStreak(routine.id, _currentDateKey);
    bool recentlyDone = false;
    if (routine.frequency == '3 günde 1') {
      recentlyDone = await _storage.isRoutineDoneRecently(
          routine.id, 3, _currentDateKey);
    }

    setState(() {
      _study = updated;
      _streakCache[routine.id] = streak;
      _recentlyDoneCache[routine.id] = recentlyDone;
    });
  }

  int get _doneCount =>
      _study == null ? 0 : _study!.routinesDone.length;

  int get _totalCount =>
      _settings == null ? 0 : _settings!.routines.length;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final doneCount = _doneCount;
    final totalCount = _totalCount;
    final progress = totalCount > 0 ? doneCount / totalCount : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('RUTİNLER'),
            const SizedBox(width: 12),
            if (!_loading)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.4)),
                ),
                child: Text(
                  '$doneCount/$totalCount',
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // İlerleme barı
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'İlerleme: %${(progress * 100).round()}',
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.onSurface
                                  .withOpacity(0.7),
                            ),
                          ),
                          Text(
                            '$doneCount / $totalCount rutin',
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                // Tarih navigatörü
                DateNavigatorWidget(
                  currentDateKey: _currentDateKey,
                  onDateChanged: _onDateChanged,
                ),
                // Rutin listesi
                Expanded(
                  child: _settings == null || _settings!.routines.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle_outline,
                                  size: 64,
                                  color: theme.colorScheme.primary
                                      .withOpacity(0.3)),
                              const SizedBox(height: 12),
                              Text(
                                'Henüz rutin eklenmemiş.\nAyarlar\'dan rutin ekleyebilirsiniz.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.5)),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 24, top: 8),
                          itemCount: _settings!.routines.length,
                          itemBuilder: (ctx, i) {
                            final routine = _settings!.routines[i];
                            final checked =
                                _study?.routinesDone.contains(routine.id) ??
                                    false;
                            final streak =
                                _streakCache[routine.id] ?? 0;
                            final recentlyDone =
                                _recentlyDoneCache[routine.id] ?? false;
                            // "3 günde 1" ise ve son 3 günde yapıldıysa dimmed
                            final dimmed = routine.frequency == '3 günde 1' &&
                                recentlyDone &&
                                !checked;

                            return ChecklistItemWidget(
                              checked: checked,
                              onToggle: (_) => _toggleRoutine(routine),
                              label: routine.text,
                              sublabel: routine.frequency,
                              streak: streak,
                              dimmed: dimmed,
                              recentlyDone: recentlyDone && !checked,
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
