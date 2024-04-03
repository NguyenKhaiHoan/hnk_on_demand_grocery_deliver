import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:ffi';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:on_demand_grocery_deliver/src/constants/app_colors.dart';
import 'package:on_demand_grocery_deliver/src/constants/app_key.dart';
import 'package:on_demand_grocery_deliver/src/constants/app_sizes.dart';
import 'package:on_demand_grocery_deliver/src/features/personalization/controllers/user_controller.dart';
import 'package:on_demand_grocery_deliver/src/features/personalization/models/delivery_person_model.dart';
import 'package:on_demand_grocery_deliver/src/features/shop/controllers/map_controller.dart';
import 'package:on_demand_grocery_deliver/src/features/shop/controllers/order_controller.dart';
import 'package:on_demand_grocery_deliver/src/features/shop/models/order_model.dart';
import 'package:on_demand_grocery_deliver/src/repositories/delivery_person_repository.dart';
import 'package:on_demand_grocery_deliver/src/utils/theme/app_style.dart';
import 'package:on_demand_grocery_deliver/src/utils/utils.dart';
import 'package:http/http.dart' as http;

class HNotificationService {
  static String? fcmToken;

  static final HNotificationService _instance =
      HNotificationService._internal();

  factory HNotificationService() => _instance;
  final orderController = Get.put(OrderController());

  HNotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  final deliveryPersonRepository = Get.put(DeliveryPersonRepository());

  Future<void> init(BuildContext context) async {
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    debugPrint(
        'User granted notifications permission: ${settings.authorizationStatus}');

    fcmToken = await _fcm.getToken();
    log('fcmToken: $fcmToken');
    await deliveryPersonRepository
        .updateSingleField({'CloudMessagingToken': fcmToken});

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      debugPrint('Message data: ${message.notification!.title.toString()}');

      if (message.notification != null) {
        if (message.notification!.title != null &&
            message.notification!.body != null) {
          final notificationData = message.data;
          if (MapController.instance.deliveryProcess.value.activeOrderId ==
                  null ||
              MapController.instance.deliveryProcess.value.activeOrderId ==
                  '') {
            OrderModel orderData =
                OrderModel.fromJson(json.decode(notificationData['order']));

            final String storeId = notificationData['storeId'];
            orderController.nearbyStoreId.value = storeId;

            if (!orderController.listOrder.contains(orderData)) {
              orderController.listOrder.addIf(
                  !orderController.listOrder.contains(orderData), orderData);
              HAppUtils.showSnackBarSuccess(
                  message.notification!.title!, message.notification!.body!);
            }
          }
        }
      }
    });

    // FirebaseMessaging.instance.getInitialMessage().then((message) {
    //   if (message != null) {
    //     _handleNotificationClick(context, message);
    //   }
    // });

    // FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    //   debugPrint(
    //       'onMessageOpenedApp: ${message.notification!.title.toString()}');
    //   _handleNotificationClick(context, message);
    // });
  }

  void _handleNotificationClick(BuildContext context, RemoteMessage message) {
    final notificationData = message.data;

    // if (notificationData.containsKey('screen')) {
    //   final screen = notificationData['screen'];
    //   Navigator.of(context).pushNamed(screen);
    // }
  }

  static sendNotificationToUser(String userFcmToken) async {
    try {
      final deliveryPerson = DeliveryPersonController.instance.user.value;
      const postUrl = 'https://fcm.googleapis.com/fcm/send';
      final data = {
        "to": userFcmToken,
        "notification": {
          "title": 'Đã tìm thấy người giao hàng!',
          "body": 'Người giao hàng đã nhận đơn và chuẩn bị giao hàng',
        },
        "data": {'deliveryPerson': deliveryPerson.toJson()}
      };

      final headers = {
        'content-type': 'application/json',
        'Authorization': 'key=${HAppKey.fcmKeyServer}'
      };

      await http
          .post(Uri.parse(postUrl),
              body: json.encode(data),
              encoding: Encoding.getByName('utf-8'),
              headers: headers)
          .then((value) {
        log('Đã gửi thông báo');
      }).timeout(const Duration(seconds: 60), onTimeout: () {
        log('Đã hết thời gian kết nối');
        throw TimeoutException('Đã hết thời gian kết nối');
      }).onError((error, stackTrace) {
        HAppUtils.showSnackBarError('Lỗi', error.toString());
        throw Exception(error);
      });
    } catch (e) {
      throw Exception(e);
    }
  }

  static sendNotificationToUserComplete(String userFcmToken) async {
    try {
      final deliveryPerson = DeliveryPersonController.instance.user.value;
      const postUrl = 'https://fcm.googleapis.com/fcm/send';
      final data = {
        "to": userFcmToken,
        "notification": {
          "title": 'Đơn hàng của bạn đã được giao đến!',
          "body":
              'Hãy kiểm tra hàng và thanh toán (nếu có) để hoàn tất quá trình giao hàng',
        },
        "data": {'deliveryPerson': deliveryPerson.toJson()}
      };

      final headers = {
        'content-type': 'application/json',
        'Authorization': 'key=${HAppKey.fcmKeyServer}'
      };

      await http
          .post(Uri.parse(postUrl),
              body: json.encode(data),
              encoding: Encoding.getByName('utf-8'),
              headers: headers)
          .then((value) {
        log('Đã gửi thông báo');
      }).timeout(const Duration(seconds: 60), onTimeout: () {
        log('Đã hết thời gian kết nối');
        throw TimeoutException('Đã hết thời gian kết nối');
      }).onError((error, stackTrace) {
        HAppUtils.showSnackBarError('Lỗi', error.toString());
        throw Exception(error);
      });
    } catch (e) {
      throw Exception(e);
    }
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Handling a background message: ${message.notification!.title}');
}
