import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'settings_screen.dart';

class ProfileTab extends ConsumerStatefulWidget {
  const ProfileTab({super.key});

  @override
  ConsumerState<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends ConsumerState<ProfileTab> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  Uint8List? _profileImage;
  String? _photoUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // --- take data ---
  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          _nameController.text = data['name'] ?? '';
          _surnameController.text = data['surname'] ?? '';
          _ageController.text = (data['age'] ?? '').toString();
          _heightController.text = (data['height'] ?? '').toString();
          _weightController.text = (data['weight'] ?? '').toString();
          _photoUrl = data['photoUrl'];
        });
      }
    }
  }

  Future<void> _saveUserData() async {
    setState(() { _isLoading = true; });
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      int age = int.tryParse(_ageController.text) ?? 0;
      double height = double.tryParse(_heightController.text) ?? 0.0;
      double weight = double.tryParse(_weightController.text) ?? 0.0;
      String? photoUrl;

      // Upload Image if selected
      if (_profileImage != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_images')
            .child('${user.uid}.jpg');
            
        await storageRef.putData(_profileImage!);
        photoUrl = await storageRef.getDownloadURL();
      }

      Map<String, dynamic> userData = {
        'name': _nameController.text,
        'surname': _surnameController.text,
        'age': age,
        'height': height,
        'weight': weight,
        if (photoUrl != null) 'photoUrl': photoUrl,
      };

      if (!mounted) return;
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
        userData,
        SetOptions(merge: true),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profile updated successfully!"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e, stack) {
      debugPrint("Update Error: $e\n$stack");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Select Profile Photo", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSourceButton(
                  icon: Icons.camera_alt,
                  label: "Camera",
                  onTap: () {
                    Navigator.pop(context);
                    _pickImageFromSource(ImageSource.camera);
                  },
                ),
                _buildSourceButton(
                  icon: Icons.photo_library,
                  label: "Gallery",
                  onTap: () {
                    Navigator.pop(context);
                    _pickImageFromSource(ImageSource.gallery);
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Colors.blue),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImageFromSource(ImageSource source) async {
    try {
      PermissionStatus status;
      if (source == ImageSource.camera) {
        status = await Permission.camera.request();
      } else {
        // Android 13+ için photos, altı için storage gerekebilir.
        // permission_handler bunu genelde otomatik yönetir ama garantiye alalım.
        if (await Permission.photos.isGranted) {
           status = PermissionStatus.granted;
        } else {
           status = await Permission.photos.request();
        }
        
        if (status.isPermanentlyDenied) {
           // Fallback for older android versions or specifics
           status = await Permission.storage.request();
        }
      }

      if (status.isPermanentlyDenied) {
         if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Permission denied. You need to allow access in settings."),
              action: SnackBarAction(label: "Settings", onPressed: openAppSettings),
            ),
          );
        }
        return;
      }
      

      
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 800, // Optimize image size
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() { 
          _profileImage = bytes; 
        });
      }
    } catch (e) {
      debugPrint("Image Picker Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Image not selected: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final Color primaryColor = Colors.blue.shade800;
    final Color secondaryColor = Colors.blue.shade400;


    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER PART ---
            SizedBox(
              height: 280,
              child: Stack(
                children: [
                   Positioned(
                     top: 0, 
                     left: 0, 
                     right: 0,
                     height: 220,
                     child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [secondaryColor, primaryColor],
                        ),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                     ),
                   ),
                  Positioned(
                    top: 50,
                    left: 0,
                    right: 0,
                    child: const Center(
                      child: Text(
                        "Edit Profile",
                        style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
                            ),
                            child: CircleAvatar(
                              radius: 60,
                              backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                              backgroundImage: _profileImage != null 
                                  ? MemoryImage(_profileImage!) 
                                  : (_photoUrl != null ? NetworkImage(_photoUrl!) : null) as ImageProvider?,
                              child: (_profileImage == null && _photoUrl == null)
                                  ? Icon(Icons.person, size: 60, color: isDark ? Colors.grey[600] : Colors.grey[400])
                                  : null,
                            ),
                          ),
                          Positioned(
                            bottom: 5,
                            right: 5,
                            child: InkWell(
                              onTap: _pickImage,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.orangeAccent,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: isDark ? 0.3 : 0.1), blurRadius: 10)],
                    ),
                    child: Column(
                      children: [
                        _buildModernTextField("Name", _nameController, Icons.person, theme),
                        const SizedBox(height: 15),
                        _buildModernTextField("Surname", _surnameController, Icons.person_outline, theme),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(child: _buildStatCard("Age", _ageController, Icons.cake, Colors.orange, theme)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildStatCard("Height (cm)", _heightController, Icons.height, Colors.blue, theme)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildStatCard("Weight (kg)", _weightController, Icons.monitor_weight, Colors.purple, theme)),
                    ],
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _saveUserData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: const Text("Save Changes", style: TextStyle(fontSize: 18, color: Colors.white)),
                    ),
                  ),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernTextField(String label, TextEditingController controller, IconData icon, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return TextField(
      controller: controller,
      style: TextStyle(color: theme.textTheme.bodyLarge?.color),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: theme.textTheme.bodyLarge?.color?.withValues(alpha: 0.7)),
        prefixIcon: Icon(icon, color: Colors.blue.shade300),
        filled: true,
        fillColor: isDark ? theme.cardColor : Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? Colors.grey[700]! : Colors.transparent),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, TextEditingController controller, IconData icon, Color color, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.textTheme.bodyLarge?.color ?? (isDark ? Colors.white : Colors.black);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: isDark ? 0.3 : 0.1), blurRadius: 8)],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 5),
          Text(label, style: TextStyle(fontSize: 12, color: textColor.withValues(alpha: 0.7))),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor),
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              hintText: "-",
              hintStyle: TextStyle(color: textColor.withValues(alpha: 0.5)),
            ),
          ),
        ],
      ),
    );
  }


}
