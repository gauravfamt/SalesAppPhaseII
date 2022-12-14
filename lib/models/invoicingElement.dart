// To parse this JSON data, do
//
//     final invoicingElement = invoicingElementFromJson(jsonString);

import 'dart:convert';

InvoicingElement invoicingElementFromJson(String str) =>
    InvoicingElement.fromJson(json.decode(str));

String invoicingElementToJson(InvoicingElement data) =>
    json.encode(data.toJson());

class InvoicingElement {
  InvoicingElement({
    this.id,
    this.code,
    this.description,
    this.sequenceNumber,
    this.createdDate,
    this.updatedDate,
  });

  int id;
  String code;
  String description;
  int sequenceNumber;
  DateTime createdDate;
  DateTime updatedDate;

  factory InvoicingElement.fromJson(Map<String, dynamic> json) =>
      InvoicingElement(
        id: json["Id"],
        code: json["Code"].toString(),
        description: json["Description"].toString(),
        sequenceNumber:int.parse(json["SequenceNumber"].toString()),
        createdDate: json["CreatedDate"] != null
            ? DateTime.tryParse(json["CreatedDate"].toString())
            : DateTime.now(),
        updatedDate: json["UpdatedDate"] != null
            ? DateTime.tryParse(json["UpdatedDate"].toString())
            : DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        "Id": id,
        "Code": code,
        "Description": description,
        "SequenceNumber":sequenceNumber,
        "CreatedDate":
            createdDate != null ? createdDate.toIso8601String() : null,
        "UpdatedDate":
            updatedDate != null ? updatedDate.toIso8601String() : null,
      };
}
