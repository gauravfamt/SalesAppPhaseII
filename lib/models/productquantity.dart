import 'package:moblesales/models/index.dart';

class ProductQuantity {
  Product ProductObject;
  int Quantity;

  ProductQuantity(Product PO, int Qty) {
    ProductObject = PO;
    Quantity = Qty;
  }
}
