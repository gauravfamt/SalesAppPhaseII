class Inventory{
  String ProductCode;
  int  QtyOnHand;
  int  QtyAfterOrder;
  int  QtyAfterAllocation;

  Inventory({
    this.ProductCode,
    this.QtyOnHand,
    this.QtyAfterOrder,
    this.QtyAfterAllocation,
  });

  factory Inventory.fromJson(Map<String, dynamic> json) {
    return Inventory(
      ProductCode: json['ProductCode'] as String,
      QtyOnHand: json['QtyOnHand'] as int,
      QtyAfterOrder: json['QtyAfterOrder'] as int,
      QtyAfterAllocation: json['QtyAfterAllocation'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ProductCode': ProductCode,
      'QtyOnHand':QtyOnHand,
      'QtyAfterOrder':QtyAfterOrder,
      'QtyAfterAllocation':QtyAfterAllocation,
    };
  }
}