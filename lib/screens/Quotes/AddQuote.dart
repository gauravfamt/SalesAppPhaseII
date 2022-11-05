import 'package:expandable/expandable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:http/http.dart' as http;
import 'package:moblesales/helpers/index.dart';
import 'package:moblesales/models/QuoteInvElement.dart';
import 'package:moblesales/models/index.dart';
import 'package:moblesales/models/otherParams.dart';
import 'package:moblesales/models/quoteInvoicingElement.dart';
import 'package:moblesales/screens/index.dart';
import 'package:moblesales/utils/Helper/AddQuote/QuoteInvoicingElementDBHelper.dart';
import 'package:moblesales/utils/index.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:core';

import 'package:modal_progress_hud/modal_progress_hud.dart';

class AddQuotePage extends StatefulWidget {
  final AddQuoteType addQuoteType;
  final int quoteId;
  final Quotes listingQuoteObj;
  final List<ProductQuantity> ProductQuantityList;
  final Company selectedCompany;
  final String PONumber;
  final String Note;
  final bool isOfflineQuote;

  AddQuotePage(
      {@required this.addQuoteType,
      this.quoteId = 0,
      this.listingQuoteObj,
      this.ProductQuantityList,
      this.selectedCompany,
      this.PONumber,
      this.Note,
      this.isOfflineQuote});

  @override
  _AddQuotePageState createState() => _AddQuotePageState();
}

class _AddQuotePageState extends State<AddQuotePage> {
  ///MAIN ADD_QUOTE_DB_HELPER CLASS OBJECT
  AddQuoteDBHelper _addQuoteDBHelper;

  ///MAIN ADD_QUOTE_HEADER_DB_HELPER CLASS OBJECT
  AddQuoteHeaderDBHelper _addQuoteHeaderDBHelper;

  ///MAIN ADD_QUOTE_DETAIL_DB_HELPER CLASS OBJECT
  AddQuoteDetailDBHelper _addQuoteDetailDBHelper;


  QuoteInvoicingElementDBHelper _quoteInvoicingElementDBHelper;

  ///HOLDS THE CLASS OBJECT WHICH PROVIDES STANDARD_FIELDS LOCAL TABLE CRUD OPERATIONS
  StandardFieldsDBHelper _standardFieldsDBHelper;

  ///MAIN COMPANY_DATABASE_HELPER CLASS OBJECT
  CompanyDBHelper _companyDBHelper;

  //Added by Mayuresh, 27-07-22
  ///MAIN COMPANY_DATABASE_HELPER CLASS OBJECT
  AddressDBHelper _addressDBHelper;

  ///MAIN SALES_SITE_DATABASE_HELPER CLASS OBJECT
  SalesSiteDBHelper _salesSiteDBHelper;

  ///MAIN PRODUCT_DATABASE_HELPER CLASS OBJECT
  ProductDBHelper _productDBHelper;

  ///HOLDS THE CLASS OBJECT WHICH CONTAINS THE REUSABLE WIDGETS
  CommonWidgets _commonWidgets;

  ///HOLDS ALL THE MAIN QUOTE OBJECT WHICH CONTAINS THE QUOTE_HEADERS AND QUOTE_DETAILS LIST
  AddQuote _quote;

  ///USED TO STORE THE WIDGET_CONTEXT FOR THE BACK NAVIGATION
  BuildContext widgetContext;

  ///TO IDENTIFY IF IT'S A INITIAL NAVIGATION TO THE WIDGET
  bool isInitialNavigation;

  ///USED TO HANDLE THE FULLSCREEN_LOADER JUST SET THE STATE TO THE TRUE TO START
  bool isFullScreenLoading;

  ///HOLDS THE COMPANY SELECTED FROM THE DROPDOWN
  Company selectedCompany;

  ///HANDLES THE FORM GLOBAL KEY FOR THE VALIDATIONS
  final _formKey = GlobalKey<FormState>();

  ///IT SETS SET FOR CUSTOMER CREDIT LIMIT EXCEEDS
  bool isCustomerCreditLimitExceeds;

