
import '../core/features/hsn_form/model/hsn_model.dart';

import '../db/sqlitedatabase.dart';

/// HSN Repository - Provides a clean API for HSN operations
/// This acts as a middle layer between the UI and Sqlitedatabase
class HSNRepository {

    // Get all HSN
  Future<List<HSN>> getHSN() async {
  final rows = await Sqlitedatabase.get('HSN');
  final fetchAllHsn =  rows.map((row) =>  HSN.fromJson(row)).toList();
  return  fetchAllHsn ;
  }

  
  //Create and save a new HSN code
  Future<int> createHSN(HSN hsn) async {
    final hsnMap = hsn.toJson();
    return await Sqlitedatabase.create('HSN', hsnMap);
  }


  /// Fetch a specific HSN code by ID
  Future<HSN?> fetchHSNById(int id) async {
    final hsn = await Sqlitedatabase.getById('HSN',id);
    return hsn as HSN;
  }

  /// Update an existing HSN code
  Future<bool> updateHSN(HSN hsn) async {
    final hsnMap = hsn.toJson();
    final result = await Sqlitedatabase.update('HSN', hsn.id!, hsnMap);
    return result > 0;
  }

  /// Delete an HSN code by ID
  Future<bool> deleteHSN(int id) async {
    final result = await Sqlitedatabase.delete(id);
    return result > 0;
  }

  /// Check if HSN code exists
  Future<bool> hsnCodeExists(String hsncode) async {
    final hsn = await Sqlitedatabase.exist(hsncode);
    return hsn != null;
  }


  /// Close Sqlitedatabase connection
  Future<void> closeConnection() async {
    await Sqlitedatabase.closeDatabase();
  }
}
