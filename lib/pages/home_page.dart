import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mon_projet/pages/register_page.dart';
import 'package:mon_projet/pages/login_page.dart';    

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Change the status bar color
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Color(0xFFFBFCFC), // Same as your background color
    ));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFBFCFC), // Match the app bar background color
        elevation: 0, // Remove shadow/elevation
      ),
      
      // Change the background color of the page
      backgroundColor: Color(0xFFFBFCFC),
      
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Image.asset('assets/ai_image.png'),
          Text(
            'Bienvenue',
            style: TextStyle(
              fontSize: 60,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
              color: Color(0xFF191970),
            ),
          ),
          SizedBox(height: 150), // Adjust space as needed
          
          // Sign Up button
          Container(
            width: 270,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF191970), // Dark blue (Midnight Blue)
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // Rounded edges
                ),
              ),
              onPressed: () {
                // Rediriger vers la page d'inscription
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterPage()),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                     "S'inscrire",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 10), // Space between button and "Login" link
          
          GestureDetector(
            onTap: () {
              // Rediriger vers la page de connexion
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
            child: Text.rich(
              TextSpan(
                text: "Vous avez déjà un compte ? ",
                style: TextStyle(
                  color: Colors.black54, // Default text color
                ),
                children: [
                  TextSpan(
                    text: "se Connecter",
                    style: TextStyle(
                      color: Color(0xFF191970), // Dark blue (Midnight Blue)
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
