import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:on_demand_grocery_deliver/src/exceptions/firebase_exception.dart';
import 'package:on_demand_grocery_deliver/src/features/authentication/controller/network_controller.dart';
import 'package:on_demand_grocery_deliver/src/features/personalization/controllers/address_controller.dart';
import 'package:on_demand_grocery_deliver/src/features/personalization/models/delivery_person_model.dart';
import 'package:on_demand_grocery_deliver/src/repositories/authentication_repository.dart';
import 'package:on_demand_grocery_deliver/src/repositories/delivery_person_repository.dart';
import 'package:on_demand_grocery_deliver/src/utils/utils.dart';

class DeliveryPersonController extends GetxController {
  static DeliveryPersonController get instance => Get.find();

  final deliveryPersonRepository = Get.put(DeliveryPersonRepository());
  // final addressController = Get.put(AddressController());
  final authenticationRepository = Get.put(AuthenticationRepository());

  var user = DeliveryPersonModel.empty().obs;
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
          final user = DeliveryPersonModel(
              id: userCredential.user!.uid,
              name: userCredential.user!.displayName ?? '',
              email: userCredential.user!.email ?? '',
              phoneNumber: userCredential.user!.phoneNumber ?? '',
              image: userCredential.user!.photoURL ?? '',
              vehicleRegistrationNumber: '',
              drivingLicenseNumber: '',
              creationDate:
                  DateFormat('EEEE, d-M-y', 'vi').format(DateTime.now()),
              authenticationBy: authenticationBy,
              isActiveAccount: false,
              vehicleRegistrationNumberImage: '',
              drivingLicenseNumberImage: '',
              activeDeliveryRequestId: '',
              status: false,
              cloudMessagingToken: '');

          await deliveryPersonRepository.saveDeliveryPersonRecord(user);
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
      final user =
          await deliveryPersonRepository.getDeliveryPersonInformation();
      this.user(user);
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      HAppUtils.showSnackBarError('Lỗi', 'Không tìm thấy dữ liệu của cửa hàng');
      user(DeliveryPersonModel.empty());
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

      final user =
          await deliveryPersonRepository.getDeliveryPersonInformation();
      this.user(user);
      HAppUtils.stopLoading();
    } catch (e) {
      HAppUtils.showSnackBarError('Lỗi', 'Không tìm thấy dữ liệu của cửa hàng');
      user(DeliveryPersonModel.empty());
    } finally {
      HAppUtils.stopLoading();
    }
  }

  void uploadDeliveryPersonImage() async {
    try {
      final image = await ImagePicker().pickImage(
          source: ImageSource.gallery,
          imageQuality: 70,
          maxHeight: 512,
          maxWidth: 512);
      if (image != null) {
        isUploadImageLoading.value = true;
        final imageUrl = await deliveryPersonRepository.uploadImage(
            'DeliveryPersons/${user.value.id}/Images/Profile', image);
        Map<String, dynamic> json = {'Image': imageUrl};
        await deliveryPersonRepository.updateSingleField(json);

        user.value.image = imageUrl;
        user.refresh();

        isUploadImageLoading.value = false;
      }
    } catch (e) {
      isUploadImageLoading.value = false;
      HAppUtils.showSnackBarError('Lỗi', e.toString());
    }
  }

  void uploadDriverImage() async {
    try {
      final image = await ImagePicker().pickImage(
          source: ImageSource.gallery,
          imageQuality: 70,
          maxHeight: 512,
          maxWidth: 512);
      if (image != null) {
        isUploadImageLoading.value = true;
        final imageUrl = await deliveryPersonRepository.uploadImage(
            'DeliveryPersons/${user.value.id}/Images/Profile', image);
        Map<String, dynamic> json = {'DrivingLicenseNumberImage': imageUrl};
        await deliveryPersonRepository.updateSingleField(json);

        user.value.drivingLicenseNumberImage = imageUrl;
        user.refresh();

        isUploadImageLoading.value = false;
      }
    } catch (e) {
      isUploadImageLoading.value = false;
      HAppUtils.showSnackBarError('Lỗi', e.toString());
    }
  }

  void uploadVehicleImage() async {
    try {
      final image = await ImagePicker().pickImage(
          source: ImageSource.gallery,
          imageQuality: 70,
          maxHeight: 512,
          maxWidth: 512);
      if (image != null) {
        isUploadImageBackgroundLoading.value = true;
        final imageUrl = await deliveryPersonRepository.uploadImage(
            'DeliveryPersons/${user.value.id}/Images/Profile', image);
        Map<String, dynamic> json = {
          'VehicleRegistrationNumberImage': imageUrl
        };
        await deliveryPersonRepository.updateSingleField(json);

        user.value.vehicleRegistrationNumberImage = imageUrl;
        user.refresh();

        isUploadImageBackgroundLoading.value = false;
      }
    } catch (e) {
      isUploadImageBackgroundLoading.value = false;
      HAppUtils.showSnackBarError('Lỗi', e.toString());
    }
  }
}
