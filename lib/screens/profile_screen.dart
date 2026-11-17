
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../config/app_theme.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'login_screen.dart';
import '../widgets/network_image_view.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  String formatDate(dynamic rawDate) {
    DateTime? date;

    if (rawDate is Timestamp) {
      date = rawDate.toDate();
    } else if (rawDate is DateTime) {
      date = rawDate;
    }

    if (date == null) return 'Tanggal tidak tersedia';

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day/$month/$year';
  }

  Widget buildPhoto(String foto) {
    final uri = Uri.tryParse(foto);

    final valid = uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;

    if (valid) {
      return ClipOval(
        child: Image.network(
          foto,
          height: 95,
          width: 95,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            return const CircleAvatar(
              radius: 47,
              backgroundColor: Colors.white,
              child: Icon(
                Icons.person,
                size: 55,
                color: AppTheme.secondary,
              ),
            );
          },
        ),
      );
    }

    return const CircleAvatar(
      radius: 47,
      backgroundColor: Colors.white,
      child: Icon(
        Icons.person,
        size: 55,
        color: AppTheme.secondary,
      ),
    );
  }

  Future<void> logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text(
            'Apakah kamu yakin ingin keluar dari aplikasi?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      await AuthService().logout();

      if (!context.mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
        (route) => false,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal logout: $e')),
        );
      }
    }
  }

  Future<void> editProfile(BuildContext context, UserModel user) async {
    final nameController = TextEditingController(text: user.name);
    final kelasController = TextEditingController(text: user.kelas);
    final fotoController = TextEditingController(text: user.foto);
    bool saving = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('Edit Profil'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipOval(
                  child: NetworkImageView(
                    imageUrl: fotoController.text,
                    width: 100,
                    height: 100,
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama siswa',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: kelasController,
                  decoration: const InputDecoration(
                    labelText: 'Kelas',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: fotoController,
                  keyboardType: TextInputType.url,
                  onChanged: (_) => setDialogState(() {}),
                  decoration: const InputDecoration(
                    labelText: 'URL Foto Profil',
                    hintText: 'https://contoh.com/foto.jpg',
                    prefixIcon: Icon(Icons.link),
                  ),
                ),
                const SizedBox(height: 6),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Foto akan berubah setelah URL disimpan.',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: saving
                  ? null
                  : () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: saving
                  ? null
                  : () async {
                      final name = nameController.text.trim();
                      final kelas = kelasController.text.trim();
                      final foto = fotoController.text.trim();
                      final uri =
                          foto.isEmpty ? null : Uri.tryParse(foto);

                      if (name.isEmpty || kelas.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Nama dan kelas wajib diisi.',
                            ),
                          ),
                        );
                        return;
                      }

                      if (foto.isNotEmpty &&
                          (uri == null ||
                              (uri.scheme != 'http' &&
                                  uri.scheme != 'https') ||
                              uri.host.isEmpty)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'URL foto harus berupa alamat HTTP/HTTPS yang valid.',
                            ),
                          ),
                        );
                        return;
                      }

                      setDialogState(() => saving = true);

                      try {
                        await AuthService().updateProfile(
                          uid: user.userId,
                          name: name,
                          kelas: kelas,
                          foto: foto,
                        );

                        if (dialogContext.mounted) {
                          Navigator.pop(dialogContext);
                        }

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Profil berhasil diperbarui.',
                              ),
                            ),
                          );
                        }
                      } catch (e) {
                        setDialogState(() => saving = false);

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Gagal memperbarui profil: $e',
                              ),
                            ),
                          );
                        }
                      }
                    },
              child: saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Simpan'),
            ),
          ],
        ),
      ),
    );

    nameController.dispose();
    kelasController.dispose();
    fotoController.dispose();
  }

  Widget profileInfo(BuildContext context, UserModel user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(23),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppTheme.primary,
            AppTheme.secondary,
          ],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              buildPhoto(user.foto),
              Positioned(
                right: 0,
                bottom: 0,
                child: Material(
                  color: Colors.white,
                  shape: const CircleBorder(),
                  child: IconButton(
                    onPressed: () => editProfile(context, user),
                    icon: const Icon(
                      Icons.edit,
                      color: AppTheme.primary,
                      size: 19,
                    ),
                    tooltip: 'Edit foto dan profil',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            user.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            user.email,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 13),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 17,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Kelas ${user.kelas}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget borrowingHistory(String uid) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: FirestoreService().getBorrowings(uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text(
            'Gagal mengambil riwayat peminjaman.',
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final borrowings = snapshot.data ?? [];

        if (borrowings.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.history,
                  size: 45,
                  color: Colors.grey,
                ),
                SizedBox(height: 10),
                Text(
                  'Belum ada riwayat peminjaman.',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return Column(
          children: borrowings.map((borrowing) {
            return Card(
              color: Colors.white,
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2F1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.science_outlined,
                    color: AppTheme.secondary,
                  ),
                ),
                title: Text(
                  (borrowing['item_name'] ?? '-').toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  'Kode barang: ${borrowing['item_id'] ?? '-'}\n'
                  'Tanggal: ${formatDate(borrowing['borrow_date'])}',
                ),
                isThreeLine: true,
              ),
            );
          }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Pengguna belum login.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profil Saya',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () => logout(context),
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: StreamBuilder<UserModel?>(
        stream: AuthService().watchUserProfile(user.uid),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Gagal mengambil profil.'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final profile = snapshot.data;

          if (profile == null) {
            return const Center(
              child: Text('Profil tidak ditemukan.'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                profileInfo(context, profile),
                const SizedBox(height: 25),
                const Text(
                  'Riwayat Peminjaman',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(height: 15),
                borrowingHistory(user.uid),
                const SizedBox(height: 25),
                ElevatedButton.icon(
                  onPressed: () => logout(context),
                  icon: const Icon(Icons.logout),
                  label: const Text('Keluar dari Akun'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
