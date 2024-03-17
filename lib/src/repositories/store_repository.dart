import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:on_demand_grocery_deliver/src/exceptions/firebase_exception.dart';
import 'package:on_demand_grocery_deliver/src/features/shop/models/store_model.dart';

class StoreRepository extends GetxController {
  static StoreRepository get instance => Get.find();

  final _db = FirebaseFirestore.instance;

  Future<void> saveStoreRecord(StoreModel store) async {
    try {
      await _db.collection('Stores').doc(store.id).set(store.toJson());
    } on FirebaseException catch (e) {
      throw HFirebaseException(code: e.code).message;
    } catch (e) {
      throw 'Đã xảy ra sự cố. Xin vui lòng thử lại sau.';
    }
  }

  Future<StoreModel> getStoreInformation(String storeId) async {
    try {
      final documentSnapshot =
          await _db.collection('Stores').doc(storeId).get();
      if (documentSnapshot.exists) {
        return StoreModel.fromDocumentSnapshot(documentSnapshot);
      } else {
        return StoreModel.empty();
      }
    } on FirebaseException catch (e) {
      throw HFirebaseException(code: e.code).message;
    } catch (e) {
      throw 'Đã xảy ra sự cố. Xin vui lòng thử lại sau.';
    }
  }

  Future<void> updateStore(StoreModel store) async {
    try {
      await _db.collection('Stores').doc(store.id).update(store.toJson());
    } on FirebaseException catch (e) {
      throw HFirebaseException(code: e.code).message;
    } catch (e) {
      throw 'Đã xảy ra sự cố. Xin vui lòng thử lại sau.';
    }
  }

  Future<void> updateSingleField(
      String storeId, Map<String, dynamic> json) async {
    try {
      await _db.collection('Stores').doc(storeId).update(json);
    } on FirebaseException catch (e) {
      throw HFirebaseException(code: e.code).message;
    } catch (e) {
      throw 'Đã xảy ra sự cố. Xin vui lòng thử lại sau.';
    }
  }

  Future<void> removeStoreRecord(StoreModel store) async {
    try {
      await _db.collection('Stores').doc(store.id).delete();
    } on FirebaseException catch (e) {
      throw HFirebaseException(code: e.code).message;
    } catch (e) {
      throw 'Đã xảy ra sự cố. Xin vui lòng thử lại sau.';
    }
  }

  Future<String> uploadImage(String path, XFile image) async {
    try {
      final ref = FirebaseStorage.instance.ref(path).child(image.name);
      await ref.putFile(File(image.path));
      final url = await ref.getDownloadURL();
      return url;
    } on FirebaseException catch (e) {
      throw HFirebaseException(code: e.code).message;
    } catch (e) {
      throw 'Đã xảy ra sự cố. Xin vui lòng thử lại sau.';
    }
  }
}
