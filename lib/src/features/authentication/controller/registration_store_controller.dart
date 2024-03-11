import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:on_demand_grocery_deliver/src/features/authentication/controller/network_controller.dart';
import 'package:on_demand_grocery_deliver/src/features/personalization/controllers/address_controller.dart';
import 'package:on_demand_grocery_deliver/src/features/personalization/controllers/user_controller.dart';
import 'package:on_demand_grocery_deliver/src/features/personalization/models/address_model.dart';
import 'package:on_demand_grocery_deliver/src/repositories/address_repository.dart';
import 'package:on_demand_grocery_deliver/src/utils/utils.dart';

class RegistrationController extends GetxController {
  static RegistrationController get instance => Get.find();

  GlobalKey<FormState> addAddressFormKey = GlobalKey<FormState>();
  final streetController = TextEditingController();
  var city = ''.obs;
  var district = ''.obs;
  var ward = ''.obs;
  final addressRepository = Get.put(AddressRepository());
  final addressController = Get.put(AddressController());
  final userController = Get.put(UserController());

  Future<void> saveInfo() async {
    try {
      HAppUtils.loadingOverlays();

      final isConnected = await NetworkController.instance.isConnected();
      if (!isConnected) {
        HAppUtils.stopLoading();
        return;
      }

      if (userController.user.value.storeImage == '' ||
          userController.user.value.storeImageBackground == '') {
        HAppUtils.stopLoading();
        HAppUtils.showSnackBarWarning('Chọn ảnh',
            'Bạn chưa chọn đầy đủ ảnh. Hãy chọn đầy đủ ảnh đại diện và ảnh nền cho cửa hàng.');
        return;
      }

      if (!addAddressFormKey.currentState!.validate() ||
          city.value == '' ||
          district.value == '' ||
          ward.value == '') {
        HAppUtils.stopLoading();
        HAppUtils.showSnackBarWarning('Chọn địa chỉ',
            'Bạn chưa điền đầy đủ địa chỉ. Hãy chọn đầy đủ Thành phố, Quận/Huyện, Phường/Xã và Số nhà, đường, ngõ.');
        return;
      }

      final address = AddressModel(
        id: '',
        city: city.value,
        district: district.value,
        ward: ward.value,
        street: streetController.text.trim(),
        latitude: 0.0,
        longitude: 0.0,
      );

      final id = await addressRepository.addAndFindIdForNewAddress(address);
      address.id = id;

      addressController.currentAddress.value = address;
      resetFormAddAddress();

      Navigator.of(Get.context!).pop();
      Get.back();
    } catch (e) {
      HAppUtils.stopLoading();
      HAppUtils.showSnackBarError('Lỗi', 'Thêm địa chỉ không thành công');
    }
  }

  void resetFormAddAddress() {
    streetController.clear();
    city.value = '';
    district.value = '';
    ward.value = '';
    addAddressFormKey.currentState?.reset();
  }
}
