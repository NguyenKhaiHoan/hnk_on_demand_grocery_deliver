import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:on_demand_grocery_deliver/src/features/authentication/views/change_password/change_password_screen.dart';
import 'package:on_demand_grocery_deliver/src/features/authentication/views/forget_password/forget_password_screen.dart';
import 'package:on_demand_grocery_deliver/src/features/authentication/views/forget_password/sent_password_screen.dart';
import 'package:on_demand_grocery_deliver/src/features/authentication/views/login/login_screen.dart';
import 'package:on_demand_grocery_deliver/src/features/authentication/views/registration_store/registration_store.dart';
import 'package:on_demand_grocery_deliver/src/features/authentication/views/signup/sign_up_screen.dart';
import 'package:on_demand_grocery_deliver/src/features/authentication/views/verify/complete_create_account_screen.dart';
import 'package:on_demand_grocery_deliver/src/features/authentication/views/verify/verify_screen.dart';
import 'package:on_demand_grocery_deliver/src/features/personalization/views/change_name/change_name_screen.dart';
import 'package:on_demand_grocery_deliver/src/features/personalization/views/change_phone_number/change_phone_screen.dart';
import 'package:on_demand_grocery_deliver/src/features/personalization/views/no_deliver/no_deliver_screen.dart';
import 'package:on_demand_grocery_deliver/src/features/shop/views/drawer/drawer_screen.dart';
import 'package:on_demand_grocery_deliver/src/features/shop/views/order/order_detail_screen.dart';

abstract class HAppPages {
  static final pages = [
    GetPage(
      name: HAppRoutes.login,
      page: () => const LoginScreen(),
      transitionDuration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: HAppRoutes.drawer,
      page: () => const DrawerScreen(),
      transitionDuration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: HAppRoutes.verify,
      page: () => const VerifyScreen(),
      transitionDuration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: HAppRoutes.completeAccount,
      page: () => const CompleteCreateAccountScreen(),
      transitionDuration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: HAppRoutes.signup,
      page: () => const SignUpScreen(),
      transitionDuration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: HAppRoutes.forgetPassword,
      page: () => const ForgetPasswordScreen(),
      transitionDuration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: HAppRoutes.sentPassword,
      page: () => const SentPasswordScreen(),
      transitionDuration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: HAppRoutes.changePassword,
      page: () => const ChangePasswordScreen(),
      transitionDuration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: HAppRoutes.changeName,
      page: () => const ChangeNameScreen(),
      transitionDuration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: HAppRoutes.changePhone,
      page: () => const ChangePhoneScreen(),
      transitionDuration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: HAppRoutes.registrationDeliveryPerson,
      page: () => const RegistrationDeliveryPersonScreen(),
      transitionDuration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: HAppRoutes.orderDetail,
      page: () => OrderDetailScreen(),
      transitionDuration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: HAppRoutes.noDeliver,
      page: () => const NoDeliverScreen(),
      transitionDuration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      transition: Transition.fadeIn,
    ),
  ];
}

abstract class HAppRoutes {
  static const onboarding = '/onboarding';
  static const drawer = '/drawer';
  static const login = '/login';
  static const verify = '/verify';
  static const complete = '/complete';
  static const signup = '/signup';
  static const forgetPassword = '/forgetPassword';
  static const sentPassword = '/sentPassword';
  static const profileDetail = '/profileDetail';
  static const changePassword = '/changePassword';
  static const changeName = '/changeName';
  static const changePhone = '/changePhone';
  static const noDeliver = '/noDeliver';
  static const completeAccount = '/completeAccount';
  static const registrationDeliveryPerson = '/registrationDeliveryPerson';
  static const orderDetail = '/orderDetail';
}
