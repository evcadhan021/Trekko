import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../product/domain/product_model.dart';
import '../../../product/presentation/providers/product_provider.dart';

class EditProductPage extends ConsumerStatefulWidget {
  final ProductModel product;

  const EditProductPage({super.key, required this.product});

  @override
  ConsumerState<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends ConsumerState<EditProductPage> {
  late TextEditingController nameController;
  late TextEditingController categoryController;
  late TextEditingController descriptionController;
  late TextEditingController imageController;
  late TextEditingController priceController;
  late TextEditingController stockController;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.product.name);

    categoryController = TextEditingController(text: widget.product.category);

    descriptionController = TextEditingController(
      text: widget.product.description,
    );

    imageController = TextEditingController(text: widget.product.imageUrl);

    priceController = TextEditingController(
      text: widget.product.pricePerDay.toString(),
    );

    stockController = TextEditingController(
      text: widget.product.stock.toString(),
    );
  }

  Future<void> updateProduct() async {
    try {
      setState(() {
        isLoading = true;
      });

      await ref
          .read(productRepositoryProvider)
          .updateProduct(
            productId: widget.product.id,
            name: nameController.text,
            category: categoryController.text,
            description: descriptionController.text,
            imageUrl: imageController.text,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Produk')),

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
              decoration: const InputDecoration(labelText: 'Harga'),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: stockController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Stok'),
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
              child: ElevatedButton(
                onPressed: isLoading ? null : updateProduct,
                child: Text(isLoading ? 'Menyimpan...' : 'Update Produk'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
