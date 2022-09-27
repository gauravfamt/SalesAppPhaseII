// To parse this JSON data, do
//
//     final quoteHeader = quoteHeaderFromJson(jsonString);

import 'dart:convert';

RequestQuoteHeader requestQuoteHeaderFromJson(String str) =>
    RequestQuoteHeader.fromJson(json.decode(str));

String requestQuoteHeaderToJson(RequestQuoteHeader data) =>
    json.encode(data.toJson());

class RequestQuoteHeader {
  String DocumentNo;
  String DocumentDate;
  String DocumentType;
  String CustomerNo;
  String Description;
  String SalesPerson;
  double DocumentTotal;
  double FreightAmount;
  double DiscountPercentage;
  String Status;
  String CurrencyCode;
  String OuoteEntryType;
  String SalesSite;

  RequestQuoteHeader({
    this.DocumentNo,
    this.DocumentDate,
    this.DocumentType,
    this.CustomerNo,
    this.Description,
    this.SalesPerson,
    this.DocumentTotal,
    this.FreightAmount,
    this.DiscountPercentage,
    this.Status,
    this.CurrencyCode,
    this.OuoteEntryType,
    this.SalesSite,
  });

  factory RequestQuoteHeader.fromJson(Map<String, dynamic> json) =>
      RequestQuoteHeader(
        DocumentNo: json["DocumentNo"] as String,
        DocumentDate: json["DocumentDate"] as String,
        DocumentType: json["DocumentType"] as String,
        CustomerNo: json["CustomerNo"] as String,
        Description: json["Description"] as String,
        SalesPerson: json["SalesPerson"] as String,
        DocumentTotal: json["DocumentTotal"] as double,
        FreightAmount: json["FreightAmount"] as double,
        DiscountPercentage: json["DiscountPercentage"] as double,
        Status: json["Status"] as String,
        CurrencyCode: json["CurrencyCode"] as String,
        OuoteEntryType: json["OuoteEntryType"] as String,
        SalesSite: json["SalesSite"] as String,
      );

  Map<String, dynamic> toJson() => {
        "DocumentNo": DocumentNo,
        "DocumentDate": DocumentDate,
        "DocumentType": DocumentType,
        "CustomerNo": CustomerNo,
        "Description": Description,
        "SalesPerson": SalesPerson,
        "DocumentTotal": DocumentTotal.toStringAsFixed(2),
        "FreightAmount": FreightAmount,
        "DiscountPercentage": DiscountPercentage,
        "Status": Status,
        "CurrencyCode": CurrencyCode,
        "OuoteEntryType": OuoteEntryType,
        "SalesSite": SalesSite,
      };
}
