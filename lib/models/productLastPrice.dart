class ProductLastPrice {
  double LastPrice;

  ProductLastPrice({
    this.LastPrice,
  });

  factory ProductLastPrice.fromJson(Map<String, dynamic> json) {
    return ProductLastPrice(
      LastPrice: json['LastPrice'] as double,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'LastPrice': LastPrice,
    };
  }
}
