import 'package:base_project/common/themes/colors.dart';
import 'package:base_project/common/widget/button_custom_widget.dart';
import 'package:base_project/config/fonts.dart';
import 'package:base_project/generated/assets.dart';
import 'package:base_project/screens/contact_devices/contact_devices_controller.dart';
import 'package:fast_contacts/fast_contacts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class ContactDeviceScreen extends StatefulWidget {
  const ContactDeviceScreen({Key? key}) : super(key: key);

  @override
  State<ContactDeviceScreen> createState() => _ContactDeviceScreenState();
}

class _ContactDeviceScreenState extends State<ContactDeviceScreen> {
  final ContactDevicesController _controller = Get.put(ContactDevicesController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.colorGreyBackground,
      body: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text("Danh bạ", style: FontFamily.DemiBold(size: 20)),
          elevation: 0,
          actions: [
            SvgPicture.asset(Assets.iconsIconSearch, width: 24, height: 24),
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
                  child: Container(
                      color: Colors.white,
                      child: GetBuilder<ContactDevicesController>(
                        builder: (context) {
                          return  ListView.builder(
                              itemCount: _controller.contact.length,
                              itemBuilder: (context, index) {
                                Contact contact = _controller.contact[index];
                                return InkWell(
                                  onTap: () async => await FlutterPhoneDirectCaller.callNumber(
                                      contact.phones.first),
                                  child: Column(children: [
                                    ListTile(
                                      leading: CircleAvatar(
                                        radius: 20,
                                        backgroundColor: AppColor.colorGreyBackground,
                                        child: Image.asset(Assets.imagesImageNjv),
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
                      )))
            ],
          ),
        ),
      ),
    );
  }
}
