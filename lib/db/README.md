# HSN Database API Documentation

## Overview

This HSN Database API provides a complete solution for managing HSN (Harmonized System Nomenclature) codes with persistent storage using SQLite. The API includes database operations, repository pattern for clean code, and easy integration with your Flutter UI.

## Files Created

### 1. **lib/db/hsn_database.dart**
   - Low-level database operations using SQLite
   - Handles all CRUD operations directly with the database
   - Manages database initialization and schema creation
   - Singleton pattern with lazy initialization

### 2. **lib/db/hsn_repository.dart**
   - High-level business logic layer
   - Clean API for HSN operations
   - Wraps database operations with proper error handling
   - Recommended for use in your application

### 3. **lib/db/HSN_API_USAGE_GUIDE.dart**
   - Complete usage examples and documentation
   - Shows different integration patterns
   - Includes advanced usage patterns with Provider

## Database Schema

```sql
CREATE TABLE hsn_codes (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  hsncode TEXT UNIQUE NOT NULL,
  taxrate INTEGER NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
```

## Dependencies Added

Add these to your `pubspec.yaml`:
```yaml
dependencies:
  sqflite: ^2.3.0
  path: ^1.9.0
```

Run `flutter pub get` to install the dependencies.

## Quick Start

### 1. Setup (Do this once in main.dart)

```dart
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}
```

### 2. Basic Usage

```dart
import 'db/hsn_repository.dart';

final hsnRepository = HSNRepository();

// Create a new HSN code
await hsnRepository.createHSN(
  hsncode: '1234567890',
  taxrate: 5,
);

// Fetch all HSN codes
List<HSN> allCodes = await hsnRepository.fetchAllHSN();

// Update an HSN code
await hsnRepository.updateHSN(
  id: 1,
  hsncode: '9876543210',
  taxrate: 18,
);

// Delete an HSN code
await hsnRepository.deleteHSN(1);
```

## API Reference

### HSNRepository Methods

#### Create Operations
- **`createHSN(String hsncode, int taxrate) -> Future<int>`**
  - Creates a new HSN code
  - Returns the ID of the created record
  - Throws exception if hsncode already exists

#### Read Operations
- **`fetchAllHSN() -> Future<List<HSN>>`**
  - Fetches all HSN codes from database
  - Ordered by creation date (newest first)
  - Returns empty list if no codes exist

- **`fetchHSNById(int id) -> Future<HSN?>`**
  - Fetches a specific HSN code by its ID
  - Returns null if not found

- **`fetchHSNByCode(String hsncode) -> Future<HSN?>`**
  - Fetches a specific HSN code by its code value
  - Returns null if not found

- **`searchHSN(String query) -> Future<List<HSN>>`**
  - Searches HSN codes using partial match
  - Example: `searchHSN('123')` finds all codes containing '123'

#### Update Operations
- **`updateHSN(int id, String hsncode, int taxrate) -> Future<bool>`**
  - Updates an existing HSN code
  - Returns true if successful
  - Requires a valid id

#### Delete Operations
- **`deleteHSN(int id) -> Future<bool>`**
  - Deletes an HSN code by ID
  - Returns true if successful

- **`deleteHSNByCode(String hsncode) -> Future<bool>`**
  - Deletes an HSN code by its code value
  - Returns true if successful

#### Utility Methods
- **`getTotalCount() -> Future<int>`**
  - Returns the total number of HSN codes in the database

- **`hsnCodeExists(String hsncode) -> Future<bool>`**
  - Checks if a specific HSN code already exists

- **`saveHSN(HSN hsn) -> Future<int>`**
  - Saves an HSN object (creates if new, updates if has id)
  - Returns the ID

- **`clearAll() -> Future<void>`**
  - Deletes all HSN codes (use with caution!)

- **`closeConnection() -> Future<void>`**
  - Closes the database connection

## Integration with Existing Code

### Option 1: Update HSNManagementWidget (Recommended)

