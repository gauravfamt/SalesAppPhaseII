import 'package:flutter/material.dart';
import 'package:moblesales/models/index.dart';
import 'package:moblesales/utils/index.dart';
import 'package:sqflite/sqflite.dart';

class AddQuoteDBHelper {
  ///IT HOLDS THE TABLE CREATE QUERY
  final String tableName = 'Quote';

  String getTableCreateQuery() {
    return '''
          CREATE TABLE IF NOT EXISTS $tableName(
              Id INTEGER PRIMARY KEY AUTOINCREMENT,
              Active Integer,
              QuoteHeaderIds TEXT,
              QuoteDetailIds TEXT,
              CreatedDate datetime,
              UpdatedDate datetime,
              IsLocalQuote Integer,
              ServerUpdatedDate TEXT,
              ServerQuoteId Integer
          )
          ''';
  }

  ///IT RETURNS ALL THE QUOTES LIST
  Future<List<AddQuote>> getQuotes({
    int quoteId,
    bool isDetailsRequired = true,
    String strWherClause,
    int pageNo = 1,
    int pageSize = 10,
    //TO IDENTIFY IF QUOTE HEADERS/DETAILS REQUIRED OR NOT
  }) async {
    try {
      ///HERE AS PAGES START FROM 0 IN SQLITE SO DECREASING THE PAGE NO. BY 1
      ///THIS CHANGES ARE DONE TO MATCH THE EXTERNAL API CALLS PAGINATION's PAGE_NO FORMAT
      pageNo = pageNo - 1;

      ///GETTING THE RECORDS POSITIONS BY PAGE SIZE * PAGE NUMBER COUNTS
      pageNo = pageNo * pageSize;

      final db = await DBProvider.db.database;
      String _query = ''' SELECT * FROM $tableName ''';
      if (quoteId != null) {
        _query += ' WHERE Id=$quoteId ';
      } else if (strWherClause != null) {
        _query += " WHERE 1=1 " + strWherClause;
      }
      _query += ' ORDER BY CreatedDate DESC LIMIT $pageNo, $pageSize ';
      print(_query);
      var res = await db.rawQuery(_query);
      List<AddQuote> _addQuoteList =
          res.isNotEmpty ? res.map((c) => AddQuote.fromJson(c)).toList() : [];

      ///IF ONLY ADD_QUOTE'S LIST NEEDED TO DISPLAY ON UI THEN PASS isDetailsRequired
      ///ARGUMENT AS FALSE TO ABORT DETAILS AND HEADERS DATA FETCH
      if (isDetailsRequired) {
        String _quoteHeaderTableName = AddQuoteHeaderDBHelper().tableName;

        ///FETCHING QUOTE_HEADER_FIELDS
        final List<dynamic> responses = await Future.wait(
          _addQuoteList.map((AddQuote singleAddQuote) {
            List<String> _splittedQuoteHeaderIds =
                singleAddQuote.QuoteHeaderIds.split(',');

            ///STORED ALL THE QUOTE_HEADER FIELDS
            List<QuoteHeaderField> _headerFieldsList = List<QuoteHeaderField>();

            return db.rawQuery('''
          SELECT * FROM  $_quoteHeaderTableName WHERE AddQuoteID = ${singleAddQuote.Id} 
          ''').then(
              (singleQuoteRes) => {
                ///PREPARING QUOTE_FIELDS COMBINED LIST
                _headerFieldsList = singleQuoteRes.isNotEmpty
                    ? singleQuoteRes
                        .map((c) => QuoteHeaderField.fromJson(c))
                        .toList()
                    : [],

                ///SPLITTING QUOTE_HEADER_FIELDS BASED UPON THE QUOTE_HEADER_REFERENCE_ID
                ///WHICH SPLIT EARLIER
                _splittedQuoteHeaderIds.forEach((String _headerRefId) {
                  ///HOLDS FIELDS LIST WHICH CONTAINS _headerRefId ID
                  List<QuoteHeaderField> _subFieldsList =
                      List<QuoteHeaderField>();

                  ///FILTERING COMBINED HEADER_FIELDS_LIST BASED UPON _headerRefId FOR SINGLE QUOTE DETAIL
                  _headerFieldsList.forEach((singleField) {
                    if (_headerRefId == singleField.HeaderReferenceId) {
                      _subFieldsList.add(singleField);
                    }
                  });

                  ///FINALLY ADDING QUOTE_HEADER WITH QUOTE_FIELDS TO THE SINGLE_QUOTE
                  singleAddQuote.QuoteHeader.add(
                    AddQuoteHeader(
                      QuoteHeaderFields: _subFieldsList,
                      HeaderReferenceId: _headerRefId,
                      AddQuoteID: singleAddQuote.Id,
                    ),
                  );
                })
              },
            );
          }),
        );

        ///FETCHING QUOTE_DETAIL_FIELDS
        String _quoteDetailTableName = AddQuoteDetailDBHelper().tableName;
        final List<dynamic> detailResponses = await Future.wait(
          _addQuoteList.map((AddQuote singleAddQuote) {
            print(
                'singleAddQuote.QuoteDetailIds : ${singleAddQuote.QuoteDetailIds}');

            ///SPLITTING MULTIPLE QUOTE_DETAILS_REFERENCE ID's TO MAP IT TO THE QUOTE_DETAIL
            List<String> _splittedQuoteDetailsIds =
                singleAddQuote.QuoteDetailIds.split(',');

            ///STORED ALL THE FIELDS
            List<QuoteDetailField> _fieldsList = List<QuoteDetailField>();

            ///WORKING CODE BUT ONLY ONE QUOTE DETAIL FIELD IS ADDED WITH REPEATED QUOTE FIELDS
            return db.rawQuery('''
          SELECT * FROM  $_quoteDetailTableName WHERE AddQuoteID = ${singleAddQuote.Id}
          ''').then(
              (singleQuoteRes) => {
                ///PREPARING QUOTE_FIELDS COMBINED LIST
                _fieldsList = singleQuoteRes.isNotEmpty
                    ? singleQuoteRes
                        .map((c) => QuoteDetailField.fromJson(c))
                        .toList()
                    : [],

                ///SPLITTING QUOTE_DETAIL_FIELDS BASED UPON THE QUOTE_DETAIL_REFERENCE_ID
                ///WHICH SPLIT EARLIER
                _splittedQuoteDetailsIds.forEach((String _detailRefId) {
                  ///HOLDS FIELDS LIST WHICH CONTAINS _detailRefId ID
                  List<QuoteDetailField> _subFieldsList =
                      List<QuoteDetailField>();

                  ///FILTERING COMBINED DETAIL_FIELDS_LIST BASED UPON _detailRefId FOR SINGLE QUOTE DETAIL
                  _fieldsList.forEach((singleField) {
                    if (_detailRefId == singleField.DetailReferenceId) {
                      _subFieldsList.add(singleField);
                    }
                  });

                  if (_fieldsList.length > 0) {
                    ///FINALLY ADDING QUOTE_DETAIL WITH QUOTE_FIELDS TO THE SINGLE_QUOTE
                    singleAddQuote.QuoteDetail.add(
                      AddQuoteDetail(
                        QuoteDetailFields: _subFieldsList,
                        DetailReferenceId: _detailRefId,
                        AddQuoteID: singleAddQuote.Id,
                      ),
                    );
                  }
                })
              },
            );
          }),
        );
      } else {
        print('Quote Details and Headers data not fetched ');
      }
      return _addQuoteList;
    } catch (e) {
      print('Error Inside AddQuoteDBHelper getAllQuotes Fn  ');
      print(e);
      return Future.error(e);
    }
  }

