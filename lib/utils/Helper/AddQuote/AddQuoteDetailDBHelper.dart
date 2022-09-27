import 'package:moblesales/helpers/index.dart';
import 'package:moblesales/models/index.dart';
import 'package:moblesales/utils/index.dart';

class AddQuoteDetailDBHelper {
  ///IT HOLDS THE TABLE CREATE QUERY
  final String tableName = 'QuoteDetail';

  String getTableCreateQuery() {
    return '''
          CREATE TABLE IF NOT EXISTS $tableName(
              Id INTEGER PRIMARY KEY AUTOINCREMENT,
              FieldName TEXT,
              FieldValue TEXT, 
              LabelName TEXT,
              DetailReferenceId TEXT,
              AddQuoteID INTEGER,
              IsReadonlyInt INTEGER,
              IsRequiredInt INTEGER,
              FOREIGN KEY(AddQuoteID) REFERENCES ${AddQuoteDBHelper().tableName}(Id)
          )
          ''';
  }

  ///IT INSERTS THE QUOTE DETAIL FIELDS
  Future<AddQuoteDetail> insertQuoteDetailFields({
    List<QuoteDetailField> detailFields,
    String quoteDetailReferenceId,
    AddQuote quote,
  }) async {
    try {
      print('Inside insertQuoteDetailFields Fn ');
      final db = await DBProvider.db.database;
      String values = "";
      print('detailFields.length : ${detailFields.length}');

      for (var i = 0; i < detailFields.length; i++) {
        QuoteDetailField singleQuoteDetailField = detailFields[i];
        int _isRequired = singleQuoteDetailField.IsRequired ? 1 : 0;
        int _isReadonly = singleQuoteDetailField.IsReadonly ? 1 : 0;

        values +=
            '''( "${getFormattedStringForSave(singleQuoteDetailField.FieldName)}" ,"${getFormattedStringForSave(singleQuoteDetailField.FieldValue)}", "${getFormattedStringForSave(singleQuoteDetailField.LabelName)}", "${getFormattedStringForSave(singleQuoteDetailField.DetailReferenceId)}", ${singleQuoteDetailField.AddQuoteID}, $_isReadonly, $_isRequired  )  , ''';
      }
      values = values.substring(0, values.lastIndexOf(',') - 1);
      print('Values : $values ');

      String _insertQuery = ''' 
          INSERT INTO $tableName ( FieldName, FieldValue, LabelName, DetailReferenceId, AddQuoteID, IsReadonlyInt, IsRequiredInt ) 
          VALUES $values
      ''';
      print('QuoteDetailFields_insertQuery : $_insertQuery');
      var _addQuoteDetailRes = await db.rawInsert(_insertQuery);

      print('_addQuoteDetailRes : $_addQuoteDetailRes');

      ///UPDATING DetailReferenceId TO ADD_QUOTE TABLE
      print('Updating quoteDetailReferenceId in AddQuote ');
      var _addQuoteUpdateRes = await AddQuoteDBHelper().updateFieldById(
        quoteId: quote.Id,
        fieldName: 'QuoteDetailIds',
        stringFieldValue: quote.QuoteDetailIds,
      );
      print(
          'AddQuote QuoteDetailIds Field Update Response : $_addQuoteUpdateRes');

      ///FETCHING THE UPDATED QUOTE_DETAIL_FIELDS FOR ADD_QUOTE_HEADER
      var _queryRes = await db.rawQuery(
          'SELECT * FROM $tableName WHERE DetailReferenceId="$quoteDetailReferenceId"');
      print('AddQuoteDetailFields get _queryRes received : ');
      List<QuoteDetailField> _tempQuoteDetailFields = _queryRes.isNotEmpty
          ? _queryRes.map((c) => QuoteDetailField.fromJson(c)).toList()
          : [];
      print('Inserted QuoteDetailFields ${_tempQuoteDetailFields.length}');
      AddQuoteDetail _tempAddQuoteDetail = AddQuoteDetail(
        AddQuoteID: quote.Id,
        DetailReferenceId: quoteDetailReferenceId,
        Id: 1,
        QuoteDetailFields: _tempQuoteDetailFields,
      );
      return Future.value(_tempAddQuoteDetail);
    } catch (e) {
      print('Error Inside insertQuoteDetailFields FN ');
      print(e);
      return Future.error(e);
    }
  }

