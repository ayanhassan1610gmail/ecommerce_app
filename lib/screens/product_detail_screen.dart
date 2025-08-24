import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';

class ProductDetailScreen extends StatelessWidget {
  final int productId;
  final String initialImageUrl;

  const ProductDetailScreen(this.productId, this.initialImageUrl, {super.key});

  static final flutterCacheManager = CacheManager(
    Config(
      'cacheKey',
      stalePeriod: const Duration(days: 10),
      maxNrOfCacheObjects: 20,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final productProvider = Provider.of<ProductProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Product Details')),
      body: Column(
        children: [
          Hero(
            // tag: initialImageUrl,
            tag: 'image_$productId',
            child: CachedNetworkImage(
              key: UniqueKey(),
              cacheManager: ProductDetailScreen.flutterCacheManager,
              imageUrl: initialImageUrl,
              height: 300,
              fit: BoxFit.cover,
              placeholder: (context, url) =>
                  const Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),
          Expanded(
            child: productProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : FutureBuilder<Product>(
                    future: productProvider.fetchProductById(productId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return const Center(
                          child: Text('Failed to load product details'),
                        );
                      }
                      if (!snapshot.hasData) {
                        return const Center(child: Text('Product not found'));
                      }
                      final product = snapshot.data!;
                      return ListView(
                        children: [
                          Hero(
                            tag: 'title_${product.id}',
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                product.title,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              product.description,
                              style: const TextStyle(fontSize: 10),
                            ),
                          ),
                          Hero(
                            tag: 'price_${product.id}',
                            child: Center(child: Text('\$${product.price}')),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              cart.addItem(product);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Row(
                                    children: [
                                      Icon(
                                        Icons.shopping_cart,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 8),
                                      Text('Added to cart!'),
                                    ],
                                  ),
                                  duration: Duration(seconds: 2),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                            child: const Text('Add to Cart'),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
