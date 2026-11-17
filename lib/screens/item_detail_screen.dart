
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../config/app_theme.dart';
import '../models/item_model.dart';
import '../services/firestore_service.dart';

class ItemDetailScreen extends StatefulWidget {
  final ItemModel item;

  const ItemDetailScreen({
    super.key,
    required this.item,
  });

  @override
  State<ItemDetailScreen> createState() =>
      _ItemDetailScreenState();
}

class _ItemDetailScreenState
    extends State<ItemDetailScreen> {
  bool loading = false;

  Future<void> borrowItem() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      showMessage('Silakan login terlebih dahulu.');
      return;
    }

    setState(() => loading = true);

    try {
      await FirestoreService().borrowItem(
        uid: user.uid,
        item: widget.item,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Pengajuan peminjaman berhasil disimpan.',
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        showMessage(
          e.toString().replaceFirst('Exception: ', ''),
        );
      }
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget detailRow(
    String title,
    String value,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: AppTheme.secondary,
            size: 22,
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value.isEmpty ? '-' : value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    final isAvailable =
        item.status.toLowerCase() == 'available';

    final uri = Uri.tryParse(item.image);

    final validImage = uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detail Inventaris',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: validImage
                  ? Image.network(
                      item.image,
                      height: 240,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return Container(
                          height: 240,
                          color: const Color(0xFFE5EEF5),
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              size: 65,
                            ),
                          ),
                        );
                      },
                    )
                  : Container(
                      height: 240,
                      width: double.infinity,
                      color: const Color(0xFFE5EEF5),
                      child: const Icon(
                        Icons.image_not_supported,
                        size: 65,
                      ),
                    ),
            ),
            const SizedBox(height: 22),
            Text(
              item.itemName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 9),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 13,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: isAvailable
                    ? const Color(0xFFE0F2F1)
                    : const Color(0xFFFFE0E0),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                item.status,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isAvailable
                      ? Colors.teal
                      : Colors.red,
                ),
              ),
            ),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  detailRow(
                    'Kategori',
                    item.category,
                    Icons.category_outlined,
                  ),
                  const Divider(),
                  detailRow(
                    'Kode Serial',
                    item.code,
                    Icons.qr_code,
                  ),
                  const Divider(),
                  detailRow(
                    'Status',
                    item.status,
                    Icons.info_outline,
                  ),
                  const Divider(),
                  detailRow(
                    'Spesifikasi',
                    item.specification,
                    Icons.description_outlined,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            ElevatedButton.icon(
              onPressed:
                  isAvailable && !loading ? borrowItem : null,
              icon: const Icon(Icons.assignment_outlined),
              label: Text(
                loading
                    ? 'Memproses...'
                    : isAvailable
                        ? 'Ajukan Peminjaman'
                        : 'Barang Sedang Dipinjam',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
