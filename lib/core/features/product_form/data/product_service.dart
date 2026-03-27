import 'package:inventory_management/core/features/product_form/model/product_model.dart';
import 'product_repository.dart';


class ProductService {
  final ProductRepository _repository = ProductRepository();

  /// Load all HSN codes from database
  Future<List<Product>> get() async {
    try {
      return await _repository.get();
    } catch (e) {
      throw Exception('Failed to load HSN codes: $e');
    }
  }

  /// Save an HSN code to database
  Future<void> save(Product product) async {
    try {
      // Check if updating or creating
      if (product.id != null) {
        // Update existing
        await _repository.update(product);
      } else {
        // Create new
        await _repository.create(product);
      }
    } catch (e) {
      throw Exception('Failed to save HSN code: $e');
    }
  }

  /// Delete an HSN code from database
  Future<void> delete(Product product) async {
    try {
      if (product.id != null) {
        await _repository.delete(product.id!);
      }
    } catch (e) {
      throw Exception('Failed to delete HSN code: $e');
    }
  }

  /// Search for HSN codes
  // Future<List<HSN>> searchHSNCodes(String query) async {
  //   try {
  //     if (query.isEmpty) {
  //       return await _repository.fetchAllHSN();
  //     }
  //     return await _repository.searchHSN(query);
  //   } catch (e) {
  //     throw Exception('Failed to search HSN codes: $e');
  //   }
  // }

  /// Check if HSN code already exists
  // Future<bool> hsnCodeExists(String hsncode) async {
  //   try {
  //     return await _repository.hsnCodeExists(hsncode);
  //   } catch (e) {
  //     throw Exception('Failed to check HSN code: $e');
  //   }
  // }

  /// Close database connection
  Future<void> closeDatabase() async {
    try {
      await _repository.closeConnection();
    } catch (e) {
      throw Exception('Failed to close database: $e');
    }
  }
}