  Future<int> getOfflineQuoteCount(String strWhereClause) async {
    try {
      final db = await DBProvider.db.database;
      String _query =
          'SELECT COUNT(*)  FROM $tableName where 1=1 $strWhereClause  ';
      print('getQuoteCount Query : $_query');
      var res = await db.rawQuery(_query);
      final Count = Sqflite.firstIntValue(res);
      print('getOfflineQuoteCount $Count');
      return Count;
    } catch (e) {
      print('Error Inside getOfflineQuoteCount FN ');
      print(e);
      return Future.error(e);
    }
  }

  Future<AddQuote> addSingleQuote({
    int isLocalQuote,
    String serverUpdatedDate,
    int serverQuoteId,
  }) async {
    try {
      print('Inside addSingleQuote Fn');
      final db = await DBProvider.db.database;
      String _emptyString = '';
      DateTime _date = DateTime.now();
      String _serverUpdatedDate =
          serverUpdatedDate != null ? '"$serverUpdatedDate"' : null;
      String _insertQuery = ''' 
          INSERT INTO $tableName ( Active, QuoteHeaderIds, QuoteDetailIds, CreatedDate, UpdatedDate, isLocalQuote, ServerUpdatedDate, serverQuoteId ) 
          VALUES ( 1, "$_emptyString" , "$_emptyString" , "$_date", "$_date" , $isLocalQuote, $_serverUpdatedDate, $serverQuoteId )
      ''';
      var _addQuoteRes = await db.rawInsert(_insertQuery);
      print('QuoteAdd Response ');
      print(_addQuoteRes);

      var _queryRes = await db
          .rawQuery('SELECT * FROM $tableName WHERE Id = $_addQuoteRes');
      List<AddQuote> _tempAddQuoteList = _queryRes.isNotEmpty
          ? _queryRes.map((c) => AddQuote.fromJson(c)).toList()
          : [];
      print('_tempAddQuoteList $_tempAddQuoteList');
      if (_tempAddQuoteList.length > 0) {
        ///CREATED ENTRY FOUND SENDING BACK SINGLE RESPONSE
        return Future.value(_tempAddQuoteList[0]);
      } else {
        print(
            'Did not found Created Record SO deleting the createdRecord if present ');
        var _deleteRes = await deleteRowById(addQuoteId: _addQuoteRes);
        print('Single Record Delete Res $_deleteRes');
        return Future.error(ErrorDescription('Created Entry Not Found'));
      }
    } catch (e) {
      print('Error inside AddQuoteDBHelper addSingleQuote Fn');
      print(e);
      return Future.error(e);
    }
  }

