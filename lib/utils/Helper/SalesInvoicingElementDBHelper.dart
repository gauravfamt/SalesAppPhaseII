import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:moblesales/helpers/index.dart';
import 'package:moblesales/models/index.dart';
import 'package:moblesales/utils/index.dart';

class SalesInvoicingElementDBHelper {
  ///IT HOLDS THE TABLE CREATE QUERY
  final String tableName = 'SalesInvoicingElements';

  ///RETURNS THE CREATE TABLE QUERY FOR THE PRODUCT
  ///ANY NEW FIELDS ADD, UPDATE OR DELETE IN LOCAL DATABASE MUST BE DONE HERE
  String getTableCreateQuery() {
    return '''
          CREATE TABLE IF NOT EXISTS $tableName(
                    Id INTEGER PRIMARY KEY AUTOINCREMENT,
                    TransactionNo TEXT,
                    Code TEXT,
                    Description TEXT,
                    Value TEXT,
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

  String getFormattedString(String val) {
    return val != null ? val.replaceAll('"', ' ') : '';
  }

  ///Adds Products to the Local DB
  Future addSalesInvoicingElements(List<SalesInvoicingElement> elements) async {
    try {
      final db = await DBProvider.db.database;
      print('Inside addInvoicingElements after database connection received!');
      String values = "";
      for (var i = 0; i < elements.length; i++) {
        SalesInvoicingElement singleProduct = elements[i];
        values += '''(
         "${getFormattedString(singleProduct.transactionNo)}" , "${getFormattedString(singleProduct.code)}" , "${getFormattedString(singleProduct.description)}", "${singleProduct.value}", "${singleProduct.createdDate}" , "${singleProduct.updatedDate}"  
         ) , ''';
      }
      values = values.substring(0, values.lastIndexOf(',') - 1);

      var res = await db.rawInsert(''' 
    INSERT OR REPLACE INTO $tableName ( TransactionNo, Code , Description, Value, CreatedDate , UpdatedDate ) 
          VALUES $values  
    ''');

      return res;
    } catch (e) {
      print('Error inside addSalesInvoicingElements');
      print(e);
      throw Future.error(e);
    }
  }

  ///IT RETURNS THE INVOICE ELEMENT LIST FROM CODE's PROVIDED
  Future<List<SalesInvoicingElement>> getInvoiceElementByTransactionNo({
    List<String> codeList,
  }) async {
    try {
      List<SalesInvoicingElement> _invoiceElement =
          List<SalesInvoicingElement>();
      final db = await DBProvider.db.database;
      String _query = 'SELECT * FROM $tableName WHERE TransactionNo IN ( ';
      for (var cd = 0; cd < codeList.length; cd++) {
        _query += '"${codeList[cd]}"';
        if (cd < codeList.length - 1) {
          _query += ',';
        }
      }
      _query += ' ) ';
      // _query += " and Status = 'Active' ";
      print('getInvoiceElementByTransactionNo Query : $_query');
      var res = await db.rawQuery(_query);
      List<SalesInvoicingElement> _list = res.isNotEmpty
          ? res.map((c) => SalesInvoicingElement.fromJson(c)).toList()
          : [];

      _invoiceElement.addAll(_list);
      return _invoiceElement;
    } catch (e) {
      print('Error Inside getInvoiceElementByTransactionNo FN ');
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
}
