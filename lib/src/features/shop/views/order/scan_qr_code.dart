import 'dart:typed_data';

import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:on_demand_grocery_deliver/src/constants/app_colors.dart';
import 'package:on_demand_grocery_deliver/src/constants/app_sizes.dart';
import 'package:on_demand_grocery_deliver/src/features/shop/controllers/order_controller.dart';
import 'package:on_demand_grocery_deliver/src/utils/theme/app_style.dart';
import 'package:on_demand_grocery_deliver/src/utils/utils.dart';

class ScanQrCodeScreen extends StatelessWidget {
  ScanQrCodeScreen({super.key});

  final String orderId = Get.arguments['orderId'];
  final int index = Get.arguments['index'];
  final orderController = OrderController.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        titleSpacing: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        backgroundColor: HAppColor.hTransparentColor,
        toolbarHeight: 80,
        title: Padding(
          padding: hAppDefaultPaddingL,
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  Get.back();
                },
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
            ],
          ),
        ),
      ),
      body: MobileScanner(
        controller: MobileScannerController(
          detectionSpeed: DetectionSpeed.noDuplicates,
          returnImage: true,
        ),
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          final Uint8List? image = capture.image;

          if (image != null) {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text(
                    "Quét mã Qr",
                  ),
                  content: Image(
                    image: MemoryImage(image),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Get.back();
                      },
                      child: Text(
                        'Thoát',
                        style: HAppStyle.label4Bold
                            .copyWith(color: HAppColor.hDarkColor),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        if (barcodes.first.rawValue ==
                            orderId.substring(orderId.length - 4)) {
                          orderController.checkQrListStore[index] = true;
                          HAppUtils.showSnackBarSuccess('Thành công',
                              'Bạn đã quét mã Qr tại cửa hàng thành công');
                        } else {
                          orderController.checkQrListStore[index] = false;
                          HAppUtils.showSnackBarWarning('Không thành công',
                              'Có vẻ mã bạn quét không đúng, hãy thử lại');
                        }
                        print('ĐÃ KIỂM TRA');
                      },
                      child: Text(
                        'Kiểm tra',
                        style: HAppStyle.label4Bold
                            .copyWith(color: HAppColor.hBluePrimaryColor),
                      ),
                    ),
                  ],
                );
              },
            );
          }
        },
      ),
    );
  }
}
