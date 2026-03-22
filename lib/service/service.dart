import 'package:inventory_management/core/features/hsn_form/model/hsn_model.dart';
import '../db/hsn_repository.dart';

/// HSN Service - High-level service that integrates the database with UI logic
/// This is the recommended way to use the HSN database API in your Flutter widgets
class HSNService {
  final HSNRepository _repository = HSNRepository();

  /// Load all HSN codes from database
  Future<List<HSN>> loadAllHSN() async {
    try {
      return await _repository.getHSN();
    } catch (e) {
      throw Exception('Failed to load HSN codes: $e');
    }
  }

  /// Save an HSN code to database
  Future<void> saveHSN(HSN hsn) async {
    try {
      // Check if updating or creating
      if (hsn.id != null) {
        // Update existing
        await _repository.updateHSN(hsn);
      } else {
        // Create new
        await _repository.createHSN(hsn);
      }
    } catch (e) {
      throw Exception('Failed to save HSN code: $e');
    }
  }

  /// Delete an HSN code from database
  Future<void> deleteHSN(HSN hsn) async {
    try {
      if (hsn.id != null) {
        await _repository.deleteHSN(hsn.id!);
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
  Future<bool> hsnCodeExists(String hsncode) async {
    try {
      return await _repository.hsnCodeExists(hsncode);
    } catch (e) {
      throw Exception('Failed to check HSN code: $e');
    }
  }

  /// Get total count of HSN codes
  // Future<int> getHSNCount() async {
  //   try {
  //     return await _repository.getTotalCount();
  //   } catch (e) {
  //     throw Exception('Failed to get HSN count: $e');
  //   }
  // }

  /// Clear all HSN codes (use with caution)
  // Future<void> clearAllHSNCodes() async {
  //   try {
  //     await _repository.clearAll();
  //   } catch (e) {
  //     throw Exception('Failed to clear HSN codes: $e');
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

// ============================================================================
// INTEGRATION EXAMPLE - How to use HSNService in your existing widget
// ============================================================================

/*
Example implementation for HSNManagementWidget:

```dart
import 'db/hsn_service.dart';

class _HSNManagementWidgetState extends State<HSNManagementWidget> {
  final HSNService hsnService = HSNService();
  
  List<HSN> hsnList = [];
  List<HSN> filteredHsnList = [];
  bool isLoading = false;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadHSNData();
  }

  Future<void> _loadHSNData() async {
    setState(() => isLoading = true);
    try {
      final data = await hsnService.loadAllHSNFromDatabase();
      setState(() {
        hsnList = data;
        filteredHsnList = data;
        isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
      setState(() => isLoading = false);
    }
  }

  void _saveHSN(HSN hsn) async {
    try {
      // Check if code already exists (for new codes)
      if (hsn.id == null) {
        final exists = await hsnService.hsnCodeExists(hsn.hsncode);
        if (exists) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('HSN code already exists'),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }
      }

      await hsnService.saveHSNToDatabase(hsn);
      await _loadHSNData();
      
      _closeForm();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            hsn.id != null ? 'HSN updated successfully' : 'HSN added successfully',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _deleteHSN(HSN hsn) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete HSN Code'),
        content: Text('Delete HSN: ${hsn.hsncode}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await hsnService.deleteHSNFromDatabase(hsn);
                await _loadHSNData();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('HSN deleted successfully'),
                    backgroundColor: Colors.red,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _searchHSN(String query) async {
    setState(() => searchQuery = query);
    try {
      final results = await hsnService.searchHSNCodes(query);
      setState(() => filteredHsnList = results);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  void dispose() {
    hsnService.closeDatabase();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HSN Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Show search dialog if needed
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (hsnList.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      onChanged: _searchHSN,
                      decoration: InputDecoration(
                        hintText: 'Search HSN codes...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  child: HSNListView(
                    hsnList: filteredHsnList,
                    onEdit: _openForm,
                    onDelete: _deleteHSN,
                    onAddNew: () => _openForm(null),
                  ),
                ),
              ],
            ),
    );
  }
}
```

This integration:
1. Loads HSN data from database on widget init
2. Saves new/updated codes to database
3. Deletes codes from database
4. Provides search functionality
5. Shows appropriate error messages
6. Closes database connection on widget dispose
*/
