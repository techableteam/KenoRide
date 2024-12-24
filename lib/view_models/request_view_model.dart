import 'package:kenorider_driver/services/useDio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/request_model.dart';
import 'package:localstorage/localstorage.dart';
import 'package:logger/logger.dart';
import '../common/stoplocation.dart';
import 'dart:convert';
import 'package:kenorider_driver/common/Global_variable.dart';

class RequestViewModel extends ChangeNotifier {
  final logger = Logger();
  final RequestModel _request = RequestModel();
  RequestModel get request => _request;
  String _status = '';
  String get status => _status;

  void setStatus(String value){
    _status = value;
    notifyListeners();
  }

  Map<String, dynamic> _data = {};

  Map<String, dynamic> get data => _data;

  void updateFromData(Map<String, dynamic> newData) {
    if (newData.containsKey('period')) {
      setPeriod(newData['period'].toString());
    }
    if (newData.containsKey('riderName')) {
      setRiderName(newData['riderName'].toString());
    }  
    if (newData.containsKey('end_location')) {
      setEnd(newData['end_location'].toString());
    }
    if (newData.containsKey('start_location')) {
      setStart(newData['start_location'].toString());
    }
    if (newData.containsKey('orderID')) {
      setOrderID(int.parse(newData['orderID']));
    }
    if (newData.containsKey('cost')) {
      setCost(newData['cost'].toString());
    }
      if (newData.containsKey('rating')) {
      setRating(double.parse(newData['rating'].toString()));
    }
    if (newData.containsKey('riderID')) {
      setRiderID(int.parse(newData['riderID']));
    }
    if(newData.containsKey('route_distance')){
      setDistance(newData['route_distance'].toString());
    }
    if(newData.containsKey('status')){
      setStatus(newData['status'].toString());
    }
    // if(newData.containsKey('status')){
    //   setStatus(newData['status'].toString());
    // }
    // if(newData.containsKey('status')){
    //   setStatus(newData['status'].toString());
    // }
    if (newData.containsKey('stop_locations') && newData['stop_locations'] != null) {
      var stopLocationsData = newData['stop_locations'];
      
      if (stopLocationsData is String && stopLocationsData.isNotEmpty) {
        // If stop_locations is a JSON-encoded string, decode it first
        try {
          List<dynamic> decodedStops = jsonDecode(stopLocationsData);
          List<StopLocation> stops = decodedStops
              .where((stop) => stop != null) // Filter out any null stops
              .map((stop) => StopLocation.fromJson(stop))
              .toList();
          setStopLocations(stops);
          localStorage.setItem("stop_positions", jsonEncode(stops));
        } catch (e) {
          // Handle JSON decoding error
          setStopLocations([]); // If decoding fails, set an empty list
        }
      } else if (stopLocationsData is List) {
        // If stop_locations is already a List, map it to StopLocation objects
        List<StopLocation> stops = stopLocationsData
            .where((stop) => stop != null) // Filter out any null stops
            .map((stop) => StopLocation.fromJson(stop))
            .toList();
        setStopLocations(stops);
        localStorage.setItem("stop_positions", jsonEncode(stops));
      } else {
        // If stop_locations is not a valid type (String or List), set an empty list
        setStopLocations([]);
      }
    } else {
      // Handle the case where stop_locations is null or missing
      setStopLocations([]); // Set an empty list or handle it accordingly
    }

    // Add other fields as needed
    notifyListeners();
  }

  void setStopLocations(List<StopLocation> stops) {
    _request.stopLocations = stops;
    notifyListeners();
  }

