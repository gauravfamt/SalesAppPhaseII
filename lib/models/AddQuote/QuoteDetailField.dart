import 'package:flutter/material.dart';

class QuoteDetailField {
  int Id;
  int AddQuoteID;
  String DetailReferenceId;
  String FieldName;
  String FieldValue;
  String LabelName;
  bool IsRequired;
  bool IsReadonly;
  TextEditingController textEditingController;

  QuoteDetailField({
    this.Id,
    this.LabelName,
    this.FieldValue,
    this.FieldName,
    this.AddQuoteID,
    this.DetailReferenceId,
    this.IsRequired,
    this.IsReadonly,
    this.textEditingController,
  });

  factory QuoteDetailField.fromJson(Map<String, dynamic> json) {
    bool _isReadonly = json['IsReadonlyInt'] != null
        ? (json['IsReadonlyInt'] as int == 1 ? true : false)
        : json['IsReadonly'] as bool;

    bool _isRequired = json['IsRequiredInt'] != null
        ? (json['IsRequiredInt'] as int == 1 ? true : false)
        : json['IsRequired'] as bool;

//    print('==========QUOTE DETAIL_FIELDS============');
//    print('DF - json[IsRequiredInt] as int: ${json['IsRequiredInt'] as int}');
//    print('DF - json[IsReadonlyInt] as int: ${json['IsReadonlyInt'] as int}');
//    print('DF - _isReadonly: $_isReadonly');
//    print('DF - _isRequired: $_isRequired');
//    print('=========================================');

    return QuoteDetailField(
      Id: json['Id'] as int,
      LabelName: json['LabelName'] as String,
      FieldValue: json['FieldValue'] as String,
      FieldName: json['FieldName'] as String,
      AddQuoteID: json['AddQuoteID'] as int,
      DetailReferenceId: json['DetailReferenceId'] as String,
      IsRequired: _isRequired,
      IsReadonly: _isReadonly,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': Id,
      'LabelName': LabelName,
      'FieldValue': FieldValue,
      'FieldName': FieldName,
      'AddQuoteID': AddQuoteID,
      'DetailReferenceId': DetailReferenceId,
      'textEditingController': textEditingController,
      'IsRequired': IsRequired,
      'IsReadonly': IsReadonly,
    };
  }
}
