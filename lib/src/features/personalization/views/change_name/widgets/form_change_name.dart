import 'package:flutter/material.dart';

class FormChangeNameWidget extends StatelessWidget {
  const FormChangeNameWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }

  // final changeNameController = Get.put(ChangeNameController());
  // final userController = UserController.instance;

  // @override
  // Widget build(BuildContext context) {
  //   return Form(
  //     key: changeNameController.changeNameFormKey,
  //     child: Padding(
  //       padding: hAppDefaultPaddingLR,
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text.rich(
  //             TextSpan(
  //               text:
  //                   'Hãy nhập đầy đủ các thông tin dưới đây để tiến hành đổi tên.',
  //               style: HAppStyle.paragraph2Regular
  //                   .copyWith(color: HAppColor.hGreyColorShade600),
  //               children: const [],
  //             ),
  //           ),
  //           gapH24,
  //           TextFormField(
  //             keyboardType: TextInputType.name,
  //             enableSuggestions: true,
  //             autocorrect: true,
  //             controller: changeNameController.nameController,
  //             validator: (value) => HAppUtils.validateEmptyField('Tên', value),
  //             decoration: InputDecoration(
  //               enabledBorder: OutlineInputBorder(
  //                   borderSide: BorderSide(
  //                       color: HAppColor.hGreyColorShade300, width: 1),
  //                   borderRadius: BorderRadius.circular(10)),
  //               focusedBorder: OutlineInputBorder(
  //                   borderSide: BorderSide(
  //                       color: HAppColor.hGreyColorShade300, width: 1),
  //                   borderRadius: BorderRadius.circular(10)),
  //               hintText: 'Nhập tên của bạn',
  //               border: OutlineInputBorder(
  //                 borderRadius: BorderRadius.circular(10),
  //               ),
  //             ),
  //           ),
  //           gapH12,
  //           ElevatedButton(
  //             onPressed: () {
  //               FocusScope.of(context).requestFocus(FocusNode());
  //               changeNameController.changeName();
  //             },
  //             style: ElevatedButton.styleFrom(
  //                 backgroundColor: HAppColor.hBluePrimaryColor,
  //                 fixedSize:
  //                     Size(HAppSize.deviceWidth - hAppDefaultPadding * 2, 50),
  //                 shape: RoundedRectangleBorder(
  //                     borderRadius: BorderRadius.circular(50))),
  //             child: Text("Đổi",
  //                 style: HAppStyle.label2Bold
  //                     .copyWith(color: HAppColor.hWhiteColor)),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
}
