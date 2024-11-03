// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'cloth_list_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vinted App'),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 25, 104, 250),
              Color.fromARGB(255, 0, 224, 213)
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 30),
                // Login field with styling
                _buildTextField(
                  controller: _loginController,
                  hintText: 'Saisir votre login',
                  icon: Icons.person,
                ),
                const SizedBox(height: 20),
                // Password field with styling (obfuscated)
                _buildTextField(
                  controller: _passwordController,
                  hintText: 'Saisir votre mot de passe',
                  icon: Icons.lock,
                  obscureText: true,
                ),
                const SizedBox(height: 30),
                // Login button with styling
                _buildLoginButton(),
                const SizedBox(height: 20),
                // Error message if any
                if (_errorMessage != null)
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Reusable method for building text fields with styling
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        contentPadding: const EdgeInsets.symmetric(vertical: 18.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: _handleLogin,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        backgroundColor: Colors.white,
      ),
      child: const Text(
        'Se connecter',
        style: TextStyle(color: Color(0xFF4A00E0), fontWeight: FontWeight.bold),
      ),
    );
  }

  // Se connecter avec la collection "Users" de Firebase
  Future<void> _handleLogin() async {
    final login = _loginController.text;
    final password = _passwordController.text;

    if (login.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Login et Password sont obligatoires';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final QuerySnapshot users = await FirebaseFirestore.instance
          .collection('Users')
          .where('login', isEqualTo: login)
          .where('password', isEqualTo: password)
          .get();

      final List<DocumentSnapshot> docs = users.docs;

      if (docs.isNotEmpty) {
        final String userId = docs.first.id;
        // Si la connexion est réussite, passer à la page de liste des vêtements
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => ClothingListScreen(
                    login: login,
                    userId: userId,
                  )),
        );
        // Si la connexion est réussite, passer à la page suivante
        print("L'authentification a réussi: $login");
      } else {
        setState(() {
          _errorMessage = 'Login ou Password incorrect';
        });
      }
    } catch (e) {
      // ignore: avoid_print
      print("L'authentification a échoué: $e");
      setState(() {
        _errorMessage = 'Erreur de connexion';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

/* import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'cloth_list_screen.dart'; // Ecran de la liste des vêtements

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Firebase instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Add gradient background
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 25, 104, 250),
              Color.fromARGB(255, 0, 224, 213)
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // App title with styling
                const Text(
                  'Flutter App',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 30),
                // Login field with styling
                _buildTextField(
                  controller: _loginController,
                  hintText: 'Saisir votre login',
                  icon: Icons.person,
                ),
                const SizedBox(height: 20),
                // Password field with styling
                _buildTextField(
                  controller: _passwordController,
                  hintText: 'Saisir votre mot de passe',
                  icon: Icons.lock,
                  obscureText: true,
                ),
                const SizedBox(height: 30),
                // Login button with styling
                _buildLoginButton(),
                const SizedBox(height: 20),
                // Additional text
                TextButton(
                  onPressed: () {
                    // Forgot password action (can be added later)
                  },
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Reusable method for building text fields with styling
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        contentPadding: const EdgeInsets.symmetric(vertical: 18.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // Login button with styling
  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: _handleLogin,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        backgroundColor: Colors.white,
      ),
      child: const Text(
        'Se connecter',
        style: TextStyle(color: Color(0xFF4A00E0), fontWeight: FontWeight.bold),
      ),
    );
  }

  // Handle login button click (add Firebase functionality later)
  void _handleLogin() async {
    final login = _loginController.text;
    final password = _passwordController.text;

    if (login.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Login et Password sont obligatoires';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Se connecter avec Firebase
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: login, 
          password: password
      );
      // Si la connexion est réussite, passer à la page de liste des vêtements
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ClothingListScreen()),
      );
      // Si la connexion est réussite, passer à la page suivante
      print("L'authentification a réussi: ${userCredential.user?.email}");
    } on FirebaseAuthException catch (e) {
      print("L'authentification a échoué: $e");
      setState(() {
        _errorMessage = e.message;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
 */