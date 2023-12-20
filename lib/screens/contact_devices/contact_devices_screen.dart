
import 'package:base_project/common/themes/colors.dart';
import 'package:base_project/common/widget/loading_widget.dart';
import 'package:base_project/common/widget/text_input_search_widget.dart';
import 'package:base_project/config/fonts.dart';
import 'package:base_project/generated/assets.dart';
import 'package:base_project/screens/call_log_screen/call_log_controller.dart';
import 'package:base_project/screens/contact_devices/contact_devices_controller.dart';
import 'package:fast_contacts/fast_contacts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class ContactDeviceScreen extends StatefulWidget {
  const ContactDeviceScreen({Key? key}) : super(key: key);

  @override
  State<ContactDeviceScreen> createState() => _ContactDeviceScreenState();
}

class _ContactDeviceScreenState extends State<ContactDeviceScreen>  with WidgetsBindingObserver{
  final ContactDevicesController controller =
  Get.put(ContactDevicesController());
  TextEditingController searchController = TextEditingController(text: "");
  ScrollController scrollController = ScrollController();
  CallLogController callLogController = Get.put(CallLogController());


  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) { }
  }

  Widget _buildItemContact(Contact contact) {
    return InkWell(
      onTap: () async {},
      child: Column(children: [
        ListTile(
          leading: CircleAvatar(
            radius: 20,
            backgroundColor: AppColor.colorGreyBackground,
            child: Image.asset(Assets.imagesImgNjv512h),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(contact.displayName,
                      style: FontFamily.demiBold(size: 14)),
                  Text(
                    contact.phones.isNotEmpty ? contact.phones.first : "",
                    style: FontFamily.regular(size: 12),
                  )
                ],
              ),
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      controller.handSMS(contact.phones.first);
                    },
                    child: SvgPicture.asset(Assets.iconsMessger,
                        color: AppColor.colorBlack, width: 25, height: 25),
                  ),
                  const SizedBox(width: 16),
                  InkWell(
                    onTap: () {
                      callLogController.secondCall = 0;
                      callLogController.handCall(contact.phones.first);
                    },
                    child: SvgPicture.asset(Assets.iconsIconCall,
                        color: AppColor.colorBlack, width: 25, height: 25),
                  )
                ],
              )
            ],
          ),
        ),
        const SizedBox(height: 16)
      ]),
    );
  }

  @override
  void initState() {
    super.initState();
    controller.initPlatformState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.colorGreyBackground,
      body: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text("Danh bạ", style: FontFamily.demiBold(size: 20)),
          elevation: 0,
          actions: [
            InkWell(
                onTap: () {
                  controller.onClickSearch();
                },
                child: Row(
                  children: [
                    SvgPicture.asset(Assets.iconsIconSearch,
                        width: 25, height: 25),
                    const SizedBox(width: 16),
                  ],
                )),
          ],
        ),
        body: SizedBox(
          height: double.infinity,
          child: Column(
            children: [
              Obx(() {
                if (controller.showSearch.value == true) {
                  return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      color: Colors.white,
                      child: TextInputSearchWidget(
                        hideClose: true,
                        controller: searchController,
                        onChange: (value) => controller.searchContactLocal(
                            search: searchController.text),
                        labelHint: 'Nhập tên tìm kiếm',
                      ));
                }
                return const SizedBox();
              }),
              const SizedBox(height: 8),
              Expanded(child: Obx(
                    () {
                  if (controller.loading.value == true) {
                    return const ShowLoading();
                  }
                  return Container(
                      color: Colors.white,
                      child: controller.contactSearch.isNotEmpty
                          ? ListView.builder(
                          controller: scrollController,
                          itemCount: controller.contactSearch.length,
                          itemBuilder: (context, index) {
                            Contact contact =
                            controller.contactSearch.value[index];
                            print(contact);
                            return _buildItemContact(contact);
                          })
                          : Center(
                          child: Text('Danh sách trống',
                              style: FontFamily.demiBold(size: 20))));
                },
              ))
            ],
          ),
        ),
      ),
    );
  }
}
