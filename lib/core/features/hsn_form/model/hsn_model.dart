class HSN {
   int? id;
   String hsncode;
   int taxrate;

  HSN({
    this.id,
    required this.hsncode,
    required this.taxrate,
  });

  /// Convert HSN to JSON for database operations
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hsncode': hsncode,
      'taxrate': taxrate,
    };
  }

  /// Create HSN from JSON
   factory HSN.fromJson(Map<String, dynamic> json) {
    return HSN(
      id: json['id'] as int?,
      hsncode: json['hsncode'] as String,
      taxrate: json['taxrate'] as int,
    );
  }

  

  /// Create a copy with modified fields
  HSN copyWith({
    int? id,
    String? hsncode,
    int? taxrate,
  }) {
    return HSN(
      id: id ?? this.id,
      hsncode: hsncode ?? this.hsncode,
      taxrate: taxrate ?? this.taxrate,
    );
  }
}
