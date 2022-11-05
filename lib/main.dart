import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:moblesales/helpers/index.dart';
import 'package:moblesales/models/index.dart';
import 'package:moblesales/screens/index.dart';
import 'package:moblesales/utils/index.dart';
import 'package:shared_preferences/shared_preferences.dart';

///HOLDS TOKEN VALUE
String _tokenValue = '';

String _userNameValue = '';

String _apiDomainValue = '';

///PROVIDES SYNC_MASTER TABLE CRUD OPERATIONS
SyncMasterDBHelper _syncMasterDBHelper = SyncMasterDBHelper();

///PROVIDES TOKEN_MASTER TABLE CRUD OPERATIONS
TokenDBHelper _tokenDBHelper = TokenDBHelper();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(debug: true);

  ///INITIALIZING CONNECTION_SERVICE ONLY ONCE
  ///AND CAN BE USED IN ALL SCREENS JUST BY GETTING CONNECTION_SERVICE INSTANCE AND
  ///SUBSCRIBING TO THE CONNECTION CHANGE
  ConnectivityService connectionStatus = ConnectivityService.getInstance();
  connectionStatus.initialize();
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: await Session.getData(Session.accessToken) == null
          ? Login()
          : MyAPP(),
    ),
  );
}

class MyAPP extends StatefulWidget {
  @override
  _MyAPPState createState() => _MyAPPState();
}

class _MyAPPState extends State<MyAPP> {
  ///TO SHOW THE SPLASH_SCREEN BEFORE LOADING THE DATA
  bool showSplashScreen;

  ///CIRCULAR_PROGRESS_INDICATOR PROGRESS VALUE DEPENDS
  double progressIndicatorVal;

  @override
  void initState() {
    super.initState();

    ///TODO: HERE DO THE SPLASH_SCREEN VALUE TO TRUE WHILE GIT PUSH
    showSplashScreen = true;
    progressIndicatorVal = 0.0;

    ///CALLING NEW SQFLITE PACKAGE BACKGROUND RUN
    ApplyDBLevelChanges();
    // setInitialTokenValue();
  }

  Future<void> ApplyDBLevelChanges() async {
    try {
      print('ApplyDBLevelChanges');
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String isProductTableChange = await Session.getData(Session.isProductTableChange);
      String isCompanyTableChange = await Session.getData(Session.isCompanyTableChange);
      print('isCompanyTableChange before $isCompanyTableChange');

      if (isProductTableChange == null || isProductTableChange == '') {
        prefs.setString(Session.isProductTableChange,
            DBChanges.isProductTableChange.toString());
      }
      if (isCompanyTableChange == null || isCompanyTableChange == '') {
        prefs.setString(Session.isCompanyTableChange,
            DBChanges.isCompanyTableChange.toString());
      }

      print('isCompanyTableChange After $isCompanyTableChange');

      if (isCompanyTableChange.toString() == 'true') {
        final db = await DBProvider.db.database;
        await db.execute(CompanyDBHelper().getTableDropQuery());
        print('Company Table Droped');
        await db.execute(CompanyDBHelper().getTableCreateQuery());
        print('Company Table created');
        prefs.setString(Session.isCompanyTableChange, "false");
        var syncMasterResetRes =
            await _syncMasterDBHelper.updateMasterTableLastSyncDateByName(
          lastSyncDate: '',
          masterTableName: CompanyDBHelper().tableName,
        );
      }

      if (isProductTableChange.toString() == 'true') {
        final db = await DBProvider.db.database;
        await db.execute(ProductDBHelper().getTableDropQuery());
        print('Product Table Dropped');
        await db.execute(ProductDBHelper().getTableCreateQuery());
        print('Product Table created');

        prefs.setString(Session.isProductTableChange, "false");
        var syncMasterResetRes =
            await _syncMasterDBHelper.updateMasterTableLastSyncDateByName(
          lastSyncDate: '',
          masterTableName: ProductDBHelper().tableName,
        );
      }

      setInitialTokenValue();
    } catch (e) {
      print('Error inside HandleActionButtonEnableStatus ');
      print(e);
    }
  }

  ///IT INSERTS THE TOKEN VALUE TO THE LOCAL_DATABASE FOR SYNC IN BACKGROUND
  void setInitialTokenValue() async {
    print('Inside setInitialTokenValue Fn ');
    _tokenValue = await Session.getData(Session.accessToken);
    _userNameValue = await Session.getData(Session.userName);
    _apiDomainValue = await Session.getData(Session.apiDomain);
    print('_apiDomainValue $_apiDomainValue');

    TokenHelper _tokenHelper = new TokenHelper(
        Id: 1,
        Token: '$_tokenValue',
        Username: '$_userNameValue',
        ApiDomain: _apiDomainValue);
    _tokenDBHelper
        .addToken(
          tokenHelperObject: _tokenHelper,
        )
        .then((value) => {
              print('LocalDBToken Token Insert Res $value'),
              this.setState(() {
                progressIndicatorVal = 1.0;
                showSplashScreen = false;
              }),
              backgroundedSFInsertUpdateHandler(),
            })
        .catchError((e) => {
              print(
                  'Error inside setInitialTokenValue FN  while setting token in local Database '),
              print(e),
              this.setState(() {
                progressIndicatorVal = 1.0;
                showSplashScreen = false;
              }),
            });
  }

  ///IT UPDATES THE PROGRESS_INDICATOR PROGRESS VALUE BY SETTING THE STATUS
  void updateProgress(double value) {
    setState(() {
      progressIndicatorVal = value;
    });
  }

  ///IT RETURNS THE LOADING SCREEN WIDGET CONTAINING THE CIRCULAR_PROGRESS_INDICATOR
  Widget getLoadingScreen() {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomPadding: false,
        body: Container(
          color: Colors.white,
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CircularProgressIndicator(
                  value: progressIndicatorVal,
                  backgroundColor: Colors.cyan,
                  strokeWidth: 9.0,
                ),
                SizedBox(
                  height: 20.0,
                ),
                Text('LOADING...${progressIndicatorVal * 100}%'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return showSplashScreen ? getLoadingScreen() : MainScreen();
  }
}
