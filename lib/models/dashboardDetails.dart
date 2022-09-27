class DashboardDetails {
  final double TotalRevenue;
  final int TotalSales;
  final int TotalOrders;
  final double TotalPaymentDues;

  DashboardDetails(
      {this.TotalRevenue,
      this.TotalSales,
      this.TotalOrders,
      this.TotalPaymentDues});

  factory DashboardDetails.fromJson(Map<String, dynamic> json) {
    return DashboardDetails(
        TotalRevenue: json['TotalRevenue'] as double,
        TotalSales: json['TotalSales'] as int,
        TotalOrders: json['TotalOrders'] as int,
        TotalPaymentDues: json['TotalPaymentDues'] as double);
  }

  Map<String, dynamic> toJson() {
    return {
      'TotalRevenue': TotalRevenue,
      'TotalSales': TotalSales,
      'TotalOrders': TotalOrders,
      'TotalPaymentDues': TotalPaymentDues,
    };
  }
}
