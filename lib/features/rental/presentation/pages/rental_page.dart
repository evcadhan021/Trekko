import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/rental_provider.dart';

class RentalPage extends ConsumerStatefulWidget {
  const RentalPage({super.key});

  @override
  ConsumerState<RentalPage> createState() => _RentalPageState();
}

class _RentalPageState extends ConsumerState<RentalPage> {
  String _selectedFilter = 'all';

  List<Map<String, dynamic>> _filterItems(List<Map<String, dynamic>> items) {
    switch (_selectedFilter) {
      case 'active':
        return items
            .where(
              (rental) =>
                  (rental['status']?.toString() ?? '').toLowerCase() ==
                  'active',
            )
            .toList();
      case 'pending':
        return items
            .where(
              (rental) =>
                  (rental['status']?.toString() ?? '').toLowerCase() ==
                  'pending',
            )
            .toList();
      case 'confirmed':
        return items
            .where(
              (rental) =>
                  (rental['status']?.toString() ?? '').toLowerCase() ==
                  'confirmed',
            )
            .toList();
      default:
        return items;
    }
  }

  @override
  Widget build(BuildContext context) {
    final rentals = ref.watch(userRentalsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Rental Saya')),
      body: rentals.when(
        data: (items) {
          final filteredItems = _filterItems(items);

          if (items.isEmpty) {
            return Center(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 48,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Belum ada penyewaan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          final activeCount = items
              .where(
                (rental) =>
                    (rental['status']?.toString() ?? '').toLowerCase() ==
                    'active',
              )
              .length;
          final pendingCount = items
              .where(
                (rental) =>
                    (rental['status']?.toString() ?? '').toLowerCase() ==
                    'pending',
              )
              .length;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colorScheme.primary, const Color(0xFF0F172A)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.backpack_rounded,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Status penyewaan',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${items.length} total aktif',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _miniSummaryCard(
                      label: 'Aktif',
                      value: activeCount.toString(),
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _miniSummaryCard(
                      label: 'Pending',
                      value: pendingCount.toString(),
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _filterChip('Semua', 'all'),
                    const SizedBox(width: 8),
                    _filterChip('Aktif', 'active'),
                    const SizedBox(width: 8),
                    _filterChip('Pending', 'pending'),
                    const SizedBox(width: 8),
                    _filterChip('Confirmed', 'confirmed'),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              if (filteredItems.isEmpty)
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Text(
                    'Tidak ada data rental pada filter ini.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                )
              else
                ...filteredItems.map((rental) {
                  final status = rental['status']?.toString() ?? 'pending';
                  final statusColor = _statusColor(status, colorScheme);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                rental['productName'].toString(),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    status,
                                    style: TextStyle(
                                      color: statusColor,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  onPressed: () async {
                                    final result = await showDialog<bool>(
                                      context: context,
                                      builder: (_) {
                                        return AlertDialog(
                                          title: const Text(
                                            'Hapus data rental?',
                                          ),
                                          content: const Text(
                                            'Data rental ini akan dihapus dari daftar dan riwayat. Lanjutkan?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, false),
                                              child: const Text('Batal'),
                                            ),
                                            FilledButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, true),
                                              child: const Text('Hapus'),
                                            ),
                                          ],
                                        );
                                      },
                                    );

                                    if (result != true) return;

                                    await ref
                                        .read(rentalRepositoryProvider)
                                        .deleteRental(rental['id']);
                                    ref.invalidate(userRentalsProvider);
                                    ref.invalidate(rentalHistoryProvider);

                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Data rental berhasil dihapus.',
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  icon: const Icon(
                                    Icons.delete_outline_rounded,
                                  ),
                                  tooltip: 'Hapus rental',
                                  color: Colors.red,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _infoRow('Durasi', '${rental['totalDays']} hari'),
                        const SizedBox(height: 6),
                        _infoRow('Total', 'Rp ${rental['totalPrice']}'),
                        const SizedBox(height: 14),
                        if (status == 'pending')
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: () async {
                                final result = await showDialog<bool>(
                                  context: context,
                                  builder: (_) {
                                    return AlertDialog(
                                      title: const Text('Batalkan Penyewaan?'),
                                      content: const Text(
                                        'Apakah Anda yakin ingin membatalkan penyewaan ini?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text('Tidak'),
                                        ),
                                        FilledButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: const Text('Ya'),
                                        ),
                                      ],
                                    );
                                  },
                                );

                                if (result != true) return;

                                await ref
                                    .read(rentalRepositoryProvider)
                                    .cancelRental(rental['id']);
                                ref.invalidate(userRentalsProvider);
                                ref.invalidate(rentalHistoryProvider);
                              },
                              icon: const Icon(Icons.cancel_outlined),
                              label: const Text('Batalkan'),
                            ),
                          ),
                      ],
                    ),
                  );
                }),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text(e.toString())),
      ),
    );
  }

  Widget _filterChip(String label, String value) {
    final isSelected = _selectedFilter == value;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          _selectedFilter = value;
        });
      },
      selectedColor: Theme.of(context).colorScheme.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : const Color(0xFF334155),
        fontWeight: FontWeight.w600,
      ),
      backgroundColor: Colors.white,
      side: BorderSide(
        color: isSelected
            ? Theme.of(context).colorScheme.primary
            : const Color(0xFFE2E8F0),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
    );
  }

  Widget _miniSummaryCard({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.circle, size: 14, color: color),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }

  Color _statusColor(String status, ColorScheme colorScheme) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'active':
        return colorScheme.primary;
      case 'completed':
        return Colors.blue;
      case 'cancelled_by_admin':
      case 'cancelled':
        return Colors.red;
      case 'pending':
      default:
        return Colors.orange;
    }
  }
}
