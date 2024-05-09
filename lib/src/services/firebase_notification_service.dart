import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:ffi';

import 'package:firebase_database/firebase_database.dart';
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
import 'package:on_demand_grocery_deliver/src/features/shop/models/notification_model.dart';
import 'package:on_demand_grocery_deliver/src/features/shop/models/order_model.dart';
import 'package:on_demand_grocery_deliver/src/repositories/delivery_person_repository.dart';
import 'package:on_demand_grocery_deliver/src/repositories/notification_repository.dart';
import 'package:on_demand_grocery_deliver/src/routes/app_pages.dart';
import 'package:on_demand_grocery_deliver/src/utils/theme/app_style.dart';
import 'package:on_demand_grocery_deliver/src/utils/utils.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class HNotificationService {
  static String? fcmToken;

  static final HNotificationService _instance =
      HNotificationService._internal();

  factory HNotificationService() => _instance;
  final orderController = Get.put(OrderController());

  HNotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  final deliveryPersonRepository = Get.put(DeliveryPersonRepository());
  final mapController = Get.put(MapController());

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

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      debugPrint('Got a message whilst in the foreground!');
      debugPrint('Message data: ${message.notification!.title.toString()}');

      if (message.notification != null) {
        if (message.notification!.title != null &&
            message.notification!.body != null) {
          final notificationData = message.data;
          if (mapController.deliveryProcess.value.activeOrderId == null ||
              mapController.deliveryProcess.value.activeOrderId == '') {
            if (MapController.instance.deliveryProcess.value.activeOrderId !=
                    null &&
                MapController.instance.deliveryProcess.value.activeOrderId !=
                    '') {
              final String orderId = notificationData['orderId'];
              await FirebaseDatabase.instance
                  .ref()
                  .child('Orders/$orderId')
                  .once()
                  .then((value) {
                OrderModel orderData = OrderModel.fromJson(
                    jsonDecode(jsonEncode(value.snapshot.value)));

                final String storeId = notificationData['storeId'];
                orderController.nearbyStoreId.value = storeId;

                if (!orderController.listOrder.contains(orderData)) {
                  orderController.listOrder.addIf(
                      !orderController.listOrder.contains(orderData),
                      orderData);
                  if (orderData.orderType == 'uu_tien') {
                    final List<int> listNumberOfCart = [];
                    final List<int> listTotalPrice = [];
                    for (int i = 0; i < orderData.storeOrders.length; i++) {
                      int numberOfCart = 0;
                      int totalPrice = 0;
                      final productOrders = orderData.orderProducts
                          .where((element) =>
                              element.storeId ==
                              orderData.storeOrders[i].storeId)
                          .toList();
                      for (var product in productOrders) {
                        totalPrice += product.price! * product.quantity;
                        numberOfCart += product.quantity;
                      }
                      listNumberOfCart.add(numberOfCart);
                      listTotalPrice.add(totalPrice);
                    }
                    final List<String> listAddressStore =
                        orderData.storeOrders.map((e) => e.address).toList();
                    Get.toNamed(HAppRoutes.orderDetail, arguments: {
                      'orderId': orderData.oderId,
                      'listNumberOfCart': listNumberOfCart,
                      'listTotalPrice': listTotalPrice,
                      'listAddressStore': listAddressStore
                    });
                  }
                  HAppUtils.showSnackBarSuccess(message.notification!.title!,
                      message.notification!.body!);
                }
              });
            }
          }
        }
      }
    });

    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        _handleNotificationClick(context, message);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint(
          'onMessageOpenedApp: ${message.notification!.title.toString()}');
      _handleNotificationClick(context, message);
    });
  }

  void _handleNotificationClick(BuildContext context, RemoteMessage message) {
    final notificationData = message.data;

    if (notificationData.containsKey('screen')) {
      final screen = notificationData['screen'];
      Navigator.of(context).pushNamed(screen);
    }
  }

  static final notificationRepository = Get.put(NotificationRepository());

  static Future<void> sendNotificationToUser(
      String userFcmToken, String orderUserId) async {
    try {
      final deliveryPerson = DeliveryPersonController.instance.user.value;
      const postUrl = 'https://fcm.googleapis.com/fcm/send';

      String title = 'Đã tìm thấy người giao hàng!';
      String body = 'Người giao hàng đã nhận đơn và chuẩn bị giao hàng';

      final data = {
        "to": userFcmToken,
        "notification": {
          "title": title,
          "body": body,
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
          .then((value) async {
        print(value.body);
        var uuid = const Uuid();
        await notificationRepository.addNotification(
            NotificationModel(
                id: uuid.v1(),
                title: title,
                body: body,
                time: DateTime.now(),
                type: 'order'),
            orderUserId);
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

  static Future<void> sendNotificationToUserAllReceive(
      String userFcmToken, String userId, String orderId) async {
    try {
      const postUrl = 'https://fcm.googleapis.com/fcm/send';

      String title =
          'Đơn hàng #${orderId.substring(0, 4)}... đã được lấy đủ hàng';
      String body =
          'Người giao hàng đã lấy đủ hàng và chuẩn bị tới điểm giao hàng.';

      final data = {
        "to": userFcmToken,
        "notification": {
          "title": title,
          "body": body,
        },
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
          .then((value) async {
        var uuid = Uuid();
        await notificationRepository.addNotification(
            NotificationModel(
                id: uuid.v1(),
                title: title,
                body: body,
                time: DateTime.now(),
                type: 'order'),
            userId);
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

  static Future<void> sendNotificationToUserComplete(
      String userFcmToken, String userId, String orderId) async {
    try {
      final deliveryPerson = DeliveryPersonController.instance.user.value;
      const postUrl = 'https://fcm.googleapis.com/fcm/send';

      String title =
          'Đơn hàng với mã #${orderId.substring(0, 4)}... của bạn đã được giao đến!';
      String body =
          'Hãy kiểm tra hàng và thanh toán (nếu có) để hoàn tất quá trình giao hàng.';

      final data = {
        "to": userFcmToken,
        "notification": {
          "title": title,
          "body": body,
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
          .then((value) async {
        var uuid = Uuid();
        await notificationRepository.addNotification(
            NotificationModel(
                id: uuid.v1(),
                title: title,
                body: body,
                time: DateTime.now(),
                type: 'order'),
            userId);
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
