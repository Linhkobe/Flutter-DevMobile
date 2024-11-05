import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ClothingDetailScreen extends StatelessWidget {
  final Map<String, dynamic> clothingItem;

  final String userId;

  ClothingDetailScreen({required this.clothingItem, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(clothingItem['titre'] ?? 'Détail de vêtement choisi'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 26, 228, 201),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: (clothingItem['imageUrl'] != null &&
                      clothingItem['imageUrl']
                          .toString()
                          .contains('data:image'))
                  ? Image.memory(
                      base64Decode(clothingItem['imageUrl'].split(',')[1]),
                      height: 250,
                      fit: BoxFit.cover,
                    )
                  : const Icon(Icons.image_not_supported,
                      size: 150, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    clothingItem['titre'] ?? 'Unknown',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  Text('Taille: ${clothingItem['taille'] ?? 'Unknown'}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 15)),
                  Text('Prix: ${clothingItem['prix'] ?? 'N/A'}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 15)),
                  Text('Marque: ${clothingItem['marque'] ?? 'N/A'}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 15)),
                  Text('Catégorie: ${clothingItem['Catégorie'] ?? 'N/A'}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 15)),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await FirebaseFirestore.instance
                          .collection('Users')
                          .doc(userId)
                          .collection('Panier')
                          .add({
                        'imageUrl': clothingItem['imageUrl'],
                        'titre': clothingItem['titre'],
                        'taille': clothingItem['taille'],
                        'prix': clothingItem['prix'],
                        'marque': clothingItem['marque'],
                        'Catégorie': clothingItem['Catégorie'],
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              '${clothingItem['titre']} a été ajouté au panier!'),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text('Erreur lors de l\'ajout au panier: $e'),
                        ),
                      );
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                        (Set<WidgetState> states) {
                      if (states.contains(WidgetState.hovered)) {
                        return const Color.fromARGB(255, 26, 228, 201);
                      }
                      return const Color.fromARGB(255, 240, 236, 236);
                    }),
                  ),
                  child: const Text('Ajouter au panier'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                        (Set<WidgetState> states) {
                      if (states.contains(WidgetState.hovered)) {
                        return const Color.fromARGB(255, 26, 228, 201);
                      }
                      return const Color.fromARGB(255, 240, 236, 236);
                    }),
                  ),
                  child: const Text('Retour'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
