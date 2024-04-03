import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:another_stepper/another_stepper.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swipe_button/flutter_swipe_button.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_network/image_network.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:on_demand_grocery_deliver/src/common_widgets/custom_shimmer_widget.dart';
import 'package:on_demand_grocery_deliver/src/constants/app_colors.dart';
import 'package:on_demand_grocery_deliver/src/constants/app_sizes.dart';
import 'package:on_demand_grocery_deliver/src/features/personalization/controllers/user_controller.dart';
import 'package:on_demand_grocery_deliver/src/features/shop/controllers/initialize_location_controller.dart';
import 'package:on_demand_grocery_deliver/src/features/shop/controllers/map_controller.dart';
import 'package:on_demand_grocery_deliver/src/features/shop/controllers/order_controller.dart';
import 'package:on_demand_grocery_deliver/src/features/shop/controllers/timmer_controller.dart';
import 'package:on_demand_grocery_deliver/src/features/shop/models/order_model.dart';
import 'package:on_demand_grocery_deliver/src/features/shop/models/product_in_cart_model.dart';
import 'package:on_demand_grocery_deliver/src/features/shop/models/store_order_model.dart';
import 'package:on_demand_grocery_deliver/src/features/shop/models/user_address_model.dart';
import 'package:on_demand_grocery_deliver/src/features/shop/views/order/chat_order.dart';
import 'package:on_demand_grocery_deliver/src/features/shop/views/order/show_all_product_in_store.dart';
import 'package:on_demand_grocery_deliver/src/utils/theme/app_style.dart';
import 'package:on_demand_grocery_deliver/src/utils/utils.dart';

class OrderDetailScreen extends StatelessWidget {
  OrderDetailScreen({
    super.key,
  });

  final orderController = Get.put(OrderController());
  final String orderId = Get.arguments['orderId'];

  @override
  Widget build(BuildContext context) {
    final timerController = Get.find<TimerController>(tag: orderId);
    timerController.isInOrderDetailScreen.value = true;
    orderController.acceptOrder.value = 0;
    return StreamBuilder(
      stream: FirebaseDatabase.instance.ref().child('Orders/$orderId').onValue,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child:
                CircularProgressIndicator(color: HAppColor.hBluePrimaryColor),
          );
        }
        if (snapshot.hasError) {
          return const Center(
            child: Text('Lỗi, không thể tải dữ liệu'),
          );
        }

