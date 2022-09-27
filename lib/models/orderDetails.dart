import 'package:moblesales/helpers/index.dart';

class OrderDetails {
  final int Id;
  final int TenantId;
  final String CustomerNo;
  final String ProductCode;
  final String Description;
  final double BasePrice;
  final double ExtAmount;
  final double Quantity;
  final int HeaderId;
  final String CreatedDate;
  final String UpdatedDate;
  final double TotalWeight;

  OrderDetails({
    this.Id,
    this.TenantId,
    this.CustomerNo,
    this.ProductCode,
    this.Description,
    this.BasePrice,
    this.ExtAmount,
    this.Quantity,
    this.HeaderId,
    this.CreatedDate,
    this.UpdatedDate,
    this.TotalWeight,
  });

  factory OrderDetails.fromJson(Map<String, dynamic> json) {
    return OrderDetails(
      Id: json['Id'] as int,
      TenantId: json['TenantId'] as int,
      CustomerNo: json['CustomerNo'] as String,
      ProductCode: json['ProductCode'] as String,
      Description: json['Description'] as String,
      BasePrice: json['BasePrice'] as double,
      ExtAmount: json['ExtAmount'] as double,
      Quantity: json['Quantity'] as double,
      HeaderId: json['HeaderId'] as int,
      CreatedDate: json['CreatedDate'] as String,
      UpdatedDate: json['UpdatedDate'] as String,
      TotalWeight: json['TotalWeight'] as double,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': Id,
      'TenantId': TenantId,
      'CustomerNo': CustomerNo,
      'ProductCode': ProductCode,
      'Description': Other().parseHtmlString(Description),
      'BasePrice': BasePrice.toStringAsFixed(2),
      'ExtAmount': ExtAmount.toStringAsFixed(2),
      'Quantity': Quantity,
      'HeaderId': HeaderId,
      'CreatedDate': CreatedDate,
      'UpdatedDate': UpdatedDate,
      'TotalWeight': TotalWeight,
    };
  }
}
