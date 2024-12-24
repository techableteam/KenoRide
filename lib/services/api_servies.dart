import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kenorider_driver/common/Global_variable.dart';
import '../models/driver_model.dart';
import 'package:localstorage/localstorage.dart';
import 'package:logger/logger.dart';

class ApiService {
  final String baseUrl =
      "https://admin.kenoride.ca/api/";
  String apiKey = 'cfdb0e89363c14687341dbc25d1e1d43';
  static final Logger logger = Logger(); 

  // ignore: prefer_typing_uninitialized_variables
  var token;
  Future<Map<String, dynamic>> registerDriver(DriverModel driver) async {
    var url = Uri.parse('https://api.imgbb.com/1/upload');
    var base64Images = [
      driver.licenseVerification,
      driver.driverPhoto,
      driver.carPhoto
    ];
    var imageUrls = [];
    for (var base64Image in base64Images) {
      var response = await http.post(url, body: {
        'key': apiKey,
        'image': base64Image,
      });
      imageUrls.add(jsonDecode(response.body)['data']['url']);
    }
    final response = await http.post(
      Uri.parse("https://admin.kenoride.ca/api/registerDriver"),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'full_name': driver.fullName,
        'email': driver.email,
        'phone_number': driver.phoneNumber,
        'password': driver.password,
        'city': driver.city,
        "rating": 0.0,
        "credit": 0.0,
        'car_type': driver.carType,
        'car_color': driver.carColor,
        'car_number': driver.carNumber,
        'device_token': GlobalVariables.deviceToken,
        "license_verification": imageUrls[0],
        "driver_photo": imageUrls[1],
        "car_photo": imageUrls[2],
        'license_number': driver.licenseNo
      }),
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      String id = responseBody['driverID'].toString();
      String rating = responseBody['rating'].toString();
      String credit = responseBody['credit'].toString();
      await initLocalStorage();
      localStorage.setItem('driverID', id);
      localStorage.setItem('driverName', responseBody['driverName']);
      localStorage.setItem('access_token', responseBody['access_token']);
      localStorage.setItem('rating', rating);
      localStorage.setItem('creditCard', credit);
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to register driver');
    }
  }

  static Future<void> logout() async {
    localStorage.removeItem("user");
  }

  static Future<int> loginDriver(
      String email, String password, String method) async {
    final String flag = method == 'email'
        ? 'email'
        : 'phone_number'; // Determine the flag based on the method
    final url = Uri.parse('https://admin.kenoride.ca/api/loginDriver');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'method': flag,
      flag: email,
      'password': password,
      'driver_token': GlobalVariables.deviceToken
    });
    final response = await http.post(url, headers: headers, body: body);
    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      // ignore: non_constant_identifier_names
      String ID = responseBody['driverID'].toString();
      String rating = responseBody['rating'].toString();
      String credit = responseBody['credit'].toString();
      await initLocalStorage();
      localStorage.setItem('driverID', ID);
      localStorage.setItem('driverName', responseBody['driverName']);
      localStorage.setItem('access_token', responseBody['access_token']);
      localStorage.setItem('rating', rating);
      localStorage.setItem('creditCard', credit);
      return response.statusCode;
    } else {
      return response.statusCode;
    }
  }

  static Future<int> loginDriverByphone(String email, String method) async {
    final String flag = method == 'email'
        ? 'email'
        : 'phone_number'; // Determine the flag based on the method
    final url = Uri.parse('https://admin.kenoride.ca/api/loginDriver');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'method': flag,
      flag: email,
      'driver_token': GlobalVariables.deviceToken
    });
    final response = await http.post(url, headers: headers, body: body);
    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      // ignore: non_constant_identifier_names
      String ID = responseBody['driverID'].toString();
      await initLocalStorage();
      localStorage.setItem('driverID', ID);
      localStorage.setItem('driverName', responseBody['driverName']);
      localStorage.setItem('access_token', responseBody['access_token']);
      return response.statusCode;
    } else {
      return 404;
    }
  }

  static Future<void> sendLocationToBackend(double latitude, double longitude, int status) async {
    final url = Uri.parse('https://admin.kenoride.ca/api/update_driver_location');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'driver_id': localStorage.getItem('driverID'),
      "rider_id": GlobalVariables.riderID,
      'lat': latitude.toString(),
      'lng': longitude.toString(),
      'status' : status
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        logger.i("Location send successfully: ${response.body}");
      } else {
        logger.i("Failed to send location: ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      logger.i("Error sending location to backend: $e");
    }
  }

  static Future<int> sendVerifyCode(String phoneNumber, String flag) async {
    final url = Uri.parse('https://admin.kenoride.ca/api/sendVerificationCode');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'method': flag, 'phone_number': phoneNumber});
    logger.i("request: $body");
    final response = await http.post(url, headers: headers, body: body);
    logger.i("sendVerifyCode: $response");
    if (response.statusCode != 404) {
      final responseData = jsonDecode(response.body);
      logger.i("responseData : $responseData");
      return response.statusCode;
    } else {
      return 404;
    }
  }

  static Future<int> confirmVerifyCode(String phoneNumber, String code, String flag, int tmpId) async {
    final url = Uri.parse('https://admin.kenoride.ca/api/confirmVerificationCode');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'method': flag, 'phone_number': phoneNumber, 'verifyCode': code, 'tmp_id': tmpId});
    logger.i("request: $body");
    final response = await http.post(url, headers: headers, body: body);
    logger.i("sendVerifyCode: $response");
    if (response.statusCode != 404) {
      final responseData = jsonDecode(response.body);
      logger.i("responseData : $responseData");
      return response.statusCode;
    } else {
      return 404;
    }
  }

  static Future<int> updateToken(String? id, String? token, String flag) async {
    final url = Uri.parse('https://admin.kenoride.ca/api/updateToken');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'method': flag, 'id': id, 'token': token});
    logger.i("request: $body");
    final response = await http.post(url, headers: headers, body: body);
    logger.i("updateToken: $response");
    if (response.statusCode != 404) {
      return response.statusCode;
    } else {
      return 404;
    }
  }
}