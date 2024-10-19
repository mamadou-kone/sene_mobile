import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../couleur.dart';
import '../../models/user.dart';
import '../../services/auth_controleur.dart';

class LoginIvestisseur extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthController authController = AuthController.instance;

  final FocusNode usernameFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        // Utilisation de SingleChildScrollView pour permettre le défilement
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/images/login_bg.png',
                fit: BoxFit.cover,
              ),
              Column(
                children: [
                  const SizedBox(height: 10),
                  Expanded(
                    flex: 1,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          margin: const EdgeInsets.only(left: 5, top: 5),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.elliptical(20, 15),
                              topLeft: Radius.elliptical(20, 15),
                            ),
                          ),
                          child: const Icon(Icons.arrow_back),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Center(
                      child: Image.asset(
                        'assets/images/logo_sene_blanc.png',
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(40.0),
                        ),
                      ),
                      padding: const EdgeInsets.all(16.0),
                      child: SingleChildScrollView(
                        // Ajout du scroll ici pour éviter l'overflow
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            SizedBox(
                              width: 250,
                              height: 45,
                              child: TextField(
                                focusNode: usernameFocusNode,
                                controller: usernameController,
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  filled: true,
                                  fillColor: Couleur.primary,
                                  labelStyle: const TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: 250,
                              height: 45,
                              child: TextField(
                                focusNode: passwordFocusNode,
                                controller: passwordController,
                                decoration: InputDecoration(
                                  labelText: 'Mot de passe',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  filled: true,
                                  fillColor: Couleur.primary,
                                  labelStyle: const TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                obscureText: true,
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                    context, '/forgot_password');
                              },
                              child: Text(
                                'Mot de passe oublié ?',
                                style: TextStyle(
                                  color: Couleur.primary,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                            const SizedBox(height: 50),
                            SizedBox(
                              height: 45,
                              width: 200,
                              child: ElevatedButton(
                                onPressed: () async {
                                  User user = User(
                                    username: usernameController.text,
                                    password: passwordController.text,
                                  );
                                  var result = await authController.login(user);
                                  if (result['success']) {
                                    String token = result['token'];
                                    String role = result['role'];
                                    // Stockez le token si nécessaire

                                    // Redirection basée sur le rôle
                                    if (role == 'Investisseur') {
                                      Navigator.pushReplacementNamed(
                                          context, '/homeInvestisseur');
                                    } else {
                                      Navigator.pushReplacementNamed(
                                          context, '/access_denied');
                                    }
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Échec de la connexion'),
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Couleur.primary,
                                    foregroundColor: Colors.white),
                                child: const Text('Connexion'),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                        context, '/investisseurAjout');
                                  },
                                  child: Text(
                                    'Créer un compte',
                                    style: TextStyle(
                                      color: Couleur.primary,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
