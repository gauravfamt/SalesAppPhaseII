import 'dart:convert';

import 'package:moblesales/models/index.dart';

AddQuoteRequest addQuoteRequestFromJson(String str) =>
    AddQuoteRequest.fromJson(json.decode(str));

String addQuoteRequestToJson(AddQuoteRequest data) =>
    json.encode(data.toJson());

class AddQuoteRequest {
  List<RequestQuoteHeader> QuoteHeader;
  List<RequestQuoteDetail> QuoteDetail;

  AddQuoteRequest({
    this.QuoteHeader,
    this.QuoteDetail,
  });

  factory AddQuoteRequest.fromJson(Map<String, dynamic> json) {
    var quoteHeaderListFromJson = json['QuoteHeader'] as List;
    List<RequestQuoteHeader> quoteHeaderList = quoteHeaderListFromJson != null
        ? quoteHeaderListFromJson
            .map((i) => RequestQuoteHeader.fromJson(i))
            .toList()
        : [];

    var quoteDetailListFromJson = json['QuoteDetail'] as List;
    List<RequestQuoteDetail> quoteDetailList = quoteDetailListFromJson != null
        ? quoteDetailListFromJson
            .map((i) => RequestQuoteDetail.fromJson(i))
            .toList()
        : [];

    return AddQuoteRequest(
      QuoteHeader: quoteHeaderList,
      QuoteDetail: quoteDetailList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'QuoteHeader': QuoteHeader,
      'QuoteDetail': QuoteDetail,
    };
  }
}
