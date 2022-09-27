import 'package:moblesales/models/otherParams.dart';

class ProductRealTimePrice {
  String ProductCode;
  double Price;
  final OtherParam otherParams;//Added by Gaurav, 12-08-2022, to store product proce extra parmas

  ProductRealTimePrice({
    this.ProductCode,
    this.Price,
    this.otherParams
  });

  factory ProductRealTimePrice.fromJson(Map<String, dynamic> json) {
    var quoteLineItemOtherParams = json['OtherParam'] as List;

    List<OtherParam> otherParamList =
    quoteLineItemOtherParams.map((i) => OtherParam.fromJson(i)).toList();

    return ProductRealTimePrice(
      ProductCode: json['ProductCode'] as String,
      Price: json['Price'] as double,
      otherParams:  otherParamList[0]
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ProductCode': ProductCode,
      'Price': Price.toStringAsFixed(2),
      'OtherParam': otherParams,
    };
  }
}
