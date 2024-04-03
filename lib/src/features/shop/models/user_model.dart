import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String id;
  String name;
  String email;
  String phoneNumber;
  String profileImage;
  String creationDate;
  String authenticationBy;
  String? cloudMessagingToken;

  UserModel(
      {required this.id,
      required this.name,
      required this.email,
      required this.phoneNumber,
      required this.profileImage,
      required this.creationDate,
      required this.authenticationBy,
      this.cloudMessagingToken});

  static UserModel empty() => UserModel(
        id: '',
        name: '',
        email: '',
        phoneNumber: '',
        profileImage: '',
        creationDate: '',
        authenticationBy: '',
      );

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'Name': name,
      'Email': email,
      'PhoneNumber': phoneNumber,
      'ProfileImage': profileImage,
      'CreationDate': creationDate,
      'AuthenticationBy': authenticationBy,
      'CloudMessagingToken': cloudMessagingToken
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
        profileImage: data['ProfileImage'] ?? '',
        creationDate: data['CreationDate'] ?? '',
        authenticationBy: data['AuthenticationBy'] ?? '',
        cloudMessagingToken: data['CloudMessagingToken'] ?? '');
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['Id'] ?? '',
      name: json['Name'] ?? '',
      email: json['Email'] ?? '',
      phoneNumber: json['PhoneNumber'] ?? '',
      profileImage: json['ProfileImage'] ?? '',
      creationDate: json['CreationDate'] ?? '',
      authenticationBy: json['AuthenticationBy'] ?? '',
      cloudMessagingToken: json['CloudMessagingToken'],
    );
  }
}
