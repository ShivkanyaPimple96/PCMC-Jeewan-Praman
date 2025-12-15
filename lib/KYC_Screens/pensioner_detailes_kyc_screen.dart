import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pcmc_jeevan_praman/KYC_Screens/aadhar_verification_kyc_screen.dart';

class PensionerDetailesKYCScreen extends StatefulWidget {
  final String ppoNumber;
  final String mobileNumber;
  final String fullName;
  final String pensionType;

  const PensionerDetailesKYCScreen({
    super.key,
    required this.ppoNumber,
    required this.mobileNumber,
    required this.fullName,
    required this.pensionType,
  });

  @override
  State<PensionerDetailesKYCScreen> createState() =>
      _PensionerDetailesKYCScreenState();
}

class _PensionerDetailesKYCScreenState
    extends State<PensionerDetailesKYCScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _aadharController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  String? _selectedGender;
  bool _isLoading = false;
  bool _genderValidationError = false;

  final List<String> _genderOptions = [
    'Male',
    'Female',
    'Other',
  ];

  Future<void> _submitData() async {
    // Reset validation error
    setState(() {
      _genderValidationError = false;
    });

    // Check if gender is selected
    if (_selectedGender == null) {
      setState(() {
        _genderValidationError = true;
      });
    }

    // Validate form
    if (!_formKey.currentState!.validate() || _selectedGender == null) {
      print('Form validation failed');
      return; // Stop here if validation fails
    }

    // All validations passed, navigate to next screen
    print('Form validation successful, navigating to next screen');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AadharVerificationKYCScreen(
          ppoNumber: widget.ppoNumber,
          fullName: widget.fullName,
          mobileNumber: widget.mobileNumber,
          aadharNumber: _aadharController.text,
          address: _addressController.text,
          gender: _selectedGender!,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _aadharController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pensioner Details [Step-2]',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF92B7F7),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF92B7F7), width: 2),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoCard('PPO Number', widget.ppoNumber),
                  const SizedBox(height: 15),
                  _buildInfoCard('Full Name', widget.fullName),
                  const SizedBox(height: 15),
                  _buildInfoCard('PensionType', widget.pensionType),
                  const SizedBox(height: 15),
                  _buildInfoCard('Mobile Number', widget.mobileNumber),
                  const SizedBox(height: 25),
                  TextFormField(
                    controller: _aadharController,
                    keyboardType: TextInputType.number,
                    maxLength: 12,
                    decoration: InputDecoration(
                      labelText: 'Enter Aadhar Number',
                      hintText: 'Enter 12-digit Aadhar number',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                            color: Color(0xFF92B7F7), width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                            color: Color(0xFF92B7F7), width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter Aadhar number';
                      }
                      if (value.length != 12) {
                        return 'Aadhar must be exactly 12 digits';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _addressController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Enter your Address',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                            color: Color(0xFF92B7F7), width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                            color: Color(0xFF92B7F7), width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  // Gender Dropdown with validation
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Select Gender*',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: Color(0xFF92B7F7), width: 2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: Color(0xFF92B7F7), width: 2),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                const BorderSide(color: Colors.red, width: 2),
                          ),
                          errorText: _genderValidationError
                              ? 'Please select your gender'
                              : null,
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedGender,
                            isDense: true,
                            isExpanded: true,
                            hint: const Text('Select Gender'),
                            items: _genderOptions.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedGender = newValue;
                                _genderValidationError = false;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: _submitData,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 35, vertical: 8),
                              backgroundColor: Color(0xFF92B7F7),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              elevation: 5,
                              shadowColor: Colors.teal.withOpacity(0.3),
                            ),
                            child: const Text(
                              'Complete Your KYC\nतुमची केवायसी पूर्ण करा',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
