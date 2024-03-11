import 'package:flutter/material.dart';

class ChangeNameScreen extends StatefulWidget {
  const ChangeNameScreen({super.key});

  @override
  State<ChangeNameScreen> createState() => _ChangeNameScreenState();
}

class _ChangeNameScreenState extends State<ChangeNameScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     resizeToAvoidBottomInset: true,
  //     appBar: AppBar(
  //       toolbarHeight: 80,
  //       leading: Align(
  //         alignment: Alignment.centerLeft,
  //         child: Padding(
  //           padding: const EdgeInsets.only(left: hAppDefaultPadding),
  //           child: GestureDetector(
  //               onTap: () {
  //                 Get.back();
  //               },
  //               child: const Icon(
  //                 Icons.arrow_back_ios,
  //                 size: 20,
  //               )),
  //         ),
  //       ),
  //       title: const Text("Đổi tên"),
  //       centerTitle: true,
  //     ),
  //     body: SingleChildScrollView(
  //         child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [FormChangeNameWidget()],
  //     )),
  //   );
  // }
}
