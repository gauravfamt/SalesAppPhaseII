class Contact {
  final String Id;
  final int TenantType;
  final Object SubDomain;
  final String RealName;
  final int TenantId;
  final int CompanyId;
  final String Email;
  final bool IsActivated;
  final bool IsDisabled;
  final Object Password;
  final Object CompanyCode;
  final String AreaCode;
  final String PhoneNo;
  final String BusinessEmail;
  final String City;
  final String State;
  final String Country;
  final String UserCode;
  final String CreatedDate;
  final String UpdatedDate;
  final String AssignedEmail;
  final String FirstName;
  final String LastName;
  final int PortalCompanyId;
  final bool FirstLogin;
  final Object SalesRep;
  final Object Supervisor;
  final String Manager;
  final bool IsDefault;

  Contact({
    this.Id,
    this.TenantType,
    this.SubDomain,
    this.RealName,
    this.TenantId,
    this.CompanyId,
    this.Email,
    this.IsActivated,
    this.IsDisabled,
    this.Password,
    this.CompanyCode,
    this.AreaCode,
    this.PhoneNo,
    this.BusinessEmail,
    this.City,
    this.State,
    this.Country,
    this.UserCode,
    this.CreatedDate,
    this.UpdatedDate,
    this.AssignedEmail,
    this.FirstName,
    this.LastName,
    this.PortalCompanyId,
    this.FirstLogin,
    this.SalesRep,
    this.Supervisor,
    this.Manager,
    this.IsDefault,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      Id: json['Id'] as String,
      TenantType: json['TenantType'] as int,
      SubDomain: json['SubDomain'] as Object,
      RealName: json['RealName'] as String,
      TenantId: json['TenantId'] as int,
      CompanyId: json['CompanyId'] as int,
      Email: json['Email'] as String,
      IsActivated: json['IsActivated'] as bool,
      IsDisabled: json['IsDisabled'] as bool,
      Password: json['Password'] as Object,
      CompanyCode: json['CompanyCode'] as Object,
      AreaCode: json['AreaCode'] as String,
      PhoneNo: json['PhoneNo'] as String,
      BusinessEmail: json['BusinessEmail'] as String,
      City: json['City'] as String,
      State: json['State'] as String,
      Country: json['Country'] as String,
      UserCode: json['UserCode'] as String,
      CreatedDate: json['CreatedDate'] as String,
      UpdatedDate: json['UpdatedDate'] as String,
      AssignedEmail: json['AssignedEmail'] as String,
      FirstName: json['FirstName'] as String,
      LastName: json['LastName'] as String,
      PortalCompanyId: json['PortalCompanyId'] as int,
      FirstLogin: json['FirstLogin'] as bool,
      SalesRep: json['SalesRep'] as Object,
      Supervisor: json['Supervisor'] as Object,
      Manager: json['Manager'] as String,
      IsDefault: json['IsDefault'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': Id,
      'TenantType': TenantType,
      'SubDomain': SubDomain,
      'RealName': RealName,
      'TenantId': TenantId,
      'CompanyId': CompanyId,
      'Email': Email,
      'IsActivated': IsActivated,
      'IsDisabled': IsDisabled,
      'Password': Password,
      'CompanyCode': CompanyCode,
      'AreaCode': AreaCode,
      'PhoneNo': PhoneNo,
      'BusinessEmail': BusinessEmail,
      'City': City,
      'State': State,
      'Country': Country,
      'UserCode': UserCode,
      'CreatedDate': CreatedDate,
      'UpdatedDate': UpdatedDate,
      'AssignedEmail': AssignedEmail,
      'FirstName': FirstName,
      'LastName': LastName,
      'PortalCompanyId': PortalCompanyId,
      'FirstLogin': FirstLogin,
      'SalesRep': SalesRep,
      'Supervisor': Supervisor,
      'Manager': Manager,
      'IsDefault': IsDefault,
    };
  }
}
