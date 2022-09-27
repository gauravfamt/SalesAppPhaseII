import 'package:flutter/material.dart';
import 'package:moblesales/models/index.dart';

class AddQuoteDetail {
  Product product;
  double productRealTimePrice;
  int productRealTimeQuantity;
  final int Id;
  final int AddQuoteID;
  final String DetailReferenceId;
  List<QuoteDetailField> QuoteDetailFields;
  StandardDropDownField TaxDropDownValue;

  AddQuoteDetail({
    this.Id,
    this.product,
    this.AddQuoteID,
    this.DetailReferenceId,
    this.QuoteDetailFields,
    this.productRealTimePrice,
    this.productRealTimeQuantity,
    this.TaxDropDownValue,
  });

  factory AddQuoteDetail.fromJson(Map<String, dynamic> json) {
    List<QuoteDetailField> _quoteDetailFields = [];
    return AddQuoteDetail(
      Id: json['Id'] as int,
      AddQuoteID: json['AddQuoteID'] as int,
      DetailReferenceId: json['DetailReferenceId'] as String,
      QuoteDetailFields: _quoteDetailFields,
      productRealTimePrice: 0.0, //DEFAULT VALUE SET
      productRealTimeQuantity: 0, //DEFAULT VALUE SET
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': Id,
      'AddQuoteID': AddQuoteID,
      'DetailReferenceId': DetailReferenceId,
      'product': product,
      'QuoteDetailFields': QuoteDetailFields,
      'productRealTimePrice': productRealTimePrice,
      'productRealTimeQuantity': productRealTimeQuantity,
      'TaxDropDownValue': TaxDropDownValue,
    };
  }
}
