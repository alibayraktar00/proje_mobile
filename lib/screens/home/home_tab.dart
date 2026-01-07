import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

// Paket ismini kendi proje adınla (gym_buddy_ali_try) kontrol etmeyi unutma
import 'package:gym_buddy_ali_try/providers/tracking_provider.dart';

import '../exercises/exercises_tab.dart';
import '../calculations/calculations_tab.dart';
import '../nutrition/nutrition_tab.dart';
import '../supplements/supplements_tab.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';

class HomeTab extends ConsumerWidget {
  const HomeTab({super.key});

  // Gelişmiş Aksiyon Paneli
  void _showActionDialog({
    required BuildContext context,
    required String title,
    required String unit,
    required Function(double) onAdd,
    required Function(double) onSetTarget,
    required VoidCallback onReset,
  }) {
    final TextEditingController amountController = TextEditingController();
    final TextEditingController targetController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Miktar Ekleme Bölümü
              const Text("Bugüne Ekle", style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "Örn: 500 $unit",
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  final double? val = double.tryParse(amountController.text);
                  if (val != null) onAdd(val);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 45)),
                child: const Text("Ekle"),
              ),
              const Divider(height: 32),

              // Hedef Belirleme Bölümü
              const Text("Günlük Hedefi Güncelle", style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: targetController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "Yeni Hedef ($unit)",
                  filled: true,
                  fillColor: Colors.blue[50],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {
                  final double? val = double.tryParse(targetController.text);
                  if (val != null) onSetTarget(val);
                  Navigator.pop(context);
                },
                style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 45)),
                child: const Text("Hedefi Kaydet"),
              ),
              const Divider(height: 32),

              // Sıfırlama
              TextButton.icon(
                onPressed: () {
                  onReset();
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.refresh, color: Colors.red),
                label: const Text("İlerlemeyi Sıfırla", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final String displayName = firebaseUser?.displayName ?? "GymBuddy";

    final trackingData = ref.watch(trackingProvider);
    final trackingNotifier = ref.read(trackingProvider.notifier);

    void signOut() async {
      try {
        final authService = ref.read(authServiceProvider);
        await authService.signOut();
        if (context.mounted) {
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
        }
      } catch (e) { debugPrint("Exit Error: $e"); }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Kısmı
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Welcome,", style: TextStyle(fontSize: 16, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                        const SizedBox(height: 4),
                        Text(displayName, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 10)]),
                    child: IconButton(onPressed: signOut, icon: Icon(Icons.logout_rounded, color: Colors.red[400]), tooltip: "Log Out"),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              const Text("Categories", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12.0,
                mainAxisSpacing: 12.0,
                childAspectRatio: 1.6,
                children: [
                  _buildModernCard(context, "Exercise", "Follow Your Program", Icons.fitness_center_rounded, Colors.blueAccent, Colors.lightBlueAccent, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ExercisesTab()))),
                  _buildModernCard(context, "Calculate", "Body İndex", Icons.calculate_rounded, Colors.orange, Colors.deepOrangeAccent, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CalculationsTab()))),
                  _buildModernCard(context, "Supplements", "Supplement List", Icons.local_pharmacy_rounded, Colors.green, Colors.tealAccent, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SupplementsTab()))),
                  _buildModernCard(context, "Nutrition", "Diet and Meals", Icons.restaurant_menu_rounded, Colors.redAccent, Colors.pinkAccent, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NutritionTab()))),
                ],
              ),

              const SizedBox(height: 24),
              const Text("Daily Tracking", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              // --- DINAMIK TAKIP BARLARI ---
              _buildTrackingBar(
                title: "Daily Calories",
                value: "${trackingData.currentCalories.toInt()} / ${trackingData.targetCalories.toInt()} kcal",
                progress: (trackingData.currentCalories / trackingData.targetCalories).clamp(0.0, 1.0),
                icon: Icons.local_fire_department_rounded,
                color1: Colors.deepOrange,
                color2: Colors.orangeAccent,
                onTap: () => _showActionDialog(
                  context: context,
                  title: "Kalori Ayarları",
                  unit: "kcal",
                  onAdd: (val) => trackingNotifier.addCalories(val),
                  onSetTarget: (val) => trackingNotifier.setTargetCalories(val),
                  onReset: () => trackingNotifier.resetCalories(),
                ),
              ),
              const SizedBox(height: 12),
              _buildTrackingBar(
                title: "Water Consumption",
                value: "${trackingData.currentWater.toStringAsFixed(1)} / ${trackingData.targetWater} L",
                progress: (trackingData.currentWater / trackingData.targetWater).clamp(0.0, 1.0),
                icon: Icons.water_drop_rounded,
                color1: Colors.blue,
                color2: Colors.lightBlueAccent,
                onTap: () => _showActionDialog(
                  context: context,
                  title: "Su Ayarları",
                  unit: "L",
                  onAdd: (val) => trackingNotifier.addWater(val),
                  onSetTarget: (val) => trackingNotifier.setTargetWater(val),
                  onReset: () => trackingNotifier.resetWater(),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // Arayüz Widget'ları (ModernCard ve TrackingBar)
  Widget _buildModernCard(BuildContext context, String title, String subtitle, IconData icon, Color c1, Color c2, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [c1, c2]),
          boxShadow: [BoxShadow(color: c1.withValues(alpha: 0.3), blurRadius: 6, offset: const Offset(0, 3))],
        ),
        child: Stack(
          children: [
            Positioned(right: -8, bottom: -8, child: Icon(icon, size: 50, color: Colors.white.withValues(alpha: 0.15))),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                    child: Icon(icon, color: Colors.white, size: 18),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 1),
                      Text(subtitle, style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.9)), maxLines: 1, overflow: TextOverflow.ellipsis),
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

  Widget _buildTrackingBar({
    required String title,
    required String value,
    required double progress,
    required IconData icon,
    required Color color1,
    required Color color2,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, 3))]),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(gradient: LinearGradient(colors: [color1, color2]), shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      Text(value, style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: color2.withValues(alpha: 0.15),
                      valueColor: AlwaysStoppedAnimation<Color>(color1),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}