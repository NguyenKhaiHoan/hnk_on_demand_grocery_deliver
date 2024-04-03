import 'package:cloud_firestore/cloud_firestore.dart';

class DeliveryPersonModel {
  String id;
  String name;
  String email;
  String image;
  String phoneNumber;
  String? vehicleRegistrationNumber;
  String? drivingLicenseNumber;
  String? vehicleRegistrationNumberImage;
  String? drivingLicenseNumberImage;
  String? creationDate;
  bool status;
  String cloudMessagingToken;
  String? authenticationBy;
  bool? isActiveAccount;

  DeliveryPersonModel(
      {required this.id,
      required this.name,
      required this.image,
      required this.email,
      required this.phoneNumber,
      this.vehicleRegistrationNumber,
      this.drivingLicenseNumber,
      this.vehicleRegistrationNumberImage,
      this.drivingLicenseNumberImage,
      this.creationDate,
      required this.status,
      required this.cloudMessagingToken,
      this.authenticationBy,
      this.isActiveAccount});

  static DeliveryPersonModel empty() => DeliveryPersonModel(
      isActiveAccount: false,
      id: '',
      name: '',
      image: '',
      email: '',
      phoneNumber: '',
      vehicleRegistrationNumber: '',
      drivingLicenseNumber: '',
      vehicleRegistrationNumberImage: '',
      drivingLicenseNumberImage: '',
      creationDate: '',
      status: false,
      cloudMessagingToken: '',
      authenticationBy: '');

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'Name': name,
      'Image': image,
      'Email': email,
      'PhoneNumber': phoneNumber,
      'VehicleRegistrationNumber': vehicleRegistrationNumber,
      'DrivingLicenseNumber': drivingLicenseNumber,
      'VehicleRegistrationNumberImage': vehicleRegistrationNumberImage,
      'DrivingLicenseNumberImage': drivingLicenseNumberImage,
      'CreationDate': creationDate,
      'Status': status,
      'CloudMessagingToken': cloudMessagingToken,
      'AuthenticationBy': authenticationBy,
      'IsActiveAccount': isActiveAccount,
    };
  }

  factory DeliveryPersonModel.fromDocumentSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    if (document.data() != null) {
      final data = document.data()!;
      return DeliveryPersonModel(
          id: document.id,
          name: data['Name'] ?? '',
          image: data['Image'] ?? '',
          email: data['Email'] ?? '',
          phoneNumber: data['PhoneNumber'] ?? '',
          vehicleRegistrationNumber: data['VehicleRegistrationNumber'] ?? '',
          drivingLicenseNumber: data['DrivingLicenseNumber'] ?? '',
          vehicleRegistrationNumberImage:
              data['VehicleRegistrationNumberImage'] ?? '',
          drivingLicenseNumberImage: data['DrivingLicenseNumberImage'] ?? '',
          creationDate: data['CreationDate'] ?? '',
          status: data['Status'] ?? false,
          cloudMessagingToken: data['CloudMessagingToken'] ?? '',
          authenticationBy: data['AuthenticationBy'] ?? '',
          isActiveAccount: data['IsActiveAccount'] ?? false);
    }
    return DeliveryPersonModel.empty();
  }

  factory DeliveryPersonModel.fromJson(Map<String, dynamic> json) {
    return DeliveryPersonModel(
      id: json['Id'] ?? '',
      name: json['Name'] ?? '',
      image: json['Image'] ?? '',
      email: json['Email'] ?? '',
      phoneNumber: json['PhoneNumber'] ?? '',
      status: json['Status'] ?? false,
      cloudMessagingToken: json['CloudMessagingToken'] ?? '',
    );
  }
}
