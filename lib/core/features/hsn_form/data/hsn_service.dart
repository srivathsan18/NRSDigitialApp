import 'package:inventory_management/core/features/hsn_form/model/hsn_model.dart';
import 'hsn_repository.dart';


class HSNService {
  final HSNRepository _repository = HSNRepository();

  /// Load all HSN codes from database
  Future<List<HSN>> get() async {
    try {
      return await _repository.get();
    } catch (e) {
      throw Exception('Failed to load HSN codes: $e');
    }
  }

  /// Save an HSN code to database
  Future<void> save(HSN hsn) async {
    try {
      // Check if updating or creating
      if (hsn.id != null) {
        // Update existing
        await _repository.update(hsn);
      } else {
        // Create new
        await _repository.create(hsn);
      }
    } catch (e) {
      throw Exception('Failed to save HSN code: $e');
    }
  }

  /// Delete an HSN code from database
  Future<void> delete(HSN hsn) async {
    try {
      if (hsn.id != null) {
        await _repository.delete(hsn.id!);
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
