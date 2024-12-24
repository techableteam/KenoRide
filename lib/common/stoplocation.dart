class StopLocation {
  String? position;
  String? address;

  StopLocation({this.position, this.address});

  StopLocation.fromJson(Map<String, dynamic> json) {
    position = json['position'];
    address = json['address'];
  }

  Map<String, dynamic> toJson() {
    return {
      'position': position,
      'address': address,
    };
  }
}