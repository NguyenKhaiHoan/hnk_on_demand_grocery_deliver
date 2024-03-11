import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:on_demand_grocery_deliver/src/exceptions/firebase_auth_exceptions.dart';
import 'package:on_demand_grocery_deliver/src/exceptions/firebase_exception.dart';
import 'package:on_demand_grocery_deliver/src/repositories/address_repository.dart';
import 'package:on_demand_grocery_deliver/src/routes/app_pages.dart';
import 'package:on_demand_grocery_deliver/src/utils/utils.dart';

class AuthenticationRepository extends GetxController {
  static AuthenticationRepository get instance => Get.find();
  final _auth = FirebaseAuth.instance;
  final deviceStorage = GetStorage();
  final _db = FirebaseFirestore.instance;

  User? get authUser => _auth.currentUser;

  @override
  void onReady() {
    screenRedirect();
  }

  void screenRedirect() async {
    final user = _auth.currentUser;
    FlutterNativeSplash.remove();
    if (user != null) {
      await checkUserRegistration(user);
    } else {
      Get.offAllNamed(HAppRoutes.login);
    }
  }

  Future<UserCredential> loginWithEmailAndPassword(
      String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw HFirebaseAuthException(code: e.code).message;
    } on FirebaseException catch (e) {
      throw HFirebaseException(code: e.code).message;
    } catch (e) {
      throw 'Đã xảy ra sự cố. Xin vui lòng thử lại sau.';
    }
  }

  Future<void> changePasswordWithEmailAndPassword(
      String email, String oldPassword, String newPassword) async {
    try {
      var credential =
          EmailAuthProvider.credential(email: email, password: oldPassword);
      return _auth.currentUser!
          .reauthenticateWithCredential(credential)
          .then((value) {
        _auth.currentUser!.updatePassword(newPassword);
      }).catchError((e) {
        throw 'Đã xảy ra sự cố. Xin vui lòng thử lại sau.';
      });
    } on FirebaseAuthException catch (e) {
      throw HFirebaseAuthException(code: e.code).message;
    } on FirebaseException catch (e) {
      throw HFirebaseException(code: e.code).message;
    } catch (e) {
      throw 'Mật khẩu hiện tại không đúng.';
    }
  }

  Future<UserCredential> registerWithEmailAndPassword(
      String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw HFirebaseAuthException(code: e.code).message;
    } on FirebaseException catch (e) {
      throw HFirebaseException(code: e.code).message;
    } catch (e) {
      throw 'Đã xảy ra sự cố. Xin vui lòng thử lại sau.';
    }
  }

  Future<void> sendEmailVerification() async {
    try {
      await _auth.currentUser!.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw HFirebaseAuthException(code: e.code).message;
    } on FirebaseException catch (e) {
      throw HFirebaseException(code: e.code).message;
    } catch (e) {
      throw 'Đã xảy ra sự cố. Xin vui lòng thử lại sau.';
    }
  }

  Future<void> sendPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw HFirebaseAuthException(code: e.code).message;
    } on FirebaseException catch (e) {
      throw HFirebaseException(code: e.code).message;
    } catch (e) {
      throw 'Đã xảy ra sự cố. Xin vui lòng thử lại sau.';
    }
  }

  Future<void> logOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      Get.offAllNamed(HAppRoutes.login);
    } on FirebaseAuthException catch (e) {
      throw HFirebaseAuthException(code: e.code).message;
    } on FirebaseException catch (e) {
      throw HFirebaseException(code: e.code).message;
    } catch (e) {
      throw 'Đã xảy ra sự cố. Xin vui lòng thử lại sau.';
    }
  }

  Future<void> checkUserRegistration(User user) async {
    try {
      bool userIsRegistered = false;
      await _db
          .collection('Stores')
          .where('Id', isEqualTo: user.uid)
          .get()
          .then((value) {
        userIsRegistered = value.size > 0 ? true : false;
      });
      if (userIsRegistered) {
        if (user.emailVerified) {
          Get.offAllNamed(HAppRoutes.root);
          final addressRepository = Get.put(AddressRepository());
          final addresses = await addressRepository.getUserAddress();
          if (addresses.isEmpty) {
            Get.toNamed(HAppRoutes.registrationStore);
          }
        } else {
          Get.offAllNamed(HAppRoutes.verify, arguments: {'email': user.email});
        }
      } else {
        HAppUtils.showSnackBarError('Lỗi', 'Cửa hàng chưa được đăng ký');
      }
    } catch (e) {
      Get.offAllNamed(HAppRoutes.login);
      HAppUtils.showSnackBarError(
          'Lỗi', 'Tài khoản cửa hàng chưa được đăng ký');
    }
  }
}
