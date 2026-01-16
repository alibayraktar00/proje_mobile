import 'package:cloud_firestore/cloud_firestore.dart';
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
import '../ai_assistant/ai_assistant_screen.dart';

final userStreamProvider = StreamProvider<DocumentSnapshot>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return const Stream.empty();
  return FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots();
});

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

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  hintText: "Örn: 500 $unit",
                  hintStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                  filled: true,
                  fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
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
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  hintText: "Yeni Hedef ($unit)",
                  hintStyle: TextStyle(color: isDark ? Colors.white70 : Colors.blueGrey),
                  filled: true,
                  fillColor: isDark ? Colors.blue.withOpacity(0.2) : Colors.blue[50],
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.textTheme.bodyLarge?.color ?? (isDark ? Colors.white : Colors.black);

    final userAsyncValue = ref.watch(userStreamProvider);
    final trackingData = ref.watch(trackingProvider);
    final trackingNotifier = ref.read(trackingProvider.notifier);

    String getDisplayName() {
      return userAsyncValue.when(
        data: (snapshot) {
          if (snapshot.exists) {
            final data = snapshot.data() as Map<String, dynamic>;
            final name = data['name'] as String?;
            if (name != null && name.isNotEmpty) {
              return name;
            }
          }
          return "GYMBUDDY"; // Name not found in Firestore
        },
        loading: () => "...",
        error: (error, stack) => "GYMBUDDY",
      );
    }

    final displayName = getDisplayName();

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
      backgroundColor: theme.scaffoldBackgroundColor,
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
                        Text("Welcome, ${displayName != "GYMBUDDY" ? displayName : ""}", 
                            style: TextStyle(fontSize: 16, color: textColor.withValues(alpha: 0.7), fontWeight: FontWeight.w500)),
                        const SizedBox(height: 4),
                        Text("GYMBUDDY", 
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textColor), 
                            maxLines: 1, 
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.08), blurRadius: 10)],
                        ),
                        child: IconButton(
                          onPressed: () {
                             Navigator.push(context, MaterialPageRoute(builder: (context) => const AIAssistantScreen()));
                          },
                          icon: const Icon(Icons.smart_toy_rounded, color: Colors.blueAccent),
                          tooltip: "AI Assistant",
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.08), blurRadius: 10)],
                        ),
                        child: IconButton(onPressed: signOut, icon: Icon(Icons.logout_rounded, color: Colors.red[400]), tooltip: "Log Out"),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),
              Text("Categories", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
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
              Text("Daily Tracking", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
              const SizedBox(height: 12),

              // --- DINAMIK TAKIP BARLARI ---
              _buildTrackingBar(
                context: context,
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
                context: context,
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
    required BuildContext context,
    required String title,
    required String value,
    required double progress,
    required IconData icon,
    required Color color1,
    required Color color2,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.textTheme.bodyLarge?.color ?? (isDark ? Colors.white : Colors.black);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.08), blurRadius: 8, offset: const Offset(0, 3))],
        ),
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
                      Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor)),
                      Text(value, style: TextStyle(fontSize: 12, color: textColor.withValues(alpha: 0.7), fontWeight: FontWeight.w500)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(color1),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: textColor.withValues(alpha: 0.4)),
          ],
        ),
      ),
    );
  }
}