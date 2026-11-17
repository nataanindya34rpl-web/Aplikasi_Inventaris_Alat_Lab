import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../models/item_model.dart';
import '../services/firestore_service.dart';

class ItemFormScreen extends StatefulWidget {
  final ItemModel? item;

  const ItemFormScreen({
    super.key,
    this.item,
  });

  @override
  State<ItemFormScreen> createState() =>
      _ItemFormScreenState();
}

class _ItemFormScreenState extends State<ItemFormScreen> {
  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final categoryController = TextEditingController();
  final codeController = TextEditingController();
  final imageController = TextEditingController();
  final specificationController = TextEditingController();

  String status = 'Available';
  bool loading = false;

  bool get isEditing => widget.item != null;

  @override
  void initState() {
    super.initState();

    final item = widget.item;

    if (item != null) {
      nameController.text = item.itemName;
      categoryController.text = item.category;
      codeController.text = item.code;
      imageController.text = item.image;
      specificationController.text = item.specification;
      status = item.status;
    }

    imageController.addListener(_refreshPreview);
  }

  void _refreshPreview() {
    if (mounted) setState(() {});
  }

  bool isValidUrl(String value) {
    final uri = Uri.tryParse(value.trim());

    return uri != null &&
        (uri.scheme == 'https' || uri.scheme == 'http') &&
        uri.host.isNotEmpty;
  }

  String? validateImageUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'URL foto wajib diisi';
    }

    if (!isValidUrl(value)) {
      return 'Masukkan URL gambar yang benar';
    }

    return null;
  }

  Widget buildImagePreview() {
    final url = imageController.text.trim();

    if (url.isEmpty || !isValidUrl(url)) {
      return Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: const Color(0xFFE5EEF5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              size: 55,
              color: Colors.blueGrey,
            ),
            SizedBox(height: 10),
            Text(
              'Masukkan URL foto untuk melihat preview',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.blueGrey),
            ),
          ],
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.network(
        url,
        width: double.infinity,
        height: 200,
        fit: BoxFit.contain,
        headers: const {
          'User-Agent':
              'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 Version/17.0 Mobile/15E148 Safari/604.1',
          'Referer': 'https://pusatalatlaboratorium.com/',
        },
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;

          return Container(
            height: 200,
            alignment: Alignment.center,
            child: const CircularProgressIndicator(),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          debugPrint('PREVIEW IMAGE ERROR: $error');

          return Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.broken_image_outlined,
                  color: Colors.red,
                  size: 45,
                ),
                SizedBox(height: 8),
                Text(
                  'Foto tidak dapat dimuat',
                  style: TextStyle(color: Colors.red),
                ),
                Text(
                  'Periksa kembali URL gambar',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildInput({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? Function(String?)? validator,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 17),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator ??
            (value) {
              if (value == null || value.trim().isEmpty) {
                return '$label wajib diisi';
              }
              return null;
            },
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          alignLabelWithHint: maxLines > 1,
        ),
      ),
    );
  }

  Future<void> saveItem() async {
    if (loading) return;

    if (!formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      final item = ItemModel(
        itemId: widget.item?.itemId ?? '',
        itemName: nameController.text.trim(),
        category: categoryController.text.trim(),
        code: codeController.text.trim(),
        status: status,
        image: imageController.text.trim(),
        specification: specificationController.text.trim(),
        createdAt:
            widget.item?.createdAt ?? DateTime.now(),
      );

      if (isEditing) {
        await FirestoreService().updateItem(item);
      } else {
        await FirestoreService().addItem(item);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing
                ? 'Inventaris berhasil diperbarui'
                : 'Inventaris berhasil ditambahkan',
          ),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan inventaris: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  void dispose() {
    imageController.removeListener(_refreshPreview);

    nameController.dispose();
    categoryController.dispose();
    codeController.dispose();
    imageController.dispose();
    specificationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Inventaris' : 'Tambah Inventaris',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2F1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  size: 45,
                  color: AppTheme.secondary,
                ),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'Informasi Barang',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppTheme.primary,
              ),
            ),

            const SizedBox(height: 15),

            buildInput(
              label: 'Nama Barang',
              controller: nameController,
              icon: Icons.inventory_2_outlined,
            ),

            buildInput(
              label: 'Kategori',
              controller: categoryController,
              icon: Icons.category_outlined,
            ),

            buildInput(
              label: 'Kode Serial',
              controller: codeController,
              icon: Icons.qr_code,
            ),

            const SizedBox(height: 5),

            const Text(
              'Foto Inventaris',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 10),

            buildInput(
              label: 'URL Foto JPG / PNG / WEBP',
              controller: imageController,
              icon: Icons.link,
              keyboardType: TextInputType.url,
              validator: validateImageUrl,
            ),

            const SizedBox(height: 3),

            const Text(
              'Tempelkan alamat gambar langsung dari internet.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 12),

            buildImagePreview(),

            const SizedBox(height: 25),

            const Text(
              'Spesifikasi Barang',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 12),

            buildInput(
              label: 'Keterangan dan Spesifikasi',
              controller: specificationController,
              icon: Icons.description_outlined,
              maxLines: 4,
            ),

            const SizedBox(height: 5),

            const Text(
              'Status Barang',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: status,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.info_outline),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Available',
                  child: Text('Available'),
                ),
                DropdownMenuItem(
                  value: 'Borrowed',
                  child: Text('Borrowed'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => status = value);
                }
              },
            ),

            const SizedBox(height: 30),

            SizedBox(
              height: 55,
              child: ElevatedButton.icon(
                onPressed: loading ? null : saveItem,
                icon: loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(
                  loading
                      ? 'Menyimpan...'
                      : isEditing
                          ? 'Simpan Perubahan'
                          : 'Tambah Inventaris',
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
