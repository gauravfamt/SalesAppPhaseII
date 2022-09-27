import 'dart:convert';
import 'dart:async';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:moblesales/helpers/index.dart';
import 'package:moblesales/models/index.dart';
import 'package:moblesales/screens/index.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class Invoice extends StatelessWidget {
  Company company;

  Invoice({
    Key key,
    this.company,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return (MaterialApp(
      debugShowCheckedModeBanner: false,
      home: InvoicePage(
        parentBuildContext: context,
        selectedCompany: company,
      ),
    ));
  }
}

class InvoicePage extends StatefulWidget {
  final BuildContext parentBuildContext;
  final Company selectedCompany;

  InvoicePage(
      {Key key, @required this.parentBuildContext, this.selectedCompany})
      : super(key: key);

  @override
  InvoicePageState createState() => InvoicePageState();
}

class InvoicePageState extends State<InvoicePage> {
  ///IT HOLDS ALL THE COMMON REUSABLE WIDGETS WHICH CAN BE USED THROUGH OUT PROJECT
  CommonWidgets _commonWidgets;

  ///USED TO HANDLE THE FULLSCREEN_LOADER JUST SET THE STATE TO THE TRUE TO START
  bool isFullScreenLoading;

  ///HOLDS STANDARD_FIELDS FOR THE ORDER_HEADER ENTITY
  List<StandardField> onGridStandardFields;

  List<StandardField> headerOnScreenStandardFields;

  ///HOLDS STANDARD_FIELDS FOR THE ORDER_DETAIL ENTITY
  List<StandardField> detailsOnScreenStandardFields;

  ///HOLDS THE CURRENCY_CAPTION STANDARD FIELD
  StandardDropDownField _currencyCaption;

  ///IT HOLDS ALL THE INVOICES LIST
  List<Invoices> invoices;

  ///HANDLES THE SEARCH_TEXT_FIELD STATE FOR THE ADVANCED SEARCH
  String searchFieldContent;

  ///IT HOLDS THE INVOICES STATUSES LIST FOR SHOWING DROPDOWN OF THE ADVANCED SEARCH
  List<InvoiceStatus> invoiceStatusList;

  ///IT HOLDS THE SELECTED INVOICE LIST FOR THE ADVANCED SEARCH
  InvoiceStatus _selectedInvoiceStatus;

  ///IT HOLDS THE SELECTED COMPANY/CUSTOMER FOR THE ADVANCED SEARCH
  Company _selectedCompany;

  ///USED TO CONFIGURE VISIBILITY OF SEARCH LOADER DISPLAY BELOW SEARCH PANEL
  bool isShowLoader;

  List<Invoices> SendMailInvoiceList;

  ///API PARAMETER FOR PAGINATION PAGES
  int pageNumber;
  int pageSize;

  //for Data table
  bool isLargeScreen;

  StreamSubscription _connectionChangeStream;
  bool isOffline = false;

  //To handle pagination wise data
  bool isNextButtonPressed;
  bool isPreviousButtonPressed;
  bool isNextButtonDisabled;
  bool isPreviousButtonDisabled;
  bool isShowPaginationButtons;
  int maxAttachmentCount;
  int lastPageNumber;

