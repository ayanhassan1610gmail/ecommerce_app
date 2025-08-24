import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/auth_provider.dart';
import '../models/product.dart';

class CartProvider with ChangeNotifier {
  Map<int, CartItem> _items = {};
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthProviders authProvider;
  String? _currentUserId;

  CartProvider(this.authProvider);

  Map<int, CartItem> get items => _items;

  double get totalAmount {
    return _items.values.fold(
      0,
      (sum, item) => sum + (item.product.price * item.quantity),
    );
  }

  Future<void> initializeCart() async {
    final userId = authProvider.getCurrentUserId();
    if (_currentUserId != userId) {
      _currentUserId = userId;
      await _loadUserCart();
    }
  }

  Future<void> addItem(Product product, {int quantity = 1}) async {
    await initializeCart();
    if (_items.containsKey(product.id)) {
      _items[product.id]!.quantity += quantity;
    } else {
      _items[product.id] = CartItem(product: product, quantity: quantity);
    }
    await _saveCart();
    notifyListeners();
  }

  Future<void> updateItemQuantity(int id, int quantity) async {
    if (_items.containsKey(id) && quantity > 0) {
      _items[id]!.quantity = quantity;
    } else {
      _items.remove(id);
    }
    await _saveCart();
    notifyListeners();
  }

  Future<void> removeItem(int id) async {
    _items.remove(id);
    await _saveCart();
    notifyListeners();
  }

  Future<void> clearCart() async {
    _items = {};
    await _saveCart();
    notifyListeners();
  }

  Future<void> _saveCart() async {
    final userId = authProvider.getCurrentUserId();
    if (userId != null) {
      await _saveCartToFirestore();
    }
    await _cacheCart();
  }

  Future<void> _saveCartToFirestore() async {
    final userId = authProvider.getCurrentUserId();
    if (userId == null) return;

    final cartItems = _items.values
        .map(
          (cartItem) =>
              cartItem.product.toJson()..['quantity'] = cartItem.quantity,
        )
        .toList();

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .doc('currentCart')
        .set({'items': cartItems});
  }

  Future<void> _cacheCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartItemsJson = jsonEncode(
      _items.values.map((item) => item.toJson()).toList(),
    );
    await prefs.setString('cached_cart', cartItemsJson);
  }

  Future<void> _getCachedCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedCart = prefs.getString('cached_cart');
    if (cachedCart != null) {
      final List<dynamic> cartItemsData = jsonDecode(cachedCart);
      _loadItemsFromData(cartItemsData);
    }
  }

  Future<void> _loadUserCart() async {
    final userId = authProvider.getCurrentUserId();
    if (userId == null) return;

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc('currentCart')
          .get();

      if (snapshot.exists) {
        final cartData = snapshot.data();
        if (cartData != null && cartData['items'] != null) {
          _loadItemsFromData(cartData['items']);
        }
      } else {
        await _getCachedCart();
      }
    } catch (e) {
      await _getCachedCart();
    }

    notifyListeners();
  }

  void _loadItemsFromData(List<dynamic> cartItemsData) {
    final loadedItems = cartItemsData.map((item) {
      final product = Product.fromJson(item);
      final quantity = item['quantity'] as int;
      return CartItem(product: product, quantity: quantity);
    }).toList();

    _items = {for (var item in loadedItems) item.product.id: item};
  }
}

class CartItem {
  Product product;
  int quantity;

  CartItem({required this.product, required this.quantity});

  Map<String, dynamic> toJson() {
    return {...product.toJson(), 'quantity': quantity};
  }
}
