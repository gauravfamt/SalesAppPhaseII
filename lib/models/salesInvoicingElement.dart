// To parse this JSON data, do
//
//     final invoicingElement = invoicingElementFromJson(jsonString);

import 'dart:convert';

SalesInvoicingElement salesInvoicingElementFromJson(String str) =>
    SalesInvoicingElement.fromJson(json.decode(str));

String salesInvoicingElementToJson(SalesInvoicingElement data) =>
    json.encode(data.toJson());

class SalesInvoicingElement {
  SalesInvoicingElement({
    this.transactionNo,
    this.code,
    this.description,
    this.value,
    this.createdDate,
    this.updatedDate,
  });

  String transactionNo;
  String code;
  String description;
  String value;
  DateTime createdDate;
  DateTime updatedDate;

  factory SalesInvoicingElement.fromJson(Map<String, dynamic> json) =>
      SalesInvoicingElement(
        transactionNo: json["TransactionNo"] != null
            ? json["TransactionNo"].toString()
            : '',
        code: json["Code"] != null ? json["Code"].toString() : '',
        description:
            json["Description"] != null ? json["Description"].toString() : '',
        value: json["Value"] != null ? json["Value"].toString() : '',
        createdDate: json["CreatedDate"] != null
            ? DateTime.tryParse(json["CreatedDate"].toString())
            : DateTime.now(),
        updatedDate: json["UpdatedDate"] != null
            ? DateTime.tryParse(json["UpdatedDate"].toString())
            : DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        "TransactionNo": transactionNo,
        "Code": code,
        "Description": description,
        "Value": value,
        "CreatedDate":
            createdDate != null ? createdDate.toIso8601String() : null,
        "UpdatedDate":
            updatedDate != null ? updatedDate.toIso8601String() : null,
      };
}
