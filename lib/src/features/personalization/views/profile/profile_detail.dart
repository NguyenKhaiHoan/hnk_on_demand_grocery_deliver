import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_network/image_network.dart';
import 'package:on_demand_grocery_deliver/src/common_widgets/custom_shimmer_widget.dart';
import 'package:on_demand_grocery_deliver/src/constants/app_colors.dart';
import 'package:on_demand_grocery_deliver/src/constants/app_sizes.dart';
import 'package:on_demand_grocery_deliver/src/features/personalization/controllers/change_name_controller.dart';
import 'package:on_demand_grocery_deliver/src/features/personalization/controllers/change_phone_controller.dart';
import 'package:on_demand_grocery_deliver/src/features/personalization/controllers/user_controller.dart';
import 'package:on_demand_grocery_deliver/src/features/personalization/views/profile/widgets/section_profile.dart';
import 'package:on_demand_grocery_deliver/src/routes/app_pages.dart';

class ProfileDetailScreen extends StatefulWidget {
  const ProfileDetailScreen({super.key});

  @override
  State<ProfileDetailScreen> createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends State<ProfileDetailScreen> {
  final userController = UserController.instance;
  final changeNameController = ChangeNameController.instance;
  var changePhoneController = Get.put(ChangePhoneController());

  final double storeBackgroundHeight = 200;
  final double storeImageHeight = 140;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        leading: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: hAppDefaultPadding),
            child: GestureDetector(
                onTap: () {
                  Get.back();
                },
                child: const Icon(
                  Icons.arrow_back_ios,
                  size: 20,
                )),
          ),
        ),
        title: const Text("Hồ sơ"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: hAppDefaultPaddingLR,
        child: Column(children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                  padding: EdgeInsets.only(bottom: storeImageHeight / 2),
                  height: storeBackgroundHeight,
                  width: HAppSize.deviceWidth,
                  color: HAppColor.hGreyColorShade300,
                  child: Stack(
                    children: [
                      Obx(
                        () =>
                            userController.user.value.storeImageBackground != ''
                                ? ImageNetwork(
                                    image: userController.user.value.storeImage,
                                    height: storeBackgroundHeight,
                                    width: HAppSize.deviceWidth,
                                    duration: 500,
                                    curve: Curves.easeIn,
                                    onPointer: true,
                                    debugPrint: false,
                                    fullScreen: false,
                                    fitAndroidIos: BoxFit.cover,
                                    fitWeb: BoxFitWeb.cover,
                                    borderRadius: BorderRadius.circular(100),
                                    onLoading: CustomShimmerWidget.circular(
                                        width: storeImageHeight,
                                        height: storeImageHeight),
                                    onError: const Icon(
                                      Icons.error,
                                      color: Colors.red,
                                    ),
                                  )
                                : Container(),
                      ),
                      Positioned(
                          right: 10,
                          bottom: 10,
                          child: GestureDetector(
                            onTap: () =>
                                userController.uploadStoreImageBackground(),
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: HAppColor.hBluePrimaryColor,
                                border: Border.all(
                                    width: 2, color: HAppColor.hWhiteColor),
                                boxShadow: [
                                  BoxShadow(
                                      spreadRadius: 2,
                                      blurRadius: 10,
                                      color:
                                          HAppColor.hDarkColor.withOpacity(0.1))
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
                  )),
              Positioned(
                  top: storeBackgroundHeight - storeImageHeight / 2,
                  child: Stack(
                    children: [
                      Container(
                        height: storeImageHeight,
                        width: storeImageHeight,
                        decoration: BoxDecoration(
                          color: HAppColor.hGreyColorShade300,
                          border: Border.all(
                              width: 4, color: HAppColor.hWhiteColor),
                          boxShadow: [
                            BoxShadow(
                                spreadRadius: 2,
                                blurRadius: 10,
                                color: HAppColor.hDarkColor.withOpacity(0.1))
                          ],
                          shape: BoxShape.circle,
                        ),
                        child:
                            Obx(() => userController.user.value.storeImage != ''
                                ? ImageNetwork(
                                    image: userController.user.value.storeImage,
                                    height: storeImageHeight,
                                    width: storeImageHeight,
                                    duration: 500,
                                    curve: Curves.easeIn,
                                    onPointer: true,
                                    debugPrint: false,
                                    fullScreen: false,
                                    fitAndroidIos: BoxFit.cover,
                                    fitWeb: BoxFitWeb.cover,
                                    borderRadius: BorderRadius.circular(100),
                                    onLoading: CustomShimmerWidget.circular(
                                        width: storeImageHeight,
                                        height: storeImageHeight),
                                    onError: const Icon(
                                      Icons.error,
                                      color: Colors.red,
                                    ),
                                  )
                                : Container()),
                      ),
                      Positioned(
                          right: 0,
                          bottom: 0,
                          child: GestureDetector(
                            onTap: () => userController.uploadStoreImage(),
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: HAppColor.hBluePrimaryColor,
                                border: Border.all(
                                    width: 2, color: HAppColor.hWhiteColor),
                                boxShadow: [
                                  BoxShadow(
                                      spreadRadius: 2,
                                      blurRadius: 10,
                                      color:
                                          HAppColor.hDarkColor.withOpacity(0.1))
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
                  )),
            ],
          ),
          gapH24,
          Container(
            padding: const EdgeInsets.all(hAppDefaultPadding),
            width: HAppSize.deviceWidth,
            decoration: BoxDecoration(
                color: HAppColor.hWhiteColor,
                borderRadius: BorderRadius.circular(10)),
            child: Column(
              children: [
                Obx(() => SectionProfileWidget(
                      title: 'Tên',
                      showIcon: true,
                      function: () {
                        Get.toNamed(HAppRoutes.changeName);
                      },
                      title2: userController.user.value.name,
                      isSubLoading: changeNameController.isLoading.value,
                    )),
                gapH6,
                Divider(
                  color: HAppColor.hGreyColorShade300,
                ),
                gapH6,
                SectionProfileWidget(
                  title: 'Id',
                  showIcon: true,
                  title2: userController.user.value.id,
                  isSubLoading: false,
                ),
                gapH6,
                Divider(
                  color: HAppColor.hGreyColorShade300,
                ),
                gapH6,
                Obx(() => SectionProfileWidget(
                      title: 'Số điện thoại',
                      showIcon: true,
                      function: () {
                        Get.toNamed(HAppRoutes.changePhone);
                      },
                      title2: userController.user.value.phoneNumber,
                      isSubLoading: changePhoneController.isLoading.value,
                    )),
                gapH6,
                Divider(
                  color: HAppColor.hGreyColorShade300,
                ),
                gapH6,
                SectionProfileWidget(
                  title: 'Mô tả',
                  showIcon: true,
                  title2: userController.user.value.description,
                  isSubLoading: false,
                ),
                gapH6,
                Divider(
                  color: HAppColor.hGreyColorShade300,
                ),
                gapH6,
                SectionProfileWidget(
                  title: 'Email',
                  showIcon: false,
                  title2: userController.user.value.email,
                  isSubLoading: false,
                ),
                gapH6,
                Divider(
                  color: HAppColor.hGreyColorShade300,
                ),
                gapH6,
                SectionProfileWidget(
                  title: 'Ngày tạo',
                  showIcon: false,
                  title2: userController.user.value.creationDate,
                  isSubLoading: false,
                ),
              ],
            ),
          ),
          gapH12,
          Container(
            padding: const EdgeInsets.all(hAppDefaultPadding),
            width: HAppSize.deviceWidth,
            decoration: BoxDecoration(
                color: HAppColor.hWhiteColor,
                borderRadius: BorderRadius.circular(10)),
            child: Column(
              children: [
                SectionProfileWidget(
                  title: 'Hình thức đăng nhập',
                  showIcon: false,
                  title2: userController.user.value.authenticationBy,
                  isSubLoading: false,
                ),
                userController.user.value.authenticationBy == 'Email'
                    ? Column(
                        children: [
                          gapH6,
                          Divider(
                            color: HAppColor.hGreyColorShade300,
                          ),
                          gapH6,
                          SectionProfileWidget(
                            title: 'Đổi mật khẩu',
                            title2: '',
                            showIcon: true,
                            function: () {
                              Get.toNamed(HAppRoutes.changePassword);
                            },
                            isSubLoading: false,
                          )
                        ],
                      )
                    : Container(),
              ],
            ),
          ),
          gapH12,
          Container(
            padding: const EdgeInsets.all(hAppDefaultPadding),
            width: HAppSize.deviceWidth,
            decoration: BoxDecoration(
                color: HAppColor.hWhiteColor,
                borderRadius: BorderRadius.circular(10)),
            child: Column(
              children: [
                SectionProfileWidget(
                  title: 'Xóa tài khoản',
                  showIcon: true,
                  function: () {},
                  title2: '',
                  isSubLoading: false,
                ),
              ],
            ),
          )
        ]),
      ),
    );
  }
}
