import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:moblesales/helpers/index.dart';
import 'package:moblesales/models/index.dart';
import 'package:moblesales/screens/index.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class CustomerProfiles extends StatelessWidget {
  Company company;
  CustomerProfiles({
    Key key,
    this.company,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return (MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CustomerProfilesPage(
          parentBuildContext: context, selectedCompany: company),
    ));
  }
}

class CustomerProfilesPage extends StatefulWidget {
  final BuildContext parentBuildContext;
  final Company selectedCompany;
  CustomerProfilesPage(
      {Key key, @required this.parentBuildContext, this.selectedCompany})
      : super(key: key);
  @override
  CustomerProfilesPageState createState() => CustomerProfilesPageState();
}

class CustomerProfilesPageState extends State<CustomerProfilesPage> {
  ///HOLDS THE CLASS OBJECT WHICH CONTAINS THE REUSABLE WIDGETS
  CommonWidgets _commonWidgets;

  ///USED TO HANDLE THE FULLSCREEN_LOADER JUST SET THE STATE TO THE TRUE TO START
  bool isFullScreenLoading;

  ///HOLDS STANDARD_FIELDS FOR THE COMPANY ENTITY
  List<StandardField> onGridStandardFields;

  ///HOLDS STANDARD_FIELDS FOR THE COMPANY ENTITY
  List<StandardField> addressesOnGridStandardFields;

  ///HOLDS STANDARD_FIELDS FOR THE PERSON ENTITY
  List<StandardField> contactsOnGridStandardFields;

  ///HOLDS THE CURRENCY_CAPTION STANDARD FIELD
  StandardDropDownField _currencyCaption;

  ///HOLDS THE COMPANIES LIST
  List<Company> companies;

  ///HANDLES THE SEARCH_TEXT_FIELD STATE FOR THE ADVANCED SEARCH
  String searchFieldContent;

  ///TO SHOW THE LOADER WHILE COMPANIES LIST IS FETCHING
  bool isShowLoader;

  ///IT HOLDS THE SELECTED COMPANY/CUSTOMER FOR THE ADVANCED SEARCH
  Company _selectedCompany;

  ///API PARAMETERS FOR THE PAGINATION PURPOSE
  int pageNumber;
  int pageSize;

  //for Data table
  bool isLargeScreen;

  //To handle pagination wise data
  bool isNextButtonPressed;
  bool isPreviousButtonPressed;
  bool isNextButtonDisabled;
  bool isPreviousButtonDisabled;
  bool isShowPaginationButtons;
  int lastPageNumber;

  ///NETWORK_CONNECTION STREAM SUBSCRIPTION TO GET UPDATES WHEN APP IS ONLINE OR OFFLINE
  StreamSubscription _connectionChangeStream;

  bool isOffline = false;

  @override
  void initState() {
    super.initState();
    _commonWidgets = CommonWidgets();
    isShowLoader = true;
    isOffline = ConnectionStatus.isOffline;
    pageNumber = 1;
    pageSize = Pagination.LIST_PAGE_SIZE;
    searchFieldContent = null;
    _selectedCompany = widget.selectedCompany;
    companies = List<Company>();
    onGridStandardFields = List<StandardField>();
    addressesOnGridStandardFields = List<StandardField>();
    contactsOnGridStandardFields = List<StandardField>();
    _currencyCaption = StandardDropDownField();
    isFullScreenLoading = false;
    fetchCurrencyStandardField();
    fetchCompanyStandardFields();

    isNextButtonDisabled = false;
    isPreviousButtonDisabled = true; //Initialy on 1 page
    isShowPaginationButtons = true;
    int lastPageNumber = 0;

    if (_selectedCompany != null && _selectedCompany != '') {
      print('Selected company: ${_selectedCompany.CustomerNo}');
      setState(() {
        searchFieldContent = _selectedCompany.CustomerNo;
      });

      ConnectivityService connectionStatus = ConnectivityService.getInstance();
      _connectionChangeStream =
          connectionStatus.connectionChange.listen(connectionChanged);

      fetchCompanies();
    }
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

  ///II FETCHES THE COMPANIES LIST
  Future<List<Company>> fetchCompanies() async {
    try {
      var companyData = List<Company>();
      String url =
          '${await Session.getData(Session.apiDomain)}/${URLs.GET_COMPANIES}?pageNumber=$pageNumber&pageSize=$pageSize';
      if (searchFieldContent != null && searchFieldContent.trim().length > 0) {
        url = '$url&Searchtext=${searchFieldContent.trim().toUpperCase()}';
      }

      http.Client client = http.Client();
      final response = await client.get(url, headers: {
        "token": await Session.getData(Session.accessToken),
        "Username": await Session.getData(Session.userName),
      }).timeout(duration);
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        companyData =
            data.map<Company>((json) => Company.fromJson(json)).toList();
      }
      return companyData;
    } catch (e) {
      print('Error inside fetchCompanies fn');
      print(e);
      throw Future.error(e);
    }
  }

