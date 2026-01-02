import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pcmc_jeevan_praman/life_certificate_screens/view_button_screen.dart';
import 'dart:convert';

class ResponseKYCScreen extends StatefulWidget {
  final String message;
  final bool success;
  final String ppoNumber;
  final String mobileNumber;

  ResponseKYCScreen({
    required this.message,
    required this.success,
    required this.ppoNumber,
    required this.mobileNumber,
  });

  @override
  State<ResponseKYCScreen> createState() => _ResponseKYCScreenState();
}

class _ResponseKYCScreenState extends State<ResponseKYCScreen> {
  bool _isLoading = false;

  Future<void> _fetchDataAndNavigate() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final url = Uri.parse(
          'https://testingpcmcpensioner.altwise.in/api/aadhar/GetDataUsingPPONo?PPONumber=${widget.ppoNumber}');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        // Check if the API response indicates success
        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          final data = jsonResponse['data'];

          // Navigate to ViewButtonScreen with the data
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => ViewButtonScreen(
                statusCode: jsonResponse['status_code'] ?? 200,
                messageCode: jsonResponse['message_code']?.toString() ?? '',
                message: jsonResponse['message']?.toString() ?? '',
                verificationStatus:
                    data['verificationStatus']?.toString() ?? '',
                fullName: data['FullName']?.toString() ?? '',
                mobileNumber:
                    data['MobileNumber']?.toString() ?? widget.mobileNumber,
                address: data['address']?.toString() ?? '',
                createdAt: '', // Not present in API response, keeping empty
                verificationStatusNote:
                    data['verificationStatusNote']?.toString() ?? '',
                aadharNumber: data['aadharNumber']?.toString() ??
                    data['AdharCardNo']?.toString() ??
                    '',
                url: '',
                profilePhotoUrl:
                    '', // Not present in API response, keeping empty
                dateOfBirth: data['dateOfBirth']?.toString() ?? '',
                ppoNumber: data['ppoNumber']?.toString() ??
                    data['PPONumber']?.toString() ??
                    widget.ppoNumber,
                pensionType: data['pensionType']?.toString() ??
                    data['PensionType']?.toString() ??
                    '',
              ),
            ),
            (Route<dynamic> route) => false,
          );
        } else {
          // Handle unsuccessful API response
          _showErrorDialog(
              jsonResponse['message']?.toString() ?? 'Failed to fetch data');
        }
      } else {
        // Handle non-200 status codes
        _showErrorDialog(
            'Failed to fetch data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Handle errors
      _showErrorDialog('Error occurred: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(errorMessage),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: const [
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
                        widget.success
                            ? Icons.check_circle_outline
                            : Icons.error_outline,
                        color: widget.success ? Colors.green : Colors.red,
                        size: 28,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        widget.success ? 'Success' : 'Note',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Divider(thickness: 2.5),
                  const SizedBox(height: 10),
                  Text(
                    widget.message,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  const Divider(thickness: 2.5),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _fetchDataAndNavigate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              widget.success ? Colors.green : Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text("OK"),
                      ),
                    ],
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
