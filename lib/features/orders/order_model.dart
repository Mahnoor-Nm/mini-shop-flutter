import 'package:cloud_firestore/cloud_firestore.dart';

class OrderItemModel {
  const OrderItemModel({
    required this.productId,
    required this.title,
    required this.quantity,
    required this.price,
    required this.thumbnail,
  });

  final int productId;
  final String title;
  final int quantity;
  final double price;
  final String thumbnail;

  double get subtotal => price * quantity;

  Map<String, dynamic> toMap() => <String, dynamic>{
    'productId': productId,
    'title': title,
    'quantity': quantity,
    'price': price,
    'thumbnail': thumbnail,
    'subtotal': subtotal,
  };

  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      productId: _asInt(map['productId']),
      title: map['title']?.toString() ?? 'Product',
      quantity: _asInt(map['quantity']),
      price: _asDouble(map['price']),
      thumbnail: map['thumbnail']?.toString() ?? '',
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class OrderModel {
  const OrderModel({
    required this.id,
    required this.orderNumber,
    required this.createdAt,
    required this.status,
    required this.paymentMethod,
    required this.total,
    required this.originalAmount,
    required this.discount,
    required this.delivery,
    required this.deliveryName,
    required this.deliveryPhone,
    required this.deliveryAddress,
    required this.items,
  });

  final String id;
  final String orderNumber;
  final DateTime createdAt;
  final String status;
  final String paymentMethod;
  final double total;
  final double originalAmount;
  final double discount;
  final double delivery;
  final String deliveryName;
  final String deliveryPhone;
  final String deliveryAddress;
  final List<OrderItemModel> items;

  int get itemCount =>
      items.fold(0, (totalCount, item) => totalCount + item.quantity);

  Map<String, dynamic> toFirestore() => <String, dynamic>{
    'orderNumber': orderNumber,
    'createdAt': Timestamp.fromDate(createdAt),
    'status': status,
    'paymentMethod': paymentMethod,
    'originalAmount': originalAmount,
    'discount': discount,
    'delivery': delivery,
    'total': total,
    'deliveryName': deliveryName,
    'deliveryPhone': deliveryPhone,
    'deliveryAddress': deliveryAddress,
    'items': items.map((item) => item.toMap()).toList(growable: false),
  };

  factory OrderModel.fromDocument(String id, Map<String, dynamic> map) {
    final rawItems = map['items'];
    final items = rawItems is List
        ? rawItems
              .whereType<Map>()
              .map(
                (item) =>
                    OrderItemModel.fromMap(Map<String, dynamic>.from(item)),
              )
              .toList(growable: false)
        : const <OrderItemModel>[];

    final rawCreatedAt = map['createdAt'];
    final createdAt = rawCreatedAt is Timestamp
        ? rawCreatedAt.toDate()
        : DateTime.tryParse(rawCreatedAt?.toString() ?? '') ?? DateTime.now();

    return OrderModel(
      id: id,
      orderNumber: map['orderNumber']?.toString() ?? id,
      createdAt: createdAt,
      status: map['status']?.toString() ?? 'Placed',
      paymentMethod: map['paymentMethod']?.toString() ?? 'Cash on delivery',
      total: _asDouble(map['total']),
      originalAmount: _asDouble(map['originalAmount']),
      discount: _asDouble(map['discount']),
      delivery: _asDouble(map['delivery']),
      deliveryName: map['deliveryName']?.toString() ?? '',
      deliveryPhone: map['deliveryPhone']?.toString() ?? '',
      deliveryAddress: map['deliveryAddress']?.toString() ?? '',
      items: items,
    );
  }

  static double _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
