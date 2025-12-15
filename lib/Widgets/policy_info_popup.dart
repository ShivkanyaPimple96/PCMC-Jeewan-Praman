import 'package:flutter/material.dart';

class PolicyInfoPopup {
  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.only(top: 233.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.9,
                maxHeight: MediaQuery.of(context).size.height * 0.9,
              ),
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  Image.asset(
                    'assets/images/policy_image.jpeg',
                    fit: BoxFit.contain,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(05.0),
                    child: IconButton(
                      icon: const Icon(Icons.cancel,
                          size: 40, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