  ///IT UPDATES THE PROVIDED FIELD_NAME VALUE WITH UPDATED FIELD VALUE PROVIDED
  Future updateFieldById({
    int quoteId,
    String fieldName,
    String stringFieldValue,
    int intFieldValue,
  }) async {
    try {
      print('Inside updateFieldById Fn');
      final db = await DBProvider.db.database;
      String _updateQuery = '''UPDATE $tableName SET $fieldName= ''';
      if (stringFieldValue != null) {
        _updateQuery += '"$stringFieldValue"';
      } else if (intFieldValue != null) {
        _updateQuery += '$intFieldValue';
      } else {
        return Future.error(ErrorDescription(
            'Provide the valid update value for the Update Query'));
      }
      _updateQuery += ' WHERE Id=$quoteId ';

      print('===========Update Query===========\n : $_updateQuery ');
      var updateRes = await db.rawUpdate(_updateQuery);
      return Future.value(updateRes);
    } catch (e) {
      print('Error Inside updateFieldById Fn of AddQuoteDBHelper ');
      print(e);
      return Future.error(e);
    }
  }

  ///IT FETCHES THE SINGLE QUOTE BY SERVER_QUOTE_ID
  Future<List<AddQuote>> fetchQuoteByServerQuoteId({
    int serverQuoteId,
  }) async {
    try {
      AddQuote _addQuote = AddQuote();
      final db = await DBProvider.db.database;
      String _query =
          ''' SELECT * FROM $tableName WHERE ServerQuoteId=$serverQuoteId''';
      print('Quotes By ServerQuoteId: $_query');
      var res = await db.rawQuery(_query);
      List<AddQuote> _quoteList =
          res.isNotEmpty ? res.map((c) => AddQuote.fromJson(c)).toList() : [];
      return Future.value(_quoteList);
    } catch (e) {
      print('Error Inside fetchQuoteByServerQuoteId: ');
      print(e);

      return Future.error(e);
    }
  }

  ///IT DELETES SINGLE QUOTE ROW FROM THE LOCAL_DATABASE BY ID
  Future deleteRowById({
    int addQuoteId,
  }) async {
    try {
      final db = await DBProvider.db.database;
      final deleteRes =
          await db.rawDelete('DELETE FROM $tableName WHERE Id = $addQuoteId ');
      print('deleteAddQuote By ID Res');
      print(deleteRes);
      return deleteRes;
    } catch (e) {
      print('Error inside deleteALLRows FN in AddQuoteDBHelper');
      print(e);
      throw Future.error(e);
    }
  }

  ///IT DELETES ALL THE ROWS FROM THE LOCAL_DATABASE
  Future deleteALLRows() async {
    try {
      final db = await DBProvider.db.database;
      final deleteRes = await db.delete(tableName);
      print('deleteAddQuotes Res');
      print(deleteRes);
      return deleteRes;
    } catch (e) {
      print('Error inside deleteALLRows FN in AddQuoteDBHelper');
      print(e);
      throw Future.error(e);
    }
  }

  Future<int> getAddQuoteCount() async {
    try {
      final db = await DBProvider.db.database;
      int count = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM $tableName'));
      print('getAddQuoteCount Res');
      print(count);
      return count;
    } catch (e) {
      print('Error inside getAddQuoteCount FN in AddQuoteDBHelper');
      print(e);
      return 0;
    }
  }
}
