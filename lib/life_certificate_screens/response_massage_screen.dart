import 'package:flutter/material.dart';
import 'package:pcmc_jeevan_praman/splash_screen.dart';

class ResponseScreen extends StatelessWidget {
  final String message;
  final bool success;

  ResponseScreen({required this.message, required this.success});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Dim background like a dialog effect
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85, // Dialog width
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.0), // Rounded corners
            boxShadow: [
              BoxShadow(
                color: Color(0xFF92B7F7),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    success ? Icons.check_circle_outline : Icons.error_outline,
                    color: success ? Colors.green : Colors.red,
                    size: 28,
                  ),
                  SizedBox(width: 10),
                  Text(
                    success ? 'Success' : 'Error',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Divider(thickness: 2.5),
              SizedBox(height: 10),
              Text(
                message,
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Divider(thickness: 2.5),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // TextButton(
                  //   child: Text('Cancel', style: TextStyle(color: Colors.red)),
                  //   onPressed: () {
                  //     Navigator.of(context).pop();
                  //   },
                  // ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => SplashScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: success ? Colors.green : Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    child: Text("OK"),
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
