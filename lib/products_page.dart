import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() {
    return _ProductsPageState();
  }
}

class _ProductsPageState extends State<ProductsPage> {
  @override
  void initState() {
    print(" start Products");
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    print(" finish Products");
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Products"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("welcome to Products Page"),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.pop();
              },
              child: const Text("go back"),
            ),
          ],
        ),
      ),
    );
  }
}
