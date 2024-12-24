import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GlobalVariables {
  static String? deviceToken = '';
  static String username = '';
  static List<File> mainImage = [];
  static List<File> mainImage2 = [];
  static String avatarImage = '1';
  static String avatarImage1 = '1';
  static double space = 0;
  static String reservationStart = '';
  static String reservationEnd = '';
  static String dragFlag = '';
  static bool accepted = false;
  static String landingavatar = "";
  static String landingurl = "";
  static String landingname = "";
  static var memberlist = [];
  static double riderLat = 0.0;
  static String driverPhoto = "";
  static double riderLng = 0.0;
  static double driverLng = 0.0;
  static double driverLat = 0.0;
  static double desLat = 0.0;
  static int progress = 0;
  static double desLng = 0.0;
  static bool flag = false;
  static List<String> messages = [];
  static var chatroom = [];
  static int orderID = 0;
  static List<String> imageUrls = List.filled(22, '');
  static List<String> imageUrls1 = List.filled(21, '');
  static var idCard = [];
  static String totalEarning = "";
  static var idCard1 = [];
  static int index = 0;
  static int? riderID;
  static var tabArray = [];
  static bool isTyping = false;
  static List<String> tabs = [];
  static List<Widget> tabScreens = [];
  static void copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
  }
}
