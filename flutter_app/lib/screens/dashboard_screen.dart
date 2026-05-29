import 'dart:math';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../widgets/date_navigator_widget.dart';
import '../widgets/task_color_picker.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _storage = StorageService();
  final _notif = NotificationService();

  late String _currentDateKey;
  DailyPlan? _plan;
  List<TimeSlot> _defaultSlots = [];

  // Todo input controller
  final _todoController = TextEditingController();
  bool _loadingPlan = true;

  @override
  void initState() {
    super.initState();
    _currentDateKey = _storage.formatDateKey(DateTime.now());
    _loadData();
  }

  @override
  void dispose() {
    _todoController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _loadingPlan = true);
    final settings = await _storage.loadSettings();
    _defaultSlots = settings.defaultTimeSlots;
    final plan = await _storage.loadPlan(_currentDateKey);
    setState(() {
      if (plan != null) {
        _plan = plan;
      } else {
        // Yeni gün: varsayılan saat dilimlerini kopyala
        _plan = DailyPlan(
          date: _currentDateKey,
          timeSlots: _defaultSlots
              .map((s) => TimeSlot(
                    id: '${s.id}_$_currentDateKey',
                    startTime: s.startTime,
                    endTime: s.endTime,
                  ))
              .toList(),
          todos: [],
        );
      }
      _loadingPlan = false;
    });
  }

  Future<void> _savePlan() async {
    if (_plan != null) {
      await _storage.savePlan(_plan!);
    }
  }

  void _onDateChanged(String newKey) {
    setState(() {
      _currentDateKey = newKey;
    });
    _loadData();
  }

  // -------------------------------------------------------------------------
  // Göreve tıklanınca BottomSheet
  // -------------------------------------------------------------------------
  void _showAddTaskSheet(TimeSlot slot) {
    final textController = TextEditingController();
    int selectedColor = TASK_COLORS[0]['hex'] as int;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: StatefulBuilder(
            builder: (ctx2, setModal) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${slot.startTime} – ${slot.endTime}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: textController,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: 'Görev adı girin…',
                      labelText: 'Görev',
                    ),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 16),
                  const Text('Renk seçin:',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  TaskColorPicker(
                    selectedColor: selectedColor,
                    onColorSelected: (c) =>
                        setModal(() => selectedColor = c),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final text = textController.text.trim();
                        if (text.isEmpty) return;
                        _addTaskToSlot(slot, text, selectedColor);
                        Navigator.of(ctx).pop();
                      },
                      child: const Text('Ekle'),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  void _addTaskToSlot(TimeSlot slot, String text, int color) {
    if (_plan == null) return;
    final newTask = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      color: color,
    );
    final updatedSlots = _plan!.timeSlots.map((s) {
      if (s.id == slot.id) {
        return s.copyWith(tasks: [...s.tasks, newTask]);
      }
      return s;
    }).toList();
    setState(() {
      _plan = _plan!.copyWith(timeSlots: updatedSlots);
    });
    _savePlan();
  }

  void _deleteTaskFromSlot(TimeSlot slot, Task task) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Görevi Sil'),
        content: Text('"${task.text}" silinsin mi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              final updatedSlots = _plan!.timeSlots.map((s) {
                if (s.id == slot.id) {
                  return s.copyWith(
                      tasks: s.tasks.where((t) => t.id != task.id).toList());
                }
                return s;
              }).toList();
              setState(() {
                _plan = _plan!.copyWith(timeSlots: updatedSlots);
              });
              _savePlan();
            },
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _deleteSlot(TimeSlot slot) {
    setState(() {
      _plan = _plan!.copyWith(
          timeSlots:
              _plan!.timeSlots.where((s) => s.id != slot.id).toList());
    });
    _savePlan();
  }

  // -------------------------------------------------------------------------
  // Todo işlemleri
  // -------------------------------------------------------------------------
  void _addTodo() {
    final text = _todoController.text.trim();
    if (text.isEmpty || _plan == null) return;
    final todo = TodoItem(
      id: '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(9999)}',
      text: text,
    );
    setState(() {
      _plan = _plan!.copyWith(todos: [..._plan!.todos, todo]);
      _todoController.clear();
    });
    _savePlan();
  }

  void _toggleTodo(TodoItem todo) {
    if (_plan == null) return;
    final updated = _plan!.todos.map((t) {
      if (t.id == todo.id) return t.copyWith(completed: !t.completed);
      return t;
    }).toList();
    setState(() {
      _plan = _plan!.copyWith(todos: updated);
    });
    _savePlan();
  }

  void _deleteTodo(TodoItem todo) {
    if (_plan == null) return;
    // Hatırlatıcı iptal et
    _notif.cancelNotification(_notif.todoIdToNotifId(todo.id));
    setState(() {
      _plan = _plan!
          .copyWith(todos: _plan!.todos.where((t) => t.id != todo.id).toList());
    });
    _savePlan();
  }

  Future<void> _setReminder(TodoItem todo) async {
    // Tarih seç
    final date = await showDatePicker(
      context: context,
      initialDate: todo.reminder ?? DateTime.now().add(const Duration(hours: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;

    // Saat seç
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
          todo.reminder ?? DateTime.now().add(const Duration(hours: 1))),
    );
    if (time == null || !mounted) return;

    final scheduled = DateTime(
        date.year, date.month, date.day, time.hour, time.minute);

    // Bildirimi planla
    await _notif.scheduleNotification(
      id: _notif.todoIdToNotifId(todo.id),
      title: 'Hatırlatıcı',
      body: todo.text,
      scheduledDate: scheduled,
    );

    // Modeli güncelle
    if (_plan == null) return;
    final updated = _plan!.todos.map((t) {
      if (t.id == todo.id) return t.copyWith(reminder: scheduled);
      return t;
    }).toList();
    setState(() {
      _plan = _plan!.copyWith(todos: updated);
    });
    _savePlan();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Hatırlatıcı ayarlandı: ${scheduled.day.toString().padLeft(2, '0')}.${scheduled.month.toString().padLeft(2, '0')} ${scheduled.hour.toString().padLeft(2, '0')}:${scheduled.minute.toString().padLeft(2, '0')}'),
          backgroundColor: const Color(0xFF2e8b57),
        ),
      );
    }
  }

  void _clearReminder(TodoItem todo) async {
    _notif.cancelNotification(_notif.todoIdToNotifId(todo.id));
    if (_plan == null) return;
    final updated = _plan!.todos.map((t) {
      if (t.id == todo.id) return t.copyWith(clearReminder: true);
      return t;
    }).toList();
    setState(() {
      _plan = _plan!.copyWith(todos: updated);
    });
    _savePlan();
  }

  // -------------------------------------------------------------------------
  // BUILD
  // -------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('GÜNLÜK PLAN'),
            Text(
              _storage.formatDisplayDate(_currentDateKey),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
      body: _loadingPlan
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                DateNavigatorWidget(
                  currentDateKey: _currentDateKey,
                  onDateChanged: _onDateChanged,
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 24),
                    children: [
                      // --- Saat tablosu başlığı ---
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Text(
                          'SAAT PLANI',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      // --- Saat dilimi satırları ---
                      ..._buildTimeSlotRows(isDark),
                      const SizedBox(height: 16),
                      // --- Yapılacaklar ---
                      _buildTodoSection(isDark, theme),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  // -------------------------------------------------------------------------
  // Saat dilimi satırları
  // -------------------------------------------------------------------------
  List<Widget> _buildTimeSlotRows(bool isDark) {
    if (_plan == null) return [];
    return _plan!.timeSlots.map((slot) {
      return GestureDetector(
        onTap: () => _showAddTaskSheet(slot),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF162030) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDark
                  ? const Color(0xFF2a3a4a)
                  : const Color(0xFFd0dce8),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Saat aralığı
                SizedBox(
                  width: 90,
                  child: Text(
                    '${slot.startTime}–${slot.endTime}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                // Görevler
                Expanded(
                  child: slot.tasks.isEmpty
                      ? Text(
                          'Dokunun ekleyin…',
                          style: TextStyle(
                            color: isDark
                                ? Colors.white30
                                : Colors.black26,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        )
                      : Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: slot.tasks.map((task) {
                            return GestureDetector(
                              onLongPress: () =>
                                  _deleteTaskFromSlot(slot, task),
                              child: Chip(
                                label: Text(
                                  task.text,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                                backgroundColor: Color(task.color),
                                padding: EdgeInsets.zero,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                deleteIcon: const Icon(Icons.close,
                                    size: 14, color: Colors.white70),
                                onDeleted: () =>
                                    _deleteTaskFromSlot(slot, task),
                              ),
                            );
                          }).toList(),
                        ),
                ),
                // Sil butonu
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18),
                  color: Colors.redAccent,
                  onPressed: () => _deleteSlot(slot),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Saat dilimini sil',
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  // -------------------------------------------------------------------------
  // Yapılacaklar bölümü
  // -------------------------------------------------------------------------
  Widget _buildTodoSection(bool isDark, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF0d2020)
            : const Color(0xFFe0f5f5),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              'YAPILACAKLAR',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                color: theme.colorScheme.secondary,
              ),
            ),
          ),
          // Todo listesi
          if (_plan != null && _plan!.todos.isNotEmpty)
            ..._plan!.todos.map((todo) => _buildTodoItem(todo, isDark)),
          const SizedBox(height: 8),
          // Ekleme alanı
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _todoController,
                  decoration: const InputDecoration(
                    hintText: 'Yapılacak ekle…',
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  onSubmitted: (_) => _addTodo(),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _addTodo,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                ),
                child: const Text('Ekle'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTodoItem(TodoItem todo, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF162030)
            : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: todo.completed
              ? const Color(0xFF2e8b57)
              : (isDark
                  ? const Color(0xFF2a3a4a)
                  : const Color(0xFFd0dce8)),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Checkbox(
            value: todo.completed,
            onChanged: (_) => _toggleTodo(todo),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  todo.text,
                  style: TextStyle(
                    decoration: todo.completed
                        ? TextDecoration.lineThrough
                        : null,
                    color: todo.completed ? Colors.grey : null,
                  ),
                ),
                if (todo.reminder != null)
                  GestureDetector(
                    onTap: () => _clearReminder(todo),
                    child: Container(
                      margin: const EdgeInsets.only(top: 2),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFc9a227),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.alarm, size: 11,
                              color: Colors.white),
                          const SizedBox(width: 3),
                          Text(
                            '${todo.reminder!.hour.toString().padLeft(2, '0')}:${todo.reminder!.minute.toString().padLeft(2, '0')}',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 11),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.close, size: 11,
                              color: Colors.white70),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Hatırlatıcı butonu
          IconButton(
            icon: Icon(
              todo.reminder != null
                  ? Icons.notifications_active
                  : Icons.notifications_none,
              size: 20,
              color: todo.reminder != null
                  ? const Color(0xFFc9a227)
                  : Colors.grey,
            ),
            onPressed: () => _setReminder(todo),
            padding: const EdgeInsets.symmetric(horizontal: 6),
            constraints: const BoxConstraints(),
            tooltip: 'Hatırlatıcı ayarla',
          ),
          // Sil butonu
          IconButton(
            icon: const Icon(Icons.close, size: 18, color: Colors.redAccent),
            onPressed: () => _deleteTodo(todo),
            padding: const EdgeInsets.symmetric(horizontal: 6),
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
