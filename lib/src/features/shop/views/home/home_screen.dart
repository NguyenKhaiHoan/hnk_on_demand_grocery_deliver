import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:on_demand_grocery_deliver/src/common_widgets/user_image_logo.dart';
import 'package:on_demand_grocery_deliver/src/constants/app_colors.dart';
import 'package:on_demand_grocery_deliver/src/features/personalization/controllers/user_controller.dart';
import 'package:on_demand_grocery_deliver/src/services/location_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CameraPosition initialCameraPosition = const CameraPosition(
    target: LatLng(20.980724334716797, 105.7970962524414),
    zoom: 14,
  );
  Completer<GoogleMapController> googleMapController = Completer();
  GoogleMapController? mapController;

  RxBool online = false.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        automaticallyImplyLeading: false,
        title: UserImageLogoWidget(
          hasFunction: false,
          size: 40,
        ),
        actions: [
          Obx(() => Switch(
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
              }))
        ],
      ),
      // body: GoogleMap(
      //   initialCameraPosition: initialCameraPosition,
      //   mapType: MapType.normal,
      //   // myLocationButtonEnabled: true,
      //   // myLocationEnabled: true,
      //   // zoomControlsEnabled: true,
      //   // zoomGesturesEnabled: true,
      //   // onMapCreated: (GoogleMapController controller) async {
      //   //   googleMapController.complete(controller);
      //   //   mapController = controller;
      //   //   Position currentPositon =
      //   //       await HLocationService.getGeoLocationPosition();
      //   //   LatLng currentLatLng = LatLng(
      //   //     currentPositon.latitude,
      //   //     currentPositon.longitude,
      //   //   );
      //   //   CameraPosition cameraPosition = CameraPosition(
      //   //     target: currentLatLng,
      //   //     zoom: 14,
      //   //   );
      //   //   mapController!
      //   //       .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
      //   // },
      // ),
      body: Container(),
    );
  }
}
