import 'package:co2_detection_app_flutter/screens/homepage.dart';
import 'package:co2_detection_app_flutter/screens/login_screen.dart';
import 'package:co2_detection_app_flutter/screens/register_screen.dart';
import 'package:co2_detection_app_flutter/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Future<bool> _isLoggedIn() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   return prefs.containsKey('userId');
  // }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
          textTheme: GoogleFonts.rubikTextTheme(Theme.of(context).textTheme)),
      initialRoute: '/',
      routes: {
        RegisterScreen.routeName: (context) => RegisterScreen(),
        Homepage.routeName: (context) => const Homepage(),
        LoginScreen.routeName: (context) => LoginScreen(),
      },
      // home: FutureBuilder<bool>(
      //   future: _isLoggedIn(),
      //   builder: (context, snapshot) {
      //     if (snapshot.connectionState == ConnectionState.waiting) {
      //       return CircularProgressIndicator();
      //     } else {
      //       return snapshot.data! ? const Homepage() : LoginScreen();
      //     }
      //   },
      // ),
      home: const SplashScreen(),
    );
  }
}
