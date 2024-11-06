import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'cloth_detail_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';

class ClothingListScreen extends StatefulWidget {
  final String login;

  final String userId;

  ClothingListScreen({required this.login, required this.userId});

  @override
  _ClothingListScreenState createState() => _ClothingListScreenState();
}

class _ClothingListScreenState extends State<ClothingListScreen> {
  int _selectedIndex = 0;

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      ClothingListView(
        userId: widget.userId,
      ),
      CartScreen(
        userId: widget.userId,
      ),
      ProfileScreen(
        userId: widget.userId,
      ),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  String x() {
    switch (_selectedIndex) {
      case 0:
        return 'Liste des vêtements';
      case 1:
        return 'Panier';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _selectedIndex != 2
          ? AppBar(
              title: Text(x()),
              centerTitle: true,
              backgroundColor: Color.fromARGB(255, 26, 228, 201))
          : null,
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.euro),
            label: 'Acheter',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_basket),
            label: 'Panier',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}

class ClothingListView extends StatelessWidget {
  final String userId;

  ClothingListView({Key? key, required this.userId}) : super(key: key);

  // Shared collection to display all items for the "Acheter" page
/*   final CollectionReference clothingItemsCollection =
      FirebaseFirestore.instance.collection('clothingItems'); */
  final CollectionReference sharedCollection =
      FirebaseFirestore.instance.collection('clothingItems');

  @override
  Widget build(BuildContext context) {
    final CollectionReference userCollection = FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .collection('clothingItems');
    return StreamBuilder<QuerySnapshot>(
      stream: sharedCollection.snapshots(),
      builder: (context, sharedSnapshot) {
        return StreamBuilder<QuerySnapshot>(
          stream: userCollection.snapshots(),
          builder: (context, userSnapshot) {
            if (sharedSnapshot.hasError || userSnapshot.hasError) {
              return Center(child: Text('Error loading items'));
            }

            if (sharedSnapshot.connectionState == ConnectionState.waiting ||
                userSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final sharedItems = sharedSnapshot.data?.docs ?? [];
            final userItems = userSnapshot.data?.docs ?? [];
            final allItems = [...sharedItems, ...userItems];

            if (allItems.isEmpty) {
              return const Center(child: Text('Aucun vêtement trouvé'));
            }

            return ListView.builder(
              itemCount: allItems.length,
              itemBuilder: (context, index) {
                final item = allItems[index].data() as Map<String, dynamic>?;
                if (item == null) {
                  return const ListTile(title: Text('Invalid data'));
                }

                final base64Image = item['imageUrl'] as String?;
                final titre = item['titre'] as String? ?? 'Inconnu';
                final taille = item['taille'] as String? ?? 'Inconnu';
                final prix = item['prix'] as num? ?? 0;
                final marque = item['marque'] as String? ?? 'Inconnu';

                final imageWidget =
                    base64Image != null && base64Image.startsWith("data:image")
                        ? Image.memory(
                            base64Decode(base64Image.split(',')[1]),
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          )
                        : const Icon(Icons.image_not_supported,
                            size: 50, color: Colors.grey);

                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: imageWidget,
                    title: Text(titre),
                    subtitle:
                        Text('Taille: $taille, Prix: $prix, Marque: $marque'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ClothingDetailScreen(
                            clothingItem: item,
                            userId: userId,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
