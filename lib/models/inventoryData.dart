import 'package:moblesales/models/index.dart';

class InventoryData {
  Product ProductObject;
  int QtyOnHand;
  int QtyAfterOrder;
  int QtyAfterAllocation;

  InventoryData(Product _productObj, int _QtyOnHand, int _QtyAfterOrder,
      int _QtyAfterAllocation) {
    ProductObject = _productObj;
    QtyOnHand = _QtyOnHand;
    QtyAfterOrder = _QtyAfterOrder;
    QtyAfterAllocation = _QtyAfterAllocation;
  }
}
