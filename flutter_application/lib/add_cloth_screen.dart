import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class AddClothingScreen extends StatefulWidget {
  final String userId;

  AddClothingScreen({required this.userId});
  @override
  // ignore: library_private_types_in_public_api
  _AddClothingScreenState createState() => _AddClothingScreenState();
}

class _AddClothingScreenState extends State<AddClothingScreen> {
  final _formKey = GlobalKey<FormState>();
  XFile? _imageFile;
  String? _base64Image;
  final picker = ImagePicker();
  String _predictedCategory = 'Autre';
  bool _isLoading = false;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
        _isLoading = true;
      });
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _base64Image = 'data:image/jpeg;base64,' + base64Encode(bytes);
        print("String base64: $_base64Image");
      });
      await _predictImageCategory(_imageFile!);
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_imageFile != null) {
        print('Base64 Image: $_base64Image');

        // Replace 'YOUR_USER_ID' with the actual logged-in user's ID
        final userId = widget.userId; // Get the user's ID dynamically

        // Create a new item in the user's clothingItems collection
        try {
          await FirebaseFirestore.instance
              .collection('Users')
              .doc(userId)
              .collection('clothingItems')
              .add({
            'titre': _titleController.text,
            'taille': _sizeController.text,
            'marque': _brandController.text,
            'prix': double.parse(_priceController.text),
            'Catégorie': _categoryController.text,
            'imageUrl': _base64Image,
            'createdAt': FieldValue.serverTimestamp(),
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vêtement ajouté à votre liste !'),
              backgroundColor: Colors.green,
            ),
          );

          // Clear the form
          _titleController.clear();
          _sizeController.clear();
          _brandController.clear();
          _priceController.clear();
          _categoryController.clear();
          setState(() {
            _imageFile = null;
          });
        } catch (e) {
          print('Erreur lors de l\'ajout à Firestore: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erreur lors de l\'ajout à la liste.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez choisir une image'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }



  @override
  void initState() {
    super.initState();
    loadModel();
  }

  Future<void> loadModel() async {
    try {
      String? result = await Tflite.loadModel(
        model: 'assets/model_unquant.tflite',
        labels: 'assets/labels.txt',
        numThreads: 1,
      );
      print('Modèle chargé: $result');
    } catch (e) {
      print('Erreur lors du chargement du modèle: $e');
    }
  }

  Future<void> _predictImageCategory(XFile image) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final bytes = await image.readAsBytes();
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://127.0.0.1:8000/predict/'),
      );
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: image.name, // Use the actual name of the selected file
        ),
      );

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final result = jsonDecode(responseBody);
        setState(() {
          _predictedCategory = result['label'];
          _categoryController.text = _predictedCategory;
        });
      } else {
        print('Server error: ${response.statusCode}');
        setState(() {
          _predictedCategory = 'Erreur lors de la prédiction';
        });
      }
    } catch (e) {
      print('Error making prediction request: $e');
      setState(() {
        _predictedCategory = 'Erreur lors de la prédiction';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un vêtement'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 26, 228, 201),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Image picker
              _imageFile == null
                  ? TextButton(
                      onPressed: _pickImage,
                      child: const Text('Choisir une image',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                    )
                  : Image.network(_imageFile!.path),
              const SizedBox(height: 10),

              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Titre'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un titre';
                  }
                  return null;
                },
              ),

              TextFormField(
                controller: _sizeController,
                decoration: const InputDecoration(labelText: 'Taille'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer la taille';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _brandController,
                decoration: const InputDecoration(labelText: 'Marque'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer la marque';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Prix'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le prix';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Veuillez entrer un nombre valide';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              Align(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Save form data and image to Firestore
                      // ignore: avoid_print
                      print('Base64 Image: $_base64Image');
                      _submitForm();
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
                  child: Text('Valider'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
