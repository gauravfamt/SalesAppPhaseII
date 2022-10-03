import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:moblesales/helpers/index.dart';
import 'package:moblesales/models/index.dart';
import 'package:moblesales/utils/index.dart';

class ProductDBHelper {
  ///IT HOLDS THE TABLE CREATE QUERY
  final String tableName = 'Product';

  ///RETURNS THE CREATE TABLE QUERY FOR THE PRODUCT
  ///ANY NEW FIELDS ADD, UPDATE OR DELETE IN LOCAL DATABASE MUST BE DONE HERE
  String getTableCreateQuery() {
    return '''
          CREATE TABLE IF NOT EXISTS $tableName(
                    Id INTEGER ,
                    ProductCode TEXT PRIMARY KEY,
                    Description TEXT,
                    Description2 TEXT,
                    Description3 TEXT,
                    BaseUnit TEXT,
                    IsTaxable TEXT,
                    Status TEXT,
                    ProductCategory TEXT,
                    ProductKey TEXT,
                    BasePrice REAL,
                    Weight REAL,
                    UPCCode TEXT,
                    WeightUOM TEXT,
                    CreatedDate datetime,
                    UpdatedDate datetime
          )
          ''';
  }

  String getTableDropQuery() {
    return '''
          DROP TABLE IF EXISTS $tableName
          ''';
  }

