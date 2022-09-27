import 'package:moblesales/helpers/index.dart';

class Address {
  final int Id;
  final String Code;
  final int TenantId;
  final String Address1;
  final String City;
  final String State;
  final String Country;
  final String PostCode;
  final String TelephoneNo;
  final String BusinessEmail;
  final String SalesSite;
  final String ShipSite;
  final int PortalCompanyId;
  final int PortalUserId;
  final String CustomerNo;
  final String Address2;
  final String Address3;
  final bool IsShipping;
  String DefaultBilling;
  String DefaultShipping;

  Address(
      {this.Id,
      this.Code,
      this.TenantId,
      this.Address1,
      this.City,
      this.State,
      this.Country,
      this.PostCode,
      this.TelephoneNo,
      this.BusinessEmail,
      this.SalesSite,
      this.ShipSite,
      this.PortalCompanyId,
      this.PortalUserId,
      this.CustomerNo,
      this.Address2,
      this.Address3,
      this.IsShipping,
      this.DefaultBilling,
      this.DefaultShipping});

  factory Address.fromJson(Map<String, dynamic> json) {
    bool _isShippingInt = json['IsShippingInt'] != null
        ? (json['IsShippingInt'] as int == 1 ? true : false)
        : json['IsShipping'] as bool;
    return Address(
        Id: json['Id'] as int,
        Code: json['Code'] as String,
        TenantId: json['TenantId'] as int,
        Address1: json['Address1'] as String,
        City: json['City'] as String,
        State: json['State'] as String,
        Country: json['Country'] as String,
        PostCode: json['PostCode'] as String,
        TelephoneNo: json['TelephoneNo'] as String,
        BusinessEmail: json['BusinessEmail'] as String,
        SalesSite: json['SalesSite'] as String,
        ShipSite: json['ShipSite'] as String,
        PortalCompanyId: json['PortalCompanyId'] as int,
        PortalUserId: json['PortalUserId'] as int,
        CustomerNo: json['CustomerNo'] as String,
        Address2: json['Address2'] as String,
        Address3: json['Address3'] as String,
        IsShipping: _isShippingInt,
        DefaultBilling: json['DefaultBilling'] as String,
        DefaultShipping: json['DefaultShipping'] as String);
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': Id,
      'Code': Code,
      'TenantId': TenantId,
      'Address1': Other().parseHtmlString(Address1),
      'City': Other().parseHtmlString(City),
      'State': Other().parseHtmlString(State),
      'Country': Other().parseHtmlString(Country),
      'PostCode': PostCode,
      'TelephoneNo': TelephoneNo,
      'BusinessEmail': BusinessEmail,
      'SalesSite': SalesSite,
      'ShipSite': ShipSite,
      'PortalCompanyId': PortalCompanyId,
      'PortalUserId': PortalUserId,
      'CustomerNo': CustomerNo,
      'Address2': Other().parseHtmlString(Address2),
      'Address3': Other().parseHtmlString(Address3),
      'IsShipping': IsShipping,
      'DefaultBilling': DefaultBilling,
      'DefaultShipping': DefaultShipping
    };
  }
}