  ///IT FETCHES THE CURRENCY STANDARD FIELD
  void fetchCurrencyStandardField() {
    ApiService.getCurrencyStandardDropdownFields()
        .then((value) => {
              if (value.length > 0)
                {
                  _currencyCaption = value[0],
                }
              else
                print('No StandardFields received for the Currency '),
            })
        .catchError((err) {
      print('Error while fetching Currency Standard fields');
      print(err);
    });
  }

  ///IT FETCHES THE STANDARD FIELDS FOR ON_GRID_SHOW FIELDS SHOW IN LIST UI
  void fetchCompanyStandardFields() {
    ApiService.getStandardFields(
            entity: StandardEntity.COMPANY,
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
                  }),
                  _commonWidgets.showFlutterToast(
                      toastMsg: ConnectionStatus.NetworkNotAvailble),
                }
            })
        .catchError((onError) => {
              print(
                  'Error while fetching OnGrid StandardFields for the Company Entity'),
              print(onError)
            });
  }

  ///IT FETCHES THE STANDARD FIELDS FOR ON_GRID_SHOW FIELDS SHOW IN LIST UI
  void fetchCompanyDetailStandardFields(int recordPosition) {
    ApiService.getStandardFields(
            entity: StandardEntity.COMPANY,
            showInGrid: true,
            showOnScreen: false)
        .then((value) => {
              print(
                  'fetchOrderDetailStandardFields Response received in CustomerProfiles Page'),

              ///HERE CHECKING IF STANDARD FIELDS RESPONSE DID'T RECEIVED THEN NOT CALLING THE GET_DATA_API
              if (value.length > 0)
                {
                  setState(() {
                    addressesOnGridStandardFields = value;
                  }),
                  fetchContactsStandardFields(recordPosition),
                }
              else
                {
                  setState(() {
                    isFullScreenLoading = false;
                  }),
                  showErrorToast(),
                }
            })
        .catchError((onError) => {
              print(
                  'Error while fetching OnGrid StandardFields for the Company Entity'),
              print(onError),
              showErrorToast(),
            });
  }

  ///IT FETCHES THE STANDARD FIELDS FOR ON_GRID_SHOW FIELDS SHOW IN LIST UI
  void fetchContactsStandardFields(int recordPosition) {
    ApiService.getStandardFields(
      entity: StandardEntity.PERSON,
      showInGrid: true,
      showOnScreen: false,
    )
        .then((value) => {
              print(
                  'fetchContactsStandardFields Response received in CustomerProfiles Page'),

              ///HERE CHECKING IF STANDARD FIELDS RESPONSE DID'T RECEIVED THEN NOT CALLING THE GET_DATA_API
              if (value.length > 0)
                {
                  setState(() {
                    contactsOnGridStandardFields = value;
                    isFullScreenLoading = false;
                  }),
                  Navigator.of(widget.parentBuildContext).push(
                    MaterialPageRoute(
                      builder: (context) => CompanyDetails(
                        companyData: companies[recordPosition],
                        contactsStandardFields: contactsOnGridStandardFields,
                        addressesStandardFields: addressesOnGridStandardFields,
                        currencyCaptionStandardField: _currencyCaption,
                      ),
                    ),
                  ),
                }
              else
                {
                  setState(() {
                    isFullScreenLoading = false;
                  }),
                  showErrorToast(),
                }
            })
        .catchError((onError) => {
              print(
                  'Error while fetching OnGrid StandardFields for the Company Entity'),
              print(onError),
              showErrorToast(),
            });
  }

  ///IT DELETES THE SELECTED COMPANY
  void handleDeleteCompany(recordPosition) async {
    try {
      setState(() {
        isFullScreenLoading = true;
      });
      String companyCode = companies[recordPosition].CustomerNo;
      String url =
          '${await Session.getData(Session.apiDomain)}/${URLs.DELETE_COMPANY}?CompanyCode=$companyCode';
      http.Client client = http.Client();
      final response = await client.get(url, headers: {
        "token": await Session.getData(Session.accessToken),
        "Username": await Session.getData(Session.userName)
      }).timeout(duration);
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
//        await Future.delayed(new Duration(seconds: 5));
        setState(() {
          isFullScreenLoading = false;
          companies.removeAt(recordPosition);
        });
        showSuccessToast('Company Deleted Successfully.');
      } else {
        setState(() {
          isFullScreenLoading = false;
        });
        showErrorToast();
      }
    } catch (e) {
      print('Error inside handleDeleteCompany Fn');
      print(e);
      setState(() {
        isFullScreenLoading = false;
      });
      showErrorToast();
    }
  }

  ///IT SHOWS THE ERROR TOAST IF ANY ERROR OCCURS BEFORE NAVIGATING TO THE CUSTOMER DETAILS PAGE
  void showErrorToast() {
    _commonWidgets.showFlutterToast(toastMsg: "Try Again Later!");
  }

  ///IT SHOWS THE ERROR TOAST IF ANY ERROR OCCURS BEFORE NAVIGATING TO THE CUSTOMER DETAILS PAGE
  void showSuccessToast(String msg) {
    _commonWidgets.showFlutterToast(toastMsg: '$msg');
  }

  ///IT GETS CALLS THE FETCH_COMPANIES FUNCTION FOR INITIAL LOAD AND FOR PAGINATION ALSO
  void dataFetch() {
    if (isNextButtonPressed == true && lastPageNumber != pageNumber) {
      pageNumber = pageNumber + 1;
    } else if (isPreviousButtonPressed == true) {
      if (pageNumber > 1) {
        pageNumber = pageNumber - 1;
        if (pageNumber == 1) {
          isPreviousButtonDisabled = true;
        }
      }
    }
    pageSize =
        isLargeScreen ? Pagination.TABLE_PAGE_SIZE : Pagination.LIST_PAGE_SIZE;
    fetchCompanies().then((companiesDataRes) => {
          print('fetchCompanies response'),
          setState(() {
            int newRecordCount = companiesDataRes.length;
            companies.clear();
            companies.addAll(companiesDataRes);
            companies.sort((a, b) => a.CustomerNo.compareTo(b.CustomerNo));
            isShowLoader = false;
            if (newRecordCount < pageSize) {
              isNextButtonDisabled = true;
              lastPageNumber = pageNumber;
              if (isPreviousButtonDisabled == true) {
                isShowPaginationButtons = false;
              } else {
                isShowPaginationButtons = true;
              }
            } else {
              isShowPaginationButtons = true;
              isNextButtonDisabled = false;
              lastPageNumber = 0;
            }
          })
        });
  }

  ///IT HANDLES THE SEARCH_TEXT_FIELD SEARCH CLICK CHANGES AND LOADS THE NEW DATA ACCORDINGLY
  void handleTextFieldSearch(String searchText) {
    setState(() {
      searchFieldContent = searchText;
    });
    loadNewSearchData();
  }

  ///IT HANDLES THE SEARCH_TEXT_FIELD CANCEL/CLEAR CLICK CHANGES AND LOADS THE NEW DATA ACCORDINGLY
  void clearTextFieldSearch() {
    setState(() {
      searchFieldContent = '';
    });
    loadNewSearchData();
  }

  ///IT CALLS THE DATA_FETCH FUNCTION TO LOAD THE NEW LIST AS PER SEARCH PARAMETERS ALSO
  ///IT CLEARS THE EXISTING STATES
  void loadNewSearchData() {
    setState(() {
      companies.clear();
      pageNumber = 1;
      isShowLoader = true;
      isNextButtonPressed = false;
      isPreviousButtonPressed = false;
      isNextButtonDisabled = false;
      isPreviousButtonDisabled = true;
      lastPageNumber = 0;
    });
    dataFetch();
  }

  ///IT HANDLES THE DETAILS PAGE NAVIGATION
  void handleDetailsPageNavigation(int recordPosition) {
    ///SETTING SHOW LOADING STATE TRUE FOR DETAILS PAGE STATE
    setState(() {
      isFullScreenLoading = true;
      addressesOnGridStandardFields = List<StandardField>();
      contactsOnGridStandardFields = List<StandardField>();
    });

    ///FETCHING THE STANDARD_FIELDS FOR THE DETAILS PAGE ON_GRID FIELDS DISPLAY
    fetchCompanyDetailStandardFields(recordPosition);
  }

  ///IT OPENS THE DELETE COMPANY DIALOG
  void showDeleteCompanyDialog(recordPosition) {
    showDialog(
      useRootNavigator: true,
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        actions: <Widget>[
          RaisedButton(
            onPressed: () {
              handleDeleteCompany(recordPosition);
              Navigator.of(context, rootNavigator: true).pop('PopupCLosed');
            },
            color: AppColors.blue,
            child: Text('OK'),
          ),
          RaisedButton(
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop('PopupCLosed');
            },
            child: Text('Cancel'),
          ),
        ],
        content: Text(
            'All users and cases associated with company are going to be deleted. Click OK to continue '),
      ),
    );
  }

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
  ///       KEEP ONLY THREE BUTTONS INSIDE THE SINGLE ROW
  ///       OTHERWISE IT'LL LOOK CONJESTED IN THE LIST VIEW
  List<Row> getActionButtonRows(int recordPosition) {
    List<Row> rowsList = List<Row>();

    ///ADDING THE FIRST ROW WITH ONE BUTTON FOR THE NAVIGATION
    rowsList.add(
      Row(
        children: <Widget>[
          getActionButton('View Details', recordPosition,
              handleDetailsPageNavigation, AppColors.blue),
          //getActionButton(
          //    'Delete', recordPosition, showDeleteCompanyDialog, Colors.red)
        ],
      ),
    );
    return rowsList;
  }

  ///IT RETURNS THE COMPANY_PROFILES LIST
  Widget _buildList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: ScrollPhysics(),
      itemCount: companies.length,
      padding: const EdgeInsets.all(15.0),
      itemBuilder: (context, position) {
        return Container(
          child: ListViewRows(
            standardFields: onGridStandardFields,
            recordObj: companies[position],
            recordPosition: position,
            isActionsEnabled: true,
            isEntitySectionCheckDisabled: true,
            actionButtonRows: getActionButtonRows(position),
            showOnGridFields: true,
            isExcludedFieldEnabled: false,
            currencyCaption: _currencyCaption.Caption != null
                ? _currencyCaption.Caption
                : null,
          ),
        );
      },
    );
  }

  //For large screen
  Widget _buildTable() {
    return Container(
      child: companies.length > 0
          ? TableView(
              standardFields: onGridStandardFields,
              isActionsEnabled: true,
              isEntitySectionCheckDisabled: true,
              actionButtonRows: getActionButtonRows,
              showOnGridFields: true,
              isExcludedFieldEnabled: false,
              isCheckBoxVisible: false,
              currencyCaption: _currencyCaption.Caption != null
                  ? _currencyCaption.Caption
                  : null,
              ListObject: companies)
          : Text(''),
    );
  }

  @override
  Widget build(BuildContext context) {
    isLargeScreen = isLargeScreenAvailable(context);
    return ModalProgressHUD(
      inAsyncCall: isFullScreenLoading,
      opacity: FullScreenLoader.OPACITY,
      progressIndicator: FullScreenLoader.PROGRESS_INDICATOR,
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppBarTitles.CUSTOMER_PROFILES),
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(widget.parentBuildContext);
              }),
        ),

        ///NOTIFICATION LISTENER ADDED TO LISTEN TO THE BOTTOM PAGE SCROLL
        ///TO LOAD NEW PAGE DATA FROM API
        body: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Visibility(
              visible: widget.selectedCompany == null ||
                  widget.selectedCompany.CustomerNo == '',
              child: SearchTextField(
                searchFieldContent: searchFieldContent,
                clearTextFieldSearch: clearTextFieldSearch,
                handleTextFieldSearch: handleTextFieldSearch,
                placeHolder: 'Search Customer',
              ),
            ),
            SizedBox(height: 5.0),

            ///FIRST TIME LOADING DATA LOADER
            _commonWidgets.showCommonLoader(isLoaderVisible: isShowLoader),

            ///IT SHOWS THE NO DATA PRESENT MESSAGE
            _commonWidgets.buildEmptyDataWidget(
              textMsg: 'No Data Found!',
              isVisible: companies.length < 1 && !isShowLoader,
            ),

            ///BUILDS CUSTOMERS/COMPANIES LIST
            isLargeScreen ? _buildTable() : _buildList(),
          ],
        ),
        bottomNavigationBar: BottomAppBar(
          child: Visibility(
            visible: isShowPaginationButtons,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 10.0),
              child: Row(
                //crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                    child: RaisedButton(
                      onPressed: isPreviousButtonDisabled == true
                          ? null
                          : () {
                              setState(() {
                                isPreviousButtonPressed = true;
                                isNextButtonPressed = false;
                                dataFetch();
                                isNextButtonDisabled = false;
                              });
                            },
                      color: Colors.blue,
                      child: Icon(
                        Icons.navigate_before,
                        color: Colors.white,
                      ),
//                        child: Text(
//                          'Previous',
//                          style: TextStyle(color: Colors.white),
//                        ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                    child: RaisedButton(
                      onPressed: isNextButtonDisabled == true
                          ? null
                          : () {
                              setState(() {
                                isNextButtonDisabled = true;
                                isNextButtonPressed = true;
                                isPreviousButtonPressed = false;
                                dataFetch();
                                isPreviousButtonDisabled = false;
                              });
                            },
                      color: Colors.blue,
//                        child: Text(
//                          'Next',
//                          style: TextStyle(color: Colors.white),
//                        ),
                      child: Icon(
                        Icons.navigate_next,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
