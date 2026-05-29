import 'dart:convert';
import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Renk sabitleri
// ---------------------------------------------------------------------------
const List<Map<String, dynamic>> TASK_COLORS = [
  {'name': 'Mavi', 'hex': 0xFF4a7fa5},
  {'name': 'Altın', 'hex': 0xFFc9a227},
  {'name': 'Kırmızı', 'hex': 0xFFc0392b},
  {'name': 'Turuncu', 'hex': 0xFFe08030},
  {'name': 'Mor', 'hex': 0xFF7b5ea7},
  {'name': 'Yeşil', 'hex': 0xFF2e8b57},
  {'name': 'Pembe', 'hex': 0xFFc06080},
  {'name': 'Lacivert', 'hex': 0xFF2c3e7a},
];

Color taskColorFromHex(int hex) => Color(hex);

// ---------------------------------------------------------------------------
// Task
// ---------------------------------------------------------------------------
class Task {
  final String id;
  final String text;
  final int color; // ARGB int

  Task({
    required this.id,
    required this.text,
    required this.color,
  });

  Task copyWith({String? id, String? text, int? color}) => Task(
        id: id ?? this.id,
        text: text ?? this.text,
        color: color ?? this.color,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'color': color,
      };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'] as String,
        text: json['text'] as String,
        color: json['color'] as int,
      );
}

// ---------------------------------------------------------------------------
// TimeSlot
// ---------------------------------------------------------------------------
class TimeSlot {
  final String id;
  final String startTime; // "08:00"
  final String endTime;   // "09:00"
  final List<Task> tasks;

  TimeSlot({
    required this.id,
    required this.startTime,
    required this.endTime,
    this.tasks = const [],
  });

  TimeSlot copyWith({
    String? id,
    String? startTime,
    String? endTime,
    List<Task>? tasks,
  }) =>
      TimeSlot(
        id: id ?? this.id,
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
        tasks: tasks ?? this.tasks,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'startTime': startTime,
        'endTime': endTime,
        'tasks': tasks.map((t) => t.toJson()).toList(),
      };

  factory TimeSlot.fromJson(Map<String, dynamic> json) => TimeSlot(
        id: json['id'] as String,
        startTime: json['startTime'] as String,
        endTime: json['endTime'] as String,
        tasks: (json['tasks'] as List<dynamic>? ?? [])
            .map((t) => Task.fromJson(t as Map<String, dynamic>))
            .toList(),
      );
}

// ---------------------------------------------------------------------------
// TodoItem
// ---------------------------------------------------------------------------
class TodoItem {
  final String id;
  final String text;
  final bool completed;
  final DateTime? reminder; // nullable

  TodoItem({
    required this.id,
    required this.text,
    this.completed = false,
    this.reminder,
  });

  TodoItem copyWith({
    String? id,
    String? text,
    bool? completed,
    DateTime? reminder,
    bool clearReminder = false,
  }) =>
      TodoItem(
        id: id ?? this.id,
        text: text ?? this.text,
        completed: completed ?? this.completed,
        reminder: clearReminder ? null : (reminder ?? this.reminder),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'completed': completed,
        'reminder': reminder?.toIso8601String(),
      };

  factory TodoItem.fromJson(Map<String, dynamic> json) => TodoItem(
        id: json['id'] as String,
        text: json['text'] as String,
        completed: json['completed'] as bool? ?? false,
        reminder: json['reminder'] != null
            ? DateTime.tryParse(json['reminder'] as String)
            : null,
      );
}

// ---------------------------------------------------------------------------
// DailyPlan
// ---------------------------------------------------------------------------
class DailyPlan {
  final String date; // "yyyy-MM-dd"
  final List<TimeSlot> timeSlots;
  final List<TodoItem> todos;

  DailyPlan({
    required this.date,
    required this.timeSlots,
    this.todos = const [],
  });

  DailyPlan copyWith({
    String? date,
    List<TimeSlot>? timeSlots,
    List<TodoItem>? todos,
  }) =>
      DailyPlan(
        date: date ?? this.date,
        timeSlots: timeSlots ?? this.timeSlots,
        todos: todos ?? this.todos,
      );

  Map<String, dynamic> toJson() => {
        'date': date,
        'timeSlots': timeSlots.map((s) => s.toJson()).toList(),
        'todos': todos.map((t) => t.toJson()).toList(),
      };

  factory DailyPlan.fromJson(Map<String, dynamic> json) => DailyPlan(
        date: json['date'] as String,
        timeSlots: (json['timeSlots'] as List<dynamic>? ?? [])
            .map((s) => TimeSlot.fromJson(s as Map<String, dynamic>))
            .toList(),
        todos: (json['todos'] as List<dynamic>? ?? [])
            .map((t) => TodoItem.fromJson(t as Map<String, dynamic>))
            .toList(),
      );

