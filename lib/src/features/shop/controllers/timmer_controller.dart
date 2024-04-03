import 'dart:async';
import 'package:get/get.dart';
import 'package:on_demand_grocery_deliver/src/features/shop/controllers/order_controller.dart';

class TimerController extends GetxController {
  final String tag;
  TimerController(this.tag);

  static const maxSeconds = 60;
  final Rx<DateTime> _endTime = DateTime.now().obs;
  var difference = Duration.zero.obs;
  var isTimerStarted = false.obs;
  final RxString _timeLeft = '00'.obs;
  String get timeLeft => _timeLeft.value;
  Timer? timer;

  var isInOrderDetailScreen = false.obs;

  void startTimer(Duration temporarySecond) {
    _endTime.value = DateTime.now().add(temporarySecond);
    updateDifference();
  }

  void updateDifference() {
    difference.value = _endTime.value.difference(DateTime.now());
    update();
  }

  @override
  void onInit() {
    ever(isTimerStarted, _handleTimerStartedChange);
    ever(difference, _handleDifferenceChange);
    super.onInit();
  }

  @override
  void onClose() {
    timer?.cancel();
    super.onClose();
  }

  void _handleTimerStartedChange(bool event) {
    if (event) {
      timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
        updateDifference();
      });
    } else {
      timer?.cancel();
    }
  }

  final orderController = OrderController.instance;

  void _handleDifferenceChange(Duration event) {
    if (event.inSeconds <= 0) {
      removeOrder();
    } else {
      isTimerStarted.value = true;
      _timeLeft.value = formatDuration(event);
    }
  }

  void removeOrder() {
    if (!isInOrderDetailScreen.value ||
        OrderController.instance.acceptOrder.value != 1) {
      Get.back();
      timer?.cancel();
      isTimerStarted.value = false;
      _timeLeft.value = '00';
      orderController.removeOrder(tag);
      Get.delete<TimerController>(tag: tag);
    }
    timer?.cancel();
    isTimerStarted.value = false;
    _timeLeft.value = '00';
    orderController.removeOrder(tag);
  }

  String formatDuration(Duration value) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final String twoDigitSeconds = twoDigits(value.inSeconds.remainder(60));
    return twoDigitSeconds;
  }
}
