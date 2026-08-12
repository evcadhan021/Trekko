import 'package:flutter/material.dart';

class HikingGuidePage extends StatelessWidget {
  const HikingGuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    final tips = [
      'Siapkan fisik dengan latihan ringan dan hidrasi yang cukup sebelum mendaki.',
      'Bawa perlengkapan dasar: tas, sepatu nyaman, jaket, power bank, dan perlengkapan darurat.',
      'Selalu cek cuaca, jalur, dan durasi pendakian sebelum berangkat.',
      'Naiklah dengan pacing yang sesuai dan jangan memaksakan diri saat mulai lelah.',
      'Jaga sampah, patuhi aturan pendakian, dan hormati alam serta sesama pendaki.',
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Panduan Pendaki')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFF1E9E5A), const Color(0xFF0F172A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TREKKO',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Jalan sehat, aman, dan siap mendaki.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Bergabunglah dengan pendaki baru dan nikmati pengalaman mendaki dengan alat yang tepat dan persiapan yang aman.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'Untuk para pendaki pemula',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              ...tips.asMap().entries.map((entry) {
                final index = entry.key;
                final tip = entry.value;

                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF1E9E5A,
                          ).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Color(0xFF1E9E5A),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          tip,
                          style: const TextStyle(fontSize: 14, height: 1.6),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 22),
              const Text(
                'Aturan dasar saat mendaki',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              _ruleCard(
                '1. Jangan mendaki sendiri di jalur yang belum familiar.',
              ),
              _ruleCard('2. Pastikan alat dan pakaian sesuai kondisi cuaca.'),
              _ruleCard('3. Sering istirahat agar kondisi tubuh tetap prima.'),
              _ruleCard(
                '4. Selalu bawa alat darurat dan informasi kontak penting.',
              ),
              _ruleCard(
                '5. Hargai alam dan jangan meninggalkan sampah di jalur pendakian.',
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E9E5A),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('Kembali ke Home'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _ruleCard(String text) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Text(text, style: const TextStyle(fontSize: 14, height: 1.6)),
    );
  }
}
