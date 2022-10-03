import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:moblesales/helpers/index.dart';
import 'package:moblesales/models/index.dart';
import 'package:moblesales/utils/index.dart';

class CompanyDBHelper {
  ///IT HOLDS THE TABLE CREATE QUERY
  final String tableName = 'Company';

  String getTableCreateQuery() {
    return '''
          CREATE TABLE IF NOT EXISTS $tableName(
          Id INTEGER,
          Name TEXT,
          CustomerNo TEXT PRIMARY KEY,
          TenantId INTEGER,
          DefaultBillAdd TEXT,
          DefaultShippAdd TEXT,
          Type TEXT,
          SalesRep TEXT,
          CurrencyCode TEXT,
          CreditLimit REAL,
          Balance REAL,
          TotalBalance REAL,
          IsActiveInt INTEGER,
          City TEXT,
          PostCode TEXT,
          addressesString TEXT
          )
          ''';
  }

  String getTableDropQuery() {
    return '''
          DROP TABLE IF EXISTS $tableName
          ''';
  }

  /// IT FETCHES THE COMPANY_DATA FROM THE API AND INSERT IT IN THE LOCAL DATABASE
  Future<List<Company>> fetchCompanies({
    String lastSyncDate,
    String tokenValue = '',
    String apiDomain = '',
    String Username = '',
  }) async {
    try {
      var companyData = List<Company>();
      String url = '${apiDomain}/${URLs.GET_COMPANIES}?backgroundSync=true';
      if (lastSyncDate != null && lastSyncDate.trim().length > 0) {
        url += '&lastsyncdate=$lastSyncDate';
      }
      print('$url');
      http.Client client = http.Client();
      final response = await client.get(url, headers: {
        "token": tokenValue != null && tokenValue != ''
            ? tokenValue
            : await Session.getData(Session.accessToken),
        "Username": Username != null && Username != ''
            ? Username
            : await Session.getData(Session.userName),
      }).timeout(duration);
      print('response.statusCode: ${response.statusCode}');
      if (response.statusCode == 200 && response.body != null) {
        var data = json.decode(response.body);
        companyData =
            data.map<Company>((json) => Company.fromJson(json)).toList();
        return companyData;
      } else if (response.statusCode == 204 ||
          (response.body != null &&
              response.body.toString().contains('No Companies found'))) {
        print('getcompanies 204 response returned so no updated data present');
        return companyData;
      } else {
        print('response.body : ');
        print(response.body);
        throw Future.error(
          ErrorDescription(
              '${response.body != null ? response.body.toString() : 'Error response received from api'}'),
        );
      }
    } catch (e) {
      print('Error inside fetchCompanies Fn ');
      print(e);
      throw Future.error(e);
    }
  }

  ///INSERTS THE NEW COMPANY IN LOCAL_STORAGE USING THE MODEL
  Future newCompany(Company company) async {
    final db = await DBProvider.db.database;
    var res = await db.insert('Company', company.toJson());
    return res;
  }

  String getFormattedString(String val) {
    return val != null ? val.replaceAll('"', ' ') : '';
  }

  /// IT INSERTS MULTIPLE COMPANIES DATA TO THE LOCAL_DB
  Future addCompanies(List<Company> companies) async {
    try {
      final db = await DBProvider.db.database;
      var sqltQuery = " PRAGMA table_info($tableName) ";
      var ress = await db.rawQuery(sqltQuery);
      if(!ress.toString().contains('DefaultShippAdd')){
        sqltQuery="alter table $tableName add column DefaultShippAdd TEXT ";
        await db.rawQuery(sqltQuery);
      }
      print('Inside addCompanies after database connection received!');
      String values = "";
      List<Address> addressList = List<Address>();
      for (var i = 0; i < companies.length; i++) {
        Company singleCompany = companies[i];
        int isActiveInt =
            singleCompany.IsActive != null && singleCompany.IsActive ? 1 : 0;

        double totalBal = singleCompany.TotalBalance != null
            ? singleCompany.TotalBalance
            : 0.0;
        String City = "";
        String PostCode = "";
        for (var address = 0;
            address < singleCompany.addresses.length;
            address++) {
          City += '${singleCompany.addresses[address].City},';
          PostCode += '${singleCompany.addresses[address].PostCode},';
          addressList.add(singleCompany.addresses[address]);
        }
        values +=
            '''( ${singleCompany.Id} ,"${getFormattedString(singleCompany.Name)}", "${getFormattedString(singleCompany.CustomerNo)}", 
             ${singleCompany.TenantId}, "${getFormattedString(singleCompany.CurrencyCode)}", ${singleCompany.CreditLimit},
             ${singleCompany.Balance},"${getFormattedString(singleCompany.DefaultBillAdd)}","${getFormattedString(singleCompany.DefaultShippAdd)}", "${getFormattedString(singleCompany.Type)}", 
            "${getFormattedString(singleCompany.SalesRep)}", $totalBal, $isActiveInt, "$City", "$PostCode" )  , ''';
      }
      values = values.substring(0, values.lastIndexOf(',') - 1);

      var res = await db.rawInsert('''
    INSERT OR REPLACE INTO $tableName ( Id, name, customerNo, tenantId, currencyCode, creditLimit, balance, 
    defaultBillAdd,DefaultShippAdd, type, salesRep, totalBalance, IsActiveInt, City, PostCode )
          VALUES $values
    ''');
      if (addressList.length > 0) {
        print('Company Address');
        await AddressDBHelper().addAddresses(addressList);
      }

      return res;
    } catch (e) {
      print('Error inside addCompanies');
      print(e);
      throw Future.error(e);
    }
  }

