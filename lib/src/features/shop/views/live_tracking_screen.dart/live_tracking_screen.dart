import 'dart:async';
import 'dart:convert';

import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_network/image_network.dart';
import 'package:on_demand_grocery_deliver/src/common_widgets/custom_shimmer_widget.dart';
import 'package:on_demand_grocery_deliver/src/constants/app_colors.dart';
import 'package:on_demand_grocery_deliver/src/constants/app_sizes.dart';
import 'package:on_demand_grocery_deliver/src/features/shop/models/delivery_location_model.dart';
import 'package:on_demand_grocery_deliver/src/features/shop/models/order_model.dart';
import 'package:on_demand_grocery_deliver/src/features/shop/models/store_model.dart';
import 'package:on_demand_grocery_deliver/src/features/shop/models/store_order_model.dart';
import 'package:on_demand_grocery_deliver/src/features/shop/models/user_address_model.dart';
import 'package:on_demand_grocery_deliver/src/features/shop/models/user_model.dart';
import 'package:on_demand_grocery_deliver/src/repositories/store_repository.dart';
import 'package:on_demand_grocery_deliver/src/utils/theme/app_style.dart';
import 'package:on_demand_grocery_deliver/src/utils/utils.dart';

class LiveTrackingScreen extends StatefulWidget {
  const LiveTrackingScreen({super.key});

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen>
    with OSMMixinObserver {
  String orderId = Get.arguments['orderId'];
  String deliveryPersonId = Get.arguments['deliveryPersonId'];

  @override
  void initState() {
    super.initState();
    mapController = MapController(
        initMapWithUserPosition: const UserTrackingOption(
            enableTracking: true, unFollowUser: false));

    mapController.addObserver(this);

    FirebaseDatabase.instance
        .ref()
        .child('Orders/$orderId')
        .onValue
        .listen((event) async {
      if (event.snapshot.exists) {
        OrderModel orderData =
            OrderModel.fromJson(jsonDecode(jsonEncode(event.snapshot.value)));
        order.value = orderData;
        print('Vào đây mau:');
        print(order.value.toString());
        task.value = await taskDelivery(
            orderData.orderStatus == HAppUtils.orderStatus(2));
      }
    });

    bool firstTime = true;

    FirebaseDatabase.instance
        .ref()
        .child('DeliveryPersons/$deliveryPersonId')
        .onValue
        .listen((event) async {
      if (event.snapshot.exists) {
        if (firstTime) {
          mapIsReady(true);
          firstTime = false;
        }

        DeliveryProcessModel deliveryProcess = DeliveryProcessModel.fromJson(
            jsonDecode(jsonEncode(event.snapshot.value)));
        await mapController.setZoom(zoomLevel: 16);
        await mapController.goToLocation(
          GeoPoint(
              latitude: deliveryProcess.l[0], longitude: deliveryProcess.l[1]),
        );

        await mapController.setStaticPosition([
          GeoPoint(
              latitude: deliveryProcess.l[0], longitude: deliveryProcess.l[1])
        ], 'deliveryPerson');
      }
    });
  }

  var order = OrderModel.empty().obs;
  Rx<Widget> task = Rx<Widget>(Container());

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Stack(children: [
        getMap(),
        Align(
          alignment: Alignment.topLeft,
          child: Container(
            height: 80,
            alignment: Alignment.centerLeft,
            child: Padding(
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
        ),
      ]),
    ));
  }

  late MapController mapController;

