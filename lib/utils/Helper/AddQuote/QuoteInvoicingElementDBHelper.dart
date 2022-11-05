import 'package:moblesales/helpers/index.dart';
import 'package:moblesales/models/index.dart';
import 'package:moblesales/models/quoteInvoicingElement.dart';
import 'package:moblesales/utils/index.dart';

class QuoteInvoicingElementDBHelper {
  ///IT HOLDS THE TABLE CREATE QUERY
  final String tableName = 'QuoteInvoicingElement';
  final String oldTableName='SalesInvoicingElements';
  String getTableCreateQuery() {
   // deleteOldTable();
    return '''
          CREATE TABLE IF NOT EXISTS $tableName(
          Id INTEGER PRIMARY KEY AUTOINCREMENT,
          QuoteHeaderId  INTEGER ,
          InvoicingElementCode INTEGER ,
          InvoicingElementValue REAL,
          CreatedBy TEXT,
          UpdatedBy TEXT,
          CreatedDate TEXT,
          UpdatedDate TEXT
          )
          ''';
  }

  /// IT INSERTS MULTIPLE COMPANIES DATA TO THE LOCAL_DB
  Future AddQuoteInvoicingElement(List<QuoteInvoicingElement> quoteInvoivingElement) async {
    try {
      print('AddQuoteInvoicingElement====');
      final db = await DBProvider.db.database;
      await deleteQuoteInvoicingElementByQuoteHeaderId(QuoteHeaderId:quoteInvoivingElement[0].QuoteHeaderId );
      print('Inside AddQuoteInvoicingElement!');
      String values = "";
      for (var i = 0; i < quoteInvoivingElement.length; i++) {
        QuoteInvoicingElement single = quoteInvoivingElement[i];
        double invoicingElemetValue =single.InvoicingElementValue != null && single.InvoicingElementValue !=""
            ? single.InvoicingElementValue
            : 0;

        values +=
        '''(  ${single.QuoteHeaderId}, ${single.InvoicingElementCode}, ${invoicingElemetValue}, "${single.CreatedBy}", "${single.UpdatedBy}", "${single.CreatedDate}", "${single.UpdatedDate}")  , ''';
      }
      values = values.substring(0, values.lastIndexOf(',') - 1);
      var res = await db.rawInsert('''
    INSERT OR REPLACE INTO $tableName ( QuoteHeaderId, InvoicingElementCode, InvoicingElementValue, CreatedBy, UpdatedBy, CreatedDate, UpdatedDate )
          VALUES $values
    ''');
      //print('QuoteInvoicingElement Addedd');
      return res;
    } catch (e) {
      //print('Error inside AddQuoteInvoicingElement in QuoteInvoicingElementDBHelper');
      //print(e);
      throw Future.error(e);
    }
  }

  ///IT RETURNS THE SINGLE COMPANY OBJECT FROM CUSTOMER_NO PROVIDED
  Future <List<QuoteInvoicingElement>> getInvoicingElementByQuoteHederNo({
    int QuoteHeaderId,
  }) async {
    try {
      List<QuoteInvoicingElement> _invoiceElement = List<QuoteInvoicingElement>();
      final db = await DBProvider.db.database;
      String _query = 'SELECT * FROM $tableName WHERE QuoteHeaderId = ${QuoteHeaderId}';
      //print('_query');
      //print(_query);
      var res = await db.rawQuery(_query);
      List<QuoteInvoicingElement> _list =
      res.isNotEmpty ? res.map((c) => QuoteInvoicingElement.fromJson(c)).toList() : [];
      _invoiceElement.addAll(_list);
      return _invoiceElement;
    } catch (e) {
      //print('Error Inside getInvoicingElementByQuoteHederNo() FN in QuoteInvoicingElementDBHelper ');
      //print(e);
      return Future.error(e);
    }
  }
  ///IT DELETES ALL THE ROWS FROM THE LOCAL_DATABASE
  Future deleteALLRows() async {
    try {
      final db = await DBProvider.db.database;
      final deleteRes = await db.delete(tableName);
      //print('deleteCompanies Res');
      //print(deleteRes);
      return deleteRes;
    } catch (e) {
      //print('Error inside deleteALLRows FN');
      //print(e);
      throw Future.error(e);
    }
  }

  Future deleteQuoteInvoicingElementByQuoteHeaderId({
    int QuoteHeaderId,
  }) async {
    try {
      print('Inside deleteQuoteInvoicingElementByQuoteHeaderId!');
      final db = await DBProvider.db.database;
      final deleteRes = await db.rawDelete('DELETE FROM $tableName WHERE QuoteHeaderId = $QuoteHeaderId ');
      print(' deleteQuoteInvoicingElementByQuoteHeaderId  Res');
      print(deleteRes);
      return deleteRes;
    } catch (e) {
      //print('Error inside deleteQuoteInvoicingElementByQuoteHeaderId FN in QuoteInvoicingElementDBHelper');
      //print(e);
      throw Future.error(e);
    }
  }


  Future deleteOldTable() async {
    try {
      final db = await DBProvider.db.database;
      final deleteRes = await db.delete(oldTableName);
      print('deleteSalesSites Res');
      print(deleteRes);
      return deleteRes;
    } catch (e) {
      print('Error inside deleteOldTable');
      print(e);
      throw Future.error(e);
    }
  }
}
