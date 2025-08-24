import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  bool _isOffline = false;
  bool isLoading = false;
  Product? _currentProduct;

  List<Product> get products => _products;

  bool get isOffline => _isOffline;

  Product? get currentProduct => _currentProduct;

  Future<void> fetchProducts() async {
    try {
      _isOffline = false;
      _products = await ApiService.getProducts();
      await _cacheProducts(_products);
    } catch (error) {
      _isOffline = true;
      _products = await _getCachedProductsList();
    }
    notifyListeners();
  }

  Future<void> _cacheProducts(List<Product> products) async {
    final prefs = await SharedPreferences.getInstance();
    final productListJson = jsonEncode(
      products.map((p) => p.toJson()).toList(),
    );
    prefs.setString('cached_products', productListJson);
  }

  Future<List<Product>> _getCachedProductsList() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedProducts = prefs.getString('cached_products');
    if (cachedProducts != null) {
      List<dynamic> productListJson = jsonDecode(cachedProducts);
      return productListJson.map((json) => Product.fromJson(json)).toList();
    }
    return [];
  }

  Future<Product> fetchProductById(int id) async {
    try {
      final product = findById(id);
      _currentProduct = product;
      return product;
    } catch (e) {
      debugPrint('Error fetching product: $e');
      rethrow;
    }
  }

  Product findById(int id) {
    return _products.firstWhere((product) => product.id == id);
  }
}
