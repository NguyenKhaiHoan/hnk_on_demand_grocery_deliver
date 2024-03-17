import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:on_demand_grocery_deliver/src/exceptions/firebase_exception.dart';
import 'package:on_demand_grocery_deliver/src/features/personalization/models/delivery_person_model.dart';
import 'package:on_demand_grocery_deliver/src/repositories/authentication_repository.dart';

class DeliveryPersonRepository extends GetxController {
  static DeliveryPersonRepository get instance => Get.find();

  final _db = FirebaseFirestore.instance;

  Future<void> saveDeliveryPersonRecord(DeliveryPersonModel user) async {
    try {
      await _db.collection('DeliveryPersons').doc(user.id).set(user.toJson());
    } on FirebaseException catch (e) {
      throw HFirebaseException(code: e.code).message;
    } catch (e) {
      throw 'Đã xảy ra sự cố. Xin vui lòng thử lại sau.';
    }
  }

  Future<DeliveryPersonModel> getDeliveryPersonInformation() async {
    try {
      final documentSnapshot = await _db
          .collection('DeliveryPersons')
          .doc(AuthenticationRepository.instance.authUser?.uid)
          .get();
      if (documentSnapshot.exists) {
        return DeliveryPersonModel.fromDocumentSnapshot(documentSnapshot);
      } else {
        return DeliveryPersonModel.empty();
      }
    } on FirebaseException catch (e) {
      throw HFirebaseException(code: e.code).message;
    } catch (e) {
      throw 'Đã xảy ra sự cố. Xin vui lòng thử lại sau.';
    }
  }

  Future<void> updateDeliveryPerson(DeliveryPersonModel user) async {
    try {
      await _db
          .collection('DeliveryPersons')
          .doc(user.id)
          .update(user.toJson());
    } on FirebaseException catch (e) {
      throw HFirebaseException(code: e.code).message;
    } catch (e) {
      throw 'Đã xảy ra sự cố. Xin vui lòng thử lại sau.';
    }
  }

  Future<void> updateSingleField(Map<String, dynamic> json) async {
    try {
      await _db
          .collection('DeliveryPersons')
          .doc(AuthenticationRepository.instance.authUser?.uid)
          .update(json);
    } on FirebaseException catch (e) {
      throw HFirebaseException(code: e.code).message;
    } catch (e) {
      throw 'Đã xảy ra sự cố. Xin vui lòng thử lại sau.';
    }
  }

  Future<void> removeDeliveryPersonRecord(DeliveryPersonModel user) async {
    try {
      await _db.collection('DeliveryPersons').doc(user.id).delete();
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
