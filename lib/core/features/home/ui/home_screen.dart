import 'package:flutter/material.dart';
import 'package:inventory_management/core/features/hsn_form/ui/hsn_form_screen.dart';
import 'package:inventory_management/core/features/product_form/ui/product_form_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Inventory Management'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo/Icon Header
              CircleAvatar(
                radius: 45,
                backgroundColor: Colors.blue.shade50,
                child: Icon(Icons.inventory_2, size: 50, color: Colors.blue[600]),
              ),
              const SizedBox(height: 16),
              Text(
                'Welcome Back',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey[900],
                    ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Select a module to continue',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 40),

              // Button 1: HSN Code
              _buildMenuButton(
                context,
                label: 'HSN Code',
                icon: Icons.receipt_long,
                color: Colors.indigo,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HSNFormScreen(title: 'HSN Code')),
                ),
              ),

              const SizedBox(height: 16), // Proper spacing between buttons

              // Button 2: Product
              _buildMenuButton(
                context,
                label: 'Product',
                icon: Icons.inventory_2,
                color: Colors.blue,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProductFormScreen(title: 'Product')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method for the "Small" wide buttons
  Widget _buildMenuButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity, // Makes button take full available width
      height: 60, // Consistent height for all buttons
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 24),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: color,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}