import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:on_demand_grocery_deliver/src/features/authentication/controller/network_controller.dart';
import 'package:on_demand_grocery_deliver/src/features/personalization/controllers/user_controller.dart';
import 'package:on_demand_grocery_deliver/src/features/shop/controllers/root_controller.dart';
import 'package:on_demand_grocery_deliver/src/repositories/delivery_person_repository.dart';
import 'package:on_demand_grocery_deliver/src/utils/utils.dart';

class ChangeNameController extends GetxController {
  static ChangeNameController get instance => Get.find();

  final TextEditingController nameController = TextEditingController();
  GlobalKey<FormState> changeNameFormKey = GlobalKey<FormState>();
  final deliveryController = DeliveryPersonController.instance;
  final deliveryPersonRepository = Get.put(DeliveryPersonRepository());
  final rootController = RootController.instance;
  var isLoading = false.obs;

  @override
  void onInit() {
    initNameField();
    super.onInit();
  }

  Future<void> initNameField() async {
    nameController.text = deliveryController.user.value.name!;
  }

  changeName() async {
    try {
      isLoading.value = true;
      HAppUtils.loadingOverlays();

      final isConnected = await NetworkController.instance.isConnected();
      if (!isConnected) {
        HAppUtils.stopLoading();
        return;
      }

      if (!changeNameFormKey.currentState!.validate()) {
        HAppUtils.stopLoading();
        return;
      }

      var name = {'Name': nameController.text.trim()};
      await deliveryPersonRepository.updateSingleField(name);

      deliveryController.user.value.name = nameController.text.trim();
      deliveryController.user.refresh();

      HAppUtils.stopLoading();
      HAppUtils.showSnackBarSuccess(
          'Thành công', 'Bạn đã thay đổi tên của cửa hàng thành công.');

      isLoading.value = false;
      resetFormChangeName();
      Navigator.of(Get.context!).pop();
    } catch (e) {
      isLoading.value = false;
      HAppUtils.stopLoading();
      HAppUtils.showSnackBarError('Lỗi', e.toString());
    }
  }

  void resetFormChangeName() {
    nameController.clear();
    changeNameFormKey.currentState?.reset();
  }
}
