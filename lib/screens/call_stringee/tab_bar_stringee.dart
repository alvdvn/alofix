import 'dart:io';

import 'package:base_project/screens/call_stringee/tab/call_tab.dart';
import 'package:base_project/screens/call_stringee/tab/chat_tab.dart';
import 'package:base_project/screens/call_stringee/tab/conference_tab.dart';
import 'package:base_project/screens/call_stringee/tab/live_chat_tab.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class StringeeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Stringee test",
        home:  StringeePage());
  }
}

class StringeePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _StringeeState();
  }
}

class _StringeeState extends State<StringeePage> {
  int _currentIndex = 0;
  final List<Widget> _childrent = [
    CallTab(),
    ChatTab(),
    // LiveChatTab(),
    // ConferenceTab(),
  ];

  @override
  void initState() {
    super.initState();

    if (Platform.isAndroid) {
      requestPermissions();
    }
  }

  requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.microphone,
    ].request();
    print(statuses);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBar(
        title:  const Text("Stringee test"),
        backgroundColor: Colors.indigo[600],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _childrent,
      ),
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.call),
              label: 'Call',
            ),
            // BottomNavigationBarItem(
            //   icon: Icon(Icons.chat),
            //   label: 'Chat',
            // ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat),
              label: 'Live chat',
            ),
            // BottomNavigationBarItem(
            //   icon: Icon(Icons.ondemand_video),
            //   label: 'Conference',
            // ),
          ]),
    );
  }
}