import 'package:flutter/material.dart';

class AdminRentalDetailPage extends StatelessWidget {
  final Map<String, dynamic> rental;

  const AdminRentalDetailPage({super.key, required this.rental});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Rental')),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const Text(
              'Penyewa',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            Text(rental['userName'] ?? '-'),

            const SizedBox(height: 16),

            const Text('Produk', style: TextStyle(fontWeight: FontWeight.bold)),

            Text(rental['productName'] ?? '-'),

            const SizedBox(height: 16),

            const Text('Durasi', style: TextStyle(fontWeight: FontWeight.bold)),

            Text('${rental['totalDays']} hari'),

            const SizedBox(height: 16),

            const Text(
              'Total Harga',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            Text('Rp ${rental['totalPrice']}'),

            const SizedBox(height: 16),

            const Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),

            Text(rental['status'] ?? '-'),
          ],
        ),
      ),
    );
  }
}
