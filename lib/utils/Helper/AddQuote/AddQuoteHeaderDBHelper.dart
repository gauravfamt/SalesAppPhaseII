import 'package:moblesales/helpers/index.dart';
import 'package:moblesales/models/index.dart';
import 'package:moblesales/utils/index.dart';

class AddQuoteHeaderDBHelper {
  ///IT HOLDS THE TABLE CREATE QUERY
  final String tableName = 'QuoteHeader';

  String getTableCreateQuery() {
    return '''
          CREATE TABLE IF NOT EXISTS $tableName(
              Id INTEGER PRIMARY KEY AUTOINCREMENT,
              FieldName TEXT,
              FieldValue TEXT, 
              LabelName TEXT,
              HeaderReferenceId TEXT,
              AddQuoteID INTEGER,
              IsReadonlyInt INTEGER,
              IsRequiredInt INTEGER,
              FOREIGN KEY(AddQuoteID) REFERENCES ${AddQuoteDBHelper().tableName}(Id)
          )
          ''';
  }

  ///IT INSERTS THE QUOTE HEADER FIELDS
  Future<AddQuoteHeader> insertQuoteHeaderFields({
    List<QuoteHeaderField> headerFields,
    String quoteHeaderReferenceId,
    AddQuote quote,
  }) async {
    try {
      print('Inside insertQuoteHeaderFields Fn ');
      final db = await DBProvider.db.database;
      String values = "";
      print('headerFields.length : ${headerFields.length}');

      for (var i = 0; i < headerFields.length; i++) {
        QuoteHeaderField singleQuoteHeaderField = headerFields[i];
        int _isRequired = singleQuoteHeaderField.IsRequired ? 1 : 0;
        int _isReadonly = singleQuoteHeaderField.IsReadonly ? 1 : 0;
        values +=
            '''( "${getFormattedStringForSave(singleQuoteHeaderField.FieldName)}" ,"${getFormattedStringForSave(singleQuoteHeaderField.FieldValue)}", "${getFormattedStringForSave(singleQuoteHeaderField.LabelName)}", "${getFormattedStringForSave(singleQuoteHeaderField.HeaderReferenceId)}", ${singleQuoteHeaderField.AddQuoteID}, $_isReadonly, $_isRequired  )  , ''';
      }
      values = values.substring(0, values.lastIndexOf(',') - 1);
      print('Values : $values ');

      String _insertQuery = ''' 
          INSERT INTO $tableName ( FieldName, FieldValue, LabelName, HeaderReferenceId, AddQuoteID, IsReadonlyInt, IsRequiredInt  ) 
          VALUES $values
      ''';
      print('QuoteHeaderFields_insertQuery : $_insertQuery');
      var _addQuoteHeaderRes = await db.rawInsert(_insertQuery);

      print('_addQuoteHeaderRes : $_addQuoteHeaderRes');

      ///UPDATING HeaderReferenceId TO ADD_QUOTE TABLE
      print('Updating QuoteHeaderReferenceId in AddQuote ');
      var _addQuoteUpdateRes = await AddQuoteDBHelper().updateFieldById(
        quoteId: quote.Id,
        fieldName: 'QuoteHeaderIds',
        stringFieldValue: quote.QuoteHeaderIds,
      );
      print(
          'AddQuote QuoteHeaderIds Field Update Response : $_addQuoteUpdateRes');

      ///FETCHING THE UPDATED QUOTE_HEADER_FIELDS FOR ADD_QUOTE_HEADER
      var _queryRes = await db.rawQuery(
          'SELECT * FROM $tableName WHERE HeaderReferenceId="$quoteHeaderReferenceId"');
      print('AddQuoteHeaderFields get _queryRes received : ');
      List<QuoteHeaderField> _tempQuoteHeaderFields = _queryRes.isNotEmpty
          ? _queryRes.map((c) => QuoteHeaderField.fromJson(c)).toList()
          : [];
      print('Inserted QuoteHeaderFields ${_tempQuoteHeaderFields.length}');
      AddQuoteHeader _tempAddQuoteHeader = AddQuoteHeader(
        AddQuoteID: quote.Id,
        HeaderReferenceId: quoteHeaderReferenceId,
        Id: 1,
        QuoteHeaderFields: _tempQuoteHeaderFields,
      );
      return Future.value(_tempAddQuoteHeader);
    } catch (e) {
      print('Error Inside insertQuoteHeaderFields FN ');
      print(e);
      return Future.error(e);
    }
  }

  ///IT INSERTS THE QUOTE HEADER FIELDS
  Future insertUpdateHeaderFields({
    List<QuoteHeaderField> headerFields,
  }) async {
    try {
      print('Inside insertUpdateHeaderFields Fn ');
      final db = await DBProvider.db.database;
      String values = "";
      print('headerFields.length : ${headerFields.length}');

      for (var i = 0; i < headerFields.length; i++) {
        QuoteHeaderField singleQuoteHeaderField = headerFields[i];

        int _isRequired = singleQuoteHeaderField.IsRequired ? 1 : 0;
        int _isReadonly = singleQuoteHeaderField.IsReadonly ? 1 : 0;
        values +=
            '''(${singleQuoteHeaderField.Id}, "${getFormattedStringForSave(singleQuoteHeaderField.FieldName)}" ,"${getFormattedStringForSave(singleQuoteHeaderField.FieldValue)}", "${getFormattedStringForSave(singleQuoteHeaderField.LabelName)}", "${getFormattedStringForSave(singleQuoteHeaderField.HeaderReferenceId)}", ${singleQuoteHeaderField.AddQuoteID}, $_isReadonly, $_isRequired )  , ''';
      }
      values = values.substring(0, values.lastIndexOf(',') - 1);
      print('Values : $values ');
      print('--------------------------------');
      String _insertUpdateQuery = ''' 
          INSERT OR REPLACE INTO $tableName (Id, FieldName, FieldValue, LabelName, HeaderReferenceId, AddQuoteID, IsReadonlyInt, IsRequiredInt ) 
          VALUES $values
      ''';
      print('QuoteHeaderFields_insertUPDATEQuery : $_insertUpdateQuery');
      var _headerInsertUpdateRes = await db.rawInsert(_insertUpdateQuery);

      print('_headerInsertUpdateRes : $_headerInsertUpdateRes');

      return Future.value(_headerInsertUpdateRes);
    } catch (e) {
      print('Error Inside insertUpdateHeaderFields FN ');
      print(e);
      return Future.error(e);
    }
  }

  ///IT DELETES QUOTE_HEADER ROWS FROM THE LOCAL_DATABASE BY ID
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
      print('Error inside deleteRowByQuoteId FN in AddQuoteHeaderDBHelper');
      print(e);
      throw Future.error(e);
    }
  }

  ///IT DELETES ALL THE ROWS FROM THE LOCAL_DATABASE
  Future deleteALLRows() async {
    try {
      final db = await DBProvider.db.database;
      final deleteRes = await db.delete(tableName);
      print('deleteAddQuoteHeader Res');
      print(deleteRes);
      return deleteRes;
    } catch (e) {
      print('Error inside deleteALLRows FN in deleteAddQuoteHeader');
      print(e);
      throw Future.error(e);
    }
  }
}
