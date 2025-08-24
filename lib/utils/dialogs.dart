import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';

class Dialogs {

  void showRemoveConfirmationDialog(
      BuildContext context, dynamic cartItem, {required VoidCallback onConfirmed}) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Item'),
        content: const Text('Are you sure you want to remove this item from the cart?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              onConfirmed();
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void showOrderConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Order'),
        content: const Text('Do you want to place this order?'),
        actions: [
          TextButton(
            onPressed: Navigator.of(ctx).pop,
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<CartProvider>(context, listen: false).clearCart();
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Order placed successfully!')),
              );
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }
}
