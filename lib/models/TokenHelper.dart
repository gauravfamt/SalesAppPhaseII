import 'package:flutter/material.dart';

class TokenHelper {
  int Id;
  String Token;
  String Username;
  String ApiDomain;

  TokenHelper({
    @required this.Id,
    @required this.Token,
    @required this.Username,
    @required this.ApiDomain,
  });

  factory TokenHelper.fromJson(Map<String, dynamic> json) {
    return TokenHelper(
      Id: json['Id'] as int,
      Token: json['Token'] as String,
      Username: json['Username'] as String,
      ApiDomain: json['ApiDomain'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': Id,
      'Token': Token,
      'Username':Username,
      'ApiDomain':ApiDomain,
    };
  }
}
