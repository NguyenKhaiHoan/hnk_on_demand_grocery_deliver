import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:on_demand_grocery_deliver/src/features/personalization/models/address_model.dart';
import 'package:on_demand_grocery_deliver/src/repositories/authentication_repository.dart';

class AddressRepository extends GetxController {
  static AddressRepository get instance => Get.find();

  final _db = FirebaseFirestore.instance;

  Future<List<AddressModel>> getUserAddress() async {
    try {
      final userId = AuthenticationRepository.instance.authUser!.uid;
      if (userId.isEmpty) throw 'Không có thông tin người dùng';
      final addresses = await _db
          .collection('Stores')
          .doc(userId)
          .collection('Addresses')
          .get();

      return addresses.docs
          .map((snapshot) => AddressModel.fromDocumentSnapshot(snapshot))
          .toList();
    } catch (e) {
      throw 'Đã xảy ra sự cố. Xin vui lòng thử lại sau.';
    }
  }

  Future<void> updateAddressField(
      String addressId, Map<String, dynamic> json) async {
    try {
      final userId = AuthenticationRepository.instance.authUser!.uid;
      await _db
          .collection('Stores')
          .doc(userId)
          .collection('Addresses')
          .doc(addressId)
          .update(json);
    } catch (e) {
      throw 'Đã xảy ra sự cố. Không thể cập nhật lựa chọn địa chỉ của bạn. Vui lòng thử lại sau.';
    }
  }

  Future<String> addAndFindIdForNewAddress(AddressModel address) async {
    try {
      final userId = AuthenticationRepository.instance.authUser?.uid;
      final currentAddress = await _db
          .collection('Stores')
          .doc(userId)
          .collection('Addresses')
          .add(address.toJon());
      return currentAddress.id;
    } catch (e) {
      throw 'Đã xảy ra sự cố. Xin vui lòng thử lại sau.';
    }
  }
}
