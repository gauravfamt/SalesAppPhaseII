import 'package:moblesales/helpers/index.dart';
import 'package:moblesales/models/index.dart';

class Company {
  final int Id;
  final String Name;
  final String CustomerNo;
  final int TenantId;
  final String CurrencyCode;
  final double CreditLimit;
  final double Balance;
  final String DefaultBillAdd;
  String DefaultShippAdd;
  final String Type;
  final String SalesRep;
  final double TotalBalance;
  final bool IsActive;
  final List<Address> addresses;
  final List<Contact> contacts;
  bool IsSelected;

  Company({
    this.Id,
    this.Name,
    this.CustomerNo,
    this.TenantId,
    this.CurrencyCode,
    this.CreditLimit,
    this.Balance,
    this.DefaultBillAdd,
    this.DefaultShippAdd,
    this.Type,
    this.SalesRep,
    this.TotalBalance,
    this.IsActive,
    this.addresses,
    this.contacts,
    this.IsSelected,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    var addressListFromJson = json['addresses'] as List;

    List<Address> addressList = addressListFromJson != null
        ? addressListFromJson.map((i) => Address.fromJson(i)).toList()
        : [];

    var contactListFromJson = json['contacts'] as List;
    List<Contact> contactList = contactListFromJson != null
        ? contactListFromJson.map((i) => Contact.fromJson(i)).toList()
        : [];

    bool isActiveInt = json['isActiveInt'] != null
        ? (json['isActiveInt'] as int == 1 ? true : false)
        : json['IsActive'] as bool;

    return Company(
      Id: json['Id'] as int,
      Name: json['Name'] as String,
      CustomerNo: json['CustomerNo'] as String,
      TenantId: json['TenantId'] as int,
      CurrencyCode: json['CurrencyCode'] as String,
      CreditLimit: json['CreditLimit'] as double,
      Balance: json['Balance'] as double,
      DefaultBillAdd: json['DefaultBillAdd'] as String,
      DefaultShippAdd: json['DefaultShippAdd'] as String,
      Type: json['Typev'] as String,
      SalesRep: json['SalesRep'] as String,
      TotalBalance: json['TotalBalance'] as double,
      IsActive: isActiveInt,
      addresses: addressList,
      contacts: contactList,
      IsSelected: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': Id,
      'Name': Other().parseHtmlString(Name),
      'CustomerNo': CustomerNo,
      'TenantId': TenantId,
      'CurrencyCode': CurrencyCode,
      'CreditLimit': CreditLimit.toStringAsFixed(2),
      'Balance': Balance.toStringAsFixed(2),
      'DefaultBillAdd': DefaultBillAdd,
      'DefaultShippAdd': DefaultShippAdd,
      'Type': Type,
      'SalesRep': SalesRep,
      'TotalBalance': TotalBalance.toStringAsFixed(2),
      'IsActive': IsActive,
      'addresses': addresses,
      'contacts': contacts,
      'IsSelected': IsSelected
    };
  }
}
