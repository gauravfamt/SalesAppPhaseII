import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:http/http.dart' as http;
import 'package:moblesales/helpers/index.dart';
import 'package:moblesales/models/index.dart';
import 'package:moblesales/screens/index.dart';
import 'package:moblesales/utils/index.dart';
import 'dart:convert';
import 'dart:async';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class Quote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return (MaterialApp(
      debugShowCheckedModeBanner: false,
      home: QuotePage(
        parentBuildContext: context,
      ),
    ));
  }
}

class QuotePage extends StatefulWidget {
  final BuildContext parentBuildContext;

  QuotePage({Key key, @required this.parentBuildContext}) : super(key: key);

  @override
  _QuotePageState createState() => _QuotePageState();
}

class _QuotePageState extends State<QuotePage> {
  ///IT HOLDS ALL THE COMMON REUSABLE WIDGETS WHICH CAN BE USED THROUGH OUT PROJECT
  CommonWidgets _commonWidgets;

  ///USED TO HANDLE THE FULLSCREEN_LOADER JUST SET THE STATE TO THE TRUE TO START
  bool isFullScreenLoading;

  ///HOLDS STANDARD_FIELDS FOR THE QUOTE_HEADER ENTITY
  List<StandardField> onGridStandardFields;

  List<StandardField> headerOnScreenStandardFields;

  ///HOLDS STANDARD_FIELDS FOR THE QUOTE_DETAIL ENTITY
  List<StandardField> detailsOnGridStandardFields;

  ///HOLDS THE CURRENCY_CAPTION STANDARD FIELD
  StandardDropDownField _currencyCaption;

  ///TO IDENTIFY DETAILS PAGE STANDARD FIELDS ARE LOADED AND TO CLOSE DETAILS PAGE LOADER
  bool isDetailsFieldsLoading;

  ///HOLDS ALL THE QUOTES LIST
  List<Quotes> quotes;

  ///HOLDS OFFLINE QUOTES DATA FOR THE NOTIFICATIONS MSG
  List<AddQuote> offlineQuotes;

  ///HOLDS ALL THE QUOTE STATUSES LIST FOR THE ADVANCED SEARCH OPTION
  List<StandardDropDownField> statusList;

  ///HOLDS THE QUOTE_STATUS FOR ADVANCED SEARCH DROPDOWN FILTERING
  StandardDropDownField _selectedStatus;

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

  //To handle pagination wise data
  bool isNextButtonPressed;
  bool isPreviousButtonPressed;
  bool isNextButtonDisabled;
  bool isPreviousButtonDisabled;
  bool isShowPaginationButtons;

  bool isDisableEditButton;
  int lastPageNumber;

  AddQuoteDBHelper _addQuoteDBHelper;
  AddQuoteHeaderDBHelper _addQuoteHeaderDBHelper;
  AddQuoteDetailDBHelper _addQuoteDetailDBHelper;
  StandardDropDownFieldsDBHelper _standardDropDownFieldsDBHelper;
  StandardFieldsDBHelper _standardFieldsDBHelper;

  //To despaly Offline quote data table on Large screen
  List<DataColumn> _Datacolumn;
  List<DataRow> _DataRow;

  // bool isOffline = false;

  ///NETWORK_CONNECTION STREAM SUBSCRIPTION TO GET UPDATES WHEN APP IS ONLINE OR OFFLINE
  StreamSubscription _connectionChangeStream;

  bool isOffline;

  //Company DB Object
  CompanyDBHelper _companyDBHelper;

