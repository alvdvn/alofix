import 'package:base_project/common/themes/colors.dart';
import 'package:base_project/common/widget/button_custom_widget.dart';
import 'package:base_project/config/fonts.dart';
import 'package:base_project/generated/assets.dart';
import 'package:fast_contacts/fast_contacts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
      backgroundColor: AppColor.colorGreyBackground,
      body: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text("Danh bạ",style: FontFamily.DemiBold(size: 20)),
          elevation: 0,
          actions: [
            SvgPicture.asset(Assets.iconsIconSearch,width: 24,height: 24),
            const SizedBox(width: 32),
            SvgPicture.asset(Assets.iconsIconPlus),
            const SizedBox(width: 16),
          ],
        ),
        body: SizedBox(
          height: double.infinity,
          child: Column(
            children: [
              const SizedBox(height: 8),
              Expanded(
                  child: Container(color: Colors.white, child: _buildBody()))
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return FutureBuilder(
      future: getContacts(),
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.data == null) {
          return const Center(
            child: SizedBox(height: 50, child: CircularProgressIndicator()),
          );
        }
        return ListView.builder(
            itemCount: snapshot.data.length,
            itemBuilder: (context, index) {
              Contact contact = snapshot.data[index];
              return InkWell(
                onTap: () async => await FlutterPhoneDirectCaller.callNumber(
                    contact.phones.first),
                child: Column(children: [
                  ListTile(
                    leading: const CircleAvatar(
                      radius: 20,
                      child: Icon(Icons.person),
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(contact.displayName,
                                style: FontFamily.DemiBold(size: 14)),
                            Text(
                              contact.phones.first,
                              style: FontFamily.Regular(size: 12),
                            )
                          ],
                        ),
                        SvgPicture.asset(Assets.iconsIconCall,
                            color: AppColor.colorBlack)
                      ],
                    ),
                  ),
                  const SizedBox(height: 16)
                ]),
              );
            });
      },
    );
  }

  Widget _buildHeader(){
    return Row(
      children: [
        const SizedBox(width: 16),
        Expanded(child: ButtonCustomWidget(title: 'Chung', action: () {  })),
        const SizedBox(width: 16),
        Expanded(child: ButtonCustomWidget(title: 'Từ máy', action: () {  })),
        const SizedBox(width: 16),
      ],
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
