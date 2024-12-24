import '../common/stoplocation.dart';

class RequestModel {
  String? riderName;
  String? distance;
  double? rating;
  String? riderToken;
  String? startLocation;
  String? endLocation;
  String? period;
  String? currentPostion;
  int? riderID;
  int? orderID;
  String? cost;
  double? riderlatitude;
  double? riderlongitude;
  List<StopLocation>? stopLocations;


  RequestModel({this.startLocation,this.orderID,this.riderlongitude, this.riderlatitude, this.currentPostion, this.riderToken, 
  this.riderID, this.distance, this.riderName, this.rating, this.endLocation, this.period, this.cost});

  RequestModel.fromJson(Map<String, dynamic> json) {
    startLocation = json['start_location'];
    riderID = json['riderID'];
    orderID = int.parse(json['orderID']);
    endLocation = json['end_location'];
    riderToken = json['riderToken'];
    period = json['period'];
    cost = json['cost'];
    riderlongitude = json['longitude'];
    riderlatitude = json['latitude'];
    riderName = json['riderName'];
    distance = json['route_distance'];
    riderID = json['riderId'];

     if (json['stop_locations'] != null) {
      stopLocations = (json['stop_locations'] as List)
          .map((stop) => StopLocation.fromJson(stop))
          .toList();
    }
  }
}