import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class ProductRepository extends GetxController {
  static ProductRepository get instance => Get.find();

  final _db = FirebaseFirestore.instance;

  // Future<List<ProductModel>> getAllProducts() async {
  //   try {
  //     final snapshot = await _db.collection('Products').limit(10).get();
  //     final list = snapshot.docs
  //         .map((document) => ProductModel.fromDocumentSnapshot(document))
  //         .toList();
  //     return list;
  //   } on FirebaseException catch (e) {
  //     throw HFirebaseException(code: e.code).message;
  //   } catch (e) {
  //     throw 'Đã xảy ra sự cố. Xin vui lòng thử lại sau.';
  //   }
  // }

  // Future<void> uploadDummyData(List<ProductModel> products) async {
  //   try {
  //     final storage = Get.put(FirebaseStorageService());
  //     for (var product in products) {
  //       final image = await storage.getImageData(product.image);
  //       final url = await storage.uploadImageData(
  //           'Products/Images', image, product.image.toString());
  //       product.image = url;
  //       await _db.collection('Products').doc(product.id).set(product.toJson());
  //     }
  //   } on FirebaseException catch (e) {
  //     throw e.message!;
  //   }
  // }
}
