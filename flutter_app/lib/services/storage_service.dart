import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';

class StorageService {
  // Singleton
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ---------------------------------------------------------------------------
  // Date helpers
  // ---------------------------------------------------------------------------
  String formatDateKey(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  String formatDisplayDate(String key) {
    try {
      final dt = DateTime.parse(key);
      return DateFormat('dd.MM.yyyy').format(dt);
    } catch (_) {
      return key;
    }
  }

  // ---------------------------------------------------------------------------
  // Settings
  // ---------------------------------------------------------------------------
  Future<AppSettings> loadSettings() async {
    final raw = _prefs.getString('app_settings');
    if (raw == null) return DEFAULT_SETTINGS;
    try {
      return AppSettings.fromJsonString(raw);
    } catch (_) {
      return DEFAULT_SETTINGS;
    }
  }

  Future<void> saveSettings(AppSettings settings) async {
    await _prefs.setString('app_settings', settings.toJsonString());
  }

  // ---------------------------------------------------------------------------
  // Daily Plan
  // ---------------------------------------------------------------------------
  Future<DailyPlan?> loadPlan(String dateKey) async {
    final raw = _prefs.getString('plan_$dateKey');
    if (raw == null) return null;
    try {
      return DailyPlan.fromJsonString(raw);
    } catch (_) {
      return null;
    }
  }

  Future<void> savePlan(DailyPlan plan) async {
    await _prefs.setString('plan_${plan.date}', plan.toJsonString());
  }

  // ---------------------------------------------------------------------------
  // Daily Study (Rutinler + Çalışmalar aynı obje)
  // ---------------------------------------------------------------------------
  Future<DailyStudy?> loadStudy(String dateKey) async {
    final raw = _prefs.getString('study_$dateKey');
    if (raw == null) return null;
    try {
      return DailyStudy.fromJsonString(raw);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveStudy(DailyStudy study) async {
    await _prefs.setString('study_${study.date}', study.toJsonString());
  }

  // ---------------------------------------------------------------------------
  // Streak hesaplama
  // Bir rutin için son 60 günde kaç gün üst üste yapıldığını döner.
  // ---------------------------------------------------------------------------
  Future<int> getRoutineStreak(
      String routineId, String currentDate) async {
    final today = DateTime.parse(currentDate);
    int streak = 0;

    for (int i = 0; i < 60; i++) {
      final checkDate = today.subtract(Duration(days: i));
      final key = formatDateKey(checkDate);
      final study = await loadStudy(key);
      if (study != null && study.routinesDone.contains(routineId)) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  // ---------------------------------------------------------------------------
  // Son X günde rutin yapıldı mı?
  // ---------------------------------------------------------------------------
  Future<bool> isRoutineDoneRecently(
      String routineId, int daysBack, String currentDate) async {
    final today = DateTime.parse(currentDate);
    // today dahil değil, önceki daysBack gün
    for (int i = 1; i <= daysBack; i++) {
      final checkDate = today.subtract(Duration(days: i));
      final key = formatDateKey(checkDate);
      final study = await loadStudy(key);
      if (study != null && study.routinesDone.contains(routineId)) {
        return true;
      }
    }
    return false;
  }

  // ---------------------------------------------------------------------------
  // Tüm çalışma anahtarlarını listele (streak için yardımcı)
  // ---------------------------------------------------------------------------
  Set<String> allStudyKeys() {
    return _prefs
        .getKeys()
        .where((k) => k.startsWith('study_'))
        .map((k) => k.replaceFirst('study_', ''))
        .toSet();
  }
}
