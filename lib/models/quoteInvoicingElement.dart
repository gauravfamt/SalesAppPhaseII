import 'dart:convert';

QuoteInvoicingElement quoteInvoicingElementFromJson(String str) => QuoteInvoicingElement.fromJson(json.decode(str));
String quoteInvoicingElementToJson(QuoteInvoicingElement data) => json.encode(data.toJson());

class QuoteInvoicingElement {
  QuoteInvoicingElement({
    this.Id,
    this.QuoteHeaderId,
    this.InvoicingElementCode,
    this.InvoicingElementValue,
    this.CreatedBy,
    this.CreatedDate,
    this.UpdatedBy,
    this.UpdatedDate,
  });

  int Id;
  int QuoteHeaderId;
  int InvoicingElementCode;
  double InvoicingElementValue;
  String CreatedBy;
  String CreatedDate;
  String UpdatedBy;
  String UpdatedDate;

  factory QuoteInvoicingElement.fromJson(Map<String, dynamic> json) => QuoteInvoicingElement(
    Id: json["Id"] == null ? null : json["Id"],
    QuoteHeaderId: json["QuoteHeaderId"] == null ? null : json["QuoteHeaderId"],
    InvoicingElementCode: json["InvoicingElementCode"] == null ? null : json["InvoicingElementCode"],
    InvoicingElementValue: json["InvoicingElementValue"] == null ? null : json["InvoicingElementValue"],
    CreatedBy: json["CreatedBy"] == null ? null : json["CreatedBy"],
    CreatedDate: json["CreatedDate"] == null ? null : json["CreatedDate"],
    UpdatedBy: json["UpdatedBy"] == null ? null : json["UpdatedBy"],
    UpdatedDate: json["UpdatedDate"] == null ? null : json["UpdatedDate"],
  );

  Map<String, dynamic> toJson() => {
    "Id": Id == null ? null : Id,
    "QuoteHeaderId": QuoteHeaderId == null ? null : QuoteHeaderId,
    "InvoicingElementCode": InvoicingElementCode == null ? null : InvoicingElementCode,
    "InvoicingElementValue": InvoicingElementValue == null ? null : InvoicingElementValue,
    "CreatedBy": CreatedBy == null ? null : CreatedBy,
    "CreatedDate": CreatedDate == null ? null : CreatedDate,
    "UpdatedBy": UpdatedBy == null ? null : UpdatedBy,
    "UpdatedDate": UpdatedDate == null ? null : UpdatedDate,
  };
}

