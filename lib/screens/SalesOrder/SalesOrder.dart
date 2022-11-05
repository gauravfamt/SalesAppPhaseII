import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:moblesales/helpers/index.dart';
import 'package:moblesales/models/index.dart';
import 'package:moblesales/screens/index.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class SalesOrder extends StatelessWidget {
  Company company;

  SalesOrder({
    Key key,
    this.company,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SalesOrderPage(
        parentBuildContext: context,
        selectedCompany: company,
      ),
    );
  }
}

class SalesOrderPage extends StatefulWidget {
  final BuildContext parentBuildContext;
  final Company selectedCompany;

  SalesOrderPage(
      {Key key, @required this.parentBuildContext, this.selectedCompany})
      : super(key: key);

  @override
  _SalesOrderPageState createState() => _SalesOrderPageState();
}

class _SalesOrderPageState extends State<SalesOrderPage> {
  ///IT HOLDS ALL THE COMMON REUSABLE WIDGETS WHICH CAN BE USED THROUGH OUT PROJECT
  CommonWidgets _commonWidgets;

  ///USED TO HANDLE THE FULLSCREEN_LOADER JUST SET THE STATE TO THE TRUE TO START
  bool isFullScreenLoading;

  ///HOLDS STANDARD_FIELDS FOR THE ORDER_HEADER ENTITY
  List<StandardField> onGridStandardFields;

  ///HOLDS STANDARD_FIELDS FOR THE ORDER_DETAIL ENTITY
  List<StandardField> detailsOnScreenStandardFields;

  ///HOLDS STANDARD_FIELDS FOR THE ORDER_HEADER ENTITY
  List<StandardField> headerOnScreenStandardFields;

  ///HOLDS ALL THE SALES_ORDERS LIST
  List<SalesOrders> salesOrders;

  ///HOLDS ALL THE SALES_ORDERS LIST WHICH ARE SELECTED FOR THE SEND_MAIL
  List<SalesOrders> sendMailSalesOrdersList;

  ///HOLDS ALL THE DELIVERY STATUSES LIST FOR THE ADVANCED SEARCH OPTION
  List<StandardDropDownField> deliveryStatusList;

  ///HOLDS THE ORDER_DELIVERY_STATUS FOR ADVANCED SEARCH DROPDOWN FILTERING
  StandardDropDownField _selectedDeliveryStatus;

  ///HOLDS THE CURRENCY_CAPTION STANDARD FIELD
  StandardDropDownField _currencyCaption;

  ///HOLDS THE SELECTED COMPANY / CUSTOMER FOR THE ADVANCED SEARCH
  Company _selectedCompany;

  ///HANDLES THE SEARCH_TEXT_FIELD CONTENT
  String searchFieldContent;

  ///TO SHOW THE LOADER BELOW THE ADVANCED SEARCH OPTION
  bool isShowLoader;

  ///API PAGES PARAMETER
  int pageNumber;
  int pageSize;

  //for Data table
  bool isLargeScreen;

  ///NETWORK_CONNECTION STREAM SUBSCRIPTION TO GET UPDATES WHEN APP IS ONLINE OR OFFLINE
  StreamSubscription _connectionChangeStream;

  ///HOLDS APP ONLINE/OFFLINE STATUS
  bool isOffline;

  //To handle pagination wise data
  bool isNextButtonPressed;
  bool isPreviousButtonPressed;
  bool isNextButtonDisabled;
  bool isPreviousButtonDisabled;
  bool isShowPaginationButtons;
  int lastPageNumber;

