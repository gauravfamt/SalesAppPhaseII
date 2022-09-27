import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:moblesales/helpers/index.dart';
import 'package:moblesales/models/index.dart';
import 'package:moblesales/screens/index.dart';

import 'package:package_info/package_info.dart';
import 'package:store_redirect/store_redirect.dart';

class NotificationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final platform = Theme.of(context).platform;
    return (MaterialApp(
      debugShowCheckedModeBanner: false,
      home: NotificationScreenPage(
        parentBuildContext: context,
        platform: platform,
      ),
    ));
  }
}

class NotificationScreenPage extends StatefulWidget {
  final BuildContext parentBuildContext;
  final TargetPlatform platform;

  NotificationScreenPage({
    Key key,
    @required this.parentBuildContext,
    this.platform,
  }) : super(key: key);

  @override
  _NotificationScreenPageState createState() => _NotificationScreenPageState();
}

class _NotificationScreenPageState extends State<NotificationScreenPage> {
  ///HOLDS COMMON_WIDGETS OBJECT WHICH CONTAINS REUSABLE WIDGETS
  CommonWidgets _commonWidgets;

  ///USED TO HANDLE THE FULLSCREEN_LOADER JUST SET THE STATE TO THE TRUE TO START
  bool isFullScreenLoading;

  ///HOLDS ALL THE NOTIFICATIONS DATA
  List<NotificationPOJO> notificationData;

  ///NETWORK_CONNECTION STREAM SUBSCRIPTION TO GET UPDATES WHEN APP IS ONLINE OR OFFLINE
  StreamSubscription _connectionChangeStream;

  ///HOLDS APP ONLINE/OFFLINE STATUS
  bool isOffline = false;

  PackageInfo _packageInfo;

  String latestAppVersion;
  String currentAppVersion;
  bool isDetailsRequired;

  @override
  void initState() {
    super.initState();
    isFullScreenLoading = false;
    notificationData = List<NotificationPOJO>();
    _commonWidgets = CommonWidgets();
    _packageInfo = PackageInfo();
    ConnectivityService connectionStatus = ConnectivityService.getInstance();
    _connectionChangeStream =
        connectionStatus.connectionChange.listen(connectionChanged);

    _initPackageInfo();
  }

  ///SETS THE CONNECTION STATUS DEPENDING ON THE CONNECTION_SERVICE SUBSCRIPTION LISTEN EVENTS
  void connectionChanged(dynamic hasConnection) {
    setState(() {
      isOffline = !hasConnection;
    });
  }

  Future<void> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
      currentAppVersion = _packageInfo.version;
    });
    insertAppUpdateNotification();
    print('App Version ${_packageInfo.version}');
  }

  Future<void> insertAppUpdateNotification() async {
    try {
      print('insertAppUpdateNotification');
      ApiService.getAppInfo()
          .then((value) => {
                if (!value.toString().contains('Error'))
                  {
                    setState(() {
                      if (value.length > 0) {
                        for (int i = 0; i < value.length; i++) {
                          print('${value[i].App}');
                          if (value[i].App == 'Andriod' &&
                              widget.platform == TargetPlatform.android) {
                            setState(() {
                              latestAppVersion = value[i].Version;
                            });
                          } else if (value[i].App == 'IOS' &&
                              widget.platform == TargetPlatform.iOS) {
                            setState(() {
                              latestAppVersion = value[i].Version;
                            });
                          }
                        }

                        if (latestAppVersion != '' && currentAppVersion != '') {
                          print('currentAppVersion: $currentAppVersion');
                          print('latestAppVersion: $latestAppVersion');
                          int intResult = versionCompare(
                              currentAppVersion, latestAppVersion);

//                          if (intResult == 2) // New Update Avilable
//                          {
//                            //Add Notification
//                            setState(() {
//                              notificationData.insert(
//                                  0,
//                                  NotificationPOJO(
//                                    notificationType:
//                                        '${NotificationType.APP_UPDATE}',
//                                    message: NotificationMessages.APP_UPDATE,
//                                  ));
//                            });
//                          }
                        }
                      }
                    }),
                  }
              })
          .catchError((e) => {
                print('Inventory  Error Response $e'),
              });
    } catch (e) {
      print('Error inside prepareInventoryData Response ');
      print(e);
    }
  }

  int versionCompare(String v1, String v2) {
    // vnum stores each numeric
    // part of version
    int vnum1 = 0;
    int vnum2 = 0;
    // loop untill both string are
    // processed
    for (int i = 0, j = 0; (i < v1.length || j < v2.length);) {
      // storing numeric part of
      // version 1 in vnum1
      while (i < v1.length && v1[i] != '.') {
        vnum1 = vnum1 * 10 + int.parse((v1[i].toString() + '0'));
        i++;
      }

      // storing numeric part of
      // version 2 in vnum2
      while (j < v2.length && v2[j] != '.') {
        vnum2 = vnum2 * 10 + int.parse((v2[j].toString() + '0'));
        j++;
      }

      if (vnum1 > vnum2) {
        print('Large vnum1');
        return 1;
      }

      if (vnum2 > vnum1) {
        print('Large vnum2');
        return 2;
      }

      // if equal, reset variables and
      // go for next numeric part
      vnum1 = vnum2 = 0;
      i++;
      j++;
    }
    return 0;
  }

  void handlePlayStoreRedirection() {
    StoreRedirect.redirect(
        androidAppId: Other().ANDROID_APP_ID, iOSAppId: Other().APPLE_APP_ID);
  }

  Widget _buildList() {
    return notificationData.length > 0
        ? ListView.builder(
            itemCount: notificationData.length,
            padding: const EdgeInsets.all(15.0),
            itemBuilder: (context, position) {
              return GestureDetector(
                onTap: () {
                  if (notificationData[position].notificationType ==
                      '${NotificationType.APP_UPDATE}') {
                    handlePlayStoreRedirection();
                  }
                },
                child: Card(
                  child: Container(
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        _buildRow(
                            "Message", notificationData[position].message),
                        SizedBox(
                          height: 10.0,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            })
        : Text(
            NotificationMessages.EMPTY_NOTIFICATIONS,
            style: TextStyle(color: AppColors.grey, fontSize: 19.0),
          );
  }

  Widget _buildRow(String key, String val) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Expanded(
          flex: 1,
          child: Container(
            child: Text('$key'),
            alignment: Alignment.centerLeft,
          ),
        ),
        Expanded(
          flex: 3,
          child: Container(
            child: Text('$val'),
            alignment: Alignment.centerLeft,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isFullScreenLoading,
      opacity: 0.5,
      // progressIndicator: CircularProgressIndicator(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppBarTitles.NOTIFICATIONS),
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(widget.parentBuildContext);
              }),
        ),
        body: Container(
            width: double.infinity,
            height: double.infinity,
            alignment: Alignment.center,
            child: _buildList()),
      ),
    );
  }
}
