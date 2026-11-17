
import 'package:flutter/material.dart';

import 'config/app_theme.dart';
import 'models/item_model.dart';
import 'services/firestore_service.dart';
import 'widgets/item_card.dart';
import 'widgets/search_field.dart';
import 'screens/item_detail_screen.dart';

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  final searchController = TextEditingController();

  String searchQuery = '';
  String selectedCategory = 'Semua';
  String selectedStatus = 'Semua';

  final firestoreService = FirestoreService();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void openDetail(ItemModel item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ItemDetailScreen(item: item),
      ),
    );
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 23,
        bottom: 13,
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: AppTheme.primary,
        ),
      ),
    );
  }

  Widget buildBannerCarousel() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: firestoreService.getBanners(),
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
                ConnectionState.waiting &&
            !snapshot.hasData) {
          return const SizedBox(
            height: 170,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Container(
            height: 170,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Gagal memuat banner.',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        final banners = snapshot.data ?? [];

        if (banners.isEmpty) {
          return Container(
            height: 170,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Selamat Datang di Inventaris Lab',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }

        return SizedBox(
          height: 170,
          child: PageView.builder(
            itemCount: banners.length,
            itemBuilder: (context, index) {
              final banner = banners[index];

              final imageUrl =
                  (banner['image'] ?? '').toString();

              final uri = Uri.tryParse(imageUrl);

              final validUrl = uri != null &&
                  (uri.scheme == 'http' ||
                      uri.scheme == 'https') &&
                  uri.host.isNotEmpty;

              return Container(
                margin: const EdgeInsets.only(right: 10),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (validUrl)
                      Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) {
                          return Container(
                            color: AppTheme.primary,
                            child: const Icon(
                              Icons.science,
                              color: Colors.white,
                              size: 55,
                            ),
                          );
                        },
                      )
                    else
                      Container(
                        color: AppTheme.primary,
                        child: const Icon(
                          Icons.science,
                          color: Colors.white,
                          size: 55,
                        ),
                      ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primary.withValues(alpha: 0.95),
                            Colors.transparent,
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                          width: 220,
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                (banner['title'] ?? '')
                                    .toString(),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                (banner['subtitle'] ?? '')
                                    .toString(),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget buildHorizontalItems(List<ItemModel> items) {
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 15),
        child: Text(
          'Tidak ada inventaris ditemukan.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: 10),
        itemBuilder: (context, index) {
          return ItemCard(
            item: items[index],
            compact: true,
            onTap: () => openDetail(items[index]),
          );
        },
      ),
    );
  }

  Widget buildCategorySelector(List<String> categories) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = categories[index];

          return ChoiceChip(
            label: Text(category),
            selected: selectedCategory == category,
            selectedColor: const Color(0xFFD8E5FA),
            onSelected: (_) {
              setState(() {
                selectedCategory = category;
              });
            },
          );
        },
      ),
    );
  }

  Widget buildStatusSelector() {
    const statuses = [
      'Semua',
      'Available',
      'Borrowed',
    ];

    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: statuses.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final status = statuses[index];

          return ChoiceChip(
            label: Text(status),
            selected: selectedStatus == status,
            selectedColor: const Color(0xFFD8E5FA),
            onSelected: (_) {
              setState(() {
                selectedStatus = status;
              });
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Inventaris Lab',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            Text(
              'Kelola peralatan laboratorium',
              style: TextStyle(
                fontSize: 11,
                color: Colors.blueGrey,
              ),
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(
              Icons.science_outlined,
              color: AppTheme.secondary,
              size: 28,
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<ItemModel>>(
        stream: firestoreService.getItems(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Gagal mengambil data inventaris.'),
            );
          }

          if (snapshot.connectionState ==
                  ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final allItems = snapshot.data ?? [];

          final categories = <String>{
            'Semua',
            ...allItems.map((item) => item.category),
          }.toList();

          final filteredItems = allItems.where((item) {
            final matchesSearch =
                item.itemName.toLowerCase().contains(
                      searchQuery.toLowerCase(),
                    ) ||
                item.code.toLowerCase().contains(
                      searchQuery.toLowerCase(),
                    ) ||
                item.category.toLowerCase().contains(
                      searchQuery.toLowerCase(),
                    );

            final matchesCategory =
                selectedCategory == 'Semua' ||
                item.category == selectedCategory;

            final matchesStatus =
                selectedStatus == 'Semua' ||
                item.status.toLowerCase() ==
                    selectedStatus.toLowerCase();

            return matchesSearch &&
                matchesCategory &&
                matchesStatus;
          }).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              18,
              5,
              18,
              25,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SearchField(
                  controller: searchController,
                  hintText: 'Cari nama, kategori, atau kode...',
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 22),
                buildBannerCarousel(),
                sectionTitle('Semua Data Inventaris'),
                buildHorizontalItems(filteredItems),
                sectionTitle('Kategori Peralatan'),
                buildCategorySelector(categories),
                sectionTitle('Status Inventaris'),
                buildStatusSelector(),
                sectionTitle('Hasil Inventaris'),
                buildHorizontalItems(filteredItems),
              ],
            ),
          );
        },
      ),
    );
  }
}
