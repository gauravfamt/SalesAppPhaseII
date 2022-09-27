class CustomField {
  final int CustomFieldId;
  final int DataType;
  final String FieldValues;
  final String FieldName;
  final String FieldLabel;
  final String Entity;
  final String UniqueReferenceId;
  final bool IsCompulsory;
  final bool GridRequired;
  final bool ShowOnScreen;
  final int TenantId;
  final int CustomUserFieldId;

  CustomField({
    this.CustomFieldId,
    this.DataType,
    this.FieldValues,
    this.FieldName,
    this.FieldLabel,
    this.Entity,
    this.UniqueReferenceId,
    this.IsCompulsory,
    this.GridRequired,
    this.ShowOnScreen,
    this.TenantId,
    this.CustomUserFieldId,
  });

  factory CustomField.fromJson(Map<String, dynamic> json) {
    return CustomField(
      CustomFieldId: json['CustomFieldId'] as int,
      DataType: json['DataType'] as int,
      FieldValues: json['FieldValues'] as String,
      FieldName: json['FieldName'] as String,
      FieldLabel: json['FieldLabel'] as String,
      Entity: json['Entity'] as String,
      UniqueReferenceId: json['UniqueReferenceId'] as String,
      IsCompulsory: json['IsCompulsory'] as bool,
      GridRequired: json['GridRequired'] as bool,
      ShowOnScreen: json['ShowOnScreen'] as bool,
      TenantId: json['TenantId'] as int,
      CustomUserFieldId: json['CustomUserFieldId'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'CustomFieldId': CustomFieldId,
      'DataType': DataType,
      'FieldValues': FieldValues,
      'FieldName': FieldName,
      'FieldLabel': FieldLabel,
      'Entity': Entity,
      'UniqueReferenceId': UniqueReferenceId,
      'IsCompulsory': IsCompulsory,
      'GridRequired': GridRequired,
      'ShowOnScreen': ShowOnScreen,
      'TenantId': TenantId,
      'CustomUserFieldId': CustomUserFieldId,
    };
  }
}
