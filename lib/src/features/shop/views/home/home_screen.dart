import 'dart:async';
import 'dart:convert';
import 'dart:ffi';

import 'package:another_stepper/another_stepper.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cool_card_swiper/widgets/cool_swiper.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:on_demand_grocery_deliver/src/common_widgets/user_image_logo.dart';
import 'package:on_demand_grocery_deliver/src/constants/app_colors.dart';
import 'package:on_demand_grocery_deliver/src/constants/app_sizes.dart';
import 'package:on_demand_grocery_deliver/src/features/personalization/controllers/user_controller.dart';
import 'package:on_demand_grocery_deliver/src/features/shop/controllers/initialize_location_controller.dart';
import 'package:on_demand_grocery_deliver/src/features/shop/controllers/map_controller.dart';
import 'package:on_demand_grocery_deliver/src/features/shop/controllers/order_controller.dart';
import 'package:on_demand_grocery_deliver/src/features/shop/controllers/timmer_controller.dart';
import 'package:on_demand_grocery_deliver/src/features/shop/models/delivery_location_model.dart';
import 'package:on_demand_grocery_deliver/src/features/shop/models/order_model.dart';
import 'package:on_demand_grocery_deliver/src/features/shop/models/product_in_cart_model.dart';
import 'package:on_demand_grocery_deliver/src/features/shop/views/home/widgets/order_notification_widget.dart';
import 'package:on_demand_grocery_deliver/src/features/shop/views/live_tracking_screen.dart/live_tracking_screen.dart';
import 'package:on_demand_grocery_deliver/src/routes/app_pages.dart';
import 'package:on_demand_grocery_deliver/src/services/location_service.dart';
import 'package:on_demand_grocery_deliver/src/utils/theme/app_style.dart';
import 'package:on_demand_grocery_deliver/src/utils/utils.dart';
import 'package:rounded_background_text/rounded_background_text.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Completer<GoogleMapController> googleMapController = Completer();
  // GoogleMapController? mapController;

  RxBool online = false.obs;

  final orderController = Get.put(OrderController());
  final mapOrderController = Get.put(MapController());

  final initializeLocationController = InitializeLocationController.instance;

  @override
  void initState() {
    super.initState();
    online.value = DeliveryPersonController.instance.user.value.status;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HAppColor.hBackgroundColor,
      appBar: AppBar(
        toolbarHeight: 80,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: hAppDefaultPaddingL,
          child: GestureDetector(
            onTap: () {
              if (ZoomDrawer.of(context)!.isOpen()) {
                ZoomDrawer.of(context)!.close();
              } else {
                ZoomDrawer.of(context)!.open();
              }
            },
            child: const Icon(
              EvaIcons.menu2Outline,
            ),
          ),
        ),
        actions: [
          Obx(() => online.value
              ? StreamBuilder(
                  stream: FirebaseDatabase.instance
                      .ref()
                      .child(
                          'DeliveryPersons/${DeliveryPersonController.instance.user.value.id}')
                      .onValue,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Container();
                    }
                    if (snapshot.hasError) {
                      return Container();
                    }

                    if (!snapshot.hasData ||
                        snapshot.data!.snapshot.value == null) {
                      return Padding(
                        padding: hAppDefaultPaddingR,
                        child: Switch(
                            trackOutlineColor:
                                MaterialStateProperty.resolveWith(
                              (final Set<MaterialState> states) {
                                if (states.contains(MaterialState.selected)) {
                                  return null;
                                }
                                return HAppColor.hGreyColorShade300;
                              },
                            ),
                            activeColor: HAppColor.hBluePrimaryColor,
                            activeTrackColor: HAppColor.hBlueSecondaryColor,
                            inactiveThumbColor: HAppColor.hWhiteColor,
                            inactiveTrackColor: HAppColor.hGreyColorShade300,
                            value: online.value,
                            onChanged: (changed) async {
                              online.value = changed;
                              HLocationService.checkStatus(online.value);
                            }),
                      ); // Hiển thị thông báo không có dữ liệu
                    }
                    mapOrderController.deliveryProcess.value =
                        DeliveryProcessModel.fromJson(jsonDecode(
                                jsonEncode(snapshot.data!.snapshot.value))
                            as Map<String, dynamic>);
                    mapOrderController.deliveryProcess.refresh();
                    if (online.value) {
                      HLocationService.updateLocationRealtime();
                    }
                    return Padding(
                      padding: hAppDefaultPaddingR,
                      child: Obx(() {
                        return Switch(
                            trackOutlineColor:
                                MaterialStateProperty.resolveWith(
                              (final Set<MaterialState> states) {
                                if (states.contains(MaterialState.selected)) {
                                  return null;
                                }
                                return HAppColor.hGreyColorShade300;
                              },
                            ),
                            activeColor: HAppColor.hBluePrimaryColor,
                            activeTrackColor: HAppColor.hBlueSecondaryColor,
                            inactiveThumbColor: HAppColor.hWhiteColor,
                            inactiveTrackColor: HAppColor.hGreyColorShade300,
                            value: online.value,
                            onChanged: (changed) async {
                              online.value = changed;
                              HLocationService.checkStatus(online.value);
                            });
                      }),
                    );
                  },
                )
              : Padding(
                  padding: hAppDefaultPaddingR,
                  child: Switch(
                      trackOutlineColor: MaterialStateProperty.resolveWith(
                        (final Set<MaterialState> states) {
                          if (states.contains(MaterialState.selected)) {
                            return null;
                          }
                          return HAppColor.hGreyColorShade300;
                        },
                      ),
                      activeColor: HAppColor.hBluePrimaryColor,
                      activeTrackColor: HAppColor.hBlueSecondaryColor,
                      inactiveThumbColor: HAppColor.hWhiteColor,
                      inactiveTrackColor: HAppColor.hGreyColorShade300,
                      value: online.value,
                      onChanged: (changed) async {
                        online.value = changed;
                        HLocationService.checkStatus(online.value);
                      }),
                ))
        ],
      ),
      body: Stack(children: [
        Padding(
          padding: hAppDefaultPaddingLR,
          child: FirebaseAnimatedList(
            sort: (a, b) {
              return ((b.value as Map)['OrderDate'] as int)
                  .compareTo(((a.value as Map)['OrderDate'] as int));
            },
            // physics: const NeverScrollableScrollPhysics(),
            // shrinkWrap: true,
            query: FirebaseDatabase.instance
                .ref()
                .child('Orders')
                .orderByChild('DeliveryPersonId')
                .equalTo(DeliveryPersonController.instance.user.value.id),
            itemBuilder: (context, snapshot, animation, index) {
              final orderData = snapshot.value as Map;
              if (orderData.isEmpty || orderData['DeliveryPerson'] == null) {
                return const Text('Không có đơn đang hoạt động bây giờ');
              } else {
                if (orderData['DeliveryPerson'] != null) {
                  final order = OrderModel.fromJson(
                      jsonDecode(jsonEncode(snapshot.value))
                          as Map<String, dynamic>);

                  int numberOfCart = 0;
                  for (var product in order.orderProducts) {
                    numberOfCart += product.quantity;
                  }
                  return GestureDetector(
                    onTap: () {
                      final List<int> listNumberOfCart = [];
                      final List<int> listTotalPrice = [];
                      for (int i = 0; i < order.storeOrders.length; i++) {
                        int numberOfCart = 0;
                        int totalPrice = 0;
                        final productOrders = order.orderProducts
                            .where((element) =>
                                element.storeId == order.storeOrders[i].storeId)
                            .toList();
                        for (var product in productOrders) {
                          totalPrice += product.price! * product.quantity;
                          numberOfCart += product.quantity;
                        }
                        listNumberOfCart.add(numberOfCart);
                        listTotalPrice.add(totalPrice);
                      }
                      final List<String> listAddressStore =
                          order.storeOrders.map((e) => e.address).toList();
                      Get.toNamed(HAppRoutes.orderDetail, arguments: {
                        'orderId': order.oderId,
                        'listNumberOfCart': listNumberOfCart,
                        'listTotalPrice': listTotalPrice,
                        'listAddressStore': listAddressStore
                      });
                    },
                    child: Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.only(
                            bottom: hAppDefaultPadding / 2),
                        decoration: BoxDecoration(
                            color: HAppColor.hWhiteColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                width: 1, color: HAppColor.hGreyColorShade300)),
                        child: Column(children: [
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  Text(
                                    '#${(order.oderId).substring(0, 6)}...',
                                    style: HAppStyle.label2Bold
                                        .copyWith(fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                  ),
                                  Container(
                                    padding:
                                        const EdgeInsets.fromLTRB(5, 5, 5, 5),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: order.orderType == 'uu_tien'
                                          ? HAppColor.hRedColor
                                          : order.orderType == 'tieu_chuan'
                                              ? HAppColor.hBluePrimaryColor
                                              : HAppColor.hOrangeColor,
                                    ),
                                    child: Text(
                                      order.orderType == 'uu_tien'
                                          ? 'Ưu tiên'
                                          : order.orderType == 'tieu_chuan'
                                              ? 'Tiêu chuẩn'
                                              : 'Đặt lịch',
                                      style: HAppStyle.paragraph3Regular
                                          .copyWith(
                                              color: HAppColor.hWhiteColor),
                                    ),
                                  ),
                                  const Spacer(),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(
                                        DateFormat('h:mm a')
                                            .format(order.orderDate!),
                                      ),
                                      Text(
                                        DateFormat('EEEE, d-M-y', 'vi')
                                            .format(order.orderDate!),
                                        style: HAppStyle.paragraph3Regular
                                            .copyWith(
                                                color: HAppColor
                                                    .hGreyColorShade600),
                                      ),
                                    ],
                                  ),
                                ]),
                              ]),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                  child: ProductListStackWidget(
                                maxItems: 6,
                                items: order.orderProducts,
                              )),
                              Text(
                                'Số lượng: $numberOfCart',
                                style: HAppStyle.paragraph2Bold.copyWith(
                                    color: HAppColor.hBluePrimaryColor),
                              ),
                            ],
                          )
                        ])),
                  );
                } else {
                  return Container();
                }
              }
            },
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Obx(() => orderController.listOrder.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.only(bottom: hAppDefaultPadding),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                        minWidth: HAppSize.deviceWidth,
                        minHeight: HAppSize.deviceHeight * 0.3,
                        maxWidth: HAppSize.deviceWidth,
                        maxHeight: HAppSize.deviceHeight * 0.8),
                    child: CoolSwiper(
                        children: List.generate(
                            orderController.listOrder.length, (index) {
                      List<StepperData> stepperData =
                          orderController.listStepData(index);
                      OrderModel order = orderController.listOrder[index];
                      return OrderNotificationWidget(
                        stepperData: stepperData,
                        order: order,
                      );
                    })),
                  ),
                )
              : Container()),
        ),
      ]),
    );
  }
}

