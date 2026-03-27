import 'package:flutter/material.dart';
import 'package:inventory_management/core/features/product_form/data/product_service.dart';
import '../model/product_model.dart';
import '../../hsn_form/model/hsn_model.dart';
//import '../../../repositories/product_repository.dart';
import '../../hsn_form/data/hsn_service.dart';

class ProductFormScreen extends StatefulWidget {
  final String title;
  const ProductFormScreen({super.key, this.title = 'Product Form'});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _hsnService = HSNService();
  final _productService = ProductService();

  // State
  final List<Product> _products = [];
  List<HSN> _hsnOptions = [];
  bool _isFormVisible = false;
  bool _isLoading = false;
  Product? _editingProduct;

  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _skuController;
  late TextEditingController _qtyController;
  int? _selectedHsnId;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _skuController = TextEditingController();
    _qtyController = TextEditingController();
    _refreshData();
  }

  Future<void> _refreshData() async {
    setState(() => _isLoading = true);
    try {
      final prods = await _productService.get();
      final hsns = await _hsnService.get(); // Need HSNs for the dropdown
      setState(() {
        _products.addAll(prods);
        _hsnOptions = hsns;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _toggleForm({Product? product}) {
    setState(() {
      _editingProduct = product;
      _isFormVisible = product != null || !_isFormVisible;
      _nameController.text = product?.name ?? '';
      _skuController.text = product?.sku ?? '';
      _qtyController.text = product?.qty.toString() ?? '';
      _selectedHsnId = product?.hsnId;
    });
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate() || _selectedHsnId == null) {
      if (_selectedHsnId == null) _showError("Please select an HSN code");
      return;
    }

    try {
      final p = Product(
        id: _editingProduct?.id,
        hsnId: _selectedHsnId!,
        sku: _skuController.text,
        name: _nameController.text,
        qty: int.parse(_qtyController.text),
      );
       await _productService.save(p);
      _toggleForm();
      _refreshData();
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> _handleDelete(Product p) async {
  try {
    // Assuming your ProductService has a delete method
    await _productService.delete(p); 
    _showError("Product deleted"); // Reusing your snackbar method
    _refreshData();
  } catch (e) {
    _showError("Delete failed: $e");
  }
}

  void _showError(String msg) => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isFormVisible ? "Product Entry" : "Inventory"),
        actions: [
          if (!_isFormVisible) 
            IconButton(icon: const Icon(Icons.add), onPressed: () => _toggleForm())
        ],
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _isFormVisible ? _buildForm() : _buildList(),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // HSN Dropdown
            DropdownButtonFormField<int>(
              initialValue: _selectedHsnId,
              decoration: const InputDecoration(labelText: 'Select HSN Code', prefixIcon: Icon(Icons.pin)),
              items: _hsnOptions.map((hsn) => DropdownMenuItem(
                value: hsn.id,
                child: Text("${hsn.hsncode} (${hsn.taxrate}%)"),
              )).toList(),
              onChanged: (val) => setState(() => _selectedHsnId = val),
              validator: (val) => val == null ? 'Required' : null,
            ),
            const SizedBox(height: 15),
            _buildField(_nameController, "Product Name", Icons.inventory),
            const SizedBox(height: 15),
            _buildField(_skuController, "SKU / Model Number", Icons.qr_code),
            const SizedBox(height: 15),
            _buildField(_qtyController, "Initial Quantity", Icons.numbers, isNum: true),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _handleSave,
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              child: const Text("SAVE PRODUCT"),
            ),
            TextButton(onPressed: _toggleForm, child: const Text("Cancel"))
          ],
        ),
      ),
    );
  }

Widget _buildList() {
  if (_products.isEmpty) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text("No products found", style: TextStyle(color: Colors.grey)),
          TextButton(onPressed: _toggleForm, child: const Text("Add your first product")),
        ],
      ),
    );
  }

  return ListView.builder(
    padding: const EdgeInsets.all(12),
    itemCount: _products.length,
    itemBuilder: (context, i) {
      final p = _products[i];
      
      // Finding the HSN code text for the subtitle
      final hsnLabel = _hsnOptions.firstWhere(
        (h) => h.id == p.hsnId, 
        orElse: () => HSN(hsncode: 'N/A', taxrate: 0)
      ).hsncode;

      return Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: CircleAvatar(
            backgroundColor: Colors.blue.shade100,
            child: const Icon(Icons.shopping_bag, color: Colors.blue),
          ),
          title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("SKU: ${p.sku} | Qty: ${p.qty}"),
              Text("HSN: $hsnLabel", style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          trailing: PopupMenuButton(
            onSelected: (value) {
              if (value == 'edit') _toggleForm(product: p);
              if (value == 'delete') _handleDelete(p);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Text("Edit")),
              const PopupMenuItem(value: 'delete', child: Text("Delete", style: TextStyle(color: Colors.red))),
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
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon), border: const OutlineInputBorder()),
      validator: (v) => v!.isEmpty ? 'Field required' : null,
    );
  }
}