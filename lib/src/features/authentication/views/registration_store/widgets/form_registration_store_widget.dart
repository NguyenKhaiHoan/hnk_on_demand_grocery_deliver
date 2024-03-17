// import 'package:eva_icons_flutter/eva_icons_flutter.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:on_demand_grocery_deliver/src/common_widgets/custom_shimmer_widget.dart';
// import 'package:on_demand_grocery_deliver/src/constants/app_colors.dart';
// import 'package:on_demand_grocery_deliver/src/constants/app_sizes.dart';
// import 'package:on_demand_grocery_deliver/src/features/authentication/controller/registration_store_controller.dart';
// import 'package:on_demand_grocery_deliver/src/features/personalization/controllers/address_controller.dart';
// import 'package:on_demand_grocery_deliver/src/features/personalization/controllers/user_controller.dart';
// import 'package:on_demand_grocery_deliver/src/features/personalization/models/district_ward_model.dart';
// import 'package:on_demand_grocery_deliver/src/utils/theme/app_style.dart';
// import 'package:on_demand_grocery_deliver/src/utils/utils.dart';

// class FormRegistrationStoreWidget extends StatefulWidget {
//   const FormRegistrationStoreWidget({
//     super.key,
//   });

//   @override
//   State<FormRegistrationStoreWidget> createState() =>
//       _FormRegistrationStoreWidgetState();
// }

// class _FormRegistrationStoreWidgetState
//     extends State<FormRegistrationStoreWidget> {
//   final double storeBackgroundHeight = 200;
//   final double storeImageHeight = 140;

//   Uint8List? storeImage;
//   Uint8List? storeImageBackground;

//   // final addressController = AddressController.instance;
//   final registrationController = Get.put(RegistrationController());
//   final deliveryPersonController = DeliveryPersonController.instance;

//   String? valueDistrict;
//   String? valueWard;
//   String? valueCity;
//   List<String> list = [];

//   void selectWard(String? newValue) {
//     valueWard = newValue!;
//     registrationController.ward.value = valueWard!;
//     setState(() {});
//   }

//   void selectCity(String? newValue) {
//     valueCity = newValue!;
//     valueDistrict = null;
//     valueWard = null;
//     registrationController.city.value = valueCity!;
//     registrationController.district.value = '';
//     registrationController.ward.value = '';
//     setState(() {});
//   }

//   // void selectDistrict(String? newValue) {
//   //   valueDistrict = newValue!;
//   //   valueWard = null;
//   //   registrationController.district.value = valueDistrict!;
//   //   registrationController.ward.value = '';
//   //   list.assignAll(List<String>.from(addressController.hanoiData
//   //       .firstWhere((DistrictModel model) => model.name == valueDistrict)
//   //       .children!
//   //       .map((WardModel model) => model.name)
//   //       .toList()));
//   //   setState(() {});
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return Form(
//       key: registrationController.addAddressFormKey,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             "Hoàn thiện đăng ký cửa hàng,",
//             style: HAppStyle.heading3Style,
//           ),
//           gapH6,
//           Text.rich(
//             TextSpan(
//               text:
//                   'Hãy hoàn thành nốt các thông tin sau đây để hoàn tất đăng ký cửa hàng.',
//               style: HAppStyle.paragraph2Regular
//                   .copyWith(color: HAppColor.hGreyColorShade600),
//               children: const [],
//             ),
//           ),
//           gapH24,
//           gapH12,
//           ElevatedButton(
//             onPressed: () {
//               FocusScope.of(context).requestFocus(FocusNode());
//               registrationController.saveInfo();
//             },
//             style: ElevatedButton.styleFrom(
//                 backgroundColor: HAppColor.hBluePrimaryColor,
//                 fixedSize:
//                     Size(HAppSize.deviceWidth - hAppDefaultPadding * 2, 50),
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(50))),
//             child: Text("Lưu",
//                 style: HAppStyle.label2Bold
//                     .copyWith(color: HAppColor.hWhiteColor)),
//           ),
//         ],
//       ),
//     );
//   }
// }