  @override
  void initState() {
    super.initState();
    isShowLoader = true;
    pageNumber = 1;
    isOffline = ConnectionStatus.isOffline;
    pageSize = Pagination.LIST_PAGE_SIZE;
    invoices = List<Invoices>();
    _commonWidgets = CommonWidgets();
    invoiceStatusList = buildDeliveryDropdownList();
    _selectedInvoiceStatus = invoiceStatusList[0];
    _selectedCompany = widget.selectedCompany;
    searchFieldContent = null;
    onGridStandardFields = List<StandardField>();
    detailsOnScreenStandardFields = List<StandardField>();
    headerOnScreenStandardFields = List<StandardField>();

    _currencyCaption = StandardDropDownField();
    isFullScreenLoading = false;

    isNextButtonDisabled = false;
    isPreviousButtonDisabled = true; //Initialy on 1 page
    isShowPaginationButtons = true;
    SendMailInvoiceList = List<Invoices>();
    maxAttachmentCount = 1;
    lastPageNumber = 0;

    ///GETTING CONNECTION_SERVICE SINGLETON INSTANCE AND SUBSCRIBING TO CONNECTION_CHANGE EVENTS
    ConnectivityService connectionStatus = ConnectivityService.getInstance();
    _connectionChangeStream =
        connectionStatus.connectionChange.listen(connectionChanged);

    fetchCurrencyStandardField();
    fetchEmailFeature();
    fetchInvoiceHeaderStandardFields();
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

  void fetchEmailFeature() {
    ApiService.getEmailFeature()
        .then((value) => {
              print('fetchEmailFeature Response received '),

              ///HERE CHECKING IF STANDARD FIELDS RESPONSE DID'T RECEIVED THEN NOT CALLING THE GET_DATA_API
              if (value.length > 0)
                {
                  setState(() {
                    var EmilFeature = value
                        .where((singleField) => singleField.Name == 'Invoices')
                        .toList();
                    maxAttachmentCount =
                        int.parse(EmilFeature[0].StartingValue.toString());
                    // print('maxAttachmentCount $maxAttachmentCount');
                  }),
                }
            })
        .catchError((onError) => {
              print(
                  'Error while fetching OnGrid StandardFields for the InvoiceHeader Entity'),
              print(onError)
            });
  }

  ///IT FETCHES THE STANDARD FIELDS FOR ON_GRID_SHOW FIELDS SHOW IN LIST UI
  void fetchInvoiceHeaderStandardFields() {
    ApiService.getStandardFields(
            entity: StandardEntity.INVOICE_HEADER,
            showInGrid: true,
            showOnScreen: false)
        .then((value) => {
              if (value.length > 0)
                {
                  setState(() {
                    onGridStandardFields = value
                        .where((singleField) =>
                            singleField.Entity == StandardEntity.INVOICE_HEADER)
                        .toList();
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
                  'Error while fetching OnGrid StandardFields for the InvoiceHeader Entity'),
              print(onError)
            });
  }

  ///IT FETCHES THE STANDARD FIELDS FOR ON_GRID_SHOW FIELDS SHOW IN LIST UI
  void fetchInvoiceDetailStandardFields(int recordPosition) {
    ApiService.getStandardFields(
      entity: StandardEntity.INVOICE_DETAIL,
      showInGrid: false,
      showOnScreen: true,
    )
        .then((value) => {
              ///HERE CHECKING IF STANDARD FIELDS RESPONSE DID'T RECEIVED THEN NOT CALLING THE GET_DATA_API
              if (value.length > 0)
                {
                  setState(() {
                    detailsOnScreenStandardFields = value;
                  }),

                  ///FETCHING ON_SCREEN STANDARD FIELDS FOR THE ORDER_HEADER ENTITY
                  fetchInvoiceHeaderDetailStandardFields(recordPosition),
                }
              else
                {
                  setState(() {
                    isFullScreenLoading = false;
                  }),
                }
            })
        .catchError((onError) => {
              print(onError),
              setState(() {
                isFullScreenLoading = false;
              }),
            });
  }

  ///IT FETCHES THE STANDARD FIELDS FOR ON_GRID_SHOW FIELDS SHOW IN LIST UI
  void fetchInvoiceHeaderDetailStandardFields(int recordPosition) {
    ApiService.getStandardFields(
            entity: StandardEntity.INVOICE_HEADER,
            showInGrid: false,
            showOnScreen: true)
        .then((value) => {
              ///HERE CHECKING IF STANDARD FIELDS RESPONSE DID'T RECEIVED THEN NOT CALLING THE GET_DATA_API
              if (value.length > 0)
                {
                  setState(() {
                    headerOnScreenStandardFields = value
                        .where((singleField) =>
                            singleField.Entity == StandardEntity.INVOICE_HEADER)
                        .toList();
                    ;
                    isFullScreenLoading = false;
                  }),

                  ///NAVIGATING TO THE SALES_ORDER_DETAILS PAGE
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => InvoiceDetailsPage(
                        invoiceObj: invoices[recordPosition],
                        headerOnScreenStandardFields:
                            headerOnScreenStandardFields,
                        detailsOnScreenStandardFields:
                            detailsOnScreenStandardFields,
                        currencyCaptionSF: _currencyCaption,
                      ),
                    ),
                  ),
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
                  'Error while fetching OnGrid StandardFields for the InvoiceHeader Entity'),
              print(onError)
            });
  }

  ///It fetches the initial data for the companies state
  void dataFetch() {
    if (_selectedCompany != null && _selectedCompany.CustomerNo != '') {}
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
        : ApiService.fetchInvoices(
            pageNumber: pageNumber,
            pageSize: pageSize,
            customerNo:
                _selectedCompany != null && _selectedCompany.CustomerNo != null
                    ? _selectedCompany.CustomerNo
                    : '',
            searchFieldContent: searchFieldContent,
            selectedInvoiceStatusKey: _selectedInvoiceStatus != null &&
                    _selectedInvoiceStatus.key != 'ALL'
                ? _selectedInvoiceStatus.value
                : '',
          )
            .then((invoicesDataRes) => {
                  setState(() {
                    // pageNumber = pageNumber + 1; //<--To get next record set
                    int newRecordCount = invoicesDataRes.length;
                    invoices.clear();
                    invoices.addAll(invoicesDataRes);
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
                      isShowPaginationButtons = true;
                      isNextButtonDisabled = false;
                      lastPageNumber = 0;
                    }

                    //Configure checkbox on pagination
                    if (SendMailInvoiceList != null &&
                        invoices != null &&
                        SendMailInvoiceList.length > 0 &&
                        SendMailInvoiceList.length > 0) {
                      for (int i = 0; i < invoices.length; i++) {
                        var invoice = SendMailInvoiceList.firstWhere(
                            (e) => e.DocumentNo == invoices[i].DocumentNo,
                            orElse: () => null);
                        if (invoice != null) {
                          invoices[i].IsSelected = true;
                        } else {
                          invoices[i].IsSelected = false;
                        }
                      }
                    }
                  })
                })
            .catchError((e) => {
                  setState(() {
                    isShowLoader = false;
                  }),
                  _commonWidgets.showFlutterToast(toastMsg: 'No more data'),
                });
  }

