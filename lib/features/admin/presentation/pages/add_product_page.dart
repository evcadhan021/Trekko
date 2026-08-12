import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../product/presentation/providers/product_provider.dart';

class AddProductPage extends ConsumerStatefulWidget {
  const AddProductPage({super.key});

  @override
  ConsumerState<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends ConsumerState<AddProductPage> {
  File? selectedImage;
  final ImagePicker picker = ImagePicker();

  final nameController = TextEditingController();
  final categoryController = TextEditingController();
  final descriptionController = TextEditingController();
  final imageController = TextEditingController();
  final priceController = TextEditingController();
  final stockController = TextEditingController();

  bool isLoading = false;

  Future<void> saveProduct() async {
    try {
      setState(() => isLoading = true);

      if (nameController.text.trim().isEmpty ||
          categoryController.text.trim().isEmpty ||
          imageController.text.trim().isEmpty ||
          priceController.text.trim().isEmpty ||
          stockController.text.trim().isEmpty) {
        throw Exception('Semua field harus diisi terlebih dahulu');
      }

      await ref
          .read(productRepositoryProvider)
          .addProduct(
            name: nameController.text.trim(),
            category: categoryController.text.trim(),
            description: descriptionController.text.trim(),
            imageUrl: imageController.text.trim(),
            pricePerDay: int.parse(priceController.text),
            stock: int.parse(stockController.text),
          );

      ref.invalidate(productsProvider);

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }

    if (mounted) setState(() => isLoading = false);
  }

  Future<void> pickImage() async {
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (file == null) return;
    setState(() => selectedImage = File(file.path));
  }

  Future<String> uploadImage() async {
    if (selectedImage == null) {
      throw Exception('Pilih gambar terlebih dahulu');
    }

    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final refStorage = FirebaseStorage.instance
        .ref()
        .child('products')
        .child('$fileName.jpg');

    await refStorage.putFile(selectedImage!);
    return refStorage.getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Produk')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informasi Produk',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nama Produk'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: categoryController,
              decoration: const InputDecoration(labelText: 'Kategori'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Harga per Hari',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: stockController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Stok'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: imageController,
              decoration: const InputDecoration(labelText: 'URL Gambar'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Deskripsi'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : saveProduct,
                icon: const Icon(Icons.save_rounded),
                label: Text(isLoading ? 'Menyimpan...' : 'Simpan Produk'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
