class ProductModel {
  final String id;
  final String name;
  final String category;
  final String description;
  final String imageUrl;
  final int pricePerDay;
  final int stock;
  final bool isBestSeller;

  ProductModel({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.imageUrl,
    required this.pricePerDay,
    required this.stock,
    required this.isBestSeller,
  });

  factory ProductModel.fromMap(String id, Map<String, dynamic> map) {
    return ProductModel(
      id: id,
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      pricePerDay: map['pricePerDay'] ?? 0,
      stock: map['stock'] ?? 0,
      isBestSeller: map['isBestSeller'] ?? false,
    );
  }
}
