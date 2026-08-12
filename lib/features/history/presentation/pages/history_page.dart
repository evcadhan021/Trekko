import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../rental/presentation/providers/rental_provider.dart';

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  String _selectedFilter = 'all';

  List<Map<String, dynamic>> _filterItems(List<Map<String, dynamic>> items) {
    switch (_selectedFilter) {
      case 'completed':
        return items
            .where(
              (rental) =>
                  (rental['status']?.toString() ?? '').toLowerCase() ==
                  'completed',
            )
            .toList();
      case 'cancelled':
        return items
            .where(
              (rental) =>
                  (rental['status']?.toString() ?? '').toLowerCase() ==
                      'cancelled' ||
                  (rental['status']?.toString() ?? '').toLowerCase() ==
                      'cancelled_by_admin',
            )
            .toList();
      default:
        return items;
    }
  }

  @override
  Widget build(BuildContext context) {
    final histories = ref.watch(rentalHistoryProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Penyewaan'),
        actions: [
          if (FirebaseAuth.instance.currentUser != null)
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded),
              tooltip: 'Hapus semua riwayat',
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) {
                    return AlertDialog(
                      title: const Text('Hapus semua riwayat?'),
                      content: const Text(
                        'Semua item riwayat yang sudah selesai atau dibatalkan akan dihapus. Lanjutkan?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Batal'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Hapus semua'),
                        ),
                      ],
                    );
                  },
                );

                if (confirm != true) return;

                await ref
                    .read(rentalRepositoryProvider)
                    .deleteUserHistory(FirebaseAuth.instance.currentUser!.uid);
                ref.invalidate(rentalHistoryProvider);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Semua riwayat berhasil dihapus.'),
                    ),
                  );
                }
              },
            ),
        ],
      ),
      body: histories.when(
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
                        Icons.history_rounded,
                        size: 48,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Belum ada riwayat',
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

          final completedCount = items
              .where(
                (rental) =>
                    (rental['status']?.toString() ?? '').toLowerCase() ==
                    'completed',
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
                        Icons.history_rounded,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Riwayat transaksi',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${items.length} total transaksi',
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
              Container(
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
                child: Row(
                  children: [
                    Expanded(
                      child: _miniSummaryCard(
                        label: 'Selesai',
                        value: completedCount.toString(),
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _miniSummaryCard(
                        label: 'Total',
                        value: items.length.toString(),
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _filterChip('Semua', 'all'),
                    const SizedBox(width: 8),
                    _filterChip('Selesai', 'completed'),
                    const SizedBox(width: 8),
                    _filterChip('Dibatalkan', 'cancelled'),
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
                    'Tidak ada data riwayat pada filter ini.',
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
                    margin: const EdgeInsets.only(bottom: 12),
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
                                          title: const Text('Hapus riwayat?'),
                                          content: const Text(
                                            'Item riwayat ini akan dihapus dari daftar. Lanjutkan?',
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
                                    ref.invalidate(rentalHistoryProvider);

                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Riwayat berhasil dihapus.',
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  icon: const Icon(
                                    Icons.delete_outline_rounded,
                                  ),
                                  tooltip: 'Hapus riwayat',
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
    return Column(
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
