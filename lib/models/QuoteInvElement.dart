import 'package:flutter/material.dart';
import 'package:moblesales/models/index.dart';

class QuoteInvElement {
  int quoteHeaderId;
  InvoicingElement invoicingElement;
  double invoicingElementvalue;
  String txtValue;
  TextEditingController textEditingController;

  QuoteInvElement({
    this.invoicingElement,
    this.invoicingElementvalue,
    this.quoteHeaderId,
    this.textEditingController,
    this.txtValue
  });

  factory QuoteInvElement.fromJson(Map<String, dynamic> json) {
    return QuoteInvElement(
        invoicingElement: json['invoicingElement'] as InvoicingElement,
        invoicingElementvalue: json['invoicingElementvalue'] as double,
        quoteHeaderId:  json['quoteHeaderId'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quoteHeaderId': quoteHeaderId,
      'invoicingElement': invoicingElement,
      'invoicingElementvalue': invoicingElementvalue,
      'textEditingController': textEditingController,
      'txtValue': txtValue,
    };
  }
}
