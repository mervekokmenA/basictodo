import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/models.dart';
import 'services/storage_service.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';
import 'screens/dashboard_screen.dart';
import 'screens/rutinler_screen.dart';
import 'screens/calisma_screen.dart';
import 'screens/ayarlar_screen.dart';
import 'widgets/bottom_nav_widget.dart';

// ---------------------------------------------------------------------------
// SettingsProvider
// ---------------------------------------------------------------------------
class SettingsProvider extends ChangeNotifier {
  AppSettings _settings = DEFAULT_SETTINGS;
  AppSettings get settings => _settings;

  ThemeMode get themeMode =>
      _settings.theme == 'dark' ? ThemeMode.dark : ThemeMode.light;

  Future<void> load() async {
    _settings = await StorageService().loadSettings();
    notifyListeners();
  }

  void update(AppSettings newSettings) {
    _settings = newSettings;
    notifyListeners();
  }
}

// ---------------------------------------------------------------------------
// main()
// ---------------------------------------------------------------------------
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Servisleri başlat
  await StorageService().init();
  await NotificationService().init();
  await NotificationService().requestPermission();

  final settingsProvider = SettingsProvider();
  await settingsProvider.load();

  runApp(
    ChangeNotifierProvider<SettingsProvider>.value(
      value: settingsProvider,
      child: const GunlukPlanlayiciApp(),
    ),
  );
}

// ---------------------------------------------------------------------------
// App widget
// ---------------------------------------------------------------------------
class GunlukPlanlayiciApp extends StatelessWidget {
  const GunlukPlanlayiciApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, provider, _) {
        return MaterialApp(
          title: 'Günlük Planlayıcı',
          debugShowCheckedModeBanner: false,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: provider.themeMode,
          locale: const Locale('tr', 'TR'),
          home: const MainShell(),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Ana kabuk (BottomNavigationBar ile 4 sekme)
// ---------------------------------------------------------------------------
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  // Sayfaları IndexedStack ile tutup yeniden oluşturmayı önle
  static const List<Widget> _pages = [
    DashboardScreen(),
    RutinlerScreen(),
    CalismaScreen(),
    AyarlarScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavWidget(
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
