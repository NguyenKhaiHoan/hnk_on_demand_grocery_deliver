import 'package:cloud_firestore/cloud_firestore.dart';

class UserAddressModel {
  String id;
  String name;
  String phoneNumber;
  String city;
  String district;
  String ward;
  String street;
  bool selectedAddress;
  bool isChoseCurrentAddress;
  double latitude;
  double longitude;

  UserAddressModel(
      {required this.id,
      required this.name,
      required this.phoneNumber,
      this.city = 'Hà Nội',
      required this.district,
      required this.ward,
      required this.street,
      this.selectedAddress = true,
      required this.latitude,
      required this.longitude,
      this.isChoseCurrentAddress = true});

  static UserAddressModel empty() => UserAddressModel(
        id: '',
        name: '',
        phoneNumber: '',
        district: '',
        ward: '',
        street: '',
        latitude: 0,
        longitude: 0,
      );

  Map<String, dynamic> toJon() {
    return {
      'Name': name,
      'PhoneNumber': phoneNumber,
      'City': city,
      'District': district,
      'Ward': ward,
      'Street': street,
      'SelectedAddress': selectedAddress,
      'Latitude': latitude,
      'Longitude': longitude,
    };
  }

  factory UserAddressModel.fromDocumentSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    if (document.data() != null) {
      final data = document.data()!;
      return UserAddressModel(
        id: document.id,
        name: data['Name'] ?? '',
        phoneNumber: data['PhoneNumber'] ?? '',
        city: data['City'] ??= 'Hà Nội',
        district: data['District'] ?? '',
        ward: data['Ward'] ?? '',
        street: data['Street'] ?? '',
        selectedAddress: data['SelectedAddress'] as bool,
        latitude: double.parse((data['Latitude'] ?? 0.0).toString()),
        longitude: double.parse((data['Longitude'] ?? 0.0).toString()),
      );
    }
    return UserAddressModel.empty();
  }

  factory UserAddressModel.fromJson(Map<String, dynamic> json) {
    return UserAddressModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      city: json['city'] ?? '',
      district: json['district'] ?? '',
      ward: json['ward'] ?? '',
      street: json['street'] ?? '',
      selectedAddress: json['selectedAddress'] ?? false,
      isChoseCurrentAddress: json['isChoseCurrentAddress'] ?? false,
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
    );
  }
}
