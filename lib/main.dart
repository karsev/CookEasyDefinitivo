import 'package:CookEasy/constants/colors.dart';
import 'package:CookEasy/firebase_options.dart';
import 'package:CookEasy/view/screen/start_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CookEasy',
      theme: ThemeData(
        textTheme: const TextTheme(
          //this Font we will use later 'H1'

          displayLarge: TextStyle(
            color: mainText,
            fontFamily: 'Inter',
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),

          //this font we will use later 'H2'

          displayMedium: TextStyle(
            color: mainText,
            fontFamily: 'Inter',
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
          //this font we will use  later 'H3'

          displaySmall: TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),

          //this font we will use later 'P1'

          bodyLarge: TextStyle(
            color: SecondaryText,
            fontFamily: 'Inter',
            fontSize: 17,
            fontWeight: FontWeight.w500,
          ),

          //this font we will use later 'P2'

          bodyMedium: TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          //this font we will use later 'S'
          titleMedium: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          //thus we have added all the fonts used in the projct ..
        ),
        primarySwatch: Colors.blue,
      ),
      home: const StartScreen(),
    );
  }
}
