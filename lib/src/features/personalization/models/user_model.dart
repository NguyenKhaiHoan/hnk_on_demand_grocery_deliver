import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String id;
  String name;
  String email;
  String phoneNumber;
  String storeImage;
  String storeImageBackground;
  String description;
  String creationDate;
  String authenticationBy;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    this.storeImage = '',
    this.storeImageBackground = '',
    required this.description,
    required this.creationDate,
    required this.authenticationBy,
  });

  static UserModel empty() => UserModel(
      id: '',
      name: '',
      email: '',
      phoneNumber: '',
      storeImage: '',
      storeImageBackground: '',
      description: '',
      creationDate: '',
      authenticationBy: '');

  Map<String, dynamic> toJon() {
    return {
      'Id': id,
      'Name': name,
      'Email': email,
      'PhoneNumber': phoneNumber,
      'StoreImage': storeImage,
      'StoreImageBackground': storeImageBackground,
      'Description': description,
      'CreationDate': creationDate,
      'AuthenticationBy': authenticationBy
    };
  }

  factory UserModel.fromDocumentSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;
    return UserModel(
        id: document.id,
        name: data['Name'] ?? '',
        email: data['Email'] ?? '',
        phoneNumber: data['PhoneNumber'] ?? '',
        storeImage: data['StoreImage'] ?? '',
        storeImageBackground: data['StoreImageBackground'] ?? '',
        description: data['Description'] ?? '',
        creationDate: data['CreationDate'] ?? '',
        authenticationBy: data['AuthenticationBy'] ?? '');
  }
}
