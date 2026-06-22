import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/jelajah_screen.dart';
import 'screens/cerita_saya_screen.dart';
import 'screens/profil_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/admin/admin_shell.dart';
import 'services/auth_service.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'utils/localization.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const KisantaraApp());
}

class KisantaraApp extends StatelessWidget {
  const KisantaraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppLocalizations.currentLanguageNotifier,
      builder: (context, lang, child) {
        return MaterialApp(
          title: 'Kisantara',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF00743B),
              surface: const Color(0xFFFEFDF1),
            ),
            textTheme: GoogleFonts.plusJakartaSansTextTheme(),
          ),
          home: const AuthGate(), // Entry point: AuthGate checks active session
        );
      },
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  void _checkAuth() async {
    // Wait for the widgets binding to be initialized and Firebase to restore session
    await Future.delayed(const Duration(milliseconds: 500));
    final currentUser = _authService.currentUser;
    if (currentUser == null) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } else {
      final profile = await _authService.getUserProfile(currentUser.uid);
      if (!mounted) return;
      if (profile != null) {
        if (profile.language.isNotEmpty) {
          AppLocalizations.changeLanguage(profile.language);
        }
        if (profile.role == 'admin') {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const AdminShell()),
          );
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeShell()),
          );
        }
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeShell()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFFEFDF1),
      body: Center(
        child: CircularProgressIndicator(
          color: Color(0xFF00743B),
        ),
      ),
    );
  }
}


class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;

  // Build screens dynamically (not const) so they rebuild when language changes
  List<Widget> get _screens => [
    const JelajahScreen(),
    const CeritaSayaScreen(),
    const ProfilScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // ValueListenableBuilder ensures all child screens rebuild on language change
    return ValueListenableBuilder<String>(
      valueListenable: AppLocalizations.currentLanguageNotifier,
      builder: (context, _, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFFEFDF1),
          body: Stack(
            children: [
              _screens[_currentIndex],
              // Bottom Navigation Bar
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _BottomNav(
                  currentIndex: _currentIndex,
                  onTap: (i) => setState(() => _currentIndex = i),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// Bottom Navigation Bar
// ─────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5).withValues(alpha: 0.92),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(48)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00743B).withValues(alpha: 0.08),
            blurRadius: 48,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _NavItem(
                icon: Icons.explore_rounded,
                activeIcon: Icons.explore_rounded,
                label: AppLocalizations.translate('beranda'),
                isActive: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              _NavItem(
                icon: Icons.menu_book_outlined,
                activeIcon: Icons.menu_book_rounded,
                label: AppLocalizations.translate('cerita_saya'),
                isActive: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              _NavItem(
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
                label: AppLocalizations.translate('profil'),
                isActive: currentIndex == 2,
                onTap: () => onTap(2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 24 : 16,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFFA7F3D0).withValues(alpha: 0.5)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(9999),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive
                  ? const Color(0xFF047857)
                  : const Color(0xFF059669).withValues(alpha: 0.7),
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isActive
                    ? const Color(0xFF064E3B)
                    : const Color(0xFF059669).withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
