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
      setState(() {
        isLoading = true;
      });
      final imageUrl = await uploadImage();
      await ref
          .read(productRepositoryProvider)
          .addProduct(
            name: nameController.text,
            category: categoryController.text,
            description: descriptionController.text,
            imageUrl: imageUrl,
            pricePerDay: int.parse(priceController.text),
            stock: int.parse(stockController.text),
          );

      ref.invalidate(productsProvider);

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }

    setState(() {
      isLoading = false;
    });
  }

  // Fungsi untuk memilih gambar dari galeri //
  Future<void> pickImage() async {
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (file == null) return;

    setState(() {
      selectedImage = File(file.path);
    });
  }

  // Fungsi untuk mengunggah gambar ke Firebase Storage //
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

    return await refStorage.getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Produk')),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
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

            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Harga per Hari'),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: stockController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Stok'),
            ),

            const SizedBox(height: 12),

            Column(
              children: [
                if (selectedImage != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      selectedImage!,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,

                  child: OutlinedButton.icon(
                    onPressed: pickImage,
                    icon: const Icon(Icons.image),
                    label: const Text('Pilih Gambar'),
                  ),
                ),
              ],
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
              child: ElevatedButton(
                onPressed: isLoading ? null : saveProduct,
                child: Text(isLoading ? 'Menyimpan...' : 'Simpan Produk'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
