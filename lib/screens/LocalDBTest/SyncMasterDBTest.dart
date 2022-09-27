import 'package:flutter/material.dart';
import 'package:moblesales/helpers/index.dart';
import 'package:moblesales/models/index.dart';
import 'package:moblesales/utils/index.dart';
import 'package:true_time/true_time.dart';

///HOLDS THE KEY TO IDENTIFY TRUE_TIME_PACKAGE ERROR
const lastSyncDateErrorCode = "TRUE_TIME_ERROR";

class SyncMasterDBTestScreen extends StatefulWidget {
  @override
  _SyncMasterDBTestScreenState createState() => _SyncMasterDBTestScreenState();
}

class _SyncMasterDBTestScreenState extends State<SyncMasterDBTestScreen> {
  ///HOLDS ALL THE SYNC_MASTERS LIST FOR SHOWING ON UI
  List<SyncMaster> _syncMasters;

  CommonDBHelper _commonDBHelper;

  SyncMasterDBHelper _syncMasterDBHelper;

  SalesSiteDBHelper _salesSiteDBHelper;

  void initState() {
    super.initState();
    _syncMasters = List<SyncMaster>();
    _syncMasterDBHelper = SyncMasterDBHelper();
    _commonDBHelper = CommonDBHelper();
    _salesSiteDBHelper = SalesSiteDBHelper();
    fetchSyncMastersData();
  }

  void resetLocalDBData() async {
    try {
      _commonDBHelper
          .deleteAllTablesData()
          .then((value) => {
                print('deleteAllTablesData Success Response '),
                print(value),
              })
          .catchError((e) => {
                print('deleteAllTablesData Catch Error Response '),
                print(e),
              });
    } catch (e) {
      print('Error Inside resetLocalDBData Fn ');
      print(e);
    }
  }

  void getCurrentDateTimeFn() async {
    ApiService.getCurrentDateTime()
        .then((value) => {
              print('Inside getCurrentDateTimeFn FN Success response $value'),
            })
        .catchError((e) => {
              print('Inside getCurrentDateTimeFn FN Error response $e'),
            });
  }

  ///IT FETCHES THE SYNC_MASTERS DATA
  void fetchSyncMastersData() {
    this.setState(() {
      _syncMasters = [];
    });
    _syncMasterDBHelper
        .getAllSyncMasters()
        .then((syncMastersRes) => {
              if (syncMastersRes.length > 0)
                {
                  this.setState(() {
                    _syncMasters.addAll(syncMastersRes);
                  }),
                }
            })
        .catchError((e) => {
              print("Error while SyncMaster Data from local DB"),
              print(e),
            });
  }

  void updateProductLastDate() async {
    try {
      String _lastSyncDateForSave = await getLastSyncDateForSave();
      if (_lastSyncDateForSave != lastSyncDateErrorCode) {
        var updateRes =
            await _syncMasterDBHelper.updateMasterTableLastSyncDateByName(
          masterTableName: ProductDBHelper().tableName,
          lastSyncDate: _lastSyncDateForSave,
        );
        print('Product Last Sync Date Update Res');
        print(updateRes);
        fetchSyncMastersData();
      } else {
        print('Valid LastSyncDate NOT FOUND FOR UPDATION');
      }
    } catch (e) {
      print('Error inside updateCompanyLastDate Fn ');
      print(e);
    }
  }

  void updateCompanyLastDate() async {
    try {
      String _lastSyncDateForSave = await getLastSyncDateForSave();
      if (_lastSyncDateForSave != lastSyncDateErrorCode) {
        var updateRes =
            await _syncMasterDBHelper.updateMasterTableLastSyncDateByName(
          masterTableName: CompanyDBHelper().tableName,
          lastSyncDate: _lastSyncDateForSave,
        );
        print('Company Last Sync Date Update Res');
        print(updateRes);
        fetchSyncMastersData();
      } else {
        print('Valid LastSyncDate NOT FOUND FOR UPDATION');
      }
    } catch (e) {
      print('Error inside updateCompanyLastDate Fn ');
      print(e);
    }
  }

  void resetProductLastSyncDate() async {
    try {
      var updateRes =
          await _syncMasterDBHelper.updateMasterTableLastSyncDateByName(
        masterTableName: ProductDBHelper().tableName,
        lastSyncDate: '',
      );
      print('Product Last Sync Date Reset Res');
      print(updateRes);
      fetchSyncMastersData();
    } catch (e) {
      print('Error Inside resetProductLastSyncDate Fn ');
      print(e);
    }
  }

  void resetCompanyLastSyncDate() async {
    try {
      var updateRes =
          await _syncMasterDBHelper.updateMasterTableLastSyncDateByName(
        masterTableName: CompanyDBHelper().tableName,
        lastSyncDate: '',
      );
      print('Company Last Sync Date Reset Res');
      print(updateRes);
      fetchSyncMastersData();
    } catch (e) {
      print('Error Inside resetProductLastSyncDate Fn ');
      print(e);
    }
  }