        if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
          return const Center(
            child: Text('Lỗi, không có dữ liệu để hiển thị'),
          );
        }
        OrderModel order = OrderModel.fromJson(
            jsonDecode(jsonEncode(snapshot.data!.snapshot.value))
                as Map<String, dynamic>);

        if (order.deliveryPerson != null) {
          orderController.acceptOrder.value = 1;
        }
        return Scaffold(
            appBar: AppBar(
              toolbarHeight: 80,
              leading: GestureDetector(
                onTap: () => Get.back(),
                child: Padding(
                  padding: hAppDefaultPaddingL,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: HAppColor.hGreyColorShade300,
                          width: 1.5,
                        ),
                        color: HAppColor.hBackgroundColor),
                    child: const Center(
                      child: Icon(
                        EvaIcons.arrowBackOutline,
                      ),
                    ),
                  ),
                ),
              ),
              centerTitle: true,
              title: const Text('Chi tiết đơn hàng'),
              backgroundColor: HAppColor.hBackgroundColor,
            ),
            body: SingleChildScrollView(
                child: Padding(
              padding: hAppDefaultPaddingLR,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Đơn hàng #${orderId.substring(0, 15)}...',
                    overflow: TextOverflow.ellipsis,
                    style: HAppStyle.heading4Style,
                  ),
                  gapH6,
                  Text(
                    'Dưới đây là chi tiết về đơn hàng',
                    style: HAppStyle.paragraph3Regular
                        .copyWith(color: HAppColor.hGreyColorShade600),
                  ),
                  gapH12,
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: HAppColor.hWhiteColor,
                        borderRadius: BorderRadius.circular(10)),
                    child: Column(children: [
                      SectionWidget(
                        title: 'Thời gian',
                        title2: DateFormat('EEEE, d-M-y', 'vi')
                            .format(order.orderDate!),
                        down: false,
                      ),
                      gapH6,
                      Divider(
                        color: HAppColor.hGreyColorShade300,
                      ),
                      gapH6,
                      Obx(() => SectionWidget(
                            title: 'Trạng thái đơn hàng',
                            title2: orderController.acceptOrder.value == 0
                                ? 'Đang chờ xác nhận'
                                : orderController.acceptOrder.value == -1
                                    ? 'Từ chối'
                                    : 'Đã xác nhận',
                            down: false,
                          )),
                    ]),
                  ),
                  gapH12,
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: HAppColor.hWhiteColor,
                        borderRadius: BorderRadius.circular(10)),
                    child: Column(children: [
                      SectionWidget(
                        title: 'Đường đi',
                        actions: [
                          GestureDetector(
                            onTap: () {
                              orderController.openGoogleMaps(
                                  order.orderUserAddress, order);
                            },
                            child: const Icon(
                              EvaIcons.navigation2Outline,
                              size: 18,
                            ),
                          )
                        ],
                        down: false,
                      ),
                    ]),
                  ),
                  gapH12,
                  for (int i = 0; i < order.storeOrders.length; i++)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: HAppColor.hWhiteColor,
                          borderRadius: BorderRadius.circular(10)),
                      child: Column(children: [
                        SectionWidget(
                          title: order.storeOrders.length > 1
                              ? 'Cửa hàng thứ ${i + 1}'
                              : 'Cửa hàng',
                          title2: order.storeOrders[i].name,
                          down: false,
                        ),
                        gapH6,
                        Divider(
                          color: HAppColor.hGreyColorShade300,
                        ),
                        gapH6,
                        SectionWidget(
                          title: 'Địa chỉ',
                          title2: order.storeOrders[i].address,
                          down: true,
                        ),
                        gapH6,
                        Divider(
                          color: HAppColor.hGreyColorShade300,
                        ),
                        gapH6,
                        SectionWidget(
                          title: 'Số lượng',
                          title2: order.orderProducts
                              .where((element) =>
                                  element.storeId ==
                                  order.storeOrders[i].storeId)
                              .fold(
                                  0,
                                  (previous, current) =>
                                      previous + current.quantity)
                              .toString(),
                          down: false,
                          index: i,
                          order: order,
                        ),
                        gapH6,
                        Divider(
                          color: HAppColor.hGreyColorShade300,
                        ),
                        gapH6,
                        SectionWidget(
                          title: 'Tổng trả',
                          title2: HAppUtils.vietNamCurrencyFormatting(order
                              .orderProducts
                              .where((element) =>
                                  element.storeId ==
                                  order.storeOrders[i].storeId)
                              .fold(
                                  0,
                                  (previous, current) =>
                                      previous + current.price!)),
                          down: false,
                        ),
                        gapH6,
                        Divider(
                          color: HAppColor.hGreyColorShade300,
                        ),
                        gapH6,
                        SectionWidget(
                          title: 'Hành động',
                          actions: [
                            GestureDetector(
                              onTap: () {},
                              child: const Icon(
                                EvaIcons.phoneOutline,
                                size: 18,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Get.to(
                                  const ChatOrderRealtimeScreen(),
                                  arguments: {'orderId': orderId}),
                              child: const Icon(
                                EvaIcons.messageSquareOutline,
                                size: 18,
                              ),
                            ),
                          ],
                          down: false,
                        ),
                      ]),
                    ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: HAppColor.hWhiteColor,
                        borderRadius: BorderRadius.circular(10)),
                    child: Column(children: [
                      const SectionWidget(
                        title: 'Ghi chú',
                        down: true,
                        title2: 'Không có ghi chú',
                      ),
                      gapH6,
                      Divider(
                        color: HAppColor.hGreyColorShade300,
                      ),
                      gapH6,
                      SectionWidget(
                        title: 'Địa chỉ',
                        down: true,
                        userAddress: order.orderUserAddress,
                      ),
                      gapH6,
                      Divider(
                        color: HAppColor.hGreyColorShade300,
                      ),
                      gapH6,
                      SectionWidget(
                        title: 'Tổng thu',
                        title2:
                            HAppUtils.vietNamCurrencyFormatting(order.price),
                        down: false,
                      ),
                    ]),
                  ),
                  gapH24,
                ],
              ),
            )),
            bottomNavigationBar: Container(
              padding: const EdgeInsets.fromLTRB(hAppDefaultPadding,
                  hAppDefaultPadding, hAppDefaultPadding, hAppDefaultPadding),
              decoration: BoxDecoration(
                color: HAppColor.hBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    offset: const Offset(0, -15),
                    blurRadius: 20,
                    color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.1),
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SwipeButton.expand(
                    thumb: const Icon(
                      EvaIcons.arrowIosForwardOutline,
                      color: Colors.white,
                    ),
                    activeThumbColor: HAppColor.hBluePrimaryColor,
                    activeTrackColor: HAppColor.hBlueSecondaryColor,
                    onSwipe: () async {
                      orderController.processOrder(
                          order, order.orderUser.cloudMessagingToken!);
                    },
                    child: Obx(() => Text(
                          orderController.acceptOrder.value == 1
                              ? orderController.acceptOrder.value == 1 &&
                                      orderController.checkProduct.value == 0
                                  ? "Vuốt để xác nhận đã lấy hàng"
                                  : 'Vuốt để xác nhận đã đến điểm giao'
                              : "Vuốt để xác nhận đơn hàng (${timerController.timeLeft})",
                          style: HAppStyle.paragraph2Bold
                              .copyWith(color: HAppColor.hWhiteColor),
                        )),
                  ),
                ],
              ),
            ));
      },
    );
  }
}