```dart
import 'db/hsn_repository.dart';

class _HSNManagementWidgetState extends State<HSNManagementWidget> {
  final _repository = HSNRepository();
  List<HSN> hsnList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHSNData();
  }

  Future<void> _loadHSNData() async {
    try {
      setState(() => isLoading = true);
      hsnList = await _repository.fetchAllHSN();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _saveHSN(HSN hsn) async {
    try {
      await _repository.saveHSN(hsn);
      await _loadHSNData();
      // Show success message
    } catch (e) {
      // Handle error
    }
  }

  void _deleteHSN(HSN hsn) async {
    try {
      if (hsn.id != null) {
        await _repository.deleteHSN(hsn.id!);
        await _loadHSNData();
      }
    } catch (e) {
      // Handle error
    }
  }
}
```

### Option 2: Use with Provider (State Management)

If you want to use Provider for state management:

1. Add to pubspec.yaml:
```yaml
dependencies:
  provider: ^6.0.0
```

2. Create a notifier:
```dart
import 'package:flutter/material.dart';
import 'db/hsn_repository.dart';

class HSNNotifier extends ChangeNotifier {
  final _repository = HSNRepository();
  List<HSN> _hsnList = [];
  bool _isLoading = false;

  List<HSN> get hsnList => _hsnList;
  bool get isLoading => _isLoading;

  Future<void> loadAll() async {
    _isLoading = true;
    notifyListeners();
    _hsnList = await _repository.fetchAllHSN();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addHSN(String hsncode, int taxrate) async {
    await _repository.createHSN(hsncode: hsncode, taxrate: taxrate);
    await loadAll();
  }
}
```

3. Use in your widget:
```dart
class HSNManagementWidget extends StatefulWidget {
  @override
  State<HSNManagementWidget> createState() => _HSNManagementWidgetState();
}

class _HSNManagementWidgetState extends State<HSNManagementWidget> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<HSNNotifier>().loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HSNNotifier>(
      builder: (context, notifier, _) {
        if (notifier.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
          itemCount: notifier.hsnList.length,
          itemBuilder: (context, index) {
            final hsn = notifier.hsnList[index];
            return ListTile(
              title: Text('HSN: ${hsn.hsncode}'),
              subtitle: Text('Tax: ${hsn.taxrate}%'),
            );
          },
        );
      },
    );
  }
}
```

## Error Handling

All database operations throw exceptions with descriptive error messages. Always wrap calls in try-catch:

```dart
try {
  final hsn = await hsnRepository.fetchHSNById(1);
} catch (e) {
  print('Error: $e');
  // Handle error appropriately
}
```

## Best Practices

1. **Always initialize database** before using it:
   ```dart
   void main() async {
     WidgetsFlutterBinding.ensureInitialized();
     // Database will auto-initialize on first use
     runApp(MyApp());
   }
   ```

2. **Check for existence before operations**:
   ```dart
   if (await hsnRepository.hsnCodeExists('1234567890')) {
     // Code exists, update instead
   }
   ```

3. **Handle errors gracefully**:
   ```dart
   try {
     await hsnRepository.createHSN(hsncode: code, taxrate: rate);
   } catch (e) {
     showErrorDialog(context, 'Failed to save HSN code');
   }
   ```

4. **Close database connection when app closes**:
   ```dart
   @override
   void dispose() {
     hsnRepository.closeConnection();
     super.dispose();
   }
   ```

5. **Use search for large datasets**:
   ```dart
   // Instead of loading all and filtering locally
   final results = await hsnRepository.searchHSN('123');
   ```

## Troubleshooting

### Database not updating
- Ensure you're awaiting all async operations
- Check that the HSN code is unique before inserting

### Performance issues with large datasets
- Use `searchHSN()` instead of fetching all records
- Add pagination if database gets large

### Migration/Upgrade
If you need to add new columns to the schema:
1. Update the `_createDatabase` method version number
2. Add migration logic in a new `onCreate` or `onUpgrade` handler

## Support

For more usage examples, see `lib/db/HSN_API_USAGE_GUIDE.dart`
