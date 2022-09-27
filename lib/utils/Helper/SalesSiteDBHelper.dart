import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:moblesales/helpers/index.dart';
import 'package:moblesales/utils/index.dart';
import 'package:moblesales/models/index.dart';

class SalesSiteDBHelper {
  ///IT HOLDS THE TABLE CREATE QUERY/
  final String tableName = 'SalesSite';

  String getTableCreateQuery() {
    return '''
          CREATE TABLE IF NOT EXISTS $tableName(
            Id INTEGER PRIMARY KEY,
            TenantId INTEGER,
            SiteCode TEXT,
            SiteName TEXT,
            CreatedDate TEXT,
            UpdatedDate TEXT
          )
          ''';
  }

  /// IT FETCHES THE SALES_SITES_DATA FROM THE API AND INSERT IT IN THE LOCAL DATABASE
  Future<List<SalesSite>> fetchSalesSites({
    String lastSyncDate,
    String tokenValue = '',
  }) async {
    try {
      var salesSiteData = List<SalesSite>();
      String url =
          '${await Session.getData(Session.apiDomain)}/${URLs.GET_SALES_SITE}';
      if (lastSyncDate != null && lastSyncDate.trim().length > 0) {
        url += '?lastsyncdate=$lastSyncDate';
      }
      print('$url');
      http.Client client = http.Client();
      final response = await client.get(url, headers: {
        "token": tokenValue != null && tokenValue != ''
            ? tokenValue
            : await Session.getData(Session.accessToken)
      }).timeout(duration);
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        salesSiteData =
            data.map<SalesSite>((json) => SalesSite.fromJson(json)).toList();
        return salesSiteData;
      } else if (response.statusCode == 204) {
        print('salesSites 204 response returned so no updated data present');
        return salesSiteData;
      } else {
        throw Future.error(
          ErrorDescription(
              '${response.body != null ? response.body.toString() : 'Error response received from api'}'),
        );
      }
    } catch (e) {
      print('Error inside fetchSalesSites Fn ');
      print(e);
      throw Future.error(e);
    }
  }

  /// IT INSERTS MULTIPLE SALES_SITE DATA TO THE LOCAL_DB
  Future addSalesSites(List<SalesSite> salesSites) async {
    try {
      final db = await DBProvider.db.database;
      print('ADDING addSalesSites DATA');
      String values = "";

      for (var i = 0; i < salesSites.length; i++) {
        SalesSite singleSalesSite = salesSites[i];
        values += '''(  ${singleSalesSite.Id} ,
                  ${singleSalesSite.TenantId}, 
                  "${getFormattedStringForSave(singleSalesSite.SiteCode)}", 
                  "${getFormattedStringForSave(singleSalesSite.SiteName)}", 
                  "${getFormattedStringForSave(singleSalesSite.CreatedDate)}",
                  "${getFormattedStringForSave(singleSalesSite.UpdatedDate)}"
                  )  , ''';
      }
      values = values.substring(0, values.lastIndexOf(',') - 1);

      var res = await db.rawInsert('''
        INSERT OR REPLACE INTO $tableName (
                Id ,
                TenantId ,
                SiteCode,
                SiteName,
                CreatedDate,
                UpdatedDate 
              )
              VALUES $values
        ''');

      return res;
    } catch (e) {
      print('Error inside addSalesSites');
      print(e);
      throw Future.error(e);
    }
  }

  ///IT RETURNS THE SALES_SITE LIST
  Future<List<SalesSite>> getSalesSitesData() async {
    try {
      final db = await DBProvider.db.database;
      String _query = '''SELECT * FROM $tableName ''';
      var res = await db.rawQuery(_query);
      List<SalesSite> list =
          res.isNotEmpty ? res.map((c) => SalesSite.fromJson(c)).toList() : [];
      return list;
    } catch (e) {
      print('Error inside getSalesSitesData Fn');
      print(e);
      return Future.error(e);
    }
  }

  ///IT RETURNS THE SALES_SITES LIST USING THE PAGINATION WISE
  Future<List<SalesSite>> getSalesSitePaginationData({
    int pageNo,
    int pageSize,
    String searchText,
  }) async {
    try {
      ///HERE AS PAGES START FROM 0 IN SQLITE SO DECREASING THE PAGE NO. BY 1
      ///THIS CHANGES ARE DONE TO MATCH THE EXTERNAL API CALLS PAGINATION's PAGE_NO FORMAT
      pageNo = pageNo - 1;

      ///GETTING THE RECORDS POSITIONS BY PAGE SIZE * PAGE NUMBER COUNTS
      pageNo = pageNo * pageSize;
      final db = await DBProvider.db.database;
      String _query = 'SELECT * FROM $tableName ';
      if (searchText != null && searchText.trim().length > 0) {
        _query +=
            ''' WHERE ( SiteCode LIKE '${'%' + searchText + '%'}' OR SiteName LIKE '${'%' + searchText + '%'}' ) ''';
      }

      _query += ' ORDER BY Id DESC LIMIT $pageNo, $pageSize ';
      var res = await db.rawQuery(_query);
      List<SalesSite> list =
          res.isNotEmpty ? res.map((c) => SalesSite.fromJson(c)).toList() : [];
      return list;
    } catch (e) {
      print('Error inside getSalesSitePaginationData Fn');
      print(e);
      return Future.error(e);
    }
  }

  ///IT RETURNS THE SALES_SITES DATA FROM SiteCode's PROVIDED
  Future<List<SalesSite>> getSalesSitesBySiteCodes({
    List<String> siteCodeList,
  }) async {
    try {
      final db = await DBProvider.db.database;
      String _query = 'SELECT * FROM $tableName WHERE SiteCode IN ( ';
      for (var cn = 0; cn < siteCodeList.length; cn++) {
        _query += '"${siteCodeList[cn]}"';
        if (cn < siteCodeList.length - 1) {
          _query += ',';
        }
      }
      _query += ' ) ';
      var res = await db.rawQuery(_query);
      List<SalesSite> _list =
          res.isNotEmpty ? res.map((c) => SalesSite.fromJson(c)).toList() : [];
      return _list;
    } catch (e) {
      print('Error Inside getSalesSitesBySiteCodes FN ');
      print(e);
      return Future.error(e);
    }
  }

  Future<List<SalesSite>> getLoginUserSalesSite() async {
    try {
      final db = await DBProvider.db.database;
      String salesSiteCode = await Session.getSalesSiteCode();
      print('Sales Site Code:${salesSiteCode}');
      String _query =
          "SELECT * FROM $tableName WHERE SiteCode='${salesSiteCode}'";
      print(_query);
      var res = await db.rawQuery(_query);
      List<SalesSite> _list =
          res.isNotEmpty ? res.map((c) => SalesSite.fromJson(c)).toList() : [];
      return _list;
    } catch (e) {
      print('Error Inside getLoginUserSalesSite FN ');
      print(e);
      return Future.error(e);
    }
  }

  ///IT DELETES ALL THE ROWS FROM THE LOCAL_DATABASE
  Future deleteALLRows() async {
    try {
      final db = await DBProvider.db.database;
      final deleteRes = await db.delete(tableName);
      print('deleteSalesSites Res');
      print(deleteRes);
      return deleteRes;
    } catch (e) {
      print('Error inside deleteALLRows FN for SalesSite');
      print(e);
      throw Future.error(e);
    }
  }
}
