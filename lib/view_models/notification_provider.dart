import 'package:flutter/material.dart';


class NotificationProvider extends ChangeNotifier {
  Map<String, dynamic>? _messageData;

  Map<String, dynamic>? get messageData => _messageData;

  void setMessageData(Map<String, dynamic> messageData) {
    _messageData = messageData;
    notifyListeners();
  }

  void clearMessageData() {
    _messageData = null;
    notifyListeners();
  }
}