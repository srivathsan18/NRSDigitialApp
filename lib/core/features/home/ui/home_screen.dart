import 'package:flutter/material.dart';
import 'package:inventory_management/core/features/hsn_form/ui/hsn_form_screen.dart';
import 'package:inventory_management/core/features/product_form/ui/product_form_screen.dart';



class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(
              Icons.inventory_2,
              size: 80,
              color: Colors.blue[300],
            ),
            const SizedBox(height: 24),
            Text(
              'Inventory Management',
              style: Theme.of(context).textTheme.headlineSmall,
            ),

            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HSNFormScreen(
                      title: 'HSN Code',
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('HSN Code'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductFormScreen(
                      title: 'Product',
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Product'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
