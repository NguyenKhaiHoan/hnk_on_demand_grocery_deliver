import 'dart:convert';

import 'package:another_stepper/another_stepper.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:on_demand_grocery_deliver/src/constants/app_colors.dart';
import 'package:on_demand_grocery_deliver/src/features/personalization/controllers/user_controller.dart';
import 'package:on_demand_grocery_deliver/src/features/shop/controllers/map_controller.dart';
import 'package:on_demand_grocery_deliver/src/features/shop/controllers/timmer_controller.dart';
import 'package:on_demand_grocery_deliver/src/features/shop/models/order_model.dart';
import 'package:on_demand_grocery_deliver/src/features/shop/models/store_brief_model.dart';
import 'package:on_demand_grocery_deliver/src/features/shop/models/store_model.dart';
import 'package:on_demand_grocery_deliver/src/features/shop/models/store_order_model.dart';
import 'package:on_demand_grocery_deliver/src/features/shop/models/user_address_model.dart';
import 'package:on_demand_grocery_deliver/src/repositories/store_repository.dart';
import 'package:on_demand_grocery_deliver/src/services/firebase_notification_service.dart';
import 'package:on_demand_grocery_deliver/src/services/location_service.dart';
import 'package:on_demand_grocery_deliver/src/utils/utils.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderController extends GetxController {
  static OrderController get instance => Get.find();

  var listOrder = <OrderModel>[].obs;

  // var orderObs = OrderModel.empty().obs;

  addOrder(OrderModel order) {
    listOrder.addIf(!listOrder.contains(order), order);
  }

  removeOrderNotification(String id) {
    listOrder.removeWhere((element) => element.oderId == id);
  }

  final storeRepository = Get.put(StoreRepository());

  var acceptOrder = 0.obs;
  var checkProduct = 0.obs;

  List<StepperData> listStepData(int index) {
    final orderData = listOrder[index];
    List<StepperData> stepperData = [];
    // print('Địa chỉ ${orderData.orderUserAddress.toJson().toString()}');
    stepperData.addAll(orderData.storeOrders.map((e) {
      return StepperData(
          title: StepperText(
            "Lấy: ${e.name}",
          ),
          subtitle: StepperText(e.address),
          iconWidget: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
                color: HAppColor.hBluePrimaryColor,
                borderRadius: BorderRadius.all(Radius.circular(30))),
            child: const Center(
              child: Icon(Icons.storefront_outlined,
                  size: 14, color: HAppColor.hWhiteColor),
            ),
          ));
    }));
    stepperData.add(StepperData(
        title: StepperText(
            "Giao: ${HAppUtils.maskName(orderData.orderUser.name)}"),
        subtitle: StepperText(orderData.orderUserAddress.toString()),
        iconWidget: Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
              color: HAppColor.hBluePrimaryColor,
              borderRadius: BorderRadius.all(Radius.circular(30))),
          child: const Center(
            child: Icon(EvaIcons.homeOutline,
                size: 14, color: HAppColor.hWhiteColor),
          ),
        )));
    return stepperData;
  }

  var nearbyStoreId = ''.obs;

  Future<void> openGoogleMaps(
      UserAddressModel userAddress, OrderModel order) async {
    try {
      HAppUtils.loadingOverlaysAddress();
      Position currentPosition =
          await HLocationService.getGeoLocationPosition();
      String waypoints = '&waypoints=';
      List<StoreOrderModel> storeOrders = order.storeOrders;
      for (int i = 0; i < storeOrders.length; i++) {
        waypoints += '${storeOrders[i].latitude},${storeOrders[i].longitude}|';
      }

      if (waypoints.isNotEmpty) {
        waypoints.substring(0, waypoints.length - 1);
      }

      String urlString =
          'https://www.google.com/maps/dir/?api=1&origin=${currentPosition.latitude},${currentPosition.longitude}&destination=${userAddress.latitude},${userAddress.longitude}$waypoints&travelmode=driving&dir_action=navigate';
      print(urlString);
      final url = Uri.parse(
        urlString,
      );
      if (await canLaunchUrl(url)) {
        HAppUtils.stopLoading();
        await launchUrl(url, mode: LaunchMode.inAppBrowserView);
      } else {
        HAppUtils.stopLoading();
        HAppUtils.showSnackBarError("Lỗi", 'Không thể mở được Google Map');
        throw Exception('Could not launch $url');
      }
      print(urlString);
    } catch (e) {
      HAppUtils.showSnackBarError('Lỗi', 'Không tìm được vị trí');
    }
  }

  var checkQrListStore = <bool>[].obs;

  Future<void> processOrder(OrderModel order, String userFcmToken) async {
    try {
      if (acceptOrder.value == 0) {
        acceptOrder.value = 1;
        for (int i = 0; i < listOrder.length; i++) {
          final timerController =
              Get.find<TimerController>(tag: listOrder[i].oderId);
          timerController.stopTimmer();
          if (listOrder[i].oderId != order.oderId) {
            timerController.removeOrderAndDeleteController(listOrder[i].oderId);
          }
        }
        listOrder.clear();
        var ref = FirebaseDatabase.instance.ref("Orders/${order.oderId}");
        var ref2 = FirebaseDatabase.instance.ref(
            "DeliveryPersons/${DeliveryPersonController.instance.user.value.id}");

        await ref.update({
          "OrderStatus": HAppUtils.orderStatus(2),
          "DeliveryPerson":
              DeliveryPersonController.instance.user.value.toJson(),
          "DeliveryPersonId": DeliveryPersonController.instance.user.value.id
        }).then((value) async {
          await ref2.update({
            "ActiveOrderId": order.oderId,
          }).then((value) async {
            MapController.instance.deliveryProcess.value.activeOrderId =
                order.oderId;
            MapController.instance.deliveryProcess.refresh();

            await HNotificationService.sendNotificationToUser(
                userFcmToken, order.orderUserId);
          });
        });

        checkQrListStore.value =
            List<bool>.filled(order.storeOrders.length, false);
      } else if (acceptOrder.value == 1) {
        if (order.orderStatus == HAppUtils.orderStatus(2)) {
          bool checkAllProduct = true;
          for (int i = 0; i < order.storeOrders.length; i++) {
            if (order.storeOrders[i].isCheckFullProduct != 1) {
              checkAllProduct = false;
              HAppUtils.showSnackBarError("Chưa kiểm tra",
                  'Bạn chưa kiểm tra sản phẩm của cửa hàng: ${order.storeOrders[i].name}');
              return;
            }
          }
          if (checkAllProduct) {
            var ref = FirebaseDatabase.instance.ref("Orders/${order.oderId}");
            await ref.update({
              "OrderStatus": HAppUtils.orderStatus(3),
            }).then((value) async {
              await HNotificationService.sendNotificationToUserAllReceive(
                  userFcmToken, order.orderUserId, order.oderId);
            });
          }
        } else if (order.orderStatus == HAppUtils.orderStatus(3)) {
          Position currentPosition = await HAppUtils.getGeoLocationPosition();
          final distance = HAppUtils.calculateDistance(
              currentPosition.latitude,
              currentPosition.longitude,
              order.orderUserAddress.latitude,
              order.orderUserAddress.longitude);
          if (distance < 50) {
            var ref = FirebaseDatabase.instance.ref("Orders/${order.oderId}");
            await ref.update({
              "OrderStatus": HAppUtils.orderStatus(4),
            }).then((value) async {
              await HNotificationService.sendNotificationToUserComplete(
                      userFcmToken, order.orderUserId, order.oderId)
                  .then((value) async {
                await FirebaseDatabase.instance
                    .ref(
                        "DeliveryPersons/${DeliveryPersonController.instance.user.value.id}/ActiveOrderId")
                    .remove();
                MapController.instance.deliveryProcess.value.activeOrderId ??
                    '';
              });
            });
          } else {
            HAppUtils.showSnackBarWarning('Không đúng vị trí',
                'Có vẻ khoảng cách từ vị trí hiện tại của bạn với vị trí cửa khách hàng còn khá xa');
          }
        }
      }
    } catch (e) {
      HAppUtils.showSnackBarError('Lỗi', 'Đã xảy ra lối: ${e.toString()}');
    }
  }
}
