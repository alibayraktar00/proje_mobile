import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/exercise_model.dart';
import '../../providers/task_provider.dart';
import '../../services/exercise_service.dart';
import 'exercise_detail_screen.dart';

class ExercisesTab extends ConsumerStatefulWidget {
  const ExercisesTab({super.key});

  @override
  ConsumerState<ExercisesTab> createState() => _ExercisesTabState();
}

class _ExercisesTabState extends ConsumerState<ExercisesTab> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _setsController = TextEditingController(text: "3");
  final TextEditingController _repsController = TextEditingController(text: "12");

  String _selectedCategory = "Tümü";
  String _selectedEquipment = "Tümü";
  String _selectedDifficulty = "Tümü";

  final List<String> _categories = ["Tümü", "Göğüs", "Sırt", "Bacak", "Omuz", "Kol", "Karın", "Cardio"];
  final List<String> _equipments = ["Tümü", "Barbell", "Dumbbell", "Makine", "Vücut Ağırlığı", "Kablo"];
  final List<String> _difficulties = ["Tümü", "Beginner", "Intermediate", "Advanced"];

  final Map<String, String> _bodyPartMap = {
    "Göğüs": "chest",
    "Sırt": "back",
    "Bacak": "upper legs",
    "Omuz": "shoulders",
    "Kol": "upper arms",
    "Karın": "waist",
    "Cardio": "cardio",
  };

  final Map<String, String> _equipmentMap = {
    "Barbell": "barbell",
    "Dumbbell": "dumbbell",
    "Makine": "leverage machine",
    "Vücut Ağırlığı": "body weight",
    "Kablo": "cable",
  };

  bool _isLoading = true;
  String? _error;
  List<ExerciseModel> _exercises = [];

  @override
  void initState() {
    super.initState();
    _fetchExercises();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _setsController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  Future<void> _fetchExercises() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final bodyPart = _bodyPartMap[_selectedCategory];
      final equipment = _equipmentMap[_selectedEquipment];
      final data = await ExerciseService.fetchExercises(
        bodyPart: bodyPart,
        equipment: equipment,
        limit: 80,
      );
      setState(() {
        _exercises = data;
      });
    } catch (_) {
      setState(() {
        _error = "ExerciseDB verisi alınamadı. Lütfen tekrar deneyin.";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<ExerciseModel> get _filteredExercises {
    final query = _searchController.text.toLowerCase();
    return _exercises.where((ex) {
      final matchesSearch = query.isEmpty || ex.name.toLowerCase().contains(query);
      final matchesDifficulty = _selectedDifficulty == "Tümü" || (ex.difficulty ?? "Intermediate").toLowerCase() == _selectedDifficulty.toLowerCase();
      return matchesSearch && matchesDifficulty;
    }).toList();
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text("Filtreler", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  Icon(Icons.filter_list, color: Colors.cyanAccent),
                ],
              ),
              const SizedBox(height: 16),
              _buildFilterDropdown("Kas Grubu", _selectedCategory, _categories, (val) {
                setState(() => _selectedCategory = val ?? "Tümü");
              }),
              const SizedBox(height: 12),
              _buildFilterDropdown("Ekipman", _selectedEquipment, _equipments, (val) {
                setState(() => _selectedEquipment = val ?? "Tümü");
              }),
              const SizedBox(height: 12),
              _buildFilterDropdown("Zorluk", _selectedDifficulty, _difficulties, (val) {
                setState(() => _selectedDifficulty = val ?? "Tümü");
              }),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyanAccent,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _fetchExercises();
                  },
                  child: const Text("Filtreyi Uygula"),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  void _showAddToWorkoutDialog(BuildContext context, ExerciseModel exercise) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: exercise.imageUrl != null
                        ? Image.network(
                            exercise.imageUrl!,
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => Container(
                              width: 70,
                              height: 70,
                              color: Colors.grey.shade800,
                              child: const Icon(Icons.fitness_center, color: Colors.cyanAccent),
                            ),
                          )
                        : Container(
                            width: 70,
                            height: 70,
                            color: Colors.grey.shade800,
                            child: const Icon(Icons.fitness_center, color: Colors.cyanAccent),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(exercise.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _setsController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: "Set", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _repsController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: "Tekrar", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  onPressed: () {
                    final subtitle = "${_setsController.text} x ${_repsController.text}";
                    ref.read(taskProvider.notifier).addTask(exercise.name, subtitle);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("${exercise.name} eklendi!"), backgroundColor: Colors.green),
                    );
                  },
                  child: const Text("Listeme Ekle", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  void _navigateToDetail(BuildContext context, ExerciseModel exercise) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExerciseDetailScreen(exercise: exercise),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1021),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1021),
        elevation: 0,
        title: const Text("Exercises", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt_rounded, color: Colors.cyanAccent),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF11182F),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.3)),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: "Search exercises...",
                        hintStyle: TextStyle(color: Colors.white54),
                        prefixIcon: Icon(Icons.search, color: Colors.cyanAccent),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.cyanAccent,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _showFilterSheet,
                  icon: const Icon(Icons.tune),
                )
              ],
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = cat == _selectedCategory;
                return ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() => _selectedCategory = cat);
                    _fetchExercises();
                  },
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.black : Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  selectedColor: Colors.cyanAccent,
                  backgroundColor: const Color(0xFF11182F),
                  side: BorderSide(color: Colors.cyanAccent.withValues(alpha: 0.4)),
                );
              },
            ),
          ),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.cyanAccent));
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _fetchExercises,
              icon: const Icon(Icons.refresh),
              label: const Text("Tekrar dene"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent, foregroundColor: Colors.black),
            ),
          ],
        ),
      );
    }

    final data = _filteredExercises;
    if (data.isEmpty) {
      return const Center(child: Text("No exercises were found to display.", style: TextStyle(color: Colors.white70)));
    }

    return RefreshIndicator(
      color: Colors.cyanAccent,
      onRefresh: _fetchExercises,
      child: GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 12,
          childAspectRatio: 0.78,
        ),
        itemCount: data.length,
        itemBuilder: (context, index) {
          return _buildExerciseCard(context, data[index]);
        },
      ),
    );
  }

  Widget _buildFilterDropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF11182F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.cyanAccent.withOpacity(0.4)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          dropdownColor: const Color(0xFF0F172A),
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.cyanAccent),
          style: const TextStyle(fontSize: 14, color: Colors.white),
          onChanged: onChanged,
          items: items.map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
        ),
      ),
    );
  }

  Widget _buildExerciseCard(BuildContext context, ExerciseModel item) {
    final difficultyLabel = (item.difficulty ?? "Intermediate").toUpperCase();
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF11182F), Color(0xFF0B1021)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.cyanAccent.withOpacity(0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.cyanAccent.withOpacity(0.15),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _navigateToDetail(context, item),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Hero(
                    tag: 'exercise-${item.id}',
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                      child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: item.imageUrl!,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                              fadeInDuration: const Duration(milliseconds: 200),
                              placeholder: (c, _) => Container(
                                color: const Color(0xFF0B1021),
                                alignment: Alignment.center,
                                child: const CircularProgressIndicator(color: Colors.cyanAccent, strokeWidth: 2),
                              ),
                              errorWidget: (c, e, s) => Container(
                                color: const Color(0xFF0B1021),
                                alignment: Alignment.center,
                                child: const Icon(Icons.broken_image, color: Colors.cyanAccent, size: 36),
                              ),
                            )
                          : Container(
                              color: const Color(0xFF0B1021),
                              alignment: Alignment.center,
                              child: const Icon(Icons.fitness_center, color: Colors.cyanAccent, size: 36),
                            ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: InkWell(
                      onTap: () => _showAddToWorkoutDialog(context, item),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.cyanAccent),
                        ),
                        child: const Icon(Icons.add, color: Colors.cyanAccent, size: 18),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 10,
                    bottom: 10,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.cyanAccent),
                      ),
                      child: const Icon(Icons.play_arrow_rounded, color: Colors.cyanAccent),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _chip(item.bodyPart, Colors.cyanAccent),
                      const SizedBox(width: 6),
                      _chip(difficultyLabel, Colors.pinkAccent),
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

  Widget _chip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}