  ///IT HOLDS ALL THE FORM_TF TEXT_STYLE
  final TextStyle _formTFTextStyle = TextStyle(
    color: AppColors.black,
    fontFamily: 'OpenSans',
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  //Added by Mayuresh, 27-07-22
  ///IT HOLDS ALL THE FORM_TF TEXT_STYLE
  final TextStyle _formDDTextStyle = TextStyle(
    color: AppColors.black,
    fontFamily: 'OpenSans',
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  ///HOLDS THE QUOTE_HEADER DATE_TF_CONTROLLER
  TextEditingController _dateController;

  ///HOLDS THE QUOTE_HEADER CUSTOMER_TF_CONTROLLER
  TextEditingController _customerTFController;

  ///HOLDS THE QUOTE_HEADER SALES_SITE_TF_CONTROLLER
  TextEditingController _salesSiteTFController;

  ///HOLDS STANDARD_FIELDS FOR THE QUOTE_HEADER ON_SCREEN ENTITY
  List<StandardField> _headersOnScreenStandardFields;

  ///HOLDS STANDARD_FIELDS FOR THE QUOTE_DETAIL ON_SCREEN ENTITY
  List<StandardField> _detailsOnScreenStandardFields;

  ///HOLDS STANDARD_FIELDS FOR THE QUOTE_HEADER ENTITY PREVIEW
  List<StandardField> _headersShowOnPreviewStandardFields;

  ///HOLDS STANDARD_FIELDS FOR THE QUOTE_DETAIL ENTITY PREVIEW
  List<StandardField> _detailsShowOnPreviewStandardFields;

  ///TO IDENTIFY IF ANY_ERROR IS OCCURRED WHILE LOADING THE PAGE
  bool _isPageLoadError;

  int _activeMeterIndex;

  ///HOLDS ALL THE NUMERIC TYPE FIELDS FOR THE QUOTE_DETAILS
  List<String> numericFieldNames = [
    'BasePrice',
//    'Quantity',
    'ExtAmount',
    'Weight',
    'Discount',
  ];

  ///HOLDS ALL THE FIELD_NAMES WHICH ARE READ_ONLY FIELDS
  List<String> readOnlyFieldNames = [
    'Description',
    'Weight',
    'ExtAmount',
    'BasePrice',
  ];

  ///HOLDS ALL THE FIELD_NAMES WHICH ARE TO BE EXCLUDED FROM QUOTE_HEADER_SECTION FIELDS
  List<String> quoteHeaderExcludedFieldNames = [
    'DocumentTotal',
    'Status',
  ];

  ///HOLDS THE PAGE LOAD ERROR MESSAGE
  final String _pageLoadErrorMsg =
      'Something went wrong! Please try again later';

  ///HOLDS ERROR TOAST MSG IF ANY ERROR OCCURRED WHILE ADDING THE QUOTE
  final String QUOTE_ADD_ERR_MSG = 'Try Again Later!';

  final String QUOTE_OFFLINE_SAVE_EXIT_MSG =
      'Do you want to save this quote offline and edit again later?';

  final String QUOTE_OFFLINE_EDIT_EXIT_MSG =
      'Do you want to save any changes made?';

  ///NETWORK_CONNECTION STREAM SUBSCRIPTION TO GET UPDATES WHEN APP IS ONLINE OR OFFLINE
  StreamSubscription _connectionChangeStream;

  ///HOLDS APP ONLINE/OFFLINE STATUS
  bool isOffline = false;

  ///TO FETCH THE CURRENCY DROPDOWN VALUES
  StandardDropDownFieldsDBHelper _standardDropDownFieldsDBHelper;

  ///HOLDS CURRENCY DROPDOWN FIELD
  StandardDropDownField _standardCurrencyDropDownField;

  ///HOLDS ERP DROPDOWN FIELD
  StandardDropDownField _standardERPDropDownField;

  ///HOLDS TAX DROPDOWN FIELD
  List<StandardDropDownField> _standardTaxDropDownFields;

  ///HOLDS TAX DROPDOWN FIELDS FOR UI
  List<DropdownMenuItem<StandardDropDownField>> taxDropDownMenuItems;

  ///HOLDS CURRENCY_SYMBOL
  String currencySymbol;

  ///HOLDS TOTAL WEIGHT FOR PREVIEW
  double totalWeight;

  List<ProductQuantity> ProductList;

  ///HOLDS TOTAL QUANTITY FOR PREVIEW
  int totalQuantity;

  ///HOLDS THE DOCUMENT TOTAL VALUE FOR PREVIEW OR IN CASE IF NEEDED FOR THE API CALL
  double documentTotal;

  ///TO IDENTIFY IF THE CREATE FORM CLICKED OR NOT TO ENABLE AND DISABLE THE FIELDS AUTO VALIDATION OPTION
  bool isInitialCreateQuoteCLicked;

  //Button Enabled Desable
  bool isSubmitButtonDisabled;

  bool isHeaderLoded;
  bool isDetailsLoded;

  bool isProductRealTimeDataLoded;
  List<ProductRealTimePrice> ProductRealTimePriceData;

  ///IT HOLDS PRODUCT LAST_PRICE_LOOKUP
  ProductLastPrice _productLastPrice;

  TextEditingController poNumberController;
  TextEditingController noteController;

  int intOfflineSaveQuoteCount;

  bool isProductLoaded;

  bool isValidateButtonDesable;

  String userSalesSiteCode;

  //to store newly added quote details ids
  List<String> NewQuoteDetailsIds;

  //to identify integration status
  bool isIntegrated = false;

  List<ProductQuantity> zeroPriceProduct;

  //Added by Gaurav to disply snackbar, 04-03-2022
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();

  //Added by Mayuresh, 24-07-22
  //Intial Timer for AutoSaving Purposes
  Timer intialSaveQuote;

  ///Timer for AutoSaving Purposes
  Timer saveQuote;

  ///Duration for AutoSaving Purposes
  Duration intervalDuration;

  ///Integer to append to Duration for AutoSaving Purposes
  int intervalValue;

  ///Boolean to enable AutoSaving Feature
  bool quoteAutoSaved = false;

  ///Stores Shipping Address Value
  String shippingAddressCode;

  ///Stores Shipping Address List
  Map<String, dynamic> shippingAddresses = {};

  ///Stores Invoicing Elements List
  List<InvoicingElement> invoicingElement = <InvoicingElement>[];

  ///Stores Invoicing Elements List
  List<QuoteInvElement> quoteInvElement = <QuoteInvElement>[];

  List<QuoteInvoicingElement> quoteInvoivingElement = <QuoteInvoicingElement>[];
  ///Invoicing Element DB
  InvoicingElementDBHelper invoicingElementDBHelper = new InvoicingElementDBHelper();
  ///Check if any dialog is open
  bool isDialogOpen = false;

  final List<TextEditingController> invoicingElementTextEditingController = new List();
  @override
  void initState() {
    super.initState();
    print('AddQuoteType Opened Type : ${widget.addQuoteType}');
    totalWeight = 0.0;
    totalQuantity = 0;
    documentTotal = 0.0;
    _isPageLoadError = false;
    isCustomerCreditLimitExceeds = false;
    isInitialCreateQuoteCLicked = true;
    _quote = AddQuote();
    selectedCompany = widget.selectedCompany;
    _productLastPrice = new ProductLastPrice();
    _commonWidgets = CommonWidgets();
    _addQuoteDBHelper = AddQuoteDBHelper();
    _companyDBHelper = CompanyDBHelper();
    _addressDBHelper = AddressDBHelper();
    _productDBHelper = ProductDBHelper();
    _salesSiteDBHelper = SalesSiteDBHelper();
    _dateController = TextEditingController();
    _addQuoteHeaderDBHelper = AddQuoteHeaderDBHelper();
    _addQuoteDetailDBHelper = AddQuoteDetailDBHelper();
    _quoteInvoicingElementDBHelper=QuoteInvoicingElementDBHelper();
    _standardFieldsDBHelper = StandardFieldsDBHelper();
    _headersShowOnPreviewStandardFields = List<StandardField>();
    _detailsShowOnPreviewStandardFields = List<StandardField>();
    _salesSiteTFController = TextEditingController();
    if (selectedCompany != null) {
      _customerTFController = TextEditingController(
          text: '${selectedCompany.Name} (${selectedCompany.CustomerNo})');
    } else {
      _customerTFController = TextEditingController(text: 'Select Customer');
    }
    zeroPriceProduct = List<ProductQuantity>();
    ProductRealTimePriceData = List<ProductRealTimePrice>();

    ///Added by Mayuresh - S, 24-07-22
    ///Sets the Timer and Duration
    intervalValue = 60;
    quoteAutoSaved = false;

    ///Shipping Addresses Variables
    shippingAddressCode = '';
    shippingAddresses = {};

    ///Dialog Check Variable
    isDialogOpen = false;

    ///Intializes Invoicing Elements List
    invoicingElement = <InvoicingElement>[];

    quoteInvElement=<QuoteInvElement>[];
    quoteInvoivingElement=<QuoteInvoicingElement>[];

    ///Intialize DB Helpers
    invoicingElementDBHelper = new InvoicingElementDBHelper();
    ///Added by Mayuresh - E
    isInitialNavigation = true;
    isFullScreenLoading = true;
    isSubmitButtonDisabled = true;
    isValidateButtonDesable = false;
    isHeaderLoded = false;
    isDetailsLoded = false;
    isProductRealTimeDataLoded = false;
    isProductLoaded = false;
    ApiService.getAutoSaveQuoteInterval().then((value) {
      ///Sets Interval Value from Customer Web Portal
      intervalValue = value;
      intervalDuration = new Duration(seconds: intervalValue);
      isFullScreenLoading = false;
      _headersOnScreenStandardFields = List<StandardField>();
      _detailsOnScreenStandardFields = List<StandardField>();

      ///GETTING CONNECTION_SERVICE SINGLETON INSTANCE AND SUBSCRIBING TO CONNECTION_CHANGE EVENTS
      ConnectivityService connectionStatus = ConnectivityService.getInstance();
      _connectionChangeStream =
          connectionStatus.connectionChange.listen(connectionChanged);

      _standardDropDownFieldsDBHelper = StandardDropDownFieldsDBHelper();
      _standardCurrencyDropDownField = StandardDropDownField();
      _standardERPDropDownField = StandardDropDownField();
      _standardTaxDropDownFields = List<StandardDropDownField>();
      taxDropDownMenuItems = List();
      currencySymbol = '';

      setUserSalesSite();

      ///FIRST FETCHING TAX FIELD FROM DB
      fetchTaxDropDownValue();
      isSubmitButtonDisabled = true;
      isValidateButtonDesable = false;

      isOffline = ConnectionStatus.isOffline;
      isHeaderLoded = false;
      isDetailsLoded = false;
      isProductRealTimeDataLoded = false;
      intOfflineSaveQuoteCount = 0;
      userSalesSiteCode = '';

      poNumberController = TextEditingController();
      noteController = TextEditingController();
      isProductLoaded = false;
      if (widget.PONumber != null) {
        poNumberController.text = widget.PONumber.toString();
      }
      if (widget.Note != null) {
        noteController.text = widget.Note.toString();
      }
      NewQuoteDetailsIds = List<String>();
    }).catchError((err) {
      ///Sets the default value for Interval
      intervalDuration = new Duration(seconds: intervalValue);
      isFullScreenLoading = false;
      _headersOnScreenStandardFields = List<StandardField>();
      _detailsOnScreenStandardFields = List<StandardField>();

      ///GETTING CONNECTION_SERVICE SINGLETON INSTANCE AND SUBSCRIBING TO CONNECTION_CHANGE EVENTS
      ConnectivityService connectionStatus = ConnectivityService.getInstance();
      _connectionChangeStream =
          connectionStatus.connectionChange.listen(connectionChanged);

      _standardDropDownFieldsDBHelper = StandardDropDownFieldsDBHelper();
      _standardCurrencyDropDownField = StandardDropDownField();
      _standardERPDropDownField = StandardDropDownField();
      _standardTaxDropDownFields = List<StandardDropDownField>();
      taxDropDownMenuItems = List();
      currencySymbol = '';

      setUserSalesSite();

      ///FIRST FETCHING TAX FIELD FROM DB
      fetchTaxDropDownValue();
      isSubmitButtonDisabled = true;
      isValidateButtonDesable = false;

      isOffline = ConnectionStatus.isOffline;
      isHeaderLoded = false;
      isDetailsLoded = false;
      isProductRealTimeDataLoded = false;
      intOfflineSaveQuoteCount = 0;
      userSalesSiteCode = '';

      poNumberController = TextEditingController();
      noteController = TextEditingController();
      isProductLoaded = false;
      if (widget.PONumber != null) {
        poNumberController.text = widget.PONumber.toString();
      }
      if (widget.Note != null) {
        noteController.text = widget.Note.toString();
      }
      NewQuoteDetailsIds = List<String>();
    });
  }

  Future<void> setUserSalesSite() async {
    userSalesSiteCode = await Session.getSalesSiteCode();
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

  void AddProductData(int quotePosition) {
    if (widget.ProductQuantityList != null) {
      print('Adding Product Data');
      // print('widget.ProductQuantityList ${widget.ProductQuantityList.length}');
      if (widget.ProductQuantityList.length > 0) {
        if (isProductRealTimeDataLoded == false) {
          GetProductRealTimeAPIData(quotePosition);
        } else {
          if (isHeaderLoded == isDetailsLoded && isProductLoaded == false) {
            setState(() {
              isFullScreenLoading = true;
            });
            for (int i = 0; i < widget.ProductQuantityList.length; i++) {
              // print( 'Product :${widget.ProductQuantityList[i].ProductObject .ProductCode}');
              OtherParam otherParam; //Added by Gaurav Gurav, 24-Aug-2022
              if (ProductRealTimePriceData.length > 0) {
                var productPrice = ProductRealTimePriceData.firstWhere(
                    (e) =>
                        e.ProductCode ==
                        widget.ProductQuantityList[i].ProductObject.ProductCode,
                    orElse: () => null);
                if (productPrice != null) {
                  //  print('Real time Price ${productPrice.Price} ');
                  widget.ProductQuantityList[i].ProductObject.BasePrice =
                      productPrice.Price;
                  otherParam=productPrice.otherParams;//Added by Gaurav Gurav, 24-Aug-2022
                }
              }
              addQuoteDetailWithProductQuantityData(
                quote: _quote,
                isLoadingLocalQuote: 1,
                ProductObj: widget.ProductQuantityList[i].ProductObject,
                Quantity: widget.ProductQuantityList[i].Quantity,
                otherParam:otherParam ,
                quotePosition: quotePosition + i,
              );
              //To exapand last product details
              _activeMeterIndex = quotePosition + i;
            }
            setState(() {
              isProductLoaded = true;
              isFullScreenLoading = true;
            });
          }
        }
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _customerTFController.dispose();
    _salesSiteTFController.dispose();
    _dateController.dispose();
    //Added by Mayuresh 27-07-22
    if (intialSaveQuote.isActive) {
      print("Stops intial Timer");
      intialSaveQuote.cancel();
    }
    if (saveQuote.isActive) {
      print("Stops Peroidic Method");
      saveQuote.cancel();
    }

    if (_quote.Id != null && _quote.QuoteDetail.length > 0)
      _quote.QuoteDetail.forEach((singleQuoteObj) {
        if (singleQuoteObj.QuoteDetailFields.length > 0)

          ///DISPOSING ALL THE TEXT_FIELD_CONTROLLERS ASSIGNED TO EACH
          ///TFF OR TF TO AVOID ANY MEMORY LEAKS
          singleQuoteObj.QuoteDetailFields.forEach((singleQuoteListField) {
            singleQuoteListField.textEditingController.dispose();
          });
      });

    if (_quote.Id != null && _quote.QuoteHeader.length > 0)
      _quote.QuoteHeader.forEach((singleQuoteObj) {
        if (singleQuoteObj.QuoteHeaderFields.length > 0)

          ///DISPOSING ALL THE TEXT_FIELD_CONTROLLERS ASSIGNED TO EACH
          ///TFF OR TF TO AVOID ANY MEMORY LEAKS
          singleQuoteObj.QuoteHeaderFields.forEach((singleQuoteListField) {
            if (singleQuoteListField.textEditingController != null)
              singleQuoteListField.textEditingController.dispose();
          });
      });
  }

  ///SETS THE CONNECTION STATUS DEPENDING ON THE CONNECTION_SERVICE SUBSCRIPTION LISTEN EVENTS

  ///FETCHES Tax DROPDOWN VALUE
  void fetchTaxDropDownValue() async {
    _standardDropDownFieldsDBHelper
        .getEntityStandardDropdownFieldsData(
          entity: StandardEntity.TAX_DROPDOWN_ENTITY,
          searchText: '',
        )
        .then((value) => {
              if (value.length > 0)
                {
                  this.setState(() {
                    _standardTaxDropDownFields.addAll(value);

                    ///BUILDING THE TAX DROPDOWN MENU LIST
                    value.forEach((element) {
                      taxDropDownMenuItems.add(
                        DropdownMenuItem(
                          child: Text(
                            '${element.Code}',
                            style: TextStyle(
                                color: AppColors.black, fontSize: 15.0),
                          ),
                          value: element,
                        ),
                      );
                    });
                  }),
                  fetchCurrencyDropDownValue(),
                }
              else
                {
                  // print( 'Tax DropDown Entry not present at localDB for addQuoteScreen'),
                  showErrorToast('Try again later!'),
                }
            })
        .catchError((e) => {
              print(
                  'Error while fetching Tax dropdown fields from LocalDB for addQuoteScreen'),
              print(e),
              showErrorToast('Try again later!'),
            });
  }

  ///FETCHES CURRENCY DROPDOWN VALUE
  void fetchCurrencyDropDownValue() async {
    _standardDropDownFieldsDBHelper
        .getEntityStandardDropdownFieldsData(
          entity: StandardEntity.CURRENCY_DROPDOWN_ENTITY,
          searchText: DropdownSearchText.CURRENCY_DROPDOWN_SEARCH_TEXT,
        )
        .then((value) => {
              if (value.length > 0)
                {
                  this.setState(() {
                    _standardCurrencyDropDownField = value[0];
                    currencySymbol = _standardCurrencyDropDownField.Caption !=
                            null
                        ? '${HtmlUnescape().convert(_standardCurrencyDropDownField.Caption)}'
                        : '';
                  }),
                  fetchERPDropDownValue(),
                }
              else
                {
                  print(
                      'Currency DropDown Entry not present at localDB for ProductLastPriceLookup'),
                  fetchERPDropDownValue(),
                }
            })
        .catchError((e) => {
              print(
                  'Error while fetching currency dropdown fields from LocalDB for ProductLastPriceLookup'),
              print(e),
              fetchERPDropDownValue(),
            });
  }

  ///FETCHES ERP DROPDOWN VALUE
  void fetchERPDropDownValue() async {
    _standardDropDownFieldsDBHelper
        .getEntityStandardDropdownFieldsData(
          entity: StandardEntity.ERP_DROPDOWN_ENTITY,
          searchText: '',
        )
        .then((value) => {
              if (value.length > 0)
                {
                  this.setState(() {
                    _standardERPDropDownField = value[0];
                  }),
                  // fetchQuoteHeaderOnScreenFields(),
                  fetchShippingAddressesValue(),
                }
              else
                {
                  print(
                      'ERP DropDown Entry not present at localDB for REAL-TIME-PRICING AND QUANTITY '),
                  // fetchQuoteHeaderOnScreenFields(),
                  fetchShippingAddressesValue(),
                }
            })
        .catchError((e) => {
              print(
                  'Error while fetching ERP dropdown fields from LocalDB for REAL_TIME_PRICING AND QUANTITY'),
              print(e),
              // fetchQuoteHeaderOnScreenFields(),
              fetchShippingAddressesValue(),
            });
  }

  ///FETCHES COMPANY'S ADDRESSES VALUE
  void fetchShippingAddressesValue() async {
    // print("fetchShippingAddressesValue");
    // print(widget.listingQuoteObj.CustomerNo);
    String customerNo = selectedCompany != null
        ? selectedCompany.CustomerNo
        : widget.listingQuoteObj.CustomerNo;
    _addressDBHelper
        .getAddressByCustomerNo(customerNo: customerNo)
        .then((addressRes) {
      if (addressRes.length > 0) {
        //Adds Single Values
//        shippingAddresses[""] = "";
//        shippingAddressCode = "";
        //Attaches Addresses
        if (addressRes.isNotEmpty) {
          shippingAddresses.addEntries(addressRes
              .where((e) => e.IsShipping)
              .map((e) => MapEntry(buildAddressString(e), e.Code)));
          if (selectedCompany != null &&
              selectedCompany.DefaultShippAdd != null) {
            shippingAddressCode = selectedCompany.DefaultShippAdd;
            if (!shippingAddresses
                    .containsValue(selectedCompany.DefaultShippAdd) &&
                selectedCompany.DefaultShippAdd != null) {
              shippingAddresses[selectedCompany.DefaultShippAdd] =
                  selectedCompany.DefaultShippAdd;
            }
          } else {
            shippingAddressCode = widget.listingQuoteObj.ShippingAddressCode;
            if (!shippingAddresses.containsValue(
                    widget.listingQuoteObj.ShippingAddressCode) &&
                widget.listingQuoteObj.ShippingAddressCode != null) {
              shippingAddresses[widget.listingQuoteObj.ShippingAddressCode] =
                  widget.listingQuoteObj.ShippingAddressCode;
            }
          }
        }
        fetchInvoicingElements();
      } else {
        print('Company not present in localDB for SHIPPING ADDRESSES');
        // fetchQuoteHeaderOnScreenFields();
        fetchInvoicingElements();
      }
    }).catchError((e) => {
              print(
                  'Error while fetching Customer\'s dropdown fields from LocalDB for SHIPPING ADDRESSES'),
              print(e),
              // fetchQuoteHeaderOnScreenFields(),
              fetchInvoicingElements(),
            });
  }

  ///Builds Address String for the Dropdown
  String buildAddressString(Address address) {
    try {
      String formattedAddress = "";
      if (address.Address1.isNotEmpty) formattedAddress += address.Address1;
      if (address.City.isNotEmpty) formattedAddress += " " + address.City;
      if (address.PostCode.isNotEmpty)
        formattedAddress += " " + address.PostCode;
      if (address.State.isNotEmpty) formattedAddress += " " + address.State;
      if (address.Country.isNotEmpty) formattedAddress += " " + address.Country;
      print ('formattedAddress----${formattedAddress}');
      return formattedAddress;
    } catch (e) {
      print("Error in buildAddressString");
      print(e);
      return "";
    }
  }

  void fetchInvoicingElements() {
    try {
      invoicingElementDBHelper.getAllInvoiceElements().then((invElementsRes) {
        print("Fill Sales Invoice Elements");
          for (InvoicingElement element in invElementsRes) {
            quoteInvElement.add(new QuoteInvElement(invoicingElement:element,quoteHeaderId: 0,invoicingElementvalue: 0,txtValue: '') );
          }
          fetchQuoteHeaderOnScreenFields();

      }).catchError((err) {
        print('Error while fetching Invoicing Elements from LocalDB');
        print(err);
        fetchQuoteHeaderOnScreenFields();
      });
    } catch (e) {
      print("Error in fetchInvoicingElements");
      print(e);
      fetchQuoteHeaderOnScreenFields();
    }
  }

  ///IT FETCHES THE ORDER_HEADER STANDARD FIELDS FIELDS FROM THE LOCAL DATABASE FOR ON_SCREEN_SHOW FIELDS SHOW
  void fetchQuoteHeaderOnScreenFields() {
    _standardFieldsDBHelper
        .getEntityStandardFieldsData(
          entity: StandardEntity.QUOTE_HEADER,
          showInGrid: false,
          showOnScreen: true,
        )
        .then((value) => {
              ///HERE CHECKING IF STANDARD FIELDS RESPONSE DID'T RECEIVED THEN NOT CALLING THE GET_DATA_API
              if (value.length > 0)
                {
                  ///SORTING THE STANDARD_FIELDS ACCORDING TO SORT_ORDER
                  value.sort((a, b) => a.SortOrder.compareTo(b.SortOrder)),
                  setState(() {
                    _headersOnScreenStandardFields = value;

                    _headersOnScreenStandardFields.removeWhere(
                        (element) => element.FieldName == 'SalesSite');

                    _headersOnScreenStandardFields.removeWhere(
                            (element) => element.FieldName == 'CustomerName');
                  }),
                  ///CALLING THE QUOTE_DETAILS STANDARD FIELDS FETCH API
                  fetchQuoteDetailOnScreenFields(),

                  // AddProductData(),
                }
              else
                {
                  print(
                      'Standard Fields not available for the OrderHeader Entity '),
                  showErrorToast('Try again later!'),
                }
            })
        .catchError((onError) => {
              print(
                  'Error while fetching OnScreen StandardFields for the OrderHeader Entity on ADD_Quote page'),
              print(onError),
              showErrorToast('Try again later!')
            });
  }

  ///IT FETCHES THE ORDER_DETAIL STANDARD FIELDS FROM THE LOCAL DATABASE FOR ON_SCREEN_SHOW FIELDS SHOW
  void fetchQuoteDetailOnScreenFields() {
    _standardFieldsDBHelper
        .getEntityStandardFieldsData(
          entity: StandardEntity.QUOTE_DETAIL,
          showInGrid: false,
          showOnScreen: true,
        )
        .then((value) => {
              ///HERE CHECKING IF STANDARD FIELDS RESPONSE DID'T RECEIVED THEN NOT CALLING THE GET_DATA_API
              if (value.length > 0)
                {
                  ///SORTING THE STANDARD_FIELDS ACCORDING TO SORT_ORDER
                  value.sort((a, b) => a.SortOrder.compareTo(b.SortOrder)),
                  setState(() {
                    _detailsOnScreenStandardFields = value;
                  }),

                  ///CALLING THE QUOTE_HEADERS SHOW_ON_PREVIEW STANDARD FIELDS FETCH FROM LOCAL_DATABASE
                  fetchQuoteHeaderShowOnPreviewFields(),
                }
              else
                {
                  print(
                      'Standard Fields not available for the Order_detail Entity '),
                  showErrorToast('Try again later!'),
                }
            })
        .catchError((onError) => {
              print(
                  'Error while fetching OnScreen StandardFields for the QuoteDetail Entity on ADD_Quote page'),
              print(onError),
              showErrorToast('Try again later!')
            });
  }

  ///IT FETCHES THE ORDER_HEADER STANDARD FIELDS FIELDS FROM THE LOCAL DATABASE FOR SHOW_ON_PREVIEW FIELDS SHOW
  void fetchQuoteHeaderShowOnPreviewFields() {
    _standardFieldsDBHelper
        .getEntityStandardFieldsData(
          entity: StandardEntity.QUOTE_HEADER,
          showInGrid: false,
          showOnScreen: false,
          showOnPreview: true,
        )
        .then((value) => {
              ///HERE CHECKING IF STANDARD FIELDS RESPONSE DID'T RECEIVED THEN NOT CALLING THE GET_DATA_API
//              if (value.length > 0)
//                {
              ///IF PREVIEW FIELDS ARE NOT AVAILABLE THEN DO NOT SHOW THE PREVIEW
              if (value.length > 0)
                {
                  ///SORTING THE STANDARD_FIELDS ACCORDING TO SORT_ORDER
                  value.sort((a, b) => a.SortOrder.compareTo(b.SortOrder)),
                  setState(() {
                    _headersShowOnPreviewStandardFields = value;
                  }),
                },

              ///CALLING THE QUOTE_DETAILS SHOW_ON_PREVIEW STANDARD FIELDS FETCH FROM LOCAL_DATABASE
              fetchQuoteDetailShowOnPreviewFields(),
//                }
//              else
//                {
//                  print(
//                      'Standard Fields not available for the OrderHeader Entity Preview'),
////                  showErrorToast('Try again later!'),
//                }
            })
        .catchError((onError) => {
              print(
                  'Error while fetching ShowOnPreview StandardFields for the OrderHeader Entity on ADD_Quote page'),
              print(onError),
              showErrorToast('Try again later!')
            });
  }

  ///IT FETCHES THE ORDER_DETAIL STANDARD FIELDS FROM THE LOCAL DATABASE FOR SHOW_ON_PREVIEW FIELDS SHOW
  void fetchQuoteDetailShowOnPreviewFields() {
    _standardFieldsDBHelper
        .getEntityStandardFieldsData(
          entity: StandardEntity.QUOTE_DETAIL,
          showInGrid: false,
          showOnScreen: false,
          showOnPreview: true,
        )
        .then((value) => {
              //Starts TImer
              startTimer(),
              // print('QUOTE_DETAIL Show On Preview Fields Response $value'),

              ///HERE CHECKING IF STANDARD FIELDS RESPONSE DID'T RECEIVED THEN NOT CALLING THE GET_DATA_API
//              if (value.length > 0)
//                {
              ///IF PREVIEW FIELDS NOT AVAILABLE THEN DO NOT ALLOW TO OPEN THE PREVIEW SCREEN
              if (value.length > 0)
                {
                  ///SORTING THE STANDARD_FIELDS ACCORDING TO SORT_ORDER
                  value.sort((a, b) => a.SortOrder.compareTo(b.SortOrder)),
                  setState(() {
                    _detailsShowOnPreviewStandardFields = value;
                  }),
                },
              if (widget.addQuoteType == AddQuoteType.NEW_QUOTE)
                {
                  ///FOR CREATING NEW QUOTE
                  addNewQuote(
                    isLocalQuote: 1,
                    serverUpdatedDate: null,
                    serverQuoteId: -1,
                  ),
                }
              else if (widget.addQuoteType == AddQuoteType.EDIT_OFFLINE_QUOTE)
                {
                  ///FOR EDITING OFFLINE CREATED QUOTE
                  bindOfflineQuoteData(
                    quoteId: widget.quoteId,
                  ),
                }
              else if (widget.addQuoteType == AddQuoteType.EDIT_CREATED_QUOTE &&
                  widget.listingQuoteObj != null)
                {
                  ///FOR HANDLING QUOTES WHICH ARE EDITED FROM THE QUOTES LISTING PAGE
                  // bindListingEditedQuoteData(),
                  // To avoid syn with erp
                  UpdateQuoteStatus(IsEdit: true),
                  //  print('count ${widget.listingQuoteObj.Quotedetail.length}'),
                }
              else
                {
                  ///IF NO QUOTE_TYPE PROVIDED THEN NOT LOADING PAGE
                  //  print('addQuoteType Not sent for the AddQuotePage '),
                  showErrorToast('Try again later!'),
                }
            })
        .catchError((onError) => {
              print(
                  'Error while fetching ShowOnPreview StandardFields for the QuoteDetail Entity on ADD_Quote page'),
              print(onError),
              showErrorToast('Try again later!')
            });
  }

  ///IT SHOWS THE FLUTTER ERROR TOAST IF API ERROR IS RETURNED
  void showErrorToast(String msg) {
    setState(() {
      isFullScreenLoading = false;
      _isPageLoadError = true;
    });
    _commonWidgets.showFlutterToast(toastMsg: msg);
  }

  ///IT HANDLES THE ERROR TOAST SHOW AND LOCAL_DB_QUOTE ENTRY DELETE
  void handleAddQuoteError({
    int quoteId,
  }) {
    this.showErrorToast(QUOTE_ADD_ERR_MSG);
    if (quoteId != -1) deleteQuoteByID(quoteId: quoteId);
  }

  void UpdateQuoteStatus({
    bool IsEdit = true,
  }) async {
    print('inside UpdateQuoteStatus');
    try {
      String requestBody = '{';
      requestBody += '"Id" : "${widget.listingQuoteObj.Id}",';
      requestBody += '"DocumentNo" : "${widget.listingQuoteObj.DocumentNo}",';
      requestBody += '"IsEdit" : "$IsEdit",';
      requestBody += '"IsIntegrated" : "false"';
      requestBody += '}';
      // print('Request Body: $requestBody');
      ApiService.updateQuoteById(
        requestBody: requestBody,
      )
          .then((value) => {
                if (!value.toString().contains('Error'))
                  {
                    //  print('value $value'),
                    ActionAfterStatusChange(IsEdit),
                    //bindListingEditedQuoteData(),
                  }
              })
          .catchError((e) => {
                // print('UpdateQuoteStatus Error Response $e'),
                ActionAfterStatusChange(IsEdit),
                // bindListingEditedQuoteData(),
              });
    } catch (e) {
      // bindListingEditedQuoteData();
      ActionAfterStatusChange(IsEdit);
      print(
          'Error while calling multiple realtime APIs So calling normal flow');
      print(e);
    }
  }

  void ActionAfterStatusChange(bool IsEdit) {
    if (IsEdit == true) {
      bindListingEditedQuoteData();
    } else {
      //User don't save quote online ouote in offline mode
      deleteQuoteByID(
        quoteId: _quote.Id,
        isDeleteOnExit: true,
      );
    }
  }

  ///IT HANDLES THE QUOTE_LISTING PAGE SINGLE QUOTE EDIT
  ///HANDLES QUOTE NEW ENTRY/ EXISTING EDITED DATA UPDATE

  void bindListingEditedQuoteData() async {
    try {
      DateTime _localServerUpdatedDate;
      DateTime _serverUpdatedDate;

      ///FETCHING OFFLINE QUOTE ENTRY IF EXISTED IN LOCAL_DATABASE
      _addQuoteDBHelper
          .fetchQuoteByServerQuoteId(
            serverQuoteId: widget.listingQuoteObj.Id,
          )
          .then((localAddQuotesRes) => {
                //  print('localAddQuotesRes : $localAddQuotesRes'),

                ///IF SERVER's EDITED QUOTE ENTRY FOUND TO THE LOCAL_DATABASE THEN CHECKING ENTRY IS
                ///UPDATED OR NOT OTHERWISE CREATING NEW ENTRY TO LOCAL_DATABASE
                if (localAddQuotesRes.length > 0)
                  {
                    ///PARSING LOCAL_DB ENTRY SERVER_UPDATED_DATE STRING
                    _localServerUpdatedDate = DateTime.parse(
                        localAddQuotesRes[0].UpdatedDate.toString()),
                    //   print('_localUpdatedDate $_localServerUpdatedDate'),
                    ///PARSING QUOTE's UPDATED_DATE STRING
                    _serverUpdatedDate =
                        DateTime.parse(widget.listingQuoteObj.UpdatedDate),
                    //   print('_serverUpdatedDate $_serverUpdatedDate'),
                    //   print ('difference ${_serverUpdatedDate.difference(_localServerUpdatedDate)}'),

                    ///HERE CHECKING IF QUOTE's SERVER UPDATED DATE IS GREATER THAN LOCAL DATE THEN DELETING
                    ///LOCAL_DATA AND INSERTING QUOTE_UPDATED DATA
                    if (_serverUpdatedDate.difference(_localServerUpdatedDate) >
                        Duration(
                          days: 0,
                          hours: 0,
                          microseconds: 0,
                          milliseconds: 0,
                          minutes: 0,
                          seconds: 0,
                        ))
                      {
                        ///AS SERVER's EDITED QUOTE ENTRY IS UPDATED THEN DELETING OLD LOCAL DATA AND INSERTING NEW UPDATED DATA
                        handleServerQuoteDataToLocal(
                          quoteLocalData: localAddQuotesRes[0],
                        ),
                      }
                    else
                      {
                        print(
                            'Loading offline data as servers data is not updated '),

                        ///LOCAL_DATABASE PRESENT UPDATED DATA AS SERVER
                        ///SO LOADING EDIT QUOTE DATA FORM LOCAL
                        bindOfflineQuoteData(
                          quoteId: localAddQuotesRes[0].Id,
                        ),
                      },
                  }
                else
                  {
                    ///HERE IF SERVER EDITED QUOTE ENTRY DOES NOT EXISTS IN LOCAL_DATABASE THEN CREATING
                    ///NEW ENTRY TO THE LOCAL_DATABASE
                    addNewQuote(
                      isLocalQuote: 0,
                      serverQuoteId: widget.listingQuoteObj.Id,
                      serverUpdatedDate: widget.listingQuoteObj.UpdatedDate,
                    ),
                  },
              })
          .catchError((e) => {
                print('Error while fetching ServerEditedQuote from localDB'),
                showErrorToast('Something went wrong! Try again later'),
              })
          .whenComplete(() => {
                setState(() {
                  isHeaderLoded = true;
                  print('isHeaderLoded');
                }),
                print('Length ${widget.listingQuoteObj.Quotedetail.length}'),
                AddProductData(widget.listingQuoteObj.Quotedetail.length),
              });
    } catch (e) {
      print('Error Inside bindListingEditedQuoteData Fn ');
      print(e);
      showErrorToast('Try Again Later');
    }
  }

  ///IT HANDLES SERVER's QUOTE DATA TO LOCAL_DATABASE AND THEN BINDS NEW DATA TO ADD_QUOTE_SCREEN
  void handleServerQuoteDataToLocal({
    AddQuote quoteLocalData,
  }) async {
    try {
      print('handleServerQuoteDataToLocal');

      ///DELETING OLD QUOTE_HEADERS DATA TO INSERT UPDATED SERVER's DATA
      var _quoteHeaderDeleteRes = await _addQuoteHeaderDBHelper
          .deleteRowByQuoteId(addQuoteId: quoteLocalData.Id);
      print(
          'Quote Headers Delete By QuoteID $_quoteHeaderDeleteRes for updating new data from server');

      ///DELETING OLD QUOTE_DETAILS DATA TO INSERT UPDATED SERVER's DATA
      var _quoteDetailDeleteRes = await _addQuoteDetailDBHelper
          .deleteRowByQuoteId(addQuoteId: quoteLocalData.Id);
      print(
          'Quote Details Delete By QuoteID $_quoteDetailDeleteRes for updating new data from server');

      //Added By Gaurav
      var _quoteDeleteRes =
          await _addQuoteDBHelper.deleteRowById(addQuoteId: quoteLocalData.Id);
      print('Quote Delete By QuoteID Res $_quoteDeleteRes');

      quoteLocalData.QuoteHeader = List<AddQuoteHeader>();
      quoteLocalData.QuoteDetail = List<AddQuoteDetail>();

      ///SETTING THE LOCAL_QUOTE STATE FOR THE UI
      this.setState(() {
        _quote = quoteLocalData;
      });

      ///ADDING THE NEW HEADERS AND DETAILS OF THE QUOTE
//      this.addQuoteHeader(
//        quote: _quote,
//        isInitialLoading: true,
//        isLoadingLocalQuote: 0,
//      );

      addNewQuote(
        isLocalQuote: 0,
        serverQuoteId: widget.listingQuoteObj.Id,
        serverUpdatedDate: widget.listingQuoteObj.UpdatedDate,
      );
    } catch (e) {
      print('Error inside handleServerQuoteDataToLocal Fn ');
      print(e);
      showErrorToast('Something went wrong! Try again later');
    }
  }

  ///IT BINDS THE OFFLINE QUOTE DATA TO THE ADD_QUOTE PAGE
  void bindOfflineQuoteData({
    int quoteId,
  }) async {
    try {
      _addQuoteDBHelper
          .getQuotes(
            quoteId: quoteId,
          )
          .then((quotesRes) => {
                if (quotesRes.length > 0)
                  {
                    fetchOfflineQuoteSelectedLookupsValues(
                      quoteObj: quotesRes[0],
                    ),
                  }
                else
                  {
                    print('Offline Quote Not found '),
                    showErrorToast('Try Again Later'),
                  }
              })
          .catchError((e) {
        print('Error while binding Offline quote to the AddQuotePage ');
        print(e);
        showErrorToast('Try Again Later');
      });
    } catch (e) {
      print(
          'Error inside bindOfflineQuoteData Fn while binding Offline QuoteData for Editing');
      print(e);
      showErrorToast('Try Again Later');
    }
  }

  ///IT FETCHES THE SELECTED LOOKUP'S VALUES FROM THE LOCAL_DB FOR BINDING TO THE UI

  void fetchOfflineQuoteSelectedLookupsValues({
    AddQuote quoteObj,
  }) async {
    try {
      ///HOLDS PRODUCT'S ID'S SELECTED FOR QUOTE_DETAILS
      setState(() {
        intOfflineSaveQuoteCount = quoteObj.QuoteDetail.length;
      });
      List<String> _quoteDetailProductIds = List<String>();
      quoteObj.QuoteDetail.forEach((singleQuoteDetail) {
        singleQuoteDetail.product = Product();
        singleQuoteDetail.QuoteDetailFields.forEach((singleField) {
          String _fieldValue = (singleField.FieldValue != null &&
                  singleField.FieldValue != 'null')
              ? singleField.FieldValue.toString().trim()
              : '';
          if (singleField.FieldName == 'ProductCode') {
            if (_fieldValue != 'Select Product') {
              _quoteDetailProductIds.add(_fieldValue);
              singleQuoteDetail.product.ProductCode = _fieldValue;
            }
            singleField.textEditingController = new TextEditingController(
                text: '${_fieldValue != '' ? _fieldValue : 'Select Product'}');
          } else if (singleField.FieldName == 'Quantity') {
            //  print('Quantity Value: ${_fieldValue == '' ? 1 : _fieldValue}');
            singleField.textEditingController = new TextEditingController(
                text:
                    '${double.parse('${_fieldValue == '' || _fieldValue == null ? 1 : _fieldValue}').toInt()}');
          } else if (singleField.FieldName == 'Tax' &&
              singleField.FieldValue != null &&
              _standardTaxDropDownFields.length > 0) {
            singleField.textEditingController =
                new TextEditingController(text: _fieldValue);

            ///ASSIGNING THE DEFAULT TEXT_FORM_FIELD_VALUE
            for (var tdf = 0; tdf < _standardTaxDropDownFields.length; tdf++) {
              if (_standardTaxDropDownFields[tdf].Code ==
                  singleField.FieldValue) {
                singleQuoteDetail.TaxDropDownValue =
                    _standardTaxDropDownFields[tdf];
                break;
              }
            }
          } else
            singleField.textEditingController =
                new TextEditingController(text: _fieldValue);
        });
      });

      ///IF PRODUCT_CODE's LIST FOUND THEN FETCHING OFFLINE PRODUCTS FOM LOCAL_DATABASE
      if (_quoteDetailProductIds.length > 0) {
        List<Product> _products =
            await _productDBHelper.getProductsByProductCode(
          productCodeList: _quoteDetailProductIds,
        );

        ///HERE ASSIGNING THE PRODUCTS FETCHED FOR EACH QUOTE
        _products.forEach((singleProduct) {
          quoteObj.QuoteDetail.forEach((singleQuoteDetail) {
            if (singleQuoteDetail.product.ProductCode ==
                singleProduct.ProductCode) {
              singleQuoteDetail.product = singleProduct;
            }
          });
        });
      }

      ///HOLDS CUSTOMER SELECTED FOR THE QUOTE_HEADER
      List<String> _quoteHeaderCustomerNos = List<String>();

      ///HOLDS SALES_SITE SELECTED FOR THE QUOTE_HEADER
      List<String> _quoteSalesSites = List<String>();

      quoteObj.QuoteHeader.forEach((singleQuoteHeader) {
        singleQuoteHeader.QuoteHeaderFields.forEach((singleField) {
          String _fieldValue =
              singleField.FieldValue != null ? singleField.FieldValue : '';
          if (singleField.FieldName == 'CustomerNo') {
            _quoteHeaderCustomerNos.add(_fieldValue);
            _customerTFController.text = _fieldValue;
          } else if (singleField.FieldName == 'DocumentDate') {
            _dateController.text = Other().DisplayDate(_fieldValue.toString());
            // transformDate(dateValue: _fieldValue.toString());
          } else if (singleField.FieldName == 'SalesSite') {
            _salesSiteTFController.text = _fieldValue;
            _quoteSalesSites.add(_fieldValue);
          } else if (singleField.FieldName == 'PONumber') {
            if (_fieldValue != 'null') poNumberController.text = _fieldValue;
          } else if (singleField.FieldName == 'Notes') {
            if (_fieldValue != 'null') noteController.text = _fieldValue;
          } else
            singleField.textEditingController =
                new TextEditingController(text: _fieldValue);
        });
      });

      ///CHECKING IF ANY CUSTOMER SELECTED FROM LOOKUP THEN FETCHING LOOKUP VALUE
      if (_quoteHeaderCustomerNos.length > 0) {
        List<Company> _companies =
            await _companyDBHelper.getCompanyByCustomerNos(
          customerNoList: _quoteHeaderCustomerNos,
        );
        if (_companies.length > 0) {
          setState(() {
            selectedCompany = _companies[0];
          });
        }
      }

      print(
          '_quoteSalesSites For fetching offline selected lookup values $_quoteSalesSites');

      this.setState(() {
        _quote = quoteObj;
        isFullScreenLoading = false;
        isDetailsLoded = true;
        print('isDetailsLoded');
      });
      if (widget.addQuoteType != AddQuoteType.EDIT_OFFLINE_QUOTE) {
        AddProductData(widget.listingQuoteObj.Quotedetail.length);
      } else if (widget.addQuoteType == AddQuoteType.EDIT_OFFLINE_QUOTE &&
          widget.ProductQuantityList != null) {
        // TO ADD NEW PRODUCT TO OFFLINE SAVE QOUTE
        //   print('Offline Quote:${intOfflineSaveQuoteCount}');
        setState(() {
          isHeaderLoded = true;
        });
        if (widget.ProductQuantityList.length > 0) {
          AddProductData(intOfflineSaveQuoteCount);
        }
      }
      //Added By Gaurav, 15-09-2020
      for (int i = 0; i < _quote.QuoteHeader.length; i++) {
        for (int j = 0;
            j < _quote.QuoteHeader[i].QuoteHeaderFields.length;
            j++) {
          if (_quote.QuoteHeader[i].QuoteHeaderFields[j].FieldName ==
                  'PONumber' ||
              _quote.QuoteHeader[i].QuoteHeaderFields[j].FieldName == 'Notes')
            _quote.QuoteHeader[i].QuoteHeaderFields[j].IsReadonly = false;
        }
      }
      for (int i = 0; i < _quote.QuoteDetail.length; i++) {
        for (int j = 0;
            j < _quote.QuoteDetail[i].QuoteDetailFields.length;
            j++) {
          if (_quote.QuoteDetail[i].QuoteDetailFields[j].FieldName ==
                  'BasePrice' ||
              _quote.QuoteDetail[i].QuoteDetailFields[j].FieldName ==
                  'Quantity') {
            _quote.QuoteDetail[i].QuoteDetailFields[j].IsReadonly = false;
          }
        }
      }
    } catch (e) {
      print('Error Inside fetchOfflineQuoteSelectedLookupsValues ');
      print(e);
      showErrorToast('Try Again Later');
    }
  }

  ///ADD THE SINGLE QUOTE THEN ADDS TO THE LOCAL_DATABASE THEN ADD
  ///ITS RESPECTIVE QUOTE_HEADERS AND QUOTE_DETAILS
  void addNewQuote({
    int isLocalQuote,
    String serverUpdatedDate,
    int serverQuoteId,
  }) async {
    _addQuoteDBHelper
        .addSingleQuote(
          isLocalQuote: isLocalQuote,
          serverUpdatedDate: serverUpdatedDate,
          serverQuoteId: serverQuoteId,
        )
        .then((createdQuote) => {
              print('addNewQuote Success Response '),
              // print(createdQuote),
              print('value.Id: ${createdQuote.Id} '),
              createdQuote.QuoteHeader = List<AddQuoteHeader>(),
              createdQuote.QuoteDetail = List<AddQuoteDetail>(),
              this.setState(() {
                _quote = createdQuote;
              }),
              this.addQuoteHeader(
                quote: _quote,
                isInitialLoading: true,
                isLoadingLocalQuote: isLocalQuote,
              ),
            })
        .catchError((e) => {
              print('Error Inside addNewQuote Fn '),
              print(e),
              this.handleAddQuoteError(quoteId: -1),
            });
  }

  //Added By Gaurav 04-03-2022
  void showRealTimePriceIssue(String strMsg) {
    String strError = strMsg;
    String strErrorMsg;
    var ErrorMsges = [];
    strError = strError
        .replaceAll('{', '')
        .replaceAll('}', '')
        .replaceAll('"', '')
        .replaceAll('ErrorMessage:', '');
    strErrorMsg = strError.substring(1, strError.length - 1);
    if (strErrorMsg.contains(',')) {
      ErrorMsges = strErrorMsg.split(',');
      strErrorMsg = '';
      for (int i = 0; i < ErrorMsges.length; i++) {
        if (strErrorMsg.isEmpty) {
          strError = ErrorMsges[i].toString().trimLeft();
          strErrorMsg = strError.trimRight();
        } else {
          strError = ErrorMsges[i].toString().trimLeft();
          strErrorMsg += ', ' + strError.trimRight();
        }
      }
    }
    //print('strErrorMsg ${strErrorMsg}');
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text('Real Time Pricing Error : ${strErrorMsg}'),
      backgroundColor: AppColors.greyOut,
      duration: Duration(seconds: 10),
      behavior: SnackBarBehavior.floating,
      elevation: 20,
      action: SnackBarAction(
          label: "Close",
          onPressed: () {
            // Some code to undo the change.
          }),
    ));
  }

  void GetProductRealTimeAPIData(int intPosition) async {
    try {
      setState(() {
        isFullScreenLoading = true;
      });

      print('inside GetProductRealTimeAPIData');
      if (isOffline == false && isProductRealTimeDataLoded == false) {
        String _salesSite = userSalesSiteCode;
        String _customer = selectedCompany.CustomerNo;
        String _currency = _standardCurrencyDropDownField.Code;
        String _erpName = _standardERPDropDownField.Code;
        try {
          String strFlag = '';
          String requestBody = '{';
          requestBody += '"CustomerNo" : "${_customer}",';
          requestBody += '"SalesSite" : "${_salesSite}",';
          requestBody += '"Currency" : "${_currency}",';
          requestBody += '"QuoteDetailsGrid" : [{';
          requestBody += '"QuoteDetail" : [';
          for (int i = 0; i < widget.ProductQuantityList.length; i++) {
            if (strFlag == '') {
              strFlag = 'val';
              requestBody += '{';
              requestBody +=
                  '"ProductCode" : "${widget.ProductQuantityList[i].ProductObject.ProductCode}",';
              requestBody += '"BasePrice" : "0",';

              requestBody +=
                  '"Quantity" : "${widget.ProductQuantityList[i].Quantity}"';
            } else {
              requestBody += ',{';
              requestBody +=
                  '"ProductCode" : "${widget.ProductQuantityList[i].ProductObject.ProductCode}",';
              requestBody += '"BasePrice" : "0",';
              requestBody +=
                  '"Quantity" : "${widget.ProductQuantityList[i].Quantity}"';
            }
            requestBody += '}';
          }
          requestBody += ']';
          requestBody += '}]';
          requestBody += '}';

          //print('Request Body: $requestBody');
          ApiService.getPricing(
            erpName: _erpName,
            requestBody: requestBody,
          )
              .then((value) => {
                    if (!value.toString().contains('Error'))
                      {
                        ProductRealTimePriceData.addAll(value),
                      }
                    else
                      {
                        showRealTimePriceIssue(value.toString()),
                      }
                  })
              .catchError((e) => {
                    print('Pricing API Error Response $e'),
                    setState(() {
                      isProductRealTimeDataLoded = true;
                      AddProductData(intPosition);
                      // updateDataBase(ProductRealTimePriceData);
                    }),
                  })
              .whenComplete(() => {
                    setState(() {
                      isProductRealTimeDataLoded = true;
                      AddProductData(intPosition);
                      if (ProductRealTimePriceData.length > 0)
                        updateDataBase(ProductRealTimePriceData);
                    }),
                  });
        } catch (e) {
          isFullScreenLoading = false;
          print(
              'Error while calling multiple realtime APIs So calling normal flow');
          print(e);
        }
      } else {
        print('Offline Api not call');
        setState(() {
          isFullScreenLoading = false;
          isProductRealTimeDataLoded = true;
          AddProductData(intPosition);
        });
      }
    } catch (e) {
      print('Error inside GetProductRealTimeAPIData FN ');
      print(e);
    }
  }

  ///IT ADDS THE QUOTE_HEADER TO THE ADD_QUOTE
  void addQuoteHeader({
    AddQuote quote,
    bool isInitialLoading,
    int isLoadingLocalQuote,
  }) async {
    print(
        'Inserting Initial Default AddQuoteHeader Inside addQuoteHeader Function');
    try {
      List<QuoteHeaderField> _temp = List<QuoteHeaderField>();
      String loggedInSalesPerson = await Session.getUserCode();

      ///IT GENERATES THE RANDOM UNIQUE KEY FOR THE QUOTE HEADER FIELDS REFERENCE
      String _quoteHeaderRefId = RandomKeyGenerator.createCryptoRandomString();

      ///HERE ADDING THE _quoteHeaderRefId OF THE QUOTE_HEADER TO THE QuoteHeaderIds FIELD
      /// OF ADD QUOTE TO UPDATE IN DATABASE TO MAINTAIN THE RELATION_SHIP BETWEEN
      /// ADD_QUOTE AND ADD_QUOTE_HEADER
      quote.QuoteHeaderIds = getFormattedIdsString(
        splitText: ',',
        stringToSplit: quote.QuoteHeaderIds,
        newStringToAppend: '$_quoteHeaderRefId',
      );
      print('Updated quote.QuoteHeaderIds : ${quote.QuoteHeaderIds}');

      ///CREATING TEMPORARY QUOTE_HEADER_FIELDS TO INSERT INTO LOCAL_DATABASE
      ///BY REFERRING THE STANDARD_FIELDS
      _headersOnScreenStandardFields.forEach((singleSF) {
        if (singleSF.ShowOnScreen) {
          String _fieldValue = '';

          ///IF QUOTE IS EDITED FROM THE LISTING PAGE THEN SETTING UP THE DEFAULT VALUES FOR THE FORM
          ///BY PROVIDED QUOTE_OBJECT
          if (isLoadingLocalQuote == 0 && widget.listingQuoteObj != null) {
            if (widget.listingQuoteObj
                .toJson()
                .containsKey(singleSF.FieldName)) {
              _fieldValue = widget.listingQuoteObj
                  .toJson()['${singleSF.FieldName}']
                  .toString();
            }
          } else if (isLoadingLocalQuote == 1 &&
              singleSF.FieldName == "CurrencyCode" &&
              _standardCurrencyDropDownField.Code != null) {
            _fieldValue = _standardCurrencyDropDownField.Code;
          } else if (isLoadingLocalQuote == 1 &&
              singleSF.FieldName == "DocumentType") {
            _fieldValue = AddQuoteDefaults.DEFAULT_DOCUMENT_TYPE;
          } else if (isLoadingLocalQuote == 1 &&
              singleSF.FieldName == "DocumentNo") {
            _fieldValue = AddQuoteDefaults.DEFAULT_DOCUMENT_NO;
          } else if (isLoadingLocalQuote == 1 &&
              singleSF.FieldName == "SalesPerson") {
            ///BINDING LOGGED IN SALES PERSON USER_CODE
            _fieldValue =
                loggedInSalesPerson != null && loggedInSalesPerson != 'null'
                    ? loggedInSalesPerson
                    : '';
          }
          _temp.add(
            QuoteHeaderField(
              AddQuoteID: quote.Id,
              FieldName: singleSF.FieldName,
              LabelName: singleSF.LabelName,
              FieldValue: '$_fieldValue',
              HeaderReferenceId: '$_quoteHeaderRefId',
              IsReadonly: singleSF.IsReadonly,
              IsRequired: singleSF.IsRequired,
            ),
          );
        }
      });
      if (_temp.length > 0) {
        ///HOLDS CUSTOMER SELECTED FOR THE QUOTE_HEADER
        List<String> _quoteHeaderCustomerNos = List<String>();

        ///HOLDS SALES_SITE SELECTED FOR THE QUOTE_HEADER
        List<String> _quoteSalesSites = List<String>();

        ///INSERTING QUOTE_HEADER_FIELDS TO THE LOCAL_DATABASE
        _addQuoteHeaderDBHelper
            .insertQuoteHeaderFields(
              headerFields: _temp,
              quoteHeaderReferenceId: _quoteHeaderRefId,
              quote: quote,
            )
            .then((value) => {
                  print('QuoteHeader Fields Insert Response '),
                  print(value),
                  if (value.QuoteHeaderFields.length > 0)
                    {
                      ///ADDING THE TEXT_EDITING_CONTROLLERS TO THE QUOTE_DETAIL_FIELDS
                      value.QuoteHeaderFields.forEach((singleField) {
                        String _tfValue = '';
                        ///HERE ADDING IF LOADING SERVER'S QUOTE THEN ADDING IT's VALUES TO THE TEXT_CONTROLLERS
                        if (isLoadingLocalQuote == 0 &&
                            widget.listingQuoteObj != null) {
                          _tfValue = singleField.FieldValue.toString().trim();
                          print('${singleField.FieldName} || $_tfValue');
                          if (singleField.FieldName == 'CustomerNo') {
                            _quoteHeaderCustomerNos.add(_tfValue);
                            _customerTFController.text = _tfValue;
                          } else if (singleField.FieldName == 'DocumentDate') {
                            _dateController.text =
                                Other().DisplayDate(_tfValue.toString());
                          } else if (singleField.FieldName == 'SalesSite') {
                            _quoteSalesSites.add(_tfValue);
                            _salesSiteTFController.text = _tfValue;
                          } else if (singleField.FieldName == 'PONumber') {
                            if (_tfValue != 'null')
                              poNumberController.text = _tfValue;
                          } else if (singleField.FieldName == 'Notes') {
                            if (_tfValue != 'null')
                              noteController.text = _tfValue;
                          } else {
                            singleField.textEditingController =
                                new TextEditingController(text: _tfValue);
                          }
                        } else {
                          if (singleField.FieldName == 'CustomerNo')
                            _tfValue = 'Select Customer';
                          else if (singleField.FieldValue != null &&
                              singleField.FieldValue != 'null') {
                            _tfValue = singleField.FieldValue;
                          }
                          singleField.textEditingController =
                              new TextEditingController(text: _tfValue);
                        }
                      }),
                    },
                  this.setState(() {
                    _quote.QuoteHeader.add(value);
                  }),
                  ///HERE CHECKING IF ADDING QUOTE INITIALLY THEN ALSO CALL THE FUNCTION TO
                  /// ADD DEFAULT QUOTE_DETAIL ENTRY TO MAIN_QUOTE_OBJECT
                  if (isInitialLoading && isLoadingLocalQuote == 1)
                    {
                      AddProductData(0),
                    }
                  else
                    {
                      addServerQuoteDetailFields(
                        quote: _quote,
                        isLoadingLocalQuote: isLoadingLocalQuote,
                        quoteHeaderCustomerNoList: _quoteHeaderCustomerNos,
                        quoteSalesSitesCodeNoList: _quoteSalesSites,
                      ),
                      print('inside addServerQuoteDetailFields ${widget.listingQuoteObj.Quotedetail.length}'),
                    },

                })
            .catchError((e) => {
                  print('QuoteHeader Fields Insert Error Response '),
                  print(e),
                  this.handleAddQuoteError(quoteId: quote.Id),
                });
      } else {
        print('_temp fields not Present for insertion inside addQuoteHeader ');
        handleAddQuoteError(quoteId: quote.Id);
      }
    } catch (e) {
      print('Error Inside addQuoteHeader ');
      print(e);
      handleAddQuoteError(quoteId: quote.Id);
    }
  }

  void addQuoteDetailWithProductQuantityData({
    AddQuote quote,
    int isLoadingLocalQuote,
    Product ProductObj,
    int Quantity,
    OtherParam otherParam, //Added by Gaurav Gurav, 24-Aug-2022
    int quotePosition,
    bool isEditExistingQuote = false,
  }) async {
    print('Inserting Quote_Detail Inside addQuoteDetail Function');
    try {
      List<QuoteDetailField> _temp = List<QuoteDetailField>();

      ///IT GENERATES THE RANDOM UNIQUE KEY FOR THE QUOTE DETAIL FIELDS REFERENCE
      String _quoteDetailRefId = RandomKeyGenerator.createCryptoRandomString();
      if (isEditExistingQuote == true) {
        print('isEditExistingQuote true');
        NewQuoteDetailsIds.add(_quoteDetailRefId);
      }

      ///HERE ADDING THE _quoteHeaderRefId OF THE QUOTE_DETAIL TO THE QuoteDetailsIds FIELD
      /// OF ADD QUOTE TO UPDATE IN DATABASE TO MAINTAIN THE RELATION_SHIP BETWEEN
      /// ADD_QUOTE AND ADD_QUOTE_HEADER

      quote.QuoteDetailIds = getFormattedIdsString(
        splitText: ',',
        stringToSplit: quote.QuoteDetailIds,
        newStringToAppend: '$_quoteDetailRefId',
      );
      print('Updated quote.QuoteDetailIds : ${quote.QuoteDetailIds}');

      ///CREATING TEMPORARY QUOTE_DETAIL_FIELDS TO INSERT INTO LOCAL_DATABASE
      ///BY REFERRING THE STANDARD_FIELDS
      _detailsOnScreenStandardFields.forEach((singleSF) {
        if (singleSF.ShowOnScreen) {
          String _fieldValue = '';
          if (singleSF.FieldName == "Tax" &&
              _standardTaxDropDownFields.length > 0) {
            _fieldValue = _standardTaxDropDownFields[0].Code;
            print(
                'Default Tax FieldValue Set to the QuoteDetail : $_fieldValue');
          }
          _temp.add(
            QuoteDetailField(
              AddQuoteID: quote.Id,
              FieldName: singleSF.FieldName,
              LabelName: singleSF.LabelName,
              FieldValue: _fieldValue,
              DetailReferenceId: '$_quoteDetailRefId',
              IsReadonly: singleSF.IsReadonly,
              IsRequired: singleSF.IsRequired,
            ),
          );
        }
      });
      if (_temp.length > 0) {
        ///ADDING QUOTE_DETAIL ENTRY TO THE LOCAL_DATABASE
        _addQuoteDetailDBHelper
            .insertQuoteDetailFields(
              detailFields: _temp,
              quoteDetailReferenceId: _quoteDetailRefId,
              quote: quote,
            )
            .then((value) => {
                  print('QuoteDetail Fields Insert Response '),
                  print(value),
                  value.product = Product(),
                  value.product = ProductObj,
                  print('Assigning Product Obj '),
                  if (value.QuoteDetailFields.length > 0)
                    {
                      ///ADDING THE TEXT_EDITING_CONTROLLERS TO THE QUOTE_DETAIL_FIELDS
                      value.QuoteDetailFields.forEach((singleField) {
                        String _textEditorValue = '';
                        if (singleField.FieldName == 'ProductCode') {
                          singleField.FieldValue =
                              ProductObj.ProductCode.toString();
                          _textEditorValue = ProductObj.ProductCode.toString();
                          print('Product ${ProductObj.ProductCode.toString()}');
                        } else if (singleField.FieldName == 'Tax' &&
                            singleField.FieldValue != null &&
                            _standardTaxDropDownFields.length > 0) {
                          print(
                              'TaxDropDown value assigned to the QuoteDetail ');
                          _textEditorValue = singleField.FieldValue;

                          StandardDropDownField _tempTaxField =
                              StandardDropDownField();

                          ///ASSIGNING THE DEFAULT TEXT_FORM_FIELD_VALUE
                          for (var tdf = 0;
                              tdf < _standardTaxDropDownFields.length;
                              tdf++) {
                            print(
                                'singleField.FieldValue: ${singleField.FieldValue}');
                            if (_standardTaxDropDownFields[tdf].Code ==
                                singleField.FieldValue) {
                              print(
                                  'Assigned the Default Value to the TaxDropDown');
                              _tempTaxField = _standardTaxDropDownFields[tdf];
                              break;
                            }
                          }
                          if (_tempTaxField.Code == null &&
                              _standardTaxDropDownFields.length > 0) {
                            _tempTaxField = _standardTaxDropDownFields[0];
                          }
                          value.TaxDropDownValue = _tempTaxField;
                        }
                        singleField.textEditingController =
                            new TextEditingController(text: _textEditorValue);
                      }),
                    },
                  this.setState(() {
                    _quote.QuoteDetail.add(value);
                    isFullScreenLoading = false;
                  }),
                  print('Calling  handle Product Change '),
                  handleProductChange(
                      quantity: Quantity,
                      productObj: ProductObj,
                      quotePosition: quotePosition,
                      otherParam:  otherParam),
                })
            .catchError((e) => {
                  print('QuoteDetails Fields Insert Error Response '),
                  print(e),
                  this.handleAddQuoteError(quoteId: quote.Id),
                });
      } else {
        print('_temp fields not Present for insertion ');
        handleAddQuoteError(quoteId: quote.Id);
      }
    } catch (e) {
      print('Error Inside addQuoteDetail ');
      print(e);
      handleAddQuoteError(quoteId: quote.Id);
    }
  }

  ///IT ADDS THE QUOTE_DETAIL TO THE MAIN_QUOTE OBJECT
  void addQuoteDetail({
    AddQuote quote,
    int isLoadingLocalQuote,
  }) async {
    print('Inserting Quote_Detail Inside addQuoteDetail Function');
    try {
      List<QuoteDetailField> _temp = List<QuoteDetailField>();

      ///IT GENERATES THE RANDOM UNIQUE KEY FOR THE QUOTE DETAIL FIELDS REFERENCE
      String _quoteDetailRefId = RandomKeyGenerator.createCryptoRandomString();

      ///HERE ADDING THE _quoteHeaderRefId OF THE QUOTE_DETAIL TO THE QuoteDetailsIds FIELD
      /// OF ADD QUOTE TO UPDATE IN DATABASE TO MAINTAIN THE RELATION_SHIP BETWEEN
      /// ADD_QUOTE AND ADD_QUOTE_HEADER
      quote.QuoteDetailIds = getFormattedIdsString(
        splitText: ',',
        stringToSplit: quote.QuoteDetailIds,
        newStringToAppend: '$_quoteDetailRefId',
      );
      print('Updated quote.QuoteDetailIds : ${quote.QuoteDetailIds}');

      ///CREATING TEMPORARY QUOTE_DETAIL_FIELDS TO INSERT INTO LOCAL_DATABASE
      ///BY REFERRING THE STANDARD_FIELDS
      _detailsOnScreenStandardFields.forEach((singleSF) {
        if (singleSF.ShowOnScreen) {
          String _fieldValue = '';
          if (singleSF.FieldName == "Tax" &&
              _standardTaxDropDownFields.length > 0) {
            _fieldValue = _standardTaxDropDownFields[0].Code;
            print(
                'Default Tax FieldValue Set to the QuoteDetail : $_fieldValue');
          }
          _temp.add(
            QuoteDetailField(
              AddQuoteID: quote.Id,
              FieldName: singleSF.FieldName,
              LabelName: singleSF.LabelName,
              FieldValue: _fieldValue,
              DetailReferenceId: '$_quoteDetailRefId',
              IsReadonly: singleSF.IsReadonly,
              IsRequired: singleSF.IsRequired,
            ),
          );
        }
      });
      if (_temp.length > 0) {
        ///ADDING QUOTE_DETAIL ENTRY TO THE LOCAL_DATABASE
        _addQuoteDetailDBHelper
            .insertQuoteDetailFields(
              detailFields: _temp,
              quoteDetailReferenceId: _quoteDetailRefId,
              quote: quote,
            )
            .then((value) => {
                  print('QuoteDetail Fields Insert Response '),
                  print(value),
                  value.product = Product(),
                  if (value.QuoteDetailFields.length > 0)
                    {
                      ///ADDING THE TEXT_EDITING_CONTROLLERS TO THE QUOTE_DETAIL_FIELDS
                      value.QuoteDetailFields.forEach((singleField) {
                        String _textEditorValue = '';
                        if (singleField.FieldName == 'ProductCode') {
                          _textEditorValue = 'Select Product';
                        } else if (singleField.FieldName == 'Tax' &&
                            singleField.FieldValue != null &&
                            _standardTaxDropDownFields.length > 0) {
                          print(
                              'TaxDropDown value assigned to the QuoteDetail ');
                          _textEditorValue = singleField.FieldValue;

                          StandardDropDownField _tempTaxField =
                              StandardDropDownField();

                          ///ASSIGNING THE DEFAULT TEXT_FORM_FIELD_VALUE
                          for (var tdf = 0;
                              tdf < _standardTaxDropDownFields.length;
                              tdf++) {
                            print(
                                'singleField.FieldValue: ${singleField.FieldValue}');
                            if (_standardTaxDropDownFields[tdf].Code ==
                                singleField.FieldValue) {
                              print(
                                  'Assigned the Default Value to the TaxDropDown');
                              _tempTaxField = _standardTaxDropDownFields[tdf];
                              break;
                            }
                          }
                          if (_tempTaxField.Code == null &&
                              _standardTaxDropDownFields.length > 0) {
                            _tempTaxField = _standardTaxDropDownFields[0];
                          }
                          value.TaxDropDownValue = _tempTaxField;
                        }
                        singleField.textEditingController =
                            new TextEditingController(text: _textEditorValue);
                      }),
                    },
                  this.setState(() {
                    _quote.QuoteDetail.add(value);
                    isFullScreenLoading = false;
                  }),
                })
            .catchError((e) => {
                  print('QuoteDetails Fields Insert Error Response '),
                  print(e),
                  this.handleAddQuoteError(quoteId: quote.Id),
                });
      } else {
        print('_temp fields not Present for insertion ');
        handleAddQuoteError(quoteId: quote.Id);
      }
    } catch (e) {
      print('Error Inside addQuoteDetail ');
      print(e);
      handleAddQuoteError(quoteId: quote.Id);
    }
  }

  ///IT ADDS THE QUOTE_DETAIL TO THE MAIN_QUOTE OBJECT
  ///FOR THE QUOTES WHICH ARE EDITED FROM THE QUOTES_LIST SCREEN
  void addServerQuoteDetailFields({
    AddQuote quote,
    int isLoadingLocalQuote,
    List<String> quoteHeaderCustomerNoList,
    List<String> quoteSalesSitesCodeNoList,
  }) async {
    print('Inserting Quote_Detail Inside addServerQuoteDetailFields Function');
    try {
      ///HOLDS PRODUCTS IDS LIST FOR FETCHING QUOTE_DETAILS PRODUCTS IF QUOTE EDITED FOR SERVER's QUOTE
      List<String> _quoteDetailProductIds = List<String>();

      List<QuoteDetailField> _temp = List<QuoteDetailField>();

      ///GENERATING MULTIPLE RANDOM UNIQUE KEY FOR THE QUOTE DETAIL FIELDS REFERENCE
      ///IF SERVER's EDITED QUOTE CONTAINS MULTIPLE QUOTES
      List<String> _quoteDetailRefIds = List<String>();
      for (var i = 0; i < widget.listingQuoteObj.Quotedetail.length; i++) {
        String _refId = RandomKeyGenerator.createCryptoRandomString();
        _quoteDetailRefIds.add(_refId);

        print('_refId: $_refId');

        ///HERE ADDING THE _quoteHeaderRefId OF THE QUOTE_DETAIL TO THE QuoteDetailsIds FIELD
        /// OF ADD QUOTE TO UPDATE IN DATABASE TO MAINTAIN THE RELATION_SHIP BETWEEN
        /// ADD_QUOTE AND ADD_QUOTE_HEADER
        quote.QuoteDetailIds = getFormattedIdsString(
          splitText: ',',
          stringToSplit: quote.QuoteDetailIds,
          newStringToAppend: '$_refId',
        );
      }
      print('Updated quote.QuoteDetailIds : ${quote.QuoteDetailIds}');

      ///CREATING TEMPORARY QUOTE_DETAIL_FIELDS TO INSERT INTO LOCAL_DATABASE
      ///BY REFERRING THE STANDARD_FIELDS
      _detailsOnScreenStandardFields.forEach(
        (singleSF) {
          if (singleSF.ShowOnScreen) {
            ///HERE ADDING IF LOADING SERVER'S QUOTE THEN ADDING IT's VALUES TO THE TEXT_CONTROLLERS
            for (var qd = 0;
                qd < widget.listingQuoteObj.Quotedetail.length;
                qd++) {
              QuoteDetail singleQuoteDetail =
                  widget.listingQuoteObj.Quotedetail[qd];
              String _quoteDetailFieldValue = '';
              if (singleQuoteDetail.toJson().containsKey(singleSF.FieldName)) {
                _quoteDetailFieldValue = singleQuoteDetail
                    .toJson()['${singleSF.FieldName}']
                    .toString();
              }
              if (singleSF.FieldName == 'TotalWeight')
                print(
                    '${singleSF.FieldName} Value: ${singleQuoteDetail.toJson()['${singleSF.FieldName}']} ');
              //Added by gaurav 31-aug-2022
              if (singleSF.FieldName == 'OtherParam') {
                print('${singleSF.FieldName} Value: ${singleQuoteDetail
                    .toJson()['${singleSF.FieldName}']} ');
                String extraParam = singleQuoteDetail.toJson()['${singleSF
                    .FieldName}'];
                extraParam = extraParam.replaceAll('{"OtherParam":"', '');
                extraParam = extraParam.replaceAll('"}', '');
                extraParam = extraParam.replaceAll('"', '*');
                print('--Fianl--extraParam--------${extraParam}');
                _quoteDetailFieldValue = extraParam;
              }
              print(' AFTER ${singleSF.FieldName} Value: ${singleQuoteDetail.toJson()['${singleSF.FieldName}']} ');
              //end
              _temp.add(
                QuoteDetailField(
                  AddQuoteID: quote.Id,
                  FieldName: singleSF.FieldName,
                  LabelName: singleSF.LabelName,
                  FieldValue: '$_quoteDetailFieldValue',
                  DetailReferenceId: '${_quoteDetailRefIds[qd]}',
                  IsRequired: singleSF.IsRequired,
                  IsReadonly: singleSF.IsReadonly,
                ),
              );
            }
          }
        },
      );
      if (_temp.length > 0) {
        ///ADDING QUOTE_DETAIL ENTRY TO THE LOCAL_DATABASE
        _addQuoteDetailDBHelper
            .insertServerQuoteDetailFields(
              detailFields: _temp,
              quoteDetailReferenceIds: _quoteDetailRefIds,
              quote: quote,
            )
            .then((quoteDetailsListRes) => {
                  quoteDetailsListRes.forEach((singleQuoteDetail) {
                    singleQuoteDetail.product = Product();
                    singleQuoteDetail.TaxDropDownValue =
                        StandardDropDownField();
                    if (singleQuoteDetail.QuoteDetailFields.length > 0) {
                      ///ADDING THE TEXT_EDITING_CONTROLLERS TO THE QUOTE_DETAIL_FIELDS
                      singleQuoteDetail.QuoteDetailFields.forEach(
                          (singleField) {
                        String _fieldValue = (singleField.FieldValue != null &&
                                    singleField.FieldValue != 'null') &&
                                singleField.FieldValue.toString()
                                        .trim()
                                        .length >
                                    0
                            ? singleField.FieldValue.toString().trim()
                            : '';
                        if (_fieldValue.length < 1 &&
                            singleField.FieldName == 'ProductCode') {
                          _fieldValue = 'Select Product';
                        }
                        if (singleField.FieldName == 'ProductCode' &&
                            _fieldValue.length > 1) {
                          _quoteDetailProductIds.add(_fieldValue);
                          singleQuoteDetail.product.ProductCode = _fieldValue;
                        } else if (singleField.FieldName ==
                                'Tax' && //ASSIGNING THE TAX DROPDOWN VALUE
                            _fieldValue != null &&
                            _fieldValue != '' &&
                            _standardTaxDropDownFields.length > 0) {
                          print(
                              'Assigned the Default TaxDropDown for ServerEditedQuote');

                          ///ASSIGNING THE DEFAULT TEXT_FORM_FIELD_VALUE
                          for (var tdf = 0;
                              tdf < _standardTaxDropDownFields.length;
                              tdf++) {
                            if (_standardTaxDropDownFields[tdf].Code ==
                                singleField.FieldValue) {
                              singleQuoteDetail.TaxDropDownValue =
                                  _standardTaxDropDownFields[tdf];
                              break;
                            }
                          }
                        }
                        //modified by gauraav, 31-Aug-2022
                        if (singleField.FieldName == 'OtherParam'){
                          _fieldValue=_fieldValue.replaceAll('*','"');
                          print('Details Field ${singleField.FieldName}--${_fieldValue} ');
                          singleField.textEditingController =
                          new TextEditingController(text: '$_fieldValue');
                        }
                        else{
                          print('Details Field ${singleField.FieldName}--${_fieldValue} ');
                          singleField.textEditingController =
                          new TextEditingController(text: '$_fieldValue');
                        }
                        //end
                      });
                    }
                  }),
                  this.setState(() {
                    _quote.QuoteDetail.addAll(quoteDetailsListRes);
                  }),

                  ///LOADING LOOKUPS SELECTED VALUES
                  loadSelectedLookupsData(
                    quoteObj: _quote,
                    quoteHeaderCustomerNoList: quoteHeaderCustomerNoList,
                    quoteSalesSitesCodeNoList: quoteSalesSitesCodeNoList,
                    quoteDetailsProductsCodeNoList: _quoteDetailProductIds,
                  ),
                })
            .catchError((e) => {
                  print(
                      'QuoteDetails Fields Insert Error Response Inside addServerQuoteDetailFields'),
                  print(e),
                  this.handleAddQuoteError(quoteId: quote.Id),
                })
            .whenComplete(() => {
                  print('Length ${widget.listingQuoteObj.Quotedetail.length}'),
                  setState(() {
                    isDetailsLoded = true;
                    print('isDetailsLoded');
                  }),
                  AddProductData(widget.listingQuoteObj.Quotedetail.length),
                });
      } else {
        print('_temp fields not Present for insertion inside addServerQuoteDetailFields Fn');
        handleAddQuoteError(quoteId: quote.Id);
      }

      //added by Gaurav Gurav 26-Sep-2022

    } catch (e) {
      print('Error Inside addServerQuoteDetailFields Fn');
      print(e);
      handleAddQuoteError(quoteId: quote.Id);
    }
  }

  ///IT LOADS CUSTOMER/ SALES_SITE/QUOTE_DETAILS_PRODUCTS SELECTED LOOKUP VALUES AND ASSIGNS THEM TO THE QUOTE_STATE
  void loadSelectedLookupsData({
    AddQuote quoteObj,
    List<String> quoteHeaderCustomerNoList,
    List<String> quoteSalesSitesCodeNoList,
    List<String> quoteDetailsProductsCodeNoList,
  }) async {
    try {
      ///CHECKING IF ANY CUSTOMER SELECTED FROM LOOKUP THEN FETCHING LOOKUP VALUE
      if (quoteHeaderCustomerNoList.length > 0) {
        List<Company> _companies =
            await _companyDBHelper.getCompanyByCustomerNos(
          customerNoList: quoteHeaderCustomerNoList,
        );
        if (_companies.length > 0) {
          setState(() {
            selectedCompany = _companies[0];
          });
        }
      }

      print( 'quoteSalesSitesCodeNoList Selected SalesSites fetch $quoteSalesSitesCodeNoList');

      ///IF PRODUCT_CODE's LIST FOUND THEN FETCHING OFFLINE PRODUCTS FOM LOCAL_DATABASE
      if (quoteDetailsProductsCodeNoList.length > 0) {
        List<Product> _products =
            await _productDBHelper.getProductsByProductCode(
          productCodeList: quoteDetailsProductsCodeNoList,
        );
        print('Products List: $_products');

        ///HERE ASSIGNING THE PRODUCTS FETCHED FOR EACH QUOTE
        _products.forEach((singleProduct) {
          quoteObj.QuoteDetail.forEach((singleQuoteDetail) {
            if (singleQuoteDetail.product.ProductCode ==
                singleProduct.ProductCode) {
              singleQuoteDetail.product = singleProduct;
            }
          });
        });
      }

      setState(() {
        _quote = quoteObj;
        isFullScreenLoading = false;
      });

      if(widget.listingQuoteObj.quoteInvoicingElement.length >0){
        quoteInvElement = [];
        invoicingElementDBHelper.getAllInvoiceElements().then((invElementsRes) {
          print("Fill Sales Invoice Elements");
          for (InvoicingElement element in invElementsRes) {
            var objQuoteInvElm = widget.listingQuoteObj.quoteInvoicingElement.firstWhere(
            (e) => e.InvoicingElementCode.toString() == element.code.toString(), orElse: () => null);
            if (objQuoteInvElm != null) {
              setState(() {
                quoteInvElement.add(new QuoteInvElement(
                invoicingElement: element,
                quoteHeaderId: widget.listingQuoteObj.Id,
                invoicingElementvalue: objQuoteInvElm.InvoicingElementValue,
                  txtValue: objQuoteInvElm.InvoicingElementValue.toString()
                ));
              });
            }
          }
          }).catchError((err){
            print( 'Error while fetching Invoicing Elements from LocalDB');
            print(err);
        });
    }
    } catch (e) {
      print('Error Inside addServerQuoteDetailFields Fn');
      print(e);
      handleAddQuoteError(quoteId: quoteObj.Id);
    }
  }

  ///IT SPLITS THE COMMA SEPARATED STRING AND BUILDS NEW STRING WITH
  ///NEW ID PROVIDED TO ATTACH THE MAIN ID'S STRING
  String getFormattedIdsString({
    String stringToSplit,
    String splitText,
    String newStringToAppend,
  }) {
    String _finalString = '';
    try {
      List<String> _list = stringToSplit.trim().split(splitText);
      _list.forEach((singleStr) {
        if (singleStr != null && singleStr.trim().length > 0)
          _finalString += '${singleStr.trim()},';
      });
      if (_finalString.trim().length > 0) {
        _finalString += newStringToAppend;
      } else {
        _finalString += newStringToAppend;
      }
      print('_finalString: $_finalString');
      return _finalString;
    } catch (e) {
      print('Error Inside getFormattedIdsString FN ');
      print(e);
      throw ErrorDescription('Error While Splitting');
    }
  }

  ///IT DELETES THE QUOTE WITH RESPECTIVE QUOTE_HEADER AND QUOTE_DETAIL ENTRIES BY QUOTE_ID
  void deleteQuoteByID({
    @required int quoteId,
    bool isDeleteOnExit = false,
  }) async {
    try {
      if (quoteId != null) {
        var _quoteHeaderDeleteRes = await _addQuoteHeaderDBHelper.deleteRowByQuoteId(addQuoteId: quoteId);
        print('Quote Headers Delete By QuoteID Res $_quoteHeaderDeleteRes');
        var _quoteDetailDeleteRes = await _addQuoteDetailDBHelper.deleteRowByQuoteId(addQuoteId: quoteId);
        print('Quote Details Delete By QuoteID Res $_quoteDetailDeleteRes');
        var _quoteDeleteRes =await _addQuoteDBHelper.deleteRowById(addQuoteId: quoteId);
        print('Quote Delete By QuoteID Res $_quoteDeleteRes');
        var _quoteInvoicingElement =await _quoteInvoicingElementDBHelper.deleteQuoteInvoicingElementByQuoteHeaderId(QuoteHeaderId: quoteId);
        print('Quote Delete By QuoteID Res $_quoteInvoicingElement');
      } else {
        print('Invalid Quote Id Found for the deletion');
      }
      if (isDeleteOnExit) {
        print('Deleted Quotes offline data on exit');
        handleDeleteOnExitResponse();
      }
    } catch (e) {
      print('Error Inside deleteQuoteByID Fn ');
      print(e);
      if (isDeleteOnExit) {
        print('Error while deleting Quotes offline data on exit');
        handleDeleteOnExitResponse();
      }
    }
  }

  void deleteAll() async {
    var _quoteDetailDeleteRes =
        await _addQuoteDetailDBHelper.deleteRowByQuoteId(addQuoteId: _quote.Id);
    print('Quote Details Delete By QuoteID Res $_addQuoteDetailDBHelper');
    var _addQuoteUpdateRes = await AddQuoteDBHelper().updateFieldById(
      quoteId: _quote.Id,
      fieldName: 'QuoteDetailIds',
      stringFieldValue: '',
    );
    print(
        'AddQuote QuoteDetailIds Field Update Response : $_addQuoteUpdateRes');
  }

  ///IT HANDLES DELETING THE SINGLE_QUOTE_DETAIL FROM LOCAL_DATABASE
  void handleSingleQuoteDetailDelete({
    int quoteDetailPosition,
  }) async {
    try {
      String strQuoteDetailsRefId;
      setState(() {
        isFullScreenLoading = true;
        strQuoteDetailsRefId =
            _quote.QuoteDetail[quoteDetailPosition].DetailReferenceId;
      });

      print('quoteDetailPosition $quoteDetailPosition');

      String _updatedQuoteDetailsIds = getQuoteDetailIdsUpdated(
        splitText: ',',
        stringToSplit: _quote.QuoteDetailIds,
        stringToExclude:
            _quote.QuoteDetail[quoteDetailPosition].DetailReferenceId,
      );
      print('Updated Quote Details value: $_updatedQuoteDetailsIds');

      var addQuoteUpdateRes = await _addQuoteDBHelper.updateFieldById(
        quoteId: _quote.Id,
        fieldName: 'QuoteDetailIds',
        stringFieldValue: _updatedQuoteDetailsIds,
      );
      print('addQuoteUpdateRes : $addQuoteUpdateRes');

      var quoteDetailFieldDelete =
          await _addQuoteDetailDBHelper.deleteRowByDetailRefId(
        detailReferenceId:
            _quote.QuoteDetail[quoteDetailPosition].DetailReferenceId,
      );
      print('QuoteDetails Delete Response : $addQuoteUpdateRes');

      _quote.QuoteDetailIds = _updatedQuoteDetailsIds;
      print('_updatedQuoteDetailsIds : $_updatedQuoteDetailsIds');
      _quote.QuoteDetail.removeAt(quoteDetailPosition);
      print('Remove quote :');

      setState(() {
        _quote = _quote;
      });
      setState(() {
        isFullScreenLoading = false;
      });

      setState(() {
        //If delete newly added product then uodate new quote details id list
        NewQuoteDetailsIds.removeWhere(
            (element) => element == strQuoteDetailsRefId);
      });
      updateDocumentTotal();
    } catch (e) {
      print('Error inside handleSingleQuoteDetailDelete Fn ');
      print(e);
      setState(() {
        isFullScreenLoading = false;
      });
    }
  }

  //To delete unsaved quote details on back button on "NO" button click
  void handleUnsavedQuoteDetailDelete() async {
    try {
      setState(() {
        isFullScreenLoading = true;
      });
      for (int i = 0; i < NewQuoteDetailsIds.length; i++) {
        print('quoteDetailId ${NewQuoteDetailsIds[i].toString()}');
        String _updatedQuoteDetailsIds = getQuoteDetailIdsUpdated(
          splitText: ',',
          stringToSplit: _quote.QuoteDetailIds,
          stringToExclude: NewQuoteDetailsIds[i].toString(),
        );
        print('Updated Quote Details value: $_updatedQuoteDetailsIds');

        var addQuoteUpdateRes = await _addQuoteDBHelper.updateFieldById(
          quoteId: _quote.Id,
          fieldName: 'QuoteDetailIds',
          stringFieldValue: _updatedQuoteDetailsIds,
        );
        print('addQuoteUpdateRes : $addQuoteUpdateRes');

        var quoteDetailFieldDelete =
            await _addQuoteDetailDBHelper.deleteRowByDetailRefId(
          detailReferenceId: NewQuoteDetailsIds[i].toString(),
        );
        print('QuoteDetails Delete Response : $addQuoteUpdateRes');

        _quote.QuoteDetailIds = _updatedQuoteDetailsIds;
        print('_updatedQuoteDetailsIds : $_updatedQuoteDetailsIds');
        print('Before Delete Length ${_quote.QuoteDetail.length}');
        _quote.QuoteDetail.removeWhere((element) =>
            element.DetailReferenceId == NewQuoteDetailsIds[i].toString());
        print('After Delete Length ${_quote.QuoteDetail.length}');
        print('Remove quote :');
        setState(() {
          _quote = _quote;
        });
      }
      setState(() {
        isFullScreenLoading = false;
      });
      handleDeleteOnExitResponse();
    } catch (e) {
      print('Error inside handleUnsavedQuoteDetailDelete Fn ');
      print(e);
      setState(() {
        isFullScreenLoading = false;
      });
    }
  }

  ///IT SPLITS THE COMMA SEPARATED STRING AND BUILDS NEW STRING,
  ///BY EXCLUDING THE SPECIFIED QUOTE_DETAIL_REFERENCE_ID FROM THE MAIN_STRING
  String getQuoteDetailIdsUpdated({
    String stringToSplit,
    String splitText,
    String stringToExclude,
  }) {
    String _finalString = '';
    try {
      List<String> _list = stringToSplit.trim().split(splitText);

      ///EXCLUDING THE STRING WHICH NEEDS TO BE DELETED
      _list.forEach((singleStr) {
        if (singleStr != null &&
            singleStr.trim().length > 0 &&
            singleStr.trim() != stringToExclude)
          _finalString += '${singleStr.trim()},';
      });

      ///IF ONLY ONE QUOTE DETAIL IS PRESENT, WHICH IS ALSO REMOVED THEN RETURNING THE EMPTY STRING
      if (_list.length > 1)
        _finalString = _finalString.substring(0, _finalString.lastIndexOf(','));
      return _finalString;
    } catch (e) {
      print('Error Inside getQuoteDetailIdsUpdated FN ');
      print(e);
      throw ErrorDescription(
          'Error While Splitting the String to remove the specified reference ID');
    }
  }

  ///IT SHOWS THE ERROR MESSAGE IF ANY ERROR OCCURS WHILE DELETING THE SINGLE QUOTE_DETAIL FROM THE ADD_QUOTE SCREEN
  void showSingleQuoteDeleteErrToast({
    String toastMsg,
  }) {
    setState(() {
      isFullScreenLoading = false;
    });
    _commonWidgets.showFlutterToast(toastMsg: toastMsg);
  }

  void handleDeleteOnExitResponse() {
    setState(() {
      isFullScreenLoading = false;
    });

    ///THEN NAVIGATING TO THE LISTING PAGE
    if (isBackPressed == true) {
      Navigator.pop(widgetContext, true);
    } else {
      print('Save and Go to Main Page');
      Navigator.pop(widgetContext, true);
    }
  }

  ///IT RETURNS THE FORM INPUT_DECORATION FOR THE TEXT_FIELDS
  InputDecoration getFormTFInputDecoration(
      String label, bool isShowCounterText) {
    return isShowCounterText
        ? InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(5, 20, 5, 10),
            labelText: '$label',
            labelStyle: TextStyle(
              color: Colors.blue,
              height: 0.5,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          )
        : InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(5, 20, 5, 10),
            labelText: '$label',
            counterText: '',
            labelStyle: TextStyle(
              color: Colors.blue,
              height: 0.5,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          );
  }

  ///ITE RETURNS THE DATE_PICKER
  Widget getDatePicker({
    String label,
    int quoteHeaderFieldPosition,
    int quoteHeaderPosition,
    String fieldName,
  }) {
    print('getDatePicker');
    if (_dateController.text == '') {
      // Existing Quote
      _dateController.text = Other().DateFormater.format(DateTime.now());
      setState(() {
        _quote
            .QuoteHeader[quoteHeaderPosition]
            .QuoteHeaderFields[quoteHeaderFieldPosition]
            .FieldValue = DateTime.now().toString();
      });
    }

    return TextFormField(
      autovalidate: !isInitialCreateQuoteCLicked ? true : false,
      readOnly: true,
      controller: _dateController,
//      onTap:isSubmitButtonDisabled==false?null: () {
//        setState((){
//          isSubmitButtonDisabled=true;
//        });
//        showDatePicker(
//          context: context,
//          initialDate: DateTime.now(),
//          firstDate: DateTime(2001),
//          lastDate: DateTime(2021),
//        ).then(
//          (date) => {
//            print('Selected Date $date'),
//
//            ///UPDATING DATE TO ITS SPECIFIC FIELD_VALUE
//            if (date != null)
//              {
//                _dateController.text = Other().DateFormater.format(date),
//                // transformDate(dateValue: date.toString()),
//                setState(() {
//                  _quote
//                      .QuoteHeader[quoteHeaderPosition]
//                      .QuoteHeaderFields[quoteHeaderFieldPosition]
//                      .FieldValue = date.toString();
//                }),
//              }
//          },
//        );
//      },
      style: _formTFTextStyle,
      decoration: getFormTFInputDecoration(label, false),
    );
  }

  ///IT RETURNS THE MANDATORY TEXT_FIELD FOR THE FORM
  ///BY PROVIDING THE VALIDATORS
  Widget getQuoteHeaderTFF({
    String label,
    String fieldName,
    int quoteHeaderFieldPosition,
    int quoteHeaderPosition,
    TextEditingController textEditingController,
  }) {
    bool _isReadOnly = _quote.QuoteHeader[quoteHeaderPosition]
        .QuoteHeaderFields[quoteHeaderFieldPosition].IsReadonly;
    bool _isRequired = _quote.QuoteHeader[quoteHeaderPosition]
        .QuoteHeaderFields[quoteHeaderFieldPosition].IsRequired;

    int maxLines = 1;
    int maxLength; //AddQuoteDefaults.FIELDS_DEFAULT_MAX_LENGTH;
    TextInputType _textInputType = TextInputType.text;

    ///IF NOTES FIELD PRESENT THEN SETTING UP THE MULTI_LINE TEXT_FIELD
    if (fieldName == 'Notes') {
      maxLines = 3;
      _textInputType = TextInputType.multiline;
      maxLength = AddQuoteDefaults.NOTES_FIELD_MAX_LENGTH;
    } else if (fieldName == 'PONumber') {
      maxLength = AddQuoteDefaults.PO_NUMBER_FIELD_MAX_LENGTH;
    }

    setState(() {
      //To Set PO number and Note values
      _quote
          .QuoteHeader[quoteHeaderPosition]
          .QuoteHeaderFields[quoteHeaderFieldPosition]
          .FieldValue = textEditingController.text;
    });
    return TextFormField(
      maxLength: maxLength,
      autovalidate:
          _isRequired ? (!isInitialCreateQuoteCLicked ? true : false) : false,
      minLines: maxLines,
      maxLines: maxLines,
      readOnly: _isReadOnly,
      controller: textEditingController,
     // keyboardType: TextInputType.numberWithOptions(decimal: true),
//      inputFormatters: [
//        // WhitelistingTextInputFormatter(RegExp(r'^\d+\.?\d{0,2}'))
//        WhitelistingTextInputFormatter(RegExp(r'(^\d*\.?\d{0,2})'))
//      ],
      style: _formTFTextStyle,
      decoration: getFormTFInputDecoration('$label', true),
      onChanged: (value) {
        if (value != null && value != '') {
          setState(() {
            isSubmitButtonDisabled = true;
            _quote.QuoteHeader[quoteHeaderPosition]
                .QuoteHeaderFields[quoteHeaderFieldPosition].FieldValue = value;
          });
        }
      },
      validator: (value) {
        if (_isRequired) {
          if (value.isEmpty) {
            return 'Enter the value for $label field';
          }
          try {
            textEditingController.text = value.toString();
          } catch (e) {
            print(
                'Error while setting the value for the textEditingController For Header Fields');
            print(e);
          }
        }
        return null;
      },
    );
  }

  Widget getQuoteHeaderDDF({
    String label,
    String fieldName,
    int quoteHeaderFieldPosition,
    int quoteHeaderPosition,
    String selectedValue,
    Map<String, dynamic> itemList,
    Function(String) onChangeMethod,
  }) {
    bool _isReadOnly = _quote.QuoteHeader[quoteHeaderPosition]
        .QuoteHeaderFields[quoteHeaderFieldPosition].IsReadonly;
    bool _isRequired = _quote.QuoteHeader[quoteHeaderPosition]
        .QuoteHeaderFields[quoteHeaderFieldPosition].IsRequired;
    List<DropdownMenuItem<String>> dropDownMenuItems = List();

    ///IF ShippingAddressCode FIELD PRESENT THEN SETTING UP THE MULTI_LINE TEXT_FIELD
    if (fieldName == 'ShippingAddressCode') {
      itemList.entries.forEach((element) {
        dropDownMenuItems.add(
          DropdownMenuItem(
            child: Text(
              '${element.key}',
              style: TextStyle(color: AppColors.black, fontSize: 15.0 ),
              overflow: TextOverflow.ellipsis,
            ),
            value: element.value,
          ),
        );
      });
    }
    setState(() {
      //To Set PO number and Note values
      _quote
          .QuoteHeader[quoteHeaderPosition]
          .QuoteHeaderFields[quoteHeaderFieldPosition]
          .FieldValue = selectedValue;
    });
    return DropdownButtonFormField(
      validator: (value) {
        if (_isRequired && value == '') {
          return "Please select valid value";
        }
      },
      value: selectedValue,
      items: dropDownMenuItems,
      style: _formDDTextStyle,
      decoration: getFormTFInputDecoration('$label', true),
      onChanged: (selectedItem) {
        if (_isReadOnly != true) {
          if (selectedItem != selectedValue) {
            print('New Item Selected ');
            _quote
                .QuoteHeader[quoteHeaderPosition]
                .QuoteHeaderFields[quoteHeaderFieldPosition]
                .FieldValue = selectedItem;
            onChangeMethod(selectedItem);
          } else {
            print('Already Selected Item Selected ');
          }
        }
      },
      isExpanded: true,
    );
  }

  //Ship Address On Change
  onShipAddressChange(String address) {
    try {
      this.setState(() {
        shippingAddressCode = address;
      });
    } catch (e) {
      print("Error in onShipAddressChange");
      print(e);
    }
  }

  ///IT SETS THE STATE FOR DROPDOWN SELECTED COMPANY
  void handleCompanyChange({
    Company companyObj,
    int quoteHeaderFieldPosition,
    int quoteHeaderPosition,
    String fieldName,
  }) {
    _customerTFController.text =
        '${companyObj.Name} ( ${companyObj.CustomerNo})';
    setState(() {
      selectedCompany = companyObj;
      _quote.QuoteHeader[quoteHeaderPosition].QuoteHeaderFields[quoteHeaderFieldPosition].FieldValue = companyObj.CustomerNo;
    });
  }

  ///IT SETS THE STATE FOR DROPDOWN SELECTED SALES_SITE

  void userSalesSite({
    String salesSiteCode,
    int quoteHeaderFieldPosition,
    int quoteHeaderPosition,
    String fieldName,
  }) {
    setState(() {
      _salesSiteTFController.text = salesSiteCode;
      _quote
          .QuoteHeader[quoteHeaderPosition]
          .QuoteHeaderFields[quoteHeaderFieldPosition]
          .FieldValue = salesSiteCode;

      ///IF ADD_QUOTE OPENED TYPE IS FOR NEW_QUOTE OR LOCAL_QUOTE EDIT THEN SETTING UP THE DOCUMENT_NO FIELD
      if (widget.addQuoteType == AddQuoteType.NEW_QUOTE ||
          widget.addQuoteType == AddQuoteType.EDIT_OFFLINE_QUOTE) {
        for (var i = 0;
            i <
                _quote
                    .QuoteHeader[quoteHeaderPosition].QuoteHeaderFields.length;
            i++) {
          if (_quote.QuoteHeader[quoteHeaderPosition].QuoteHeaderFields[i]
                  .FieldName ==
              'DocumentNo') {
            ///HERE SETTING THE DOCUMENT_NO BASED ON THE SALES_SITE SELECTED
            ///i.e. SALES_SITE_CODE + DEFAULT_DOCUMENT_NO VALUE
            var _newDocumentNo =
                '${salesSiteCode}${AddQuoteDefaults.DEFAULT_DOCUMENT_NO}';
            _quote.QuoteHeader[quoteHeaderPosition].QuoteHeaderFields[i]
                .FieldValue = _newDocumentNo;
            _quote.QuoteHeader[quoteHeaderPosition].QuoteHeaderFields[i]
                .textEditingController.text = _newDocumentNo;
            break;
          }
        }
      }
    });
  }

  ///It closes the CompanySearch/ProductSearch Dialog On CLose Btn click
  void closeSearchDialog() {
    print('closeSearchDialog called of the AddQuote page');
  }

  ///IT CHECKS IF ALL THE DATA IS PRESENT FOR CALLING THE REALTIME DATA FROM THE API
  bool isFieldsExistForRealTimeData({
    @required Product productObj,
    @required int quotePosition,
  }) {
    print('productObj.ProductCode: ${productObj.ProductCode}');
    print('selectedCompany.CustomerNo : ${selectedCompany.CustomerNo}');
    print('UserSalesSite : ${userSalesSiteCode}');
    print(
        '_standardCurrencyDropDownField.Code : ${_standardCurrencyDropDownField.Code}');
    print('_standardERPDropDownField.Code: ${_standardERPDropDownField.Code} ');

    ///CHECKING IF ALL THE REQUIRED FIELDS ARE PRESENT FOR THE API CALLS
    if (productObj.ProductCode != null &&
        selectedCompany.CustomerNo != null &&
        _standardCurrencyDropDownField.Code != null &&
        _standardERPDropDownField.Code != null) {
      return true;
    } else {
      return false;
    }
  }

  ///IT HANDLES THE SELECTED PRODUCT'S REALTIME_DATA FETCH FOR PRICING AND AVAILABLE QUANTITY

  ///IT SETS THE STATE FOR SELECTED PRODUCT FOR THE QUOTE DETAILS
  void handleProductChange({
    Product productObj,
    int quotePosition,
    int quantity,
    OtherParam otherParam
  }) {
    try {
      print('quotePosition $quotePosition');
      if (quotePosition != null) {
        double _realTimePrice =
            _quote.QuoteDetail[quotePosition].productRealTimePrice;
        int _realTimeQuantity =
            _quote.QuoteDetail[quotePosition].productRealTimeQuantity;

        ///HERE SETTING UP THE PRODUCT FOR SELECTED QUOTE_DETAIL
        setState(() {
          _quote.QuoteDetail[quotePosition].product = productObj;

          ///HERE SETTING UP THE QUOTE_DETAILS_CONTENTS VALUES BY USING THE ASSIGNED CONTROLLERS
          ///CHECKING IF THE PRODUCT_OBJECT CONTAINS THE STANDARD_FIELD VALUES
          ///IF PRESENT THEN SETTING UP THE VALUE BY USING THE TEXT_EDITING_CONTROLLERS
          _quote.QuoteDetail[quotePosition].QuoteDetailFields
              .forEach((singleQuoteElm) {
            if (singleQuoteElm.FieldName == 'ExtAmount' &&
                productObj.toJson().containsKey('BasePrice')) {
              String _basePrice = productObj.toJson()['BasePrice'].toString();
              singleQuoteElm.textEditingController.text =
                  double.parse(_basePrice.toString())
                      .toStringAsFixed(2)
                      .toString();
              singleQuoteElm.FieldValue = double.parse(_basePrice.toString())
                  .toStringAsFixed(2)
                  .toString();
            } else if (singleQuoteElm.FieldName == 'Quantity') {
              ///
              ///HERE IF THE FIELD IS QUANTITY THEN SETTING THE DEFAULT QUANTITY BY DEFAULT TO - 1
              ///

              if (quantity != 1) {
                singleQuoteElm.textEditingController.text = quantity.toString();
                singleQuoteElm.FieldValue = quantity.toString();
              } else {
                singleQuoteElm.textEditingController.text = '1';
                singleQuoteElm.FieldValue = '1';
              }
            } else if (singleQuoteElm.FieldName == 'TotalWeight' &&
                productObj.toJson().containsKey('Weight')) {
              ///
              ///IF THE FIELD IS TotalWeight THEN SETTING TotalWeight SAME AS INITIAL Product Weight FIELD
              ///
              singleQuoteElm.textEditingController.text =
                  productObj.toJson()['Weight'].toString();
              singleQuoteElm.FieldValue =
                  productObj.toJson()['Weight'].toString();
            }
            else if (singleQuoteElm.FieldName == 'OtherParam')//added bu Gaurav Gurav 31-Aug-2022
                {
              singleQuoteElm.textEditingController.text =otherParam.toStringify().toString();
              singleQuoteElm.FieldValue =otherParam.toStringify().toString();
            }
            else if (productObj
                .toJson()
                .containsKey(singleQuoteElm.FieldName)) {
              ///
              ///
              singleQuoteElm.textEditingController.text =
                  productObj.toJson()[singleQuoteElm.FieldName].toString();
              singleQuoteElm.FieldValue =
                  productObj.toJson()[singleQuoteElm.FieldName].toString();
            }
          });
        });
        print('quantity $quantity');
        QuantityOnChange(
          quoteDetailPosition: quotePosition,
          onChangedValue: quantity,
        );
        print('quantity $quantity');

        ///UPDATES DOCUMENT_TOTAL

      } else {
        print('Quote Position Not provided for the QuoteList');
      }
    } catch (e) {
      print('Error inside handleProductChange ');
      print(e);
    }
  }

  ///IT RETURNS THE LOOKUP FIELD FOR THE COMPANY SEARCH
  Widget getCompanyLookupTF({
    String label,
    int quoteHeaderFieldPosition,
    int quoteHeaderPosition,
    String fieldName,
  }) {
    return TextFormField(
        autovalidate: !isInitialCreateQuoteCLicked ? true : false,
        readOnly: true,
        controller: _customerTFController,
//        onTap:isSubmitButtonDisabled==false?null: () {
//          setState((){
//            isSubmitButtonDisabled=true;
//          });
//          showDialog(
//            useRootNavigator: true,
//            barrierDismissible: false,
//            context: context,
//            builder: (context) => CustomerSearchDialog(
//              handleCustomerSelectedSearch: (Company companyObj) {
//                this.handleCompanyChange(
//                  companyObj: companyObj,
//                  fieldName: fieldName,
//                  quoteHeaderFieldPosition: quoteHeaderFieldPosition,
//                  quoteHeaderPosition: quoteHeaderPosition,
//                );
//              },
//              closeSearchDialog: this.closeSearchDialog,
//              forLookupType: true,
//            ),
//          );
//        },
        style: _formTFTextStyle,
        decoration: getFormTFInputDecoration('$label', false),
        validator: (value) {
          if (this.selectedCompany == null ||
              this.selectedCompany.CustomerNo == null) {
            return 'Select the Customer';
          }
          return null;
        });
  }

  ///IT RETURNS THE LOOKUP FIELD FOR THE SALES_SITE SEARCH
  Widget getSalesSiteLookupTF({
    String label,
    int quoteHeaderFieldPosition,
    int quoteHeaderPosition,
    String fieldName,
  }) {
    userSalesSite(
      salesSiteCode: userSalesSiteCode,
      quoteHeaderFieldPosition: quoteHeaderFieldPosition,
      quoteHeaderPosition: quoteHeaderPosition,
      fieldName: fieldName,
    );
    return Visibility(
      visible: false,
      child: TextFormField(
        autovalidate: !isInitialCreateQuoteCLicked,
        readOnly: true,
        controller: _salesSiteTFController,
        style: _formTFTextStyle,
        decoration: getFormTFInputDecoration('$label', false),
      ),
    );
  }

  ///IT HANDLES THE LOOKUP FIELD FOR THE QUOTE_DETAILS PRODUCTS LIST
  Widget getProductLookupTF({
    String label,
    TextEditingController controller,
    int quoteDetailPosition,
    int quoteDetailFieldPosition,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
      child: TextField(
        decoration: getFormTFInputDecoration('$label', false),
        readOnly: true,
        controller: controller,
        style: _formTFTextStyle,
      ),
    );
  }

  ///IT RETURNS THE ADD QUOTE BUTTON FOR ADDING MORE PRODUCTS TO THE QUOTE DETAILS
  ///ALSO HANDLES THE NEW QUOTE
  Widget getQuoteAddButton() {
    return Center(
      child: RaisedButton(
        onPressed: () {
          print('Add Button Pressed ');
          setState(() {
            isFullScreenLoading = true;
          });
          addQuoteDetail(
            quote: _quote,
            isLoadingLocalQuote: 1,
          );
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100.0),
        ),
        color: AppColors.blue,
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  ///IT BUILDS THE FORM FIELDS
  ///HERE ADD THE NEW FIELDS WHICH ARE IMPORTANT
  List<Widget> buildQuoteHeaderView() {
    List<Widget> _fields = List<Widget>();
    for (var qh = 0; qh < _quote.QuoteHeader.length; qh++) {
      for (var qhf = 0;
          qhf < _quote.QuoteHeader[qh].QuoteHeaderFields.length;
          qhf++) {
        String _fieldName =
            _quote.QuoteHeader[qh].QuoteHeaderFields[qhf].FieldName;
        String _labelName =
            _quote.QuoteHeader[qh].QuoteHeaderFields[qhf].LabelName;
        if (_quote.QuoteHeader[qh].QuoteHeaderFields[qhf].IsRequired) {
          _labelName += ' *';
        }
        TextEditingController _textEditingController =
            _quote.QuoteHeader[qh].QuoteHeaderFields[qhf].textEditingController;

        ///EXCLUDED FIELDS CHECK FOR THE QUOTE_HEADERS_FIELDS
        if (!quoteHeaderExcludedFieldNames.contains(_fieldName)) {
          if (_fieldName == 'CustomerNo') {
            ///IF THE FIELD_NAME IS CustomerNo THEN ADDING THE CUSTOMER_LOOKUP TO THE FIELD
            _fields.add(
              getCompanyLookupTF(
                label: _labelName,
                quoteHeaderFieldPosition: qhf,
                quoteHeaderPosition: qh,
                fieldName: _fieldName,
              ),
            );
            if (selectedCompany != null) {
              print('handleCompanyChange  ---- ');
              handleCompanyChange(
                companyObj: selectedCompany,
                quoteHeaderFieldPosition: qhf,
                quoteHeaderPosition: qh,
                fieldName: _fieldName,
              );
            }
          } else if (_fieldName == 'DocumentDate') {
            ///IF THE FIELD_NAME IS DocumentDate THEN ADDING THE DATE_PICKER TO THE FIELD
            _fields.add(
              getDatePicker(
                label: _labelName,
                quoteHeaderFieldPosition: qhf,
                quoteHeaderPosition: qh,
                fieldName: _fieldName,
              ),
            );
          } else if (_fieldName == 'SalesSite') {
            ///IF THE FIELD_NAME IS CustomerNo THEN ADDING THE CUSTOMER_LOOKUP TO THE FIELD
            _fields.add(
              getSalesSiteLookupTF(
                label: _labelName,
                quoteHeaderFieldPosition: qhf,
                quoteHeaderPosition: qh,
                fieldName: _fieldName,
              ),
            );
          } else if (_fieldName == 'PONumber') {
            _fields.add(
              getQuoteHeaderTFF(
                label: _labelName,
                quoteHeaderFieldPosition: qhf,
                quoteHeaderPosition: qh,
                fieldName: _fieldName,
                textEditingController: poNumberController,
              ),
            );
          } else if (_fieldName == 'Notes') {
            _fields.add(
              getQuoteHeaderTFF(
                label: _labelName,
                quoteHeaderFieldPosition: qhf,
                quoteHeaderPosition: qh,
                fieldName: _fieldName,
                textEditingController: noteController,
              ),
            );
          } else if (_fieldName == 'ShippingAddressCode') {
            _fields.add(
              getQuoteHeaderDDF(
                label: _labelName,
                quoteHeaderFieldPosition: qhf,
                quoteHeaderPosition: qh,
                fieldName: _fieldName,
                itemList: shippingAddresses,
                selectedValue: shippingAddressCode,
                onChangeMethod: (p0) => onShipAddressChange(p0),
              ),
            );
          } else {
            ///ADDING THE NORMAL TEXT_FORM_FIELD TO THE FIELDS
            _fields.add(
              getQuoteHeaderTFF(
                label: _labelName,
                quoteHeaderFieldPosition: qhf,
                quoteHeaderPosition: qh,
                fieldName: _fieldName,
                textEditingController: _textEditingController,
              ),
            );
          }
        }
      }
    }

    return _fields;
  }

  ///IT RETURNS THE ACTUAL LIST ROWS CARD CONTENTS IN THE KEY VALUE PAIR
  Widget _getRowContentWidget({String keyText, Widget widget}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 0.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Expanded(
            child: Text(
              '$keyText',
              style: TextStyle(color: AppColors.grey, fontSize: 15),
            ),
          ),

          ///THIS WIDGET WILL BE DISPLAYED ON QUOTE ROW
          ///i.e IN CASE OF ITEM_CODE FIELD IT WILL BE PRODUCT_LOOKUP WIDGET
          ///     AND IN CASE OF QUANTITY FIELD IT WILL BE NUMBER TEXT_FIELD
          ///     IN CASE OF EXT_AMOUNT IT WILL BE READ_ONLY TEXT_FIELD
          widget,
        ],
      ),
    );
  }

  ///IT RETURNS CHECKS IF CUSTOMER CREDIT LIMIT EXCEEDS
  bool isCustomerLimitExceeds({
    @required int quantity,
    @required int quoteDetailPosition,
    @required bool isQuantityCheck,
    @required double basePrice,
  }) {
    Product _quoteProduct = _quote.QuoteDetail[quoteDetailPosition].product;
    if (isQuantityCheck &&
        (basePrice * quantity) > selectedCompany.CreditLimit) {
      setState(() {
        isCustomerCreditLimitExceeds = true;
      });
      return true;
    } else {
      double _totalExtAmt = basePrice * quantity;
      bool limitExceeds = false;
      for (var qd = 0; qd < _quote.QuoteDetail.length; qd++) {
        if (qd != quoteDetailPosition) {
          _quote.QuoteDetail[qd].QuoteDetailFields.forEach((singleField) {
            if (singleField.FieldName == "ExtAmount" &&
                singleField.textEditingController.text != null &&
                singleField.textEditingController.text.length > 0) {
              ///MERGING ALL THE QUOTE DETAILS EXT_AMOUNT AND CHECKING IF CUSTOMER LIMIT EXCEEDS
              _totalExtAmt = _totalExtAmt +
                  double.parse(singleField.textEditingController.text);
            }
          });
        }
      }
      if (_totalExtAmt > selectedCompany.CreditLimit) {
        setState(() {
          isCustomerCreditLimitExceeds = true;
        });
        limitExceeds = true;
      } else {
        setState(() {
          isCustomerCreditLimitExceeds = false;
        });
      }
      return limitExceeds;
    }
  }

  void QuantityOnChange({
    onChangedValue,
    int quoteDetailPosition,
  }) {
    try {
      setState(() {
        isSubmitButtonDisabled = true;
      });

      int _qty = int.parse(onChangedValue.toString());
      print('_qty: $_qty');
      double _realTimePrice =
          _quote.QuoteDetail[quoteDetailPosition].productRealTimePrice;
      int _realTimeQuantity =
          _quote.QuoteDetail[quoteDetailPosition].productRealTimeQuantity;

      ///IF REAL_TIME QUANTITY IS NOT AVAILABLE THEN FOLLOWING THE NORMAL FLOW
      Product _quoteProduct = _quote.QuoteDetail[quoteDetailPosition].product;
      QuoteDetailField _basePriceField = QuoteDetailField();
      double _basePrice = 0;
      for (var i = 0;
          i < _quote.QuoteDetail[quoteDetailPosition].QuoteDetailFields.length;
          i++) {
        if (_quote.QuoteDetail[quoteDetailPosition].QuoteDetailFields[i]
                .FieldName ==
            "BasePrice") {
          _basePriceField =
              _quote.QuoteDetail[quoteDetailPosition].QuoteDetailFields[i];
          print('BasePrice Found ${_basePriceField.FieldValue}');
          _basePrice = double.parse(_basePriceField.FieldValue);
          break;
        }
      }

      if (_qty > 0) {
        ///IF SELECTED CUSTOMER's CREDIT LIMIT IS GREATER THAN THE EXT AMOUNT THEN SHOWING WARNING
        if (_basePriceField.FieldName == "BasePrice") {
          for (var qdf = 0;
              qdf <
                  _quote.QuoteDetail[quoteDetailPosition].QuoteDetailFields
                      .length;
              qdf++) {
            QuoteDetailField _singleQuoteDetailField =
                _quote.QuoteDetail[quoteDetailPosition].QuoteDetailFields[qdf];

            if (_singleQuoteDetailField.FieldName == 'ExtAmount') {
              ///IF THE FIELD IS EXT_AMOUNT THE MULTIPLYING QUANTITY BY THE PRODUCT's BASE_PRICE

              setState(() {
                _singleQuoteDetailField.textEditingController.text =
                    (_qty * _basePrice).toStringAsFixed(2).toString();
                _singleQuoteDetailField.FieldValue =
                    (_qty * _basePrice).toStringAsFixed(2).toString();
              });
            } else if (_singleQuoteDetailField.FieldName == 'TotalWeight') {
//                _singleQuoteDetailField.FieldName.contains('Weight') ||
              ///IF THE FIELD IS TotalWeight THEN MULTIPLYING QUANTITY BY PRODUCT's WEIGHT
              setState(() {
                _singleQuoteDetailField.textEditingController.text =
                    (_qty * _quoteProduct.Weight).toString();
                _singleQuoteDetailField.FieldValue =
                    (_qty * _quoteProduct.Weight).toString();
              });
            } else if (_singleQuoteDetailField.FieldName == 'Quantity') {
              ///IF THE FIELD IS QUANTITY THEN SETTING IT'S FIELD_VALUE
              setState(() {
                _singleQuoteDetailField.FieldValue = _qty.toString();
              });
            }
          }

          ///UPDATES DOCUMENT_TOTAL
          updateDocumentTotal();
        }
      }
    } catch (e) {
      print('Error inside QuantityOnChange');
      print(e);
    }
  }

  ///HANDLES SINGLE QUANTITY CHANGE TO UPDATE RESPECTIVE QUOTE EXT_AMOUNT AND WEIGHT
  bool ValidationOnQuantity({
    onChangedValue,
    int quoteDetailPosition,
    int quoteDetailFieldPosition,
  }) {
    bool isValidate = true;
    try {
      int _qty = int.parse(onChangedValue);
      print('_qty: $_qty');
      double _realTimePrice =
          _quote.QuoteDetail[quoteDetailPosition].productRealTimePrice;
      int _realTimeQuantity =
          _quote.QuoteDetail[quoteDetailPosition].productRealTimeQuantity;

      ///IF REAL_TIME QUANTITY IS NOT AVAILABLE THEN FOLLOWING THE NORMAL FLOW
      Product _quoteProduct = _quote.QuoteDetail[quoteDetailPosition].product;
      QuoteDetailField _basePriceField = QuoteDetailField();
      double _basePrice = 0;
      for (var i = 0;
          i < _quote.QuoteDetail[quoteDetailPosition].QuoteDetailFields.length;
          i++) {
        if (_quote.QuoteDetail[quoteDetailPosition].QuoteDetailFields[i]
                .FieldName ==
            "BasePrice") {
          _basePriceField =
              _quote.QuoteDetail[quoteDetailPosition].QuoteDetailFields[i];
          print('BasePrice Found ${_basePriceField.FieldValue}');
          if (_basePriceField.FieldValue != '')
            _basePrice = double.parse(_basePriceField.FieldValue);
          break;
        }
      }

      if (_qty > 0) {
        ///IF SELECTED CUSTOMER's CREDIT LIMIT IS GREATER THAN THE EXT AMOUNT THEN SHOWING WARNING
        if (isCustomerLimitExceeds(
          isQuantityCheck: true,
          quantity: _qty,
          quoteDetailPosition: quoteDetailPosition,
          basePrice: _basePrice,
        )) {
          setState(() {
            isValidate = false;
          });
        }
      }
    } catch (e) {
      print('Error inside ValidationOnQuantity');
      print(e);
    }
    return isValidate;
  }

  ///HANDLES BASE_PRICE CHANGE TO UPDATE RESPECTIVE QUOTE EXT_AMOUNT AND WEIGHT
  ///ALSO SHOWS THE
  void handleProductBasePriceOnChange({
    onChangedValue,
    int quoteDetailPosition,
    int quoteDetailFieldPosition,
  }) {
    try {
      setState(() {
        isSubmitButtonDisabled = true;
      });

      double _basePrice = double.parse(onChangedValue.toString());
      Product _quoteProduct = _quote.QuoteDetail[quoteDetailPosition].product;

      double _realTimePrice =
          _quote.QuoteDetail[quoteDetailPosition].productRealTimePrice;
      int _realTimeQuantity =
          _quote.QuoteDetail[quoteDetailPosition].productRealTimeQuantity;
//      print('_realTimePrice: $_realTimePrice');

      ///CHECKING IF ENTERED BASE_PRICE IS MUST_NOT LESS THAN 1
//      if (_basePrice < 1.0) {
//        _basePrice = _quoteProduct.BasePrice;
//        _quote
//            .QuoteDetail[quoteDetailPosition]
//            .QuoteDetailFields[quoteDetailFieldPosition]
//            .textEditingController
//            .text = _basePrice.toString();
//      }

      ///TODO: HERE ADD THE VALID TOAST IF CHANGED BASE PRICE VALUE IS LESS THAN PRODUCT MINIMUM MARGIN VALUE
//      else if (_basePrice < _quoteProduct.BasePrice) {
//        ///CHECKING IF BASE PRICE MUST NOT BE LESS THAN PRODUCT's DEFAULT BASE PRICE
//        showWarningAlert(
//          alertMsg: 'Unit Price cannot be below product record’s unit price',
//        );
//        _basePrice = _quoteProduct.BasePrice;
//        _quote
//            .QuoteDetail[quoteDetailPosition]
//            .QuoteDetailFields[quoteDetailFieldPosition]
//            .textEditingController
//            .text = _basePrice.toString();
//      }

      ///GETTING THE QUANTITY FIELD VALUE TO UPDATE THE EXT_AMOUNT FIELD_VALUE
      int _qty = 0;
      for (var i = 0;
          i < _quote.QuoteDetail[quoteDetailPosition].QuoteDetailFields.length;
          i++) {
        if (_quote.QuoteDetail[quoteDetailPosition].QuoteDetailFields[i]
                .FieldName ==
            "Quantity") {
          _qty = int.parse(_quote
              .QuoteDetail[quoteDetailPosition].QuoteDetailFields[i].FieldValue
              .toString());

//              parseStringToDouble(
//              value: _quote.QuoteDetail[quoteDetailPosition]
//                  .QuoteDetailFields[i].FieldValue
//                  .toString());
          break;
        }
      }

      ///IF SELECTED CUSTOMER's CREDIT LIMIT IS GREATER THAN THE EXT AMOUNT THEN SHOWING WARNING
//      if (isCustomerLimitExceeds(
//        isQuantityCheck: true,
//        quantity: _qty,
//        quoteDetailPosition: quoteDetailPosition,
//        basePrice: _basePrice,
//      )) {
//        ///HERE IF CUSTOMER LIMIT EXCEEDS THEN SETTING THE SELECTED PRODUCT BASE PRICE AS THE
//        ///BASE PRICE FOR THE QUOTE DETAIL
//        _basePrice = _quoteProduct.BasePrice;
//        setState(() {
//          _quote.QuoteDetail[quoteDetailPosition].QuoteDetailFields[quoteDetailFieldPosition]
//              .textEditingController.text = _basePrice.toStringAsFixed(2).toString();
//          _quote
//              .QuoteDetail[quoteDetailPosition]
//              .QuoteDetailFields[quoteDetailFieldPosition]
//              .FieldValue = _basePrice.toStringAsFixed(2).toString();
//        });
//      } else {
//        ///IF CUSTOMER LIMIT NOT EXCEEDS THEN SETTING THE ENTERED BASE PRICE AS THE QUOTE DETAIL BASE PRICE
//        setState(() {
//          _quote
//              .QuoteDetail[quoteDetailPosition]
//              .QuoteDetailFields[quoteDetailFieldPosition]
//              .FieldValue = _basePrice.toStringAsFixed(2).toString();
//        });
//      }

      for (var qdf = 0;
          qdf <
              _quote.QuoteDetail[quoteDetailPosition].QuoteDetailFields.length;
          qdf++) {
        QuoteDetailField _singleQuoteDetailField =
            _quote.QuoteDetail[quoteDetailPosition].QuoteDetailFields[qdf];

        if (_singleQuoteDetailField.FieldName == 'ExtAmount') {
          ///IF THE FIELD IS EXT_AMOUNT THE MULTIPLYING QUANTITY BY THE PRODUCT's BASE_PRICE
          setState(() {
            _singleQuoteDetailField.textEditingController.text =
                (_qty * _basePrice).toStringAsFixed(2).toString();
            String str = (_qty * _basePrice).toStringAsFixed(2).toString();
            print('value: $str');
            _singleQuoteDetailField.FieldValue =
                (_qty * _basePrice).toStringAsFixed(2).toString();
          });
        }
      }

      ///UPDATES DOCUMENT_TOTAL
      updateDocumentTotal();
//      }
    } catch (e) {
      print('Error inside handleProductBasePriceOnChange');
      print(e);
    }
  }

  bool ValidationOnProductBasePrice({
    onChangedValue,
    int quoteDetailPosition,
    int quoteDetailFieldPosition,
  }) {
    bool isValidate = true;
    try {
      double _basePrice = double.parse(onChangedValue.toString());
      Product _quoteProduct = _quote.QuoteDetail[quoteDetailPosition].product;
      double _realTimePrice =
          _quote.QuoteDetail[quoteDetailPosition].productRealTimePrice;
      int _realTimeQuantity =
          _quote.QuoteDetail[quoteDetailPosition].productRealTimeQuantity;

      ///CHECKING IF ENTERED BASE_PRICE IS MUST_NOT LESS THAN 1
      if (_basePrice < 1.0) {
        isValidate = false;

//        showWarningAlert(
//          alertMsg: 'Unit Price cannot be 0',
//        );
        _basePrice = _quoteProduct.BasePrice;
        _quote
            .QuoteDetail[quoteDetailPosition]
            .QuoteDetailFields[quoteDetailFieldPosition]
            .textEditingController
            .text = _basePrice.toString();
      }

      ///TODO: HERE ADD THE VALID TOAST IF CHANGED BASE PRICE VALUE IS LESS THAN PRODUCT MINIMUM MARGIN VALUE
//      else if (_basePrice < _quoteProduct.BasePrice) {
//        ///CHECKING IF BASE PRICE MUST NOT BE LESS THAN PRODUCT's DEFAULT BASE PRICE
//        showWarningAlert(
//          alertMsg: 'Unit Price cannot be below product record’s unit price',
//        );
//        _basePrice = _quoteProduct.BasePrice;
//        _quote
//            .QuoteDetail[quoteDetailPosition]
//            .QuoteDetailFields[quoteDetailFieldPosition]
//            .textEditingController
//            .text = _basePrice.toString();
//      }
    } catch (e) {
      print('Error inside ValidationOnProductBasePrice');
      print(e);
    }
    return isValidate;
  }

  ///UPDATES DOCUMENT_TOTAL FIELD VALUE OF THE QUOTE_HEADER FIELDS
  void updateDocumentTotal() {
    try {
      double _documentTotal = 0.0;

      ///SETTING QUOTE_HEADER_DOCUMENT_TOTAL_FIELD_VALUE BY ADDING ALL THE
      ///QUOTE_DETAILS FIELDS EXT_AMOUNT FIELD VALUES
      if (_quote.QuoteHeader.length > 0) {
        _quote.QuoteDetail.forEach((singleQuoteDetail) {
          for (var qdf = 0;
              qdf < singleQuoteDetail.QuoteDetailFields.length;
              qdf++) {
            var fieldValue =
                singleQuoteDetail.QuoteDetailFields[qdf].FieldValue;
            fieldValue =
                fieldValue != null && fieldValue.toString().trim().length > 0
                    ? singleQuoteDetail.QuoteDetailFields[qdf].FieldValue
                        .toString()
                        .trim()
                    : '';
            if (fieldValue != '') {
              if (singleQuoteDetail.QuoteDetailFields[qdf].FieldName ==
                  "ExtAmount") {
                _documentTotal += (double.parse(fieldValue.toString()));
                break;
              }
            }
          }
        });

        ///SETTING QUOTE HEADER DOCUMENT TOTAL
        setState(() {
          documentTotal = _documentTotal;
          for (var qhf = 0;
              qhf < _quote.QuoteHeader[0].QuoteHeaderFields.length;
              qhf++) {
            if (_quote.QuoteHeader[0].QuoteHeaderFields[qhf].FieldName ==
                "DocumentTotal") {
              _quote.QuoteHeader[0].QuoteHeaderFields[qhf].FieldValue =
                  double.parse(_documentTotal.toString()).toStringAsFixed(2);
              break;
            }
          }
        });
      }
    } catch (e) {
      print('Error Inside updateDocumentTotal Fn ');
      print(e);
    }
  }

  ///IT BUILDS THE QUOTE_DETAIL's SINGLE_QUOTE ROW CONTENTS WITH TEXT_FIELDS BY ASSIGNING THE
  ///READ_ONLY AND CONTROLLERS TO IT
  Widget getQuoteRowContentTF({
    @required String label,
    @required bool readOnly, //To disable field until Product is selected
    @required TextInputType textInputType, //Type of Keypad to show on TFF Focus
    @required QuoteDetailField detailFieldObj, //Single QuoteFieldObject
    @required
        int quoteDetailPosition, //    int quoteRecordPosition, //Position for the <_quoteDetailsList>
    @required
        int quoteDetailFieldPosition, //    int fieldRecordPosition, //Position for the single Field from the <_quoteDetailsList<quotesList>>
  }) {
    bool _isReadOnly = _quote.QuoteDetail[quoteDetailPosition]
        .QuoteDetailFields[quoteDetailFieldPosition].IsReadonly;
    bool _isRequired = _quote.QuoteDetail[quoteDetailPosition]
        .QuoteDetailFields[quoteDetailFieldPosition].IsRequired;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
      child: TextFormField(
        autovalidate:
            _isRequired ? (!isInitialCreateQuoteCLicked ? true : false) : false,
        style: _formTFTextStyle,
        decoration: getFormTFInputDecoration('$label', false),
        keyboardType: textInputType,
        readOnly: readOnly,
        controller: detailFieldObj.textEditingController,
        onChanged: (value) {
          if (value != null && value.toString().trim().length > 0) {
            switch (detailFieldObj.FieldName) {
              case 'BasePrice': //HANDLING EXT_AMOUNT CHANGE IF BASE_PRICE IS CHANGED
                break;
//              case 'Weight':
//                break;

              default:
                break;
            }
          }
        },
        validator: (value) {
          if (_isRequired) {
            if (value.isEmpty) {
              return '${detailFieldObj.LabelName} cannot be empty';
            }
            try {
              detailFieldObj.textEditingController.text = value.toString();
            } catch (e) {
              print(
                  'Error while setting the value for the textEditingController For Detail Fields');
              print(e);
            }
          }
          return null;
        },
      ),
    );
  }

  Widget getQuoteRowQuantityTF({
    @required String label,
    @required bool readOnly, //To disable field until Product is selected
    @required TextInputType textInputType, //Type of Keypad to show on TFF Focus
    @required QuoteDetailField detailFieldObj, //Single QuoteFieldObject
    @required
        int quoteDetailPosition, //    int quoteRecordPosition, //Position for the <_quoteDetailsList>
    @required
        int quoteDetailFieldPosition, //    int fieldRecordPosition, //Position for the single Field from the <_quoteDetailsList<quotesList>>
  }) {
    bool _isReadOnly = _quote.QuoteDetail[quoteDetailPosition]
        .QuoteDetailFields[quoteDetailFieldPosition].IsReadonly;
    bool _isRequired = _quote.QuoteDetail[quoteDetailPosition]
        .QuoteDetailFields[quoteDetailFieldPosition].IsRequired;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: TextFormField(
              readOnly: _isReadOnly,
              maxLength: 10,
              controller: detailFieldObj.textEditingController,
              style: _formTFTextStyle,
              inputFormatters: <TextInputFormatter>[
                WhitelistingTextInputFormatter.digitsOnly,
                //To accept digit only
              ],
              keyboardType: TextInputType.number,
              decoration: getFormTFInputDecoration('$label', false),
              onChanged: (text) {
                if (text != null && text != '') {
                  text = text.replaceAll(new RegExp(r'[^0-9]'), '');
                  if (int.parse(detailFieldObj.textEditingController.text) >
                      0) {
                    setState(() {
                      detailFieldObj.FieldValue = int.parse(text).toString();
                    });
                    QuantityOnChange(
                      onChangedValue: detailFieldObj.FieldValue,
                      quoteDetailPosition: quoteDetailPosition,
                    );
                  } else {
                    setState(() {
                      detailFieldObj.FieldValue = "0";
                      detailFieldObj.textEditingController.text = "0";
                    });
                  }
                } else {
                  setState(() {
                    detailFieldObj.FieldValue = "0";
                    detailFieldObj.textEditingController.text = "";
                  });
                }
                QuantityOnChange(
                  onChangedValue: detailFieldObj.FieldValue,
                  quoteDetailPosition: quoteDetailPosition,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20.0, right: 35.0),
            child: InkWell(
                child: Icon(Icons.do_not_disturb_on, size: 20),
                onTap: isSubmitButtonDisabled == false
                    ? null
                    : () {
                        setState(() {
                          detailFieldObj.textEditingController.text == ""
                              ? "0"
                              : detailFieldObj.textEditingController.text;
                          if (int.parse(
                                  detailFieldObj.textEditingController.text) >
                              1) {
                            int Quantity = int.parse(
                                    detailFieldObj.textEditingController.text) -
                                1;
                            detailFieldObj.textEditingController.text =
                                Quantity.toString();
                            detailFieldObj.FieldValue = Quantity.toString();
                            QuantityOnChange(
                              onChangedValue: detailFieldObj.FieldValue,
                              quoteDetailPosition: quoteDetailPosition,
                            );
                          }
                        });
                      }),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20.0, right: 8.0),
            child: InkWell(
                child: Icon(
                  Icons.add_circle,
                  size: 20,
                ),
                onTap: isSubmitButtonDisabled == false
                    ? null
                    : () {
                        setState(() {
                          print(
                              'qty ${detailFieldObj.textEditingController.text}');
                          if (detailFieldObj.textEditingController.text == "" ||
                              detailFieldObj
                                  .textEditingController.text.isEmpty) {
                            detailFieldObj.textEditingController.text = "0";
                          }
                          print(
                              'qty ${detailFieldObj.textEditingController.text}');
                          int Quantity = int.parse(
                                  detailFieldObj.textEditingController.text) +
                              1;
                          detailFieldObj.FieldValue = (Quantity).toString();
                          detailFieldObj.textEditingController.text =
                              Quantity.toString();
                          QuantityOnChange(
                            onChangedValue: detailFieldObj.FieldValue,
                            quoteDetailPosition: quoteDetailPosition,
                          );
                        });
                      }),
          ),
        ],
      ),
    );
  }

  String strProductLastPrice = '';
  bool isGotLastPrice = false;

  void ShowProductLastPrice(Product _Product) async {
    this.setState(() {
      _productLastPrice = new ProductLastPrice();
      isGotLastPrice = false;
    });
    ApiService.getProductLastPrice(
      customerCode: selectedCompany.CustomerNo,
      productCode: _Product.ProductCode,
    )
        .then((value) => {
              if (value.length > 0)
                {
                  this.setState(() {
                    print('got value');
                    _productLastPrice = value[0];
                  }),
                }
            })
        .catchError((e) => {
              print('Error Inside handleProductLastPriceClick Fn '),
              print(e),
            })
        .whenComplete(() => {
              FormatAndShowProductLastPrice(_Product),
            });
  }

  void FormatAndShowProductLastPrice(Product _Product) {
    if (_productLastPrice != null && _productLastPrice.LastPrice != null) {
      this.setState(() {
        strProductLastPrice = '$currencySymbol ${_productLastPrice.LastPrice}';
        isGotLastPrice = true;
      });
    } else {
      this.setState(() {
        strProductLastPrice = 'Not Available';
        isGotLastPrice = true;
      });
    }
    showDialog(
      useRootNavigator: true,
      barrierDismissible: false,
      context: widgetContext,
      builder: (context) => new AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
        elevation: 1,
        content: Container(
          padding: const EdgeInsets.all(2.0),
          width: double.maxFinite,
          //height: 200,
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(
                        'Last Price Lookup',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: Icon(
                        Icons.close,
                        size: 30,
                      ),
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true)
                            .pop('PopupClosed');
                      },
                    ),
                  ),
                ],
              ),
              getRowContentWidget('Product Code', _Product.ProductCode),
              Divider(
                height: 1,
                color: AppColors.lightGrey,
              ),
              getRowContentWidget('Description', _Product.Description),
              Divider(
                height: 1,
                color: AppColors.lightGrey,
              ),
              getRowContentWidget('Last Price', '${strProductLastPrice}'),
            ],
          ),
        ),
