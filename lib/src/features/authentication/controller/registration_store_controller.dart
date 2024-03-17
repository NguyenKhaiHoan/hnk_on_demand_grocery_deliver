import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:on_demand_grocery_deliver/src/features/authentication/controller/network_controller.dart';
import 'package:on_demand_grocery_deliver/src/features/personalization/controllers/address_controller.dart';
import 'package:on_demand_grocery_deliver/src/features/personalization/controllers/user_controller.dart';
import 'package:on_demand_grocery_deliver/src/features/personalization/models/address_model.dart';
import 'package:on_demand_grocery_deliver/src/repositories/address_repository.dart';
import 'package:on_demand_grocery_deliver/src/repositories/delivery_person_repository.dart';
import 'package:on_demand_grocery_deliver/src/routes/app_pages.dart';
import 'package:on_demand_grocery_deliver/src/utils/utils.dart';

class RegistrationController extends GetxController {
  var currentStep = 0.obs;

  static RegistrationController get instance => Get.find();

  GlobalKey<FormState> addInfomationFormKey = GlobalKey<FormState>();
  final vehicleRegistrationNumberController = TextEditingController();
  final drivingLicenseNumberController = TextEditingController();
  final deliveryPersonController = Get.put(DeliveryPersonController());
  final deliveryPersonRepository = Get.put(DeliveryPersonRepository());

  Future<void> saveInfo() async {
    try {
      final isConnected = await NetworkController.instance.isConnected();
      if (!isConnected) {
        return;
      }

      if (!addInfomationFormKey.currentState!.validate()) {
        HAppUtils.showSnackBarWarning(
            'Điền đầy đủ thông tin', 'Bạn chưa điền đầy đủ thông tin');
        return;
      }

      if (deliveryPersonController.user.value.image == '') {
        HAppUtils.showSnackBarWarning(
            'Đăng ảnh cá nhân', 'Bạn chưa đăng ảnh cá nhân');
      }

      await deliveryPersonRepository.updateSingleField(
          {'DrivingLicenseNumber': drivingLicenseNumberController.text.trim()});
      await deliveryPersonRepository.updateSingleField({
        'VehicleRegistrationNumber':
            vehicleRegistrationNumberController.text.trim()
      });

      currentStep.value += 1;

      resetFormAddAddress();
    } catch (e) {
      HAppUtils.showSnackBarError('Lỗi', 'Thêm địa chỉ không thành công');
    }
  }

  void saveImage() {
    if ((deliveryPersonController.user.value.drivingLicenseNumberImage != '') ||
        (deliveryPersonController.user.value.vehicleRegistrationNumberImage !=
            '')) {
      currentStep.value += 1;
    }
    HAppUtils.showSnackBarWarning('Đăng tải đủ ảnh',
        'Bạn chưa đăng tải đầy đủ ảnh cần thiết cho thủ tục hoàn thiện thông tin');
  }

  void resetFormAddAddress() {
    drivingLicenseNumberController.clear();
    vehicleRegistrationNumberController.clear();
    addInfomationFormKey.currentState?.reset();
  }

  void checkActiveAccount() async {
    final deliveryPerson =
        await deliveryPersonRepository.getDeliveryPersonInformation();
    if (deliveryPerson.isActiveAccount) {
      Get.back();
    }
  }
}
