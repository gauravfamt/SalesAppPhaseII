import 'package:moblesales/helpers/index.dart';
import 'package:moblesales/models/index.dart';
import 'package:moblesales/utils/index.dart';

class AddressDBHelper {
  ///IT HOLDS THE TABLE CREATE QUERY
  final String tableName = 'Address';

  String getTableCreateQuery() {
    return '''
          CREATE TABLE IF NOT EXISTS $tableName(
          Id INTEGER PRIMARY KEY,
          Code  TEXT,
          TenantId INTEGER,
          Address1 TEXT,
          City TEXT,
          State TEXT,
          Country TEXT,
          PostCode TEXT,
          TelephoneNo TEXT,
          BusinessEmail TEXT,
          SalesSite TEXT,
          ShipSite TEXT,
          PortalCompanyId INTEGER,
          PortalUserId INTEGER,
          CustomerNo TEXT,
          Address2 TEXT,
          Address3 TEXT,
          IsShippingInt INTEGER,
          DefaultBilling TEXT,
          DefaultShipping TEXT
          )
          ''';
  }

  /// IT INSERTS MULTIPLE COMPANIES DATA TO THE LOCAL_DB
  Future addAddresses(List<Address> addresses) async {
    try {
      final db = await DBProvider.db.database;
      print('Inside addAddresses after database connection received!');
      String values = "";
      for (var i = 0; i < addresses.length; i++) {
        Address singleAddress = addresses[i];
        int _isShippingInt =
            singleAddress.IsShipping != null && singleAddress.IsShipping
                ? 1
                : 0;
        values +=
            '''( ${singleAddress.Id}, "${getFormattedStringForSave(singleAddress.Code)}", ${singleAddress.TenantId}, "${getFormattedStringForSave(singleAddress.Address1)}", "${getFormattedStringForSave(singleAddress.City)}", "${getFormattedStringForSave(singleAddress.State)}", "${getFormattedStringForSave(singleAddress.Country)}", "${getFormattedStringForSave(singleAddress.PostCode)}", "${getFormattedStringForSave(singleAddress.TelephoneNo)}", "${getFormattedStringForSave(singleAddress.BusinessEmail)}", "${getFormattedStringForSave(singleAddress.SalesSite)}", "${getFormattedStringForSave(singleAddress.ShipSite)}", ${singleAddress.PortalCompanyId}, ${singleAddress.PortalUserId}, "${getFormattedStringForSave(singleAddress.CustomerNo)}", "${getFormattedStringForSave(singleAddress.Address2)}", "${getFormattedStringForSave(singleAddress.Address3)}", $_isShippingInt )  , ''';
      }
      values = values.substring(0, values.lastIndexOf(',') - 1);

      var res = await db.rawInsert('''
    INSERT OR REPLACE INTO $tableName ( Id, Code, TenantId, Address1, City, State, Country, PostCode, TelephoneNo, BusinessEmail, SalesSite, ShipSite, PortalCompanyId, PortalUserId, CustomerNo, Address2, Address3, IsShippingInt )
          VALUES $values
    ''');

      return res;
    } catch (e) {
      print('Error inside addAddresses');
      print(e);
      throw Future.error(e);
    }
  }

  ///IT RETURNS THE SINGLE COMPANY OBJECT FROM CUSTOMER_NO PROVIDED
  Future<List<Address>> getAddressByCustomerNo({
    String customerNo,
  }) async {
    try {
      Address _address = Address();
      final db = await DBProvider.db.database;
      String _query =
          'SELECT * FROM $tableName WHERE CustomerNo LIKE "${'%' + customerNo + '%'}"';

      var res = await db.rawQuery(_query);
      print(res);
      List<Address> _list =
          res.isNotEmpty ? res.map((c) => Address.fromJson(c)).toList() : [];
      return _list;
    } catch (e) {
      print('Error Inside getAddressByCustomerNo() FN ');
      print(e);
      return Future.error(e);
    }
  }

  ///IT RETURNS THE SINGLE ADDRESS OBJECT FROM ADDRESS_CODE PROVIDED
  Future<Address> getAddressByCode({
    String addressCode,
    String customerCode,
  }) async {
    try {
      Address _address = Address();
      final db = await DBProvider.db.database;
      String _query =
          'SELECT * FROM $tableName WHERE Code LIKE "${'%' + addressCode + '%'}" AND CustomerNo LIKE "${'%' + customerCode + '%'}"';
      print("getAddressByCode Req");
      print(_query);
      var res = await db.rawQuery(_query);
      print("getAddressByCode Res");
      print(res);
      List<Address> _list =
          res.isNotEmpty ? res.map((c) => Address.fromJson(c)).toList() : [];
      return _list.first;
    } catch (e) {
      print('Error Inside getAddressByCode() FN ');
      print(e);
      return Future.error(e);
    }
  }

  ///IT DELETES ALL THE ROWS FROM THE LOCAL_DATABASE
  Future deleteALLRows() async {
    try {
      final db = await DBProvider.db.database;
      final deleteRes = await db.delete(tableName);
      print('deleteCompanies Res');
      print(deleteRes);
      return deleteRes;
    } catch (e) {
      print('Error inside deleteALLRows FN');
      print(e);
      throw Future.error(e);
    }
  }
}
