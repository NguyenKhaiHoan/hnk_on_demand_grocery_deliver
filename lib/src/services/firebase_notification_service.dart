import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:on_demand_grocery_deliver/src/repositories/delivery_person_repository.dart';

class HNotificationService {
  static final FirebaseMessaging _fbMessaging = FirebaseMessaging.instance;

  static Future initializeFirebaseCloudMessaging() async {
    await _fbMessaging.requestPermission();
    getToken();

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen(_firebaseMessagingForegroundHandler);
    _fbMessaging.subscribeToTopic('DeliveryPerson');
  }

  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {}
  static Future<void> _firebaseMessagingForegroundHandler(
      RemoteMessage message) async {}

  static Future getToken() async {
    String? token = await _fbMessaging.getToken();
    await DeliveryPersonRepository.instance
        .updateSingleField({'CloudMessagingToken': token});
  }
}
