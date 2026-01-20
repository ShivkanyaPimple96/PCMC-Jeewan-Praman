import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pcmc_jeevan_praman/splash_screen.dart';

void main() {
  // Override global HTTP settings to bypass SSL certificate verification
  HttpOverrides.global = MyHttpOverrides();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // title: 'Flutter Demo',
      home: ResponsiveScreen(),
    );
  }
}

// Define HttpOverrides class to bypass SSL certificate verification
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

// This widget adapts the layout based on screen size
class ResponsiveScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Check the screen width
        if (constraints.maxWidth < 600) {
          // Mobile View (Narrow screen)
          return SplashScreen();
        } else {
          // Tablet or Desktop View (Wide screen)
          return Scaffold(
            appBar: AppBar(
              title: Text('Office Login - Tablet View'),
            ),
            body: Row(
              children: [
                // Sidebar for tablet
                Container(
                  width: 0,
                  color: Colors.grey[200],
                  child: Center(
                    child: Text(
                      'Sidebar Navigation',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                // Main content area
                Expanded(
                  child: SplashScreen(),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}

// The following two classes are identical and represent response screens.
