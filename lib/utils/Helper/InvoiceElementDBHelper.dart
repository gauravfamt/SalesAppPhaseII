import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:moblesales/helpers/index.dart';
import 'package:moblesales/models/index.dart';
import 'package:moblesales/utils/index.dart';

class InvoicingElementDBHelper {
  ///IT HOLDS THE TABLE CREATE QUERY
  final String tableName = 'InvoicingElement';

  ///RETURNS THE CREATE TABLE QUERY FOR THE PRODUCT
  ///ANY NEW FIELDS ADD, UPDATE OR DELETE IN LOCAL DATABASE MUST BE DONE HERE
  String getTableCreateQuery() {
    return '''
          CREATE TABLE IF NOT EXISTS $tableName(
                    Id INTEGER ,
                    Code TEXT PRIMARY KEY,
                    Description TEXT,
                    SequenceNumber INTEGER,
                    CreatedDate datetime,
                    UpdatedDate datetime
          )
          ''';
  }

  Future<String> createTableOnBackgroundSyn() async {
    try{
      print('call createTableOnBackgroundSyn $tableName');
      final db = await DBProvider.db.database;
      String strQuery= '''
          CREATE TABLE IF NOT EXISTS $tableName(
                    Id INTEGER ,
                    Code TEXT PRIMARY KEY,
                    Description TEXT,
                    SequenceNumber INTEGER,
                    CreatedDate datetime,
                    UpdatedDate datetime
          )
          ''';
      await db.execute(strQuery);
    }catch (e) {
      print('createTableOnBackgroundSyn $tableName');
      throw Future.error(e);
    }
  }

  String getTableDropQuery() {
    return '''
          DROP TABLE IF EXISTS $tableName
          ''';
  }