  @override
  void initState() {
    super.initState();
    isShowLoader = true;
    pageNumber = 1;
    pageSize = Pagination.LIST_PAGE_SIZE;
    _commonWidgets = CommonWidgets();
    salesOrders = List<SalesOrders>();
    sendMailSalesOrdersList = List<SalesOrders>();
    deliveryStatusList = buildDeliveryDropdownList();
    _selectedDeliveryStatus = deliveryStatusList[0];
//    _selectedCompany = null;
    _selectedCompany = widget.selectedCompany;
    searchFieldContent = null;
    onGridStandardFields = List<StandardField>();
    detailsOnScreenStandardFields = List<StandardField>();
    headerOnScreenStandardFields = List<StandardField>();
    isFullScreenLoading = false;
    _currencyCaption = StandardDropDownField();

    isNextButtonDisabled = false;
    isPreviousButtonDisabled = true; //Initialy on 1 page
    isShowPaginationButtons = true;
    lastPageNumber = 0;
    isOffline = ConnectionStatus.isOffline;

    ///GETTING CONNECTION_SERVICE SINGLETON INSTANCE AND SUBSCRIBING TO CONNECTION_CHANGE EVENTS
    ConnectivityService connectionStatus = ConnectivityService.getInstance();
    _connectionChangeStream =
        connectionStatus.connectionChange.listen(connectionChanged);

    fetchCurrencyStandardField();
    fetchStandardStatusDropDownFields();
    fetchOrderHeaderOnGridStandardFields();
  }

