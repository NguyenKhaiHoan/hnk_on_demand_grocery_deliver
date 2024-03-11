import 'package:cloud_firestore/cloud_firestore.dart';

class AddressModel {
  String id;
  String city;
  String district;
  String ward;
  String street;
  double latitude;
  double longitude;

  AddressModel({
    required this.id,
    this.city = 'Hà Nội',
    required this.district,
    required this.ward,
    required this.street,
    required this.latitude,
    required this.longitude,
  });

  static AddressModel empty() => AddressModel(
        id: '',
        district: '',
        ward: '',
        street: '',
        latitude: 0.0,
        longitude: 0.0,
      );

  @override
  String toString() {
    return '$street, ${ward.isEmpty ? '' : '$ward,'} $district, $city';
  }

  Map<String, dynamic> toJon() {
    return {
      'City': city,
      'District': district,
      'Ward': ward,
      'Street': street,
      'Latitude': latitude,
      'Longitude': longitude,
    };
  }

  factory AddressModel.fromDocumentSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    if (document.data() != null) {
      final data = document.data()!;
      return AddressModel(
        id: document.id,
        city: data['City'] ??= 'Hà Nội',
        district: data['District'] ?? '',
        ward: data['Ward'] ?? '',
        street: data['Street'] ?? '',
        latitude: double.parse((data['Latitude'] ?? 5.0).toString()),
        longitude: double.parse((data['Longitude'] ?? 5.0).toString()),
      );
    }
    return AddressModel.empty();
  }
}
