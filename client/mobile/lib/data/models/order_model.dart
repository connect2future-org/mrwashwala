import 'cart_item_model.dart';

class OrderModel {
  final String id;
  final String orderId;
  final String status;
  final double totalAmount;
  final String paymentMethod;
  final String paymentStatus;
  final String pickupDate;
  final String pickupTime;
  final String deliveryDate;
  final String orderSummary;
  final DateTime? createdAt;
  final Map<String, dynamic>? selectedBranch;
  final Map<String, dynamic>? customer;
  final List<CartItemModel> items;

  OrderModel({
    required this.id,
    required this.orderId,
    required this.status,
    required this.totalAmount,
    this.paymentMethod = 'Cash on Delivery',
    this.paymentStatus = 'Pending',
    this.pickupDate = '',
    this.pickupTime = '',
    this.deliveryDate = '',
    this.orderSummary = '',
    this.createdAt,
    this.selectedBranch,
    this.customer,
    this.items = const [],
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    var rawItems = json['items'];
    List<CartItemModel> parsedItems = [];
    if (rawItems is List) {
      parsedItems = rawItems
          .map((item) => CartItemModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return OrderModel(
      id: json['_id'] ?? json['id'] ?? '',
      orderId: json['orderId'] ?? '',
      status: json['status'] ?? 'Pending',
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: json['paymentMethod'] ?? 'Cash on Delivery',
      paymentStatus: json['paymentStatus'] ?? 'Pending',
      pickupDate: json['pickupDate'] ?? '',
      pickupTime: json['pickupTime'] ?? '',
      deliveryDate: json['deliveryDate'] ?? '',
      orderSummary: json['orderSummary'] ?? '',
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
      selectedBranch: json['selectedBranch'] is Map<String, dynamic> ? json['selectedBranch'] as Map<String, dynamic> : null,
      customer: json['customer'] is Map<String, dynamic> ? json['customer'] as Map<String, dynamic> : null,
      items: parsedItems,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'orderId': orderId,
      'status': status,
      'totalAmount': totalAmount,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'pickupDate': pickupDate,
      'pickupTime': pickupTime,
      'deliveryDate': deliveryDate,
      'orderSummary': orderSummary,
      'createdAt': createdAt?.toIso8601String(),
      'selectedBranch': selectedBranch,
      'customer': customer,
      'items': items.map((i) => i.toJson()).toList(),
    };
  }

  String get formattedTotal {
    return '₹${totalAmount.toInt() == totalAmount ? totalAmount.toInt() : totalAmount.toStringAsFixed(2)}';
  }

  String get formattedCreatedDate {
    if (createdAt == null) return '';
    final day = createdAt!.day.toString().padLeft(2, '0');
    final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final month = monthNames[createdAt!.month - 1];
    final year = createdAt!.year;
    return '$day $month $year';
  }
}
