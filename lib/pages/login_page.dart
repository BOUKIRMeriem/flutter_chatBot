import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mon_projet/pages/register_page.dart';
import 'package:mon_projet/pages/chat_page.dart'; // Import de la page de chat

class LoginPage extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Fonction pour envoyer la requête de connexion vers l'API Spring Boot
  Future<void> _loginUser(BuildContext context) async {
    final String username = _usernameController.text;
    final String password = _passwordController.text;

    final url = Uri.parse('http://192.168.1.104:8080/api/auth/login');
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

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final responseData = jsonDecode(response.body);
        final token = responseData['token'];
        final userId = responseData['userId'];

        // Save token and userId for later use (e.g., shared preferences)

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Connexion réussie!"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        Future.delayed(Duration(seconds: 2), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ChatPage(userId: userId)),
          );
        });
      } else {
        _showErrorDialog(context, "Erreur de connexion : ${response.body}");
      }
    } catch (e) {
      _showErrorDialog(context, "Une erreur s'est produite : $e");
      _usernameController.clear();
      _passwordController.clear();
    }
  }

  // Fonction pour afficher une boîte de dialogue d'erreur
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Erreur"),
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
      backgroundColor: Color(0xFFFBFCFC),
      appBar: AppBar(
        backgroundColor: Color(0xFFFBFCFC),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Se connecter',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF191970),
                ),
              ),
              SizedBox(height: 32),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: "Nom d'utilisateur",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Mot de passe',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              SizedBox(height: 16),
              Container(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF191970),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    _loginUser(context);
                  },
                  child: Text(
                    'Se connecter',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Vous n'avez pas de compte ? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RegisterPage()),
                      );
                    },
                    child: Text(
                      "S'inscrire",
                      style: TextStyle(
                        color: Color(0xFF191970),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 40),
              Image.asset('assets/login.png'),
            ],
          ),
        ),
      ),
    );
  }
}
