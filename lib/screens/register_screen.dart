
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../config/app_theme.dart';
import '../services/auth_service.dart';
import '../widgets/network_image_view.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final kelasController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final fotoController = TextEditingController();

  final authService = AuthService();

  bool loading = false;
  bool obscurePassword = true;

  Future<void> register() async {
    if (nameController.text.trim().isEmpty ||
        kelasController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.isEmpty) {
      showMessage('Semua kolom wajib diisi kecuali foto.');
      return;
    }

    if (passwordController.text.length < 6) {
      showMessage('Password minimal 6 karakter.');
      return;
    }

    final foto = fotoController.text.trim();

    if (foto.isNotEmpty) {
      final uri = Uri.tryParse(foto);

      if (uri == null ||
          (uri.scheme != 'http' && uri.scheme != 'https') ||
          uri.host.isEmpty) {
        showMessage('URL foto harus menggunakan HTTP atau HTTPS.');
        return;
      }
    }

    setState(() => loading = true);

    try {
      final credential = await authService.register(
        name: nameController.text,
        kelas: kelasController.text,
        email: emailController.text,
        password: passwordController.text,
        foto: foto,
      );

      if (!mounted) return;

      if (credential.user == null) {
        showMessage('Registrasi gagal.');
        return;
      }

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      if (e.code == 'email-already-in-use') {
        showMessage('Email sudah digunakan.');
      } else if (e.code == 'weak-password') {
        showMessage('Password terlalu lemah.');
      } else if (e.code == 'invalid-email') {
        showMessage('Format email tidak valid.');
      } else {
        showMessage(e.message ?? 'Registrasi gagal.');
      }
    } catch (e) {
      if (mounted) {
        showMessage('Registrasi gagal: $e');
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

  @override
  void dispose() {
    nameController.dispose();
    kelasController.dispose();
    emailController.dispose();
    passwordController.dispose();
    fotoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Akun'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(25),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 430,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Daftar Akun',
                    style: TextStyle(
                      fontSize: 29,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Lengkapi data untuk membuat akun baru.',
                  ),
                  const SizedBox(height: 25),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Lengkap',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: kelasController,
                    decoration: const InputDecoration(
                      labelText: 'Kelas',
                      prefixIcon: Icon(Icons.school_outlined),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: passwordController,
                    obscureText: obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: fotoController,
                    keyboardType: TextInputType.url,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      labelText: 'URL Foto Profil (Opsional)',
                      hintText: 'https://contoh.com/foto.jpg',
                      prefixIcon: Icon(Icons.camera_alt_outlined),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Center(
                    child: Column(
                      children: [
                        const Text('Preview Foto Profil'),
                        const SizedBox(height: 8),
                        ClipOval(
                          child: NetworkImageView(
                            imageUrl: fotoController.text,
                            width: 104,
                            height: 104,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  ElevatedButton(
                    onPressed: loading ? null : register,
                    child: loading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text(
                            'Daftar Sekarang',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
