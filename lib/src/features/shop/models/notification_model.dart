import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NotificationModel {
  String id;
  Icon? icon;
  final String title;
  final String body;
  final DateTime time;
  final String type; // order, store, product
  String? storeId;
  String? orderId;
  String? productId;
  NotificationModel(
      {required this.id,
      required this.title,
      required this.body,
      required this.time,
      required this.type,
      this.orderId,
      this.productId,
      this.storeId,
      this.icon});

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'Title': title,
      'Body': body,
      'Time': time.millisecondsSinceEpoch,
      'Type': type,
      'OrderId': orderId,
      'ProductId': productId,
      'StoreId': storeId,
    };
  }

  factory NotificationModel.fromDocumentSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    if (document.data() != null) {
      final data = document.data()!;
      return NotificationModel(
        id: document.id,
        title: data['Title'] ?? '',
        body: data['Body'] ?? '',
        time:
            DateTime.fromMillisecondsSinceEpoch(int.parse((data['Time'] ?? 0))),
        type: data['Type'] ?? '',
        storeId: data['StoreId'] != null ? data['StoreId'] : null,
        orderId: data['OrderId'] != null ? data['OrderId'] : null,
        productId: data['ProductId'] != null ? data['ProductId'] : null,
      );
    }
    return NotificationModel.empty();
  }

  static NotificationModel empty() => NotificationModel(
      id: '', title: '', body: '', time: DateTime.now(), type: '');
}