  ///IT INSERTS THE QUOTE DETAIL FIELDS OF THE QUOTE WHICH IS EDITED FROM THE LISTING SCREEN
  Future<List<AddQuoteDetail>> insertServerQuoteDetailFields({
    List<QuoteDetailField> detailFields,
    List<String> quoteDetailReferenceIds,
    AddQuote quote,
  }) async {
    try {
      print('Inside insertQuoteDetailFields Fn ');
      final db = await DBProvider.db.database;
      String values = "";
      print('detailFields.length : ${detailFields.length}');

      for (var i = 0; i < detailFields.length; i++) {
        QuoteDetailField singleQuoteDetailField = detailFields[i];
        int _isRequired = singleQuoteDetailField.IsRequired ? 1 : 0;
        int _isReadonly = singleQuoteDetailField.IsReadonly ? 1 : 0;
        values +=
            '''( "${getFormattedStringForSave(singleQuoteDetailField.FieldName)}" ,"${getFormattedStringForSave(singleQuoteDetailField.FieldValue)}", "${getFormattedStringForSave(singleQuoteDetailField.LabelName)}", "${getFormattedStringForSave(singleQuoteDetailField.DetailReferenceId)}", ${singleQuoteDetailField.AddQuoteID}, $_isReadonly, $_isRequired  )  , ''';
      }
      values = values.substring(0, values.lastIndexOf(',') - 1);
      print('Values : $values ');

      String _insertQuery = ''' 
          INSERT INTO $tableName ( FieldName, FieldValue, LabelName, DetailReferenceId, AddQuoteID, IsReadonlyInt, IsRequiredInt  ) 
          VALUES $values
      ''';
      print('QuoteDetailFields_insertQuery : $_insertQuery');
      var _addQuoteDetailRes = await db.rawInsert(_insertQuery);

      print('_addQuoteDetailRes : $_addQuoteDetailRes');

      ///UPDATING DetailReferenceId TO ADD_QUOTE TABLE
      print('Updating quoteDetailReferenceId in AddQuote ');
      var _addQuoteUpdateRes = await AddQuoteDBHelper().updateFieldById(
        quoteId: quote.Id,
        fieldName: 'QuoteDetailIds',
        stringFieldValue: quote.QuoteDetailIds,
      );
      print(
          'AddQuote QuoteDetailIds Field Update Response : $_addQuoteUpdateRes');

      ///FETCHING THE UPDATED QUOTE_DETAIL_FIELDS FOR ADD_QUOTE_HEADER
      String _query = 'SELECT * FROM $tableName WHERE DetailReferenceId IN ( ';
      for (var cn = 0; cn < quoteDetailReferenceIds.length; cn++) {
        _query += '"${quoteDetailReferenceIds[cn]}"';
        if (cn < quoteDetailReferenceIds.length - 1) {
          _query += ',';
        }
      }
      _query += ' ) ';
      var _queryRes = await db.rawQuery(_query);

      print('AddQuoteDetailFields get _queryRes received : ');
      List<QuoteDetailField> _tempQuoteDetailFields = _queryRes.isNotEmpty
          ? _queryRes.map((c) => QuoteDetailField.fromJson(c)).toList()
          : [];
      print('Inserted QuoteDetailFields ${_tempQuoteDetailFields.length}');
      List<AddQuoteDetail> _tempAddQuoteDetail = List<AddQuoteDetail>();
      quoteDetailReferenceIds.forEach((singleRefId) {
        List<QuoteDetailField> _subQuoteDetailFields = List<QuoteDetailField>();
        _tempQuoteDetailFields.forEach((singleQDF) {
          if (singleRefId == singleQDF.DetailReferenceId) {
            _subQuoteDetailFields.add(singleQDF);
          }
        });
        _tempAddQuoteDetail.add(
          AddQuoteDetail(
            AddQuoteID: quote.Id,
            DetailReferenceId: singleRefId,
            Id: 1,
            QuoteDetailFields: _subQuoteDetailFields,
          ),
        );
      });

      return Future.value(_tempAddQuoteDetail);
    } catch (e) {
      print('Error Inside insertServerQuoteDetailFields FN ');
      print(e);
      return Future.error(e);
    }
  }

