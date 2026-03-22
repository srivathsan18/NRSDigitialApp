import 'package:flutter/material.dart';
import 'package:inventory_management/service/service.dart';
import '../model/hsn_model.dart';

class HSNFormScreen extends StatefulWidget {
  final String title;

  const HSNFormScreen({super.key, this.title = 'HSN Form'});

  @override
  State<HSNFormScreen> createState() => _HSNFormScreenState();
}

class _HSNFormScreenState extends State<HSNFormScreen> {
  HSN? _currentHSN;
  bool _isFormVisible = false;
  late TextEditingController _hsnCodeController;
  late TextEditingController _taxRateController;
  final _formKey = GlobalKey<FormState>();
  final _hsnService = HSNService();
  List<HSN> _hsnList = [];
  final bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _hsnCodeController = TextEditingController(
      text: _currentHSN?.hsncode ?? '',
    );
    _taxRateController = TextEditingController(
      text: _currentHSN?.taxrate.toString() ?? '',
    );
    _loadHSNList();
  }

  Future<void> _loadHSNList() async {
    try {
      final hsnList = await _hsnService.loadAllHSN();
      if (mounted) {
        setState(() {
          _hsnList = hsnList;
        });
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  void dispose() {
    _hsnCodeController.dispose();
    _taxRateController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      try {
        final hsn = HSN(
          id: _currentHSN?.id,
          hsncode: _hsnCodeController.text.trim(),
          taxrate: int.parse(_taxRateController.text.trim()),
        );

        await _hsnService.saveHSN(hsn);

        _handleReset();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _currentHSN?.id == null
                    ? 'HSN created successfully!'
                    : 'HSN updated successfully!',
              ),
              backgroundColor: Colors.green,
            ),
          );

          // Pop back to home screen
          //Navigator.pop(context);
        }
        _currentHSN = null;
        _closeForm();
        _loadHSNList();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
        _currentHSN = null;
        _closeForm();
        _loadHSNList();
      }
    }
  }

  Future<void> _editHSN(HSN hsn) async {
    setState(() {
      _currentHSN = hsn;
      _isFormVisible = true;
      _hsnCodeController.text = hsn.hsncode;
      _taxRateController.text = hsn.taxrate.toString();
    });
  }

  Future<void> _deleteHSN(HSN hsn) async {
    if (hsn.id == null) return;
    try {
      await _hsnService.deleteHSN(hsn);
      await _loadHSNList(); // Refresh the list after delete
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('HSN deleted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleReset() {
    _formKey.currentState?.reset();
    _hsnCodeController.clear();
    _taxRateController.clear();
  }

  void _showAddForm() {
    setState(() {
      _currentHSN = null;
      _isFormVisible = true;
      _hsnCodeController.clear();
      _taxRateController.clear();
    });
  }

  void _closeForm() {
    setState(() {
      _isFormVisible = false;
      _currentHSN = null;
      _hsnCodeController.clear();
      _taxRateController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        elevation: 0,
        leading: (_isFormVisible || _currentHSN != null)
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  // 2. Define what happens when back is pressed
                  setState(() {
                    _isFormVisible = false;
                    _currentHSN = null;
                  });
                },
              )
            : null,
        actions: [
          if (!_isFormVisible && _currentHSN == null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: TextButton.icon(
                onPressed: _showAddForm,
                icon: const Icon(Icons.add, size: 28), // Larger icon
                label: const Text(
                  "ADD",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: TextButton.styleFrom(foregroundColor: Colors.black),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          Row(
            children: [
              Expanded(
                child: _isFormVisible || _currentHSN != null
                    ? _buildFormPanel() // Show ONLY the form
                    : _buildHSNListView(), // Show ONLY the list
              ),
            ],
          ),
          // Full screen overlay when loading
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    const SizedBox(height: 16.0),
                    const Text(
                      'Processing...',
                      style: TextStyle(color: Colors.white, fontSize: 16.0),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFormPanel() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _currentHSN == null ? 'Add HSN' : 'Edit HSN',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _closeForm,
                ),
              ],
            ),
            const SizedBox(height: 24.0),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildHSNCodeField(),
                    const SizedBox(height: 16.0),
                    _buildTaxRateField(),
                    const SizedBox(height: 32.0),
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHSNListView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('HSN Codes', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12.0),
          _hsnList.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No HSN codes added yet'),
                  ),
                )
              : Expanded(
                  child: ListView.builder(
                    itemCount: _hsnList.length,
                    itemBuilder: (context, index) {
                      final hsn = _hsnList[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          leading: const Icon(Icons.code),
                          title: Text('HSN: ${hsn.hsncode}'),
                          subtitle: Text('Tax: ${hsn.taxrate}%'),
                          trailing: PopupMenuButton(
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                child: const Text('Edit'),
                                onTap: () => _editHSN(hsn),
                              ),
                              PopupMenuItem(
                                child: const Text('Delete'),
                                onTap: () => _deleteHSN(hsn),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildHSNCodeField() {
    return TextFormField(
      controller: _hsnCodeController,
      decoration: InputDecoration(
        labelText: 'HSN Code',
        hintText: 'Enter HSN code (e.g., 1234)',
        prefixIcon: const Icon(Icons.code),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'HSN Code is required';
        }
        if (value.length < 4) {
          return 'HSN Code must be at least 4 characters';
        }
        if (value.length > 8) {
          return 'HSN Code must not exceed 8 characters';
        }
        return null;
      },
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _buildTaxRateField() {
    return TextFormField(
      controller: _taxRateController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: 'Tax Rate (%)',
        hintText: 'Enter tax rate (e.g., 18)',
        prefixIcon: const Icon(Icons.percent),
        suffixText: '%',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Tax Rate is required';
        }
        try {
          final rate = int.parse(value);
          if (rate < 0) {
            return 'Tax Rate cannot be negative';
          }
          if (rate > 100) {
            return 'Tax Rate cannot exceed 100%';
          }
        } catch (e) {
          return 'Tax Rate must be a valid number';
        }
        return null;
      },
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: _handleSubmit,
          icon: const Icon(Icons.save),
          label: const Text('Save'),
        ),
        ElevatedButton.icon(
          onPressed: _closeForm,
          icon: const Icon(Icons.close),
          label: const Text('Cancel'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
        ),
      ],
    );
  }
}
