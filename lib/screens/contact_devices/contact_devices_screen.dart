import 'package:fast_contacts/fast_contacts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:permission_handler/permission_handler.dart';

class ContactDeviceScreen extends StatefulWidget {
  const ContactDeviceScreen({Key? key}) : super(key: key);

  @override
  State<ContactDeviceScreen> createState() => _ContactDeviceScreenState();
}

class _ContactDeviceScreenState extends State<ContactDeviceScreen> {
  List<Contact> _contacts = const [];
  String? _text;
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    try {
      await Permission.contacts.request();
      final sw = Stopwatch()..start();
      final contacts = await FastContacts.allContacts;
      _contacts = contacts;
      _text = 'Contacts: ${contacts.length}\nTook: ${sw.elapsedMilliseconds}ms';
    } on PlatformException catch (e) {
      _text = 'Failed to get contacts:\n${e.details}';
    }
    if (!mounted) return;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Scaffold(
        body: SizedBox(
          height: double.infinity,
          child: FutureBuilder(
            future: getContacts(),
            builder: (context, AsyncSnapshot snapshot) {
              if (snapshot.data == null) {
                return const Center(
                  child:
                      SizedBox(height: 50, child: CircularProgressIndicator()),
                );
              }
              return ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) {
                    Contact contact = snapshot.data[index];
                    return InkWell(
                      onTap: () async=> await FlutterPhoneDirectCaller.callNumber(contact.phones.first),
                      child: Column(children: [
                        ListTile(
                          leading: const CircleAvatar(
                            radius: 20,
                            child: Icon(Icons.person),
                          ),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(contact.displayName),
                              Text(contact.phones.first)
                            ],
                          ),
                        ),
                        const Divider()
                      ]),
                    );
                  });
            },
          ),
        ),
      ),
    );
  }

  Future<List<Contact>> getContacts() async {
    bool isGranted = await Permission.contacts.status.isGranted;
    if (!isGranted) {
      isGranted = await Permission.contacts.request().isGranted;
    }
    if (isGranted) {
      return await FastContacts.allContacts;
    }
    return [];
  }
}
