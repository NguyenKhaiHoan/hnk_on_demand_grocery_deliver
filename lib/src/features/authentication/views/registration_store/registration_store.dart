import 'dart:ffi';

import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:on_demand_grocery_deliver/src/common_widgets/custom_shimmer_widget.dart';
import 'package:on_demand_grocery_deliver/src/constants/app_colors.dart';
import 'package:on_demand_grocery_deliver/src/constants/app_sizes.dart';
import 'package:on_demand_grocery_deliver/src/features/authentication/controller/registration_store_controller.dart';
import 'package:on_demand_grocery_deliver/src/features/authentication/views/registration_store/widgets/form_registration_store_widget.dart';
import 'package:on_demand_grocery_deliver/src/features/personalization/controllers/user_controller.dart';
import 'package:on_demand_grocery_deliver/src/utils/theme/app_style.dart';
import 'package:on_demand_grocery_deliver/src/utils/utils.dart';

class RegistrationDeliveryPersonScreen extends StatefulWidget {
  const RegistrationDeliveryPersonScreen({super.key});

  @override
  State<RegistrationDeliveryPersonScreen> createState() =>
      _RegistrationDeliveryPersonScreenState();
}

class _RegistrationDeliveryPersonScreenState
    extends State<RegistrationDeliveryPersonScreen> {
  final registrationController = Get.put(RegistrationController());

  final double storeBackgroundHeight = 200;
  final deliveryPersonController = Get.put(DeliveryPersonController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          GestureDetector(
            onTap: () {},
            child: const Icon(EvaIcons.close),
          ),
          gapW12
        ],
      ),
      body: Column(
        children: [
          // Controls the stepper orientation
          Padding(
            padding: hAppDefaultPaddingLR,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text(
                "Hoàn thiện đăng ký cửa hàng,",
                style: HAppStyle.heading3Style,
              ),
              gapH6,
              Text.rich(
                TextSpan(
                  text:
                      'Chú ý: Trong quá trình hoàn thiện thông tin khi hoàn thành xong thông tin và đăng ảnh thì sẽ không thể hoàn tác.',
                  style: HAppStyle.paragraph2Regular
                      .copyWith(color: HAppColor.hGreyColorShade600),
                  children: const [],
                ),
              ),
            ]),
          ),
          Expanded(
            child: Obx(() => Stepper(
                  type: StepperType.vertical,
                  physics: const ScrollPhysics(),
                  // onStepTapped: (step) {
                  //   registrationController.currentStep.value = step;
                  // },
                  onStepCancel: () {
                    if (registrationController.currentStep.value < 2) {
                      registrationController.currentStep.value -= 1;
                    }
                  },
                  connectorColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) =>
                          HAppColor.hBluePrimaryColor),
                  currentStep: registrationController.currentStep.value,
                  controlsBuilder: (context, details) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (registrationController.currentStep.value ==
                                  0) {
                                registrationController.saveInfo();
                              } else if (registrationController
                                      .currentStep.value ==
                                  1) {
                                registrationController.saveImage();
                              } else {
                                registrationController.checkActiveAccount();
                              }
                            },
                            child: Container(
                              padding:
                                  const EdgeInsets.fromLTRB(20, 10, 20, 10),
                              height: 40,
                              decoration: BoxDecoration(
                                  color: HAppColor.hBluePrimaryColor,
                                  borderRadius: BorderRadius.circular(10)),
                              child: Text(
                                registrationController.currentStep.value > 1
                                    ? 'Kiểm tra trạng thái'
                                    : 'Tiếp tục',
                                style: HAppStyle.paragraph2Bold
                                    .copyWith(color: HAppColor.hWhiteColor),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  steps: [
                    Step(
                      title:
                          const Text('Điền thông tin và đăng/sửa ảnh cá nhân'),
                      content: Form(
                        key: registrationController.addInfomationFormKey,
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                Container(
                                  height: 140,
                                  width: 140,
                                  decoration: BoxDecoration(
                                    color: HAppColor.hGreyColorShade300,
                                    border: Border.all(
                                        width: 4, color: HAppColor.hWhiteColor),
                                    boxShadow: [
                                      BoxShadow(
                                          spreadRadius: 2,
                                          blurRadius: 10,
                                          color: HAppColor.hDarkColor
                                              .withOpacity(0.1))
                                    ],
                                    shape: BoxShape.circle,
                                  ),
                                  child: Obx(() => deliveryPersonController
                                              .user.value.image !=
                                          ''
                                      ? deliveryPersonController
                                                  .isLoading.value ||
                                              deliveryPersonController
                                                  .isUploadImageLoading.value
                                          ? const CustomShimmerWidget.circular(
                                              height: 140,
                                              width: 140,
                                            )
                                          : ClipOval(
                                              child: Image.network(
                                                deliveryPersonController
                                                    .user.value.image,
                                                height: 140,
                                                width: 140,
                                              ),
                                            )
                                      : Container()),
                                ),
                                Positioned(
                                    right: 10,
                                    bottom: 10,
                                    child: GestureDetector(
                                      onTap: () => deliveryPersonController
                                          .uploadDeliveryPersonImage(),
                                      child: Container(
                                        padding: const EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          color: HAppColor.hBluePrimaryColor,
                                          border: Border.all(
                                              width: 2,
                                              color: HAppColor.hWhiteColor),
                                          boxShadow: [
                                            BoxShadow(
                                                spreadRadius: 2,
                                                blurRadius: 10,
                                                color: HAppColor.hDarkColor
                                                    .withOpacity(0.1))
                                          ],
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          EvaIcons.camera,
                                          size: 15,
                                          color: HAppColor.hWhiteColor,
                                        ),
                                      ),
                                    ))
                              ],
                            ),
                            gapH12,
                            TextFormField(
                              keyboardType: TextInputType.number,
                              enableSuggestions: true,
                              autocorrect: true,
                              controller: registrationController
                                  .drivingLicenseNumberController,
                              validator: (value) =>
                                  HAppUtils.validateEmptyField(
                                      'Số giấy phép lái xe', value),
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: HAppColor.hGreyColorShade300,
                                        width: 1),
                                    borderRadius: BorderRadius.circular(10)),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: HAppColor.hGreyColorShade300,
                                        width: 1),
                                    borderRadius: BorderRadius.circular(10)),
                                hintText: 'Nhập số giấy phép lái xe',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            gapH12,
                            TextFormField(
                              keyboardType: TextInputType.text,
                              enableSuggestions: true,
                              autocorrect: true,
                              controller: registrationController
                                  .vehicleRegistrationNumberController,
                              validator: (value) =>
                                  HAppUtils.validateEmptyField(
                                      'Số đăng ký xe', value),
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: HAppColor.hGreyColorShade300,
                                        width: 1),
                                    borderRadius: BorderRadius.circular(10)),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: HAppColor.hGreyColorShade300,
                                        width: 1),
                                    borderRadius: BorderRadius.circular(10)),
                                hintText: 'Nhập số đăng ký xe của bạn',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      isActive: registrationController.currentStep.value >= 0,
                      state: registrationController.currentStep.value >= 0
                          ? StepState.complete
                          : StepState.disabled,
                    ),
                    Step(
                      title: const Text(
                          'Đăng tải ảnh giấp phép lái xe và số đăng ký xe'),
                      content: Column(
                        children: [
                          Stack(
                            children: [
                              Container(
                                  height: storeBackgroundHeight,
                                  width: HAppSize.deviceWidth,
                                  decoration: BoxDecoration(
                                      color: HAppColor.hGreyColorShade300,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Stack(
                                    children: [
                                      Obx(
                                        () => Container(
                                          decoration: BoxDecoration(
                                              color:
                                                  HAppColor.hGreyColorShade300,
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          child: deliveryPersonController
                                                      .user
                                                      .value
                                                      .drivingLicenseNumberImage !=
                                                  ''
                                              ? deliveryPersonController
                                                          .isLoading.value ||
                                                      deliveryPersonController
                                                          .isUploadImageLoading
                                                          .value
                                                  ? CustomShimmerWidget
                                                      .rectangular(
                                                      height:
                                                          storeBackgroundHeight,
                                                    )
                                                  : ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
                                                      child: Image.network(
                                                        deliveryPersonController
                                                            .user
                                                            .value
                                                            .drivingLicenseNumberImage!,
                                                        height:
                                                            storeBackgroundHeight,
                                                        width: HAppSize
                                                            .deviceWidth,
                                                        fit: BoxFit.cover,
                                                      ))
                                              : Container(),
                                        ),
                                      ),
                                    ],
                                  )),
                              Positioned(
                                  right: 10,
                                  bottom: 10,
                                  child: GestureDetector(
                                    onTap: () => deliveryPersonController
                                        .uploadDriverImage(),
                                    child: Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        color: HAppColor.hBluePrimaryColor,
                                        border: Border.all(
                                            width: 2,
                                            color: HAppColor.hWhiteColor),
                                        boxShadow: [
                                          BoxShadow(
                                              spreadRadius: 2,
                                              blurRadius: 10,
                                              color: HAppColor.hDarkColor
                                                  .withOpacity(0.1))
                                        ],
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        EvaIcons.camera,
                                        size: 15,
                                        color: HAppColor.hWhiteColor,
                                      ),
                                    ),
                                  ))
                            ],
                          ),
                          gapH12,
                          Stack(
                            children: [
                              Container(
                                  height: storeBackgroundHeight,
                                  width: HAppSize.deviceWidth,
                                  decoration: BoxDecoration(
                                      color: HAppColor.hGreyColorShade300,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Stack(
                                    children: [
                                      Obx(
                                        () => Container(
                                          decoration: BoxDecoration(
                                              color:
                                                  HAppColor.hGreyColorShade300,
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          child: deliveryPersonController
                                                      .user
                                                      .value
                                                      .vehicleRegistrationNumberImage !=
                                                  ''
                                              ? deliveryPersonController
                                                          .isLoading.value ||
                                                      deliveryPersonController
                                                          .isUploadImageLoading
                                                          .value
                                                  ? CustomShimmerWidget
                                                      .rectangular(
                                                      height:
                                                          storeBackgroundHeight,
                                                    )
                                                  : ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
                                                      child: Image.network(
                                                        deliveryPersonController
                                                            .user
                                                            .value
                                                            .vehicleRegistrationNumberImage!,
                                                        height:
                                                            storeBackgroundHeight,
                                                        width: HAppSize
                                                            .deviceWidth,
                                                        fit: BoxFit.cover,
                                                      ))
                                              : Container(),
                                        ),
                                      ),
                                    ],
                                  )),
                              Positioned(
                                  right: 10,
                                  bottom: 10,
                                  child: GestureDetector(
                                    onTap: () => deliveryPersonController
                                        .uploadVehicleImage(),
                                    child: Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        color: HAppColor.hBluePrimaryColor,
                                        border: Border.all(
                                            width: 2,
                                            color: HAppColor.hWhiteColor),
                                        boxShadow: [
                                          BoxShadow(
                                              spreadRadius: 2,
                                              blurRadius: 10,
                                              color: HAppColor.hDarkColor
                                                  .withOpacity(0.1))
                                        ],
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        EvaIcons.camera,
                                        size: 15,
                                        color: HAppColor.hWhiteColor,
                                      ),
                                    ),
                                  ))
                            ],
                          ),
                        ],
                      ),
                      isActive: registrationController.currentStep.value >= 0,
                      state: registrationController.currentStep.value >= 1
                          ? StepState.complete
                          : StepState.disabled,
                    ),
                    Step(
                      title: const Text('Chờ xác nhận'),
                      content: Column(
                        children: <Widget>[
                          Text(
                            'Thông tin của bạn đã được gửi, chúng tôi sẽ xem xét sớm nhất để kích hoạt tài khoản cho bạn',
                            style: HAppStyle.paragraph2Regular
                                .copyWith(color: HAppColor.hGreyColorShade600),
                          ),
                        ],
                      ),
                      isActive: registrationController.currentStep.value >= 0,
                      state: registrationController.currentStep.value >= 2
                          ? StepState.complete
                          : StepState.disabled,
                    ),
                  ],
                )),
          ),
        ],
      ),
    );
  }
}