  Widget getMap() {
    return Stack(
      children: [
        OSMFlutter(
          controller: mapController,
          osmOption: OSMOption(
            userTrackingOption: const UserTrackingOption(
              enableTracking: true,
              unFollowUser: false,
            ),
            zoomOption: const ZoomOption(
              initZoom: 8,
              minZoomLevel: 3,
              maxZoomLevel: 19,
              stepZoom: 1.0,
            ),
            roadConfiguration: const RoadOption(
              roadColor: HAppColor.hBluePrimaryColor,
            ),
            markerOption: MarkerOption(
                defaultMarker: const MarkerIcon(
              icon: Icon(
                Icons.person_pin_circle,
                color: Colors.blue,
                size: 100,
              ),
            )),
            showDefaultInfoWindow: false,
          ),
          onMapIsReady: (isReady) async {
            if (isReady) {
              await mapController.enableTracking(
                enableStopFollow: false,
              );
            }
          },
          onLocationChanged: (myLocation) {
            print('my location: $myLocation');
          },
          onGeoPointClicked: (myLocation) {
            print('clicked: $myLocation');
          },
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child:
              Obx(() => task.value != Container() ? task.value : Container()),
        ),
      ],
    );
  }

  void loadMapRoad() async {
    RoadInfo road = await mapController.drawRoad(
        GeoPoint(latitude: 20.9835, longitude: 105.7914),
        GeoPoint(latitude: 20.9807, longitude: 105.7971),
        roadType: RoadType.car,
        roadOption: const RoadOption(
            roadColor: HAppColor.hBluePrimaryColor, roadBorderWidth: 10),
        intersectPoint: [
          for (int i = 0; i < order.value.storeOrders.length; i++)
            GeoPoint(
                latitude: order.value.storeOrders[i].latitude,
                longitude: order.value.storeOrders[i].longitude),
        ]);

    print(order.value.deliveryPerson!.name);

    print('Distance: ${road.distance ?? 0.0}');
    print('Duration: ${road.duration ?? 0.0}');
  }

  Future<void> addMarker() async {
    await mapController.setMarkerOfStaticPoint(
        id: "deliveryPerson",
        markerIcon: MarkerIcon(
          iconWidget: Container(
            decoration: const BoxDecoration(
                color: HAppColor.hBluePrimaryColor, shape: BoxShape.circle),
            height: 30,
            width: 30,
          ),
        ));

    await mapController.setMarkerOfStaticPoint(
        id: "user",
        markerIcon: MarkerIcon(
          iconWidget: Container(
            decoration: const BoxDecoration(
                color: HAppColor.hRedColor, shape: BoxShape.circle),
            height: 30,
            width: 30,
          ),
        ));

    await mapController.setMarkerOfStaticPoint(
        id: "store",
        markerIcon: MarkerIcon(
          iconWidget: Container(
            decoration: const BoxDecoration(
                color: HAppColor.hOrangeColor, shape: BoxShape.circle),
            height: 30,
            width: 30,
          ),
        ));

    await mapController.setStaticPosition(
        [GeoPoint(latitude: 20.9807, longitude: 105.7971)], 'user');

    await mapController.setStaticPosition([
      for (int i = 0; i < order.value.storeOrders.length; i++)
        GeoPoint(
            latitude: order.value.storeOrders[i].latitude,
            longitude: order.value.storeOrders[i].longitude),
    ], 'store');

    loadMapRoad();
  }

  @override
  Future<void> mapIsReady(bool isReady) async {
    if (isReady) {
      await addMarker();
    }
  }

  Future<Widget> taskDelivery(bool isStore) async {
    print('Vào đây: $isStore');
    if (isStore && order.value.orderStatus != HAppUtils.orderStatus(4)) {
      var store = order.value.storeOrders.firstWhere(
        (element) => element.isCheckFullProduct != 1,
        orElse: () => StoreOrderModel.empty(),
      );
      if (store == StoreOrderModel.empty()) {
        return Container();
      }
      final index = order.value.storeOrders
          .indexWhere((element) => element.storeId == store.storeId);
      var storeData =
          await StoreRepository.instance.getStoreInformation(store.storeId);
      return buildStoreRow(storeData, store, index);
    } else if (!isStore &&
        order.value.orderStatus != HAppUtils.orderStatus(4)) {
      return buildUserRow(order.value.orderUserAddress, order.value.orderUser);
    }
    return Container();
  }

