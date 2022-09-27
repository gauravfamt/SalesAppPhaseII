import 'dart:convert';

SyncMaster syncMasterFromJson(String str) =>
    SyncMaster.fromJson(json.decode(str));

String syncMasterToJson(SyncMaster data) => json.encode(data.toJson());

class SyncMaster {
  SyncMaster({
    this.Id,
    this.TableName,
    this.LastSyncDate,
  });
  int Id;
  String TableName;
  String LastSyncDate;

  factory SyncMaster.fromJson(Map<String, dynamic> json) => SyncMaster(
        Id: json["Id"],
        TableName: json["TableName"],
        LastSyncDate: json["LastSyncDate"],
      );

  Map<String, dynamic> toJson() => {
        "Id": Id,
        "TableName": TableName,
        "LastSyncDate": LastSyncDate,
      };
}
