import 'package:flutter/material.dart';
import 'package:image_network/image_network.dart';
import 'package:on_demand_grocery_deliver/src/common_widgets/custom_shimmer_widget.dart';
import 'package:on_demand_grocery_deliver/src/constants/app_colors.dart';
import 'package:on_demand_grocery_deliver/src/features/personalization/controllers/user_controller.dart';

class UserImageLogoWidget extends StatelessWidget {
  UserImageLogoWidget({
    super.key,
    required this.size,
    required this.hasFunction,
  });

  final bool hasFunction;
  final deliveryPersonController = DeliveryPersonController.instance;

  final double size;

  @override
  Widget build(BuildContext context) {
    return deliveryPersonController.isLoading.value ||
            deliveryPersonController.isUploadImageLoading.value
        ? CustomShimmerWidget.circular(width: size, height: size)
        : deliveryPersonController.user.value.image == ''
            ? GestureDetector(
                onTap: () {},
                child: SizedBox(
                  width: size,
                  height: size,
                  child: const CircleAvatar(
                    backgroundImage: AssetImage('assets/logos/logo.png'),
                  ),
                ))
            : ImageNetwork(
                image: deliveryPersonController.user.value.image,
                height: size,
                width: size,
                duration: 500,
                curve: Curves.easeIn,
                onPointer: true,
                debugPrint: false,
                fullScreen: false,
                fitAndroidIos: BoxFit.cover,
                fitWeb: BoxFitWeb.cover,
                borderRadius: BorderRadius.circular(100),
                onLoading:
                    CustomShimmerWidget.circular(width: size, height: size),
                onError: const Icon(
                  Icons.error,
                  color: Colors.red,
                ),
                onTap: () => null,
              );
  }
}
