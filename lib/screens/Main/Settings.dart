import 'dart:async';

import 'package:flutter/material.dart';
import 'package:moblesales/helpers/index.dart';
import 'package:moblesales/models/index.dart';
import 'package:moblesales/screens/index.dart';
import 'package:moblesales/utils/index.dart';
//import 'package:flutter/services.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  ///HOLDS ALL THE SYNC_MASTERS LIST FOR SHOWING ON UI
  List<SyncMaster> _syncMasters;

  SyncMasterDBHelper _syncMasterDBHelper;
  bool isOffline = false;

  ///HOLDS THE CLASS OBJECT WHICH CONTAINS THE REUSABLE WIDGETS
  CommonWidgets _commonWidgets;

  ///NETWORK_CONNECTION STREAM SUBSCRIPTION TO GET UPDATES WHEN APP IS ONLINE OR OFFLINE
  StreamSubscription _connectionChangeStream;

  @override
  void initState() {
    super.initState();
    _syncMasters = List<SyncMaster>();
    _syncMasterDBHelper = SyncMasterDBHelper();

    ConnectivityService connectionStatus = ConnectivityService.getInstance();
    _connectionChangeStream =
        connectionStatus.connectionChange.listen(connectionChanged);

    printUserName();
    fetchSyncMastersData();
  }

  void connectionChanged(dynamic hasConnection) {
    setState(() {
      isOffline = !hasConnection;
    });
    if (isOffline == true) {
      _commonWidgets.showFlutterToast(
          toastMsg: ConnectionStatus.NetworkNotAvailble);
    } else {
      _commonWidgets.showFlutterToast(
          toastMsg: ConnectionStatus.NewtworkRestored);
    }
    ConnectionStatus.isOffline = isOffline;
  }

  Future<void> printUserName() async {
    String uname = await Session.getUserName();
    print('Uname $uname');
  }

  void fetchSyncMastersData() {
    print("arr len: ${_syncMasters.length}");
    setState(() {
      _syncMasters.clear();
      print("arr len: ${_syncMasters.length}");
    });
    _syncMasterDBHelper
        .getAllSyncMasters()
        .then((syncMastersRes) => {
              if (syncMastersRes.length > 0)
                {
                  ApiService.getAutoSaveQuoteInterval().then((value) {
                    print("getAutoSaveQuoteInterval");
                    print(value);
                    syncMastersRes.add(SyncMaster(
                        Id: (syncMastersRes.last.Id++),
                        TableName: "Auto Save Interval",
                        LastSyncDate: value.toString()));
                    for (var i = 0; i < syncMastersRes.length; i++) {
                      print(
                          "response sync master: ${syncMastersRes[i].LastSyncDate}");
                      print(
                          "response sync master: ${syncMastersRes[i].TableName}");
                    }
                    ;
                    this.setState(() {
                      _syncMasters.addAll(syncMastersRes);
                      print("arr len: ${_syncMasters.length}");
                    });
                  }),
                }
            })
        .catchError((e) => {
              print("Error while SyncMaster Data from local DB"),
              print(e),
            });
  }

  Widget _buildRow(SyncMaster item) {
    print("Inside Settings._buildRow");
    String strDate = '';
    if (item.LastSyncDate.toString() != '' && item.LastSyncDate.toString() != null) {
      print(item.TableName);
      if (item.TableName.toString().toLowerCase().replaceAll(" ", "") =="autosaveinterval") {
        item.TableName += "(in Seconds)";
        strDate = item.LastSyncDate.toString();
      } else {
        try{
          strDate = Other().DisplayDateTime(DateTime.parse(item.LastSyncDate.toString()).toString());
        }
        catch(e){
          strDate = item.LastSyncDate.toString();
        }
      }
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
          flex: 2,
          child: Text(
            item.TableName == 'Company' ? 'Customer' : item.TableName,
            textAlign: TextAlign.start,
            style: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 14,
                color: AppColors.grey),
          ),
        ),
        Expanded(
          child: Text(
            strDate,
            textAlign: TextAlign.end,
            style: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 14,
                color: AppColors.black),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              onPressed: () {
                isOffline == false
                    ? backgroundedLookupInsertUpdateHandler()
                    : _commonWidgets.showFlutterToast(
                        toastMsg: ConnectionStatus.NetworkNotAvailble);
              },
              child: Text(
                'Sync Lookups data',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                ),
              ),
              color: AppColors.blue,
            ),
            RaisedButton(
              onPressed: () {
                fetchSyncMastersData();
              },
              child: Text(
                'Check Status',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                ),
              ),
              color: AppColors.blue,
            ),
            SizedBox(
              height: 10.0,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _syncMasters.length,
                itemBuilder: (context, index) {
                  return _buildRow(_syncMasters[index]);
                },
              ),
            )
          ],
        ),
      ),
    ));
  }
}
