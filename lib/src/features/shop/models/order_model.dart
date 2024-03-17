import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:on_demand_grocery_deliver/src/features/personalization/models/delivery_person_model.dart';
import 'package:on_demand_grocery_deliver/src/features/shop/models/product_in_cart_model.dart';
import 'package:on_demand_grocery_deliver/src/features/shop/models/store_model.dart';
import 'package:on_demand_grocery_deliver/src/features/shop/models/user_address_model.dart';
import 'package:on_demand_grocery_deliver/src/features/shop/models/user_model.dart';

class OrderModel {
  String oderId;

  String orderUserId;
  List<String> orderStoreIds;
  List<ProductInCartModel> orderProducts;
  List<StoreModel> orderStores;
  UserModel orderUser;
  UserAddressModel orderUserAddress;
  DeliveryPersonModel? deliveryPerson;

  String? paymentMethod;
  String? paymentStatus;

  String? orderStatus;
  DateTime? orderDate;
  DateTime? waitingTimeForConfirmationFromStore;
  DateTime? waitingTimeForConfirmationFromDeliveryPerson;
  DateTime? waitingTimeForPickUp;
  DateTime? waitingTimeToArrive;
  bool? requestedForDelivery;

  OrderModel({
    required this.oderId,
    required this.orderUserId,
    required this.orderStoreIds,
    required this.orderProducts,
    required this.orderStores,
    required this.orderUser,
    required this.orderUserAddress,
    this.deliveryPerson,
    this.paymentMethod,
    this.paymentStatus,
    this.orderStatus,
    this.orderDate,
    this.waitingTimeForConfirmationFromStore,
    this.waitingTimeForConfirmationFromDeliveryPerson,
    this.waitingTimeForPickUp,
    this.waitingTimeToArrive,
    this.requestedForDelivery,
  });

  static OrderModel empty() => OrderModel(
        oderId: '',
        orderUserId: '',
        orderStoreIds: <String>[],
        orderProducts: <ProductInCartModel>[],
        orderStores: <StoreModel>[],
        orderUser: UserModel.empty(),
        orderUserAddress: UserAddressModel.empty(),
        deliveryPerson: DeliveryPersonModel.empty(),
      );

  Map<String, dynamic> toJson() {
    return {
      'OrderId': oderId,
      'UserId': orderUserId,
      'StoreId': orderStoreIds,
      'OrderProducts': orderProducts.map((e) => e.toJson()).toList(),
      'OrderStores': orderStores.map((e) => e.toJson()).toList(),
      'OrderUser': orderUser.toJon(),
      'OrderUserAddress': orderUserAddress.toJon(),
      'DeliveryPerson': deliveryPerson?.toJson(),
      'PaymentMethod': paymentMethod,
      'PaymentStatus': paymentStatus,
      'OrderStatus': orderStatus,
      'OrderDate': orderDate?.millisecondsSinceEpoch,
      'WaitingTimeForConfirmationFromStore':
          waitingTimeForConfirmationFromStore?.millisecondsSinceEpoch,
      'WaitingTimeForConfirmationFromDeliveryPerson':
          waitingTimeForConfirmationFromDeliveryPerson?.millisecondsSinceEpoch,
      'WaitingTimeForPickUp': waitingTimeForPickUp?.millisecondsSinceEpoch,
      'waitingTimeToArrive': waitingTimeToArrive?.millisecondsSinceEpoch,
      'RequestedForDelivery': requestedForDelivery ?? false,
    };
  }

  factory OrderModel.fromDocumentSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    if (document.data() != null) {
      final data = document.data()!;
      return OrderModel(
        oderId: document.id,
        orderUserId: data['OrderUserId'] ?? '',
        orderStoreIds: data['OrderStoreId'] ?? '',
        orderProducts: (data['OrderProducts'] as List<dynamic>)
            .map((e) => ProductInCartModel.fromJson(e))
            .toList(),
        orderStores: (data['OrderStores'] as List<dynamic>)
            .map((e) => StoreModel.fromJson(e))
            .toList(),
        orderUser: UserModel.fromJson(data['OderUser']),
        orderUserAddress: UserAddressModel.fromJson(data['OrderUserAddress']),
        deliveryPerson: DeliveryPersonModel.fromJson(data['DeliveryPerson']),
        paymentMethod: data['PaymentMethos'] ?? '',
        paymentStatus: data['PaymentStatus'] ?? '',
        orderStatus: data['OrderStatus'] ?? '',
        orderDate: DateTime.fromMillisecondsSinceEpoch(
            int.parse(data['OrderDate'] ?? 0)),
        waitingTimeForConfirmationFromStore:
            DateTime.fromMillisecondsSinceEpoch(
                int.parse(data['WaitingTimeForConfirmationFromStore'] ?? 0)),
        waitingTimeForConfirmationFromDeliveryPerson:
            DateTime.fromMillisecondsSinceEpoch(int.parse(
                data['WaitingTimeForConfirmationFromDeliveryPerson'] ?? 0)),
        waitingTimeForPickUp: DateTime.fromMillisecondsSinceEpoch(
            int.parse(data['WaitingTimeForPickUp'] ?? 0)),
        waitingTimeToArrive: DateTime.fromMillisecondsSinceEpoch(
            int.parse(data['WaitingTimeToArrive'] ?? 0)),
        requestedForDelivery: data['RequestedForDelivery'] != null
            ? data['RequestedForDelivery'] as bool
            : null,
      );
    }
    return OrderModel.empty();
  }
}
