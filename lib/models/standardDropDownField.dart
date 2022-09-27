class StandardDropDownField {
  final int Id;
  final int TenantId;
  final String Dropdown;
  final String Code;
  final String Caption;
  final String CreatedDate;
  final String UpdatedDate;
  final String Entity;

  StandardDropDownField({
    this.Id,
    this.TenantId,
    this.Dropdown,
    this.Code,
    this.Caption,
    this.CreatedDate,
    this.UpdatedDate,
    this.Entity,
  });

  factory StandardDropDownField.fromJson(Map<String, dynamic> json) {
    return StandardDropDownField(
      Id: json['Id'] as int,
      TenantId: json['TenantId'] as int,
      Dropdown: json['Dropdown'] as String,
      Code: json['Code'] as String,
      Caption: json['Caption'] as String,
      CreatedDate: json['CreatedDate'] as String,
      UpdatedDate: json['UpdatedDate'] as String,
      Entity: json['Entity'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': Id,
      'TenantId': TenantId,
      'Dropdown': Dropdown,
      'Code': Code,
      'Caption': Caption,
      'CreatedDate': CreatedDate,
      'UpdatedDate': UpdatedDate,
      'Entity': Entity,
    };
  }
}