  @override
  void initState() {
    super.initState();
    isShowLoader = true;
    pageNumber = 1;
    pageSize = Pagination.LIST_PAGE_SIZE;
    quotes = List<Quotes>();
    offlineQuotes = List<AddQuote>();
    _commonWidgets = CommonWidgets();
    statusList = buildStatusDropdownList();
    _selectedStatus = statusList[0];
    _selectedCompany = null;
    searchFieldContent = null;
    onGridStandardFields = List<StandardField>();
    headerOnScreenStandardFields = List<StandardField>();
    detailsOnGridStandardFields = List<StandardField>();
    isDetailsFieldsLoading = false;
    isFullScreenLoading = false;
    lastPageNumber = 0;

    isNextButtonDisabled = false;
    isPreviousButtonDisabled = true; //Initialy on 1 page
    isShowPaginationButtons = true;

    isDisableEditButton = true;
    _addQuoteDBHelper = AddQuoteDBHelper();
    _addQuoteHeaderDBHelper = AddQuoteHeaderDBHelper();
    _addQuoteDetailDBHelper = AddQuoteDetailDBHelper();
    _standardDropDownFieldsDBHelper = StandardDropDownFieldsDBHelper();
    _standardFieldsDBHelper = StandardFieldsDBHelper();
    //To despaly Offline quote data table on Large screen
    _Datacolumn = new List();
    _DataRow = List<DataRow>();
    isOffline = ConnectionStatus.isOffline;

    ///Object for Company Queries
    _companyDBHelper = new CompanyDBHelper();

    ///HOLDS QUOTES DATA FOR THE NOTIFICATIONS MSG

    _currencyCaption = StandardDropDownField();

    ConnectivityService connectionStatus = ConnectivityService.getInstance();
    _connectionChangeStream =
        connectionStatus.connectionChange.listen(connectionChanged);

    fetchCurrencyStandardField();
    fetchStandardStatusDropDownFields();
    fetchQuoteHeaderStandardFields();
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
  Future<void> fetchCurrencyStandardField() async {
    await _standardDropDownFieldsDBHelper
        .getEntityStandardDropdownFieldsData(
          entity: StandardEntity.CURRENCY_DROPDOWN_ENTITY,
          searchText: DropdownSearchText.CURRENCY_DROPDOWN_SEARCH_TEXT,
        )
        .then((value) => {
              if (value.length > 0)
                {
                  if (value.length > 0)
                    {
                      _currencyCaption = value[0],
                    }
                }
            });
  }

  ///IT FETCHES THE STANDARD FIELDS FOR ON_GRID_SHOW FIELDS SHOW IN LIST UI
  void fetchQuoteHeaderStandardFields() {
    _standardFieldsDBHelper
        .getEntityStandardFieldsData(
            entity: StandardEntity.QUOTE_HEADER,
            showInGrid: true,
            showOnScreen: false,
            showBySortOrder: true)
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
                  'Error while fetching OnGrid StandardFields for the QuoteHeader Entity'),
              print(onError),
            });
  }

  void fetchQuoteHeadersshowOnScreenStandardFields(
      int recordPosition, String QuoteType) {
    _standardFieldsDBHelper
        .getEntityStandardFieldsData(
            entity: StandardEntity.QUOTE_HEADER,
            showInGrid: false,
            showOnScreen: true,
            showBySortOrder: true)
        .then((value) => {
              ///HERE CHECKING IF STANDARD FIELDS RESPONSE DID'T RECEIVED THEN NOT CALLING THE GET_DATA_API
              if (value.length > 0)
                {
                  setState(() {
                    headerOnScreenStandardFields = value;
                    fetchQuoteDetailStandardFields(recordPosition, QuoteType);
                  }),
                }
              else
                {
                  setState(() {
                    isDetailsFieldsLoading = false;
                  }),
                }
            })
        .catchError((onError) => {
              print(
                  'Error while fetching OnGrid StandardFields for the QuoteDetail Entity'),
              print(onError)
            });
  }

  ///IT FETCHES THE STANDARD FIELDS FOR ON_GRID_SHOW FIELDS SHOW IN LIST UI
  void fetchQuoteDetailStandardFields(int recordPosition, String QuoteType) {
    _standardFieldsDBHelper
        .getEntityStandardFieldsData(
            entity: StandardEntity.QUOTE_DETAIL,
            showInGrid: false,
            showOnScreen: true)
        .then((value) => {
              ///HERE CHECKING IF STANDARD FIELDS RESPONSE DID'T RECEIVED THEN NOT CALLING THE GET_DATA_API
              if (value.length > 0)
                {
                  setState(() {
                    detailsOnGridStandardFields = value;
                    isDetailsFieldsLoading = false;
                    isFullScreenLoading = false;
                  }),
                  if (QuoteType == 'Online')
                    {
                      ///NAVIGATING TO THE QUOTE_DETAILS PAGE
                      Navigator.of(widget.parentBuildContext).push(
                        MaterialPageRoute(
                          builder: (context) => QuoteDetails(
                            quoteObj: quotes[recordPosition],
                            detailsOnGridStandardFields:
                                detailsOnGridStandardFields,
                            headerOnScreenStandardFields:
                                headerOnScreenStandardFields,
                            isDetailsFieldsLoading: isDetailsFieldsLoading,
                            currencyCaptionSF: _currencyCaption,
                          ),
                        ),
                      ),
                    }
                  else
                    {
                      Navigator.of(widget.parentBuildContext).push(
                        MaterialPageRoute(
                          builder: (context) => QuoteDetails(
                            offlineQuoteObj: offlineQuotes[recordPosition],
                            detailsOnGridStandardFields:
                                detailsOnGridStandardFields,
                            headerOnScreenStandardFields:
                                headerOnScreenStandardFields,
                            isDetailsFieldsLoading: isDetailsFieldsLoading,
                            currencyCaptionSF: _currencyCaption,
                          ),
                        ),
                      ),
                    }
                }
              else
                {
                  setState(() {
                    isDetailsFieldsLoading = false;
                  }),
                }
            })
        .catchError((onError) => {
              print(
                  'Error while fetching OnGrid StandardFields for the QuoteDetail Entity'),
              print(onError)
            });
  }

  ///IT FETCHES THE STANDARD_DROPDOWN_FIELDS FOR QUOTE_STATUS DROPDOWN
  Future<void> fetchStandardStatusDropDownFields() async {
    try {
      await _standardDropDownFieldsDBHelper
          .getEntityStandardDropdownFieldsData(
            entity: StandardEntity.QUOTE_DROPDOWN_ENTITY,
            searchText: DropdownSearchText.QUOTE_DROPDOWN_SEARCH_TEXT,
          )
          .then((value) => {
                if (value.length > 0)
                  {
                    this.setState(() {
                      statusList.addAll(value);
                      statusList.sort((a, b) => a.Caption.compareTo(b.Caption));
                    }),
                  }
              });
    } catch (e) {
      print(
          'Error While fetching DropDownValues in fetchStandardStatusDropDownFields FN');
      print(e);
    }
  }

  ///It makes the http Request for fetching the quotes
  Future<List<Quotes>> fetchQuotes() async {
    try {
      var quotesData = List<Quotes>();
      String url =
          '${await Session.getData(Session.apiDomain)}/${URLs.GET_QUOTES}?pageNumber=$pageNumber&pageSize=$pageSize';
      if (_selectedCompany != null) {
        url = '$url&CustomerNo=${_selectedCompany.CustomerNo}';
      }
      if (_selectedStatus.Code != '') {
        url = '$url&Status=${_selectedStatus.Code}';
      }
      if (searchFieldContent != null && searchFieldContent.trim().length > 0) {
        url = '$url&Searchtext=${searchFieldContent.trim().toUpperCase()}';
      }
      print('url--- ${url}');
      // String tk = await Session.getData(Session.accessToken);
      // String un = await Session.getData(Session.userName);

      // log(tk);
      // print(un);

      http.Client client = http.Client();
      final response = await client.get(url, headers: {
        "token": await Session.getData(Session.accessToken),
        "Username": await Session.getData(Session.userName),
      }).timeout(duration);
      // print("response.body_S");
      // print(response.body);
      // print("response.body_E");
      if (response.statusCode == 200 && response.body != "No Quotes found") {
        var data = json.decode(response.body);
        if (data != 'No Quotes found') {
          quotesData =
              data.map<Quotes>((json) => Quotes.fromJson(json)).toList();
        }
      }
      return quotesData;
    } catch (e) {
      print('Error inside fetchQuotes FN');
      print(e);
      throw Future.error(e);
    }
  }

  Future<void> getRecordCount(String strWhereClause) async {
    try {
      int recordCount =
          await _addQuoteDBHelper.getOfflineQuoteCount(strWhereClause);
      lastPageNumber = (recordCount / pageSize).ceil();
    } catch (e) {
      print('Error Inside getProductCount $e ');
    }
  }

  Future<void> fetchOfflineQuotesData() async {
    try {
      List<dynamic> customerNos = [];
      PagingControl();
      print('fetchOfflineQuotesData');
      String strWhereClause = '';
      if (_selectedCompany != null && _selectedCompany.CustomerNo != null) {
        strWhereClause =
            "and QuoteHeaderIds in (select HeaderReferenceId from QuoteHeader where FieldName='CustomerNo' and FieldValue='${_selectedCompany.CustomerNo}')";
      }
      if (searchFieldContent != null && searchFieldContent.isNotEmpty) {
        strWhereClause =
            "and QuoteHeaderIds in (select HeaderReferenceId from QuoteHeader where FieldName='DocumentNo' and FieldValue like %'${searchFieldContent}%')";
      }
      await getRecordCount(strWhereClause);
      await _addQuoteDBHelper
          .getQuotes(
            isDetailsRequired: true, //true
            strWherClause: strWhereClause,
            pageSize: pageSize,
            pageNo: pageNumber,
          )
          .then((quotesRes) => {
                if (quotesRes.length > 0)
                  {
                    print("Customer List"),
                    //Extracts Customer No from quotesRes i.e. Offline Quotes
                    customerNos = quotesRes
                        .map((e) {
                          return e.QuoteHeader.map((quoteHeader) {
                            return quoteHeader.QuoteHeaderFields.firstWhere(
                                (element) {
                              return element.FieldName == "CustomerNo";
                            }).FieldValue;
                          }).first;
                        })
                        .toSet()
                        .toList(),
                    print(customerNos),
                    //Fetches Customer Name for Offline Data
                    _companyDBHelper
                        .getCompanyByCustomerNos(
                      customerNoList: customerNos,
                    )
                        .then((companyRes) {
                      quotesRes.forEach((quoteHeader) {
                        quoteHeader.QuoteHeader.forEach((element) {
                          //Adds QuoteHeaderField for CustomerName
                          QuoteHeaderField customerName = QuoteHeaderField(
                            Id: (element.QuoteHeaderFields.last.Id++),
                            AddQuoteID:
                                element.QuoteHeaderFields.last.AddQuoteID,
                            FieldName: "CustomerName",
                            LabelName: "Customer Name",
                            //Extracts Customer Name from companyRes where it would match Customer No
                            FieldValue: companyRes
                                .firstWhere(
                                  (singleCompany) =>
                                      singleCompany.CustomerNo ==
                                      element.QuoteHeaderFields.firstWhere(
                                          (element) =>
                                              element.FieldName ==
                                              "CustomerNo").FieldValue,
                                  orElse: () => Company(Name: ""),
                                )
                                .Name,
                            HeaderReferenceId: element
                                .QuoteHeaderFields.last.HeaderReferenceId,
                            IsReadonly: true,
                            IsRequired: false,
                            textEditingController: element
                                .QuoteHeaderFields.last.textEditingController,
                          );

                          ///Adds after CustomerNo position
                          element.QuoteHeaderFields.insert(
                              //Finds Index of CustomerNo, and adds single integer to add it after CustomerNo
                              (element.QuoteHeaderFields.indexOf(
                                      element.QuoteHeaderFields.firstWhere(
                                          (element) =>
                                              element.FieldName ==
                                              'CustomerNo')) +
                                  1),
                              customerName);

                          ///Adds at last position
                          // element.QuoteHeaderFields.add(customerName);
                        });
                      });

                      this.setState(() {
                        offlineQuotes.clear();
                        offlineQuotes.addAll(quotesRes);
                        isShowLoader = false;
                        isFullScreenLoading = false;
                      });
                      dataFetch();
                    }),
                  }
                else
                  {
                    this.setState(() {
                      isShowLoader = false;
                      isFullScreenLoading = false;
                    })
                  }
              })
          .catchError((e) => {
                print('Error while fetching quotes data  '),
                print(e),
                this.setState(() {
                  isShowLoader = false;
                  isFullScreenLoading = false;
                }),
              });
    } catch (e) {
      print('fetchOfflineQuotesData $e');
      this.setState(() {
        isShowLoader = false;
        isFullScreenLoading = false;
      });
    }
  }

  void PagingControl() {
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
  }

  ///It fetches the initial data for the companies state
  void dataFetch() {
    if (_selectedStatus.Code.toLowerCase() != "offline") {
      PagingControl();
      isOffline == true
          ? _commonWidgets.showFlutterToast(
              toastMsg: ConnectionStatus.NetworkNotAvailble)
          : fetchQuotes().then((quoteDataRes) => {
                _companyDBHelper
                    .getCompanyByCustomerNos(
                  customerNoList:
                      quoteDataRes.map((e) => e.CustomerNo).toSet().toList(),
                )
                    .then((companyRes) {
                  print(companyRes.map((e) => e.Name).toSet().toList());
                  setState(() {
                    quoteDataRes.forEach((element) {
                      element.CustomerName = companyRes
                          .firstWhere(
                            (e) => e.CustomerNo == element.CustomerNo,
                            orElse: () => Company(Name: ""),
                          )
                          .Name;
                    });
                    int newRecordCount = quoteDataRes.length;
                    quotes.clear();
                    quotes.addAll(quoteDataRes);
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
                      lastPageNumber = 0;
                      isNextButtonDisabled = false;
                    }
                  });
                }),
              });
    } else {
      setState(() {
        int newRecordCount = offlineQuotes.length;
        isShowLoader = false;
        if (newRecordCount < pageSize) {
          isNextButtonDisabled = true;
          if (isPreviousButtonDisabled == true) {
            isShowPaginationButtons = false;
          } else {
            isShowPaginationButtons = true;
          }
        } else {
          if (lastPageNumber == pageNumber) {
            //for newRecordCount==pageSize
            isNextButtonDisabled = true;
          }
          if (offlineQuotes != null && offlineQuotes.length > 0) {
            isShowPaginationButtons = true;
          } else {
            isShowPaginationButtons = false;
          }
        }
      });
    }
  }

  ///It closes the CompanySearch Dialog On CLose Btn click
  void closeSearchDialog() {
    print('closeSearchDialog called of the Quotes page');
  }

  ///It handles the Selected Company Response for the search
  void handleCustomerSelectedSearch(Company selectedCompany) {
    print('Inside handleCustomerSelectedSearch fn of quote Page');
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

  ///It handles the Quote status changes and Loads the new data accordingly
  void handleStatusChange(StandardDropDownField selectedStatus) {
    setState(() {
      _selectedStatus = selectedStatus;
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
      quotes.clear(); //= List<Quotes>();
      offlineQuotes.clear();
      pageNumber = 1;
      isShowLoader = true;
      isNextButtonPressed = false;
      isPreviousButtonPressed = false;
      isNextButtonDisabled = false;
      isPreviousButtonDisabled = true;
      isDisableEditButton = true;
    });
    if (_selectedStatus.Code.toLowerCase() == "offline") {
      fetchOfflineQuotesData();
    } else {
      dataFetch();
    }
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

  ///It returns the dropDownWidget Contents list
  List<StandardDropDownField> buildStatusDropdownList() {
    List<StandardDropDownField> listItems = [
      ///ADDING THE DEFAULT DROPDOWN VALUE i.e. --SELECT-- OPTION
      StandardDropDownField(
        Caption: '--Select--',
        Code: '',
        Dropdown: DropdownSearchText.QUOTE_DROPDOWN_SEARCH_TEXT,
        Entity: StandardEntity.QUOTE_DROPDOWN_ENTITY,
        Id: 0,
        TenantId: 0,
      ),
    ];
    return listItems;
  }

  ///It returns the search bar Widget for the Quotes list screen
  Widget _buildStatusDropdown() {
    List<DropdownMenuItem<StandardDropDownField>> dropDownMenuItems = List();
    statusList.forEach((element) {
      dropDownMenuItems.add(
        DropdownMenuItem(
          child: Text(
            '${element.Caption}',
            style: TextStyle(color: AppColors.black, fontSize: 15.0),
          ),
          value: element,
        ),
      );
    });

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
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
                      'Quote Status',
                      style: TextStyle(color: AppColors.grey, fontSize: 15.0),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    DropdownButton(
                      value: _selectedStatus,
                      items: dropDownMenuItems,
                      onChanged: (StandardDropDownField selectedItem) {
                        if (selectedItem.Code != _selectedStatus.Code) {
                          handleStatusChange(selectedItem);
                        } else {
                          print('Already Selected Status State Selected ');
                        }
                      },
                      isExpanded: true,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  ///It handles the Details Page Navigation
  void handleDetailsPageNavigation(int recordPosition, String QuoteType) {
    ///SETTING SHOW LOADING STATE TRUE FOR DETAILS PAGE STATE
    setState(() {
      isFullScreenLoading = true;
      isDetailsFieldsLoading = true;
      headerOnScreenStandardFields = List<StandardField>();
      detailsOnGridStandardFields = List<StandardField>();
    });

    ///FETCHING THE STANDARD_FIELDS FOR THE DETAILS PAGE ON_GRID FIELDS DISPLAY
    fetchQuoteHeadersshowOnScreenStandardFields(recordPosition, QuoteType);
  }

  ///IT HA NDLES THE QUOTE NAVIGATION ON EDIT BUTTON CLICK
  void handleEditPageNavigation(int recordPosition, String QuoteType) async {
    Quotes _quoteObject = quotes[recordPosition];
    try {
      ///HERE PARSING THE DOCUMENT_DATE AS NEEDED TO SHOW ON THE ADD_QUOTE PAGE
      _quoteObject.DocumentDate =
          '${DateTime.parse(_quoteObject.ServerDocumentDate)}';
    } catch (e) {
      print('Error while parsing ServerDocumentDate for EditQuote screen');
      print(e);
    }

    ///NAVIGATING TO THE ADD_QUOTE PAGE
    var result = await Navigator.of(widget.parentBuildContext).push(
      MaterialPageRoute(
        builder: (context) => AddQuotePage(
          addQuoteType: AddQuoteType.EDIT_CREATED_QUOTE,
          listingQuoteObj: _quoteObject,
        ),
      ),
    );
    if (result != null) {
      //back to customer selection
      if (result == false) {
        Navigator.of(widget.parentBuildContext).push(
          MaterialPageRoute(
              builder: (context) => SelectCustomer(
                    pageNameToNavigate: 'Quotes',
                    isFromQuoteScreen: true,
                  )),
        );
      }
    }

    loadNewSearchData();
  }

  void handleNewQuoteNavigation() async {
    ///NAVIGATING TO THE ADD_QUOTE PAGE
    var result = await Navigator.push(
        widget.parentBuildContext,
        new MaterialPageRoute(
            builder: (context) => new SelectCustomer(
                  pageNameToNavigate: 'Quotes',
                  isFromQuoteScreen: true,
                )));
    if (result != null) {
      loadNewSearchData();
    }
  }

  Widget getActionButton(String title, int recordPosition, Function clickAction,
      String QuoteType) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
        child: RaisedButton(
          onPressed: quotes[recordPosition].IsIntegrated == "Yes" &&
                  title == "Edit" &&
                  _selectedStatus.Code.toLowerCase() != "offline"
              ? null
              : () {
                  clickAction(recordPosition, QuoteType);
                },
          color: AppColors.blue,
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
              handleDetailsPageNavigation, 'Online'),
          getActionButton(
              'Edit', recordPosition, handleEditPageNavigation, 'Online'),
        ],
      ),
    );
    return rowsList;
  }

  Widget getActionButtonRowsForOfflineQuote(int position) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
            child: RaisedButton(
                color: Colors.red,
                child: Text(
                  'Remove',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  showDialog(
                    useRootNavigator: true,
                    barrierDismissible: false,
                    context: context,
                    builder: (context) => new AlertDialog(
                      content: SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                            Icon(
                              Icons.warning,
                              color: Colors.deepOrangeAccent,
                              size: 50,
                            ),
                            Text(
                              'WARNING',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              'You want to delete this quote?',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        RaisedButton(
                          onPressed: () {
                            Navigator.of(context, rootNavigator: true)
                                .pop(); //Close
                            setState(() {
                              isFullScreenLoading = true;
                            });
                            deleteQuoteByID(
                                quoteId: offlineQuotes[position].Id);
                          },
                          child: Text('Yes'),
                          color: AppColors.blue,
                        ),
                        RaisedButton(
                          onPressed: () {
                            Navigator.of(context, rootNavigator: true).pop();
                          },
                          child: Text('No'),
                        ),
                      ],
                    ),
                  );
                }),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
            child: RaisedButton(
                child: Text(
                  'Details',
                  style: TextStyle(color: Colors.black),
                ),
                onPressed: () {
                  handleDetailsPageNavigation(position, 'Offline');
                }),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
            child: RaisedButton(
                color: AppColors.blue,
                child: Text(
                  'Edit',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  handleOfflineQuoteEdit(quoteObject: offlineQuotes[position]);
                }),
          ),
        ),
      ],
    );
  }

  void deleteQuoteByID({
    @required int quoteId,
  }) async {
    try {
      if (quoteId != null) {
        var _quoteHeaderDeleteRes = await _addQuoteHeaderDBHelper
            .deleteRowByQuoteId(addQuoteId: quoteId);

        var _quoteDetailDeleteRes = await _addQuoteDetailDBHelper
            .deleteRowByQuoteId(addQuoteId: quoteId);

        var _quoteDeleteRes =
            await _addQuoteDBHelper.deleteRowById(addQuoteId: quoteId);

        setState(() {
          isFullScreenLoading = false;
        });
        loadNewSearchData();
      } else {
        setState(() {
          isFullScreenLoading = false;
        });
        print('Invalid Quote Id Found for the deletion');
      }
    } catch (e) {
      print('Error Inside deleteQuoteByID Fn ');
      print(e);
      setState(() {
        isFullScreenLoading = false;
      });
    }
  }

  void handleOfflineQuoteEdit({
    AddQuote quoteObject,
  }) async {
    // navigateToOfflineEditQuote(quoteObject: quoteObject);
    if (quoteObject != null && quoteObject.Id != null) {
      if ((quoteObject.IsLocalQuote == 1) ||
          (isOffline == true && quoteObject.IsLocalQuote == 0)) {
        navigateToOfflineEditQuote(quoteObject: quoteObject);
      } else if (isOffline == false &&
          quoteObject.IsLocalQuote == 0 &&
          quoteObject.ServerQuoteId != null) {
        setState(() {
          isFullScreenLoading = true;
        });
        fetchQuoteFromServer(
          quoteObj: quoteObject,
          serverQuoteId: quoteObject.ServerQuoteId,
        );
      }
    } else {
      setState(() {
        isFullScreenLoading = false;
      });
      _commonWidgets.showFlutterToast(
          toastMsg: 'Something went wrong! Please Try again later.');
    }
  }

  ///IT FETCHES THE QUOTE FROM SERVER AND THEN NAVIGATES TO THE ADD_QUOTE_SCREEN
  void fetchQuoteFromServer({
    int serverQuoteId,
    AddQuote quoteObj,
  }) async {
    try {
      ApiService.fetchQuotesById(serverQuoteId: serverQuoteId)
          .then((quotesRes) => {
                if (quotesRes.length > 0)
                  {
                    print('server edited quote Loaded from api response '),
                    this.setState(() {
                      isFullScreenLoading = false;
                    }),
                    this.navigateToServerOfflineEditQuote(
                        quoteObj: quotesRes[0]),
                  }
                else
                  {
                    ///AS NO QUOTE FOUND BY ID FROM API LOADING THE OFFLINE QUOTE IN ADD_QUOTE_PAGE
                    navigateToOfflineEditQuote(quoteObject: quoteObj),
                  }
              })
          .catchError((e) {
        print('Error while fetching singleQuote By ID');
        print(e);

        ///AS ERROR OCCURRED LOADING OFFLINE QUOTE FOR ADD_QUOTE_PAGE
        navigateToOfflineEditQuote(quoteObject: quoteObj);
      });
    } catch (e) {
      print('Error while fetching singleQuote By ID in catch Block');
      print(e);

      ///AS ERROR OCCURRED LOADING OFFLINE QUOTE FOR ADD_QUOTE_PAGE
      navigateToOfflineEditQuote(quoteObject: quoteObj);
    }
  }

  ///IT NAVIGATES TO THE QUOTE PAGE BY PROVIDING AND LOADS OFFLINE QUOTE
  void navigateToOfflineEditQuote({
    AddQuote quoteObject,
  }) async {
    if (isFullScreenLoading)
      this.setState(() {
        isFullScreenLoading = false;
      });
    var result = await Navigator.of(widget.parentBuildContext).push(
      MaterialPageRoute(
        builder: (context) => EditOfflineQuote(
          addQuoteType: AddQuoteType.EDIT_OFFLINE_QUOTE,
          quoteId: quoteObject.Id,
          isOfflineQuote: true,
        ),
      ),
    );

    if (result != null) {
      //back to customer selection
      if (result == false) {
        Navigator.of(widget.parentBuildContext).push(
          MaterialPageRoute(
              builder: (context) => SelectCustomer(
                    pageNameToNavigate: 'Quotes',
                    isFromQuoteScreen: true,
                  )),
        );
      }
    }

    //Loading New data for the quotes to get updated Quotes list after any changes in edit quote or new quote added');
    loadNewSearchData();
  }

  ///IT NAVIGATES TO THE QUOTE PAGE BY PROVIDING AND LOADS OFFLINE QUOTE
  void navigateToServerOfflineEditQuote({
    @required Quotes quoteObj,
  }) async {
    if (isFullScreenLoading)
      this.setState(() {
        isFullScreenLoading = false;
      });
    try {
      ///HERE PARSING THE DOCUMENT_DATE AS NEEDED TO SHOW ON THE ADD_QUOTE PAGE
      quoteObj.DocumentDate = '${DateTime.parse(quoteObj.ServerDocumentDate)}';
    } catch (e) {
      print(
          'Error while parsing ServerDocumentDate for EditQuote screen in notification screen');
      print(e);
    }
    var result = await Navigator.of(widget.parentBuildContext).push(
      MaterialPageRoute(
        builder: (context) => EditOfflineQuote(
          addQuoteType: AddQuoteType.EDIT_CREATED_QUOTE,
          listingQuoteObj: quoteObj,
          isOfflineQuote: true,
        ),
      ),
    );

    if (result != null) {
      //back to customer selection
      if (result == false) {
        Navigator.of(widget.parentBuildContext).push(
          MaterialPageRoute(
              builder: (context) => SelectCustomer(
                    pageNameToNavigate: 'Quotes',
                    isFromQuoteScreen: true,
                  )),
        );
      }
    }

    loadNewSearchData();
  }

  ///It builds the Quotes List
  Widget _buildList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: ScrollPhysics(),
      itemCount: quotes.length,
      padding: const EdgeInsets.all(15.0),
      //Complete ListView Outside padding
      itemBuilder: (context, position) {
        return Container(
          child: ListViewRows(
            standardFields: onGridStandardFields,
            recordObj: quotes[position],
            recordPosition: position,
            isActionsEnabled: true,
            actionButtonRows: getActionButtonRows(position),
            isEntitySectionCheckDisabled: true,
            showOnGridFields: true,
            isExcludedFieldEnabled: false,
            currencyCaption: _currencyCaption.Caption,
          ),
        );
      },
    );
  }

  //Bind offline quote
  Widget _buildOfflineQuoteList() {
    print("Inside _buildOfflineQuoteList");
    print(offlineQuotes.length);
    return ListView.builder(
      shrinkWrap: true,
      physics: ScrollPhysics(),
      itemCount: offlineQuotes.length,
      padding: const EdgeInsets.all(15.0),
      itemBuilder: (context, position) {
        return Card(
          child: Column(
            children: <Widget>[
              Column(
                children: buildRows(
                    offlineQuotes[position].QuoteHeader[0].QuoteHeaderFields,
                    position),
              ),
              Divider(
                thickness: 2.0,
                color: AppColors.grey,
              ),
              offlineQuotes[position].QuoteHeader[0].QuoteHeaderFields.length >
                      0
                  ? getActionButtonRowsForOfflineQuote(position)
                  : null,
            ],
          ),
        );
      },
    );
  }

  //Bind offline quote
  List<Widget> buildRows(
      List<QuoteHeaderField> QuoteHeaderFields, int position) {
    print("Inside buildRows");
    QuoteHeaderFields.forEach((element) {
      print(element.FieldName + ":" + element.FieldValue);
    });
    print("Shows onGridStandardFields");
    onGridStandardFields.forEach((element) {
      print(element.FieldName);
    });
    List<Widget> _widgetsList = List<Widget>();
    for (var i = 0; i < QuoteHeaderFields.length; i++) {
      //Check which details should disply on grid
      var displayOnGrid = onGridStandardFields.firstWhere(
          (e) => e.FieldName == QuoteHeaderFields[i].FieldName,
          orElse: () => null);
      if (displayOnGrid != null) {
        _widgetsList.add(_buildQuoteHeader(QuoteHeaderFields[i]));
      }
    }
    return _widgetsList;
  }

  //Bind offline quote header details
  Widget _buildQuoteHeader(QuoteHeaderField QuoteHeaderField) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15.0, 5.0, 10.0, 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Text(
              '${QuoteHeaderField.LabelName}',
              style: TextStyle(
                color: AppColors.grey,
                fontSize: 15,
              ),
            ),
          ),
          SizedBox(
            width: 5,
          ),
          Expanded(
            child: Text(
              QuoteHeaderField.FieldName == "DocumentDate"
                  ? '${Other().DisplayDate(QuoteHeaderField.FieldValue)}'
                  : QuoteHeaderField.FieldName == "DocumentTotal"
                      ? '${HtmlUnescape().convert(_currencyCaption.Caption)} ' +
                          '${QuoteHeaderField.FieldValue}'
                      : '${QuoteHeaderField.FieldValue}',
              style: TextStyle(
                  color: AppColors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.bold),
            ),
          ),
          //_buildOfflineHeaderList(position),
        ],
      ),
    );
  }

  //For large screen
  Widget _buildTable() {
    return Container(
      child: quotes.length > 0
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
              ListObject: quotes,
            )
          : Text(''),
    );
  }

  void GetColumn(List<QuoteHeaderField> QuoteHeaderFields) {
    for (var i = 0; i < onGridStandardFields.length; i++) {
      //print('onGridStandardFields ${onGridStandardFields[i].FieldName}');
      var displayOnGrid = QuoteHeaderFields.firstWhere(
          (e) => e.FieldName == onGridStandardFields[i].FieldName,
          orElse: () => null);
      if (displayOnGrid != null) {
        _Datacolumn.add(
          DataColumn(
            label: Text(
              '${displayOnGrid.LabelName}',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                letterSpacing: 1,
              ),
            ),
          ),
        );
      }
    }
    _Datacolumn.add(DataColumn(
      label: Text(''), //For Add button
    ));
  }

