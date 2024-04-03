import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:on_demand_grocery_deliver/src/features/personalization/models/address_model.dart';
import 'package:on_demand_grocery_deliver/src/repositories/authentication_repository.dart';

class AddressRepository extends GetxController {
  static AddressRepository get instance => Get.find();

  final _db = FirebaseFirestore.instance;

  Future<List<AddressModel>> getUserAddress(String userId) async {
    try {
      final addresses = await _db
          .collection('Users')
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

  Future<List<AddressModel>> getStoreAddress(String storeId) async {
    try {
      final addresses = await _db
          .collection('Stores')
          .doc(storeId)
          .collection('Addresses')
          .get();

      return addresses.docs
          .map((snapshot) => AddressModel.fromDocumentSnapshot(snapshot))
          .toList();
    } catch (e) {
      throw 'Đã xảy ra sự cố. Xin vui lòng thử lại sau.';
    }
  }
}
