import 'package:base_project/config/routes.dart';
import 'package:fast_contacts/fast_contacts.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class ContactDeviceScreen extends StatefulWidget {
  const ContactDeviceScreen({Key? key}) : super(key: key);

  @override
  State<ContactDeviceScreen> createState() => _ContactDeviceScreenState();
}

class _ContactDeviceScreenState extends State<ContactDeviceScreen> {


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text("danh bạ"),
        ),
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
                    return Column(children: [
                      ListTile(
                        leading: const CircleAvatar(
                          radius: 20,
                          child: Icon(Icons.person),
                        ),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [Text(contact.displayName),Text(contact.phones.first)],
                        ),
                      ),
                      const Divider()
                    ]);
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
