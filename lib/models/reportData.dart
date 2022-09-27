
class ReportData{
  int Id;
  String ReportName;

  ReportData({
    this.Id,
    this.ReportName,
  });

  factory ReportData.fromJson(Map<String, dynamic> json) {
    return ReportData(
      Id: json['Id'] as int,
      ReportName: json['ReportName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': Id,
      'ReportName':ReportName,
    };
  }
}