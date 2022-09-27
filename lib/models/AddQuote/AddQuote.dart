import 'package:flutter/material.dart';
import 'package:moblesales/models/index.dart';

class AddQuote {
  int Id;
  String QuoteHeaderIds;
  String QuoteDetailIds;
  DateTime CreatedDate;
  DateTime UpdatedDate;
  List<AddQuoteDetail> QuoteDetail;
  List<AddQuoteHeader> QuoteHeader;
  int IsLocalQuote;
  String ServerUpdatedDate;
  int ServerQuoteId;

  AddQuote({
    this.Id,
    this.QuoteHeaderIds,
    this.QuoteDetailIds,
    this.CreatedDate,
    this.UpdatedDate,
    this.QuoteDetail,
    this.QuoteHeader,
    this.IsLocalQuote,
    this.ServerUpdatedDate,
    this.ServerQuoteId,
  });

  factory AddQuote.fromJson(Map<String, dynamic> json) {
    List<AddQuoteHeader> _quoteHeader = List<AddQuoteHeader>();
    List<AddQuoteDetail> _quoteDetail = List<AddQuoteDetail>();
    DateTime _createdAt = DateTime.parse(json['CreatedDate'] as String);
    DateTime _updatedAt = DateTime.parse(json['UpdatedDate'] as String);
    return AddQuote(
      Id: json['Id'] as int,
      QuoteHeaderIds: (json['QuoteHeaderIds'] as String).trim(),
      QuoteDetailIds: json['QuoteDetailIds'] as String,
      CreatedDate: _createdAt,
      UpdatedDate: _updatedAt,
      QuoteDetail: _quoteDetail,
      QuoteHeader: _quoteHeader,
      IsLocalQuote: json['IsLocalQuote'] as int,
      ServerUpdatedDate: json['ServerUpdatedDate'] as String,
      ServerQuoteId: json['ServerQuoteId'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': Id,
      'QuoteHeaderIds': QuoteHeaderIds,
      'QuoteDetailIds': QuoteDetailIds,
      'CreatedDate': CreatedDate,
      'UpdatedDate': UpdatedDate,
      'QuoteDetail': QuoteDetail,
      'QuoteHeader': QuoteHeader,
      'IsLocalQuote': IsLocalQuote,
      'ServerUpdatedDate': ServerUpdatedDate,
      'ServerQuoteId': ServerQuoteId,
    };
  }
}
