class User {
  final String UserId;
  final String UserCode;
  final String RealName;
  final String CompanyCode;
  final String AreaCode;
  final String City;
  final String State;
  final String Country;
  final String PhoneNo;
  final String Email;
  final String CreatedDate;
  final String UpdatedDate;
  final String SalesRep;
  final String SalesSite;
  User({
    this.UserId,
    this.UserCode,
    this.RealName,
    this.CompanyCode,
    this.AreaCode,
    this.City,
    this.State,
    this.Country,
    this.PhoneNo,
    this.Email,
    this.CreatedDate,
    this.UpdatedDate,
    this.SalesRep,
    this.SalesSite,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      UserId: json['UserId'] as String,
      UserCode: json['UserCode'] as String,
      RealName: json['RealName'] as String,
      CompanyCode: json['CompanyCode'] as String,
      AreaCode: json['AreaCode'] as String,
      City: json['City'] as String,
      State: json['State'] as String,
      Country: json['Country'] as String,
      PhoneNo: json['PhoneNo'] as String,
      Email: json['Email'] as String,
      CreatedDate: json['CreatedDate'] as String,
      UpdatedDate: json['UpdatedDate'] as String,
      SalesRep: json['SalesRep'] as String,
      SalesSite: json['SalesSite'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'UserId': UserId,
      'UserCode': UserCode,
      'RealName': RealName,
      'CompanyCode': CompanyCode,
      'AreaCode': AreaCode,
      'City': City,
      'State': State,
      'Country': Country,
      'PhoneNo': PhoneNo,
      'Email': Email,
      'CreatedDate': CreatedDate,
      'UpdatedDate': UpdatedDate,
      'SalesRep': SalesRep,
      'SalesSite': SalesSite
    };
  }
}