//        actions: <Widget>[
//          RaisedButton(
//            onPressed: () {
//              Navigator.of(context, rootNavigator: true).pop();
//            },
//            child: Text('Ok'),
//          ),
//        ],
      ),
    );
  }

  Widget getRowContentWidget(keyText, keyValue) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Text(
              '$keyText :',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            width: 5,
          ),
          Expanded(
            child: Text(
              '${keyValue != null ? '$keyValue' : '-'}',
              style: TextStyle(
                  color: AppColors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget getQuoteRowBasePriceTF({
    @required String label,
    @required bool readOnly, //To disable field until Product is selected
    @required TextInputType textInputType, //Type of Keypad to show on TFF Focus
    @required QuoteDetailField detailFieldObj, //Single QuoteFieldObject
    @required
        int quoteDetailPosition, //    int quoteRecordPosition, //Position for the <_quoteDetailsList>
    @required
        int quoteDetailFieldPosition, //    int fieldRecordPosition, //Position for the single Field from the <_quoteDetailsList<quotesList>>
  }) {
    bool _isReadOnly = _quote.QuoteDetail[quoteDetailPosition]
        .QuoteDetailFields[quoteDetailFieldPosition].IsReadonly;
    bool _isRequired = _quote.QuoteDetail[quoteDetailPosition]
        .QuoteDetailFields[quoteDetailFieldPosition].IsRequired;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextFormField(
              enableInteractiveSelection:false,//to avoide copy pase
              readOnly: _isReadOnly,
              controller: detailFieldObj.textEditingController,
              style: _formTFTextStyle,
              maxLength: 10,
              decoration: getFormTFInputDecoration('$label', false),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                // WhitelistingTextInputFormatter(RegExp(r'^\d+\.?\d{0,2}'))
                WhitelistingTextInputFormatter(RegExp(r'(^\d*\.?\d{0,2})'))
              ],
              onChanged: (text) {
                print('allMatches :--${'.'.allMatches(text).length}');
                if (text != null &&
                    text != '' &&
                    text.startsWith('.') == false) {
                  if (text.contains(',') ||
                      text.contains(' ') ||
                      text.contains('-')) {
                    setState(() {
                      detailFieldObj.FieldValue = "0";
                      detailFieldObj.textEditingController.text = "";
                    });
                    _scaffoldKey.currentState.showSnackBar(SnackBar(
                      content: Text('Kindly enter valid values'),
                      backgroundColor: AppColors.greyOut,
                      behavior: SnackBarBehavior.floating,
                      action: SnackBarAction(
                          label: "Close",
                          onPressed: () {
                            // Some code to undo the change.
                          }),
                    ));
                  } else {
                    if ('.'.allMatches(text).length > 1) {
                      setState(() {
                        detailFieldObj.FieldValue = "0";
                        detailFieldObj.textEditingController.text = "";
                      });
                      _scaffoldKey.currentState.showSnackBar(SnackBar(
                        content: Text('Kindly enter valid values'),
                        backgroundColor: AppColors.greyOut,
                        behavior: SnackBarBehavior.floating,
                        elevation: 20,
                        action: SnackBarAction(
                            label: "Close",
                            onPressed: () {
                              // Some code to undo the change.
                            }),
                      ));
                    } else {
                      setState(() {
                        detailFieldObj.FieldValue = text;
                      });
                    }
                  }
                } else {
                  setState(() {
                    detailFieldObj.textEditingController.text = "";
                    detailFieldObj.FieldValue = "0";
                  });
                }
                handleProductBasePriceOnChange(
                  onChangedValue: detailFieldObj.FieldValue,
                  quoteDetailPosition: quoteDetailPosition,
                  quoteDetailFieldPosition: quoteDetailFieldPosition,
                );
//                if (text != null && text != '') {
//                  text = text.replaceAll(new RegExp(r'[^0-9\.]'), '');
//                  if ('.'.allMatches(text).length > 1 && text.endsWith('.')) {
//                    //Validation for cases like 55.556.., 5..5 etc
//                    text = text.substring(0, text.lastIndexOf('.'));
//                    detailFieldObj.textEditingController.text = text;
//                  }
//                  setState(() {
//                    detailFieldObj.FieldValue = text;
//                  });
//                  handleProductBasePriceOnChange(
//                    onChangedValue: text,
//                    quoteDetailPosition: quoteDetailPosition,
//                    quoteDetailFieldPosition: quoteDetailFieldPosition,
//                  );
//                } else {
//                  setState(() {
//                    detailFieldObj.FieldValue = "0";
//                  });
//                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20.0, right: 8.0),
            child: InkWell(
                child: Icon(
                  Icons.visibility,
                  size: 20,
                ),
                onTap: () {
                  isOffline == false
                      ? ShowProductLastPrice(
                          _quote.QuoteDetail[quoteDetailPosition].product)
                      : _commonWidgets.showFlutterToast(
                          toastMsg: ConnectionStatus.NetworkNotAvailble);
                }),
          ),
        ],
      ),
    );
  }

  ///IT BUILDS THE QUOTE_DETAIL's TAX FIELD DROPDOWN
  Widget getQuoteDetailTaxDropDown({
    @required String label,
    @required QuoteDetailField detailFieldObj, //Single QuoteFieldObject
    @required
        int quoteDetailPosition, //    int quoteRecordPosition, //Position for the <_quoteDetailsList>
    @required
        int quoteDetailFieldPosition, //    int fieldRecordPosition, //Position for the single Field from the <_quoteDetailsList<quotesList>>
  }) {
//    print(
//        '_quote.QuoteDetail[quoteDetailPosition].TaxDropDownValue: ${_quote.QuoteDetail[quoteDetailPosition].TaxDropDownValue.Code}');
//    print('taxDropDownMenuItems : $taxDropDownMenuItems');

    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
      child: InputDecorator(
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(5, 20, 5, 0),
          labelText: '$label',
          labelStyle: TextStyle(
            color: Colors.blue,
            height: 0.5,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        child: DropdownButton(
          isDense: true,
//          style: _formTFTextStyle,
          value: _quote.QuoteDetail[quoteDetailPosition].TaxDropDownValue,
          items: taxDropDownMenuItems,
          onChanged: (StandardDropDownField selectedItem) {
            setState(() {
              _quote.QuoteDetail[quoteDetailPosition].TaxDropDownValue =
                  selectedItem;
              _quote
                  .QuoteDetail[quoteDetailPosition]
                  .QuoteDetailFields[quoteDetailFieldPosition]
                  .FieldValue = '${selectedItem.Code}';
            });
          },
          isExpanded: true,
        ),
      ),
    );
  }

  ///BEFORE DELETING AND ALSO UPDATES THE QUOTE_LIST IF QUOTE IS DELETED
  Widget _getQuoteDeleteButton({
    int quoteDetailPosition,
  }) {
    return Center(
      child: Padding(
        padding: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
        child: RaisedButton(
          onPressed: isSubmitButtonDisabled == false
              ? null
              : () {
                  print('single Quote delete Button pressed');
                  showDialog(
                    useRootNavigator: true,
                    barrierDismissible: false,
                    context: widgetContext,
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
                              'You want to delete the product?',
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
                            print(
                                'HERE DO THE CHANGES TO DELETE QUOTE_FIELDS ENTRY FROM LOCAL_DATABASE ALSO REMOVE DETAIL_REFERENCE_ID FROM THE MAIN_ADD_QUOTE');
                            handleSingleQuoteDetailDelete(
                              quoteDetailPosition: quoteDetailPosition,
                            );
                            Navigator.of(context, rootNavigator: true).pop();
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
                },
          child: Icon(
            Icons.delete,
            color: Colors.white,
          ),
          color: Colors.red, //AppColors.grey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100.0),
          ),
        ),
      ),
    );
  }

  ///IT RETURNS THE SINGLE QUOTE CARD CONTENTS LIST
  List<Widget> getSingleQuoteCardContents({
    AddQuoteDetail quoteDetailObj,
    int quoteDetailPosition,
  }) {
    ///HOLDS THE LIST OF THE TEXT_FORM_FIELDS AND PRODUCT_LOOKUP WIDGETS FOR THE QUOTE_DETAILS
    List<Widget> _widgetsList = List<Widget>();

    ///HERE SETTING UP THE QUOTES_LIST SINGLE ROW CONTENTS
    for (var qdf = 0; qdf < quoteDetailObj.QuoteDetailFields.length; qdf++) {
      QuoteDetailField singleQuoteDetailField =
          quoteDetailObj.QuoteDetailFields[qdf];
      String _fieldName = singleQuoteDetailField.FieldName;
      String _labelName = singleQuoteDetailField.LabelName;
      if(_fieldName=="BasePrice" || _fieldName=="ExtAmount"){
        _labelName += ' (\$)';
      }
      if (singleQuoteDetailField.IsRequired) {
        _labelName += ' *';
      }

      ///HERE IF THE STANDARD_FIELD IS NOT THE ProductCode AND Tax THEN BINDING SIMPLE TEXT_FIELD
      if (_fieldName != 'ProductCode' &&
          _fieldName != 'Tax' &&
          _fieldName != 'Weight' &&
          _fieldName != 'Quantity' &&
          _fieldName != 'BasePrice' &&
          _fieldName != 'TotalWeight'&&
          _fieldName != 'OtherParam') {
        _widgetsList.add(
          ///ADDING THE TEXT_FORM_FIELD IF FIELD_NAME IS NOT PRODUCT_CODE
          getQuoteRowContentTF(
            label: '$_labelName',
            textInputType: numericFieldNames.contains('$_fieldName')
                ? TextInputType.number
                : TextInputType.text,
            readOnly: quoteDetailObj.product != null &&
                    quoteDetailObj.product.ProductCode != null
                ? singleQuoteDetailField.IsReadonly
                : true,
            detailFieldObj: singleQuoteDetailField,
            quoteDetailPosition: quoteDetailPosition,
            quoteDetailFieldPosition: qdf,
          ),
        );
      } else if (_fieldName == 'Tax') {
        _widgetsList.add(
          ///ADDING THE TEXT_FORM_FIELD IF FIELD_NAME IS NOT PRODUCT_CODE
          getQuoteDetailTaxDropDown(
            label: '$_labelName',
            detailFieldObj: singleQuoteDetailField,
            quoteDetailPosition: quoteDetailPosition,
            quoteDetailFieldPosition: qdf,
          ),
        );
      } else if (_fieldName == 'ProductCode') {
        ///HERE IF THE STANDARD_FIELD IS ProductCode THEN BINDING THE PRODUCT_LOOKUP TO THE FIELD
        _widgetsList.add(
          getProductLookupTF(
            label: '$_labelName',
            controller: singleQuoteDetailField.textEditingController,
            quoteDetailPosition: quoteDetailPosition,
            quoteDetailFieldPosition: qdf,
          ),
        );
      } else if (_fieldName == 'Quantity') {
        ///HERE IF THE STANDARD_FIELD IS ProductCode THEN BINDING THE PRODUCT_LOOKUP TO THE FIELD
        _widgetsList.add(
          getQuoteRowQuantityTF(
            label: '$_labelName',
            textInputType: numericFieldNames.contains('$_fieldName')
                ? TextInputType.number
                : TextInputType.text,
            readOnly: false,
            detailFieldObj: singleQuoteDetailField,
            quoteDetailPosition: quoteDetailPosition,
            quoteDetailFieldPosition: qdf,
          ),
        );
      } else if (_fieldName == 'BasePrice') {
        ///HERE IF THE STANDARD_FIELD IS ProductCode THEN BINDING THE PRODUCT_LOOKUP TO THE FIELD
        _widgetsList.add(
          getQuoteRowBasePriceTF(
            label: '$_labelName',
            textInputType: numericFieldNames.contains('$_fieldName')
                ? TextInputType.number
                : TextInputType.text,
            readOnly: true,
            detailFieldObj: singleQuoteDetailField,
            quoteDetailPosition: quoteDetailPosition,
            quoteDetailFieldPosition: qdf,
          ),
        );

        //added by Gaurav, 23-03-2022 by Gaurav
        if (singleQuoteDetailField.FieldValue != null &&
            singleQuoteDetailField.FieldValue != '') {
          if (double.parse(singleQuoteDetailField.FieldValue) == 0) {
            bool isProductExist = false;
            if (zeroPriceProduct != null && zeroPriceProduct.length > 0) {
              var prod = zeroPriceProduct.firstWhere(
                  (element) =>
                      element.ProductObject.ProductCode ==
                      quoteDetailObj.product.ProductCode,
                  orElse: () => null);
              if (prod != '' && prod != null) {
                setState(() {
                  isProductExist = true;
                });
              }
            }
            if (isProductExist == false) {
              zeroPriceProduct.add(ProductQuantity(quoteDetailObj.product, 0));
              _scaffoldKey.currentState.showSnackBar(SnackBar(
                content: Text(
                    '${quoteDetailObj.product.Description} (${quoteDetailObj.product.ProductCode}) have 0 price '),
                backgroundColor: AppColors.greyOut,
                behavior: SnackBarBehavior.floating,
                elevation: 20,
                action: SnackBarAction(
                    label: "Close",
                    onPressed: () {
                      // Some code to undo the change.
                    }),
              ));
            }
          }
        }
        //end
      }
    }
    _widgetsList.add(
      _getQuoteDeleteButton(
        quoteDetailPosition: quoteDetailPosition,
      ),
    );
    return _widgetsList;
  }

  bool isExpanded = false;

  bool ExapndedValue(int position) {
    setState(() {
      isExpanded = true;
    });
  }

  ///IT RETURNS THE SINGLE QUOTE WIDGET FOR THE QUOTE DETAILS VIEW
  /* Widget getSingleQuote({
    int quoteDetailPosition,
  }) {
    return ExpandedWidget(
      headerValue: 'Product ${quoteDetailPosition + 1}',
      initialExpanded: ExapndedValue(quoteDetailPosition),
      childWidget: GestureDetector(
        child: Row(
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    0.0, 0.0, 0.0, 20.0), //CARDS CONTENTS INSIDE PADDING
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: getSingleQuoteCardContents(
                    quoteDetailObj: _quote.QuoteDetail[quoteDetailPosition],
                    quoteDetailPosition: quoteDetailPosition,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }*/

  Widget getSingleQuote({
    int quoteDetailPosition,
  }) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
                0.0, 0.0, 0.0, 20.0), //CARDS CONTENTS INSIDE PADDING
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: getSingleQuoteCardContents(
                quoteDetailObj: _quote.QuoteDetail[quoteDetailPosition],
                quoteDetailPosition: quoteDetailPosition,
              ),
            ),
          ),
        ),
      ],
    );
  }

  ///IT RETURNS THE QUOTE DETAILS ROWS BASED ON THE CONTENTS PRESENT ON THE _quoteDetailsList LIST
  List<Widget> buildQuoteRows() {
    List<Widget> quoteRows = List<Widget>();
    for (var qd = 0; qd < _quote.QuoteDetail.length; qd++) {
      quoteRows.add(Padding(
          padding: const EdgeInsets.fromLTRB(2.0, 4.0, 2.0, 4.0),
        child: ExpansionPanelList(
          expansionCallback: (int index, bool status) {
            setState(() {
              _activeMeterIndex = _activeMeterIndex == qd ? null : qd;
            });
          },
          children: [
            new ExpansionPanel(
              canTapOnHeader: true,
              isExpanded: _activeMeterIndex == qd,
              headerBuilder: (BuildContext widgetContext, bool isExpanded) =>
                  Padding(
                padding: const EdgeInsets.fromLTRB(10.0, 5.0, 0.0, 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                        '${_quote.QuoteDetail[qd].product.Description} (${_quote.QuoteDetail[qd].product.ProductCode})'),
                    double.parse(_quote.QuoteDetail[qd].QuoteDetailFields
                                .firstWhere((element) =>
                                    element.FieldName == "BasePrice")
                                .FieldValue) ==
                            0
                        ? Text(
                            'Price : \$ ${_quote.QuoteDetail[qd].QuoteDetailFields.firstWhere((element) => element.FieldName == "BasePrice").FieldValue}  ',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, color: Colors.red))
                        : Text(
                            'Price : \$ ${_quote.QuoteDetail[qd].QuoteDetailFields.firstWhere((element) => element.FieldName == "BasePrice").FieldValue} ',
                          ),
                  ],
                ),
              ),
              body: getSingleQuote(
                quoteDetailPosition: qd,
              ),
            ),
          ],
        ),
      ));
    }
    return quoteRows;
  }

  ///IT BUILDS THE QUOTE DETAILS VIEW FOR THE PRODUCT MANAGEMENT
  Widget buildQuoteDetailsView() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ...buildQuoteRows(),
          // getQuoteAddButton(),
        ],
      ),
    );
  }

  ///IT SETS THE FORM ON_SAVED VALUES INTO THE REQUEST_FORMAT
  void handleCreateFormClick() {
    try {
      if (_quote.QuoteDetail.length > 0) {
        handleAddQuoteSaveToLocalDatabase(
          forType: OfflineSaveType.FROM_ADD_QUOTE_CLICK,
        );
      } else {
        ///SHOWING TOAST IF NOT A SINGLE QUOTE DETAIL IS PRESENT
        _commonWidgets.showFlutterToast(
            toastMsg: 'Quote details section cannot be empty!');
      }
    } catch (e) {
      print('Error Inside handleCreateFormClick Fn');
      print(e);
      setLocalDBUpdateError();
    }
  }

  ///IT INSERT'S UPDATES THE QUOTE_HEADER FIELDS TO THE LOCAL_DATABASE
  void handleAddQuoteSaveToLocalDatabase({
    OfflineSaveType forType,
  }) async {
    try {
      setState(() {
        isFullScreenLoading = true;
      });

      ///IF CREATE_ADD_QUOTE CLICK AND APP IS NOT OFFLINE THEN CALLING THE ADD_QUOTE API
      if (OfflineSaveType.FROM_ADD_QUOTE_CLICK == forType &&
          isOffline == false) {
        callAddQuoteAPI(
          forType: forType,
          quote: _quote,
        );
      } else {
        _commonWidgets.showFlutterToast(
            toastMsg:
                'Slow or no Internet Connection detected, Saving quote Details Offline! ');

        ///CALLS THE LOCAL INSERT/UPDATE FUNCTIONS FOR QUOTE HEADER AND DETAIL
        insertUpdateQuoteHeadersToDB(
          forType: forType,
          quote: _quote,
          redirectToMain: true,
        );
      }
    } catch (e) {
      print('Error inside handleAddQuoteSaveToLocalDatabase Fn ');
      print(e);
      setLocalDBUpdateError();
    }
  }

  bool isSubmited;

  ///IT PREPARES THE REQUEST JSON STRUCTURE AND SENDS IT TO THE API
  void callAddQuoteAPI({
    AddQuote quote,
    OfflineSaveType forType,
  }) async {
    try {
      // // #region Print Quote
      // quote.QuoteHeader.forEach((element) {
      //   print("Quotes Headers Res - Start");
      //   element.QuoteHeaderFields.forEach((element) {
      //     print(element.FieldName + " " + element.FieldValue);
      //   });
      //   print("Quotes Headers Res - Ends");
      // });
      // quote.QuoteDetail.forEach((element) {
      //   print("Quotes Details Res - Starts");
      //   element.QuoteDetailFields.forEach((element) {
      //     print(element.FieldName + " " + element.FieldValue);
      //   });
      //   print("Quotes Details Res - Ends");
      // });
      // // #endregion
      ///BUILDING THE REQUEST_JSON FOR THE ADD_QUOTE_API
      var jsonRequestString = ' { ';

      ///BUILDING QUOTE_HEADER_FIELDS JSON
      var quoteHeadersJsonString = ' "QuoteHeader" : [ ';
      _quote.QuoteHeader.forEach((singleQuoteHeader) {
        String subHeaderString = ' { ';
        print('_quote.ServerQuoteId : ${_quote.ServerQuoteId}');
        if (widget.addQuoteType == AddQuoteType.EDIT_CREATED_QUOTE ||
            (_quote.ServerQuoteId != null && _quote.ServerQuoteId != -1)) {
          int _serverQuoteID = (widget.listingQuoteObj != null &&
                  widget.listingQuoteObj.Id != null)
              ? widget.listingQuoteObj.Id
              : _quote.ServerQuoteId;
          subHeaderString += '"Id" : $_serverQuoteID ,';
        } else {
          subHeaderString += '"Id" : 0,';
          print('subHeaderString: $subHeaderString');
        }
        if (widget.addQuoteType == AddQuoteType.EDIT_CREATED_QUOTE ||
            (_quote.ServerQuoteId != null && _quote.ServerQuoteId != -1)) {
          String _status = (widget.listingQuoteObj != null &&
                  widget.listingQuoteObj.Status != null)
              ? widget.listingQuoteObj.Status
              : '';
          subHeaderString += '"Status" : "$_status" ,';
          print('subHeaderString: $subHeaderString');
        }

        subHeaderString += '"IsIntegrated" : 0,';
        subHeaderString += '"IsEdit" :"false",';
        subHeaderString += '"SalesSite" :"${userSalesSiteCode}",';
        singleQuoteHeader.QuoteHeaderFields.forEach((singleField) {
          print(
              'Key : ${singleField.toJson()['FieldName']}   value : ${singleField.toJson()['FieldValue']}');
          var value =
              numericFieldNames.contains(singleField.toJson()['FieldName'])
                  ? double.parse(singleField.toJson()['FieldValue'])
                  : (singleField.toJson()['FieldValue'] != null &&
                          singleField
                                  .toJson()['FieldValue']
                                  .toString()
                                  .trim()
                                  .length >
                              0
                      ? '"${singleField.toJson()['FieldValue']}"'
                      : null);
          subHeaderString +=
              '"${singleField.toJson()['FieldName']}" : $value ,';
        });
        subHeaderString =
            subHeaderString.substring(0, subHeaderString.lastIndexOf(','));
        subHeaderString += ' }, ';
        quoteHeadersJsonString += subHeaderString;
      });

      quoteHeadersJsonString = quoteHeadersJsonString.substring(
          0, quoteHeadersJsonString.lastIndexOf(','));
      quoteHeadersJsonString += ' ], ';
      jsonRequestString += quoteHeadersJsonString;

      //Added by Gaurav Gurav, 14-Oct-2022
      //added invoicing element
      var invoicingElementjson=' "QuoteInvoicingElement":[';
      var invoicingElement='';
      quoteInvElement.forEach((element)
      {
        element.invoicingElementvalue= double.parse(element.txtValue!=''? element.txtValue.toString():'0');
        print('--------------) ${element.invoicingElementvalue}');
        if(invoicingElement!=''){
          invoicingElement+=',';
        }
        invoicingElement+='{';
        invoicingElement+=' "InvoicingElementCode" :'+element.invoicingElement.code.toString();
        invoicingElement+=', "InvoicingElementValue" :'+element.invoicingElementvalue.toString();
        invoicingElement+='}';
      });
      invoicingElementjson +=invoicingElement;
      invoicingElementjson += '],';
      print('invoicingElementjson ======${invoicingElementjson}');
      jsonRequestString += invoicingElementjson;
      //end

      ///BUILDING QUOTE_DETAILS_FIELDS JSON
      var quoteDetailsJsonString = ' "QuoteDetail": [ ';
      _quote.QuoteDetail.forEach((singleQuoteDetail) {
        String subDetailString = ' { ';
        singleQuoteDetail.QuoteDetailFields.forEach((singleField) {
          print(
              'Key : ${singleField.toJson()['FieldName']}   value : ${singleField.toJson()['FieldValue']}');
          var value =
              numericFieldNames.contains(singleField.toJson()['FieldName'])
                  ? double.parse(singleField.toJson()['FieldValue'])
                  : singleField.toJson()['FieldName'] == 'Quantity'
                      ? int.parse(singleField.toJson()['FieldValue'])
                      : '"${singleField.toJson()['FieldValue']}"';

          //Added by Gaurav gurav, 24-Aug-2022
          if(singleField.toJson()['FieldName']=='OtherParam'){
            if(singleField.toJson()['FieldValue'].toString().contains('OtherParam')){
              //for the quote created on web portal
              var otherParams='"${singleField.toJson()['FieldValue'].toString().replaceAll('*','\\"')}"';
              print('---------------$otherParams');
              subDetailString +='"${singleField.toJson()['FieldName']}" : $otherParams ,';
            }
            else{
              var otherParams='"{\\"OtherParam\\": ${singleField.toJson()['FieldValue'].toString().replaceAll('*','\\"')}}"';
              subDetailString +='"${singleField.toJson()['FieldName']}" : $otherParams ,';
            }
          }
          //end
          else{
            subDetailString +=
            '"${singleField.toJson()['FieldName']}" : $value ,';
          }
        });

        subDetailString =
            subDetailString.substring(0, subDetailString.lastIndexOf(','));
        subDetailString += ' }, ';
        quoteDetailsJsonString += subDetailString;
      });

      quoteDetailsJsonString = quoteDetailsJsonString.substring(
          0, quoteDetailsJsonString.lastIndexOf(','));
      quoteDetailsJsonString += ' ] ';

      print('----qu-oteDetailsJsonString : $quoteDetailsJsonString');

      jsonRequestString += quoteDetailsJsonString + ' } ';
      print('Final jsonRequestString : $jsonRequestString');
      String _url ='${await Session.getData(Session.apiDomain)}${URLs.POST_ADD_QUOTE}';
      print('AddQuote API URL : $_url');
      final http.Response response = await http.post(
        _url,

        body: json.decode(json.encode(jsonRequestString)),
        headers: <String, String>{
          'Content-Type': 'application/json',
          "token": await Session.getData(Session.accessToken),
          "Username": await Session.getUserName() //added by Gaurav, 03-08-2020
        },
      ).timeout(duration);
      print('response.statusCode : ${response.statusCode}');
      if (response.statusCode == 200) {
        print('AddQuote Success response ');
        print(response.body);
        _commonWidgets.showFlutterToast(toastMsg: 'Quote Added Successfully! ');

        ///LOCAL_DATABASE_QUOTE_DELETE AFTER QUOTE SUCCESSFULLY ADDED FROM API
        deleteQuoteByID(quoteId: _quote.Id, isDeleteOnExit: true);
        setState(() {
          isSubmited = true;
        });
      } else {
        print('AddQuote Error response ');
        print(response.body);
        setState(() {
          isFullScreenLoading = false;
        });
      }
    } catch (e) {
      print('Error Inside callAddQuoteAPI Fn ');
      print(e);
//      setState(() {
//        isFullScreenLoading = false;
//      });
//      _commonWidgets.showFlutterToast(
//          toastMsg:
//              'Slow or no Internet Connection detected, Saving quote Details Offline! ');

      ///CALLS THE LOCAL INSERT/UPDATE FUNCTIONS FOR QUOTE HEADER AND DETAIL
      insertUpdateQuoteHeadersToDB(
        forType: forType,
        quote: _quote,
        redirectToMain: true,
      );
    }
  }

  ///IT INSERT'S UPDATES THE QUOTE_HEADERS FIELDS TO THE LOCAL_DATABASE
  void insertUpdateQuoteHeadersToDB({
    AddQuote quote,
    OfflineSaveType forType,
    bool redirectToMain = false,
  }) {
    try {
      ///CALLING QUOTE_HEADER HELPER METHODS FOR INSERT/UPDATE
      _addQuoteHeaderDBHelper
          .insertUpdateHeaderFields(
              headerFields: _quote.QuoteHeader[0].QuoteHeaderFields)
          .then((value) => {
                //print('Quote header values local Update response '),
                print(value),
                print(redirectToMain),
                  insertUpdateInvoicingElementToDB(
                  quote: _quote,
                  forType: forType,
                  redirectToMain: redirectToMain,
                ),
                // }
              })
          .catchError((e) => {
                print('Error Inside handleAddQuoteSaveToLocalDatabase '),
                print(e),
                setLocalDBUpdateError(),
              });
    } catch (e) {
      print('Error Inside insertUpdateQuoteHeadersToDB Catch Block ');
      print(e);
      setLocalDBUpdateError();
    }
  }

  ///IT INSERT'S UPDATES THE QUOTE_DETAIL FIELDS TO THE LOCAL_DATABASE
  void insertUpdateQuoteDetailsToDB({
    AddQuote quote,
    OfflineSaveType forType,
    bool redirectToMain = true,
  }) async {
    try {
      if (quote.QuoteDetail.length > 0) {
        ///CALLING SEQUENTIALLY QUOTE_FIELDS INSERT/UPDATE
        for (var i = 0; i < quote.QuoteDetail.length; i++) {
          bool isLastEntry = false;
          if (i == quote.QuoteDetail.length - 1) {
            isLastEntry = true;
          }
          _addQuoteDetailDBHelper
              .insertUpdateQuoteDetailFields(
                detailFields: quote.QuoteDetail[i].QuoteDetailFields,
              )
              .then((value) => {
                    print('QuoteDetail Insert Update Response '),
                    print(value),
                    print('LocalInsert Response for lastEntry : $isLastEntry'),
                    if (mounted && isLastEntry == true)
                      setLocalDBUpdateSuccess(
                        forType: forType,
                        redirectToMain: redirectToMain,
                      ),
                  });
        }
      } else {
        ///IF NO QUOTE DETAILS FOUND FOR SAVING THEN DIRECTLY NAVIGATING BACK TO THE LISTING PAGE
        print(
            'No Quote Details found for saving to localDb so directly navigating back to the parent page');
        setLocalDBUpdateSuccess(
          forType: forType,
          redirectToMain: redirectToMain,
        );
      }
    } catch (e) {
      print('Error Inside insertUpdateQuoteDetailsToDB Fn ');
      print(e);
      setLocalDBUpdateError();
    }
  }

  void insertUpdateInvoicingElementToDB({
    AddQuote quote,
    OfflineSaveType forType,
    bool redirectToMain = true,
  }) async {
    try {
      quoteInvoivingElement.clear();
      if (quoteInvElement.length > 0) {
        for (var i = 0; i < quoteInvElement.length; i++) {
          quoteInvoivingElement.add(new QuoteInvoicingElement(
            InvoicingElementCode: int.parse(
                quoteInvElement[i].invoicingElement.code),
            InvoicingElementValue: quoteInvElement[i].txtValue.toString()!=''? double.parse(
                quoteInvElement[i].txtValue.toString()):0,
            QuoteHeaderId: int.parse(
                quoteInvElement[i].quoteHeaderId.toString()),
            CreatedBy: "Greytrix",
            UpdatedBy: "",
            CreatedDate: "",
            UpdatedDate: "",
          ));
        }

          _quoteInvoicingElementDBHelper.AddQuoteInvoicingElement(
              quoteInvoivingElement
          )
              .then((value) => {
            print('insertUpdateInvoicingElementToDB Insert Update Response '),
            print(value),
            insertUpdateQuoteDetailsToDB(
              quote: _quote,
              forType: forType,
              redirectToMain: redirectToMain,
            ),
          });
      } else {
        ///IF NO QUOTE DETAILS FOUND FOR SAVING THEN DIRECTLY NAVIGATING BACK TO THE LISTING PAGE
        print(
            'No Invoicing Element');
        insertUpdateQuoteDetailsToDB(
          quote: _quote,
          forType: forType,
          redirectToMain: redirectToMain,
        );
      }
    } catch (e) {
      print('Error Inside insertUpdateQuoteDetailsToDB Fn ');
      print(e);
      setLocalDBUpdateError();
    }
  }


  ///IT SETS THE LOCAL_DATABASE_UPDATE SUCCESS TOAST
  void setLocalDBUpdateSuccess({
    OfflineSaveType forType,
    bool redirectToMain = true,
  }) {
    print("setLocalDBUpdateSuccess called on backButton Pressed ");
    setState(() {
      isFullScreenLoading = false;
    });

    ///IF OFFLINE SAVE TYPE NOT FROM ADD_QUOTE_CLICK THEN REMOVING THE TOAST MESSAGE FOR OFFLINE SAVED
    if (forType != OfflineSaveType.FROM_ADD_QUOTE_CLICK) {
      //_commonWidgets.showFlutterToast(toastMsg: 'Quote details saved Offline');
    } else if (forType == OfflineSaveType.FROM_ADD_QUOTE_CLICK) {
      _commonWidgets.showFlutterToast(
          toastMsg:'Slow or no Internet Connection detected, Saving quote Details Offline! ');
    }

    if (redirectToMain) {
      if (forType == OfflineSaveType.FROM_BACK_NAVIGATION_CLICK) {
        ///THEN NAVIGATING TO THE LISTING PAGE
        print('Navigate back');
        Navigator.pop(widgetContext, true);
      } else {
        print('Main Page');
        print('Back to Main Page');
        Navigator.pop(widgetContext, true);
      }
    }
  }

  ///IT SETS THE LOCAL_DATABASE_UPDATE ERROR TOAST
  void setLocalDBUpdateError() {
    setState(() {
      isFullScreenLoading = false;
    });
    _commonWidgets.showFlutterToast(
        toastMsg: 'Something went wrong! Try again later');
  }

  ///IT HANDLES THE QUOVTE PREVIEW NAVIGATION
  void handleQuotePreviewNavigation() {
    try {
      ///HERE GETTING THE TOTAL QUANTITY AND TOTAL_WEIGHT FOR THE PREVIEW
      double _totalWeight = 0.0;
      int _totalQuantity = 0;
      _quote.QuoteDetail.forEach((singleQuoteObj) {
        if (singleQuoteObj.QuoteDetailFields.length > 0)
          singleQuoteObj.QuoteDetailFields.forEach((singleField) {
            String _fieldValue = singleField.FieldValue != null &&
                    singleField.FieldValue != 'null' &&
                    singleField.FieldValue.toString().trim().length > 0
                ? singleField.FieldValue.toString().trim()
                : '';

            ///HERE GETTING THE VALUES FOR THE PREVIEW SECTION
            if (_fieldValue != '') {
              if (singleField.FieldName == 'TotalWeight') {
                ///GETTING TOTAL WEIGHT FOR PREVIEW
                _totalWeight +=
                    parseStringToDouble(value: singleField.FieldValue);
              } else if (singleField.FieldName == 'Quantity') {
                ///GETTING TOTAL QUANTITY FOR PREVIEW
                _totalQuantity += int.parse(singleField.FieldValue);
              }
            }
          });
      });
      setState(() {
        totalWeight = _totalWeight;
        totalQuantity = _totalQuantity;
      });
    } catch (e) {
      print(
          'Error while setting the TotalWeight and TotalQuantity fields for the Preview');
      print(e);
    }

    ///NAVIGATING TO THE Quote Preview PAGE
    Navigator.of(widgetContext).push(
      MaterialPageRoute(
        builder: (context) => QuotePreviewScreen(
          closePreviewDialog: this.closeSearchDialog,
          quoteDetailPreviewStandardFields: _detailsShowOnPreviewStandardFields,
          quoteHeaderPreviewStandardFields: _headersShowOnPreviewStandardFields,
          addQuoteObj: _quote,
          currencySymbol: currencySymbol,
          totalQuantity: totalQuantity,
          totalWeight: totalWeight,
          quoteInvoicingElement: quoteInvElement,
        ),
      ),
    );
  }

  Future<void> ValidationOnProductRealTimePrice() async {
    try {
      print('inside ValidationOnProductRealTimePrice');
      if (isOffline == false) {
        setState(() {
          isFullScreenLoading == true;
        });
        String _salesSite = await Session.getSalesSiteCode();
        String _customer = selectedCompany.CustomerNo;
        String _currency = _standardCurrencyDropDownField.Code;
        String _erpName = _standardERPDropDownField.Code;
        try {
          String temp = '';
          List<String> ErrorMsg;
          String strErrorMsg = '';
          String strFlag = '';
          String requestBody = '{';
          requestBody += '"CustomerNo" : "${_customer}",';
          requestBody += '"SalesSite" : "${_salesSite}",';
          requestBody += '"Currency" : "${_currency}",';
          requestBody += '"QuoteDetailsGrid" : [{';
          requestBody += '"QuoteDetail" : [';
          for (int i = 0; i < _quote.QuoteDetail.length; i++) {
            if (strFlag == '') {
              strFlag = 'val';
              requestBody += '{';
            } else {
              requestBody += ',{';
            }
            for (int j = 0;
                j < _quote.QuoteDetail[i].QuoteDetailFields.length;
                j++) {
              if (_quote.QuoteDetail[i].QuoteDetailFields[j].FieldName ==
                  'ProductCode') {
                requestBody +=
                    '"ProductCode" : "${_quote.QuoteDetail[i].QuoteDetailFields[j].FieldValue}",';
              }
              if (_quote.QuoteDetail[i].QuoteDetailFields[j].FieldName ==
                  'BasePrice') {
                requestBody +=
                    '"BasePrice" : "${_quote.QuoteDetail[i].QuoteDetailFields[j].FieldValue}",';
              }
              if (_quote.QuoteDetail[i].QuoteDetailFields[j].FieldName ==
                  'Quantity') {
                requestBody +=
                    '"Quantity" : "${_quote.QuoteDetail[i].QuoteDetailFields[j].FieldValue}"';
              }
            }
            requestBody += '}';
          }
          requestBody += ']';
          requestBody += '}]';
          requestBody += '}';

          print('Request Body: $requestBody');

          var ProductPriceList = List<ProductRealTimePrice>();
          String url =
              '${await Session.getData(Session.apiDomain)}${URLs.GET_PRICING}?ERPName=$_erpName';
          print('$url');

          final http.Response response = await http.post(
            url,
            body: json.decode(json.encode(requestBody)),
            headers: <String, String>{
              'Content-Type': 'application/json',
              "token": await Session.getData(Session.accessToken),
              "Username": await Session.getUserName()
              //added by Gaurav, 03-08-2020
            },
          ).timeout(duration);
          print('getPricing response.statusCode ${response.statusCode}');
          if (response.statusCode == 200) {
            if (response.body.contains('Error')) {
              print('Error ${response.body}');
              temp = response.body;
              temp = temp
                  .replaceAll('{', '')
                  .replaceAll('}', '')
                  .replaceAll('"', '')
                  .replaceAll('ErrorMessage:', '');
              temp = temp.substring(1, temp.length - 1);

              if (temp.contains(',')) {
                var lst = temp.split(',');
                for (int i = 0; i < lst.length; i++) {
                  if (strErrorMsg.isEmpty) {
                    var str = lst[i].toString().trimLeft();
                    print('str1 ${str.replaceAll(new RegExp(r'\s+'), ' ')}');
                    strErrorMsg = str.trimRight();
                    print('str2 $strErrorMsg');
                  } else {
                    var str = lst[i].toString().trimLeft();
                    strErrorMsg += ', ' + str.trimRight();
                  }
                }
                temp = strErrorMsg;
                // strErrorMsg=temp.substring(1,temp.length-1);
                if (strErrorMsg.contains(']ITMREF')) {
                  var lst = strErrorMsg.split(']');
                  String pos = lst[1].replaceAll(new RegExp(r'[^0-9]'), '');
                  if (pos.isNotEmpty) {
                    strErrorMsg +=
                        ', Please check product: ${_quote.QuoteDetail[int.parse(pos) - 1].product.Description} (${_quote.QuoteDetail[int.parse(pos) - 1].product.ProductCode})';
                  } else {
                    strErrorMsg +=
                        ', Please check product: ${_quote.QuoteDetail[0].product.Description} (${_quote.QuoteDetail[0].product.ProductCode})';
                  }
                }
              } else {
                strErrorMsg = temp.substring(1, temp.length - 1);
              }
              print("isDialogOpen:" + isDialogOpen.toString());
              if (!isDialogOpen) {
                activateDialog();
                _commonWidgets.showAlertMsg(
                  alertMsg: strErrorMsg.replaceAll(new RegExp(r'\s+'),
                      ' '), // regExp to remove extra spaces from line
                  context: widgetContext,
                  MessageType: AlertMessageType.ERROR,
                  onMsgPressed: onDialogPressed,
                );
              }
              setState(() {
                isFullScreenLoading == false;
                isValidateButtonDesable = false;
              });
            } else {
              if (!isDialogOpen) {
                activateDialog();
                _commonWidgets.showAlertMsg(
                  alertMsg: 'Validation successful...',
                  context: widgetContext,
                  MessageType: AlertMessageType.SUCCESS,
                  onMsgPressed: onDialogPressed,
                );
              }
              setState(() {
                isFullScreenLoading == false;
                isValidateButtonDesable = true;
                print('Validation successfull..');
                print("isDialogOpen:" + isDialogOpen.toString());
                isSubmitButtonDisabled = false;
                //Make header readonly
                for (int i = 0; i < _quote.QuoteHeader.length; i++) {
                  for (int j = 0;
                      j < _quote.QuoteHeader[i].QuoteHeaderFields.length;
                      j++) {
                    if (_quote.QuoteHeader[i].QuoteHeaderFields[j].FieldName ==
                            'PONumber' ||
                        _quote.QuoteHeader[i].QuoteHeaderFields[j].FieldName ==
                            'Notes')
                      _quote.QuoteHeader[i].QuoteHeaderFields[j].IsReadonly =
                          true;
                  }
                }
                //Make quote Details read only
                for (int i = 0; i < _quote.QuoteDetail.length; i++) {
                  for (int j = 0;
                      j < _quote.QuoteDetail[i].QuoteDetailFields.length;
                      j++) {
                    if (_quote.QuoteDetail[i].QuoteDetailFields[j].FieldName ==
                            'BasePrice' ||
                        _quote.QuoteDetail[i].QuoteDetailFields[j].FieldName ==
                            'Quantity') {
                      _quote.QuoteDetail[i].QuoteDetailFields[j].IsReadonly =
                          true;
                    }
                  }
                }
              });
            }
          }
        } catch (e) {
          print(
              'Error while calling multiple realtime APIs So calling normal flow');
          print(e);
          setState(() {
            isFullScreenLoading == false;
            isValidateButtonDesable = false;
            isSubmitButtonDisabled = true;
          });
          _commonWidgets.showFlutterToast(
              toastMsg: 'Slow or no Internet Connection detected!');
        }
      } else {
        print('Offline Api not call');
        _commonWidgets.showFlutterToast(
            toastMsg: 'Slow or no Internet Connection detected! ');
        setState(() {
          isFullScreenLoading == false;
          isValidateButtonDesable = false;
          isSubmitButtonDisabled = true;
        });
      }
    } catch (e) {
      print('Error inside handleProductRealTimeAPIData FN ');
      print(e);
    }
  }

  bool OfflineValidation() {
    bool isValidate = true;
    String strErrorMsg = '';
    try {
      print('OfflineValidation');
      setState(() {
        isValidate = true;
      });

      if (_quote.QuoteDetail.length < 1) {
        setState(() {
          isValidate = false;
        });
        print("isDialogOpen:" + isDialogOpen.toString());
        if (!isDialogOpen) {
          activateDialog();
          _commonWidgets.showAlertMsg(
            alertMsg: 'Add at least one product',
            context: widgetContext,
            MessageType: AlertMessageType.INFO,
            onMsgPressed: onDialogPressed,
          );
        }
        return isValidate;
      } else {
        for (int i = 0; i < _quote.QuoteDetail.length; i++) {
          for (int j = 0;
              j < _quote.QuoteDetail[i].QuoteDetailFields.length;
              j++) {
            if (_quote.QuoteDetail[i].QuoteDetailFields[j].FieldName ==
                'BasePrice') {
              String _basePrice = _quote.QuoteDetail[i].QuoteDetailFields[j]
                  .textEditingController.text
                  .toString();
              print('_basePrice $_basePrice');
              if (!_basePrice.isNotEmpty) {
                setState(() {
                  isValidate = false;
                  strErrorMsg =
                      'Unit price should not be empty for product ${_quote.QuoteDetail[i].product.ProductCode}';
                });
                break;
              }
            }
          }
          if (isValidate == false) {
            break;
          }
        }
        if (isValidate == false) {
          print("isDialogOpen:" + isDialogOpen.toString());
          if (!isDialogOpen) {
            activateDialog();
            _commonWidgets.showAlertMsg(
              alertMsg: strErrorMsg,
              MessageType: AlertMessageType.INFO,
              context: widgetContext,
              onMsgPressed: onDialogPressed,
            );
          }
        } else {
          for (int i = 0; i < _quote.QuoteDetail.length; i++) {
            for (int j = 0;
                j < _quote.QuoteDetail[i].QuoteDetailFields.length;
                j++) {
              if (_quote.QuoteDetail[i].QuoteDetailFields[j].FieldName ==
                  'Quantity') {
                String quantity = _quote.QuoteDetail[i].QuoteDetailFields[j]
                    .textEditingController.text;
                if (!quantity.isNotEmpty) {
                  setState(() {
                    isValidate = false;
                    strErrorMsg =
                        'Quantity should not be empty for product ${_quote.QuoteDetail[i].product.ProductCode}';
                  });
                  break;
                } else if (quantity == "0") {
                  isValidate = false;
                  strErrorMsg =
                      'Quantity should not be 0 for product ${_quote.QuoteDetail[i].product.ProductCode}';
                }
              }
            }
            if (isValidate == false) {
              break;
            }
          }
          if (isValidate == false) {
            print("isDialogOpen:" + isDialogOpen.toString());
            if (!isDialogOpen) {
              activateDialog();
              _commonWidgets.showAlertMsg(
                alertMsg: strErrorMsg,
                MessageType: AlertMessageType.INFO,
                context: widgetContext,
                onMsgPressed: onDialogPressed,
              );
            }
          } else {
            setState(() {
              isValidate = true;
            });
          }
        }
        return isValidate;
      }
    } catch (e) {
      print('Error inside OfflineValidation');
      print(e);
    }
  }

  void handleValidation() {
    bool isValidate = true;
    try {
      if (OfflineValidation() == true) {
        for (int i = 0; i < _quote.QuoteDetail.length; i++) {
          for (int j = 0;
              j < _quote.QuoteDetail[i].QuoteDetailFields.length;
              j++) {
            if (_quote.QuoteDetail[i].QuoteDetailFields[j].FieldName ==
                'Quantity') {
              isValidate = ValidationOnQuantity(
                onChangedValue:
                    _quote.QuoteDetail[i].QuoteDetailFields[j].FieldValue,
                quoteDetailPosition: i,
                quoteDetailFieldPosition: 1,
              );
              if (isValidate == false) {
                break;
              }
            }
          }
          if (isValidate == false) {
            break;
          }
        }
        if (isValidate == false) {
          showDialog(
            useRootNavigator: true,
            barrierDismissible: false,
            context: widgetContext,
            builder: (context) => AlertDialog(
              actions: <Widget>[
                RaisedButton(
                  onPressed: () {
                    ValidationOnProductRealTimePrice();
                    Navigator.of(context, rootNavigator: true)
                        .pop('PopupClosed');
                  },
                  color: AppColors.blue,
                  child: Text('Ok'),
                )
              ],
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
                      'Customer credit limit exceeds',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          ValidationOnProductRealTimePrice();
        }
      } else {
        setState(() {
          isValidateButtonDesable = false;
        });
      }
    } catch (e) {
      print('Error inside handleValidation');
      print(e);
    }
  }

  ///IT BUILDS THE FORM CONSISTING OF THE TWO EXPANDED_WIDGETS
  ///FOR QUOTE_HEADER AND QUOTE_DETAILS
  Widget buildExpandableForm(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
      child: ListView(
        children: <Widget>[
          Form(
            key: _formKey,
            child: Card(
              child: Column(
                children: <Widget>[
                  ///QUOTE_HEADER EXPANDABLE WIDGET
                  _quote.Id != null
                      ? Card(
                        child: ExpansionTile(
                            title: Text('Quote Header'),
                            initiallyExpanded: true,
                    children: <Widget>[ Card(
                        child:  Padding(
                          padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                          child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: buildQuoteHeaderView(),
                              )),
                    )],
                          ),
                      )
                      : _commonWidgets.showCommonLoader(
                          isLoaderVisible: !(_quote.Id != null)),
                  ///INVOICING ELEMENT EXPANDABLE WIDGET
              _quote.Id != null
                  ? Card(
                    child: ExpansionTile(
                        title:  Text('Invoicing Elements'),
                        initiallyExpanded: false,
                children: <Widget>[  Card(
                    child:  Padding(
                        padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: buildInvoicingElements(_quote.Id),
                          )),
                )],
                      ),
                  )
                  : _commonWidgets.showCommonLoader(
                      isLoaderVisible: !(_quote.Id != null)),

                  ///QUOTE_DETAILS EXPANDABLE WIDGET
                  _quote.Id != null
                      ? /*ExpandedWidget(
                          headerValue: 'Quote Details',
                          initialExpanded: true,
                          childWidget: buildQuoteDetailsView(),
                        )*/
                      Card(child: ExpansionTile(
                          title: Text('Quote Details'),
                          initiallyExpanded: false,
                          children: <Widget>[ Card(child: buildQuoteDetailsView())]))
                      : _commonWidgets.showCommonLoader(
                          isLoaderVisible: !(_quote.Id != null)),

                  ///ADDED TO LEAVE THE SPACE BETWEEN EXPANDABLE AND CREATE BUTTON
                  SizedBox(
                    height: 20.0,
                  ),

                  Row(
                    children: <Widget>[
                      ///HANDLES THE CREATE QUOTE FORM VALIDATION AND API CALL
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(15.0, 0.0, 10.0, 0.0),
                          child: RaisedButton(
                            onPressed: () {
                              ///IF STANDARD_PREVIEW_FIELDS ARE NOT PRESeNT THEN NOT SHOWING THE PREVIEW
                              if (_detailsShowOnPreviewStandardFields.length > 0 &&
                                  _headersShowOnPreviewStandardFields.length > 0) {
                                handleQuotePreviewNavigation();
                              } else {
                                _commonWidgets.showFlutterToast(
                                    toastMsg: 'Preview not available currently!');
                              }
                            },
                            child: Text(
                              'Preview',
                              style: TextStyle(color: Colors.white),
                            ),
                            color: AppColors.blue,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10.0, 0.0, 15.0, 0.0),
                          child: RaisedButton(
                            onPressed: isSubmitButtonDisabled == false
                                ? null
                                : () {
                                    handleAddProductNavigation();
                                  },
                            child: Text(
                              'Add Product',
                              style: TextStyle(color: Colors.white),
                            ),
                            color: AppColors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Row(
                    children: <Widget>[
                      ///HANDLES THE CREATE QUOTE FORM VALIDATION AND API CALL
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(15.0, 0.0, 10.0, 0.0),
                          child: RaisedButton(
                            onPressed: _quote.IsLocalQuote == 0
                                ? null
                                : () {
                                    //desble save button for online quote
                                    if (_dateController == null ||
                                        _dateController.text == '') {
                                      print(
                                          "isDialogOpen" + isDialogOpen.toString());
                                      if (!isDialogOpen) {
                                        activateDialog();
                                        _commonWidgets.showAlertMsg(
                                          alertMsg: 'Select document date first',
                                          context: widgetContext,
                                          MessageType: AlertMessageType.INFO,
                                          onMsgPressed: onDialogPressed,
                                        );
                                      }
                                    } else if (_quote.QuoteDetail.length < 1) {
                                      print(
                                          "isDialogOpen" + isDialogOpen.toString());
                                      if (!isDialogOpen) {
                                        activateDialog();
                                        _commonWidgets.showAlertMsg(
                                          alertMsg: 'Add at least one product',
                                          context: widgetContext,
                                          MessageType: AlertMessageType.INFO,
                                          onMsgPressed: onDialogPressed,
                                        );
                                      }
                                    } else {
                                      if (OfflineValidation() == true) {
                                        insertUpdateQuoteHeadersToDB(
                                            redirectToMain: true);
                                      }
                                    }
                                  },
                            child: Text(
                              'Save',
                              style: TextStyle(color: Colors.white),
                            ),
                            color: AppColors.blue,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10.0, 0.0, 15.0, 0.0),
                          child: RaisedButton(
                            onPressed: isSubmitButtonDisabled == false
                                ? null
                                : () {
                                    showDialog(
                                      useRootNavigator: true,
                                      barrierDismissible: false,
                                      context: widgetContext,
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
                                                'You want to delete all quote information?',
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
                                              Navigator.of(context,
                                                      rootNavigator: true)
                                                  .pop();
                                              print(
                                                  'Press Button Start Over Delete all Quote');
                                              setState(() {
                                                isFullScreenLoading = true;
                                              });
                                              //  deleteAll();
                                              deleteQuoteByID(
                                                  quoteId: _quote.Id,
                                                  isDeleteOnExit: false);
                                              setState(() {
                                                _quote.QuoteDetailIds = '';
                                                isFullScreenLoading = false;
                                              });
                                              //go to Select Customer Screen
                                              Navigator.pop(widgetContext, false);
                                            },
                                            child: Text('Yes'),
                                            color: AppColors.blue,
                                          ),
                                          RaisedButton(
                                            onPressed: () {
                                              Navigator.of(context,
                                                      rootNavigator: true)
                                                  .pop();
                                            },
                                            child: Text('No'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                            child: Text(
                              'Start Over',
                              style: TextStyle(color: Colors.white),
                            ),
                            color: AppColors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(
                    height: 10.0,
                  ),
                  Row(
                    children: <Widget>[
                      ///HANDLES THE CREATE QUOTE FORM VALIDATION AND API CALL
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(15.0, 0.0, 10.0, 0.0),
                          child: isSubmitButtonDisabled == true
                              ? RaisedButton(
                                  onPressed: isValidateButtonDesable
                                      ? null
                                      : () {
                                          setState(() {
                                            isValidateButtonDesable = true;
                                          });
                                          if (_dateController == null ||
                                              _dateController.text == '') {
                                            print("isDialogOpen:" +
                                                isDialogOpen.toString());
                                            if (!isDialogOpen) {
                                              activateDialog();
                                              _commonWidgets.showAlertMsg(
                                                alertMsg:
                                                    'Select document date first',
                                                context: widgetContext,
                                                MessageType: AlertMessageType.INFO,
                                                onMsgPressed: onDialogPressed,
                                              );
                                            }
                                          } else if (_quote.QuoteDetail.length <
                                              1) {
                                            print("isDialogOpen:" +
                                                isDialogOpen.toString());
                                            if (!isDialogOpen) {
                                              activateDialog();
                                              _commonWidgets.showAlertMsg(
                                                alertMsg:
                                                    'Add at least one product',
                                                context: widgetContext,
                                                MessageType: AlertMessageType.INFO,
                                                onMsgPressed: onDialogPressed,
                                              );
                                            }
                                          } else {
                                            isOffline == true
                                                ? _commonWidgets.showFlutterToast(
                                                    toastMsg: ConnectionStatus
                                                        .NetworkNotAvailble)
                                                : handleValidation();
                                          }
                                        },
                                  child: Text(
                                    'Validate',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  color: AppColors.blue,
                                )
                              : RaisedButton(
                                  onPressed: () {
                                    setState(() {
                                      setState(() {
                                        isValidateButtonDesable = false;
                                      });
                                      isSubmitButtonDisabled = true;
                                      for (int i = 0;
                                          i < _quote.QuoteHeader.length;
                                          i++) {
                                        for (int j = 0;
                                            j <
                                                _quote.QuoteHeader[i]
                                                    .QuoteHeaderFields.length;
                                            j++) {
                                          if (_quote
                                                      .QuoteHeader[i]
                                                      .QuoteHeaderFields[j]
                                                      .FieldName ==
                                                  'PONumber' ||
                                              _quote
                                                      .QuoteHeader[i]
                                                      .QuoteHeaderFields[j]
                                                      .FieldName ==
                                                  'Notes')
                                            _quote
                                                .QuoteHeader[i]
                                                .QuoteHeaderFields[j]
                                                .IsReadonly = false;
                                        }
                                      }
                                      for (int i = 0;
                                          i < _quote.QuoteDetail.length;
                                          i++) {
                                        for (int j = 0;
                                            j <
                                                _quote.QuoteDetail[i]
                                                    .QuoteDetailFields.length;
                                            j++) {
                                          if (_quote
                                                      .QuoteDetail[i]
                                                      .QuoteDetailFields[j]
                                                      .FieldName ==
                                                  'BasePrice' ||
                                              _quote
                                                      .QuoteDetail[i]
                                                      .QuoteDetailFields[j]
                                                      .FieldName ==
                                                  'Quantity') {
                                            _quote
                                                .QuoteDetail[i]
                                                .QuoteDetailFields[j]
                                                .IsReadonly = false;
                                          }
                                        }
                                      }
                                    });
                                  },
                                  child: Text(
                                    'Edit',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  color: AppColors.blue,
                                ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10.0, 0.0, 15.0, 0.0),
                          child: RaisedButton(
                            onPressed: isSubmitButtonDisabled
                                ? null
                                : () {
                                    print('Create Quote Button Pressed');
                                    if (isInitialCreateQuoteCLicked)
                                      setState(() {
                                        isInitialCreateQuoteCLicked = false;
                                      });
                                    if (_formKey.currentState.validate()) {
                                      print('Form is Validated ');
                                      handleCreateFormClick();
                                    }
                                  },
                            child: Text(
                              'Submit',
                              style: TextStyle(color: Colors.white),
                            ),
                            color: AppColors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void GetProductRealTimeAPIDataForNewData(
      int intPosition, List<ProductQuantity> ProductList) async {
    try {
      setState(() {
        isFullScreenLoading = true;
      });
      if (isOffline == false && isProductRealTimeDataLoded == false) {
        String _salesSite = userSalesSiteCode;
        String _customer = selectedCompany.CustomerNo;
        String _currency = _standardCurrencyDropDownField.Code;
        String _erpName = _standardERPDropDownField.Code;
        try {
          String strFlag = '';
          String requestBody = '{';
          requestBody += '"CustomerNo" : "${_customer}",';
          requestBody += '"SalesSite" : "${_salesSite}",';
          requestBody += '"Currency" : "${_currency}",';
          requestBody += '"QuoteDetailsGrid" : [{';
          requestBody += '"QuoteDetail" : [';
          for (int i = 0; i < ProductList.length; i++) {
            if (strFlag == '') {
              strFlag = 'val';
              requestBody += '{';
              requestBody +=
                  '"ProductCode" : "${ProductList[i].ProductObject.ProductCode}",';
              requestBody += '"Quantity" : "${ProductList[i].Quantity}"';
            } else {
              requestBody += ',{';
              requestBody +=
                  '"ProductCode" : "${ProductList[i].ProductObject.ProductCode}",';
              requestBody += '"Quantity" : "${ProductList[i].Quantity}"';
            }
            requestBody += '}';
          }
          requestBody += ']';
          requestBody += '}]';
          requestBody += '}';
          // print('Request Body: $requestBody');
          ApiService.getPricing(
            erpName: _erpName,
            requestBody: requestBody,
          )
              .then((value) => {
                    if (!value.toString().contains('Error'))
                      {
                        ProductRealTimePriceData.addAll(value),
                      }
                    else
                      {
                        showRealTimePriceIssue(value.toString()),
                      },
                    setState(() {
                      isProductRealTimeDataLoded = true;
                      AddNewProductdata(ProductList);

                      isFullScreenLoading = false;
                    }),
                  })
              .catchError((e) => {
                    print('Pricing API Error Response $e'),
                    setState(() {
                      isProductRealTimeDataLoded = true;
                      AddNewProductdata(ProductList);
                    }),
                  })
              .whenComplete(() => {
                    setState(() {
                      print('Completed---');
                      isProductRealTimeDataLoded = true;
                      if (ProductRealTimePriceData.length > 0)
                        updateDataBase(ProductRealTimePriceData);
                    }),
                  });
        } catch (e) {
          isFullScreenLoading = false;
          print(
              'Error while calling multiple realtime APIs So calling normal flow');
          print(e);
        }
      } else {
        print('Offline Api not call');
        setState(() {
          isFullScreenLoading = false;
          isProductRealTimeDataLoded = true;
          AddNewProductdata(ProductList);
        });
      }
    } catch (e) {
      print('Error inside GetProductRealTimeAPIDataForNewData FN ');
      print(e);
      setState(() {
        isFullScreenLoading = false;
      });
    }
  }

  void AddNewProductdata(List<ProductQuantity> result) {
    int quotePosition;
    setState(() {
      isFullScreenLoading == true;
      quotePosition = _quote.QuoteDetail.length;
      print('quotePosition $quotePosition');
    });
    if (isProductRealTimeDataLoded == false) {
      print('isProductRealTimeDataLoded $isProductRealTimeDataLoded');
      GetProductRealTimeAPIDataForNewData(quotePosition, result);
    } else {
      print('isProductRealTimeDataLoded $isProductRealTimeDataLoded');
      OtherParam otherParam;
      for (int i = 0; i < result.length; i++) {
        print('Product :${result[i].ProductObject.ProductCode}');
        if (ProductRealTimePriceData.length > 0) {
          var productPrice = ProductRealTimePriceData.firstWhere(
              (e) => e.ProductCode == result[i].ProductObject.ProductCode,
              orElse: () => null);
          if (productPrice != null) {
            print('Real time Price ${productPrice.Price} ');
            result[i].ProductObject.BasePrice = productPrice.Price;
            otherParam=productPrice.otherParams;
          }
        }
        addQuoteDetailWithProductQuantityData(
          quote: _quote,
          isLoadingLocalQuote: 1,
          ProductObj: result[i].ProductObject,
          Quantity: result[i].Quantity,
          otherParam: otherParam,
          quotePosition: quotePosition + i,
          isEditExistingQuote: true,
        );
        _activeMeterIndex = quotePosition + i;
      }
      setState(() {
        isFullScreenLoading == false;
      });
    }
  }

  void handleAddProductNavigation() async {
    ///NAVIGATING TO THE ADD_QUOTE PAGE
    var result = await Navigator.of(widgetContext).push(
      MaterialPageRoute(
        builder: (context) => new SearchProduct(
          isRedirectFromAddQuote: true,
        ),
      ),
    );
    print("AddQuote Navigation Back to the QuotesList screen:");
    if (result != null) {
      setState(() {
        isProductRealTimeDataLoded = false;
        if (ProductRealTimePriceData != null) {
          ProductRealTimePriceData.clear();
        }
      });
      //To add product in existing quote
      AddNewProductdata(result);
    }
    print(
        'Loading New data for the quotes to get updated Quotes list after any changes in edit quote or new quote added');
  }

  ///IT HANDLES THE DEVICE NAVIGATION BACK AND APP_BAR NAVIGATION BACK
  ///IT DISPLAYS ALERT BOX BEFORE LEAVING THE PAGE, AS ALL THE ENTERED VALUES WILL BE CLEARED
  bool isBackPressed;

//  Future<bool> _onBackPressed() {
//    return showDialog(
//      useRootNavigator: true,
//      barrierDismissible: false,
//      context: widgetContext,
//      builder: (context) =>
//      new AlertDialog(
//        content: SingleChildScrollView(
//          child: Column(
//            children: <Widget>[
//              Icon(
//                Icons.warning,
//                color: Colors.deepOrangeAccent,
//                size: 50,
//              ),
//              Text(
//                'WARNING',
//                style: TextStyle(
//                  fontWeight: FontWeight.bold,
//                  fontSize: 24,
//                ),
//              ),
//              SizedBox(
//                height: 5,
//              ),
//              widget.isOfflineQuote == true
//                  ? new Text(
//                QUOTE_OFFLINE_EDIT_EXIT_MSG,
//                style: TextStyle(
//                  fontWeight: FontWeight.bold,
//                  fontSize: 18,
//                ),
//              )
//                  : new Text(
//                QUOTE_OFFLINE_SAVE_EXIT_MSG,
//                style: TextStyle(
//                  fontWeight: FontWeight.bold,
//                  fontSize: 18,
//                ),
//              ),
//            ],
//          ),
//        ),
//        actions: <Widget>[
//          RaisedButton(
//            onPressed:   () {
//              ///FIRST CLOSING THE ALERT DIALOG
//              Navigator.of(context, rootNavigator: true).pop(true);
//              handleAddQuoteSaveToLocalDatabase(
//                forType: OfflineSaveType.FROM_BACK_NAVIGATION_CLICK,
//              );
//            },
//            child: Text('Yes'),
//            color: AppColors.blue,
//          ),
//          RaisedButton(
//            onPressed: () {
//              setState(() {
//                isBackPressed = true;
//              });
//              Navigator.of(context, rootNavigator: true).pop(false);
//              if (widget.isOfflineQuote == true) {
//                //Quote open in Edit mode
//                if (NewQuoteDetailsIds != null &&
//                    NewQuoteDetailsIds.length > 0) {
//                  print('Unsaved Quote Details Exist');
//                  handleUnsavedQuoteDetailDelete();
//                } else {
//                  Navigator.pop(widgetContext, true);
//                }
//              } else {
//                UpdateQuoteStatus(IsEdit: false);
//
//                //Remove quote
////                deleteQuoteByID(
////                  quoteId: _quote.Id,
////                  isDeleteOnExit: true,
////                );
////
//              }
//            },
//            child: Text('No'),
//          ),
//        ],
//      ),
//    ) ??
//        false;
//  }

  Future<bool> _onBackPressed({bool quoteAutoSaved = false}) {
    print(' _quote.IsLocalQuote ${_quote.IsLocalQuote}');
    return _quote.IsLocalQuote == 1
        ? showDialog(
              useRootNavigator: true,
              barrierDismissible: false,
              context: widgetContext,
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
                      widget.isOfflineQuote == true
                          ? new Text(
                              QUOTE_OFFLINE_EDIT_EXIT_MSG,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            )
                          : new Text(
                              QUOTE_OFFLINE_SAVE_EXIT_MSG,
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
                      ///FIRST CLOSING THE ALERT DIALOG
                      Navigator.of(context, rootNavigator: true).pop(true);
                      handleAddQuoteSaveToLocalDatabase(
                        forType: OfflineSaveType.FROM_BACK_NAVIGATION_CLICK,
                      );
                    },
                    child: Text('Yes'),
                    color: AppColors.blue,
                  ),
                  RaisedButton(
                    onPressed: () {
                      setState(() {
                        isBackPressed = true;
                      });
                      Navigator.of(context, rootNavigator: true).pop(false);
                      if (widget.isOfflineQuote == true) {
                        //Quote open in Edit mode
                        if (NewQuoteDetailsIds != null &&
                            NewQuoteDetailsIds.length > 0) {
                          print('Unsaved Quote Details Exist');
                          handleUnsavedQuoteDetailDelete();
                        } else {
                          Navigator.pop(widgetContext, true);
                        }
                      } else {
                        UpdateQuoteStatus(IsEdit: false);
                      }
                    },
                    child: Text('No'),
                  ),
                ],
              ),
            ) ??
            false
        : GoBack();
  }

  //Added by Gaurav Gurav, 07-Apr-2022
  void updateDataBase(List<ProductRealTimePrice> ProductList) {
    try {
      for (int i = 0; i < ProductList.length; i++) {
        var result = _productDBHelper.updateProductBasePrice(
            ProductList[i].Price.toString(),
            ProductList[i].ProductCode.toString());
        print('result $result');
      }
    } catch (ex) {}
  }

  // Added by Gaurav, 30-03-2022
  Future<bool> GoBack() {
    showDialog(
          useRootNavigator: true,
          barrierDismissible: false,
          context: widgetContext,
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
                  new Text(
                    'Kindly Validate and Submit to save the changes online',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  )
                ],
              ),
            ),
            actions: <Widget>[
              RaisedButton(
                onPressed: () {
                  ///FIRST CLOSING THE ALERT DIALOG
                  Navigator.of(context, rootNavigator: true).pop(true);
                },
                child: Text('Ok'),
                color: AppColors.blue,
              ),
              RaisedButton(
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop(true);
                  if (_quote.Id != -1) deleteQuoteByID(quoteId: _quote.Id);
                  Navigator.pop(widgetContext, true);
                },
                child: Text('Cancel'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    ///STORING BUILD_CONTEXT FOR THE BACK BUTTON NAVIGATION
    if (isInitialNavigation) {
      setState(() {
        widgetContext = context;
        isInitialNavigation = false;
      });
    }
    return ModalProgressHUD(
      inAsyncCall: isFullScreenLoading,
      opacity: 0.5,
      progressIndicator: CircularProgressIndicator(),
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(AppBarTitles.ADD_QUOTE),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              if (quoteAutoSaved &&
                  widget.addQuoteType != AddQuoteType.EDIT_CREATED_QUOTE) {
                Navigator.of(context).pop(true);
              } else {
                _onBackPressed();
              }
            },
          ),
        ),
        body: WillPopScope(
          //Added by Mayuresh, 24-07-22
          // onWillPop: _onBackPressed,
          onWillPop: () {
            if (quoteAutoSaved &&
                widget.addQuoteType != AddQuoteType.EDIT_CREATED_QUOTE) {
              Navigator.of(context).pop(true);
              return Future.value(true);
            } else {
              _onBackPressed();
            }
          },
          child: Container(
            width: double.infinity,
            height: double.infinity,
            child: _isPageLoadError
                ? Center(
                    child: Text(
                      '$_pageLoadErrorMsg',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: AppColors.grey,
                      ),
                    ),
                  )
                : buildExpandableForm(context),
          ),
        ),
      ),
    );
  }

  //Intial Timer Start, Added by Mayuresh, 24-07-22
  void startTimer() {
    try {
      print("Starts Intial Timer");
      print(intervalDuration.inSeconds.toString());
      intialSaveQuote = new Timer(Duration.zero, () {
        print("Starts Peroidic Method");
        saveQuote = new Timer.periodic(intervalDuration, (timer) {
          print("Calls Auto Save Quote");
          autoSave();
        });
      });
    } catch (e) {
      print("Error in startTimer");
      print(e);
    }
  }

  //Method to fire on set Interval, Added by Mayuresh, 24-07-22
  void autoSave() {
    try {
      print("Inside autoSave");
      print(OfflineValidation());
      print(isFullScreenLoading);
      if (OfflineValidation() && !isFullScreenLoading) {
        quoteAutoSaved = true;
        FocusScope.of(context).unfocus();
        _commonWidgets.showFlutterToast(toastMsg: 'Quote saved Offline');
        insertUpdateQuoteHeadersToDB(redirectToMain: false, quote: _quote);
      }
    } catch (e) {
      print("Error in autoSave");
      print(e);
    }
  }

  Widget commonTextField({
    @required int position,
    bool isExpanded,
    bool isRequired=false,
    TextEditingController  textEditingController,
    EdgeInsets outerPadding = StyleUtils.smallAllPadding,
  }) {
    try {
      Widget _widget = TextFormField(
        maxLength: 10,
        controller: textEditingController,
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          WhitelistingTextInputFormatter(RegExp(r'(^\d*\.?\d{0,2})'))
        ],
        style: _formTFTextStyle,
        decoration: getFormTFInputDecoration('${quoteInvElement[position].invoicingElement.description}', true),
        onChanged: (value) {
          quoteInvElement[position].txtValue=value.toString();
          },
          onEditingComplete: () {
          FocusScope.of(context).nextFocus();
        },
      );
      return isExpanded ? Expanded(child: _widget) : _widget;
    } catch (e) {

      print("Error in commonTextField");
      print(e);
      return Container(
        child: Text(e),
      );
    }
  }

//  Widget commonTextField({
//    @required int position,
//    bool isExpanded,
//    bool isRequired=false,
//   // TextEditingController  textEditingController,
//    EdgeInsets outerPadding = StyleUtils.smallAllPadding,
//  }) {
//    try {
//      Widget _widget = TextFormField(
//        maxLength: 10,
//        controller: invoicingElementTextEditingController[position],
//       // enableInteractiveSelection: false,
//        keyboardType: TextInputType.numberWithOptions(decimal: true),
//        inputFormatters: [
//          WhitelistingTextInputFormatter(RegExp(r'(^\d*\.?\d{0,2})'))
//        ],
//       // textInputAction: TextInputAction.next,
//        style: _formTFTextStyle,
//        decoration: getFormTFInputDecoration('${quoteInvElement[position].invoicingElement.description}', true),
//        onChanged: (value) {
//          if (value != null && value != '') {
//            print(value);
//            setState(() {
//              quoteInvElement[position].textEditingController.text=value.toString();
//              invoicingElementTextEditingController[position].text=value;
//            });
//          }
//        },
//        onEditingComplete: () {
//          print('Name editing complete');
//          //quoteInvElement[position].invoicingElementvalue=double.parse(invoicingElementTextEditingController[position].text.toString());
//          FocusScope.of(context).nextFocus();
//        },
//        validator: (value) {
//          try {
//            print('validation');
//          } catch (e) {
//            print('Error while setting the value for the textEditingController For Header Fields');
//            print(e);
//          }
//          return null;
//        },
//      );
//      return isExpanded ? Expanded(child: _widget) : _widget;
//    } catch (e) {
//      print("Error in commonTextField");
//      print(e);
//      return Container(
//        child: Text(e),
//      );
//    }
//  }
  //end

  List<Widget> buildInvoicingElements(int quoteHeaderId) {
    try {
      print ('----buildInvoicingElements---');
      List<Widget> _fields = <Widget>[];
      ///Adds Invoicing Elements, if not empty
      if (quoteInvElement.isNotEmpty) {
        int pos= 0;
        for (QuoteInvElement element in quoteInvElement) {
          //print('txtValue ${element.txtValue}');
          TextEditingController _textEditingController = new TextEditingController();
          quoteInvElement[pos].textEditingController= new TextEditingController();
          setState(() {
            if(element.txtValue !='') {
              print('---${element.txtValue}');
              _textEditingController.text=element.txtValue;
               quoteInvElement[pos].textEditingController.text=element.txtValue;
               if(element.txtValue=="0.0" ){
                 _textEditingController.text='';
                 quoteInvElement[pos].textEditingController.text='';
               }
              _textEditingController.selection = TextSelection.fromPosition(TextPosition(offset: _textEditingController.text.length));
            }
            else {
              quoteInvElement[pos].textEditingController.text='';
            }
            quoteInvElement[pos].quoteHeaderId=quoteHeaderId;
          });
          _fields.add(
              commonTextField(
                  position: pos,
                  isExpanded: true,
                  textEditingController: _textEditingController
              )
          );
          pos++;
        }
      }
      List<Widget> temp;
      setState(() {
        temp = CommonWidgets().dynamicWidgetStyles(context, widgets: _fields);
      });
      return temp;
    } catch (e) {
      print('Error in buildInvoicingElements');
      print(e);
      return [];
    }
  }

//  List<Widget> buildInvoicingElements(int quoteHeaderId) {
//    try {
//      print ('----buildInvoicingElements---');
//      List<Widget> _fields = <Widget>[];
//      ///Adds Invoicing Elements, if not empty
//      if (quoteInvElement.isNotEmpty) {
//        int pos= 0;
//        invoicingElementTextEditingController.clear();
//        for (QuoteInvElement element in quoteInvElement) {
//          setState(() {
//            invoicingElementTextEditingController.add(new TextEditingController(text: ''));
//            if(element.invoicingElementvalue!=0){
//              invoicingElementTextEditingController[pos].text=element.invoicingElementvalue.toString();
//              //_textEditingController.selection= TextSelection.fromPosition(TextPosition(offset: _textEditingController.text.length));
//            }
//            element.quoteHeaderId=quoteHeaderId;
//          });
//          _fields.add(
//            commonTextField(
//              position: pos,
//              isExpanded: true,
//            )
//          );
//          pos++;
//        }
//      }
//      List<Widget> temp;
//      setState(() {
//        temp = CommonWidgets().dynamicWidgetStyles(context, widgets: _fields);
//      });
//      return temp;
//    } catch (e) {
//      print('Error in buildInvoicingElements');
//      print(e);
//      return [];
//    }
//  }

  activateDialog() {
    this.setState(() {
      isDialogOpen = true;
    });
  }

  onDialogPressed() {
    this.setState(() {
      isDialogOpen = false;
    });
  }
}
