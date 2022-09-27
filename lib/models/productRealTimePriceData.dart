import 'package:moblesales/models/index.dart';

class ProductRealTimePriceData {
  Product ProductObject;
  double Price;

  ProductRealTimePriceData(Product _productObj, double _price) {
    ProductObject = _productObj;
    Price = _price;
  }
}
