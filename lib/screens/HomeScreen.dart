import 'dart:async';
import 'package:flutter/material.dart';
import 'package:moblesales/helpers/index.dart';
import 'package:moblesales/models/index.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'Common/CommonWidgets.dart';

class HomeScreen extends StatelessWidget {
  // This widget is the root of your application.
  final Function(String folderName) createFolderHandler;

  HomeScreen({
    Key key,
    @required this.createFolderHandler,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    debugPrint("Home");
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Home",
      home: HomeScreenPage(
        createFolderHandler: createFolderHandler,
      ),
    );
  }
}

class HomeScreenPage extends StatefulWidget {
  final Function(String folderName) createFolderHandler;

  HomeScreenPage({
    Key key,
    @required this.createFolderHandler,
  }) : super(key: key);

  _HomeScreenPageState createState() => _HomeScreenPageState();
}

class _HomeScreenPageState extends State<HomeScreenPage> {
  DashboardDetails data;

  bool isLargeScreen;

  ///USED TO HANDLE THE FULLSCREEN_LOADER JUST SET THE STATE TO THE TRUE TO START
  bool isFullScreenLoading;

  ///HOLDS CURRENCY_SYMBOL
  String currencySymbol;

  CommonWidgets _commonWidgets;

  bool isOffline;
  StreamSubscription _connectionChangeStream;

  @override
  void initState() {
    super.initState();
    isOffline = ConnectionStatus.isOffline;
    _commonWidgets = CommonWidgets();
    ConnectivityService connectionStatus = ConnectivityService.getInstance();
    _connectionChangeStream = connectionStatus.connectionChange
        .listen(_commonWidgets.connectionChanged);
  }

  Widget _buildCard(String key, String imgPath) {
    return GestureDetector(
      child: Card(
        color: Colors.white,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        elevation: 4,
        child: Container(
          padding: EdgeInsets.only(left: 10.0, right: 10.0),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Center(
                  child: Padding(
                    padding: imgPath.contains("Invoices")
                        ? const EdgeInsets.fromLTRB(5.0, 0, 0, 0)
                        : const EdgeInsets.all(0.0),
                    child: Image.asset(
                      imgPath,
                      height: 80,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    '$key',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.grey,
                    ),
                  ),
                ),
              ]),
        ),
      ),
      onTap: () {
        print("ontap called");
        widget.createFolderHandler(key);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    isLargeScreen = isLargeScreenAvailable(context);
    var size = MediaQuery.of(context).size;
    /*24 is for notification bar on Android*/
    final double itemHeight = size.width / 3;
    final double itemWidth = size.width / 2;
    return ModalProgressHUD(
      inAsyncCall: false,
      opacity: 0.5,
      progressIndicator: CircularProgressIndicator(),
      child: Scaffold(
        body: Container(
          color: Colors.grey[100],
          padding: EdgeInsets.only(left: 20.0, right: 20.0),
          child: GridView.count(
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            crossAxisCount: isLargeScreen ? 4 : 2,
            childAspectRatio: (1),
            children: <Widget>[
              _buildCard("Quotes", 'assets/img/Sales-quote.png'),
              _buildCard("Customers", 'assets/img/Customer.png'),
              _buildCard("Inventory", 'assets/img/Inventory.png'),
              _buildCard("Existing Sales Orders",
                  'assets/img/Existing-sales-order.png'),
              _buildCard("A/R", 'assets/img/AR.png'),
              _buildCard(
                  "Customer Statements", 'assets/img/Customer-statement.png'),
              _buildCard("Invoices", 'assets/img/Invoices.png'),
              _buildCard("Products Catalog", 'assets/img/Product-Catalog.png'),
            ],
          ),
        ),
      ),
    );
  }
}