  ///IT RETURNS ALL THE COMPANIES LIST
  Future<List<Company>> getAllCompanies() async {
    final db = await DBProvider.db.database;
    var res = await db.query("Company");
    List<Company> list =
        res.isNotEmpty ? res.map((c) => Company.fromJson(c)).toList() : [];
    return list;
  }

  ///IT RETURNS ALL THE COMPANIES LIST WITH ADDRESSES
  Future<List<Company>> getAllCompaniesWithAddresses() async {
    final db = await DBProvider.db.database;
    var res = await db.query("Company");
    var resAddress = await db.query("Address");
    List<Company> listCompany =
        res.isNotEmpty ? res.map((c) => Company.fromJson(c)).toList() : [];
    List<Address> listAddress = res.isNotEmpty
        ? resAddress.map((c) => Address.fromJson(c)).toList()
        : [];
    print("address length: $listAddress");
    print("company length: $listCompany");
    List<Company> emptyCompanyList = List<Company>();

    for (var a = 0; a < listAddress.length; a++) {
      if (emptyCompanyList.length > 0) {
        var isFound = false;
        for (var e = 0; e < emptyCompanyList.length; e++) {
          if (emptyCompanyList[e].CustomerNo.trim() ==
              listAddress[a].CustomerNo.trim()) {
            emptyCompanyList[e].addresses.add(listAddress[a]);
            isFound = true;
            break;
          }
        }
        if (!isFound) {
          for (var e = 0; e < listCompany.length; e++) {
            if (listCompany[e].CustomerNo.trim() ==
                listAddress[a].CustomerNo.trim()) {
              listCompany[e].addresses.add(listAddress[a]);
              emptyCompanyList.add(listCompany[e]);
              break;
            }
          }
        }
      } else {
        for (var e = 0; e < listCompany.length; e++) {
          if (listCompany[e].CustomerNo.trim() ==
              listAddress[a].CustomerNo.trim()) {
            listCompany[e].addresses.add(listAddress[a]);
            emptyCompanyList.add(listCompany[e]);
            break;
          }
        }
      }
    }

    // emptyCompanyList     listCompany      listAddresses

    print("empty company length: $emptyCompanyList");
    return emptyCompanyList;
  }