  ///IT RETURNS THE DROP_DOWN_WIDGET CONTENTS LIST
  List<InvoiceStatus> buildDeliveryDropdownList() {
    List<InvoiceStatus> listItems = [
      InvoiceStatus(key: 'ALL', value: 'Select', index: 0),
      InvoiceStatus(key: 'OPEN', value: 'Open', index: 1),
      InvoiceStatus(key: 'PAID', value: 'Paid', index: 2),
    ];
    return listItems;
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

  ///It handles the Invoice status changes and Loads the new data accordingly
  void handleInvoiceStatusChange(InvoiceStatus selectedInvoiceStatus) {
    setState(() {
      _selectedInvoiceStatus = selectedInvoiceStatus;
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
      invoices.clear();
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
            ));
  }

  ///It returns the search bar Widget for the InvoiceStatus list screen
  Widget _buildInvoiceStatusDropdown() {
    List<DropdownMenuItem<InvoiceStatus>> dropDownMenuItems = List();
    invoiceStatusList.forEach((element) {
      dropDownMenuItems.add(
        DropdownMenuItem(
          child: Text(
            '${element.value}',
            style: TextStyle(color: AppColors.black, fontSize: 15.0),
          ),
          value: element,
        ),
      );
    });

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 0.0),
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
                  value: _selectedInvoiceStatus,
                  items: dropDownMenuItems,
                  onChanged: (selectedItem) {
                    if (selectedItem.key != _selectedInvoiceStatus.key) {
                      handleInvoiceStatusChange(selectedItem);
                    } else {
                      print('Already Selected Invoice State Selected ');
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

  ///IT HANDLES THE DETAILS PAGE NAVIGATION
  void handleDetailsPageNavigation(int recordPosition) {
    ///SETTING SHOW LOADING STATE TRUE FOR DETAILS PAGE STATE
    setState(() {
      isFullScreenLoading = true;
      headerOnScreenStandardFields = List<StandardField>();
      detailsOnScreenStandardFields = List<StandardField>();
    });

    ///FETCHING THE STANDARD_FIELDS FOR THE DETAILS PAGE ON_GRID FIELDS DISPLAY
    fetchInvoiceDetailStandardFields(recordPosition);
  }

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
  bool isMaxInvoiceLimitRech = false;
  void handleCheckBoxOnChange(bool isCheckedValue, int rowPosition) {
    setState(() {
      invoices[rowPosition].IsSelected = isCheckedValue;
      if (isCheckedValue) {
        if (isMaxInvoiceLimitRech == false) {
          SendMailInvoiceList.add(invoices[rowPosition]);
        } else {
          if (maxAttachmentCount == 1) {
            _commonWidgets.showAlertMsg(
                alertMsg: "Can't send more than ${maxAttachmentCount} invoice",
                MessageType: AlertMessageType.INFO,
                context: context);
          } else {
            _commonWidgets.showAlertMsg(
                alertMsg: "Can't send more than ${maxAttachmentCount} invoices",
                MessageType: AlertMessageType.INFO,
                context: context);
          }

          invoices[rowPosition].IsSelected = false;
        }
      } else {
        if (SendMailInvoiceList != null && SendMailInvoiceList.length > 0) {
          SendMailInvoiceList.removeWhere((element) =>
              element.DocumentNo == invoices[rowPosition].DocumentNo);
        }
      }
      setState(() {
        if (SendMailInvoiceList.length == maxAttachmentCount) {
          isMaxInvoiceLimitRech = true;
        } else {
          isMaxInvoiceLimitRech = false;
        }
      });
    });
  }

  ///IT GENERATES THE INVOICE LIST VIEW
  Widget _buildList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: ScrollPhysics(),
      itemCount: invoices.length,
      padding: const EdgeInsets.all(15.0),
      itemBuilder: (context, position) {
        return Container(
          child: ListViewRows(
            standardFields: onGridStandardFields,
            recordObj: invoices[position],
            recordPosition: position,
            isActionsEnabled: true,
            isEntitySectionCheckDisabled: true,
            actionButtonRows: getActionButtonRows(position),
            showOnGridFields: true,
            isExcludedFieldEnabled: false,
            isCheckBoxVisible: true,
            currencyCaption: _currencyCaption.Caption,
            handleCheckBoxOnChange: handleCheckBoxOnChange,
          ),
        );
      },
    );
  }

  Widget getButtonWidget({
    @required String buttonLabel,
    @required Function onPressedHandler,
    @required EdgeInsets buttonPadding,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 0.0, 5.0, 0.0),
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
      ),
    );
  }

  Widget getFeatureButtonButtonWidget() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0,0,20.0,0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: RaisedButton(
              color: AppColors.blue,
              onPressed: () {
                if (SendMailInvoiceList.length < 1) {
                  _commonWidgets.showAlertMsg(
                      alertMsg: 'Select at least one invoice for sending mail',
                      context: context,
                      MessageType: AlertMessageType.INFO);
                } else if (isOffline == true) {
                  _commonWidgets.showFlutterToast(
                      toastMsg: ConnectionStatus.NetworkNotAvailble);
                  resetSendMailData();
                } else {
                  showSendMailDialog();
                }
              },
              child: Text(
                'Send Mail',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  //Method updated by Mayuresh, For fetching emails as requested in Phase II, 07-21-2022
  void showSendMailDialog() {
    try {
      String idsData = '';
      String customerIdsData = '';
      List<String> customerIds = [];
      SendMailInvoiceList.forEach((element) {
        idsData += '${element.DocumentNo}|';
        customerIds.add(element.CustomerNo);
      });
      customerIds = customerIds.toSet().toList();

      ApiService.fetchCustomerMails(customerNo: customerIds).then((value) {
        customerIdsData = value;

        idsData = idsData.length > 0
            ? idsData.substring(0, idsData.lastIndexOf('|'))
            : '';
        customerIdsData = customerIdsData.length > 0
            ? customerIdsData.substring(0, customerIdsData.lastIndexOf(','))
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
            secondaryIdsData: customerIdsData,
          ),
        );
      });
    } catch (e) {
      print(
          'Error Inside showSendMailDialog FN while Opening the sendMailDialog ');
      print(e);
    }
  }

  void resetSendMailData() {
    setState(() {
      invoices.forEach((element) {
        element.IsSelected = false;
      });
      SendMailInvoiceList.clear();
      isFullScreenLoading = false;
    });
  }

  List<Row> getButtonRows(int recordPosition) {
    List<Row> rowsList = List<Row>();

    ///ADDING THE FIRST ROW WITH ONE BUTTON FOR THE NAVIGATION
    rowsList.add(
      Row(
        children: <Widget>[],
      ),
    );
    return rowsList;
  }

  //For large screen
  Widget _buildTable() {
    return Container(
      child: invoices.length > 0
          ? TableView(
              standardFields: onGridStandardFields,
              isActionsEnabled: true,
              isEntitySectionCheckDisabled: true,
              actionButtonRows: getActionButtonRows,
              showOnGridFields: true,
              isExcludedFieldEnabled: false,
              isCheckBoxVisible: true,
              handleCheckBoxOnChange: handleCheckBoxOnChange,
              currencyCaption: _currencyCaption.Caption != null
                  ? _currencyCaption.Caption
                  : null,
              ListObject: invoices)
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
          title: Text(AppBarTitles.INVOICES),
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(widget.parentBuildContext);
              }),
        ),
        body: Column(
          children: <Widget>[
            ///CUSTOMER SELECTOR
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
              child: Card(
                elevation: 1,
                child: ExpansionTile(
                  initiallyExpanded: isLargeScreen ? true : false,
                  title:Text ('Search Invoice'),
                  children: <Widget>[Column(
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
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[_buildInvoiceStatusDropdown()],
                      ),
                      SearchTextField(
                        searchFieldContent: searchFieldContent,
                        clearTextFieldSearch: clearTextFieldSearch,
                        handleTextFieldSearch: handleTextFieldSearch,
                        placeHolder: 'Search Invoice',
                      ),
                    ],
                  )],
                ),
              ),
            ),
            //SizedBox(height: 5.0),
            getFeatureButtonButtonWidget(),
            //SizedBox(height: 5.0),

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
                    isVisible: invoices.length < 1 && !isShowLoader,
                  ),

                  ///BUILDS INVOICES LIST
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
