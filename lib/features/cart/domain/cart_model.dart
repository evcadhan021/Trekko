class CartModel {
  final String id;
  final String userId;
  final String productId;
  final String productName;
  final String imageUrl;
  final int pricePerDay;
  final int quantity;

  CartModel({
    required this.id,
    required this.userId,
    required this.productId,
    required this.productName,
    required this.imageUrl,
    required this.pricePerDay,
    required this.quantity,
  });

  factory CartModel.fromMap(String id, Map<String, dynamic> map) {
    return CartModel(
      id: id,
      userId: map['userId'] ?? '',
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      pricePerDay: map['pricePerDay'] ?? 0,
      quantity: map['quantity'] ?? 1,
    );
  }
}
