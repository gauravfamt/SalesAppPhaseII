import 'package:flutter/material.dart';

class QuoteHeaderField {
  int Id;
  int AddQuoteID;
  String HeaderReferenceId;
  String FieldName;
  String FieldValue;
  String LabelName;
  bool IsRequired;
  bool IsReadonly;
  TextEditingController textEditingController;

  QuoteHeaderField({
    this.Id,
    this.LabelName,
    this.FieldValue,
    this.FieldName,
    this.AddQuoteID,
    this.HeaderReferenceId,
    this.IsRequired,
    this.IsReadonly,
    this.textEditingController,
  });

  factory QuoteHeaderField.fromJson(Map<String, dynamic> json) {
    bool _isReadonly = json['IsReadonlyInt'] != null
        ? (json['IsReadonlyInt'] as int == 1 ? true : false)
        : json['IsReadonly'] as bool;

    bool _isRequired = json['IsRequiredInt'] != null
        ? (json['IsRequiredInt'] as int == 1 ? true : false)
        : json['IsRequired'] as bool;

//    print('==========QUOTE HEADER_FIELDS============');
//    print('HF - json[IsRequiredInt] as int: ${json['IsRequiredInt'] as int}');
//    print('HF - json[IsReadonlyInt] as int: ${json['IsReadonlyInt'] as int}');
//    print('HF - _isReadonly: $_isReadonly');
//    print('HF - _isRequired: $_isRequired');
//    print('=========================================');

    return QuoteHeaderField(
      Id: json['Id'] as int,
      LabelName: json['LabelName'] as String,
      FieldValue: json['FieldValue'] as String,
      FieldName: json['FieldName'] as String,
      AddQuoteID: json['AddQuoteID'] as int,
      HeaderReferenceId: json['HeaderReferenceId'] as String,
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
      'HeaderReferenceId': HeaderReferenceId,
      'textEditingController': textEditingController,
      'IsRequired': IsRequired,
      'IsReadonly': IsReadonly,
    };
  }
}
