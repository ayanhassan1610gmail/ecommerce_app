import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/connectivity_notifier.dart';
import '../utils/connectivity_service.dart';
import '../providers/cart_provider.dart';
import '../utils/dialogs.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final isOffline = Provider.of<ConnectivityService>(context).isOffline;
    double height = MediaQuery.sizeOf(context).height;

    return ConnectivityNotifier(
      child: Scaffold(
        appBar: AppBar(title: const Text('Checkout')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Order Summary',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: cart.items.length,
                  itemBuilder: (ctx, i) {
                    final cartItem = cart.items.values.toList()[i];
                    return ListTile(
                      // leading: Image.network(cartItem.product.image, width: 50),
                      leading: CachedNetworkImage(
                        imageUrl: cartItem.product.image,
                        width: 50,
                        placeholder: (context, url) =>
                            CircularProgressIndicator(),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
                      title: Text(cartItem.product.title),
                      subtitle: Text('\$${cartItem.product.price.toString()}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          DropdownButton<int>(
                            value: cartItem.quantity,
                            items: List.generate(10, (index) => index + 1)
                                .map(
                                  (quantity) => DropdownMenuItem(
                                    value: quantity,
                                    child: Text(quantity.toString()),
                                  ),
                                )
                                .toList(),
                            onChanged: (newQuantity) {
                              if (newQuantity != null) {
                                cart.updateItemQuantity(
                                  cartItem.product.id,
                                  newQuantity,
                                );
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              Dialogs().showRemoveConfirmationDialog(
                                context,
                                cartItem,
                                onConfirmed: () =>
                                    cart.removeItem(cartItem.product.id),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const Divider(),
              Text(
                'Total: \$${cart.totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: height * 0.02),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (cart.items.isEmpty) {
                      ScaffoldMessenger.of(context)
                        ..removeCurrentSnackBar()
                        ..showSnackBar(
                          const SnackBar(content: Text('Your cart is empty!')),
                        );
                      return;
                    }

                    if (isOffline) {
                      ScaffoldMessenger.of(context)
                        ..removeCurrentSnackBar()
                        ..showSnackBar(
                          const SnackBar(content: Text('You are offline!')),
                        );
                      return;
                    }
                    Dialogs().showOrderConfirmationDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text(
                    'Confirm Order',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
              SizedBox(height: height * 0.02),
            ],
          ),
        ),
      ),
    );
  }
}
