class EmailFeature {
  final int UserFeatureId;
  final String Name;
  final bool IsSelected;
  final bool IsDisable;
  final int FeatureId;
  final String User_Id;
  final int TenantId;
  final String Url;
  final String OriginalName;
  final String CaseRefId;
  final String StartingValue;

  EmailFeature({
    this.UserFeatureId,
    this.Name,
    this.IsSelected,
    this.IsDisable,
    this.FeatureId,
    this.User_Id,
    this.TenantId,
    this.Url,
    this.OriginalName,
    this.CaseRefId,
    this.StartingValue,
  });

  factory EmailFeature.fromJson(Map<String, dynamic> json) {
    return EmailFeature(
      UserFeatureId: json['UserFeatureId'] as int,
      Name: json['Name'] as String,
      IsSelected: json['IsSelected'] as bool,
      IsDisable: json['IsDisable'] as bool,
      FeatureId: json['FeatureId'] as int,
      User_Id: json['User_Id'] as String,
      TenantId: json['TenantId'] as int,
      Url: json['Url'] as String,
      OriginalName: json['OriginalName'] as String,
      CaseRefId: json['CaseRefId'] as String,
      StartingValue: json['StartingValue'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'UserFeatureId': UserFeatureId,
      'Name': Name,
      'IsSelected': IsSelected,
      'IsDisable': IsDisable,
      'FeatureId': FeatureId,
      'User_Id': User_Id,
      'TenantId': TenantId,
      'Url': Url,
      'OriginalName': OriginalName,
      'CaseRefId': CaseRefId,
      'StartingValue': StartingValue,
    };
  }
}
