// To parse this JSON data, do
//
//     final requestQuoteDetail = requestQuoteDetailFromJson(jsonString);

import 'dart:convert';

RequestQuoteDetail requestQuoteDetailFromJson(String str) =>
    RequestQuoteDetail.fromJson(json.decode(str));

String requestQuoteDetailToJson(RequestQuoteDetail data) =>
    json.encode(data.toJson());

class RequestQuoteDetail {
  String Item;
  String Description;
  int Quantity;
  double UnitPrice;
  double ExtAmount;
  double Discount;
  String Tax;

  RequestQuoteDetail({
    this.Item,
    this.Description,
    this.Quantity,
    this.UnitPrice,
    this.ExtAmount,
    this.Discount,
    this.Tax,
  });

  factory RequestQuoteDetail.fromJson(Map<String, dynamic> json) =>
      RequestQuoteDetail(
        Item: json["Item"] as String,
        Description: json["Description"] as String,
        Quantity: json["Quantity"] as int,
        UnitPrice: json["UnitPrice"] as double,
        ExtAmount: json["ExtAmount"] as double,
        Discount: json["Discount"] as double,
        Tax: json["Tax"] as String,
      );

  Map<String, dynamic> toJson() => {
        "Item": Item,
        "Description": Description,
        "Quantity": Quantity,
        "UnitPrice": UnitPrice.toStringAsFixed(2),
        "ExtAmount": ExtAmount.toStringAsFixed(2),
        "Discount": Discount,
        "Tax": Tax,
      };
}
