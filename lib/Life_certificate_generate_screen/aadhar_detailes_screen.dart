import 'package:flutter/material.dart';
import 'package:pcmc_jeevan_praman/Life_certificate_generate_screen/capture_photo_screen.dart';

class AadharDetailsScreen extends StatefulWidget {
  final int statusCode;
  final String messageCode;
  final String message;
  final String verificationStatus;
  final String fullName;
  final String mobileNumber;
  final String address;
  final String dateOfBirth;
  final String verificationStatusNote;
  final String aadharNumber;
  final String ppoNumber;

  const AadharDetailsScreen({
    super.key,
    required this.statusCode,
    required this.messageCode,
    required this.message,
    required this.verificationStatus,
    required this.fullName,
    required this.mobileNumber,
    required this.address,
    required this.dateOfBirth,
    required this.verificationStatusNote,
    required this.aadharNumber,
    required this.ppoNumber,
  });

  @override
  _AadharDetailsScreenState createState() => _AadharDetailsScreenState();
}

class _AadharDetailsScreenState extends State<AadharDetailsScreen> {
  // Define TextEditingController for input fields
  TextEditingController inputFieldOneController = TextEditingController();

  // List of dropdown items (note1 to note10)
  final List<String> dropdownItems =
      List.generate(10, (index) => 'note${index + 1}');

  // Selected value for the dropdown
  String? selectedDropdownValue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF92B7F7),
        title: const Center(
          child: Text(
            ' Pensoiner Aadhar Detailes ',
            style: TextStyle(
              color: Colors.black,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.red, // Red border color
                  width: 2.0, // Border width
                ),
                borderRadius: BorderRadius.circular(15), // Rounded corners
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField('Full Name', widget.fullName),
                  Divider(thickness: 1, color: Colors.grey[300]),
                  _buildTextField('Aadhar Number', widget.aadharNumber),
                  Divider(thickness: 1, color: Colors.grey[300]),
                  _buildTextField('Mobile Number', widget.mobileNumber),
                  Divider(thickness: 1, color: Colors.grey[300]),
                  _buildTextField('Address', widget.address),
                  Divider(thickness: 1, color: Colors.grey[300]),
                  _buildTextField('Date of Birth', widget.dateOfBirth),
                  Divider(thickness: 1, color: Colors.grey[300]),
                  _buildTextField('Verification Status Note',
                      widget.verificationStatusNote),
                  Divider(thickness: 1, color: Colors.grey[300]),

                  // Input Field One

                  const SizedBox(height: 16),

                  // Container with Dropdown for Input Field Two
                  _buildInputFieldWithDropdown(),

                  const SizedBox(height: 16),
                  _buildInputField('Input Field Two', inputFieldOneController),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PhotoClickScreen(
                          ppoNumber: widget.ppoNumber,
                          aadhaarNumber: widget.aadharNumber,

                          //
                        ),
                      ),
                    );
                  },
                  // onPressed: () {
                  //   // Navigate to the NextScreen and pass data
                  //   Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //       builder: (context) => AadharVerificationScreen(
                  //         ppoNumber: widget.ppoNumber,
                  //         fullName: widget.fullName,
                  //         aadharNumber: widget.aadharNumber,
                  //         mobileNumber: widget.mobileNumber,
                  //         address: widget.address,
                  //         dateOfBirth: widget.dateOfBirth,
                  //         verificationStatusNote: widget.verificationStatusNote,
                  //         inputFieldOneValue: inputFieldOneController
                  //             .text, // Get value from input field
                  //         selectedDropdownValue:
                  //             selectedDropdownValue, // Pass selected dropdown value
                  //       ),
                  //     ),
                  //   );
                  // },
                  style: ElevatedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 35, vertical: 8),
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 5,
                    // ignore: deprecated_member_use
                    shadowColor: Colors.teal.withOpacity(0.3),
                  ),
                  child: const Text(
                    "Next",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String title, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(String title, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: 'Enter $title',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputFieldWithDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Input Field Two',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () {
              // Trigger the dropdown menu when the container is tapped
              _showDropdownMenu();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    selectedDropdownValue ??
                        'Select Note', // Show placeholder or selected value
                    style: TextStyle(
                      color: selectedDropdownValue == null
                          ? Colors.grey
                          : Colors.black,
                    ),
                  ),
                  const Spacer(), // This will push the icon to the right
                  const Icon(Icons.arrow_drop_down), // Add the dropdown icon
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDropdownMenu() async {
    // This method shows a dropdown-like dialog for selecting an item
    final String? newValue = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Center(
            child: Column(
              children: [
                Text(
                  'Select Note',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                Divider(
                  color: Colors.grey, // Set the color of the divider
                  thickness: 2, // Set the thickness of the divider
                ),
              ],
            ),
          ),
          children: dropdownItems.map((String item) {
            return SimpleDialogOption(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              onPressed: () {
                Navigator.pop(context, item); // Return the selected value
              },
              child: Row(
                children: [
                  const Icon(
                    Icons.note, // You can choose different icons if needed
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    item,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );

    if (newValue != null) {
      setState(() {
        selectedDropdownValue = newValue; // Update the selected value
      });
    }
  }
}