//  void GetColumn(List<QuoteHeaderField> QuoteHeaderFields) {
//    for (var i = 0; i < onGridStandardFields.length; i++) {
//      print('onGridStandardFields ${onGridStandardFields[i].FieldName}');
//    }
//
//
//    for (var i = 0; i < QuoteHeaderFields.length; i++) {
//      print('QuoteHeaderFields ${QuoteHeaderFields[i].FieldName}');
//      //Check which details should disply on grid
//      var displayOnGrid = onGridStandardFields.firstWhere(
//              (e) => e.FieldName == QuoteHeaderFields[i].FieldName,
//          orElse: () => null);
//      if (displayOnGrid != null) {
//        _Datacolumn.add(
//          DataColumn(
//            label: Text(
//              '${QuoteHeaderFields[i].LabelName}',
//              style: TextStyle(
//                color: Colors.black,
//                fontSize: 16,
//                letterSpacing: 1,
//              ),
//            ),
//          ),
//        );
//      }
//    }
//
//    _Datacolumn.add(DataColumn(
//      label: Text(''), //For Add button
//    ));
//  }

  //Change by gaurav , 12 - Jan -2022,to dispaly only onGridStandardFields on offlinr tab view
  Widget CreateTable() {
    _Datacolumn = new List();
    _DataRow = List<DataRow>();
    GetColumn(offlineQuotes[0].QuoteHeader[0].QuoteHeaderFields);
    for (int k = 0; k < offlineQuotes.length; k++) {
      for (int i = 0; i < offlineQuotes[k].QuoteHeader.length; i++) {
        List<DataCell> _DataCell = [];
        for (var j = 0; j < onGridStandardFields.length; j++) {
          //print('onGridStandardFields ${onGridStandardFields[j].FieldName}');
          if (j == _Datacolumn.length - 1) {
            //Render buttons add at last row
            _DataCell.add(DataCell(
              Column(
                children: <Widget>[
                  offlineQuotes[k].QuoteHeader[i].QuoteHeaderFields.length > 0
                      ? getActionButtonRowsForOfflineQuote(k)
                      : null,
                ],
              ),
            ));
          } else {
            var displayOnGrid = offlineQuotes[k]
                .QuoteHeader[i]
                .QuoteHeaderFields
                .firstWhere(
                    (e) => e.FieldName == onGridStandardFields[j].FieldName,
                    orElse: () => null);
            if (displayOnGrid != null) {
//                 print('FieldValue ${displayOnGrid.FieldValue}');
              _DataCell.add(DataCell(Text(
                displayOnGrid.FieldName == "DocumentDate"
                    ? '${Other().DisplayDate(DateString(displayOnGrid.FieldValue))}'
                    : displayOnGrid.FieldName == "DocumentTotal"
                        ? '${HtmlUnescape().convert(_currencyCaption.Caption)} ' +
                            '${displayOnGrid.FieldValue}'
                        : '${displayOnGrid.FieldValue}',
                style: TextStyle(
                  fontSize: 16,
                ),
              )));
            }
          }
        }
        _DataRow.add(
          DataRow(cells: _DataCell),
        );
      }
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: DataTable(
          columns: _Datacolumn,
          rows: _DataRow,
        ),
      ),
    );
  }

  String DateString(String strDocDate) {
    try {
      final date = DateTime.parse(strDocDate);
      return date.toString();
    } catch (e) {
      final date = DateTime.now();
      return date.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    isLargeScreen = isLargeScreenAvailable(context);
    return ModalProgressHUD(
      inAsyncCall: isFullScreenLoading,
      opacity: 0.5,
      progressIndicator: CircularProgressIndicator(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppBarTitles.QUOTES),
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(widget.parentBuildContext);
              }),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            handleNewQuoteNavigation();
          },
          child: Icon(Icons.add),
        ),

        ///NOTIFICATION LISTENER ADDED TO LISTEN TO THE BOTTOM PAGE SCROLL
        ///TO LOAD NEW PAGE DATA FROM API
        body: Column(
          children: <Widget>[
            ///CUSTOMER SELECTOR
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
              child: Card(
                elevation: 1,
                child: ExpansionTile(
                  initiallyExpanded: isLargeScreen ? true : false,
                  title: Text('Search Quote'),
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        _commonWidgets.getListingCompanySelectorWidget(
                          showCompanyDialogHandler: this.showCompanyDialog,
                          clearSelectedCompanyHandler:
                              this.clearSelectedCompany,
                          selectedCompany: this._selectedCompany,
                        ),

                        ///STATUS DROPDOWN WIDGET
                        _buildStatusDropdown(),

                        ///SEARCH FIELD WIDGET
                        SearchTextField(
                          searchFieldContent: searchFieldContent,
                          clearTextFieldSearch: clearTextFieldSearch,
                          handleTextFieldSearch: handleTextFieldSearch,
                          placeHolder: 'Search Quote',
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
            SizedBox(height: 5.0),

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
                    isVisible:
                        (_selectedStatus.Code.toLowerCase() != "offline" &&
                                quotes.length < 1) ||
                            (_selectedStatus.Code.toLowerCase() == "offline" &&
                                    offlineQuotes.length < 1) &&
                                !isShowLoader,
                  ),

                  ///BUILDS SALES QUOTES LIST
                  _selectedStatus.Code.toLowerCase() == "offline"
                      ? isLargeScreen == true &&
                              offlineQuotes != null &&
                              offlineQuotes.length > 0
                          ? CreateTable()
                          : _buildOfflineQuoteList()
                      : isLargeScreen ? _buildTable() : _buildList(),
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
                                if (_selectedStatus.Code.toLowerCase() ==
                                    "offline") {
                                  fetchOfflineQuotesData();
                                } else {
                                  dataFetch();
                                }
                                isNextButtonDisabled = false;
                              });
                            },
                      color: Colors.blue,
                      child: Icon(
                        Icons.navigate_before,
                        color: Colors.white,
                      ),
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
                                if (_selectedStatus.Code.toLowerCase() ==
                                    "offline") {
                                  fetchOfflineQuotesData();
                                } else {
                                  dataFetch();
                                }
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
