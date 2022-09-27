import 'package:moblesales/models/index.dart';
import 'package:moblesales/utils/index.dart';
import 'package:sqflite/sqflite.dart';

class StandardFieldsDBHelper {
  ///IT HOLDS THE TABLE CREATE QUERY
  final String tableName = 'StandardField';

  String getTableCreateQuery() {
    return '''
          CREATE TABLE IF NOT EXISTS $tableName(
          Id INTEGER PRIMARY KEY,
          TenantId INTEGER,
          StandardFieldOn INTEGER,
          FieldName TEXT,
          LabelName TEXT,
          Entity TEXT,
          ShowInGridInt INTEGER,
          ShowOnScreenInt INTEGER,
          ShowOnPreviewInt INTEGER,
          SectionName TEXT,
          SortOrder INTEGER,
          IsReadonlyInt INTEGER,
          IsRequiredInt INTEGER 
          )
          ''';
  }

  /// IT INSERTS MULTIPLE STANDARD_FIELDS DATA TO THE LOCAL_DB
  Future addStandardFields(List<StandardField> standardFields) async {
    try {
      final db = await DBProvider.db.database;
      print('Inside addStandardFields after database connection received!');
      String values = "";

      for (var i = 0; i < standardFields.length; i++) {
        StandardField singleStandardField = standardFields[i];
        int _showInGrid = singleStandardField.ShowInGrid ? 1 : 0;
        int _showOnScreen = singleStandardField.ShowOnScreen ? 1 : 0;
        int _showOnPreviewInt = singleStandardField.ShowOnPreview != null &&
                singleStandardField.ShowOnPreview
            ? 1
            : 0;
        int _isRequired = singleStandardField.IsRequired != null &&
                singleStandardField.IsRequired
            ? 1
            : 0;
        int _isReadonly = singleStandardField.IsReadonly != null &&
                singleStandardField.IsReadonly
            ? 1
            : 0;

        values += '''(  ${singleStandardField.Id} ,
                  ${singleStandardField.TenantId}, 
                  ${singleStandardField.StandardFieldOn}, 
                  "${getFormattedString(singleStandardField.FieldName)}", 
                  "${getFormattedString(singleStandardField.LabelName)}", 
                  "${getFormattedString(singleStandardField.Entity)}",
                  $_showInGrid,
                  $_showOnScreen, 
                  "${getFormattedString(singleStandardField.SectionName)}", 
                  ${singleStandardField.SortOrder},
                  $_showOnPreviewInt,
                  $_isReadonly,
                  $_isRequired
                  )  , ''';
      }
      values = values.substring(0, values.lastIndexOf(',') - 1);

      var res = await db.rawInsert('''
        INSERT OR REPLACE INTO $tableName (
                Id ,
                TenantId ,
                StandardFieldOn ,
                FieldName ,
                LabelName ,
                Entity ,
                ShowInGridInt ,
                ShowOnScreenInt ,
                SectionName ,
                SortOrder,
                ShowOnPreviewInt,
                IsReadonlyInt,
                IsRequiredInt 
              )
              VALUES $values
        ''');

      return res;
    } catch (e) {
      print('Error inside addStandardFields');
      print(e);
      throw Future.error(e);
    }
  }

  String getFormattedString(String val) {
    return val != null ? val.replaceAll('"', ' ') : '';
  }

  ///IT RETURNS THE STANDARD_FIELD LIST
  Future<List<StandardField>> getStandardFieldsData() async {
    try {
      final db = await DBProvider.db.database;
      String _query = '''SELECT * FROM $tableName ''';
      var res = await db.rawQuery(_query);
      List<StandardField> list = res.isNotEmpty
          ? res.map((c) => StandardField.fromJson(c)).toList()
          : [];
      return list;
    } catch (e) {
      print('Error inside getCompaniesPaginationData Fn');
      print(e);
      return Future.error(e);
    }
  }

  ///IT RETURNS THE STANDARD_FIELD LIST
  Future<List<StandardField>> getEntityStandardFieldsData({
    String entity,
    bool showInGrid = false,
    bool showOnScreen = false,
    bool showOnPreview = false,
    bool showBySortOrder = false,
  }) async {
    try {
      final db = await DBProvider.db.database;
      String _query = '''SELECT * FROM $tableName where Entity="$entity" ''';
      if (showInGrid) {
        _query += ' AND ShowInGridInt = 1';
      }
      if (showOnScreen) {
        _query += ' AND ShowOnScreenInt = 1';
      }
      if (showOnPreview) {
        _query += ' AND showOnPreviewInt = 1';
      }
      if (showBySortOrder) {
        _query += ' ORDER BY SortOrder ASC';
      }
      print('StandardFields GetQuery for $entity Entity :  $_query');
      var res = await db.rawQuery(_query);
      List<StandardField> list = res.isNotEmpty
          ? res.map((c) => StandardField.fromJson(c)).toList()
          : [];
      return list;
    } catch (e) {
      print('Error inside getEntityStandardFieldsData Fn');
      print(e);
      return Future.error(e);
    }
  }

  Future updateAllShowOnPreview() async {
    try {
      final db = await DBProvider.db.database;
      var res = await db.rawQuery('UPDATE $tableName SET showOnPreviewInt = 1');
      print('updateAllShowOnPreview response : $res');
      return Future.value(true);
    } catch (e) {
      print('Error inside updateAllShowOnPreview ');
      print(e);
      return Future.error(e);
    }
  }

  ///IT DELETES ALL THE ROWS FROM THE LOCAL_DATABASE
  Future deleteALLRows() async {
    try {
      print('inside delete Standard field ------------');
      final db = await DBProvider.db.database;
      final deleteRes = await db.delete(tableName);
      print('deleteStandardFields Res------------');
      print(deleteRes);
      return deleteRes;
    } catch (e) {
      print('Error inside deleteALLRows FN');
      print(e);
      throw Future.error(e);
    }
  }

  Future  removeStandardFieldEntitiwise(String strEntityName) async {
    try {
      final db = await DBProvider.db.database;
      String _query =
          " delete  FROM $tableName where Entity = '$strEntityName'  ";
      print('----- query $_query ');
      var res = await db.rawDelete(_query);
      return res;
    } catch (e) {
      print('Error Inside getProductCount FN ');
      print(e);
      return Future.error(e);
    }
  }

}