  String toJsonString() => jsonEncode(toJson());

  factory DailyPlan.fromJsonString(String s) =>
      DailyPlan.fromJson(jsonDecode(s) as Map<String, dynamic>);
}

// ---------------------------------------------------------------------------
// Routine
// ---------------------------------------------------------------------------
class Routine {
  final String id;
  final String text;
  final String frequency; // "günlük", "3 günde 1", "10 dk" vb.

  Routine({
    required this.id,
    required this.text,
    required this.frequency,
  });

  Routine copyWith({String? id, String? text, String? frequency}) => Routine(
        id: id ?? this.id,
        text: text ?? this.text,
        frequency: frequency ?? this.frequency,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'frequency': frequency,
      };

  factory Routine.fromJson(Map<String, dynamic> json) => Routine(
        id: json['id'] as String,
        text: json['text'] as String,
        frequency: json['frequency'] as String,
      );
}

// ---------------------------------------------------------------------------
// DailyStudy
// ---------------------------------------------------------------------------
class DailyStudy {
  final String date;
  final List<String> selectedHobi;
  final List<String> selectedYazi;
  final List<String> selectedYabanciDil;
  final List<String> selectedGelisim;
  final String notes;
  final List<String> routinesDone; // rutin id'leri

  DailyStudy({
    required this.date,
    this.selectedHobi = const [],
    this.selectedYazi = const [],
    this.selectedYabanciDil = const [],
    this.selectedGelisim = const [],
    this.notes = '',
    this.routinesDone = const [],
  });

  DailyStudy copyWith({
    String? date,
    List<String>? selectedHobi,
    List<String>? selectedYazi,
    List<String>? selectedYabanciDil,
    List<String>? selectedGelisim,
    String? notes,
    List<String>? routinesDone,
  }) =>
      DailyStudy(
        date: date ?? this.date,
        selectedHobi: selectedHobi ?? this.selectedHobi,
        selectedYazi: selectedYazi ?? this.selectedYazi,
        selectedYabanciDil: selectedYabanciDil ?? this.selectedYabanciDil,
        selectedGelisim: selectedGelisim ?? this.selectedGelisim,
        notes: notes ?? this.notes,
        routinesDone: routinesDone ?? this.routinesDone,
      );

  Map<String, dynamic> toJson() => {
        'date': date,
        'selectedHobi': selectedHobi,
        'selectedYazi': selectedYazi,
        'selectedYabanciDil': selectedYabanciDil,
        'selectedGelisim': selectedGelisim,
        'notes': notes,
        'routinesDone': routinesDone,
      };

  factory DailyStudy.fromJson(Map<String, dynamic> json) => DailyStudy(
        date: json['date'] as String,
        selectedHobi: List<String>.from(json['selectedHobi'] as List? ?? []),
        selectedYazi: List<String>.from(json['selectedYazi'] as List? ?? []),
        selectedYabanciDil:
            List<String>.from(json['selectedYabanciDil'] as List? ?? []),
        selectedGelisim:
            List<String>.from(json['selectedGelisim'] as List? ?? []),
        notes: json['notes'] as String? ?? '',
        routinesDone:
            List<String>.from(json['routinesDone'] as List? ?? []),
      );

  String toJsonString() => jsonEncode(toJson());

  factory DailyStudy.fromJsonString(String s) =>
      DailyStudy.fromJson(jsonDecode(s) as Map<String, dynamic>);
}

// ---------------------------------------------------------------------------
// AppSettings
// ---------------------------------------------------------------------------
class AppSettings {
  final List<TimeSlot> defaultTimeSlots;
  final List<String> hobiler;
  final List<String> yazilar;
  final List<String> yabanciDiller;
  final List<String> gelisimler;
  final List<Routine> routines;
  final String theme; // 'light' | 'dark'

  AppSettings({
    required this.defaultTimeSlots,
    required this.hobiler,
    required this.yazilar,
    required this.yabanciDiller,
    required this.gelisimler,
    required this.routines,
    this.theme = 'light',
  });

