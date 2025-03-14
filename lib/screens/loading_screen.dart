import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple, // Background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo or Icon
            Icon(
              Icons.menu_book, // You can replace this with your app logo
              size: 100,
              color: Colors.white,
            ),
            SizedBox(height: 20), // Spacing

            // Loading Text
            Text(
              "Loading the Word of God...",
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20), // Spacing

            // Animated Progress Indicator
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 5,
            ),
          ],
        ),
      ),
    );
  }
}