
import '../model/hsn_model.dart';

import '../../../database/sqlitedatabase.dart';

/// HSN Repository - Provides a clean API for HSN operations
/// This acts as a middle layer between the UI and Sqlitedatabase
class HSNRepository {

    // Get all HSN
  Future<List<HSN>> get() async {
  final rows = await Sqlitedatabase.get('HSN');
  final fetchAllHsn =  rows.map((row) =>  HSN.fromJson(row)).toList();
  return  fetchAllHsn ;
  }

  
  //Create and save a new HSN code
  Future<int> create(HSN hsn) async {
    final hsnMap = hsn.toJson();
    return await Sqlitedatabase.create('HSN', hsnMap);
  }


  /// Fetch a specific HSN code by ID
  Future<HSN?> getById(int id) async {
    final hsn = await Sqlitedatabase.getById('HSN',id);
    return hsn as HSN;
  }

  /// Update an existing HSN code
  Future<bool> update(HSN hsn) async {
    final hsnMap = hsn.toJson();
    final result = await Sqlitedatabase.update('HSN', hsn.id!, hsnMap);
    return result > 0;
  }

  /// Delete an HSN code by ID
  Future<bool> delete(int id) async {
    final result = await Sqlitedatabase.delete('HSN',id);
    return result > 0;
  }

  /// Check if HSN code exists
  // Future<bool> hsnCodeExists(String hsncode) async {
  //   final hsn = await Sqlitedatabase.exist(hsncode);
  //   return hsn != null;
  // }


  /// Close Sqlitedatabase connection
  Future<void> closeConnection() async {
    await Sqlitedatabase.closeDatabase();
  }
}