  ///IT INSERTS THE QUOTE DETAIL FIELDS
  Future insertUpdateQuoteDetailFields({
    List<QuoteDetailField> detailFields,
  }) async {
    try {
      print('Inside insertUpdateQuoteDetailFields Fn ');
      final db = await DBProvider.db.database;
      String values = "";
      print('detailFields.length : ${detailFields.length}');

      for (var i = 0; i < detailFields.length; i++) {
        QuoteDetailField singleQuoteDetailField = detailFields[i];
        int _isRequired = singleQuoteDetailField.IsRequired ? 1 : 0;
        int _isReadonly = singleQuoteDetailField.IsReadonly ? 1 : 0;
        values +=
            '''( ${singleQuoteDetailField.Id}, "${getFormattedStringForSave(singleQuoteDetailField.FieldName)}" ,
            "${getFormattedStringForSave(singleQuoteDetailField.FieldValue)}", 
            "${getFormattedStringForSave(singleQuoteDetailField.LabelName)}", 
            "${getFormattedStringForSave(singleQuoteDetailField.DetailReferenceId)}", 
            ${singleQuoteDetailField.AddQuoteID}, $_isReadonly, $_isRequired )  , ''';
      }
      values = values.substring(0, values.lastIndexOf(',') - 1);
      print('Values : $values ');

      String _insertUpdateQuery = ''' 
          INSERT OR REPLACE INTO $tableName (Id, FieldName, FieldValue, LabelName, DetailReferenceId, AddQuoteID, IsReadonlyInt, IsRequiredInt ) 
          VALUES $values
      ''';
      print('QuoteDetailFields_insertUpdateQuery : $_insertUpdateQuery');
      var _quoteDetailInsertUpdateRes = await db.rawInsert(_insertUpdateQuery);

      print('_quoteDetailInsertUpdateRes : $_quoteDetailInsertUpdateRes');

      return Future.value(_quoteDetailInsertUpdateRes);
    } catch (e) {
      print('Error Inside insertUpdateQuoteDetailFields FN ');
      print(e);
      return Future.error(e);
    }
  }

  ///IT DELETES QUOTE_DETAILS ROWS FROM THE LOCAL_DATABASE BY ID
  Future deleteRowByQuoteId({
    int addQuoteId,
  }) async {
    try {
      final db = await DBProvider.db.database;
      final deleteRes = await db
          .rawDelete('DELETE FROM $tableName WHERE AddQuoteID = $addQuoteId ');
      print('deleteRowByQuoteId Res');
      print(deleteRes);
      return deleteRes;
    } catch (e) {
      print('Error inside deleteRowByQuoteId FN in AddQuoteDetailDBHelper');
      print(e);
      throw Future.error(e);
    }
  }

  ///IT DELETES QUOTE_DETAILS ROWS FROM THE LOCAL_DATABASE BY DETAIL_REFERENCE_ID
  Future deleteRowByDetailRefId({
    String detailReferenceId,
  }) async {
    try {
      final db = await DBProvider.db.database;
      final deleteRes = await db.rawDelete(
          'DELETE FROM $tableName WHERE DetailReferenceId = "$detailReferenceId" ');
      print('deleteRowByDetailRefId Res');
      print(deleteRes);
      return deleteRes;
    } catch (e) {
      print('Error inside deleteRowByQuoteId FN in AddQuoteDetailDBHelper');
      print(e);
      throw Future.error(e);
    }
  }

  Future<List<QuoteDetailField>> getAllDetailFields() async {
    try {
      List<QuoteDetailField> _tempFields = List<QuoteDetailField>();
      final db = await DBProvider.db.database;
      var res = await db.query(tableName);

      _tempFields = res.isNotEmpty
          ? res.map((c) => QuoteDetailField.fromJson(c)).toList()
          : [];

      return _tempFields;
    } catch (e) {
      print('Error inside getAllDetailFields Fn ');
      print(e);
      return Future.error(e);
    }
  }

  ///IT DELETES ALL THE ROWS FROM THE LOCAL_DATABASE
  Future deleteALLRows() async {
    try {
      final db = await DBProvider.db.database;
      final deleteRes = await db.delete(tableName);
      print('deleteAddQuoteDetail Res');
      print(deleteRes);
      return deleteRes;
    } catch (e) {
      print('Error inside deleteALLRows FN in AddQuoteDetailDBHelper');
      print(e);
      throw Future.error(e);
    }
  }
}
