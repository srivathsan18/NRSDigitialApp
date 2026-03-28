import 'package:flutter/material.dart';
import 'package:inventory_management/core/features/hsn_form/data/hsn_service.dart';
import '../model/hsn_model.dart';

class HSNFormScreen extends StatefulWidget {
  final String title;
  const HSNFormScreen({super.key, this.title = 'HSN Form'});

  @override
  State<HSNFormScreen> createState() => _HSNFormScreenState();
}

class _HSNFormScreenState extends State<HSNFormScreen> {
  // State
  HSN? _currentHSN;
  bool _isFormVisible = false;
  bool _isLoading = false;
  List<HSN> _hsnList = [];

  // Controllers
  late TextEditingController _hsnCodeController;
  late TextEditingController _taxRateController;
  
  final _formKey = GlobalKey<FormState>();
  final _hsnService = HSNService();

  @override
  void initState() {
    super.initState();
    _hsnCodeController = TextEditingController();
    _taxRateController = TextEditingController();
    _refreshData();
  }

  @override
  void dispose() {
    _hsnCodeController.dispose();
    _taxRateController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    setState(() => _isLoading = true);
    try {
      final hsnList = await _hsnService.get();
      if (mounted) {
        setState(() => _hsnList = hsnList);
      }
    } catch (e) {
      _showSnackBar(e.toString(), isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // --- Navigation & Form Control ---

  void _handleAdd() {
    setState(() {
      _currentHSN = null;
      _isFormVisible = true;
      _hsnCodeController.clear();
      _taxRateController.clear();
    });
  }

  void _handleEdit(HSN hsn) {
    setState(() {
      _currentHSN = hsn;
      _isFormVisible = true;
      _hsnCodeController.text = hsn.hsncode;
      _taxRateController.text = hsn.taxrate.toString();
    });
  }

  void _handleClose() {
    setState(() {
      _isFormVisible = false;
      _currentHSN = null;
      _hsnCodeController.clear();
      _taxRateController.clear();
    });
  }

  // --- ACTION METHODS ---

  Future<void> _handleSave() async {
    if (_formKey.currentState!.validate()) {
      try {
        final hsn = HSN(
          id: _currentHSN?.id,
          hsncode: _hsnCodeController.text.trim(),
          taxrate: int.parse(_taxRateController.text.trim()),
        );

        await _hsnService.save(hsn);
        _showSnackBar(_currentHSN == null ? 'HSN created successfully!' : 'HSN updated successfully!');
        
        _handleClose();
        _refreshData();
      } catch (e) {
        _showSnackBar(e.toString(), isError: true);
      }
    }
  }

  Future<void> _handleDelete(HSN hsn) async {
    try {
      await _hsnService.delete(hsn);
      _showSnackBar('HSN deleted successfully!');
      _refreshData();
    } catch (e) {
      _showSnackBar(e.toString(), isError: true);
    }
  }

  void _showSnackBar(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isFormVisible ? (_currentHSN == null ? "Add HSN" : "Edit HSN") : widget.title),
        leading: _isFormVisible 
            ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: _handleClose) 
            : null,
        actions: [
          if (!_isFormVisible)
           TextButton.icon(
              onPressed: _handleAdd,
              icon: const Icon(Icons.add),
              label: const Text("ADD", style: TextStyle(fontWeight: FontWeight.bold)),
              style: TextButton.styleFrom(foregroundColor: Colors.black),
            ),
            
        ],
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _isFormVisible ? _buildForm() : _buildList(),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildField(_hsnCodeController, "HSN Code", Icons.code, hint: "e.g. 1234"),
            const SizedBox(height: 16.0),
            _buildField(_taxRateController, "Tax Rate (%)", Icons.percent, isNum: true, hint: "e.g. 18"),
            const SizedBox(height: 32.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _handleSave, 
                  icon: const Icon(Icons.save), 
                  label: const Text("Save")
                ),
                ElevatedButton.icon(
                  onPressed: _handleClose, 
                  icon: const Icon(Icons.close), 
                  label: const Text("Cancel"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    if (_hsnList.isEmpty) {
      return const Center(child: Text('No HSN codes added yet'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _hsnList.length,
      itemBuilder: (context, index) {
        final hsn = _hsnList[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              child: const Icon(Icons.receipt_long, color: Colors.blue),
            ),
            title: Text('HSN: ${hsn.hsncode}', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Tax Rate: ${hsn.taxrate}%'),
            trailing: PopupMenuButton<String>(
              onSelected: (val) {
                if (val == 'edit') _handleEdit(hsn);
                if (val == 'delete') _handleDelete(hsn);
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildField(TextEditingController ctrl, String label, IconData icon, {bool isNum = false, String? hint}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: isNum ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
        suffixText: isNum ? "%" : null,
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Field required';
        if (isNum && int.tryParse(v) == null) return 'Must be a number';
        return null;
      },
    );
  }
}