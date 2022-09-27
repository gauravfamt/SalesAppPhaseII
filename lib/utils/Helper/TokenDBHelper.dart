import 'package:flutter/material.dart';
import 'package:moblesales/helpers/index.dart';
import 'package:moblesales/models/index.dart';
import 'package:moblesales/utils/index.dart';

class TokenDBHelper {
  ///IT HOLDS THE TABLE CREATE QUERY
  final String tableName = 'TokenMaster';

  ///RETURNS THE CREATE TABLE QUERY FOR THE SyncMaster
  ///ANY NEW FIELDS ADD, UPDATE OR DELETE IN LOCAL DATABASE MUST BE DONE HERE
  String getTableCreateQuery() {
    return '''
          CREATE TABLE IF NOT EXISTS $tableName(
                    Id INTEGER PRIMARY KEY,
                    Token TEXT,
                    Username TEXT,
                    ApiDomain TEXT
                    
          )
          ''';
  }

  ///IT RETURNS THE TokenHelper TABLE ALL ENTRIES
  Future<List<TokenHelper>> getLocalDBTokens() async {
    try {
      final db = await DBProvider.db.database;
      var res = await db.query('$tableName');
      List<TokenHelper> list = res.isNotEmpty
          ? res.map((c) => TokenHelper.fromJson(c)).toList()
          : [];
      return list;
    } catch (e) {
      print('Error inside getLocalDBTokens');
      print(e);
      return Future.error(e);
    }
  }

  /// IT INSERTS SINGLE TOKEN DATA TO THE LOCAL_DB
  Future addToken({
    @required TokenHelper tokenHelperObject,
  }) async {
    try {
      final db = await DBProvider.db.database;
      print('Inside addToken after database connection received!');
      var res = await db.rawInsert('''
    INSERT OR REPLACE INTO $tableName ( Id, Token,Username,ApiDomain )
          VALUES ( ${tokenHelperObject.Id}, "${getFormattedStringForSave(tokenHelperObject.Token)}",
          "${getFormattedStringForSave(tokenHelperObject.Username)}",
          "${getFormattedStringForSave(tokenHelperObject.ApiDomain)}")
    ''');

      return res;
    } catch (e) {
      print('Error inside addToken');
      print(e);
      throw Future.error(e);
    }
  }

  ///IT DELETES ALL THE ROWS FROM THE LOCAL_DATABASE
  Future deleteALLRows() async {
    try {
      final db = await DBProvider.db.database;
      final deleteRes = await db.delete(tableName);
      print('delete all localDB Tokens Res');
      print(deleteRes);
      return deleteRes;
    } catch (e) {
      print('Error inside deleteALLRows FN');
      print(e);
      throw Future.error(e);
    }
  }
}
