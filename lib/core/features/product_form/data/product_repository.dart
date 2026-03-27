

import '../model/product_model.dart';

import '../../../database/sqlitedatabase.dart';

/// HSN Repository - Provides a clean API for HSN operations
/// This acts as a middle layer between the UI and Sqlitedatabase
class ProductRepository {

  final tableName = 'Product';

    // Get all HSN
  Future<List<Product>> get() async {
  final rows = await Sqlitedatabase.get(tableName);
  final fetchAllHsn =  rows.map((row) =>  Product.fromJson(row)).toList();
  return  fetchAllHsn ;
  }

  
  //Create and save a new HSN code
  Future<int> create(Product product) async {
    final productMap = product.toJson();
    return await Sqlitedatabase.create(tableName, productMap);
  }


  /// Fetch a specific HSN code by ID
  Future<Product?> getById(int id) async {
    final product = await Sqlitedatabase.getById(tableName,id);
    return product as Product;
  }

  /// Update an existing HSN code
  Future<bool> update(Product product) async {
    final productMap = product.toJson();
    final result = await Sqlitedatabase.update(tableName, product.id!, productMap);
    return result > 0;
  }

  /// Delete an HSN code by ID
  Future<bool> delete(int id) async {
    final result = await Sqlitedatabase.delete(tableName,id);
    return result > 0;
  }

  /// Check if HSN code exists
  // Future<bool> hsnCodeExists(String product) async {
  //   final hsn = await Sqlitedatabase.exist(hsncode);
  //   return hsn != null;
  // }


  /// Close Sqlitedatabase connection
  Future<void> closeConnection() async {
    await Sqlitedatabase.closeDatabase();
  }
}
