import 'package:flutter/material.dart';
import 'package:inventory_management/core/features/product_form/data/product_service.dart';
import '../model/product_model.dart';
import '../../hsn_form/model/hsn_model.dart';
import '../../hsn_form/data/hsn_service.dart';

class ProductFormScreen extends StatefulWidget {
  final String title;
  const ProductFormScreen({super.key, this.title = 'Product Form'});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  // State variables following Format 1
  Product? _currentProduct; 
  bool _isFormVisible = false;
  bool _isLoading = false;
  List<Product> _products = [];
  List<HSN> _hsnOptions = [];

  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _skuController;
  late TextEditingController _qtyController;
  int? _selectedHsnId;

  final _formKey = GlobalKey<FormState>();
  final _hsnService = HSNService();
  final _productService = ProductService();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _skuController = TextEditingController();
    _qtyController = TextEditingController();
    _refreshData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _qtyController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    setState(() => _isLoading = true);
    try {
      final prods = await _productService.get();
      final hsns = await _hsnService.get();
      if (mounted) {
        setState(() {
          _products = prods;
          _hsnOptions = hsns;
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // --- Navigation & Form Control ---

  void _handleAdd() {
    setState(() {
      _currentProduct = null;
      _isFormVisible = true;
      _selectedHsnId = null;
      _nameController.clear();
      _skuController.clear();
      _qtyController.clear();
    });
  }

  void _handleEdit(Product product) {
    setState(() {
      _currentProduct = product;
      _isFormVisible = true;
      _selectedHsnId = product.hsnId;
      _nameController.text = product.name;
      _skuController.text = product.sku;
      _qtyController.text = product.qty.toString();
    });
  }

  void _handleClose() {
    setState(() {
      _isFormVisible = false;
      _currentProduct = null;
      _selectedHsnId = null;
      _nameController.clear();
      _skuController.clear();
      _qtyController.clear();
    });
  }

  // --- ACTION METHODS ---

  Future<void> _handleSave() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedHsnId == null) {
        _showSnackBar("Please select an HSN code", isError: true);
        return;
      }

      try {
        final p = Product(
          id: _currentProduct?.id,
          hsnId: _selectedHsnId!,
          sku: _skuController.text.trim(),
          name: _nameController.text.trim(),
          qty: int.parse(_qtyController.text.trim()),
        );

        await _productService.save(p);
        
        if (mounted) {
          _showSnackBar(_currentProduct == null ? 'Product created!' : 'Product updated!');
        }

        _handleClose();
        _refreshData();
      } catch (e) {
        _showSnackBar(e.toString(), isError: true);
      }
    }
  }

  Future<void> _handleDelete(Product p) async {
    try {
      await _productService.delete(p);
      _showSnackBar("Product deleted successfully");
      _refreshData();
    } catch (e) {
      _showSnackBar("Delete failed: $e", isError: true);
    }
  }

  void _showSnackBar(String msg, {bool isError = false}) {
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
        title: Text(_isFormVisible ? (_currentProduct == null ? "Add Product" : "Edit Product") : widget.title),
        leading: (_isFormVisible)
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
      body: Stack(
        children: [
          _isFormVisible ? _buildFormPanel() : _buildProductListView(),
          if (_isLoading)
            const Opacity(
              opacity: 0.8,
              child: ModalBarrier(dismissible: false, color: Colors.black),
            ),
          if (_isLoading)
            const Center(child: CircularProgressIndicator(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildFormPanel() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            DropdownButtonFormField<int>(
              value: _selectedHsnId,
              decoration: const InputDecoration(
                labelText: 'Select HSN Code', 
                prefixIcon: Icon(Icons.pin),
                border: OutlineInputBorder()
              ),
              items: _hsnOptions.map((hsn) => DropdownMenuItem(
                value: hsn.id,
                child: Text("${hsn.hsncode} (${hsn.taxrate}%)"),
              )).toList(),
              onChanged: (val) => setState(() => _selectedHsnId = val),
              validator: (val) => val == null ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            _buildField(_nameController, "Product Name", Icons.inventory),
            const SizedBox(height: 16),
            _buildField(_skuController, "SKU / Model Number", Icons.qr_code),
            const SizedBox(height: 16),
            _buildField(_qtyController, "Initial Quantity", Icons.numbers, isNum: true),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _handleSave, 
                  icon: const Icon(Icons.save), 
                  label: const Text("Save")
                ),
                ElevatedButton.icon(
                  onPressed:_handleClose, 
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

  Widget _buildProductListView() {
    if (_products.isEmpty) {
      return const Center(child: Text("No products added yet"));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _products.length,
      itemBuilder: (context, i) {
        final p = _products[i];
        final hsn = _hsnOptions.firstWhere((h) => h.id == p.hsnId, orElse: () => HSN(hsncode: 'N/A', taxrate: 0));

        return Card(
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  leading: CircleAvatar(
    backgroundColor: Colors.blue.shade100,
    child: const Icon(
      Icons.inventory_2, // This looks very similar to receipt_long but is for products/boxes
      color: Colors.blue,
    ),
  ),
            title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("SKU: ${p.sku} | Qty: ${p.qty}\nHSN: ${hsn.hsncode}"),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(child: const Text('Edit'), onTap: () => _handleEdit(p)),
                PopupMenuItem(child: const Text('Delete', style: TextStyle(color: Colors.red)), onTap: () => _handleDelete(p)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildField(TextEditingController ctrl, String label, IconData icon, {bool isNum = false}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: isNum ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label, 
        prefixIcon: Icon(icon), 
        border: const OutlineInputBorder()
      ),
      validator: (v) => v == null || v.isEmpty ? 'Field required' : null,
    );
  }
}