  AppSettings copyWith({
    List<TimeSlot>? defaultTimeSlots,
    List<String>? hobiler,
    List<String>? yazilar,
    List<String>? yabanciDiller,
    List<String>? gelisimler,
    List<Routine>? routines,
    String? theme,
  }) =>
      AppSettings(
        defaultTimeSlots: defaultTimeSlots ?? this.defaultTimeSlots,
        hobiler: hobiler ?? this.hobiler,
        yazilar: yazilar ?? this.yazilar,
        yabanciDiller: yabanciDiller ?? this.yabanciDiller,
        gelisimler: gelisimler ?? this.gelisimler,
        routines: routines ?? this.routines,
        theme: theme ?? this.theme,
      );

  Map<String, dynamic> toJson() => {
        'defaultTimeSlots':
            defaultTimeSlots.map((s) => s.toJson()).toList(),
        'hobiler': hobiler,
        'yazilar': yazilar,
        'yabanciDiller': yabanciDiller,
        'gelisimler': gelisimler,
        'routines': routines.map((r) => r.toJson()).toList(),
        'theme': theme,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
        defaultTimeSlots:
            (json['defaultTimeSlots'] as List<dynamic>? ?? [])
                .map((s) => TimeSlot.fromJson(s as Map<String, dynamic>))
                .toList(),
        hobiler: List<String>.from(json['hobiler'] as List? ?? []),
        yazilar: List<String>.from(json['yazilar'] as List? ?? []),
        yabanciDiller:
            List<String>.from(json['yabanciDiller'] as List? ?? []),
        gelisimler: List<String>.from(json['gelisimler'] as List? ?? []),
        routines: (json['routines'] as List<dynamic>? ?? [])
            .map((r) => Routine.fromJson(r as Map<String, dynamic>))
            .toList(),
        theme: json['theme'] as String? ?? 'light',
      );

  String toJsonString() => jsonEncode(toJson());

  factory AppSettings.fromJsonString(String s) =>
      AppSettings.fromJson(jsonDecode(s) as Map<String, dynamic>);
}

// ---------------------------------------------------------------------------
// DEFAULT_SETTINGS
// ---------------------------------------------------------------------------
final AppSettings DEFAULT_SETTINGS = AppSettings(
  defaultTimeSlots: [
    TimeSlot(id: 'ts1', startTime: '07:00', endTime: '08:00'),
    TimeSlot(id: 'ts2', startTime: '08:00', endTime: '09:00'),
    TimeSlot(id: 'ts3', startTime: '09:00', endTime: '10:00'),
    TimeSlot(id: 'ts4', startTime: '10:00', endTime: '11:00'),
    TimeSlot(id: 'ts5', startTime: '11:00', endTime: '12:00'),
    TimeSlot(id: 'ts6', startTime: '12:00', endTime: '13:00'),
    TimeSlot(id: 'ts7', startTime: '14:00', endTime: '15:00'),
    TimeSlot(id: 'ts8', startTime: '15:00', endTime: '16:00'),
    TimeSlot(id: 'ts9', startTime: '16:00', endTime: '18:00'),
    TimeSlot(id: 'ts10', startTime: '19:00', endTime: '21:00'),
    TimeSlot(id: 'ts11', startTime: '21:00', endTime: '23:00'),
  ],
  hobiler: ['Müzik', 'Resim', 'Spor', 'Okuma'],
  yazilar: ['Roman', 'Makale', 'Şiir', 'Günlük'],
  yabanciDiller: ['İngilizce', 'Almanca', 'Fransızca', 'İspanyolca'],
  gelisimler: ['Meditasyon', 'Podcast', 'Kurs', 'Seminer'],
  routines: [
    Routine(id: 'r1', text: 'Sabah egzersizi', frequency: 'günlük'),
    Routine(id: 'r2', text: 'Meditasyon (10 dk)', frequency: '10 dk'),
    Routine(id: 'r3', text: 'Kitap okuma', frequency: 'günlük'),
    Routine(id: 'r4', text: 'Su içme (2L)', frequency: 'günlük'),
    Routine(id: 'r5', text: 'Yürüyüş', frequency: '3 günde 1'),
    Routine(id: 'r6', text: 'Günlük yazma', frequency: 'günlük'),
    Routine(id: 'r7', text: 'Vitamin alma', frequency: 'günlük'),
    Routine(id: 'r8', text: 'Soğuk duş', frequency: '3 günde 1'),
    Routine(id: 'r9', text: 'Stretching', frequency: 'günlük'),
    Routine(id: 'r10', text: 'Dil pratiği', frequency: 'günlük'),
    Routine(id: 'r11', text: 'Ağırlık antrenmanı', frequency: '3 günde 1'),
    Routine(id: 'r12', text: 'Sosyal medya detoksu', frequency: 'günlük'),
    Routine(id: 'r13', text: 'Haftalık planlama', frequency: '3 günde 1'),
  ],
  theme: 'light',
);
