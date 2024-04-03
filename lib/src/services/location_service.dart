import 'dart:async';
import 'dart:developer';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:on_demand_grocery_deliver/src/features/personalization/controllers/user_controller.dart';
import 'package:on_demand_grocery_deliver/src/features/shop/controllers/map_controller.dart';
import 'package:on_demand_grocery_deliver/src/repositories/authentication_repository.dart';
import 'package:on_demand_grocery_deliver/src/repositories/delivery_person_repository.dart';
import 'package:on_demand_grocery_deliver/src/utils/utils.dart';

class HLocationService {
  static Future<Position> getGeoLocationPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      HAppUtils.showSnackBarError('Lỗi', 'Dịch vụ định vị bị vô hiệu hóa.');
      return Future.error('Dịch vụ định vị bị vô hiệu hóa.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        HAppUtils.showSnackBarError('Lỗi', 'Quyền truy cập vị trí bị từ chối.');
        return Future.error('Quyền truy cập vị trí bị từ chối.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      HAppUtils.showSnackBarError('Lỗi',
          'Quyền vị trí bị từ chối vĩnh viễn, chúng tôi không thể yêu cầu quyền.');
      return Future.error(
          'Quyền vị trí bị từ chối vĩnh viễn, chúng tôi không thể yêu cầu quyền.');
    }

    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  static Future<List<String>> getAddressFromLatLong(Position position) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark place = placemarks[0];
      return [
        place.street ?? '',
        place.subAdministrativeArea ?? '',
        place.administrativeArea ?? ''
      ];
    } catch (e) {
      HAppUtils.showSnackBarError('Lỗi', e.toString());
      return [];
    }
  }

  static checkStatus(bool online) async {
    if (online) {
      Position currentPosition =
          await HLocationService.getGeoLocationPosition();
      Geofire.initialize('DeliveryPersons');
      Geofire.setLocation(AuthenticationRepository.instance.authUser!.uid,
          currentPosition.latitude, currentPosition.longitude);
      await DeliveryPersonRepository.instance
          .updateSingleField({'Status': true});
      DeliveryPersonController.instance.user.value.status == true;
      DeliveryPersonController.instance.user.refresh();
      HAppUtils.showSnackBarSuccess(
          "Bật nhận đơn", 'Bạn đã bật nhận đơn thành công');
    } else {
      log('Vào đây');
      Geofire.removeLocation(AuthenticationRepository.instance.authUser!.uid);
      await DeliveryPersonRepository.instance
          .updateSingleField({'Status': false});
      DeliveryPersonController.instance.user.value.status == false;
      DeliveryPersonController.instance.user.refresh();
      HAppUtils.showSnackBarSuccess(
          "Đóng nhận đơn", 'Bạn đã đóng nhận đơn thành công');
    }
  }

  late LocationSettings locationSettings;

  static updateLocationRealtime() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 10,
    );
    StreamSubscription<Position> deliveryPersonPosition =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position? position) {
      print('vào set');
      position == null
          ? print('Đang cập nhật vị trí hiện tại')
          : {
              Geofire.initialize('DeliveryPersons'),
              Geofire.setLocation(
                  AuthenticationRepository.instance.authUser!.uid,
                  position.latitude,
                  position.longitude),
              MapController.instance.updateRealtimeCurrentPositon(position)
            };
    });
  }
}
