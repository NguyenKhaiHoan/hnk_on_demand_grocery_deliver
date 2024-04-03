import 'dart:async';
import 'dart:convert';
import 'dart:ffi';

import 'package:another_stepper/another_stepper.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cool_card_swiper/widgets/cool_swiper.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
import 'package:on_demand_grocery_deliver/src/features/shop/views/home/widgets/order_notification_widget.dart';
import 'package:on_demand_grocery_deliver/src/services/location_service.dart';
import 'package:on_demand_grocery_deliver/src/utils/theme/app_style.dart';
import 'package:on_demand_grocery_deliver/src/utils/utils.dart';
import 'package:stacked_notification_cards/stacked_notification_cards.dart';

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
        // GoogleMap(
        //   initialCameraPosition: CameraPosition(
        //     target: LatLng(initializeLocationController.latitude.value,
        //         initializeLocationController.longitude.value),
        //     zoom: 16,
        //   ),
        //   mapType: MapType.normal,
        //   myLocationButtonEnabled: true,
        //   myLocationEnabled: true,
        //   zoomControlsEnabled: true,
        //   zoomGesturesEnabled: true,
        //   onMapCreated: (GoogleMapController controller) async {
        //     googleMapController.complete(controller);
        //     mapController = controller;
        //     Position currentPositon =
        //         await HLocationService.getGeoLocationPosition();
        //     LatLng currentLatLng = LatLng(
        //       currentPositon.latitude,
        //       currentPositon.longitude,
        //     );
        //     CameraPosition cameraPosition = CameraPosition(
        //       target: currentLatLng,
        //       zoom: 16,
        //     );

        //     mapController!
        //         .getLatLng(ScreenCoordinate(
        //       x: (HAppSize.deviceHeight / 2).round(),
        //       y: (HAppSize.deviceHeight / 4).round(),
        //     ))
        //         .then((latLng) {
        //       mapController!.animateCamera(
        //           CameraUpdate.newCameraPosition(cameraPosition));
        //     });
        //   },
        // ),
        Obx(() => orderController.listOrder.isNotEmpty
            ? Positioned(
                bottom: 10,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                      minWidth: HAppSize.deviceWidth,
                      minHeight: HAppSize.deviceHeight * 0.3,
                      maxWidth: HAppSize.deviceWidth,
                      maxHeight: HAppSize.deviceHeight * 0.8),
                  child: CoolSwiper(
                      children: List.generate(orderController.listOrder.length,
                          (index) {
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
            : Container())
      ]),
    );
  }
}
