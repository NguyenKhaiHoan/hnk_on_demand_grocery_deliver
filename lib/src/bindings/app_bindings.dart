import 'package:get/get.dart';
import 'package:on_demand_grocery_deliver/src/features/authentication/controller/change_password_controller.dart';
import 'package:on_demand_grocery_deliver/src/features/authentication/controller/login_controller.dart';
import 'package:on_demand_grocery_deliver/src/features/authentication/controller/network_controller.dart';
import 'package:on_demand_grocery_deliver/src/features/authentication/controller/sign_up_controller.dart';
import 'package:on_demand_grocery_deliver/src/features/authentication/controller/verify_controller.dart';
import 'package:on_demand_grocery_deliver/src/features/personalization/controllers/change_name_controller.dart';
import 'package:on_demand_grocery_deliver/src/features/personalization/controllers/user_controller.dart';
import 'package:on_demand_grocery_deliver/src/features/shop/controllers/drawer_controller.dart';
import 'package:on_demand_grocery_deliver/src/features/shop/controllers/timmer_controller.dart';

class HAppBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<NetworkController>(NetworkController(), permanent: true);
    // Get.lazyPut(() => UserController(), fenix: true);
    // Get.lazyPut(() => AddressController(), fenix: true);
    Get.lazyPut(() => ChangeNameController(), fenix: true);
    Get.lazyPut(() => TimerController(''));
    Get.lazyPut(() => ChangePasswordController(), fenix: true);
    Get.lazyPut(() => VerifyController(), fenix: true);
    Get.lazyPut(() => SignUpController(), fenix: true);
    Get.lazyPut(() => DrawerCustomController(), fenix: true);
    Get.lazyPut(() => DeliveryPersonController());
    Get.lazyPut(() => LoginController(), fenix: true);
    // Get.lazyPut(() => ProductController(), fenix: true);
  }
}
