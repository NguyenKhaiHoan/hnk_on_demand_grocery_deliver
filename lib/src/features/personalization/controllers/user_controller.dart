import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:on_demand_grocery_deliver/src/exceptions/firebase_exception.dart';
import 'package:on_demand_grocery_deliver/src/features/authentication/controller/network_controller.dart';
import 'package:on_demand_grocery_deliver/src/features/personalization/controllers/address_controller.dart';
import 'package:on_demand_grocery_deliver/src/features/personalization/models/user_model.dart';
import 'package:on_demand_grocery_deliver/src/repositories/authentication_repository.dart';
import 'package:on_demand_grocery_deliver/src/repositories/user_repository.dart';
import 'package:on_demand_grocery_deliver/src/utils/utils.dart';

class UserController extends GetxController {
  static UserController get instance => Get.find();

  final userRepository = Get.put(UserRepository());
  final addressController = Get.put(AddressController());
  final authenticationRepository = Get.put(AuthenticationRepository());

  var user = UserModel.empty().obs;
  var isLoading = false.obs;
  var isUploadImageLoading = false.obs;
  var isUploadImageBackgroundLoading = false.obs;
  var streetAddress = ''.obs;
  var districtAddress = ''.obs;
  var cityAddress = ''.obs;
  var deliveryAddress = ''.obs;
  var currentPosition = Position(
          longitude: 0.0,
          latitude: 0.0,
          timestamp: DateTime.now(),
          accuracy: 0.0,
          altitude: 0.0,
          altitudeAccuracy: 0.0,
          heading: 0.0,
          headingAccuracy: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0)
      .obs;
  var isSetAddressDeliveryTo = false.obs;

  Future<void> saveUserRecord(
      UserCredential? userCredential, String authenticationBy) async {
    try {
      await fetchUserRecord();
      if (user.value.id.isEmpty) {
        if (userCredential != null) {
          final user = UserModel(
              id: userCredential.user!.uid,
              name: userCredential.user!.displayName ?? '',
              email: userCredential.user!.email ?? '',
              phoneNumber: userCredential.user!.phoneNumber ?? '',
              storeImage: userCredential.user!.photoURL ?? '',
              storeImageBackground: '',
              description: '',
              creationDate:
                  DateFormat('EEEE, d-M-y', 'vi').format(DateTime.now()),
              authenticationBy: authenticationBy);

          await userRepository.saveUserRecord(user);
        }
      }
    } on FirebaseException catch (e) {
      throw HFirebaseException(code: e.code).message;
    } catch (e) {
      isLoading.value = false;
      throw 'Đã xảy ra sự cố. Xin vui lòng thử lại sau.';
    }
  }

  Future<void> fetchUserRecord() async {
    try {
      isLoading.value = true;
      final user = await userRepository.getUserInformation();
      this.user(user);
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      HAppUtils.showSnackBarError('Lỗi', 'Không tìm thấy dữ liệu của cửa hàng');
      user(UserModel.empty());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadingUserRecord() async {
    try {
      HAppUtils.loadingOverlays();

      final isConnected = await NetworkController.instance.isConnected();
      if (!isConnected) {
        HAppUtils.stopLoading();
        return;
      }

      final user = await userRepository.getUserInformation();
      this.user(user);
      HAppUtils.stopLoading();
    } catch (e) {
      HAppUtils.showSnackBarError('Lỗi', 'Không tìm thấy dữ liệu của cửa hàng');
      user(UserModel.empty());
    } finally {
      HAppUtils.stopLoading();
    }
  }

  void uploadStoreImage() async {
    try {
      final image = await ImagePicker().pickImage(
          source: ImageSource.gallery,
          imageQuality: 70,
          maxHeight: 512,
          maxWidth: 512);
      if (image != null) {
        isUploadImageLoading.value = true;
        final imageUrl = await userRepository.uploadImage(
            'Stores/${user.value.id}/Images/Profile', image);
        Map<String, dynamic> json = {'StoreImage': imageUrl};
        await userRepository.updateSingleField(json);

        user.value.storeImage = imageUrl;
        user.refresh();

        isUploadImageLoading.value = false;
      }
    } catch (e) {
      isUploadImageLoading.value = false;
      HAppUtils.showSnackBarError('Lỗi', e.toString());
    }
  }

  void uploadStoreImageBackground() async {
    try {
      final image = await ImagePicker().pickImage(
          source: ImageSource.gallery,
          imageQuality: 70,
          maxHeight: 512,
          maxWidth: 512);
      if (image != null) {
        isUploadImageBackgroundLoading.value = true;
        final imageUrl = await userRepository.uploadImage(
            'Stores/${user.value.id}/Images/Profile', image);
        Map<String, dynamic> json = {'StoreImageBackground': imageUrl};
        await userRepository.updateSingleField(json);

        user.value.storeImageBackground = imageUrl;
        user.refresh();

        isUploadImageBackgroundLoading.value = false;
      }
    } catch (e) {
      isUploadImageBackgroundLoading.value = false;
      HAppUtils.showSnackBarError('Lỗi', e.toString());
    }
  }
}
