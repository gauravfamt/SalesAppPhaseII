class StandardField {
  final int Id;
  final int TenantId;
  final int StandardFieldOn;
  final String FieldName;
  final String LabelName;
  final String Entity;
  final bool ShowInGrid;
  final bool ShowOnScreen;
  final String SectionName;
  final int SortOrder;
  final bool ShowOnPreview;
  final bool IsRequired;
  final bool IsReadonly;

  StandardField({
    this.Id,
    this.TenantId,
    this.StandardFieldOn,
    this.FieldName,
    this.LabelName,
    this.Entity,
    this.ShowInGrid,
    this.ShowOnScreen,
    this.SectionName,
    this.SortOrder,
    this.ShowOnPreview,
    this.IsReadonly,
    this.IsRequired,
  });

  factory StandardField.fromJson(Map<String, dynamic> json) {
    ///NOTE: IN LOCAL_SQ_LITE_DATABASE IT DOESN'T PROVIDE THE BOOLEAN TYPE FIELDS
    ///SO INSTEAD OF STORING BOOLEAN VALUES STORING 1 OR 0 IN DIFFERENT FIELD ANF THEN ASSIGNING THE BOOL VALUES OT THE FIELDS
    bool _showInGrid = json['ShowInGridInt'] != null
        ? (json['ShowInGridInt'] as int == 1 ? true : false)
        : json['ShowInGrid'] as bool;

    bool _showOnScreen = json['ShowOnScreenInt'] != null
        ? (json['ShowOnScreenInt'] as int == 1 ? true : false)
        : json['ShowOnScreen'] as bool;

    bool _showOnPreview = json['ShowOnPreviewInt'] != null
        ? (json['ShowOnPreviewInt'] as int == 1 ? true : false)
        : json['ShowOnPreview'] as bool;

    bool _isReadonly = json['IsReadonlyInt'] != null
        ? (json['IsReadonlyInt'] as int == 1 ? true : false)
        : json['IsReadonly'] as bool;

    bool _isRequired = json['IsRequiredInt'] != null
        ? (json['IsRequiredInt'] as int == 1 ? true : false)
        : json['IsRequired'] as bool;

//    print('json[IsRequiredInt] as int: ${json['IsRequiredInt'] as int}');
//    print('json[IsReadonlyInt] as int: ${json['IsReadonlyInt'] as int}');
//    print('_isReadonly: $_isReadonly');
//    print('_isRequired: $_isRequired');

    return StandardField(
      Id: json['Id'] as int,
      TenantId: json['TenantId'] as int,
      StandardFieldOn: json['StandardFieldOn'] as int,
      FieldName: json['FieldName'] as String,
      LabelName: json['LabelName'] as String,
      Entity: json['Entity'] as String,
      ShowInGrid: _showInGrid,
      ShowOnScreen: _showOnScreen,
      SectionName: json['SectionName'] as String,
      SortOrder: json['SortOrder'] as int,
      ShowOnPreview: _showOnPreview,
      IsReadonly: _isReadonly,
      IsRequired: _isRequired,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': Id,
      'TenantId': TenantId,
      'StandardFieldOn': StandardFieldOn,
      'FieldName': FieldName,
      'LabelName': LabelName,
      'Entity': Entity,
      'ShowInGrid': ShowInGrid,
      'ShowOnScreen': ShowOnScreen,
      'SectionName': SectionName,
      'SortOrder': SortOrder,
      'ShowOnPreview': ShowOnPreview,
      'IsReadonly': IsReadonly,
      'IsRequired': IsRequired,
    };
  }
}
