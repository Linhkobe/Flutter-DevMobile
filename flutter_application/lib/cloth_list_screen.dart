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
/*       case 2:
        return 'Mon Profil'; */
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _selectedIndex != 2
          ? AppBar(
              //title: Text(x()),
              title: Text(x()),
              centerTitle: true,
              backgroundColor: Color.fromARGB(255, 26, 228, 201))
          : null,
      body: _pages[_selectedIndex],

      // Bottom Navigation bar
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
  final CollectionReference clothingItemsCollection =
      FirebaseFirestore.instance.collection('clothingItems');

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: clothingItemsCollection.snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final clothingItems = snapshot.data?.docs ?? [];

        if (clothingItems.isEmpty) {
          return const Center(child: Text('Aucun vêtement trouvé'));
        }

        return ListView.builder(
          itemCount: clothingItems.length,
          itemBuilder: (context, index) {
            // Use safe access to handle potential null or malformed data
            final item = clothingItems[index].data() as Map<String, dynamic>?;

            if (item == null) {
              return const ListTile(
                title: Text('Invalid data'),
              );
            }

            final base64Image = item['imageUrl'] as String?;
            final titre = item['titre'] as String? ?? 'Inconnu';
            final taille = item['taille'] as String? ?? 'Inconnu';
            final prix = item['prix'] as num? ?? 0;
            final marque = item['marque'] as String? ?? 'Inconnu';

            // Decode the image only if it is valid base64, with a safe check
            final imageWidget = base64Image != null && base64Image.startsWith("data:image")
                ? Image.memory(
                    base64Decode(base64Image.split(',')[1]),
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  )
                : const Icon(Icons.image_not_supported, size: 50, color: Colors.grey);

            return Card(
              margin: const EdgeInsets.all(8.0),
              child: ListTile(
                leading: imageWidget,
                title: Text(titre),
                subtitle: Text('Taille: $taille , Prix: $prix, Marque: $marque'),
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
  }
}



