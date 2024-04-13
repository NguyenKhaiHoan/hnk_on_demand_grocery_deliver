import 'dart:convert';
import 'dart:developer';

import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:on_demand_grocery_deliver/src/constants/app_colors.dart';
import 'package:on_demand_grocery_deliver/src/constants/app_sizes.dart';
import 'package:on_demand_grocery_deliver/src/features/shop/controllers/order_controller.dart';
import 'package:on_demand_grocery_deliver/src/features/shop/models/order_model.dart';
import 'package:on_demand_grocery_deliver/src/features/shop/models/product_in_cart_model.dart';
import 'package:on_demand_grocery_deliver/src/features/shop/views/order/scan_qr_code.dart';
import 'package:on_demand_grocery_deliver/src/utils/theme/app_style.dart';
import 'package:on_demand_grocery_deliver/src/utils/utils.dart';

class ShowAllProductInStore extends StatelessWidget {
  ShowAllProductInStore({
    super.key,
  });

  final orderController = Get.put(OrderController());
  final OrderModel order = Get.arguments['order'];
  final int index = Get.arguments['index'];

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration.zero).then((value) {
      orderController.checkProduct.value =
          order.storeOrders[index].isCheckFullProduct == 1
              ? 1
              : order.storeOrders[index].isCheckFullProduct == -1
                  ? -1
                  : 0;
    });
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
          title: const Text('Kiểm tra số lượng hàng'),
          backgroundColor: HAppColor.hBackgroundColor,
        ),
        body: SingleChildScrollView(
            child: Padding(
          padding: hAppDefaultPaddingLR,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                order.storeOrders[index].name,
                style: HAppStyle.heading4Style,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              gapH6,
              Text(
                'Dưới đây là đầy đủ hàng hóa của cửa hàng trong đơn hàng',
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
                      title: 'Quét mã',
                      hasIcon: true,
                      icon: GestureDetector(
                        onTap: () async {
                          // orderController.checkQrListStore[index] = true;
                          if (!orderController.checkQrListStore[index]) {
                            print(
                                'Kiểm tra mã Qr: ${orderController.checkQrListStore[index]}');
                            HAppUtils.loadingOverlays();
                            Position currentPosition =
                                await HAppUtils.getGeoLocationPosition();
                            final distance = HAppUtils.calculateDistance(
                                currentPosition.latitude,
                                currentPosition.longitude,
                                order.storeOrders[index].latitude,
                                order.storeOrders[index].longitude);
                            print('Khoảng cách: $distance');
                            HAppUtils.stopLoading();
                            if (distance < 50) {
                              Get.to(() => ScanQrCodeScreen(), arguments: {
                                'orderId': order.oderId,
                                'index': index
                              });
                            } else {
                              HAppUtils.showSnackBarWarning('Không đúng vị trí',
                                  'Có vẻ khoảng cách từ vị trí hiện tại của bạn với vị trí cửa hàng còn khá xa');
                            }
                          }
                        },
                        child: const Icon(
                          Icons.qr_code_scanner_rounded,
                          size: 18,
                        ),
                      )),
                  gapH6,
                  Divider(
                    color: HAppColor.hGreyColorShade300,
                  ),
                  gapH6,
                  SectionWidget(
                    title: 'Số lượng',
                    title2: order.orderProducts
                        .where((e) =>
                            e.storeId == order.storeOrders[index].storeId)
                        .fold(
                            0,
                            (previousValue, element) =>
                                previousValue + element.quantity)
                        .toString(),
                  ),
                  gapH6,
                  Divider(
                    color: HAppColor.hGreyColorShade300,
                  ),
                  gapH6,
                  Obx(() => SectionWidget(
                        title: 'Trạng thái hàng hóa',
                        title2: orderController.checkProduct.value == 0
                            ? 'Đang chờ kiểm tra'
                            : orderController.checkProduct.value == -1
                                ? 'Thiếu hàng hóa'
                                : 'Đầy đủ',
                      )),
                ]),
              ),
              gapH12,
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: order.orderProducts
                    .where((element) =>
                        element.storeId == order.storeOrders[index].storeId)
                    .length,
                itemBuilder: (context, index) {
                  return ProductItemHorizalWidget(
                      model: order.orderProducts
                          .where((element) =>
                              element.storeId ==
                              order.storeOrders[index].storeId)
                          .toList()[index]);
                },
                separatorBuilder: (context, index) => gapH12,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text.rich(TextSpan(
                        text: 'Số lượng: ',
                        style: HAppStyle.paragraph2Regular
                            .copyWith(color: HAppColor.hGreyColorShade600),
                        children: [
                          TextSpan(
                              text: order.orderProducts
                                  .where((e) =>
                                      e.storeId ==
                                      order.storeOrders[index].storeId)
                                  .fold(
                                      0,
                                      (previousValue, element) =>
                                          previousValue + element.quantity)
                                  .toString()
                                  .toString(),
                              style: HAppStyle.label2Bold
                                  .copyWith(color: HAppColor.hDarkColor))
                        ])),
                  ),
                  TextButton(
                      onPressed: () async {
                        if (orderController.checkQrListStore[index]) {
                          orderController.checkProduct.value = -1;
                          var ref = FirebaseDatabase.instance.ref(
                              "Orders/${order.oderId}/StoreOrders/$index/");
                          await ref.update({
                            "IsCheckFullProduct": -1,
                          });
                        } else {
                          HAppUtils.showSnackBarWarning('Cảnh báo',
                              'Hãy quét mã Qr trước khi kiểm tra hàng');
                        }
                      },
                      child: Text(
                        'Thiếu hàng',
                        style: HAppStyle.paragraph2Regular.copyWith(
                          color: HAppColor.hRedColor,
                          decoration: TextDecoration.underline,
                        ),
                      )),
                  gapW10,
                  Obx(() => Expanded(
                          child: ElevatedButton(
                        onPressed: () async {
                          if (orderController.checkQrListStore[index]) {
                            orderController.checkProduct.value = 1;
                            var ref = FirebaseDatabase.instance.ref(
                                "Orders/${order.oderId}/StoreOrders/$index/");
                            await ref.update({
                              "IsCheckFullProduct": 1,
                            });
                          } else {
                            HAppUtils.showSnackBarWarning('Cảnh báo',
                                'Hãy quét mã Qr trước khi kiểm tra hàng');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          maximumSize: Size(HAppSize.deviceWidth * 0.5, 50),
                          backgroundColor: HAppColor.hBluePrimaryColor,
                        ),
                        child: orderController.checkProduct.value == 1
                            ? Text("Đầy đủ",
                                style: HAppStyle.label2Bold
                                    .copyWith(color: HAppColor.hWhiteColor))
                            : Text("Kiểm tra",
                                style: HAppStyle.label2Bold
                                    .copyWith(color: HAppColor.hWhiteColor)),
                      ))),
                ],
              ),
            ],
          ),
        ));
  }
}

