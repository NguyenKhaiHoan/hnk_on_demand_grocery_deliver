import 'package:another_stepper/dto/stepper_data.dart';
import 'package:another_stepper/widgets/another_stepper.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:on_demand_grocery_deliver/src/constants/app_colors.dart';
import 'package:on_demand_grocery_deliver/src/constants/app_sizes.dart';
import 'package:on_demand_grocery_deliver/src/features/shop/controllers/order_controller.dart';
import 'package:on_demand_grocery_deliver/src/features/shop/controllers/timmer_controller.dart';
import 'package:on_demand_grocery_deliver/src/features/shop/models/order_model.dart';
import 'package:on_demand_grocery_deliver/src/routes/app_pages.dart';
import 'package:on_demand_grocery_deliver/src/utils/theme/app_style.dart';
import 'package:on_demand_grocery_deliver/src/utils/utils.dart';

class OrderNotificationWidget extends StatelessWidget {
  const OrderNotificationWidget(
      {super.key, required this.stepperData, required this.order});

  final List<StepperData> stepperData;
  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final timerController =
        Get.put(TimerController(order.oderId), tag: order.oderId);
    timerController.startTimer(const Duration(seconds: 60));
    return Padding(
      padding: hAppDefaultPaddingLR,
      child: Container(
        padding: const EdgeInsets.all(hAppDefaultPadding),
        width: HAppSize.deviceWidth - hAppDefaultPadding * 2,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: HAppColor.hWhiteColor,
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Đơn giao hàng mới',
                      style: HAppStyle.heading4Style,
                    ),
                    gapW6,
                    Container(
                      padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: HAppColor.hRedColor,
                      ),
                      child: Text(
                        'Hỏa tốc',
                        style: HAppStyle.paragraph3Regular
                            .copyWith(color: HAppColor.hWhiteColor),
                      ),
                    )
                  ],
                ),
                gapH10,
                Text.rich(TextSpan(text: 'Tổng:\n', children: [
                  TextSpan(
                      text: HAppUtils.vietNamCurrencyFormatting(order.price),
                      style: HAppStyle.heading4Style
                          .copyWith(color: HAppColor.hBluePrimaryColor))
                ])),
              ],
            ),
            Obx(
              () => Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                width: 60,
                height: 60,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(0),
                      child: CircularProgressIndicator(
                        strokeWidth: 6,
                        valueColor: AlwaysStoppedAnimation(
                            int.parse(timerController.timeLeft) <= 10
                                ? HAppColor.hRedColor
                                : HAppColor.hBluePrimaryColor),
                        value: int.parse(timerController.timeLeft) /
                            TimerController.maxSeconds,
                      ),
                    ),
                    Center(
                      child: Text(
                        timerController.timeLeft,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: int.parse(timerController.timeLeft) <= 10
                              ? HAppColor.hRedColor
                              : HAppColor.hBluePrimaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ]),
          Divider(
            color: HAppColor.hGreyColorShade300,
          ),
          AnotherStepper(
            barThickness: 0.5,
            stepperList: stepperData,
            stepperDirection: Axis.vertical,
            iconWidth: 30,
            iconHeight: 30,
            verticalGap: 20,
          ),
          gapH8,
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    HAppUtils.loadingOverlays();
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
                    HAppUtils.stopLoading();
                    Get.toNamed(HAppRoutes.orderDetail, arguments: {
                      'orderId': order.oderId,
                      'listNumberOfCart': listNumberOfCart,
                      'listTotalPrice': listTotalPrice,
                      'listAddressStore': listAddressStore
                    });
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: HAppColor.hBluePrimaryColor,
                      maximumSize: Size(
                          HAppSize.deviceWidth - hAppDefaultPadding * 2, 50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50))),
                  child: Text("Xem chi tiết",
                      style: HAppStyle.label2Bold
                          .copyWith(color: HAppColor.hWhiteColor)),
                ),
              ),
              TextButton(
                  onPressed: () {
                    timerController.removeOrder();
                  },
                  child: Text("Từ chối",
                      style: HAppStyle.label2Bold
                          .copyWith(color: HAppColor.hRedColor)))
            ],
          )
        ]),
      ),
    );
  }
}
