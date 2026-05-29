import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class DateNavigatorWidget extends StatelessWidget {
  final String currentDateKey;
  final ValueChanged<String> onDateChanged;

  const DateNavigatorWidget({
    super.key,
    required this.currentDateKey,
    required this.onDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    final storage = StorageService();
    final displayDate = storage.formatDisplayDate(currentDateKey);
    final todayKey = storage.formatDateKey(DateTime.now());
    final isToday = currentDateKey == todayKey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Geri butonu
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              final date = DateTime.parse(currentDateKey);
              final prev = date.subtract(const Duration(days: 1));
              onDateChanged(storage.formatDateKey(prev));
            },
            tooltip: 'Önceki gün',
          ),
          // Tarih + Bugün butonu
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.parse(currentDateKey),
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
                locale: const Locale('tr', 'TR'),
              );
              if (picked != null) {
                onDateChanged(storage.formatDateKey(picked));
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  displayDate,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                if (!isToday)
                  GestureDetector(
                    onTap: () => onDateChanged(todayKey),
                    child: Text(
                      'Bugün',
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // İleri butonu
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              final date = DateTime.parse(currentDateKey);
              final next = date.add(const Duration(days: 1));
              onDateChanged(storage.formatDateKey(next));
            },
            tooltip: 'Sonraki gün',
          ),
        ],
      ),
    );
  }
}
