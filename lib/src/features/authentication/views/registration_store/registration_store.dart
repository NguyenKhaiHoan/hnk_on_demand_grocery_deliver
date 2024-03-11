import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:on_demand_grocery_deliver/src/constants/app_sizes.dart';
import 'package:on_demand_grocery_deliver/src/features/authentication/views/registration_store/widgets/form_registration_store_widget.dart';

class RegistrationStoreScreen extends StatefulWidget {
  const RegistrationStoreScreen({super.key});

  @override
  State<RegistrationStoreScreen> createState() =>
      _RegistrationStoreScreenState();
}

class _RegistrationStoreScreenState extends State<RegistrationStoreScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          GestureDetector(
            onTap: () {},
            child: const Icon(EvaIcons.close),
          ),
          gapW12
        ],
      ),
      body: const SingleChildScrollView(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
                hAppDefaultPadding, 0, hAppDefaultPadding, hAppDefaultPadding),
            child: FormRegistrationStoreWidget(),
          )
        ],
      )),
    );
  }
}
