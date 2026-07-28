import 'package:flutter/material.dart';

class AccessDeniedPage extends StatelessWidget {
  const AccessDeniedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Akses Ditolak')),

      body: const Center(
        child: Text(
          'Halaman ini hanya dapat diakses Admin',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
