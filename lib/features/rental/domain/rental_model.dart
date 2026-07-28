class RentalModel {
  final String id;
  final String userId;
  final String productId;
  final String productName;

  final DateTime? startDate;
  final DateTime? endDate;

  final int totalDays;
  final int pricePerDay;
  final int totalPrice;

  final String status;

  RentalModel({
    required this.id,
    required this.userId,
    required this.productId,
    required this.productName,
    this.startDate,
    this.endDate,
    required this.totalDays,
    required this.pricePerDay,
    required this.totalPrice,
    required this.status,
  });

  factory RentalModel.fromMap(String id, Map<String, dynamic> map) {
    return RentalModel(
      id: id,
      userId: map['userId'] ?? '',
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',

      startDate: map['startDate'] != null
          ? (map['startDate'] as dynamic).toDate()
          : null,

      endDate: map['endDate'] != null
          ? (map['endDate'] as dynamic).toDate()
          : null,

      totalDays: map['totalDays'] ?? 0,
      pricePerDay: map['pricePerDay'] ?? 0,
      totalPrice: map['totalPrice'] ?? 0,
      status: map['status'] ?? 'pending',
    );
  }
}