  void setData(Map<String, dynamic> newData) {
    _data = newData;
    notifyListeners();
    updateFromData(newData);
  }
  void setLongitude(double longitude){
    _request.riderlongitude = longitude;
    notifyListeners();
  }
  void setLangitude(double latitude){
    _request.riderlatitude = latitude;
  }
  void setRiderID(int riderID){
    _request.riderID = riderID;
    localStorage.setItem("riderID", riderID.toString());
    notifyListeners();
  }
  void setDistance(String distance){
    _request.distance = distance;
    notifyListeners();
  }
  void setCost(String cost){
    _request.cost = cost;
    notifyListeners();
  }
  void setRiderName(String name){
    _request.riderName = name;
    notifyListeners();
  }
  void setOrderID(int id){
    _request.orderID = id;
    localStorage.setItem('orderID', id.toString());
    notifyListeners();
  }
  void setRiderToken(String token){
    _request.riderToken = token;
    notifyListeners();
  }
  void setRating(double rating){
    _request.rating = rating;
    notifyListeners();
  }
  void setStart(String start){
    _request.startLocation = start;
    localStorage.setItem('startLocation', start.toString());
    notifyListeners();
  }
  void setEnd(String end){
    _request.endLocation = end;
    localStorage.setItem('endLocation', end.toString());
    notifyListeners();
  }
  void setPeriod(String period){
    _request.period = period;
    notifyListeners();
  }
  Future<int> acceptRequest() async{
    final DioService dioService = DioService();
    final data = {
      'riderID': request.riderID,
      'driverID': int.parse(localStorage.getItem('driverID')!),
      "driverlongitude": GlobalVariables.driverLng,
      "driverlatitude": GlobalVariables.driverLat,
      "orderID": request.orderID
    };
    logger.i("accept requst : $data");
    GlobalVariables.riderID = request.riderID;
    try {
      final response =await dioService.postRequest('/accept', data: data);
      logger.i("accept response : $response");
      if (response.statusCode == 200) {
          return 200;
      } else {
        // Handle error response
        return 200;
      }
    } catch (e) {
      return 200;
    }
  }
  Future<int> arrivedRequest() async{
  final DioService dioService = DioService();
  final data = {
    'riderID': request.riderID,
    'driverID': int.parse(localStorage.getItem('driverID')!),
  };
  logger.i(data);
    try {
      final response = await dioService.postRequest('/arrived', data: data);
      logger.i(response);
      if (response.statusCode == 200) {
          return 200;
      } else {
        // Handle error response
        return 404;
      }
    } catch (e) {
      logger.i(e);
      return 501;
    }
  }
  Future<int> finishRequest() async{
  final DioService dioService = DioService();
  final data = {
    'riderID': request.riderID,
    'driverID': int.parse(localStorage.getItem('driverID')!),
  };
    try {
      final response =
          await dioService.postRequest('/finish', data: data);
      if (response.statusCode == 200) {
          return 200;
      } else {
        // Handle error response
        return 404;
      }
    } catch (e) {
      return 501;
    }
  }
  Future<int> tripRequest() async{
    final DioService dioService = DioService();
    final data = {
      'riderID': request.riderID,
      'driverID': int.parse(localStorage.getItem('driverID')!),
    };
    try {
      final response =
          await dioService.postRequest('/trip', data: data);
      if (response.statusCode == 200) {
          return 200;
      } else {
        // Handle error response
        return 404;
      }
    } catch (e) {
      return 501;
    }
  }

  Future<int> startTripRequest() async{
    final DioService dioService = DioService();
    final data = {
      'orderID': int.parse(localStorage.getItem('orderID')!),
      'driverID': int.parse(localStorage.getItem('driverID')!),
      'riderID': int.parse(localStorage.getItem('riderID')!),
    };
    logger.i("startTripRequest data : $data");
    try {
      final response = await dioService.postRequest('/start_trip_request', data: data);
      if (response.statusCode == 200) {
          return 200;
      } else {
        // Handle error response
        return 404;
      }
    } catch (e) {
      return 501;
    }
  }

  Future<int> reviewSubmit(String rating, String comment) async{
    final DioService dioService = DioService();
    final data = {
      'orderID': int.parse(localStorage.getItem('orderID')!),
      'driverID': int.parse(localStorage.getItem('driverID')!),
      'riderID' : localStorage.getItem("riderID"),
      'rating': rating,
      'comment': comment
    };
    try {
      final response = await dioService.postRequest('/review_client', data: data);
      if (response.statusCode == 200) {
          return 200;
      } else {
        // Handle error response
        return 404;
      }
    } catch (e) {
      return 501;
    }
  }
}
