class SalesSite {
  final int Id;
   String SiteCode;
  final String SiteName;
  final String CreatedDate;
  final String UpdatedDate;
  final int TenantId;

  SalesSite({
    this.Id,
    this.SiteCode,
    this.SiteName,
    this.CreatedDate,
    this.UpdatedDate,
    this.TenantId,
  });

  factory SalesSite.fromJson(Map<String, dynamic> json) {
    return SalesSite(
      Id: json['Id'] as int,
      TenantId: json['TenantId'] as int,
      SiteCode: json['SiteCode'] as String,
      SiteName: json['SiteName'] as String,
      CreatedDate: json['CreatedDate'] as String,
      UpdatedDate: json['UpdatedDate'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': Id,
      'TenantId': TenantId,
      'SiteCode': SiteCode,
      'SiteName': SiteName,
      'CreatedDate': CreatedDate,
      'UpdatedDate': UpdatedDate,
    };
  }
}
