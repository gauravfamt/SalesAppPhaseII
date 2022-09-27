import 'dart:async';

import 'package:flutter/material.dart';
//import 'package:flutter/services.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:moblesales/helpers/index.dart';
import 'package:moblesales/screens/index.dart';
import 'package:moblesales/utils/index.dart';
import 'Common/CommonWidgets.dart';
import 'LoginScreen.dart';

//void main() => runApp(Home());

class MainScreen extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    debugPrint("Home");
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Home",
      home: MainScreenPage(),
    );
  }
}

class MainScreenPage extends StatefulWidget {
  _MainScreenPageState createState() => _MainScreenPageState();
}

class _MainScreenPageState extends State<MainScreenPage> {
  String _title;
  int _selectedIndex = 0;
  CommonDBHelper _commonDBHelper;

  /// FOR SHOWING FULLSCREEN LOADER
  bool isFullScreenLoading;
  TextStyle optionStyle = TextStyle(
      fontSize: 30, fontWeight: FontWeight.bold, color: Colors.purple);

  List<Widget> _widgetOptions;

  CommonWidgets _commonWidgets;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      switch (index) {
        case 0:
          {
            _title = 'Home';
          }
          break;
        case 1:
          {
            _title = 'Me';
          }
          break;
        case 2:
          {
            _title = 'Settings';
          }
          break;
      }
    });
  }

  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  bool isNotification;

  ///NETWORK_CONNECTION STREAM SUBSCRIPTION TO GET UPDATES WHEN APP IS ONLINE OR OFFLINE
  StreamSubscription _connectionChangeStream;
  bool isOffline;

  @override
  void initState() {
    super.initState();
    isOffline = ConnectionStatus.isOffline;
    _commonDBHelper = CommonDBHelper();
    _commonWidgets = CommonWidgets();
    ConnectivityService connectionStatus = ConnectivityService.getInstance();
    _connectionChangeStream = connectionStatus.connectionChange
        .listen(_commonWidgets.connectionChanged);
    isNotification = false;
    isFullScreenLoading = false;

    _title = 'Home';
    _widgetOptions = <Widget>[
      HomeScreen(
        createFolderHandler: navigate,
      ),
      ProfileScreen(),
      SettingsScreen(),
    ];
    getNotificationCount();
  }

  void navigate(String val) {
    // print("navigate called: $val");
    if (val == "Quotes") {
      // open select customer
      Navigator.push(
          context,
          new MaterialPageRoute(
              builder: (context) => new SelectCustomer(
                    pageNameToNavigate: val,
                  )));
    } else if (val == "Customers") {
      // open select customer
//      Navigator.push(context, new MaterialPageRoute(builder: (context) => new Select Customer()));
      Navigator.push(
          context,
          new MaterialPageRoute(
              builder: (context) => new SelectCustomer(
                    pageNameToNavigate: val,
                  )));
    } else if (val == "Inventory") {
      Navigator.push(context,
          new MaterialPageRoute(builder: (context) => new InventoryScreen()));
      //
    } else if (val == "Existing Sales Orders") {
      // open select customer
//      Navigator.push(context, new MaterialPageRoute(builder: (context) => new SalesOrder()));
      Navigator.push(
          context,
          new MaterialPageRoute(
              builder: (context) => new SelectCustomer(
                    pageNameToNavigate: val,
                  )));
    } else if (val == "Customer Statements") {
      // open Customer Statements
      Navigator.push(
          context,
          new MaterialPageRoute(
              builder: (context) => new CustomerStatements(
                    reportType: 1,
                  )));
    } else if (val == "A/R") {
      // open Customer Statements
      Navigator.push(
          context,
          new MaterialPageRoute(
              builder: (context) => new CustomerStatements(
                    reportType: 2,
                  )));
    } else if (val == "Invoices") {
      // open select customer
      Navigator.push(
          context,
          new MaterialPageRoute(
              builder: (context) => new SelectCustomer(
                    pageNameToNavigate: val,
                  )));
//      Navigator.push(context, new MaterialPageRoute(builder: (context) => new Invoice()));
    } else if (val == "Products Catalog") {
      Navigator.push(context,
          new MaterialPageRoute(builder: (context) => new ProductScreen()));
    }
  }

  void logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // prefs.remove(Session.userName);
    prefs.remove(Session.password);
    prefs.remove(Session.accessToken);
    prefs.remove(Session.userCode);
    prefs.remove(Session.salesSite);
    prefs.remove(Session.rptCSCode);
    prefs.remove(Session.rptARCode);
    // prefs.clear();
    try {
      setState(() {
        isFullScreenLoading = true;
      });
      var deleteRes = await _commonDBHelper.deleteTablesOnLogout();
      // print('delete Tables On Logout deleteRes : $deleteRes');
      setState(() {
        isFullScreenLoading = false;
      });
    } catch (e) {
      print('Error inside logout Fn while clearing the localDB data ');
      print(e);
      setState(() {
        isFullScreenLoading = false;
      });
    }
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (BuildContext context) => Login()),
        (Route<dynamic> route) => false);
  }

  void getNotificationCount() async {
    // check if any entry present in db
    if (await AddQuoteDBHelper().getAddQuoteCount() > 0) {
      setState(() {
        isNotification = true;
      });
    } else {
      setState(() {
        isNotification = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isFullScreenLoading,
      opacity: FullScreenLoader.OPACITY,
      progressIndicator: FullScreenLoader.PROGRESS_INDICATOR,
      child: new Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(_title),
          backgroundColor: Colors.blue,
          actions: <Widget>[
            IconButton(
              icon: Icon(isNotification == true
                  ? Icons.notifications_active
                  : Icons.notifications_none),
              onPressed: () {
                Navigator.push(
                        context,
                        new MaterialPageRoute(
                            builder: (context) => new NotificationScreen()))
                    .whenComplete(() => getNotificationCount());
              },
            )
          ],
        ),
        drawer: Theme(
          data: Theme.of(context).copyWith(canvasColor: Colors.white),
          child: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                Container(
                  height: 100.0,
                  child: DrawerHeader(
                    margin: EdgeInsets.all(0.0),
                    padding: EdgeInsets.only(
                        left: 20.0, top: 10.0, right: 10.0, bottom: 10.0),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                    ),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              FutureBuilder(
                                  future: Session.getData(Session.realName),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<dynamic> text) {
                                    return Text(
                                      text.hasData && text.data != null
                                          ? text.data
                                          : 'User',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    );
                                  }),
                              FutureBuilder(
                                future: Session.getData(Session.userName),
                                builder: (BuildContext context,
                                    AsyncSnapshot<dynamic> text) {
                                  return Text(
                                    text.hasData && text.data != null
                                        ? text.data
                                        : 'User',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.power_settings_new),
                          color: Colors.white,
                          onPressed: () {
                            logout(context);
                          },
                        )
                      ],
                    ),
                  ),
                ),
//                Divider(
//                  thickness: 2.0,
//                  color: Colors.white,
//                ),
                Ink(
                  color: Colors.white,
                  child: new ListTile(
                    leading: Icon(Icons.people, color: Colors.blue),
                    title: Text(
                      'Customer Profile',
                      style: TextStyle(color: Colors.blue),
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (context) => new CustomerProfiles()));
                    },
                  ),
                ),

                Ink(
                  color: Colors.white,
                  child: new ListTile(
                    leading: Icon(Icons.view_list, color: Colors.blue),
                    title: Text('Products Catalog',
                        style: TextStyle(color: Colors.blue)),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (context) => new ProductScreen()));
                    },
                  ),
                ),
                Ink(
                  color: Colors.white,
                  child: new ListTile(
                    leading: Icon(Icons.description, color: Colors.blue),
                    title: Text('Sales Quotes',
                        style: TextStyle(color: Colors.blue)),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                              context,
                              new MaterialPageRoute(
                                  builder: (context) => new Quote()))
                          .whenComplete(() => getNotificationCount());
                    },
                  ),
                ),
                Ink(
                  color: Colors.white,
                  child: new ListTile(
                    leading: Icon(Icons.receipt, color: Colors.blue),
                    title: Text('Sales Orders',
                        style: TextStyle(color: Colors.blue)),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (context) => new SalesOrder()));
                    },
                  ),
                ),
                Ink(
                  color: Colors.white,
                  child: new ListTile(
                    leading: Icon(Icons.receipt, color: Colors.blue),
                    title:
                        Text('Invoices', style: TextStyle(color: Colors.blue)),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (context) => new Invoice()));
                    },
                  ),
                ),
                Ink(
                  color: Colors.white,
                  child: new ListTile(
                    leading: Icon(Icons.assessment, color: Colors.blue),
                    title:
                        Text('Inventory', style: TextStyle(color: Colors.blue)),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (context) => new InventoryScreen()));
                    },
                  ),
                ),
                Ink(
                  color: Colors.white,
                  child: new ListTile(
                    leading: Icon(Icons.assessment, color: Colors.blue),
                    title: Text('A/R', style: TextStyle(color: Colors.blue)),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (context) => new CustomerStatements(
                                    reportType: 2,
                                  )));
                    },
                  ),
                ),
                Ink(
                  color: Colors.white,
                  child: new ListTile(
                    leading: Icon(Icons.assessment, color: Colors.blue),
                    title: Text('Customer Statements',
                        style: TextStyle(color: Colors.blue)),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (context) => new CustomerStatements(
                                    reportType: 1,
                                  )));
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              title: Text('Home'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              title: Text('Me'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              title: Text('Settings'),
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.blue,
          unselectedItemColor: AppColors.grey,
          selectedLabelStyle: TextStyle(color: Colors.pink),
          unselectedLabelStyle: TextStyle(color: Colors.amber),
          showUnselectedLabels: true,
          showSelectedLabels: true,
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          onTap: _onItemTapped,
        ),
        body: Center(
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
      ),
    );
  }
}
