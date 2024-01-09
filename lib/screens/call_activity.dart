import 'package:base_project/common/themes/colors.dart';
import 'package:base_project/generated/assets.dart';
import 'package:flutter/material.dart';

class CustomCallingScreen extends StatefulWidget {
  final String contactName;
  final String contactNumber;

  CustomCallingScreen({required this.contactName, required this.contactNumber});

  @override
  _CustomCallingScreenState createState() => _CustomCallingScreenState();
}

class _CustomCallingScreenState extends State<CustomCallingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.colorGrey, // Adjust color to match your design
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60.0,
              backgroundColor: Colors.white,
              child:
                  Image.asset(Assets.imagesImgNjv512h, width: 60, height: 60),
            ),
            SizedBox(height: 16),
            Text(
              'Incoming Call',
              style: TextStyle(fontSize: 24, color: Colors.black),
            ),
            SizedBox(height: 16),
            Text(
              widget.contactName,
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
            SizedBox(height: 8),
            Text(
              widget.contactNumber,
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
            SizedBox(height: 32),
            Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                padding: EdgeInsets.all(12),
                child: IconButton(
                  icon: Icon(Icons.volume_up, color: Colors.black, size: 30),
                  onPressed: () {
                    // Add volume control logic here
                  },
                )),
            Text(
              "Loa ngoài",
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
            SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red,
              ),
              margin: EdgeInsets.only(top: 40),
              padding: EdgeInsets.all(16),
              child: IconButton(
                icon: Icon(Icons.call_end, color: Colors.white, size: 36),
                onPressed: () {
                  // Add hang-up call logic here
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
