import 'package:firebase_auth/firebase_auth.dart'; // FirebaseAuth eklendi
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../exercises/exercises_tab.dart';
import '../calculations/calculations_tab.dart';
import '../nutrition/nutrition_tab.dart';
import '../supplements/supplements_tab.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';

class HomeTab extends ConsumerWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Veritabanındaki kullanıcı modelini dinle
    final userModel = ref.watch(currentUserProvider);

    // 2. Firebase Auth kullanıcısını al (Anlık güncel isim için)
    final firebaseUser = FirebaseAuth.instance.currentUser;

    // 3. İsim Belirleme Mantığı:
    // Öncelik 1: Veritabanındaki modelde isim var mı? (userModel.name varsa onu kullan)
    // Öncelik 2: Yoksa Firebase Auth'daki 'displayName'i kullan.
    // Öncelik 3: Hiçbiri yoksa 'GymBuddy' yaz.
    String displayName = "GymBuddy";

    if (firebaseUser?.displayName != null && firebaseUser!.displayName!.isNotEmpty) {
      displayName = firebaseUser.displayName!;
    }
    // Eğer User Modelinde isim alanı varsa şunun gibi yapabilirsin:
    // else if (userModel != null && userModel.name.isNotEmpty) {
    //   displayName = userModel.name;
    // }

    void signOut() async {
      try {
        final authService = ref.read(authServiceProvider);
        await authService.signOut();
        if (context.mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
          );
        }
      } catch (e) {
        debugPrint("Çıkış hatası: $e");
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HEADER ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hoş Geldin,",
                          style: TextStyle(fontSize: 16, color: Colors.grey[600], fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 4),
                        // DİNAMİK İSİM
                        Text(
                          displayName,
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10)],
                    ),
                    child: IconButton(
                      onPressed: signOut,
                      icon: Icon(Icons.logout_rounded, color: Colors.red[400]),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),
              const Text("Kategoriler", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              // --- GRID MENÜ ---
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: 0.85,
                  children: [
                    _buildModernCard(context, "Egzersiz", "Programını Takip Et", Icons.fitness_center_rounded, Colors.blueAccent, Colors.lightBlueAccent, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ExercisesTab()))),
                    _buildModernCard(context, "Hesapla", "Vücut Endeksi", Icons.calculate_rounded, Colors.orange, Colors.deepOrangeAccent, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CalculationsTab()))),
                    _buildModernCard(context, "Takviye", "Supplement Listesi", Icons.local_pharmacy_rounded, Colors.green, Colors.tealAccent, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SupplementsTab()))),
                    _buildModernCard(context, "Beslenme", "Diyet ve Öğünler", Icons.restaurant_menu_rounded, Colors.redAccent, Colors.pinkAccent, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NutritionTab()))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernCard(BuildContext context, String title, String subtitle, IconData icon, Color c1, Color c2, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [c1, c2]),
          boxShadow: [BoxShadow(color: c1.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 8))],
        ),
        child: Stack(
          children: [
            Positioned(right: -10, bottom: -10, child: Icon(icon, size: 80, color: Colors.white.withOpacity(0.2))),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                    child: Icon(icon, color: Colors.white, size: 28),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 4),
                      Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8))),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}