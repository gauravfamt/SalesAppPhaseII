import 'package:moblesales/helpers/index.dart';
import 'package:moblesales/models/index.dart';

class Quotes {
  final int Id;
  final String DocumentNo;
  String DocumentDate;
  final String DocumentType;
  final String CustomerNo;
  final String SalesPerson;
  final double DocumentTotal;
  final double FreightAmount;
  final double DiscountPercentage;
  final String Status;
  final String CurrencyCode;
  final String CreatedDate;
  final String UpdatedDate;
  final String QuoteEntryType;
  final int TenantId;
  final String SalesSite;
  final List<QuoteDetail> Quotedetail;
  final String ServerDocumentDate;
  final String PONumber;
  final String Notes;
  final String IsIntegrated;
  //Added by Mayuresh, Phase II, 24-07-22
  String CustomerName;
  String ShippingAddressCode;
  Quotes({
    this.Id,
    this.DocumentNo,
    this.DocumentDate,
    this.DocumentType,
    this.CustomerNo,
    this.SalesPerson,
    this.DocumentTotal,
    this.FreightAmount,
    this.DiscountPercentage,
    this.Status,
    this.CurrencyCode,
    this.CreatedDate,
    this.UpdatedDate,
    this.QuoteEntryType,
    this.TenantId,
    this.SalesSite,
    this.Quotedetail,
    this.ServerDocumentDate,
    this.PONumber,
    this.Notes,
    this.IsIntegrated,
    this.CustomerName,
    this.ShippingAddressCode,
  });

  factory Quotes.fromJson(Map<String, dynamic> json) {
    var quoteDetailListFromJson = json['Quotedetail'] as List;

    List<QuoteDetail> quotesList =
        quoteDetailListFromJson.map((i) => QuoteDetail.fromJson(i)).toList();

    String _documentDate = json['DocumentDate'] as String;
    //Added by Gaurav, 16-07-2020
    _documentDate = Other().DisplayDate(_documentDate);

    return Quotes(
      Id: json['Id'] as int,
      DocumentNo: json['DocumentNo'] as String,
      DocumentDate: _documentDate,
      DocumentType: json['DocumentType'] as String,
      CustomerNo: json['CustomerNo'] as String,
      CustomerName: json['CustomerName'] as String,
      ShippingAddressCode: json['ShippingAddressCode'] as String,
      SalesPerson: json['SalesPerson'] as String,
      DocumentTotal: json['DocumentTotal'] as double,
      FreightAmount: json['FreightAmount'] as double,
      DiscountPercentage: json['DiscountPercentage'] as double,
      Status: json['Status'] as String,
      CurrencyCode: json['CurrencyCode'] as String,
      CreatedDate: json['CreatedDate'] as String,
      UpdatedDate: json['UpdatedDate'] as String,
      QuoteEntryType: json['QuoteEntryType'] as String,
      TenantId: json['TenantId'] as int,
      SalesSite: json['SalesSite'] as String,
      ServerDocumentDate: json['DocumentDate'] as String,
      PONumber: json['PONumber'] as String,
      Notes: json['Notes'] as String,
      IsIntegrated: json['IsIntegrated'] as String,
      Quotedetail: quotesList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': Id,
      'DocumentNo': DocumentNo,
      'DocumentDate': DocumentDate,
      'DocumentType': DocumentType,
      'CustomerNo': CustomerNo,
      'CustomerName': CustomerName,
      'ShippingAddressCode': ShippingAddressCode,
      'SalesPerson': SalesPerson,
      'DocumentTotal': DocumentTotal.toStringAsFixed(2),
      'FreightAmount': FreightAmount,
      'DiscountPercentage': DiscountPercentage,
      'Status': Status,
      'CurrencyCode': CurrencyCode,
      'CreatedDate': CreatedDate,
      'UpdatedDate': UpdatedDate,
      'QuoteEntryType': QuoteEntryType,
      'TenantId': TenantId,
      'SalesSite': SalesSite,
      'Quotedetail': Quotedetail,
      'ServerDocumentDate': ServerDocumentDate,
      'PONumber': PONumber,
      'Notes': Notes,
      'IsIntegrated': IsIntegrated,
    };
  }
}
