import 'package:co2_detection_app_flutter/screens/homepage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/database_helper.dart';
import 'register_screen.dart';

class LoginScreen extends StatelessWidget {
  static const routeName = '/login_screen';
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _dbHelper = DatabaseHelper();

  LoginScreen({super.key});

  void _loginUser(BuildContext context) async {
    final username = _usernameController.text;
    final password = _passwordController.text;
    final user = await _dbHelper.loginUser(username, password);

    if (user != null) {
      final threshold = await _dbHelper.getUserThreshold(user.id!) as double;

      // store user session
      final prefs = await SharedPreferences.getInstance();
      prefs.setBool('isLoggedIn', true);
      prefs.setInt('userId', user.id!);
      prefs.setString('username', username);
      prefs.setDouble('threshold', threshold as double);

      Navigator.of(context).pushReplacementNamed(Homepage.routeName);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid username or password')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffd7e3fc),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset(
                  'assets/images/co2.png',
                  height: 200,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Login to your Account',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff1d3557),
                  ),
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none),
                    fillColor: Colors.white,
                    filled: true,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none),
                    fillColor: Colors.white,
                    filled: true,
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _loginUser(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff1d3557),
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  child: const Text(
                    'Sign in',
                    style: TextStyle(fontSize: 16, color: Color(0xffd7e3fc)),
                  ),
                ),
                const SizedBox(height: 16),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account?",
                      style: TextStyle(color: Colors.black54),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context)
                            .pushNamed(RegisterScreen.routeName);
                      },
                      child: const Text(
                        'Sign up',
                        style: TextStyle(
                            color: Color(0xff1d3557),
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}