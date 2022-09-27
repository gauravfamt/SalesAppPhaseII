import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:moblesales/screens/index.dart';
import 'package:moblesales/helpers/index.dart';
import 'package:moblesales/models/index.dart';
import 'package:moblesales/utils/index.dart';

class Statistics extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Statistics",
      home: StatisticsPage(parentBuildContext: context),
    );
  }
}

class StatisticsPage extends StatefulWidget {
  final BuildContext parentBuildContext;
  StatisticsPage({Key key, @required this.parentBuildContext})
      : super(key: key);
  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  DashboardDetails data;

  ///USED TO HANDLE THE FULLSCREEN_LOADER JUST SET THE STATE TO THE TRUE TO START
  bool isFullScreenLoading;

  ///TO FETCH THE CURRENCY DROPDOWN VALUES
  StandardDropDownFieldsDBHelper _standardDropDownFieldsDBHelper;

  ///HOLDS CURRENCY DROPDOWN FIELD
  StandardDropDownField _standardCurrencyDropDownField;

  ///HOLDS CURRENCY_SYMBOL
  String currencySymbol;

  CommonWidgets _commonWidgets;

  Future<DashboardDetails> fetchDashboardDetails() async {
    try {
      String url =
          '${await Session.getData(Session.apiDomain)}${URLs.GET_DASHBOARD_DETAILS}';
      print('$url');
      http.Client client = http.Client();
      final response = await client.get(url, headers: {
        "token": await Session.getData(Session.accessToken)
      }).timeout(duration);

      if (response.statusCode == 200 && response.body != "No Quotes found") {
        print("response $response");
        var dashboardResponse =
            DashboardDetails.fromJson(json.decode(response.body));
        print('dashboardResponse: $dashboardResponse');
        print('TotalRevenue: ${dashboardResponse.TotalRevenue}');
        return Future.value(dashboardResponse);
      } else {
        return Future.error(ErrorDescription('No Data Found'));
      }
    } catch (e) {
      print('Error inside fetchQuotes FN');
      print(e);
      throw Future.error(e);
    }
  }

  void dataFetch() {
    fetchDashboardDetails()
        .then((value) => {
              if (mounted)
                setState(() => {data = value, isFullScreenLoading = false}),
            })
        .catchError((e) => {
              if (mounted) setState(() => {isFullScreenLoading = false}),
            });
  }

  @override
  void initState() {
    super.initState();
    _commonWidgets = CommonWidgets();

    ///TO FETCH THE CURRENCY DROPDOWN VALUES
    _standardDropDownFieldsDBHelper = StandardDropDownFieldsDBHelper();
    _standardCurrencyDropDownField = StandardDropDownField();
    currencySymbol = '';
    data = DashboardDetails(
      TotalRevenue: 0.0,
      TotalSales: 0,
      TotalOrders: 0,
      TotalPaymentDues: 0.0,
    );
    isFullScreenLoading = true;
    fetchCurrencyDropDownValue();
  }

  ///FETCHES CURRENCY DROPDOWN VALUE
  void fetchCurrencyDropDownValue() async {
    _standardDropDownFieldsDBHelper
        .getEntityStandardDropdownFieldsData(
          entity: StandardEntity.CURRENCY_DROPDOWN_ENTITY,
          searchText: DropdownSearchText.CURRENCY_DROPDOWN_SEARCH_TEXT,
        )
        .then((value) => {
              ///BY CHECKING THIS IT DOES NOT SET THE STATE AFTER THE SCREEN IS NOT IN FRONT
              if (mounted)
                {
                  if (value.length > 0)
                    {
                      this.setState(() {
                        _standardCurrencyDropDownField = value[0];
                        currencySymbol = _standardCurrencyDropDownField
                                    .Caption !=
                                null
                            ? '${HtmlUnescape().convert(_standardCurrencyDropDownField.Caption)}'
                            : '';
                      }),
                      this.dataFetch(),
                    }
                  else
                    {
                      print('Currency DropDown Entry not present at localDB'),
                      this.dataFetch(),
                    }
                }
            })
        .catchError((e) => {
              print(
                  'Error while fetching currency dropdown fields from LocalDB'),
              print(e),
              this.dataFetch(),
            });
  }

  Widget _buildCard(String key, String value) {
    return Card(
      color: AppColors.greyOut,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      elevation: 4,
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.only(left: 10.0, right: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              child: Center(
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
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              child: Center(
                child: Text(
                  '$value',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    /*24 is for notification bar on Android*/
    final double itemHeight = size.width / 3;
    final double itemWidth = size.width / 2;
    return ModalProgressHUD(
      inAsyncCall: isFullScreenLoading,
      opacity: 0.5,
      progressIndicator: CircularProgressIndicator(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppBarTitles.STATISTICS),
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(widget.parentBuildContext);
              }),
        ),
        body: Container(
          padding: EdgeInsets.all(10),
          color: Colors.grey[100],
          child: GridView.count(
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            crossAxisCount: 2,
            childAspectRatio: (itemWidth / itemHeight),
            children: <Widget>[
              _buildCard('Total Revenue',
                  '$currencySymbol ${data.TotalRevenue != null ? data.TotalRevenue : 0.0}'),
              _buildCard('Total Sales',
                  '${data.TotalSales != null ? data.TotalSales : 0}'),
              _buildCard('Total Orders',
                  '${data.TotalOrders != null ? data.TotalOrders : 0}'),
              _buildCard('Total Payments',
                  '$currencySymbol ${data.TotalPaymentDues != null ? data.TotalPaymentDues : 0.0}'),
            ],
          ),
        ),
      ),
    );
  }
}