class ProductListStackWidget extends StatelessWidget {
  const ProductListStackWidget({
    super.key,
    required this.items,
    this.maxItems = 5,
    this.stackHeight = 60,
  });

  final List<ProductInCartModel> items;
  final int maxItems;
  final double stackHeight;

  @override
  Widget build(BuildContext context) {
    bool checkMax = items.length < maxItems;
    return SizedBox(
        height: stackHeight,
        child: Stack(
          children: List.generate(
            checkMax ? items.length : maxItems,
            (index) => checkMax
                ? Align(
                    alignment: Alignment.centerLeft,
                    child: Transform.translate(
                      offset: Offset((index) * 40, 0),
                      child: ProductItemStack(model: items[index]),
                    ),
                  )
                : Align(
                    alignment: Alignment.centerLeft,
                    child: Transform.translate(
                      offset: Offset((index) * 40, 0),
                      child: index < maxItems - 1
                          ? ProductItemStack(model: items[index])
                          : Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: HAppColor.hBackgroundColor),
                              padding: const EdgeInsets.all(2),
                              child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                      child: Text(
                                    "+${(items.length - maxItems + 1)}",
                                    style: HAppStyle.paragraph2Regular,
                                  )))),
                    ),
                  ),
          ),
        ));
  }
}

class ProductItemStack extends StatelessWidget {
  ProductItemStack({
    super.key,
    required this.model,
    this.child,
  });

  ProductInCartModel model;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: 50,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: HAppColor.hGreyColorShade300),
      padding: const EdgeInsets.all(2),
      child: Container(
        alignment: Alignment.bottomLeft,
        // padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            image: DecorationImage(
                image: NetworkImage(model.image!), fit: BoxFit.fill)),
        child: RoundedBackgroundText(
          'x${model.quantity}',
          style: HAppStyle.paragraph3Bold.copyWith(
            color: HAppColor.hWhiteColor,
          ),
          backgroundColor: HAppColor.hBluePrimaryColor,
        ),
      ),
    );
  }
}
