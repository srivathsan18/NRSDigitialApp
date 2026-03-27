class Product {
  final int? id;
  final int hsnId;
  final String sku;
  final String name;
  final int qty;
  final String? hsnCode; // Optional: to show the code in the list view

  Product({this.id, required this.hsnId, required this.sku, required this.name, required this.qty, this.hsnCode});

  Map<String, dynamic> toJson() => {
    'id': id,
    'hsnId': hsnId,
    'sku': sku,
    'name': name,
    'qty': qty,
  };



  /// Create HSN from JSON
   factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int?,
      hsnId: json['hsnId'] as int,
      sku: json['sku'] as String,
      name: json['name'] as String,
      qty: json['qty'] as int
    );
  }
}