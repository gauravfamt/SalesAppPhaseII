import 'package:moblesales/helpers/index.dart';

class QuoteDetail {
  final int Id;
  final int TenantId;
  final String ProductCode;
  final String Description;
  final int Quantity;
  final double BasePrice;
  final double ExtAmount;
  final double Discount;
  final String Tax;
  final int HeaderId;
  final String CreatedDate;
  final String UpdatedDate;
  final String Weight;
  final double TotalWeight;
  String ExtraParam;//Added by Gaurav, 12-08-2022, to store product proce extra parmas
  QuoteDetail({
    this.Id,
    this.TenantId,
    this.ProductCode,
    this.Description,
    this.Quantity,
    this.BasePrice,
    this.ExtAmount,
    this.Discount,
    this.Tax,
    this.HeaderId,
    this.CreatedDate,
    this.UpdatedDate,
    this.Weight,
    this.TotalWeight,
    this.ExtraParam
  });

  factory QuoteDetail.fromJson(Map<String, dynamic> json) {
    String _weight = json['Weight'] != null ? json['Weight'].toString() : '';
    return QuoteDetail(
      Id: json['Id'] as int,
      TenantId: json['TenantId'] as int,
      ProductCode: json['ProductCode'] as String,
      Description: json['Description'] as String,
      Quantity: json['Quantity'] as int,
      BasePrice: json['BasePrice'] as double,
      ExtAmount: json['ExtAmount'] as double,
      Discount: json['Discount'] as double,
      Tax: json['Tax'] as String,
      HeaderId: json['HeaderId'] as int,
      CreatedDate: json['CreatedDate'] as String,
      UpdatedDate: json['UpdatedDate'] as String,
      Weight: _weight,
      TotalWeight: json['TotalWeight'] as double,
      ExtraParam: json['OtherParam'] as String
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': Id,
      'TenantId': TenantId,
      'ProductCode': ProductCode,
      'Description': Other().parseHtmlString(Description),
      'Quantity': Quantity,
      'BasePrice': BasePrice.toStringAsFixed(2),
      'ExtAmount': ExtAmount.toStringAsFixed(2),
      'Discount': Discount,
      'Tax': Tax,
      'HeaderId': HeaderId,
      'CreatedDate': CreatedDate,
      'UpdatedDate': UpdatedDate,
      'Weight': Weight,
      'TotalWeight': TotalWeight,
      'OtherParam': ExtraParam,
    };
  }
}
