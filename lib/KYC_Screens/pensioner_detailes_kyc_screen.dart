import 'package:flutter/material.dart';
import 'package:pcmc_jeevan_praman/KYC_Screens/aadhar_verification_kyc_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PensionerDetailesKYCScreen extends StatefulWidget {
  final String ppoNumber;
  final String mobileNumber;
  final String fullName;

  const PensionerDetailesKYCScreen({
    super.key,
    required this.ppoNumber,
    required this.mobileNumber,
    required this.fullName,
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
  String? _selectedGender; // Changed from TextEditingController to String
  bool _isLoading = false;

  // List of gender options
  final List<String> _genderOptions = [
    'Male',
    'Female',
    'Other',
  ];

  Future<void> _submitData() async {
    if (!_formKey.currentState!.validate()) {
      print('Form validation failed');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Print the data being sent
    final postData = {
      "PPONumber": widget.ppoNumber,
      "AadhaarNumber": _aadharController.text,
      "Address": _addressController.text,
      "Gender": _selectedGender, // Using the selected gender
    };

    print('Submitting data to API: ${json.encode(postData)}');

    try {
      final response = await http.post(
        Uri.parse(
            'https://testingpcmcpensioner.altwise.in/api/aadhar/UpdateDataUsingPPONO'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(postData),
      );

      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        print('API call successful, navigating to next screen');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AadharVerificationKYCScreen(
              ppoNumber: widget.ppoNumber,
              fullName: widget.fullName,
              mobileNumber: widget.mobileNumber,
              aadharNumber: _aadharController.text,
              address: _addressController.text,
              // gender: _selectedGender,
            ),
          ),
        );
      } else {
        print('API call failed with status ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit data: ${response.body}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error during API call: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      print('API call completed');
      setState(() {
        _isLoading = false;
      });
    }
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
            fontSize: 20,
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
                        print('Aadhar number validation failed: empty');
                        return 'Please enter Aadhar number';
                      }
                      if (value.length != 12) {
                        print('Aadhar number validation failed: not 12 digits');
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
                        print('Address validation failed: empty');
                        return 'Please enter your address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  // Dropdown for Gender selection
                  InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Select Gender',
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
                          });
                        },
                      ),
                    ),
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
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              elevation: 5,
                              shadowColor: Colors.teal.withOpacity(0.3),
                            ),
                            child: const Text(
                              'Complete Your KYC\nतुमची केवायसी पूर्ण करा',
                              style: TextStyle(
                                  color: Colors.white,
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

// import 'package:flutter/material.dart';
// import 'package:pcmc_jeevan_praman/KYC_Screens/aadhar_verification_kyc_screen.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class PensionerDetailesKYCScreen extends StatefulWidget {
//   final String ppoNumber;
//   final String mobileNumber;
//   final String fullName;

//   const PensionerDetailesKYCScreen({
//     super.key,
//     required this.ppoNumber,
//     required this.mobileNumber,
//     required this.fullName,
//   });

//   @override
//   State<PensionerDetailesKYCScreen> createState() =>
//       _PensionerDetailesKYCScreenState();
// }

// class _PensionerDetailesKYCScreenState
//     extends State<PensionerDetailesKYCScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _aadharController = TextEditingController();
//   final TextEditingController _addressController = TextEditingController();
//   final TextEditingController _genderController = TextEditingController();
//   bool _isLoading = false;

//   Future<void> _submitData() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final response = await http.post(
//         Uri.parse(
//             'https://testingpcmcpensioner.altwise.in/api/aadhar/UpdateDataUsingPPONO'),
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode({
//           "PPONumber": widget.ppoNumber,
//           "AadhaarNumber": _aadharController.text,
//           "Address": _addressController.text,
//           "Gender": _genderController.text,
//         }),
//       );

//       print('API Response Status: ${response.statusCode}');
//       print('API Response Body: ${response.body}');

//       if (response.statusCode == 200) {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => AadharVerificationKYCScreen(
//               ppoNumber: widget.ppoNumber,
//               fullName: widget.fullName,
//               mobileNumber: widget.mobileNumber,
//               aadharNumber: _aadharController.text,
//               address: _addressController.text,
//               // gender: _genderController.text,
//             ),
//           ),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Failed to submit data: ${response.body}'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _aadharController.dispose();
//     _addressController.dispose();
//     _genderController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Pensioner Details [Step-2]',
//           style: TextStyle(
//             color: Colors.black,
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         backgroundColor: const Color(0xFF92B7F7),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Container(
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: const Color(0xFF92B7F7), width: 2),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _buildInfoCard('PPO Number', widget.ppoNumber),
//                   const SizedBox(height: 15),
//                   _buildInfoCard('Full Name', widget.fullName),
//                   const SizedBox(height: 15),
//                   _buildInfoCard('Mobile Number', widget.mobileNumber),
//                   const SizedBox(height: 25),
//                   TextFormField(
//                     controller: _aadharController,
//                     keyboardType: TextInputType.number,
//                     maxLength: 12,
//                     decoration: InputDecoration(
//                       labelText: 'Enter Aadhar Number',
//                       hintText: 'Enter 12-digit Aadhar number',
//                       filled: true,
//                       fillColor: Colors.white,
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                         borderSide: const BorderSide(
//                             color: Color(0xFF92B7F7), width: 2),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                         borderSide: const BorderSide(
//                             color: Color(0xFF92B7F7), width: 2),
//                       ),
//                     ),
//                     validator: (value) {
//                       if (value == null || value.isEmpty)
//                         return 'Please enter Aadhar number';
//                       if (value.length != 12)
//                         return 'Aadhar must be exactly 12 digits';
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 20),
//                   TextFormField(
//                     controller: _addressController,
//                     maxLines: 3,
//                     decoration: InputDecoration(
//                       labelText: 'Enter your Address',
//                       filled: true,
//                       fillColor: Colors.white,
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                         borderSide: const BorderSide(
//                             color: Color(0xFF92B7F7), width: 2),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                         borderSide: const BorderSide(
//                             color: Color(0xFF92B7F7), width: 2),
//                       ),
//                     ),
//                     validator: (value) {
//                       if (value == null || value.isEmpty)
//                         return 'Please enter your address';
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 20),
//                   TextFormField(
//                     controller: _genderController,
//                     decoration: InputDecoration(
//                       labelText: 'Enter your Gender',
//                       filled: true,
//                       fillColor: Colors.white,
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                         borderSide: const BorderSide(
//                             color: Color(0xFF92B7F7), width: 2),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                         borderSide: const BorderSide(
//                             color: Color(0xFF92B7F7), width: 2),
//                       ),
//                     ),
//                     validator: (value) => value == null || value.isEmpty
//                         ? 'Please enter gender'
//                         : null,
//                   ),
//                   const SizedBox(height: 30),
//                   Center(
//                     child: _isLoading
//                         ? const CircularProgressIndicator()
//                         : ElevatedButton(
//                             onPressed: _submitData,
//                             style: ElevatedButton.styleFrom(
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 35, vertical: 8),
//                               backgroundColor: Colors.green,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(25),
//                               ),
//                               elevation: 5,
//                               shadowColor: Colors.teal.withOpacity(0.3),
//                             ),
//                             child: const Text(
//                               'Complete Your KYC\nतुमची केवायसी पूर्ण करा',
//                               style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.bold),
//                             ),
//                           ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildInfoCard(String title, String value) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(15),
//       decoration: BoxDecoration(
//         color: Colors.grey[200],
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             title,
//             style: const TextStyle(
//               fontSize: 14,
//               color: Colors.grey,
//             ),
//           ),
//           const SizedBox(height: 5),
//           Text(
//             value,
//             style: const TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:pcmc_jeevan_praman/KYC_Screens/aadhar_verification_kyc_screen.dart';

// class PensionerDetailesKYCScreen extends StatefulWidget {
//   final String ppoNumber;
//   final String mobileNumber;
//   final String fullName;

//   const PensionerDetailesKYCScreen({
//     super.key,
//     required this.ppoNumber,
//     required this.mobileNumber,
//     required this.fullName,
//   });

//   @override
//   State<PensionerDetailesKYCScreen> createState() =>
//       _PensionerDetailesKYCScreenState();
// }

// class _PensionerDetailesKYCScreenState
//     extends State<PensionerDetailesKYCScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _aadharController = TextEditingController();
//   final TextEditingController _addressController = TextEditingController();
//   final TextEditingController _genderController = TextEditingController();

//   @override
//   void dispose() {
//     _aadharController.dispose();
//     _addressController.dispose();
//     _genderController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Pensioner Details [Step-2]',
//           style: TextStyle(
//             color: Colors.black,
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         backgroundColor: const Color(0xFF92B7F7), // Match the blue color
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Container(
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: const Color(0xFF92B7F7), width: 2),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _buildInfoCard('PPO Number', widget.ppoNumber),
//                   const SizedBox(height: 15),
//                   _buildInfoCard('Full Name', widget.fullName),
//                   const SizedBox(height: 15),
//                   _buildInfoCard('Mobile Number', widget.mobileNumber),
//                   const SizedBox(height: 25),
//                   TextFormField(
//                     controller: _aadharController,
//                     keyboardType: TextInputType.number,
//                     maxLength: 12,
//                     decoration: InputDecoration(
//                       labelText: 'Enter Aadhar Number',
//                       hintText: 'Enter 12-digit Aadhar number',
//                       // prefixIcon: const Icon(Icons.credit_card,
//                       //     color: Color(0xFF92B7F7)),
//                       filled: true,
//                       fillColor: Colors.white,
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                         borderSide: const BorderSide(
//                             color: Color(0xFF92B7F7), width: 2),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                         borderSide: const BorderSide(
//                             color: Color(0xFF92B7F7), width: 2),
//                       ),
//                     ),
//                     validator: (value) {
//                       if (value == null || value.isEmpty)
//                         return 'Please enter Aadhar number';
//                       if (value.length != 12)
//                         return 'Aadhar must be exactly 12 digits';
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 20),
//                   TextFormField(
//                     controller: _addressController,
//                     maxLines: 3,
//                     decoration: InputDecoration(
//                       labelText: 'Enter your Address',
//                       // hintText:
//                       //     'Enter your complete address\n(Street, City, State, PIN Code)',
//                       // prefixIcon:
//                       //     const Icon(Icons.home, color: Color(0xFF92B7F7)),
//                       filled: true,
//                       fillColor: Colors.white,
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                         borderSide: const BorderSide(
//                             color: Color(0xFF92B7F7), width: 2),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                         borderSide: const BorderSide(
//                             color: Color(0xFF92B7F7), width: 2),
//                       ),
//                     ),
//                     validator: (value) {
//                       if (value == null || value.isEmpty)
//                         return 'Please enter your address';
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 20),
//                   TextFormField(
//                     controller: _genderController, // define this in your state
//                     decoration: InputDecoration(
//                       labelText: 'Enter your Gender',
//                       filled: true,
//                       fillColor: Colors.white,
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                         borderSide: const BorderSide(
//                             color: Color(0xFF92B7F7), width: 2),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                         borderSide: const BorderSide(
//                             color: Color(0xFF92B7F7), width: 2),
//                       ),
//                     ),
//                     validator: (value) => value == null || value.isEmpty
//                         ? 'Please enter gender'
//                         : null,
//                   ),
//                   const SizedBox(height: 30),
//                   Center(
//                     child: ElevatedButton(
//                       onPressed: () {
//                         if (_formKey.currentState!.validate()) {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => AadharVerificationKYCScreen(
//                                 ppoNumber: widget.ppoNumber,
//                                 fullName: widget.fullName,
//                                 mobileNumber: widget.mobileNumber,
//                                 aadharNumber: _aadharController.text,
//                                 address: _addressController.text,
//                                 // gender: _genderController.text,
//                               ),
//                             ),
//                           );
//                         }
//                       },
//                       style: ElevatedButton.styleFrom(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 35, vertical: 8),
//                         backgroundColor: Colors.green,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(25),
//                         ),
//                         elevation: 5,
//                         shadowColor: Colors.teal.withOpacity(0.3),
//                       ),
//                       child: const Text(
//                         'Complete Your KYC\nतुमची केवायसी पूर्ण करा',
//                         style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildInfoCard(String title, String value) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(15),
//       decoration: BoxDecoration(
//         color: Colors.grey[200],
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             title,
//             style: const TextStyle(
//               fontSize: 14,
//               color: Colors.grey,
//             ),
//           ),
//           const SizedBox(height: 5),
//           Text(
//             value,
//             style: const TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
