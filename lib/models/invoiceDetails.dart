import 'package:moblesales/helpers/index.dart';

class InvoiceDetails {
  final int Id;
  final int TenantId;
  final String CustomerNo;
  final String DocDate;
  final String Item;
  final String Description;
  final double ExtAmount;
  final double UnitPrice;
  final double Qty;
  final double TaxBase;
  final double Rate;
  final double TaxAmount;
  final int HeaderId;
  final String TransactionNo;
  final String CreatedDate;
  final String UpdatedDate;

  InvoiceDetails({
    this.Id,
    this.TenantId,
    this.CustomerNo,
    this.DocDate,
    this.Item,
    this.Description,
    this.ExtAmount,
    this.UnitPrice,
    this.Qty,
    this.TaxBase,
    this.Rate,
    this.TaxAmount,
    this.HeaderId,
    this.TransactionNo,
    this.CreatedDate,
    this.UpdatedDate,
  });

  factory InvoiceDetails.fromJson(Map<String, dynamic> json) {
    return InvoiceDetails(
      Id: json['Id'] as int,
      TenantId: json['TenantId'] as int,
      CustomerNo: json['CustomerNo'] as String,
      DocDate: json['DocDate'] as String,
      Item: json['Item'] as String,
      Description: json['Description'] as String,
      ExtAmount: json['ExtAmount'] as double,
      UnitPrice: json['UnitPrice'] as double,
      Qty: json['Qty'] as double,
      TaxBase: json['TaxBase'] as double,
      Rate: json['Rate'] as double,
      TaxAmount: json['TaxAmount'] as double,
      HeaderId: json['HeaderId'] as int,
      TransactionNo: json['TransactionNo'] as String,
      CreatedDate: json['CreatedDate'] as String,
      UpdatedDate: json['UpdatedDate'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': Id,
      'TenantId': TenantId,
      'CustomerNo': CustomerNo,
      'DocDate': DocDate,
      'Item': Item,
      'Description': Other().parseHtmlString(Description),
      'ExtAmount': ExtAmount != null ? ExtAmount.toStringAsFixed(2) : ExtAmount,
      'UnitPrice': UnitPrice != null ? UnitPrice.toStringAsFixed(2) : UnitPrice,
      'Qty': Qty,
      'TaxBase': TaxBase,
      'Rate': Rate,
      'TaxAmount': TaxAmount,
      'HeaderId': HeaderId,
      'TransactionNo': TransactionNo,
      'CreatedDate': CreatedDate,
      'UpdatedDate': UpdatedDate,
    };
  }
}