  ///IT RETURNS THE COMPANIES LIST USING THE PAGINATION WISE
  Future<List<Company>> getCompaniesPaginationData({
    int pageNo,
    int pageSize,
    String searchText,
    CustomerSearch type,
  }) async {
    try {
      ///HERE AS PAGES START FROM 0 IN SQLITE SO DECREASING THE PAGE NO. BY 1
      ///THIS CHANGES ARE DONE TO MATCH THE EXTERNAL API CALLS PAGINATION's PAGE_NO FORMAT
      pageNo = pageNo - 1;

      ///GETTING THE RECORDS POSITIONS BY PAGE SIZE * PAGE NUMBER COUNTS
      pageNo = pageNo * pageSize;
      final db = await DBProvider.db.database;
      String _query = 'SELECT * FROM $tableName WHERE 1=1  ';
      if (searchText != null && searchText.trim().length > 0) {
        if (type != null) {
          switch (type) {
            case CustomerSearch.customerNumber:
              _query +=
                  ''' and ( CustomerNo LIKE '${'%' + searchText + '%'}' ) ''';
              break;
            case CustomerSearch.customerName:
              _query += ''' and ( Name LIKE '${'%' + searchText + '%'}' ) ''';
              break;
            case CustomerSearch.city:
              _query += ''' and ( City LIKE '${'%' + searchText + '%'}' ) ''';
              break;
            case CustomerSearch.zip:
              _query +=
                  ''' and ( PostCode LIKE '${'%' + searchText + '%'}' ) ''';
              break;
          }
        } else {
          _query +=
              ''' and ( Name LIKE '${'%' + searchText + '%'}' OR CustomerNo LIKE '${'%' + searchText + '%'}' ) ''';
        }
      }
      _query +=
          " and IsActiveInt=1  ORDER BY CustomerNo asc LIMIT $pageNo, $pageSize ";
      print('customer query: $_query');
      var res = await db.rawQuery(_query);
      List<Company> list =
          res.isNotEmpty ? res.map((c) => Company.fromJson(c)).toList() : [];

      if (list.length > 0) {
        final List<dynamic> responses = await Future.wait(
          list.map((Company singleCompany) {
            return AddressDBHelper()
                .getAddressByCustomerNo(
                    customerNo: singleCompany.CustomerNo.trim())
                .then((addresses) {
              singleCompany.addresses.addAll(addresses);
            });
          }),
        );
      }
      return list;
    } catch (e) {
      print('Error inside executeGetCompaniesRawQuery Fn');
      print(e);
      return Future.error(e);
    }
  }

  ///IT RETURNS THE SINGLE COMPANY OBJECT FROM CUSTOMER_NO PROVIDED
  Future<List<Company>> getCompanyByCustomerNos({
    List<String> customerNoList,
  }) async {
    try {
      Company _company = Company();
      final db = await DBProvider.db.database;
      String _query = 'SELECT * FROM $tableName WHERE CustomerNo IN ( ';
      for (var cn = 0; cn < customerNoList.length; cn++) {
        _query += '"${customerNoList[cn]}"';
        if (cn < customerNoList.length - 1) {
          _query += ',';
        }
      }
      _query += ' ) ';
      var res = await db.rawQuery(_query);
      List<Company> _list =
          res.isNotEmpty ? res.map((c) => Company.fromJson(c)).toList() : [];
      return _list;
    } catch (e) {
      print('Error Inside getCompanyByCustomerNo() FN ');
      print(e);
      return Future.error(e);
    }
  }

  ///IT RETURNS THE SINGLE COMPANY OBJECT FROM CUSTOMER_NO PROVIDED
  Future<List<Company>> getCompanywithAddressesByCustomerNos({
    List<String> customerNoList,
  }) async {
    try {
      print("getCompanywithAddressesByCustomerNos");
      Company _company = Company();
      final db = await DBProvider.db.database;
      String _query = 'SELECT * FROM $tableName WHERE CustomerNo IN ( ';
      for (var cn = 0; cn < customerNoList.length; cn++) {
        _query += '"${customerNoList[cn]}"';
        if (cn < customerNoList.length - 1) {
          _query += ',';
        }
      }
      _query += ' ) ';
      var res = await db.rawQuery(_query);
      _query = 'SELECT * FROM Address WHERE CustomerNo IN ( ';
      for (var cn = 0; cn < customerNoList.length; cn++) {
        _query += '"${customerNoList[cn]}"';
        if (cn < customerNoList.length - 1) {
          _query += ',';
        }
      }
      _query += ' ) ';
      print(_query);
      var resAddress = await db.rawQuery(_query);
      // var res = await db.rawQuery(_query);
      print(resAddress);
      List<Company> _list =
          res.isNotEmpty ? res.map((c) => Company.fromJson(c)).toList() : [];
      List<Address> listAddress = resAddress.isNotEmpty
          ? resAddress.map((c) => Address.fromJson(c)).toList()
          : [];

      for (var company in _list) {
        company.addresses.addAll(listAddress
            .where((singleAdd) => singleAdd.CustomerNo == company.CustomerNo));
        print(company.toJson());
      }
      return _list;
    } catch (e) {
      print('Error Inside getCompanyByCustomerNo() FN ');
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

  Future<int> getCompanyCount(String strWhereClause) async {
    try {
      final db = await DBProvider.db.database;
      String _query =
          "SELECT count(*) FROM $tableName where IsActiveInt=1 $strWhereClause ";
      print('getCompanyCount Query : $_query');
      var res = await db.rawQuery(_query);
      final companyCount = Sqflite.firstIntValue(res);
      return companyCount;
    } catch (e) {
      print('Error Inside getCompanyCount FN ');
      print(e);
      return Future.error(e);
    }
  }
}
