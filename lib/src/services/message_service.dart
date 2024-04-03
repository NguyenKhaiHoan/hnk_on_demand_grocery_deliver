// import 'dart:developer';

// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:on_demand_grocery_deliver/src/features/shop/controllers/order_controller.dart';
// import 'package:on_demand_grocery_deliver/src/features/shop/models/order_model.dart';

// class MessagingService {
//   static String? fcmToken;

//   static final MessagingService _instance = MessagingService._internal();

//   final orderController = Get.put(OrderController());

//   factory MessagingService() => _instance;

//   MessagingService._internal();

//   final FirebaseMessaging _fcm = FirebaseMessaging.instance;

//   Future<void> init(BuildContext context) async {
//     NotificationSettings settings = await _fcm.requestPermission(
//       alert: true,
//       announcement: false,
//       badge: true,
//       carPlay: false,
//       criticalAlert: false,
//       provisional: false,
//       sound: true,
//     );

//     debugPrint(
//         'User granted notifications permission: ${settings.authorizationStatus}');

//     fcmToken = await _fcm.getToken();
//     log('fcmToken: $fcmToken');

//     FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       debugPrint('Got a message whilst in the foreground!');
//       debugPrint('Message data: ${message.notification!.title.toString()}');

//       if (message.notification != null) {
//         if (message.notification!.title != null &&
//             message.notification!.body != null) {
//           final notificationData = message.data;
//           final orderData = OrderModel.fromJson(notificationData['data']);
//           orderController.addOrder(orderData);
//         }
//       }
//     });

//     FirebaseMessaging.instance.getInitialMessage().then((message) {
//       if (message != null) {
//         _handleNotificationClick(context, message);
//       }
//     });

//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       debugPrint(
//           'onMessageOpenedApp: ${message.notification!.title.toString()}');
//       _handleNotificationClick(context, message);
//     });
//   }

//   void _handleNotificationClick(BuildContext context, RemoteMessage message) {
//     final notificationData = message.data;

//     if (notificationData.containsKey('screen')) {
//       final screen = notificationData['screen'];
//       Navigator.of(context).pushNamed(screen);
//     }
//   }
// }

// @pragma('vm:entry-point')
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   debugPrint('Handling a background message: ${message.notification!.title}');
// }
