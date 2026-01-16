import 'package:flutter/material.dart';
import '../../services/supplement_service.dart';
import '../../models/supplement_model.dart';
import 'supplement_detail_screen.dart';

class SupplementsTab extends StatefulWidget {
  const SupplementsTab({super.key});

  @override
  State<SupplementsTab> createState() => _SupplementsTabState();
}

class _SupplementsTabState extends State<SupplementsTab> {
  final TextEditingController _searchController = TextEditingController();
  
  List<SupplementModel> _guideSupplements = [];


  @override
  void initState() {
    super.initState();
    _guideSupplements = SupplementService.getAllSupplements();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _guideSupplements = SupplementService.getAllSupplements().where((s) {
        return s.name.toLowerCase().contains(query.toLowerCase()) || 
               s.category.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Filtered list based on search
    final displayList = _guideSupplements;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 200.0,
              pinned: true,
              floating: true,
              backgroundColor: theme.scaffoldBackgroundColor,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 20, bottom: 20),
                title: Text(
                  'Supplements',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    shadows: [Shadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 8)]
                  ),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/images/supplements_banner.png',
                      fit: BoxFit.cover,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.7),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ];
        },
        body: Column(
            children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: "Search guide...",
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: theme.cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16)
                    ),
                  ),
                ),
                
                Expanded(
                    child: _buildGuideList(theme, displayList),
                )
            ],
        ),
      ),
    );
  }

  Widget _buildGuideList(ThemeData theme, List<SupplementModel> supplements) {
    if (supplements.isEmpty) {
        return Center(child: Text("No results found", style: TextStyle(color: theme.disabledColor)));
    }
  
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: supplements.length,
      itemBuilder: (context, index) {
        final supplement = supplements[index];
        return Container(
           margin: const EdgeInsets.only(bottom: 16),
           decoration: BoxDecoration(
             color: theme.cardColor,
             borderRadius: BorderRadius.circular(16),
             boxShadow: [
                 BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 4))
             ]
           ),
           child: Material(
             color: Colors.transparent,
             child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SupplementDetailScreen(supplement: supplement),
                    ),
                  );
                },
                child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                        children: [
                     Container(
                                 padding: const EdgeInsets.all(12),
                                 width: 80,
                                 height: 80,
                                 decoration: BoxDecoration(
                                     color: Colors.transparent, 
                                     borderRadius: BorderRadius.circular(12)
                                 ),
                                 child: supplement.assetPath != null
                                     ? Image.asset(supplement.assetPath!, fit: BoxFit.contain)
                                     : const Icon(Icons.science_rounded, color: Color(0xFF8E24AA), size: 40),
                             ),
                             const SizedBox(width: 16),
                             Expanded(
                                 child: Column(
                                     crossAxisAlignment: CrossAxisAlignment.start,
                                     children: [
                                         Text(supplement.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: theme.textTheme.bodyLarge?.color)),
                                         const SizedBox(height: 4),
                                         Text(supplement.category, style: const TextStyle(color: Color(0xFF8E24AA), fontWeight: FontWeight.w500, fontSize: 14)),
                                     ],
                                 ),
                             ),
                             Icon(Icons.arrow_forward_ios_rounded, size: 16, color: theme.dividerColor)
                        ],
                    ),
                ),
             ),
           )
        );
      },
    );
  }
}


