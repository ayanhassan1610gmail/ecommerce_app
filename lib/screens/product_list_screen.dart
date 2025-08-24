import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../widgets/product_item.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  ProductListScreenState createState() => ProductListScreenState();
}

class ProductListScreenState extends State<ProductListScreen>
    with AutomaticKeepAliveClientMixin<ProductListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isFirstLoad = true;
  late Future<void> _initialFetch;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initialFetch =
        Provider.of<ProductProvider>(context, listen: false).fetchProducts();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<ProductProvider>(context, listen: false).fetchProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final productProvider = Provider.of<ProductProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text('Products List Screen'),
        ),
        actions: [
          Icon(
            productProvider.isOffline ? Icons.wifi_off : Icons.wifi,
            color: productProvider.isOffline ? Colors.red : Colors.green,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name or category',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          Expanded(
            child: _isFirstLoad
                ? FutureBuilder(
                    future: _initialFetch,
                    builder: (ctx, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (snapshot.hasError) {
                        return const Center(
                          child: Text('An error occurred!'),
                        );
                      } else {
                        _isFirstLoad = false;
                        return _buildProductList(productProvider);
                      }
                    },
                  )
                : _buildProductList(productProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList(ProductProvider productProvider) {
    final filteredProducts = productProvider.products.where((product) {
      final nameMatch = product.title.toLowerCase().contains(_searchQuery);
      final categoryMatch =
      product.category.toLowerCase().contains(_searchQuery);
      return nameMatch || categoryMatch;
    }).toList();

    if (filteredProducts.isEmpty) {
      return const Center(
        child: Text('No products found. Please try a different search.'),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _refreshProducts(context),
      child: ListView.builder(
        itemCount: filteredProducts.length,
        itemBuilder: (ctx, i) => ProductItem(filteredProducts[i]),
      ),
    );
  }
}
