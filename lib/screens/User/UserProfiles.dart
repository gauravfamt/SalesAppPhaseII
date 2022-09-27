import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:moblesales/helpers/index.dart';
import 'package:moblesales/models/index.dart';
import 'package:moblesales/screens/index.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:http/http.dart' as http;

class UserProfiles extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return (MaterialApp(
      debugShowCheckedModeBanner: false,
      home: UserProfilesPage(parentBuildContext: context),
    ));
  }
}

class UserProfilesPage extends StatefulWidget {
  final BuildContext parentBuildContext;
  UserProfilesPage({Key key, @required this.parentBuildContext})
      : super(key: key);
  @override
  UserProfilesPageState createState() => UserProfilesPageState();
}

class UserProfilesPageState extends State<UserProfilesPage> {
  ///USED TO HANDLE THE FULLSCREEN_LOADER JUST SET THE STATE TO THE TRUE TO START
  bool isFullScreenLoading;

  ///HOLDS STANDARD_FIELDS FOR THE ORDER_HEADER ENTITY
  List<StandardField> onGridStandardFields;

  ///HOLDS STANDARD_FIELDS FOR THE ORDER_DETAIL ENTITY
  List<StandardField> detailsOnGridStandardFields;

  List<User> users;

  ///HANDLES THE SEARCH_TEXT_FIELD STATE FOR THE ADVANCED SEARCH
  String searchFieldContent;

  ///IT HOLDS THE SELECTED COMPANY/CUSTOMER FOR THE ADVANCED SEARCH
  Company _selectedCompany;

  ///USED TO CHECK THE PAGINATION DATA IS REMAINING FOR LOADING OR NOT
  bool isDataRemaining;

  ///USED TO CONFIGURE VISIBILITY OF SEARCH LOADER DISPLAY BELOW SEARCH PANEL
  bool isShowLoader;

  ///TO CONFIGURE VISIBILITY OF PAGINATION LOADER DISPLAY ON BOTTOM
  bool isShowPaginationLoader;

  ///API PARAMETER FOR PAGINATION PAGES
  int pageNumber;
  int pageSize;

