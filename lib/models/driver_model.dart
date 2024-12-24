class DriverModel {
  String? driver;
  String? fullName;
  String? email;
  String? phoneNumber;
  String? password;
  String? passwordConfirmation;
  String? city;
  String? carType;
  String? carColor;
  String? carNumber;
  String? licenseNo;
  double? rating;
  String? licenseVerification;
  String? driverPhoto;
  String? carPhoto;
  String? driverToken;
  double? credit;
  bool? flag;

  DriverModel(
      {this.driver,
      this.fullName,
      this.email,
      this.phoneNumber,
      this.password,
      this.passwordConfirmation,
      this.carType,
      this.carColor,
      this.carNumber,
      this.rating,
      this.city,
      this.licenseVerification,
      this.driverPhoto,
      this.carPhoto,
      this.driverToken,
      this.credit,
      this.flag,
      this.licenseNo});
  Map<String, dynamic> toJson() {
    return {
      'driver': driver,
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      'password': password,
      'password_confirmation': passwordConfirmation,
      'city': city,
      'credit': credit,
      'driver_token':driverToken,
      'flag':flag,
      'car_type': carType,
      'car_color': carColor,
      'car_number': carNumber,
      'rating': rating,
      'license_verification': licenseVerification,
      'driver_photo': driverPhoto,
      'car_photo': carPhoto,
      'license_no': licenseNo
    };
  }

  DriverModel.fromJson(Map<String, dynamic> json) {
    driver = json['driver'];
    fullName = json['full_name'];
    email = json['email'];
    phoneNumber = json['phone_number'];
    password = json['password'];
    passwordConfirmation = json['password_confirmation'];
    carType = json['car_type'];
    carColor = json['car_color'];
    driverToken = json['driver_token'];
    carNumber = json['car_number'];
    rating = json['rating'];
    credit = json['credit'];
    licenseVerification = json['license_verification'];
    driverPhoto = json['driver_photo'];
    licenseNo = json['licence_no'];
    carPhoto = json['car_photo'];
  }
}