  ///IT CALLS THE API TO FETCH THE PRODUCTS LIST
  Future<List<Product>> fetchProducts({
    String lastSyncDate,
    String tokenValue = '',
    String apiDomain = '',
  }) async {
    try {
      var productData = List<Product>();
      String url = '${apiDomain}/${URLs.GET_PRODUCTS}';
      if (lastSyncDate != null && lastSyncDate.trim().length > 0) {
        url += '?lastsyncdate=$lastSyncDate';
      }
      print('$url');
      http.Client client = http.Client();
      final response = await client.get(url, headers: {
        "token": tokenValue != null && tokenValue != ''
            ? tokenValue
            : await Session.getData(Session.accessToken)
      });
//          .timeout(duration);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        productData =
            data.map<Product>((json) => Product.fromJson(json)).toList();
        return productData;
      } else if (response.statusCode == 204) {
        print('products 204 response returned so no updated data present');
        return productData;
      } else {
        throw Future.error(
          ErrorDescription(
              '${response.body != null ? response.body.toString() : 'Error response received from api'}'),
        );
      }
    } catch (e) {
      print('Error inside fetchProducts Fn ');
      print(e);
      throw Future.error(e);
    }
  }

  Future newProduct(Product product) async {
    final db = await DBProvider.db.database;
    var res = await db.insert('$tableName', product.toJson());
    return res;
  }

  String getFormattedString(String val) {
    return val != null ? val.replaceAll('"', ' ') : '';
  }

  Future addProducts(List<Product> products) async {
    try {
      final db = await DBProvider.db.database;

      var sqltQuery = " PRAGMA table_info($tableName) ";
      var ress = await db.rawQuery(sqltQuery);
      if(!ress.toString().contains('Description2')){
        sqltQuery="alter table $tableName add column Description2 TEXT ";
        await db.rawQuery(sqltQuery);
      }
      if(!ress.toString().contains('Description3')){

        sqltQuery="alter table $tableName add column Description3 TEXT ";
        await db.rawQuery(sqltQuery);
      }
      print('Inside addProducts after database connection received!');
      String values = "";
      for (var i = 0; i < products.length; i++) {
        Product singleProduct = products[i];
        values += '''(
         ${singleProduct.Id}, "${getFormattedString(singleProduct.ProductCode)}" , "${getFormattedString(singleProduct.Description)}", "${getFormattedString(singleProduct.Description2)}", "${getFormattedString(singleProduct.Description3)}", "${getFormattedString(singleProduct.BaseUnit)}" , "${getFormattedString(singleProduct.IsTaxable)}" , "${getFormattedString(singleProduct.Status)}" , "${getFormattedString(singleProduct.ProductCategory)}", "${getFormattedString(singleProduct.ProductKey)}" , ${singleProduct.BasePrice} , ${singleProduct.Weight}, "${getFormattedString(singleProduct.UPCCode)}", "${getFormattedString(singleProduct.WeightUOM)}","${singleProduct.CreatedDate}" , "${singleProduct.UpdatedDate}"  
         ) , ''';
      }
      values = values.substring(0, values.lastIndexOf(',') - 1);

      var res = await db.rawInsert(''' 
    INSERT OR REPLACE INTO $tableName ( Id,  ProductCode , Description, Description2, Description3, BaseUnit , IsTaxable , Status , ProductCategory,ProductKey, BasePrice , Weight, UPCCode,WeightUOM, CreatedDate , UpdatedDate ) 
          VALUES $values  
    ''');

      return res;
    } catch (e) {
      print('Error inside addProducts');
      print(e);
//      return 'Unable to insert data into DB for Products';
      throw Future.error(e);
    }
  }

  Future<List<Product>> getAllProducts() async {
    final db = await DBProvider.db.database;
    var res = await db.query('$tableName');
    List<Product> list =
        res.isNotEmpty ? res.map((c) => Product.fromJson(c)).toList() : [];
    return list;
  }

  Future<List<Product>> getProductsPaginationData(
      {int pageNo, int pageSize, String searchText, String searchBy}) async {
    try {
      ///HERE AS PAGES START FROM 0 IN SQLITE SO DECREASING THE PAGE NO. BY 1
      ///THIS CHANGES ARE DONE TO MATCH THE EXTERNAL API CALLS PAGINATION's PAGE_NO FORMAT
      pageNo = pageNo - 1;


      //print(_query);



      ///GETTING THE RECORDS POSITIONS BY PAGE SIZE * PAGE NUMBER COUNTS
      pageNo = pageNo * pageSize;
      final db = await DBProvider.db.database;
      var testquery = " PRAGMA table_info($tableName) ";
      print('testquery--- ${testquery}');
      var ress = await db.rawQuery(testquery);
      if(!ress.toString().contains('Description2')){
        print('----Not Availble-----');
      }


      String _query = 'SELECT * FROM $tableName where 1=1 ';

      if (searchBy == "ProductKey") {
        if (searchText != null && searchText.trim().length > 0) {
          _query += " and  ProductKey = '${searchText}' ";
        }
      } else if (searchBy == "ProductCode") {
        if (searchText != null && searchText.trim().length > 0) {
          _query += " and ProductCode LIKE '${'%' + searchText + '%'}' ";
        }
      } else if (searchBy == "ProductCategory") {
        if (searchText != null && searchText.trim().length > 0) {
          _query += " and ProductCategory LIKE '${'%' + searchText + '%'}' ";
        }
      } else if (searchBy == "ProductDescription") {
        if (searchText != null && searchText.trim().length > 0) {
          _query += " and  Description LIKE '${'%' + searchText + '%'}'  ";
        }
      } else {
        if (searchText != null && searchText.trim().length > 0) {
          _query +=
              " and  Status LIKE '${'%' + searchText + '%'}' OR UPCCode LIKE '${'%' + searchText + '%'}' OR Description LIKE '${'%' + searchText + '%'}' OR ProductCode LIKE '${'%' + searchText + '%'}' ";
        }
      }
      _query += " and Status = 'Active' ";
      _query += " ORDER BY ProductCode asc LIMIT $pageNo, $pageSize ";
      //print(_query);
      var res = await db.rawQuery(_query);
      List<Product> list =
          res.isNotEmpty ? res.map((c) => Product.fromJson(c)).toList() : [];
      return list;
    } catch (e) {
      print('Error inside getProductsPaginationData Fn');
      print(e);
      return Future.error(e);
    }
  }

  //Used in Inventory Screen
  Future<List<Product>> getProductsDetailsForInventory({
    String productCodes,
  }) async {
    try {
      final db = await DBProvider.db.database;
      String _query = 'SELECT  * FROM $tableName where 1=1 ';
      print('productCodes ${productCodes}');
      if (productCodes != null && productCodes.trim().length > 0) {
        _query += ''' and ProductCode in (${productCodes}) ''';
      }
      _query += " and Status = 'Active' ORDER BY ProductCode asc ";
      print(_query);
      var res = await db.rawQuery(_query);
      List<Product> list =
          res.isNotEmpty ? res.map((c) => Product.fromJson(c)).toList() : [];
      return list;
    } catch (e) {
      print('Error inside getProductsDetailsForInventory Fn');
      print(e);
      return Future.error(e);
    }
  }

  ///IT RETURNS THE PRODUCTS LIST FROM PRODUCT_ID's PROVIDED
  /// //Used in Add quote Screen
  Future<List<Product>> getProductsByProductCode({
    List<String> productCodeList,
  }) async {
    try {
      List<Product> _products = List<Product>();
      final db = await DBProvider.db.database;
      String _query = 'SELECT * FROM $tableName WHERE ProductCode IN ( ';
      for (var pc = 0; pc < productCodeList.length; pc++) {
        _query += '"${productCodeList[pc]}"';
        if (pc < productCodeList.length - 1) {
          _query += ',';
        }
      }
      _query += ' ) ';
      _query += " and Status = 'Active' ";
      print('getProductsByProductCode Query : $_query');
      var res = await db.rawQuery(_query);
      List<Product> _list =
          res.isNotEmpty ? res.map((c) => Product.fromJson(c)).toList() : [];

      _products.addAll(_list);
      return _products;
    } catch (e) {
      print('Error Inside getProductsByProductCode FN ');
      print(e);
      return Future.error(e);
    }
  }

  ///IT DELETES ALL THE ROWS FROM THE LOCAL_DATABASE
  Future deleteALLRows() async {
    try {
      final db = await DBProvider.db.database;
      final deleteRes = await db.delete(tableName);
      return deleteRes;
    } catch (e) {
      print('Error inside deleteALLRows FN');
      print(e);
      throw Future.error(e);
    }
  }

  Future<int> getProductCount(String strWhereClause) async {
    try {
      final db = await DBProvider.db.database;
      String _query =
          " SELECT COUNT(*)  FROM $tableName where Status = 'Active' $strWhereClause  ";
      var res = await db.rawQuery(_query);
      final _productCount = Sqflite.firstIntValue(res);
      return _productCount;
    } catch (e) {
      print('Error Inside getProductCount FN ');
      print(e);
      return Future.error(e);
    }
  }

  ///IT DELETES ALL THE ROWS FROM THE LOCAL_DATABASE
  Future updateProductBasePrice(
      String strBasePrice, String strProductCode) async {
    try {
      final db = await DBProvider.db.database;
      String _query =
          "update $tableName set BasePrice= '$strBasePrice' where ProductCode='$strProductCode'";
      var res = await db.rawQuery(_query);
      return "";
    } catch (e) {
      print('Error inside updateProductBasePrice FN');
      print(e);
      throw Future.error(e);
    }
  }
}