class SectionWidget extends StatelessWidget {
  const SectionWidget({
    super.key,
    required this.title,
    this.title2,
    required this.down,
    this.userAddress,
    this.actions,
    this.index,
    this.order,
  });

  final String? title2;
  final String title;
  final bool down;
  final UserAddressModel? userAddress;
  final List<Widget>? actions;
  final OrderModel? order;
  final int? index;

  @override
  Widget build(BuildContext context) {
    return down
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: HAppStyle.paragraph2Bold
                    .copyWith(color: HAppColor.hGreyColorShade600),
              ),
              gapH6,
              userAddress != null
                  ? Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userAddress!.name,
                              style: HAppStyle.heading5Style,
                            ),
                            Text(userAddress!.phoneNumber),
                            Text(userAddress!.toString())
                          ]),
                    )
                  : Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        title2! == '' ? 'Không có ghi chú' : title2!,
                        style: HAppStyle.paragraph2Regular,
                        textAlign: TextAlign.left,
                      ),
                    )
            ],
          )
        : Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  title,
                  style: HAppStyle.paragraph2Bold
                      .copyWith(color: HAppColor.hGreyColorShade600),
                ),
              ),
              Expanded(
                flex: 4,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: actions == null
                      ? title == 'Số lượng'
                          ? order != null
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      title2!,
                                      style: HAppStyle.paragraph2Regular,
                                      textAlign: TextAlign.right,
                                    ),
                                    gapW4,
                                    GestureDetector(
                                      onTap: () {
                                        print(order == null
                                            ? 'Null'
                                            : 'Không null');
                                        Get.to(() => ShowAllProductInStore(),
                                            arguments: {
                                              'order': order,
                                              'index': index,
                                            });
                                      },
                                      child: const Icon(
                                        EvaIcons.arrowIosForwardOutline,
                                        size: 18,
                                      ),
                                    )
                                  ],
                                )
                              : Container()
                          : Text(
                              title2!,
                              style: HAppStyle.paragraph2Regular,
                              textAlign: TextAlign.right,
                            )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                              for (int i = 0; i < actions!.length; i++)
                                Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: actions![i],
                                )
                            ]),
                ),
              ),
            ],
          );
  }
}
