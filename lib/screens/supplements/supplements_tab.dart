import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/supplement_service.dart';
import '../../models/supplement_model.dart';
import 'supplement_detail_screen.dart';

class SupplementsTab extends StatefulWidget {
  const SupplementsTab({super.key});

  @override
  State<SupplementsTab> createState() => _SupplementsTabState();
}

class _SupplementsTabState extends State<SupplementsTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  
  List<SupplementModel> _guideSupplements = [];
  List<dynamic> _marketProducts = [];
  bool _isLoadingMarket = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _guideSupplements = SupplementService.getAllSupplements();
    _marketProducts = []; 
    // Ideally we could pre-load some popular items for market
    _searchMarket("protein"); 
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    _debounce = Timer(const Duration(milliseconds: 600), () {
      if (_tabController.index == 1) { // Market Tab
         _searchMarket(query.isEmpty ? "protein" : query);
      } else { // Guide Tab
        setState(() {
          _searchQuery = query;
          _guideSupplements = SupplementService.getAllSupplements().where((s) {
            return s.name.toLowerCase().contains(query.toLowerCase()) || 
                   s.category.toLowerCase().contains(query.toLowerCase());
          }).toList();
        });
      }
    });
  }

  Future<void> _searchMarket(String query) async {
    setState(() => _isLoadingMarket = true);
    final results = await SupplementService.searchProducts(query);
    if (mounted) {
      setState(() {
        _marketProducts = results;
        _isLoadingMarket = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 200.0, // Increased height for better visibility
              pinned: true,
              floating: true,
              backgroundColor: theme.scaffoldBackgroundColor,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 20, bottom: 90), // Increased bottom padding to clear the TabBar
                title: Text(
                  'Supplementler',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24, // Slightly larger font
                    shadows: [Shadow(color: Colors.black.withOpacity(0.5), blurRadius: 8)]
                  ),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/images/supplements_banner.png',
                      fit: BoxFit.cover,
                    ),
                    // Gradient overlay to ensure text readability
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(80), // Increased height to fix overflow
                child: Container(
                    decoration: BoxDecoration(
                        color: theme.scaffoldBackgroundColor,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20))
                    ),
                    child: TabBar(
                      controller: _tabController,
                      labelColor: const Color(0xFF8E24AA),
                      unselectedLabelColor: theme.disabledColor,
                      indicatorColor: const Color(0xFF8E24AA),
                      indicatorWeight: 3,
                      indicatorSize: TabBarIndicatorSize.label,
                      tabs: const [
                        Tab(text: "Rehber", icon: Icon(Icons.menu_book_rounded)),
                        Tab(text: "Market (Beta)", icon: Icon(Icons.shopping_bag_outlined)),
                      ],
                      onTap: (index) {
                        _searchController.clear();
                        _onSearchChanged("");
                      },
                    ),
                ),
              ),
            ),
          ];
        },
        body: Column(
            children: [
                // Persistent Search Bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: _tabController.index == 0 ? "Rehberde ara..." : "Ürün ara (örn. Whey)...",
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
                    child: TabBarView(
                        controller: _tabController,
                        children: [
                             _buildGuideList(theme),
                             _buildMarketList(theme),
                        ],
                    ),
                )
            ],
        ),
      ),
    );
  }

  Widget _buildGuideList(ThemeData theme) {
    if (_guideSupplements.isEmpty) {
        return Center(child: Text("Sonuç bulunamadı", style: TextStyle(color: theme.disabledColor)));
    }
  
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _guideSupplements.length,
      itemBuilder: (context, index) {
        final supplement = _guideSupplements[index];
        return Container(
           margin: const EdgeInsets.only(bottom: 16),
           decoration: BoxDecoration(
             color: theme.cardColor,
             borderRadius: BorderRadius.circular(16),
             boxShadow: [
                 BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4))
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

  Widget _buildMarketList(ThemeData theme) {
    if (_isLoadingMarket) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF8E24AA)));
    }
    
    if (_marketProducts.isEmpty) {
        return Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                    Icon(Icons.search_off_rounded, size: 64, color: theme.disabledColor),
                    const SizedBox(height: 16),
                    Text("Ürün bulunamadı.", style: TextStyle(color: theme.disabledColor))
                ],
            ),
        );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.70,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _marketProducts.length,
      itemBuilder: (context, index) {
        final product = _marketProducts[index];
        final brands = product['brands'] ?? 'Unknown Brand';
        final name = product['product_name'] ?? 'Unknown Product';
        final imageUrl = product['image_url'];

        return Container(
          decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 3))
              ]
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: imageUrl != null 
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                        loadingBuilder: (c, child, p) {
                            if (p == null) return child;
                            return Center(child: Icon(Icons.image, color: theme.disabledColor.withOpacity(0.2)));
                        },
                        errorBuilder: (c, e, s) => Center(child: Icon(Icons.broken_image, color: theme.disabledColor)),
                      )
                    : Center(child: Icon(Icons.image_not_supported, color: theme.disabledColor)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: theme.textTheme.bodyLarge?.color),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      brands,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}