class SectionWidget extends StatelessWidget {
  const SectionWidget({
    super.key,
    required this.title,
    this.title2,
    this.hasIcon = false,
    this.icon,
  });

  final String? title2;
  final String title;
  final bool hasIcon;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return Row(
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
            child: hasIcon
                ? icon!
                : Text(
                    title2!,
                    style: HAppStyle.paragraph2Regular,
                    textAlign: TextAlign.right,
                  ),
          ),
        ),
      ],
    );
  }
}

class ProductItemHorizalWidget extends StatelessWidget {
  ProductItemHorizalWidget({
    super.key,
    required this.model,
  });
  final ProductInCartModel model;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        height: 100,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: HAppColor.hWhiteColor,
            borderRadius: BorderRadius.circular(20)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: DecorationImage(
                          image: NetworkImage(model.image!),
                          fit: BoxFit.fitHeight)),
                ),
              ),
            ]),
            gapW10,
            Expanded(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(model.unit!,
                            style: HAppStyle.paragraph3Regular
                                .copyWith(color: HAppColor.hGreyColorShade600)),
                        gapH6,
                        Text(
                          model.productName!,
                          style: HAppStyle.label2Bold.copyWith(
                            overflow: TextOverflow.ellipsis,
                          ),
                          maxLines: 1,
                        ),
                      ]),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      HAppUtils.vietNamCurrencyFormatting(model.price!),
                      style: HAppStyle.label2Bold
                          .copyWith(color: HAppColor.hBluePrimaryColor),
                    ),
                    Text('x${model.quantity}')
                  ],
                )
              ],
            ))
          ],
        ),
      ),
    );
  }
}
