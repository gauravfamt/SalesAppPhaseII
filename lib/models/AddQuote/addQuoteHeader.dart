import 'package:moblesales/models/index.dart';

class AddQuoteHeader {
  final int Id;
  final int AddQuoteID;
  final String HeaderReferenceId;
  List<QuoteHeaderField> QuoteHeaderFields;

  AddQuoteHeader({
    this.Id,
    this.AddQuoteID,
    this.HeaderReferenceId,
    this.QuoteHeaderFields,
  });

  factory AddQuoteHeader.fromJson(Map<String, dynamic> json) {
    List<QuoteHeaderField> _quoteHeaderFields = [];
    return AddQuoteHeader(
      Id: json['Id'] as int,
      AddQuoteID: json['AddQuoteID'] as int,
      HeaderReferenceId: json['HeaderReferenceId'] as String,
      QuoteHeaderFields: _quoteHeaderFields,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': Id,
      'AddQuoteID': AddQuoteID,
      'DetailReferenceId': HeaderReferenceId,
      'QuoteHeaderFields': QuoteHeaderFields,
    };
  }
}