  void resetSalesSiteLastSyncDate() async {
    try {
      var updateRes =
          await _syncMasterDBHelper.updateMasterTableLastSyncDateByName(
        masterTableName: _salesSiteDBHelper.tableName,
        lastSyncDate: '',
      );
      print('SalesSite Last Sync Date Reset Res');
      print(updateRes);
      fetchSyncMastersData();
    } catch (e) {
      print('Error Inside resetSalesSiteLastSyncDate Fn ');
      print(e);
    }
  }

  ///IT RETURNS THE API STANDARD FORMATTED UTC_LAST_SYNC_DATE
  Future<String> getLastSyncDateForSave() async {
    try {
      bool _trueTimeInitialized =
          await TrueTime.init(ntpServer: 'time.google.com');
      String _lastSyncDateUTC = '';
      if (_trueTimeInitialized) {
        print(
            'TrueTime.now Initialized preparing UTC Date for lastSyncDate value');
        DateTime now = await TrueTime.now();
        DateTime _utcDate = DateTime.utc(now.year, now.month, now.day, now.hour,
            now.minute, now.millisecond);
        _lastSyncDateUTC =
            '${_utcDate.year}-${getFormatDateString(value: _utcDate.month)}-${getFormatDateString(value: _utcDate.day)} ${getFormatDateString(value: _utcDate.hour)}:${getFormatDateString(value: _utcDate.minute)}:${getFormatDateString(value: _utcDate.second)}';
        print('LastSyncDate API Standard UTC FORMAT :$_lastSyncDateUTC');
        return Future.value('$_lastSyncDateUTC');
      } else {
        print('True Time not initialized!');
        return Future.value(lastSyncDateErrorCode);
      }
    } catch (e) {
      print('Error Inside getLastSyncDateForSave Fn ');
      print(e);
      return Future.value(lastSyncDateErrorCode);
    }
  }

  ///IT ADDS THE 0 TO THE VALUE IF IT's LESS THAN 10 TO MAINTAIN PROPER DATE VALUES
  String getFormatDateString({int value}) {
    String _tempVal = '';
    if (value != null && value.toString().length > 0) {
      _tempVal = value < 10 ? '0' + (value).toString() : value.toString();
    }
    return _tempVal;
  }

  ///HANDLES ALL THE RAISED BUTTONS FOR ON_PRESSED FUNCTIONS AND LABELS_TEXT
  Widget getRaisedButton({
    String label,
    Function onPressedFn,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: RaisedButton(
          onPressed: () {
            onPressedFn();
          },
          child: Text('$label'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SyncMaster DB Test Screen'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                  child: Center(
                      child: Padding(
                padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                child: Text(
                  'SYNC MASTER CRUD',
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                ),
              ))),
            ],
          ),
          Row(
            children: <Widget>[
              Expanded(
                  child: Center(
                      child: Padding(
                padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                child: Text(
                  'Total Sync Masters DATA : ${_syncMasters.length}',
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                ),
              ))),
            ],
          ),
          Row(
            children: <Widget>[
              getRaisedButton(
                label: 'Fetch SyncMasters Local DB Data',
                onPressedFn: fetchSyncMastersData,
              ),
            ],
          ),
          Row(
            children: <Widget>[
              getRaisedButton(
                label: 'Update Product LastSyncDate',
                onPressedFn: updateProductLastDate,
              ),
              getRaisedButton(
                label: 'Update Company LastSyncDate',
                onPressedFn: updateCompanyLastDate,
              ),
            ],
          ),
          Row(
            children: <Widget>[
              getRaisedButton(
                label: 'Reset Product LastSyncDate',
                onPressedFn: resetProductLastSyncDate,
              ),
              getRaisedButton(
                label: 'Reset Company LastSyncDate',
                onPressedFn: resetCompanyLastSyncDate,
              ),
            ],
          ),
          Row(
            children: <Widget>[
              getRaisedButton(
                label: 'Reset SalesSite LastSyncDate',
                onPressedFn: resetSalesSiteLastSyncDate,
              ),
              getRaisedButton(
                label: 'Reset LocalDatabase Data',
                onPressedFn: resetLocalDBData,
              ),
            ],
          ),
          Row(
            children: <Widget>[
              getRaisedButton(
                label: 'get current date time',
                onPressedFn: getCurrentDateTimeFn,
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _syncMasters.length,
              itemBuilder: (context, position) {
                return Column(
                  children: <Widget>[
                    Divider(
                      color: Colors.teal,
                      thickness: 2.0,
                    ),
                    Text('ID: ${_syncMasters[position].Id}'),
                    Text('TableName: ${_syncMasters[position].TableName}'),
                    Text(
                        'LastSyncDate: ${_syncMasters[position].LastSyncDate}'),
                    Divider(
                      color: Colors.teal,
                      thickness: 2.0,
                    ),
                  ],
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
