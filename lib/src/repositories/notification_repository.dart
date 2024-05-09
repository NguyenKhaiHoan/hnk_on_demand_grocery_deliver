import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:on_demand_grocery_deliver/src/features/shop/models/notification_model.dart';

class NotificationRepository extends GetxController {
  static NotificationRepository get instance => Get.find();

  final db = FirebaseFirestore.instance;

  Future<void> addNotification(
      NotificationModel notification, String userId) async {
    try {
      await db
          .collection('Notifications')
          .doc(userId)
          .collection('UserNotification')
          .add(notification.toJson());
    } catch (e) {
      throw 'Đã xảy ra sự cố. Không thể cập nhật được mã ưu đãi. Vui lòng thử lại sau.';
    }
  }
}
