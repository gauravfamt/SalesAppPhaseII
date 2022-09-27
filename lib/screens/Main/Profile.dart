import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moblesales/helpers/index.dart';
import 'package:moblesales/models/index.dart';
import 'package:moblesales/screens/index.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  ///USED TO HANDLE THE FULLSCREEN_LOADER JUST SET THE STATE TO THE TRUE TO START
  bool isFullScreenLoading;

  ///HOLDS LOGGED_IN USER OBJECT
  User _user;

  ///HOLDS REUSABLE WIDGETS
  CommonWidgets _commonWidgets;

  ///DECIDES TO DISPLAY USER DETAILS OR NOT
  bool isUserDetailsVisible;

  ///HOLDS THE LOADING MESSAGE OR THE ERROR MESSAGE
  String message;

  ///HOLDS STANDARD_FIELDS FOR THE PERSON_ENTITY ENTITY
  List<StandardField> onGridStandardFields;

  ///TO REUSE WIDGETS WHICH BUILDS LIST KEY VALUE PAIR UI
  ListViewRowsHelper _listViewRowsHelper;
  bool isOffline;
  StreamSubscription _connectionChangeStream;
  @override
  void initState() {
    super.initState();
    isOffline = ConnectionStatus.isOffline;
    _commonWidgets = CommonWidgets();
    ConnectivityService connectionStatus = ConnectivityService.getInstance();
    _connectionChangeStream =
        connectionStatus.connectionChange.listen(connectionChanged);
    _listViewRowsHelper = ListViewRowsHelper();
    _user = User();
    onGridStandardFields = List<StandardField>();
    message = "Loading User Details...";
    isFullScreenLoading = true;
    isUserDetailsVisible = false;
    fetchStandardFields();
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

  ///IT FETCHES THE STANDARD FIELDS FOR ON_GRID_SHOW FIELDS SHOW IN LIST UI
  void fetchStandardFields() {
    isOffline == true
        ? handleNetworkIssue()
        : ApiService.getStandardFields(
            entity: StandardEntity.PERSON,
            showInGrid: true,
            showOnScreen: false,
          )
            .then((value) => {
                  ///HERE CHECKING IF STANDARD FIELDS RESPONSE DID'T RECEIVED THEN NOT CALLING THE GET_DATA_API
                  if (value.length > 0)
                    {
                      if (value.length > 1)
                        value.sort(
                          (a, b) => (a.SortOrder != null && b.SortOrder != null)
                              ? a.SortOrder.compareTo(b.SortOrder)
                              : -1,
                        ),
                      if (mounted)
                        {
                          setState(() {
                            onGridStandardFields = value;
                          }),
                          getUserDetails(),
                        },
                    }
                  else
                    {
                      this.handleUserLoadError(),
                    }
                })
            .catchError((onError) => {
                  print(
                      'Error while fetching OnGrid StandardFields for the Person Entity'),
                  print(onError),
                  this.handleUserLoadError(),
                })
            .whenComplete(() => {
                  for (int i = 0; i < onGridStandardFields.length; i++)
                    {
                      print('${onGridStandardFields[i].FieldName}'),
                    }
                });
  }

  ///LOADS LOGGED_IN USERS DETAILS
  void getUserDetails() async {
    isOffline == true
        ? handleNetworkIssue()
        : ApiService.getLoggedInUserDetails()
            .then((users) => {
                  if (users.length > 0)
                    {
                      if (mounted)
                        this.setState(() {
                          _user = users[0];

                          isFullScreenLoading = false;
                          isUserDetailsVisible = true;
                        }),
                    }
                  else
                    {
                      this.handleUserLoadError(),
                    }
                })
            .catchError((e) => {
                  this.handleUserLoadError(),
                })
            .whenComplete(() => {
                  print('User Code ${_user.UserCode}'),
                  print('Sales Site ${_user.SalesSite}'),
                });
  }

  ///HANDLES THE USER LOAD ERROR
  void handleUserLoadError() {
    if (mounted) {
      this.setState(() {
        message = 'Unable to load user details!';
        isFullScreenLoading = false;
      });
      _commonWidgets.showFlutterToast(
          toastMsg: 'Something Went Wrong while loading user details');
    }
  }

  void handleNetworkIssue() {
    if (mounted) {
      this.setState(() {
        message = "No Data Found...";
        isFullScreenLoading = false;
      });
      _commonWidgets.showFlutterToast(
          toastMsg: ConnectionStatus.NetworkNotAvailble);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isFullScreenLoading,
      opacity: 0.5,
      progressIndicator: CircularProgressIndicator(),
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          child: !isUserDetailsVisible || isFullScreenLoading
              ? Container(
                  //IF USER DETAILS NOT FOUND OR SOME ERROR OCCURRED WHILE FETCHING DATA
                  child: Center(
                    child: Text(
                      '$message',
                      style: TextStyle(
                        color: AppColors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                    ),
                  ),
                )
              : Column(
                  //IF USER DETAILS FOUND THEN SHOWING THE DETAIL SCREEN
                  children: <Widget>[
                    ///USER IMAGE
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: CircleAvatar(
                        radius: 50.0,
                        backgroundImage: AssetImage('assets/img/user.png'),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(5.0, 20.0, 5.0, 0.0),
                        width: double.infinity,
                        child: ListView(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          children: _listViewRowsHelper.getRowCardContents(
                              classObj: _user,
                              isEntitySectionCheckDisabled: true,
                              standardFields: onGridStandardFields,
                              showOnGridFields: true,
                              isExcludedFieldEnabled: false,
                              currencyCaption: '',
                              isProfile: true),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
