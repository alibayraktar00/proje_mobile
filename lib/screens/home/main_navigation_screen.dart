import 'package:flutter/material.dart';
import 'home_tab.dart';
import '../profile/profile_tab.dart';
// Task Manager dosyanı import et
import 'task_manager_tab.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  // Sayfalar Listesi
  final List<Widget> _tabs = [
    const HomeTab(),
    const TaskManagerTab(),
    const ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final Color selectedColor = theme.colorScheme.primary;
    final Color unselectedColor = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    final Color barBackground = theme.cardColor;

    return Scaffold(
      // Seçili sayfayı göster
      body: _tabs[_currentIndex],

      bottomNavigationBar: Container(
        // Alt bara hafif bir gölge vererek modernleştirdik
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.08),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed, // Butonlar kaymasın diye sabitliyoruz
          backgroundColor: barBackground,
          selectedItemColor: selectedColor, // Seçili olanın rengi
          unselectedItemColor: unselectedColor,     // Seçili olmayanın rengi
          showSelectedLabels: true,
          showUnselectedLabels: false, // Seçili olmayanın yazısını gizle (Daha temiz görünüm)

          items: [
            // --- 1. BUTON: ANASAYFA (Standart) ---
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded, size: 28, color: _currentIndex == 0 ? selectedColor : unselectedColor), // Normal Boyut
              label: 'Anasayfa',
            ),

            // --- 2. BUTON: TASK MANAGER (BÜYÜK VE HAVALI) ---
            BottomNavigationBarItem(
              icon: Container(
                // İkonun arkasına yuvarlak, hafif renkli bir zemin ekledik
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: _currentIndex == 1
                        ? selectedColor
                        : selectedColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    boxShadow: [
                      if(_currentIndex == 1) // Sadece seçiliyken gölge ver
                        BoxShadow(
                          color: selectedColor.withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                    ]
                ),
                // İkon boyutunu büyüttük (32 px) ve rengini ayarladık
                child: Icon(
                  Icons.assignment_turned_in_rounded, // Daha uygun bir ikon
                  size: 32,
                  color: _currentIndex == 1 ? Colors.white : selectedColor,
                ),
              ),
              label: 'Görevler',
            ),

            // --- 3. BUTON: PROFİL (Standart) ---
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded, size: 28, color: _currentIndex == 2 ? selectedColor : unselectedColor), // Normal Boyut
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
