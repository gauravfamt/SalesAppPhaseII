import 'package:moblesales/models/index.dart';
import 'package:moblesales/utils/index.dart';

class SyncMasterDBHelper {
  ///IT HOLDS THE TABLE CREATE QUERY
  final String tableName = 'SyncMaster';

  ///RETURNS THE CREATE TABLE QUERY FOR THE SyncMaster
  ///ANY NEW FIELDS ADD, UPDATE OR DELETE IN LOCAL DATABASE MUST BE DONE HERE
  String getTableCreateQuery() {
    return '''
          CREATE TABLE IF NOT EXISTS $tableName(
                    Id INTEGER PRIMARY KEY,
                    TableName TEXT,
                    LastSyncDate TEXT
          )
          ''';
  }

  // ///RETURNS THE CREATE TABLE QUERY FOR THE SyncMaster
  // ///ANY NEW FIELDS ADD, UPDATE OR DELETE IN LOCAL DATABASE MUST BE DONE HERE
  // String getTableAlterQueryVer2() {
  //   return '''
  //         CREATE TABLE IF NOT EXISTS $tableName(
  //                   Id INTEGER PRIMARY KEY,
  //                   TableName TEXT,
  //                   LastSyncDate TEXT
  //         )
  //         ''';
  // }

  ///IT INSERTS THE DEFAULT TABLE ENTRIES IN THE SYNC_MASTER TABLE
  Future<String> getSyncMasterEntriesInsertQuery() async {
    ///IT HOLDS THE SYNC_MASTER_TABLE INSERT QUERIES
    String _insertQuerySMD = '';
    try {
      final db = await DBProvider.db.database;
      ///GETS THE DEFAULT ENTRIES AFTER THE TABLE IS CREATED
      List<SyncMaster> _syncMasterData = getDefaultSyncMasterData();
      print('_syncMasterData ${_syncMasterData.length}');
      ///HOLDS THE INSERT QUERY'S MULTIPLE VALUES
      String _tempQueryValues = '';
      ///HOLDS THE MAIN INSERT QUERY
      String _tempInsertQuery = '';
      ///ITERATING THROUGH EACH DEFAULT ENTRY TO PREPARE INSERT QUERY'S FINAL VALUES STRING
      _syncMasterData.forEach((singleSyncMasterEntry) {
        _tempQueryValues += '''(
         ${singleSyncMasterEntry.Id}, "${singleSyncMasterEntry.TableName}","${singleSyncMasterEntry.LastSyncDate}"   
         ) , ''';
      });

      if (_tempQueryValues.length > 0) {
        _tempQueryValues = _tempQueryValues.substring(
            0, _tempQueryValues.lastIndexOf(',') - 1);

        _tempInsertQuery = ''' 
          INSERT OR REPLACE INTO $tableName ( Id, TableName, LastSyncDate ) 
                VALUES $_tempQueryValues  
          ''';
        _insertQuerySMD = _tempInsertQuery;
      }
      await db.execute(_tempInsertQuery);
      return "";
    } catch (e) {
      print('Error while inserting the Entries to the SyncMaster Table');
      print(e);
      return _insertQuerySMD;
    }
  }

  ///HERE ADD THE INITIAL ENTRIES TO THE SYNC_MASTER TABLE
  List<SyncMaster> getDefaultSyncMasterData() {
    List<SyncMaster> _tempSMD = [
      SyncMaster(
        TableName: CompanyDBHelper().tableName,
        LastSyncDate: '',
        Id: 1,
      ),
      SyncMaster(
        TableName: ProductDBHelper().tableName,
        LastSyncDate: '',
        Id: 2,
      ),
      SyncMaster(
        TableName: InvoicingElementDBHelper().tableName,
        LastSyncDate: '',
        Id: 3,
      ),

//      SyncMaster(
//        TableName: SalesSiteDBHelper().tableName,
//        LastSyncDate: '',
//        Id: 3,
//      ),
    ];

    return _tempSMD;
  }

  ///IT RETURNS THE SYNC_MASTER TABLE ALL ENTRIES
  Future<List<SyncMaster>> getAllSyncMasters() async {
    final db = await DBProvider.db.database;
    var res = await db.query('$tableName');
    List<SyncMaster> list =
        res.isNotEmpty ? res.map((c) => SyncMaster.fromJson(c)).toList() : [];
    return list;
  }

  ///IT UPDATES THE LAST_SYNC_DATE OF THE PROVIDED TABLE_NAME ENTRY IN SYNC_MASTER TABLE
  Future updateMasterTableLastSyncDateByName({
    String masterTableName,
    String lastSyncDate,
  }) async {
    try {
      final db = await DBProvider.db.database;
      var res = await db.rawUpdate('''
      UPDATE $tableName SET LastSyncDate="$lastSyncDate" WHERE TableName="$masterTableName"     
      ''');
      return Future.value(res);
    } catch (e) {
      print('Error Inside updateLocalMasterTableByName Fn ');
      print(e);
      return Future.value("Error");
    }
  }

  ///IT RESETS THE LAST_SYNC_DATE OF ALL THE ENTRIES IN SYNC_MASTER TABLE
  Future resetAllMastersTableLastSyncDate({
    String lastSyncDate,
  }) async {
    try {
      final db = await DBProvider.db.database;
      var res = await db.rawUpdate('''
      UPDATE $tableName SET LastSyncDate="$lastSyncDate"     
      ''');
      return Future.value(res);
    } catch (e) {
      print('Error Inside resetAllMastersTableLastSyncDate Fn ');
      print(e);
      return Future.value("Error");
    }
  }
}
