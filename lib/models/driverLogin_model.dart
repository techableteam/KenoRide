class DriverLoginModel {
  String? email;
  String? password;
  String? phoneNumber;

  DriverLoginModel({this.email, this.password, this.phoneNumber});

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'phone_number': phoneNumber,
    };
  }

  DriverLoginModel.fromJson(Map<String, dynamic> json) {
    email = json['email'];
    password = json['password'];
    phoneNumber = json['phone_number'];
  }
}
