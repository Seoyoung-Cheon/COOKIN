import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'providers/recipe_provider.dart';

/// 앱 시작점
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => RecipeProvider(),
      child: MaterialApp(
        title: 'COOKIN',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
          useMaterial3: true,
          fontFamily: 'LeeSeoYun',
          textTheme: const TextTheme(
            displayLarge: TextStyle(fontFamily: 'LeeSeoYun'),
            displayMedium: TextStyle(fontFamily: 'LeeSeoYun'),
            displaySmall: TextStyle(fontFamily: 'LeeSeoYun'),
            headlineLarge: TextStyle(fontFamily: 'LeeSeoYun'),
            headlineMedium: TextStyle(fontFamily: 'LeeSeoYun'),
            headlineSmall: TextStyle(fontFamily: 'LeeSeoYun'),
            titleLarge: TextStyle(fontFamily: 'LeeSeoYun'),
            titleMedium: TextStyle(fontFamily: 'LeeSeoYun'),
            titleSmall: TextStyle(fontFamily: 'LeeSeoYun'),
            bodyLarge: TextStyle(fontFamily: 'LeeSeoYun'),
            bodyMedium: TextStyle(fontFamily: 'LeeSeoYun'),
            bodySmall: TextStyle(fontFamily: 'LeeSeoYun'),
            labelLarge: TextStyle(fontFamily: 'LeeSeoYun'),
            labelMedium: TextStyle(fontFamily: 'LeeSeoYun'),
            labelSmall: TextStyle(fontFamily: 'LeeSeoYun'),
          ),
        ),
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
