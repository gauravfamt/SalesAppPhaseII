import 'package:flutter/material.dart';
import 'package:moblesales/models/index.dart';
import 'package:moblesales/utils/index.dart';

class StandardDropDownFieldsDBHelper {
  ///IT HOLDS THE TABLE CREATE QUERY
  final String tableName = 'StandardDropDownField';

  String getTableCreateQuery() {
    return '''
          CREATE TABLE IF NOT EXISTS $tableName(
          Id INTEGER PRIMARY KEY,
          TenantId INTEGER,
          Dropdown TEXT,
          Code TEXT,
          Caption TEXT,
          CreatedDate TEXT,
          UpdatedDate TEXT,
          Entity TEXT
          )
          ''';
  }

  /// IT INSERTS MULTIPLE STANDARD_DROPDOWN_FIELDS DATA TO THE LOCAL_DB
  Future addStandardDropDownFields(
      List<StandardDropDownField> standardDropdownFields) async {
    try {
      final db = await DBProvider.db.database;
      print(
          'Inside addStandardDropDownFields after database connection received!');
      String values = "";

      for (var i = 0; i < standardDropdownFields.length; i++) {
        StandardDropDownField singleStandardDropDownField =
            standardDropdownFields[i];
        values += '''(  ${singleStandardDropDownField.Id} ,
                  ${singleStandardDropDownField.TenantId},  
                  "${getFormattedString(singleStandardDropDownField.Dropdown)}", 
                  "${getFormattedString(singleStandardDropDownField.Code)}", 
                  "${getFormattedString(singleStandardDropDownField.Caption)}",
                  "${getFormattedString(singleStandardDropDownField.CreatedDate)}", 
                  "${getFormattedString(singleStandardDropDownField.UpdatedDate)}",
                  "${getFormattedString(singleStandardDropDownField.Entity)}"
                  )  , ''';
      }
      values = values.substring(0, values.lastIndexOf(',') - 1);

      var res = await db.rawInsert('''
        INSERT OR REPLACE INTO $tableName (
                Id ,
                TenantId ,
                Dropdown ,
                Code ,
                Caption ,
                CreatedDate ,
                UpdatedDate ,
                Entity
              )
              VALUES $values
        ''');

      return res;
    } catch (e) {
      print('Error inside addStandardDropDownFields');
      print(e);
      throw Future.error(e);
    }
  }

  String getFormattedString(String val) {
    return val != null ? val.replaceAll('"', ' ') : '';
  }

  ///IT RETURNS THE STANDARD_DROP_DOWN_FIELD LIST
  Future<List<StandardDropDownField>> getStandardDropDownFieldsData() async {
    try {
      final db = await DBProvider.db.database;
      String _query = '''SELECT * FROM $tableName ''';
      var res = await db.rawQuery(_query);
      List<StandardDropDownField> list = res.isNotEmpty
          ? res.map((c) => StandardDropDownField.fromJson(c)).toList()
          : [];
      return list;
    } catch (e) {
      print('Error inside StandardDropDownField Fn');
      print(e);
      return Future.error(e);
    }
  }

  ///IT RETURNS THE STANDARD_DROP_DOWN_FIELD LIST
  Future<List<StandardDropDownField>> getEntityStandardDropdownFieldsData({
    @required String entity,
    @required String searchText,
  }) async {
    try {
      final db = await DBProvider.db.database;
      String _query = '''SELECT * FROM $tableName where Entity="$entity" ''';
      if (searchText != '') _query += 'AND Dropdown="$searchText"';

      print('StandardDropDownField GetQuery for $entity Entity :  $_query');
      var res = await db.rawQuery(_query);
      List<StandardDropDownField> list = res.isNotEmpty
          ? res.map((c) => StandardDropDownField.fromJson(c)).toList()
          : [];
      return list;
    } catch (e) {
      print('Error inside getEntityStandardDropdownFieldsData Fn');
      print(e);
      return Future.error(e);
    }
  }

  ///IT DELETES ALL THE ROWS FROM THE LOCAL_DATABASE
  Future deleteALLRows() async {
    try {
      final db = await DBProvider.db.database;
      final deleteRes = await db.delete(tableName);
      print('deleteStandardDropDownFields Res');
      print(deleteRes);
      return deleteRes;
    } catch (e) {
      print(
          'Error inside deleteALLRows FN In StandardDropDownFieldsDB_HELPER ');
      print(e);
      throw Future.error(e);
    }
  }
}
