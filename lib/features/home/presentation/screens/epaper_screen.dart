import 'package:cached_network_image/cached_network_image.dart';
import 'package:chotanews/core/theme/color_tokens.dart';
import 'package:chotanews/features/home/presentation/providers/epaper_provider.dart';
import 'package:chotanews/features/home/presentation/providers/home_provider.dart';
import 'package:chotanews/features/home/presentation/screens/epaper_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class EpaperScreen extends StatefulWidget {
  const EpaperScreen({super.key});

  @override
  State<EpaperScreen> createState() => _EpaperScreenState();
}

class _EpaperScreenState extends State<EpaperScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EpaperProvider>().fetchEpapers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      bottom: false,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Align(
          alignment: Alignment.centerLeft,
          child: Image.asset(
            'assets/images/BigTvPostLogo.png',
            height: 28,
            fit: BoxFit.contain,
          ),
        ),
        backgroundColor: AppColorTokens.primaryRed,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: () {
              _showFilterOptions(context);
            },
          ),
        ],
      ),
      body: Consumer<EpaperProvider>(
        builder: (context, epaperProvider, child) {
          if (epaperProvider.isLoading) {
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.525,
              ),
              itemCount: 6,
              itemBuilder: (context, index) {
                return Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
            );
          }

          if (epaperProvider.epapers.isEmpty) {
            return const Center(child: Text("No e-papers available for selected filters"));
          }

          return GridView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.525,
            ),
            itemCount: epaperProvider.epapers.length,
            itemBuilder: (context, index) {
              final epaper = epaperProvider.epapers[index];
              final paperImages = epaper['paperImages'] as List<dynamic>? ?? [];
              final firstImage = paperImages.isNotEmpty ? paperImages.first : '';
              final logoUrl = epaper['logo'] ?? '';
              final editionName = epaper['editionName'] ?? '';
              final publishDate = epaper['publishDate'] ?? '';

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EpaperDetailScreen(epaper: epaper),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Image section
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: firstImage.isNotEmpty
                            ? CachedNetworkImage(
                          imageUrl: firstImage,
                          fit: BoxFit.fill,
                          placeholder: (context, url) => Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(color: Colors.white),
                          ),
                          errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                        )
                            : const Icon(Icons.image_not_supported,
                            size: 50, color: Colors.grey),
                      ),
                    ),
                    // Red strip at bottom
                    Container(
                      height: 55,
                      decoration: const BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      child: Row(
                        children: [
                          // Left side - Logo without round padding
                          SizedBox(
                            width: 36,
                            height: 36,
                            child: logoUrl.isNotEmpty
                                ? ClipOval(
                              child: CachedNetworkImage(
                                imageUrl: logoUrl,
                                fit: BoxFit.contain,
                                errorWidget: (context, url, error) =>
                                const Icon(Icons.newspaper, size: 18, color: Colors.grey),
                              ),
                            )
                                : const Icon(Icons.newspaper, size: 18, color: Colors.grey),
                          ),
                          const SizedBox(width: 8),
                          // Right side - Edition name and date
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  editionName,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  publishDate,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ));
            },
          );
        },
      ),
      ));
  }

  void _showFilterOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Filter E-Papers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.calendar_month),
                  title: const Text('Filter by Date'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickDate(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.location_city),
                  title: const Text('Filter by Edition'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _showEditionPicker(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.clear_all, color: Colors.red),
                  title: const Text('Clear Filters', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    context.read<EpaperProvider>().clearFilters();
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final provider = context.read<EpaperProvider>();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: provider.selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFE31E24), // AppColorTokens.primaryRed
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null) {
      provider.setDateFilter(pickedDate);
    }
  }

  void _showEditionPicker(BuildContext context) {
    final provider = context.read<EpaperProvider>();
    final editions = provider.getAvailableEditions();
    
    if (editions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No editions available')));
      return;
    }
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Select Edition', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: editions.length,
                  itemBuilder: (context, index) {
                    final edition = editions[index];
                    return ListTile(
                      title: Text(edition),
                      trailing: provider.selectedEdition == edition ? const Icon(Icons.check, color: Color(0xFFE31E24)) : null,
                      onTap: () {
                        provider.setEditionFilter(edition);
                        Navigator.pop(ctx);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}