  ///IT CALLS THE API TO FETCH THE INVOICING ELEMENT LIST
  Future<List<InvoicingElement>> fetchInvoicingElements({
    String lastSyncDate,
    String tokenValue = '',
    String apiDomain = '',
  }) async {
    try {
      var elementsData = List<InvoicingElement>();
      String url = '${apiDomain}/${URLs.GET_INVOICINGELEMENT}';

      url += '?pageNumber=0&pageSize=10';
      // if (lastSyncDate != null && lastSyncDate.trim().length > 0) {
      //   url += '?lastsyncdate=$lastSyncDate';
      // }
      print('$url');
      http.Client client = http.Client();
      final response = await client.get(url, headers: {
        "token": tokenValue != null && tokenValue != ''
            ? tokenValue
            : await Session.getData(Session.accessToken)
      });
      // .timeout(duration);
      // print("response" + response.body);
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        elementsData = data
            .map<InvoicingElement>((json) => InvoicingElement.fromJson(json))
            .toList();
        return elementsData;
      } else if (response.statusCode == 204) {
        print(
            'InvoicingElements 204 response returned so no updated data present');
        return elementsData;
      } else {
        throw Future.error(
          ErrorDescription(
              '${response.body != null ? response.body.toString() : 'Error response received from api'}'),
        );
      }
    } catch (e) {
      print('Error inside fetchInvoicingElements Fn ');
      print(e);
      throw Future.error(e);
    }
  }

  String getFormattedString(String val) {
    return val != null ? val.replaceAll('"', ' ') : '';
  }

  ///Adds Products to the Local DB
  Future addInvoicingElements(List<InvoicingElement> elements) async {
    try {
      final db = await DBProvider.db.database;
      print('Inside addInvoicingElements after database connection received!');
      String values = "";
      for (var i = 0; i < elements.length; i++) {
        InvoicingElement singleElement = elements[i];
        values += '''(
         ${singleElement.id}, "${getFormattedString(singleElement.code)}" , "${getFormattedString(singleElement.description)}",${singleElement.sequenceNumber},  "${singleElement.createdDate}" , "${singleElement.updatedDate}"  
         ) , ''';
      }
      values = values.substring(0, values.lastIndexOf(',') - 1);

      var res = await db.rawInsert(''' 
    INSERT OR REPLACE INTO $tableName ( Id,  Code , Description,SequenceNumber, CreatedDate , UpdatedDate ) 
          VALUES $values  
    ''');

      return res;
    } catch (e) {
      print('Error inside addInvoicingElements');
      print(e);
      throw Future.error(e);
    }
  }

  ///IT RETURNS THE INVOICE ELEMENT LIST FROM CODE's PROVIDED
  Future <List<InvoicingElement>> getAllInvoiceElements() async {
    try {
      List<InvoicingElement> _invoiceElement = List<InvoicingElement>();
      final db = await DBProvider.db.database;
      String _query = 'SELECT * FROM $tableName';
      print('getInvoiceElementByCode Query : $_query');
      var res = await db.rawQuery(_query);
      print(res);
      List<InvoicingElement> _list = res.isNotEmpty
          ? res.map((c) => InvoicingElement.fromJson(c)).toList()
          : [];

      _invoiceElement.addAll(_list);
      return _invoiceElement;
    } catch (e) {
      print('Error Inside getInvoiceElementByCode FN ');
      print(e);
      return Future.error(e);
    }
  }

  Future <List<InvoicingElement>> getActiveInvoiceElements() async {
    try {
      List<InvoicingElement> _invoiceElement = List<InvoicingElement>();
      final db = await DBProvider.db.database;
      String _query = 'SELECT * FROM $tableName where SequenceNumber >0';
      print('getInvoiceElementByCode Query : $_query');
      var res = await db.rawQuery(_query);
      print(res);
      List<InvoicingElement> _list = res.isNotEmpty
          ? res.map((c) => InvoicingElement.fromJson(c)).toList()
          : [];

      _invoiceElement.addAll(_list);
      return _invoiceElement;
    } catch (e) {
      print('Error Inside getInvoiceElementByCode FN ');
      print(e);
      return Future.error(e);
    }
  }


  ///IT RETURNS THE INVOICE ELEMENT LIST FROM CODE's PROVIDED
  Future<List<InvoicingElement>> getInvoiceElementByCode({
    List<String> codeList,
  }) async {
    try {
      List<InvoicingElement> _invoiceElement = List<InvoicingElement>();
      final db = await DBProvider.db.database;
      String _query = 'SELECT * FROM $tableName WHERE Code IN ( ';
      for (var cd = 0; cd < codeList.length; cd++) {
        _query += '"${codeList[cd]}"';
        if (cd < codeList.length - 1) {
          _query += ',';
        }
      }
      _query += ' ) ';
      // _query += " and Status = 'Active' ";
      print('getInvoiceElementByCode Query : $_query');
      var res = await db.rawQuery(_query);
      List<InvoicingElement> _list = res.isNotEmpty
          ? res.map((c) => InvoicingElement.fromJson(c)).toList()
          : [];

      _invoiceElement.addAll(_list);
      return _invoiceElement;
    } catch (e) {
      print('Error Inside getInvoiceElementByCode FN ');
      print(e);
      return Future.error(e);
    }
  }

  Future alterInvoicingElementTable() async {
    try {
      print('------InvoicingElementTable');
      var res=false;
      final db = await DBProvider.db.database;
      var sqltQuery = " PRAGMA table_info($tableName) ";
      var ress = await db.rawQuery(sqltQuery);
      print('--PRAGMA----${ress}');
      if(!ress.toString().contains('SequenceNumber')){
        sqltQuery="alter table $tableName add column SequenceNumber INTEGER ";
        print('------#$sqltQuery');
        await db.rawQuery(sqltQuery);
        res=true;
      }

      return res;
    } catch (e) {
      print('Error inside alterInvoicingElementTable');
      print(e);
//      return 'Unable to insert data into DB for Products';
      throw Future.error(e);
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
}