  @override
  void dispose() {
    super.dispose();
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

  ///It makes the http Request for fetching the salesOrders
  Future<List<SalesOrders>> fetchSalesOrders() async {
    try {
      var salesOrdersData = List<SalesOrders>();
      String url =
          '${await Session.getData(Session.apiDomain)}/${URLs.GET_SALES_ORDERS}?pageNumber=$pageNumber&pageSize=$pageSize';
      if (_selectedCompany != null) {
        url = '$url&CustomerNo=${_selectedCompany.CustomerNo}';
      }
      if (_selectedDeliveryStatus.Code != '') {
        url = '$url&Status=${_selectedDeliveryStatus.Code}';
      }
      if (searchFieldContent != null && searchFieldContent.trim().length > 0) {
        url = '$url&Searchtext=${searchFieldContent.trim().toUpperCase()}';
      }
      http.Client client = http.Client();
      final response = await client.get(url, headers: {
        "token": await Session.getData(Session.accessToken),
        "Username": await Session.getData(Session.userName),
      }).timeout(duration);
      print(url);
      if (response.statusCode == 200 && response.body != "No Orders found") {
        print(response.body);
        var data = json.decode(response.body);
        if (data != 'No Orders found') {
          salesOrdersData = data .map<SalesOrders>((json) => SalesOrders.fromJson(json)).toList();
        }
      }
      return salesOrdersData;
    } catch (e) {
      print('Error inside fetchSalesOrders FN');
      print(e);
      throw Future.error(e);
    }
  }

  ///IT FETCHES THE STANDARD FIELDS FOR ON_GRID_SHOW FIELDS SHOW IN LIST UI
  void fetchOrderHeaderOnGridStandardFields() {
    ApiService.getStandardFields(
      entity: StandardEntity.ORDER_HEADER,
      showInGrid: true,
      showOnScreen: false,
    )
        .then((value) => {
              ///HERE CHECKING IF STANDARD FIELDS RESPONSE DID'T RECEIVED THEN NOT CALLING THE GET_DATA_API
              if (value.length > 0)
                {
                  value.sort((a, b) => a.SortOrder.compareTo(b.SortOrder)),
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
                  'Error while fetching OnGrid StandardFields for the OrderHeader Entity'),
              print(onError)
            });
  }

  ///IT FETCHES THE STANDARD FIELDS FOR ON_GRID_SHOW FIELDS SHOW IN LIST UI
  void fetchOrderDetailStandardFields(int recordPosition) {
    ApiService.getStandardFields(
      entity: StandardEntity.ORDER_DETAIL,
      showInGrid: false,
      showOnScreen: true,
    )
        .then((value) => {
              ///HERE CHECKING IF STANDARD FIELDS RESPONSE DID'T RECEIVED THEN NOT CALLING THE GET_DATA_API
              if (value.length > 0)
                {
                  value.sort((a, b) => a.SortOrder.compareTo(b.SortOrder)),
                  setState(() {
                    detailsOnScreenStandardFields = value;
                  }),

                  ///FETCHING ON_SCREEN STANDARD FIELDS FOR THE ORDER_HEADER ENTITY
                  fetchOrderHeaderOnScreenStandardFields(recordPosition),
                }
              else
                {
                  setState(() {
                    isFullScreenLoading = false;
                  }),
                }
            })
        .catchError((onError) => {
              print(
                  'Error while fetching OnGrid StandardFields for the OrderDetail Entity'),
              print(onError),
              setState(() {
                isFullScreenLoading = false;
              }),
            });
  }

  ///IT FETCHES THE STANDARD_DROPDOWN_FIELDS FOR DELIVERY_STATUS DROPDOWN
  void fetchStandardStatusDropDownFields() {
    try {
      ApiService.getStandardDropdownFields(
        entity: StandardEntity.ORDER_DROPDOWN_ENTITY,
        searchText: DropdownSearchText.ORDER_DROPDOWN_SEARCH_TEXT,
      ).then((value) => {
            if (value.length > 0)
              {
                this.setState(() {
                  deliveryStatusList.addAll(value);
                }),
              }
          });
    } catch (e) {
      print(
          'Error While fetching DropDownValues in fetchStandardStatusDropDownFields FN');
      print(e);
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
  void fetchOrderHeaderOnScreenStandardFields(int recordPosition) {
    try {
      ApiService.getStandardFields(
        entity: StandardEntity.ORDER_HEADER,
        showInGrid: false,
        showOnScreen: true,
      )
          .then((value) => {
                print(
                    'fetchOrderHeaderOnScreenStandardFields Response received in SalesOrder Page'),

                ///HERE CHECKING IF STANDARD FIELDS RESPONSE DID'T RECEIVED THEN NOT CALLING THE GET_DATA_API
                if (value.length > 0)
                  {
                    value.sort((a, b) => a.SortOrder.compareTo(b.SortOrder)),
                    setState(() {
                      headerOnScreenStandardFields = value;
                      isFullScreenLoading = false;
                    }),

                    ///NAVIGATING TO THE SALES_ORDER_DETAILS PAGE
                    Navigator.of(widget.parentBuildContext)
                        .push(
                          MaterialPageRoute(
                            builder: (context) => SalesOrderDetails(
                              salesOrderObj: salesOrders[recordPosition],
                              detailsOnScreenStandardFields:
                                  detailsOnScreenStandardFields,
                              headerOnScreenStandardFields:
                                  headerOnScreenStandardFields,
                              currencyCaptionSF: _currencyCaption,
                            ),
                          ),
                        )
                        .whenComplete(() => {
                              print('Details Page back closed'),
                            }),
                  }
                else
                  {
                    setState(() {
                      isFullScreenLoading = false;
                    }),
                  }
              })
          .catchError((onError) => {
                print(
                    'Error while fetching OnGrid StandardFields for the OrderDetail Entity'),
                print(onError),
                setState(() {
                  isFullScreenLoading = false;
                }),
              });
    } catch (e) {
      print('Error inside fetchOrderHeaderOnScreenStandardFields ');
      print(e);
      setState(() {
        isFullScreenLoading = false;
      });
    }
  }

  ///It fetches the initial data for the companies state
  void dataFetch() {
    if (isNextButtonPressed == true && pageNumber != lastPageNumber) {
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
    isOffline == true
        ? _commonWidgets.showFlutterToast(
            toastMsg: ConnectionStatus.NetworkNotAvailble)
        : fetchSalesOrders()
            .then((salesOrderDataRes) => {
                  setState(() {
                    ///HERE salesOrderDataRes CONTAINS THE PAGE WISE RESPONSE FOR THE SALES_ORDERS_LIST
                    int newRecordCount = salesOrderDataRes.length;
                    salesOrders.clear();
                    salesOrders.addAll(salesOrderDataRes);
                    isShowLoader = false;
                    if (newRecordCount < pageSize) {
                      lastPageNumber = pageNumber;
                      isNextButtonDisabled = true;
                      if (isPreviousButtonDisabled == true) {
                        isShowPaginationButtons = false;
                      } else {
                        isShowPaginationButtons = true;
                      }
                    } else {
                      isNextButtonDisabled = false;
                      lastPageNumber = 0;
                      if (newRecordCount == 0) {
                        isShowPaginationButtons = false;
                      } else {
                        isShowPaginationButtons = true;
                      }
                    }
                  })
                })
            .catchError((onError) => {
                  setState(() {
                    isShowLoader = false;
                  }),
                });
  }

  ///It closes the CompanySearch Dialog On CLose Btn click
  void closeSearchDialog() {
    print('closeSearchDialog called of the SalesOrders page');
  }

  ///It handles the Selected Company Response for the search
  void handleCustomerSelectedSearch(Company selectedCompany) {
    print('Inside handleCustomerSelectedSearch fn of salesOrder Page');
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

  ///It handles the OrderDelivery status changes and Loads the new data accordingly
  void handleDeliveryStatusChange(
      StandardDropDownField selectedDeliveryStatus) {
    setState(() {
      _selectedDeliveryStatus = selectedDeliveryStatus;
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
      salesOrders.clear(); //= List<SalesOrders>();
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

  ///IT SHOWS THE CUSTOMER_SEARCH DIALOG FOR SELECTING THE CUSTOMER FOR THE
  ///FILTERING LISTING ACCORDING TO THE CUSTOMER_NO
  void showCompanyDialog() {
    showDialog(
        useRootNavigator: true,
        barrierDismissible: false,
        context: context,
        builder: (context) => CustomerSearchDialog(
              handleCustomerSelectedSearch: this.handleCustomerSelectedSearch,
              closeSearchDialog: this.closeSearchDialog,
              forLookupType: true,
            ));
  }

  ///IT SETS THE DEFAULT ENTRY FOR THE DROP_DOWN_WIDGET CONTENTS LIST
  List<StandardDropDownField> buildDeliveryDropdownList() {
    List<StandardDropDownField> listItems = [
      ///ADDING THE DEFAULT DROPDOWN VALUE i.e. --SELECT-- OPTION
      StandardDropDownField(
        Caption: '--Select--',
        Code: '',
        Dropdown: DropdownSearchText.ORDER_DROPDOWN_SEARCH_TEXT,
        Entity: StandardEntity.ORDER_DROPDOWN_ENTITY,
        Id: 0,
        TenantId: 0,
      ),
    ];
    return listItems;
  }

  ///It returns the search bar Widget for the SalesOrders list screen
  Widget _buildDeliveryStatusDropdown() {
    List<DropdownMenuItem<StandardDropDownField>> dropDownMenuItems = List();
    deliveryStatusList.forEach(
      (element) {
        dropDownMenuItems.add(
          DropdownMenuItem(
            child: Text(
              '${element.Caption}',
              style: TextStyle(color: AppColors.black, fontSize: 15.0),
            ),
            value: element,
          ),
        );
      },
    );

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 0.0),
        child: Card(
          elevation: 0.0,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  'Status',
                  style: TextStyle(color: AppColors.grey, fontSize: 15.0),
                ),
                SizedBox(
                  height: 10.0,
                ),
                DropdownButton(
                  value: _selectedDeliveryStatus,
                  items: dropDownMenuItems,
                  onChanged: (StandardDropDownField selectedItem) {
                    if (selectedItem.Caption !=
                        _selectedDeliveryStatus.Caption) {
                      handleDeliveryStatusChange(selectedItem);
                    } else {
                      print('Already Selected Delivery State Selected ');
                    }
                  },
                  isExpanded: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ///It handles the Details Page Navigation
  void handleDetailsPageNavigation(int recordPosition) {
    ///SETTING SHOW LOADING STATE TRUE FOR DETAILS PAGE STATE
    setState(() {
      isFullScreenLoading = true;
      detailsOnScreenStandardFields = List<StandardField>();
      headerOnScreenStandardFields = List<StandardField>();
    });

    ///FETCHING THE STANDARD_FIELDS FOR THE DETAILS PAGE ON_GRID FIELDS DISPLAY
    fetchOrderDetailStandardFields(recordPosition);
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
  ///       KEEP ONLY TWO BUTTONS INSIDE THE SINGLE ROW
  ///       OTHERWISE IT'LL LOOK CONJESTED IN THE LIST VIEW
  List<Row> getActionButtonRows(int recordPosition) {
    List<Row> rowsList = List<Row>();

    ///ADDING THE FIRST ROW WITH ONE BUTTON FOR THE NAVIGATION
    rowsList.add(
      Row(
        children: <Widget>[
          getActionButton('View Details', recordPosition,
              handleDetailsPageNavigation, AppColors.blue),
        ],
      ),
    );
    return rowsList;
  }

  ///IT HANDLES CHECKBOX_SELECTIONS FOR THE SEND_MAIL FUNCTIONALITY
  void handleCheckBoxOnChange(bool isCheckedValue, int rowPosition) {
    if (salesOrders[rowPosition].DeliveryStatus != 'NotShipped') {
      List<SalesOrders> tempSendMailSalesOrdersList = List<SalesOrders>();
      setState(() {
        salesOrders[rowPosition].isSelected = isCheckedValue;
        if (isCheckedValue) {
          ///ADDING SELECTED QUOTE TO SEND_MAIL_LIST
          sendMailSalesOrdersList.add(salesOrders[rowPosition]);
        } else {
          ///REMOVING DESELECTED QUOTE FROM THE SEND_MAIL_LIST
          sendMailSalesOrdersList.forEach((singleSalesOrderList) {
            if (singleSalesOrderList.DocumentNo !=
                salesOrders[rowPosition].DocumentNo)
              tempSendMailSalesOrdersList.add(singleSalesOrderList);
          });
          sendMailSalesOrdersList.clear();

          ///ADDING THE UPDATED SALES_QUOTE_SEND_MAIL_LIST
          if (tempSendMailSalesOrdersList.length > 0)
            sendMailSalesOrdersList.addAll(tempSendMailSalesOrdersList);
        }
      });
    } else {
      ///NOT_SHIPPED ORDERS WILL NOT BE SENT TO THE MAIL
      _commonWidgets.showFlutterToast(
          toastMsg: 'Not-Shipped Orders cannot be selected ');
    }
  }

  ///IT BUILDS THE ORDERS LIST
  Widget _buildList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: ScrollPhysics(),
      itemCount: salesOrders.length,
      padding: const EdgeInsets.all(15.0),
      //Complete ListView Outside padding
      itemBuilder: (context, position) {
        return Container(
          child: ListViewRows(
            standardFields: onGridStandardFields,
            recordObj: salesOrders[position],
            recordPosition: position,
            isActionsEnabled: true,
            actionButtonRows: getActionButtonRows(position),
            isEntitySectionCheckDisabled: true,
            showOnGridFields: true,
            isExcludedFieldEnabled: false,
            currencyCaption: _currencyCaption.Caption,
            isCheckBoxVisible: false,
//            handleCheckBoxOnChange: handleCheckBoxOnChange,//CHECKBOX CLICK HANDLER COMMENTED NOT NEEDED
          ),
        );
      },
    );
  }

  Widget _buildTable() {
    return Container(
      child: salesOrders.length > 0
          ? TableView(
              standardFields: onGridStandardFields,
              isActionsEnabled: true,
              isEntitySectionCheckDisabled: true,
              actionButtonRows: getActionButtonRows,
              showOnGridFields: true,
              isExcludedFieldEnabled: false,
              currencyCaption: _currencyCaption.Caption != null
                  ? _currencyCaption.Caption
                  : null,
              ListObject: salesOrders)
          : Text(''),
    );
  }

  Widget getButtonWidget({
    @required String buttonLabel,
    @required Function onPressedHandler,
    @required EdgeInsets buttonPadding,
  }) {
    return Expanded(
      child: RaisedButton(
        padding: buttonPadding,
        color: AppColors.blue,
        child: Text(
          '$buttonLabel',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.0,
          ),
        ),
        onPressed: onPressedHandler,
      ),
    );
  }

  ///IT OPENS PRODUCT LAST PRICE WIDGET
  Widget getFeatureButtonWidget() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0,0,20.0,0),
      child: Row(
        children: <Widget>[
          ///CHECK_PRICE_BUTTON
          getButtonWidget(
            buttonLabel: 'Check Last Price',
            onPressedHandler: () {
              showDialog(
                useRootNavigator: true,
                barrierDismissible: false,
                context: context,
                builder: (context) => ProductLastPriceLookup(),
              );
            },
          ),

          ///COMMENTED FOR NOT SHOWING BUTTON CURRENTLY
          ///SEND_MAIL_BUTTON
//          getButtonWidget(
//            buttonLabel: 'Send Mail',
//            onPressedHandler: () {
//              if (isOffline == true) {
//                _commonWidgets.showFlutterToast(
//                    toastMsg:
//                        'No internet connection detected, Try again later');
//              } else {
//                showSendMailDialog();
//              }
//            },
//            buttonPadding: const EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 0.0),
//          ),
        ],
      ),
    );
  }

  ///IT SHOWS THE SEND_MAIL SCREEN
  void showSendMailDialog() {
    try {
      String idsData = '';
      sendMailSalesOrdersList.forEach((element) {
        idsData += '${element.DocumentNo}|';
      });
      idsData = idsData.length > 0
          ? idsData.substring(0, idsData.lastIndexOf('|'))
          : '';

      showDialog(
        useRootNavigator: true,
        barrierDismissible: false,
        context: context,
        builder: (context) => SendMailDialog(
          forType: SendMailHelper.TEMPLATE_SALES_ORDER,
          closeSearchDialog: () {},
          resetSendMailData: resetSendMailData,
          idsData: idsData,
        ),
      );
    } catch (e) {
      print(
          'Error Inside showSendMailDialog FN while Opening the sendMailDialog ');
      print(e);
    }
  }

  ///IT RESETS THE SEND_MAIL DATA
  void resetSendMailData() {
    setState(() {
      salesOrders.forEach((element) {
        element.isSelected = false;
      });
      sendMailSalesOrdersList.clear();
      isFullScreenLoading = false;
    });
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
          title: Text(AppBarTitles.SALES_ORDERS),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(widget.parentBuildContext);
            },
          ),
        ),

        ///NOTIFICATION LISTENER ADDED TO LISTEN TO THE BOTTOM PAGE SCROLL
        ///TO LOAD NEW PAGE DATA FROM API
        body: Column(
          children: <Widget>[
            ///CUSTOMER SELECTOR WIDGET
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
              child: Card(
                elevation: 1,
                child: ExpansionTile(
                  initiallyExpanded: isLargeScreen ? true : false,
                  title:Text('Search Sales Order'),
                  children: <Widget>[ Column(
                    children: <Widget>[
                      Visibility(
                        visible: widget.selectedCompany == null ||
                            widget.selectedCompany.CustomerNo == '',
                        child: _commonWidgets.getListingCompanySelectorWidget(
                          showCompanyDialogHandler: this.showCompanyDialog,
                          clearSelectedCompanyHandler: this.clearSelectedCompany,
                          selectedCompany: this._selectedCompany,
                        ),
                      ),

                      ///STATUS DROPDOWN WIDGET
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[_buildDeliveryStatusDropdown()],
                      ),

                      ///SEARCH TEXT FIELD WIDGET TO HANDLE SEARCH
                      SearchTextField(
                        searchFieldContent: searchFieldContent,
                        clearTextFieldSearch: clearTextFieldSearch,
                        handleTextFieldSearch: handleTextFieldSearch,
                        placeHolder: 'Search Order',
                      ),
                    ],
                  )],
                ),
              ),
            ),

            ///LAST_PRICE_LOOKUP AND SEND MAIL FEATURE BUTTONS
            getFeatureButtonWidget(),

            ///FIRST TIME LOADING DATA LOADER
            Expanded(
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  _commonWidgets.showCommonLoader(
                      isLoaderVisible: isShowLoader),

                  ///IT SHOWS THE NO DATA PRESENT MESSAGE
                  _commonWidgets.buildEmptyDataWidget(
                    textMsg: 'No Data Found!',
                    isVisible: salesOrders.length < 1 && !isShowLoader,
                  ),

                  ///SALES ORDERS LIST
                  isLargeScreen ? _buildTable() : _buildList(),
                ],
              ),
            ),
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
                                isNextButtonPressed = true;
                                isPreviousButtonPressed = false;
                                isNextButtonDisabled = true;
                                dataFetch();
                                isPreviousButtonDisabled = false;
                              });
                            },
                      color: Colors.blue,
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