  ///IT FETCHES THE USERS LIST
  Future<List<User>> fetchUsers() async {
//    SharedPreferences prefs = await SharedPreferences.getInstance();
//    var token = prefs.getString(Session.accessToken);
    var userData = List<User>();
    String url =
        '${await Session.getData(Session.apiDomain)}/${URLs.GET_USERS}?pageNumber=$pageNumber&pageSize=$pageSize';
    if (_selectedCompany != null) {
      url = '$url&CustomerNo=${_selectedCompany.CustomerNo}';
    }
    if (searchFieldContent != null && searchFieldContent.trim().length > 0) {
      url = '$url&Searchtext=${searchFieldContent.trim()}';
    }
    print('$url');
    http.Client client = http.Client();
    final response = await client.get(url, headers: {
      "token": await Session.getData(Session.accessToken)
    }).timeout(duration);

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      userData = data.map<User>((json) => User.fromJson(json)).toList();
    }
    return userData;
  }

  @override
  void initState() {
    super.initState();
    isDataRemaining = true;
    isShowLoader = true;
    isShowPaginationLoader = false;
    pageNumber = 1;
    pageSize = Pagination.LIST_PAGE_SIZE;
    users = List<User>();
    _selectedCompany = null;
    searchFieldContent = null;
    onGridStandardFields = List<StandardField>();
    detailsOnGridStandardFields = List<StandardField>();
    isFullScreenLoading = false;
    fetchPersonStandardFields();
  }

  ///IT FETCHES THE USERS DATA AND MANAGE THE PAGINATION STATES
  void dataFetch() {
    if (isDataRemaining) {
      fetchUsers().then((invoicesDataRes) => {
            print('got fetchUser response'),
            setState(() {
              pageNumber = pageNumber + 1; //<--To get next record set
              int newRecordCount = invoicesDataRes.length;
              users.addAll(invoicesDataRes);
              isShowLoader = false;
              isShowPaginationLoader = false;
              if (newRecordCount < pageSize) {
                isDataRemaining = false;
              }
            })
          });
    } else {
      print('no more data');
      setState(() {
        isShowLoader = false;
        isShowPaginationLoader = false;
      });
      Fluttertoast.showToast(
          msg: "No more data",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black38,
          textColor: Colors.white,
          fontSize: 16.0);
    }
    paginationLoader();
  }

  ///IT FETCHES THE STANDARD FIELDS FOR ON_GRID_SHOW FIELDS SHOW IN LIST UI
  void fetchPersonStandardFields() {
    ApiService.getStandardFields(
            entity: StandardEntity.PERSON,
            showInGrid: true,
            showOnScreen: false)
        .then((value) => {
              ///HERE CHECKING IF STANDARD FIELDS RESPONSE DID'T RECEIVED THEN NOT CALLING THE GET_DATA_API
              if (value.length > 0)
                {
                  setState(() {
                    onGridStandardFields = value;
                  }),
                  dataFetch()
                }
              else
                {
                  setState(() {
                    isShowLoader = false;
                    isShowPaginationLoader = false;
                  }),
                  Fluttertoast.showToast(
                      msg: "No more data",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.black38,
                      textColor: Colors.white,
                      fontSize: 16.0),
                }
            })
        .catchError((onError) => {
              print(
                  'Error while fetching OnGrid StandardFields for the Person Entity'),
              print(onError)
            });
  }

  ///IT SHOWS THE LOADER UNTIL USERS LIST IS LOADED
  Widget loader() {
    return Visibility(
      visible: isShowLoader,
      child: Center(
        child: Padding(
          padding: EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 50.0),
          child: CircularProgressIndicator(
            backgroundColor: Colors.teal.shade100,
          ),
        ),
      ),
    );
  }

  ///IT SHOWS THE PAGINATION LOADER AT THE BOTTOM UNTIL PAGINATION DATA IS LOADED
  Widget paginationLoader() {
    return Visibility(
      visible: isShowPaginationLoader,
      child: Center(
        child: Padding(
          padding: EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 50.0),
          child: CircularProgressIndicator(
            backgroundColor: Colors.teal.shade100,
          ),
        ),
      ),
    );
  }

  ///It closes the CompanySearch Dialog On CLose Btn click
  void closeSearchDialog() {
    print('closeSearchDialog called of the Invoices page');
  }

  ///It handles the Selected Company Response for the search
  void handleCustomerSelectedSearch(Company selectedCompany) {
    print('Inside handleCustomerSelectedSearch fn of Invoice Screen');
    setState(() {
      _selectedCompany = selectedCompany;
    });
    loadNewSearchData();
  }

  ///It resets the search Data
  void clearSelectedCompany() {
    setState(() {
      _selectedCompany = null;
    });
    loadNewSearchData();
  }

  ///It handles the SearchTextField Search click changes and Loads the new data accordingly
  void handleTextFieldSearch(String searchText) {
    setState(() {
      searchFieldContent = searchText;
    });
    loadNewSearchData();
  }

  ///It handles the SearchTextField Cancel/Clear click changes and Loads the new data accordingly
  void clearTextFieldSearch() {
    setState(() {
      searchFieldContent = '';
    });
    loadNewSearchData();
  }

  ///It clears the common search states and loads new data as per the search parameters
  void loadNewSearchData() {
    setState(() {
      users.clear();
      pageNumber = 1;
      isDataRemaining = true;
      isShowLoader = true;
    });
    dataFetch();
  }

  ///It Shows the customerSearch Dialog for selecting the customer for getting specified Customer's data
  void showCompanyDialog() {
    showDialog(
      useRootNavigator: true,
      barrierDismissible: false,
      context: context,
      builder: (context) => CustomerSearchDialog(
        handleCustomerSelectedSearch: this.handleCustomerSelectedSearch,
        closeSearchDialog: this.closeSearchDialog,
        forLookupType: true,
      ),
    );
  }

  ///It returns the search bar Widget for the Users list screen
  Widget _buildCompanySearchTF() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 0.0),
        child: Card(
          elevation: 0.0,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: GestureDetector(
              onTap: () {
                showCompanyDialog();
              },
              child: Row(
                children: <Widget>[
                  Expanded(
                      child: Text(
                    '${_selectedCompany != null ? _selectedCompany.Name : 'Select Customer'}',
                    style: TextStyle(color: AppColors.grey, fontSize: 16.0),
                  )),
                  _selectedCompany != null
                      ? IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            clearSelectedCompany();
                          },
                        )
                      : Icon(
                          Icons.search,
                          color: AppColors.blue,
                        )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void dummyActionClickHandler(recordPosition) {}

  ///IT HANDLES ALL THE BUTTONS UI AND ACTIONS FOR THE LIST VIEW
  ///IT REQUIRES
  ///           title : BUTTON_TITLE
  ///           recordPosition:  RECORD_CLICK_POSITION FROM THE LIST
  ///           clickAction : FUNCTION NAVE TO PERFORM THE SPECIFIC ACTION ON THE CLICK
  Widget getActionButton(
      String title, int recordPosition, Function clickAction, Color btnColor) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
        child: RaisedButton(
          onPressed: () {
            print('Action Button Clicked for row $recordPosition');
            clickAction(recordPosition);
          },
          color: btnColor,
          child: Text(
            '$title',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  ///IT RETURNS TEH ACTIONS BUTTONS FOR THE LIST VIEW
  /// NOTE: HERE AS IT WILL BE DISPLAYED IN LIST VIEW
  ///       KEEP ONLY TWO BUTTONS INSIDE THE SINGLE ROW
  ///       OTHERWISE IT'LL LOOK CONJESTED IN THE LIST VIEW
  List<Row> getActionButtonRows(int recordPosition) {
    List<Row> rowsList = List<Row>();

    ///ADDING THE FIRST ROW WITH ONE BUTTON FOR THE NAVIGATION
    rowsList.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          getActionButton('Resend Login', recordPosition,
              dummyActionClickHandler, AppColors.blue),
          getActionButton(
              'Disable', recordPosition, dummyActionClickHandler, Colors.grey),
        ],
      ),
    );

    ///ADDING THE SECOND ROW WITH ONE BUTTON FOR THE NAVIGATION
    rowsList.add(
      Row(
        children: <Widget>[
          getActionButton('Delete', recordPosition, dummyActionClickHandler,
              AppColors.buttonBrown),
        ],
      ),
    );
    return rowsList;
  }

  Widget _buildList() {
    return Expanded(
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (!isShowPaginationLoader &&
              scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            dataFetch(); //<-- start loading data
            setState(() {
              if (isDataRemaining == true) {
                isShowPaginationLoader = true;
                paginationLoader();
              }
            });
          }
          return true;
        },
        child: Container(
          child: ListView.builder(
            itemCount: users.length,
            padding: const EdgeInsets.all(15.0),
            itemBuilder: (context, position) {
              return Container(
                child: ListViewRows(
                  standardFields: onGridStandardFields,
                  recordObj: users[position],
                  recordPosition: position,
                  isActionsEnabled: true,
                  isEntitySectionCheckDisabled: true,
                  actionButtonRows: getActionButtonRows(position),
                  showOnGridFields: true,
                  isExcludedFieldEnabled: false,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isFullScreenLoading,
      opacity: FullScreenLoader.OPACITY,
      progressIndicator: FullScreenLoader.PROGRESS_INDICATOR,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Users"),
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(widget.parentBuildContext);
              }),
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[_buildCompanySearchTF()],
              ),
              SearchTextField(
                searchFieldContent: searchFieldContent,
                clearTextFieldSearch: clearTextFieldSearch,
                handleTextFieldSearch: handleTextFieldSearch,
              ),
              SizedBox(height: 5.0),
              loader(),
              _buildList(),
              paginationLoader(),
            ],
          ),
        ),
      ),
    );
  }
}
