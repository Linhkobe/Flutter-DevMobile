import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CartScreen extends StatefulWidget {
  final String userId;

  CartScreen({required this.userId});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CollectionReference _cartCollection =
      FirebaseFirestore.instance.collection('Users');

  double _totalPrice = 0.0;
  //StreamSubscription<QuerySnapshot>? _cartSubscription;

  @override
  void initState() {
    super.initState();
    _calculateTotalPrice();
  }

  void _calculateTotalPrice() {
    _cartCollection
        //_cartSubscription = _cartCollection
        .doc(widget.userId)
        .collection('Panier')
        .snapshots()
        .listen((snapshot) {
      double total = 0;
      for (var doc in snapshot.docs) {
        final item = doc.data() as Map<String, dynamic>;
        total += item['prix'] ?? 0;
      }
      setState(() {
        _totalPrice = total;
      });
    });
  }

  void _removeItem(String docId) {
    _cartCollection
        .doc(widget.userId)
        .collection('Panier')
        .doc(docId)
        .delete()
        .then((_) {
      print('Item removed');
      _calculateTotalPrice();
    }).catchError((error) {
      print('Failed to remove item: $error');
    });
  }

/*   @override
  void dispose() {
    _cartSubscription?.cancel();
    super.dispose();
  } */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _cartCollection
                  .doc(widget.userId)
                  .collection('Panier')
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final cartItems = snapshot.data?.docs ?? [];

                return ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final doc = cartItems[index];
                    final item = doc.data() as Map<String, dynamic>;
                    final imageUrl = item['imageUrl'] as String?;
                    final titre = item['titre'] as String? ?? 'Inconnu';
                    final taille = item['taille'] as String? ?? 'Inconnu';
                    final prix = item['prix'] as num? ?? 0;

                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        leading: imageUrl != null
                            ? Image.network(imageUrl, width: 50, height: 50)
                            : const Icon(Icons.image_not_supported,
                                size: 50, color: Colors.grey),
                        title: Text(titre),
                        subtitle: Text('Taille: $taille , Prix: $prix €'),
                        trailing: IconButton(
                          icon: const Icon(Icons.clear, color: Colors.red),
                          onPressed: () {
                            _removeItem(doc.id);
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Total: $_totalPrice €',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}



/* import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartScreen extends StatefulWidget {
  final String userId;

  CartScreen({required this.userId});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late CollectionReference _cartCollection;
  double _totalPrice = 0.0;

  @override
  void initState() {
    super.initState();
    _cartCollection =
        FirebaseFirestore.instance.collection('Users/${widget.userId}/Cart');
    _calculateTotal();
  }

  void _calculateTotal() {
    _cartCollection.get().then((querySnapshot) {
      double total = 0.0;
      querySnapshot.docs.forEach((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final price = data['prix'] as num? ?? 0;
        total += price;
      });
      setState(() {
        _totalPrice = total;
      });
    });
  }

  void _removeItem(String itemId) {
    _cartCollection.doc(itemId).delete().then((_) {
      _calculateTotal();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Article supprimé du panier'),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Panier'),
        centerTitle: true,
      ),
      body: StreamBuilder <QuerySnapshot>(
            stream: _cartCollection.snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Erreur: ${snapshot.error}'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final cartItems = snapshot.data?.docs ?? [];

              if (cartItems.isEmpty) {
                return const Center(
                  child: Text('Votre panier est vide'),
                );
              }

              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        final item =
                            cartItems[index].data() as Map<String, dynamic>?;
                        final itemId = cartItems[index].id;

                        if (item == null) {
                          return const ListTile(
                            title: Text('Erreur: article non trouvé'),
                          );
                        }

                        final imageUrl = item['imageUrl'] as String?;
                        final titre = item['titre'] as String?;
                        final prix = item['prix'] as num?;
                        final taille = item['taille'] as String?;

                        return Card(
                          margin: const EdgeInsets.all(8.0),
                          child: ListTile(
                            leading: imageUrl != null
                                ? Image.network(imageUrl, width: 50, height: 50)
                                : const Icon(Icons.image_not_supported,
                                    size: 50, color: Colors.grey),
                            title: Text(titre ?? 'Inconnu'),
                            subtitle: Text('Taille: $taille, Prix: $prix'),
                            trailing: IconButton(
                              icon: const Icon(Icons.remove_circle,
                                  color: Colors.red),
                              onPressed: () {
                                _removeItem(itemId);
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Total: $_totalPrice €',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
    );
  }
}
 */