  Widget buildStoreRow(StoreModel storeData, StoreOrderModel store, int index) {
    return Container(
      width: HAppSize.deviceWidth,
      padding: hAppDefaultPaddingLR,
      margin: const EdgeInsets.all(hAppDefaultPadding),
      decoration: const BoxDecoration(
          color: HAppColor.hBackgroundColor,
          borderRadius: BorderRadius.all(Radius.circular(10)),
          boxShadow: [
            BoxShadow(
                color: HAppColor.hGreyColor,
                blurRadius: 10,
                offset: Offset(0, -5))
          ]),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            gapH12,
            Text(
              'Điểm tới ${index == 0 ? 'đầu tiên' : 'tiếp theo'}:',
              style: HAppStyle.label2Bold
                  .copyWith(color: HAppColor.hBluePrimaryColor),
            ),
            gapH6,
            Row(
              children: [
                storeData.storeImage == ''
                    ? Image.asset(
                        'assets/logos/logo.png',
                        height: 60,
                        width: 60,
                      )
                    : ImageNetwork(
                        image: storeData.storeImage,
                        height: 60,
                        width: 60,
                        borderRadius: BorderRadius.circular(100),
                        onLoading: const CustomShimmerWidget.circular(
                            width: 60, height: 60),
                      ),
                gapW10,
                Expanded(
                    child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        store.name,
                        style: HAppStyle.heading5Style,
                      ),
                      Text(store.address,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: HAppStyle.paragraph2Regular.copyWith(
                            color: HAppColor.hGreyColorShade600,
                          ))
                    ],
                  ),
                )),
              ],
            ),
            gapH6,
            buildActionRow(),
            gapH12,
          ]),
    );
  }

  Widget buildUserRow(UserAddressModel orderUserAddress, UserModel orderUser) {
    return Container(
      width: HAppSize.deviceWidth,
      padding: hAppDefaultPaddingLR,
      margin: const EdgeInsets.all(hAppDefaultPadding),
      decoration: const BoxDecoration(
          color: HAppColor.hBackgroundColor,
          borderRadius: BorderRadius.all(Radius.circular(10)),
          boxShadow: [
            BoxShadow(
                color: HAppColor.hGreyColor,
                blurRadius: 10,
                offset: Offset(0, -5))
          ]),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            gapH12,
            Text(
              'Điểm tới cuối cùng:',
              style: HAppStyle.label2Bold
                  .copyWith(color: HAppColor.hBluePrimaryColor),
            ),
            gapH6,
            Row(
              children: [
                orderUser.profileImage == ''
                    ? Image.asset(
                        'assets/logos/logo.png',
                        height: 60,
                        width: 60,
                      )
                    : ImageNetwork(
                        image: orderUser.profileImage,
                        height: 60,
                        width: 60,
                        borderRadius: BorderRadius.circular(100),
                        onLoading: const CustomShimmerWidget.circular(
                            width: 60, height: 60),
                      ),
                gapW10,
                Expanded(
                    child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        orderUser.name,
                        style: HAppStyle.heading5Style,
                      ),
                      Text(orderUserAddress.toString(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: HAppStyle.paragraph2Regular.copyWith(
                            color: HAppColor.hGreyColorShade600,
                          ))
                    ],
                  ),
                )),
              ],
            ),
            gapH6,
            buildActionRow(),
            gapH12,
          ]),
    );
  }

  Widget buildActionRow() {
    return Row(
      children: [
        Text(
          'Hành động: ',
          style:
              HAppStyle.label2Bold.copyWith(color: HAppColor.hBluePrimaryColor),
        ),
        gapW6,
        const Icon(EvaIcons.phoneOutline),
        gapW12,
        const Icon(EvaIcons.messageSquareOutline),
        gapW12,
        const Icon(Icons.storefront_outlined)
      ],
    );
  }
}
