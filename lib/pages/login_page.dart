import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mon_projet/pages/register_page.dart';
import 'package:mon_projet/pages/chat_page.dart'; // Assurez-vous d'importer votre page de chat

class LoginPage extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Fonction pour envoyer la requête de connexion vers l'API Spring Boot
  Future<void> _loginUser(BuildContext context) async {
    final String username = _usernameController.text;
    final String password = _passwordController.text;

    final url = Uri.parse('http://192.168.1.107:8080/api/auth/login');

    // Le body de la requête
    final Map<String, String> requestBody = {
      'username': username,
      'password': password,
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        // Connexion réussie
        final responseData = jsonDecode(response.body);
        final token = responseData['token'];

        // Vous pouvez stocker le token si nécessaire, par exemple dans SharedPreferences

        // Afficher un message de succès
        _showSuccessDialog(context);

        // Rediriger vers la page de chat après un court délai
        Future.delayed(Duration(seconds: 2), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ChatPage()),
          );
        });
      } else {
        // Une erreur s'est produite
        final errorData = jsonDecode(response.body);
        _showErrorDialog(context, errorData['error'] ?? "Invalid credentials");
      }
    } catch (e) {
      _showErrorDialog(context, "An error occurred: $e");
    }
  }

  // Fonction pour afficher une boîte de dialogue de réussite
  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Success"),
        content: Text("Login successful!"),
        actions: <Widget>[
          TextButton(
            child: Text("OK"),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  // Fonction pour afficher une boîte de dialogue d'erreur
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Error"),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text("OK"),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFBFCFC), // Fond blanc
      appBar: AppBar(
        backgroundColor: Color(0xFFFBFCFC), // App bar avec fond blanc
        elevation: 0, // Retirer l'ombre
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Titre "Login"
            Text(
              'Login',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF191970),
              ),
            ),
            SizedBox(height: 8),
            // Sous-titre
            Text(
              "Login to your account",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 32),
            // Champ "Username"
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            // Champ "Password"
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true, // Masquer le texte du mot de passe
            ),
            SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF191970), // Couleur bleue du bouton
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30), // Bord arrondi
                  ),
                ),
                onPressed: () {
                  _loginUser(context); // Appel à la fonction de connexion
                },
                child: Text(
                  'Login',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Don't have an account? "),
                GestureDetector(
                  onTap: () {
                    // Rediriger vers la page d'inscription
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegisterPage()),
                    );
                  },
                  child: Text(
                    'Sign up',
                    style: TextStyle(
                      color: Color(0xFF191970),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 40), // Espacement entre le texte et l'image
            // Image sous le texte
            Image.asset('assets/login.png'),
          ],
        ),
      ),
    );
  }
}
