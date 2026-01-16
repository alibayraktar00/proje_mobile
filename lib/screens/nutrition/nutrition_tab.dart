import 'package:flutter/material.dart';
import '../../services/nutrition_api_service.dart';
import '../../models/meal_model.dart';
import 'meal_detail_screen.dart';
import 'macro_filter_screen.dart';

class NutritionTab extends StatefulWidget {
  const NutritionTab({super.key});

  @override
  State<NutritionTab> createState() => _NutritionTabState();
}

class _NutritionTabState extends State<NutritionTab> {
  final NutritionApiService _apiService = NutritionApiService();
  String? _selectedMealType;
  late Future<List<MealModel>> _mealsFuture;
  
  // Categories for the filter chips. Value null means "All"
  final List<Map<String, String?>> _categories = [
    {'label': 'All', 'value': null},
    {'label': 'Breakfast', 'value': 'breakfast'},
    {'label': 'Lunch', 'value': 'lunch'},
    {'label': 'Dinner', 'value': 'dinner'},
    {'label': 'Snack', 'value': 'snack'},
  ];

  @override
  void initState() {
    super.initState();
    _loadMeals();
  }

  void _loadMeals() {
    setState(() {
      if (_selectedMealType == null) {
        _mealsFuture = _apiService.getMeals();
      } else {
        _mealsFuture = _apiService.getMealsByType(_selectedMealType!);
      }
    });
  }

  void _filterByMealType(String? mealType) {
    setState(() {
      _selectedMealType = mealType;
      _loadMeals();
    });
  }

  Future<void> _openMacroFilter() async {
    final result = await Navigator.push<Map<String, double?>>(
      context,
      MaterialPageRoute(
        builder: (_) => const MacroFilterScreen(),
      ),
    );

    if (result != null) {
      setState(() {
        _mealsFuture = _apiService.filterMeals(
          minProtein: result['minProtein'],
          maxProtein: result['maxProtein'],
          minCarbs: result['minCarbs'],
          maxCarbs: result['maxCarbs'],
          minFats: result['minFats'],
          maxFats: result['maxFats'],
          maxCalories: result['maxCalories'],
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 140.0,
            floating: true,
            pinned: true,
            backgroundColor: theme.scaffoldBackgroundColor,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: theme.cardColor,
                child: BackButton(color: theme.iconTheme.color),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: Text(
                'My Nutrition Plan',
                style: TextStyle(
                  color: theme.textTheme.titleLarge?.color,
                  fontWeight: FontWeight.bold,
                  fontSize: 20
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark 
                      ? [const Color(0xFF2C1E10), Colors.transparent]
                      : [Colors.orange.withValues(alpha: 0.15), Colors.transparent],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20, top: 20),
                    child: Icon(
                      Icons.restaurant_menu, 
                      size: 80, 
                      color: Colors.orange.withValues(alpha: isDark ? 0.1 : 0.2)
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))
                  ]
                ),
                child: IconButton(
                  icon: Icon(Icons.tune_rounded, color: theme.colorScheme.primary),
                  onPressed: _openMacroFilter,
                ),
              ),
            ],
          ),

          // Filter Chips
          SliverToBoxAdapter(
            child: Container(
              height: 60,
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = _selectedMealType == cat['value'];
                  return ChoiceChip(
                    label: Text(cat['label']!),
                    selected: isSelected,
                    onSelected: (_) => _filterByMealType(cat['value']),
                    selectedColor: Colors.orange,
                    backgroundColor: theme.cardColor,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : theme.textTheme.bodyMedium?.color,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? Colors.orange : theme.dividerColor,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          
          // Meal List
          SliverFillRemaining(
            child: FutureBuilder<List<MealModel>>(
              future: _mealsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.orange));
                } else if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                        const SizedBox(height: 16),
                        Text('Error occurred: ${snapshot.error}', textAlign: TextAlign.center),
                      ],
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.no_meals, size: 64, color: theme.disabledColor),
                        const SizedBox(height: 16),
                        Text(
                          'No meals found matching criteria.',
                          style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6), fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                final meals = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 80),
                  itemCount: meals.length,
                  itemBuilder: (context, index) {
                    final meal = meals[index];
                    return _buildMealCard(context, meal, theme);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealCard(BuildContext context, MealModel meal, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => MealDetailScreen(meal: meal)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // Image
                Hero(
                  tag: 'meal-${meal.id}',
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      image: meal.imageUrl != null 
                        ? DecorationImage(
                            image: NetworkImage(meal.imageUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                    ),
                    child: meal.imageUrl == null
                        ? const Icon(Icons.restaurant, color: Colors.orange, size: 32)
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meal.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold, 
                          fontSize: 16, 
                          color: theme.textTheme.bodyLarge?.color
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        meal.description,
                        style: TextStyle(
                          fontSize: 13, 
                          color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6)
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      
                      // Macros
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildMacroBadge(theme, "${meal.calories.toStringAsFixed(0)} kcal", Colors.orange),
                            const SizedBox(width: 6),
                            _buildMacroBadge(theme, "P: ${meal.protein.toStringAsFixed(0)}g", Colors.blue),
                            const SizedBox(width: 6),
                            _buildMacroBadge(theme, "C: ${meal.carbs.toStringAsFixed(0)}g", Colors.green),
                            const SizedBox(width: 6),
                            _buildMacroBadge(theme, "F: ${meal.fats.toStringAsFixed(0)}g", Colors.red),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                
                Icon(Icons.arrow_forward_ios_rounded, size: 16, color: theme.dividerColor),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildMacroBadge(ThemeData theme, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}
