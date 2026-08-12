import 'package:flutter/material.dart';

class AdminRentalDetailPage extends StatelessWidget {
  final Map<String, dynamic> rental;

  const AdminRentalDetailPage({super.key, required this.rental});

  @override
  Widget build(BuildContext context) {
    final status = (rental['status'] ?? '-').toString();
    final statusColor = _statusColor(status);

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Rental')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    const Color(0xFF0F172A),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      rental['productName'] ?? '-',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      status,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _detailCard(
              title: 'Penyewa',
              value: rental['userName'] ?? '-',
              icon: Icons.person_outline_rounded,
            ),
            const SizedBox(height: 12),
            _detailCard(
              title: 'Durasi',
              value: '${rental['totalDays']} hari',
              icon: Icons.calendar_month_rounded,
            ),
            const SizedBox(height: 12),
            _detailCard(
              title: 'Total Harga',
              value: 'Rp ${rental['totalPrice']}',
              icon: Icons.payments_outlined,
            ),
            const SizedBox(height: 12),
            _detailCard(
              title: 'Status',
              value: status,
              icon: Icons.info_outline_rounded,
              accentColor: statusColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailCard({
    required String title,
    required String value,
    required IconData icon,
    Color accentColor = const Color(0xFF1EA67A),
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accentColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'active':
        return Colors.blue;
      case 'completed':
        return Colors.purple;
      case 'cancelled_by_admin':
      case 'cancelled':
        return Colors.red;
      case 'pending':
      default:
        return Colors.orange;
    }
  }
}
