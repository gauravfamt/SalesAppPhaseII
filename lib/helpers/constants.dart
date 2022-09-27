import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moblesales/models/index.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DBChanges {
  // Change status when change structure of Compnay or Product Table
  static const bool isCompanyTableChange = true;
  static const bool isProductTableChange = true;
}

class URLs {
  ///TODO: Changes URL to STATIC WHILE PUSHING CHANGES TO THE DEVELOP BRANCH
  static const String LOGIN = "Login";
  static const String GET_DASHBOARD_DETAILS = "GetDashboardDetails";
  static const String GET_COMPANIES = "GetCompanies";
  static const String GET_USERS = "GetUsers";
  static const String GET_INVOICES = "GetInvoices";
  static const String GET_SALES_ORDERS = "GetOrders";
  static const String GET_QUOTES = "GetQuotes";
  static const String GET_PRODUCTS = "GetProducts";
  static const String GET_STANDARD_FIELDS = "GetStandardFields";
  static const String DELETE_COMPANY = "DeleteCompany";
  static const String GET_STANDARD_DROPDOWN_FIELDS = "GetDropDownFields";
  static const String GET_SALES_SITE = "GetSalesSites";
  static const String POST_ADD_QUOTE = "AddQuote";
  static const String GET_PRODUCT_LAST_PRICE = "GetProductLastPrice";
  static const String POST_SEND_MAIL = "SendMail";
  static const String GET_PRICING = "GetPricing";
  static const String UPDATE_QUOTE_BY_ID = "UpdateQuoteById";
  static const String GET_EMAIL_FEATURE = "GetEmailFeature";
  static const String GET_STOCK = "GetStock";
  static const String GET_CUSTOM_FIELDS = "GetCustomFields";
  static const String GET_CURRENT_DATE_TIME = "GetCurrentDatetime";
  static const String ADD_REPORT = "AddReportRequest";
  static const String GET_REPORT_STATUS = "GetReportStatus";
  static const String GET_APP_VERSION = "GetAppVersion";
  static const String GET_QUOTE_FEATURE = "GetQuoteFeature";
  static const String GET_INVOICINGELEMENT = "GetInvoicingElements";
}

class Other {
  //To redirect to play store when update is  available
  String ANDROID_APP_ID = "com.pockethcm.greytrix.test";
  String APPLE_APP_ID = "12345";

  //To display single loader at time on screen
  final DateFormater = DateFormat.yMd(Intl.defaultLocale);
  final TimeFormater = DateFormat.Hm(Intl.defaultLocale);

  String DisplayDate(String strDate) {
    String strDisplyDate = DateFormater.format(DateTime.parse(strDate));
    return strDisplyDate;
  }

  String DisplayDateTime(String strDate) {
    String strDisplyDate = DateFormater.format(DateTime.parse(strDate));
    String strDisplyTime = TimeFormater.format(DateTime.parse(strDate));
    return strDisplyDate + ' ' + strDisplyTime;
  }

  String parseHtmlString(String htmlString) {
    final document = parse(htmlString);
    final String parsedString = parse(document.body.text).documentElement.text;

    return parsedString;
  }
}

class Session {
  static const String userName = "USERNAME";
  static const String realName = "realName";
  static const String password = "PASSWORD";
  static const String accessToken = "ACCESS_TOKEN";
  static const String userCode = "USER_CODE";
  static const String salesSite = "SALES_SITE";
  static const String rptCSCode = "defaultCSRptCode";
  static const String rptARCode = "defaultARRptCode";
  static const String apiDomain = "APIDOMAIN";
  static const String isProductTableChange = "isProductTableChange";
  static const String isCompanyTableChange = "isCompanyTableChange";
  //Stores Interval
  static const String autoSaveInterval = "autoSaveInterval";

  static Future<String> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString(Session.accessToken);
    return token;
  }

  static Future<String> getUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userName = prefs.getString(Session.userName);
    return userName;
  }

  static Future<String> getUserCode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userCode = prefs.getString(Session.userCode);
    return userCode;
  }

  static Future<String> getSalesSiteCode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var salesSite = prefs.getString(Session.salesSite);
    return salesSite;
  }

  static Future<dynamic> getData(String sessionKey) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var data = prefs.get(sessionKey);
    return data;
  }

  static Future<String> getCustomerStatementReportCode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var ReportName = prefs.getString(Session.rptCSCode);
    return ReportName;
  }

  static Future<String> getARReportCode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var ReportName = prefs.getString(Session.rptARCode);
    return ReportName;
  }

  ///Gets Interval
  static Future<String> getAutoSaveInterval() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var interval = prefs.getString(Session.autoSaveInterval);
    return interval;
  }
}

///It consist of all the EntityNames which are needed for the GetStandardFields API
class StandardEntity {
  static const String COMPANY = "Company";
  static const String INVOICE_HEADER = "InvoiceHeader";
  static const String INVOICE_DETAIL = "InvoiceDetail";
  static const String PAYMENT_HEADER = "PaymentHeader";
  static const String CASES = "Cases";
  static const String OPPORTUNITY = "Opportunity";
  static const String CREDIT_MEMO_HEADER = "CreditMemoHeader";
  static const String PERSON = "Person";
  static const String AR_INVOICE_HEADER = "ARInvoiceHeader";
  static const String ORDER_HEADER = "OrderHeader";
  static const String ORDER_DETAIL = "OrderDetail";
  static const String QUOTE_HEADER = "QuoteHeader";
  static const String QUOTE_DETAIL = "QuoteDetail";
  static const String QUOTE_DROPDOWN_ENTITY = "Quote";
  static const String ORDER_DROPDOWN_ENTITY = "Order";
  static const String CURRENCY_DROPDOWN_ENTITY = "Currency";
  static const String ERP_DROPDOWN_ENTITY = "ERP";
  static const String PRODUCT = "Product";
  static const String TAX_DROPDOWN_ENTITY = "Tax";
}

///HOLDS DROPDOWN SEARCH_TEXTS FOR GETTING THE STANDARD DROPDOWN FIELDS
class DropdownSearchText {
  static const String QUOTE_DROPDOWN_SEARCH_TEXT = "Status";
  static const String ORDER_DROPDOWN_SEARCH_TEXT = "DeliveryStatus";
  static const String CURRENCY_DROPDOWN_SEARCH_TEXT = "Symbol";
}

///HERE PROVIDE THE LIST OF STRINGS WHICH CONTAINS STANDARD_ENTITY_SECTION_NAMES
///AND ONLY PROVIDED SECTION VALUES WILL BE DISPLAYED ON THE UI
class AllowedEntitySections {
  static const List<String> COMPANY_VIEW_ADDRESS_SECTIONS = ['Address'];
}

///IT HOLDS ModalProgressHUD WIDGET FULL_SCREEN LOADER SETTINGS USED IN THE APP
class FullScreenLoader {
  static const double OPACITY = 0.5;
  static const Widget PROGRESS_INDICATOR = CircularProgressIndicator();
}

///HOLDS ALL SCREENS APP BAR TITLES
class AppBarTitles {
  static const String CUSTOMER_PROFILES = "Customers";
  static const String STATISTICS = "Statistics";
  static const String CUSTOMER_PROFILE_DETAILS = "Customer Details";
  static const String SALES_ORDERS = "Sales Orders";
  static const String SALES_ORDER_DETAILS = "Sales Order Details";
  static const String INVOICES = "Invoices";
  static const String INVOICE_DETAILS = "Invoice Details";
  static const String PRODUCTS = "Products";
  static const String QUOTES = "Quotes";
  static const String QUOTES_DETAILS = "Quote Details";
  static const String ADD_QUOTE = "Quote Management";
  static const String NOTIFICATIONS = "Notifications";
  static const String PRODUCT_DETAILS = "Product Details";
  static const String SELECT_CUSTOMER = "Select Customer";
  static const String INVENTORY = "Inventory";
}

class LocalDatabase {
  static const String DATABASE_NAME = "mobileSales.db";
}

///HOLDS THE RECORDS PER PAGE FOR THE API PARAMETERS
class Pagination {
  static const int LIST_PAGE_SIZE = 10;
  static const int LOOKUP_PAGE_SIZE = 10;
  static const int GRID_PAGE_SIZE = 12;
  static const int TABLE_PAGE_SIZE = 20;
  static const String NO_MORE_DATA = 'No More Data!';
}

///HOLDS CONSTANTS WHICH CAN BE USED THROUGH_OUT APP IN ALL SCREENS
class CommonConstants {
  static const String NO_DATA_FOUND = 'No Data Found!';
  static const String LOADING_DATA = 'Loading data...';
  static const String APP_IS_OFFLINE_FOR_LOADING_DATA =
      'No internet connection present for loading data';
  static const String SEARCH_PLACEHOLDER_MSG = "Search";
  static const String CUSTOMER_SEARCH_PLACEHOLDER_MSG = "Select Customer";
  static const String PRODUCT_SEARCH_PLACEHOLDER_MSG = "Select Product";
  static const String GO_TO_SETTING_AND_SYNC_DATA =
      "Go to settings and sync data";
}

///HOLDS THE ENUM VALUES FOR INTERNET_CONNECTIVITY STATUS
enum ConnectivityStatus {
  wifi,
  mobileData,
  offline,
}
enum CustomerSearch {
  customerNumber,
  customerName,
  city,
  zip,
}
enum AlertMessageType {
  SUCCESS,
  INFO,
  ERROR,
  WARNING,
}

///USED TO CHECK IF TO INSERT/UPDATE TO THE LOCAL_DATABASE ON NAVIGATION BACK OR THE CREATE_QUOTE_BUTTON CLICK
enum OfflineSaveType {
  FROM_ADD_QUOTE_CLICK,
  FROM_BACK_NAVIGATION_CLICK,
}

///HOLDS BARCODE_SCANNER ERROR TEXTS AND OTHER CUSTOM SETTINGS
class BarcodeScanHelper {
  static const String PLATFORM_VERSION_ERROR =
      'Failed to get platform version.';
}

///HOLDS ADD_QUOTE DEFAULT VALUES IF ANY FOR FORM AUTO_FILL
class AddQuoteDefaults {
  static const String DEFAULT_DOCUMENT_TYPE = 'SQN';
  static const String DEFAULT_DOCUMENT_NO = 'SQN-';
  static const int PO_NUMBER_FIELD_MAX_LENGTH = 20;
  static const int NOTES_FIELD_MAX_LENGTH = 100;
  static const int FIELDS_DEFAULT_MAX_LENGTH = 1000;
}

///HOLDS THE LIST OF ALL THE STANDARD_FIELD_NAMES TO WHICH CURRENCY SIGN NEEDED TO BE DISPLAYED
const List<String> CurrencyFields = [
  'PaidAmount',
  'DocumentTotal',
  'AmountDue',
  'ExtAmount',
  'BasePrice',
  'Balance',
  'CreditLimit',
  'TotalBalance',
];

///TO IDENTIFY FOR WHICH TYPE ADD_QUOTE PAGE IS OPENED
enum AddQuoteType {
  NEW_QUOTE,
  EDIT_OFFLINE_QUOTE,
  EDIT_CREATED_QUOTE,
}

///HOLDS ENUMS FOR THE NOTIFICATIONS TYPES
enum NotificationType { QUOTES, DATA_SYNC, APP_UPDATE }

///NOTIFICATION CONSTANTS
class NotificationMessages {
  static const String EMPTY_NOTIFICATIONS = 'No new notifications!';
  static const String QUOTE_PENDING_TO_SYNC = 'Offline quote pending to sync';
  static const String APP_UPDATE = 'New update available';
}

class ConnectionStatus {
  static const String NewtworkRestored = 'Data Connectivity Restored!';
  static const String NetworkNotAvailble =
      'Slow or no Internet Connection detected!';
  static bool isOffline = false;
}

///CONSTANTS FOR THE SEND MAIL FEATURE
class SendMailHelper {
  static const String TEMPLATE_SALES_ORDER = 'SalesOrder';
  static const String TEMPLATE_PRODUCT = 'Product';
  static const String FILE_TYPE_SALES_ORDER = 'pdf';
  static const String FILE_TYPE_PRODUCT = '';
}

//Constant TextStyles
class StyleUtils {
  static const TextStyle smallboldStyle =
      TextStyle(fontWeight: FontWeight.bold, fontSize: 10);

  static const TextStyle labelStyle = TextStyle(
    color: Colors.blue,
    height: 0.5,
    fontSize: 10,
    fontWeight: FontWeight.bold,
  );
  static const EdgeInsets smallVerticalPadding =
      EdgeInsets.symmetric(vertical: 3.0);
  static const EdgeInsets smallHorizontalPadding =
      EdgeInsets.symmetric(horizontal: 3.0);
  static const EdgeInsets smallAllPadding = EdgeInsets.all(3.0);
  static const EdgeInsets largeVerticalPadding =
      EdgeInsets.symmetric(vertical: 20.0);
}

///IT RETURNS THE RANDOM UNIQUE KEY
class RandomKeyGenerator {
  static final Random _random = Random.secure();

  static String createCryptoRandomString([int length = 6]) {
    var values = List<int>.generate(length, (i) => _random.nextInt(256));

    return base64Url.encode(values);
  }
}

const duration = Duration(seconds: 30);

///IT RETURNS THE FORMATTED STRING FOR SAVING INTO THE DATABSE
String getFormattedStringForSave(String val) {
  return val != null ? val.replaceAll('"', ' ') : '';
}

///IT CHECKS IF ALL THE EMAIL-ID's INSERTED HAVE VALID FORMAT
bool isValidEmailFormat({
  @required String value,
}) {
  return RegExp(
          r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,3}))$')
      .hasMatch(value);
}

///IT PARSE THE STRING VALUE TO THE DOUBLE VALUE
double parseStringToDouble({@required String value}) {
  double returnVal = 0.0;
  try {
    if (value != null) {
      returnVal = double.parse(value);
    }
  } catch (e) {
    print('Error while paring the String to double value');
  }
  return returnVal;
}

bool isLargeScreenAvailable(@required BuildContext context) {
  var size = MediaQuery.of(context).size;
  return size.width > 600 ? true : false;
}

///IT PARSE THE STRING VALUE TO THE INTEGER VALUE
int parseStringToInteger({@required String value}) {
  int returnVal = 0;
  try {
    if (value != null) {
      returnVal = int.parse(value);
    }
  } catch (e) {
    print('Error while paring the String to integer value');
  }
  return returnVal;
}

///IT TRANSFORMS THE
String transformDate({
  @required String dateValue,
  bool includeTime = false,
}) {
  String _transformedDate = '';
  try {
    if (dateValue != null && dateValue != '') {
      var dt = DateTime.parse(dateValue);
      _transformedDate =
          '${(dt.day).toString()}/${(dt.month).toString()}/${dt.year}';
      if (includeTime) {
        _transformedDate += ' ${dt.hour}:${dt.minute}';
      }
    }
  } catch (e) {
    print(e);
    _transformedDate = dateValue;
  }

  return _transformedDate;
}

String transformDateToLocal({
  @required String dateValue,
  bool includeTime = false,
}) {
  String _transformedDate = '';
  try {
    if (dateValue != null && dateValue != '') {
      var dt = DateTime.parse(dateValue).toLocal();

      var dtNew = DateTime(dt.year, dt.month, dt.day, dt.hour + 5,
          dt.minute + 30, dt.second, dt.millisecond, dt.microsecond);

      _transformedDate =
          '${(dtNew.day).toString()}/${(dtNew.month).toString()}/${dtNew.year}';
      if (includeTime) {
        _transformedDate += ' ${dtNew.hour}:${dtNew.minute}';
      }
    }
  } catch (e) {
    print(e);
    _transformedDate = dateValue;
  }

  return _transformedDate;
}

///HERE ADD THE KEYS OR CONSTANTS RELATED TO BACKGROUND SERVICE
class BackgroundServiceHelper {
  static const String SHARED_PREF_IDENTIFIER = 'BACKGROUND_SYNC';

  ///TO IDENTIFY IF THE SYNC_LOOKUP'S BUTTON CALLED FROM THE SETTINGS
  static bool isBackgroundSyncCalled = false;
  static const String BACKGROUND_SYNC_TASK = "lookupsSyncTask";
  static const String BACKGROUND_STANDARD_FIELDS_SYNC_TASK =
      "standardFieldsSyncTask";

  ///HOLDS THE KEY TO IDENTIFY TRUE_TIME_PACKAGE ERROR
  static const String LAST_SYNC_DATE_ERROR_CODE = "TRUE_TIME_ERROR";

  static const String SYNC_INITIAL_LOOKUPS_DATA_MSG =
      "Please go to settings option on home Screen and press sync button to sync the lookup's data";
}

class ApiService {
  static Future<List<dynamic>> getEmployees() async {
    final response =
        await http.get('${await Session.getData(Session.apiDomain)}/employees');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  static Future<bool> addEmployee(body) async {
    // BODY
    // {
    //   "name": "test",
    //   "age": "23"
    // }
    final response = await http
        .post('${await Session.getData(Session.apiDomain)}/create', body: body);
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  ///It makes the http Request for fetching the standardFields
  static Future<List<StandardField>> getStandardFields({
    String entity,
    bool showInGrid,
    bool showOnScreen,
    String tokenValue = '',
    String apiDomain = '', //Use for background sync
  }) async {
    var standardFieldData = List<StandardField>();
    try {
      if (apiDomain == '' || apiDomain == null) {
        //Use on app screen
        apiDomain = await Session.getData(Session.apiDomain);
      }
      String url = '${apiDomain}${URLs.GET_STANDARD_FIELDS}?Entity=$entity';
      if (showInGrid) {
        url = '$url&ShowOngrid=$showInGrid';
      }
      if (showOnScreen) {
        url = '$url&ShowOnScreen=$showOnScreen';
      }

      http.Client client = http.Client();
//      SharedPreferences prefs = await SharedPreferences.getInstance();
//      var data = prefs.get(Session.accessToken);
      final response = await client.get(url, headers: {
        "token": tokenValue != null && tokenValue != ''
            ? tokenValue
            : await Session.getData(Session.accessToken),

        // "Username":await Session.getUserName()//added by Gaurav, 03-08-2020
      }).timeout(duration);

      if (response.statusCode == 200 && response.body != "No fields found") {
        var data = json.decode(response.body);
        if (data != 'No fields found') {
          standardFieldData = data
              .map<StandardField>((json) => StandardField.fromJson(json))
              .toList();
        }
      }
      return standardFieldData;
    } catch (e) {
      print('Error inside getStandardFields api call function ');
      print(e);
      return standardFieldData;
    }
  }

  ///IT MAKES THE HTTP REQUEST FOR FETCHING STANDARD_DROPDOWN_FIELDS
  static Future<List<StandardDropDownField>> getStandardDropdownFields({
    @required String entity,
    String searchText = '',
    String tokenValue = '',
    String apiDomain = '',
  }) async {
    var standardDropdownFieldData = List<StandardDropDownField>();

    try {
      if (apiDomain == '' || apiDomain == null) {
        //Use on app screen
        apiDomain = await Session.getData(Session.apiDomain);
      }
      String url =
          '${apiDomain}${URLs.GET_STANDARD_DROPDOWN_FIELDS}?Entity=$entity';
      if (searchText != '') {
        url += '&searchtext=$searchText';
      }

      http.Client client = http.Client();
      final response = await client.get(url, headers: {
//        "token": await Session.getData(Session.accessToken)
        "token": tokenValue != null && tokenValue != ''
            ? tokenValue
            : await Session.getData(Session.accessToken),
      }).timeout(duration);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data != 'No fields found') {
          standardDropdownFieldData = data
              .map<StandardDropDownField>(
                  (json) => StandardDropDownField.fromJson(json))
              .toList();
        }
      }
      return standardDropdownFieldData;
    } catch (e) {
      print('Error inside getStandardDropDownField api call function ');
      print(e);
      return standardDropdownFieldData;
    }
  }

  ///IT MAKES THE HTTP REQUEST FOR FETCHING STANDARD_DROPDOWN_FIELDS
  static Future<List<StandardDropDownField>>
      getCurrencyStandardDropdownFields() async {
    var standardDropdownFieldData = List<StandardDropDownField>();

    try {
      String url =
          '${await Session.getData(Session.apiDomain)}${URLs.GET_STANDARD_DROPDOWN_FIELDS}?Entity=${StandardEntity.CURRENCY_DROPDOWN_ENTITY}&searchtext=${DropdownSearchText.CURRENCY_DROPDOWN_SEARCH_TEXT}';

      http.Client client = http.Client();
      final response = await client.get(url, headers: {
        "token": await Session.getData(Session.accessToken),
      }).timeout(duration);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data != 'No fields found') {
          standardDropdownFieldData = data
              .map<StandardDropDownField>(
                  (json) => StandardDropDownField.fromJson(json))
              .toList();
        }
      }
      return standardDropdownFieldData;
    } catch (e) {
      print('Error inside getStandardDropDownField api call function ');
      print(e);
      return standardDropdownFieldData;
    }
  }

  ///IT MAKES THE HTTP REQUEST FOR FETCHING CUSTOM_FIELDS
  static Future<List<CustomField>> getCustomFields({
    @required String entity,
    bool showOnScreen = false,
    bool showOnGrid = false,
    String searchText = '',
    String tokenValue = '',
  }) async {
    var customFieldsData = List<CustomField>();

    try {
      String url =
          '${await Session.getData(Session.apiDomain)}${URLs.GET_CUSTOM_FIELDS}?Entity=$entity';
      if (searchText != '') {
        url += '&searchtext=$searchText';
      }
      if (showOnScreen) {
        url += '&ShowOnScreen=$showOnScreen';
      }
      if (showOnGrid) {
        url += '&ShowOngrid=$showOnGrid';
      }

      http.Client client = http.Client();
      final response = await client.get(url, headers: {
        "token": tokenValue != null && tokenValue != ''
            ? tokenValue
            : await Session.getData(Session.accessToken),
      }).timeout(duration);

      if (response.statusCode == 200 &&
          response.body != 'No Custom fields found') {
        var data = json.decode(response.body);
        customFieldsData = data
            .map<CustomField>((json) => CustomField.fromJson(json))
            .toList();
      }
      return customFieldsData;
    } catch (e) {
      print('Error inside getCustomFields api call function ');
      print(e);
      return customFieldsData;
    }
  }

  ///It makes the http Request for fetching the GetProductLastPrice
  static Future<List<ProductLastPrice>> getProductLastPrice({
    String customerCode,
    String productCode,
  }) async {
    var productLastPriceData = List<ProductLastPrice>();
    try {
      String url =
          '${await Session.getData(Session.apiDomain)}${URLs.GET_PRODUCT_LAST_PRICE}?pageSize=1&pageNumber=1&CustomerCode=$customerCode&ProductCode=$productCode';

      http.Client client = http.Client();
      final response = await client.get(url, headers: {
        "token": await Session.getData(Session.accessToken),
        "Username": await Session.getUserName() //added by Gaurav, 03-08-2020
      }).timeout(duration);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        productLastPriceData = data
            .map<ProductLastPrice>((json) => ProductLastPrice.fromJson(json))
            .toList();
      }
      return productLastPriceData;
    } catch (e) {
      print('Error inside ProductLastPrice api call function ');
      print(e);
      return Future.error(e);
    }
  }

  ///IT CALLS THE API TO GET QUOTE LIST BY THE ID PROVIDED
  static Future<List<Quotes>> fetchQuotesById({
    int serverQuoteId,
  }) async {
    try {
      var quotesData = List<Quotes>();
      String url =
          '${await Session.getData(Session.apiDomain)}/${URLs.GET_QUOTES}?pageNumber=1&pageSize=1&Id=$serverQuoteId';

      http.Client client = http.Client();
      final response = await client.get(url, headers: {
        "token": await Session.getData(Session.accessToken),
        "Username": await Session.getUserName() //added by Gaurav, 03-08-2020
      }).timeout(duration);

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

  ///IT SENDS THE MAIL API TO THE SEND THE PROVIDED SALES_ORDERS OR PRODUCTS PDF OR DATA TO PROVIDED MAIL_ID'S
  static Future<String> sendMail({
    @required String toMailIds,
    @required String template,
    @required String fileType,
    @required String data,
  }) async {
    String errMsg = 'Internal server error, Please try again later';
    try {
      String _url =
          '${await Session.getData(Session.apiDomain)}${URLs.POST_SEND_MAIL}?ToMailIds=$toMailIds&template=$template&Filetype=$fileType&Data=$data';

      http.Client client = http.Client();
      final response = await client.get(_url, headers: {
        'Content-Type': 'application/json',
        "token": await Session.getData(Session.accessToken),
        "Username": await Session.getUserName() //added by Gaurav, 03-08-2020
      }).timeout(duration);

      if (response.statusCode == 200) {
        return Future.value(response.body);
      } else {
        try {
          if (response.body != null) {
            var decodedError = json.decode(response.body);

            errMsg = decodedError.Message;
          }
        } catch (e) {
          print('Error while decoding error response data for send mail');
        }

        return Future.value(errMsg);
//        throw Future.error(
//          ErrorDescription(errMsg),
//        );
      }
    } catch (e) {
      print('Error inside sendMail api call');
      print(e);
      return Future.value(errMsg);
//      throw Future.error(errMsg);
    }
  }

  ///IT CALLS THE GET_CURRENT_TIME API TO GET LAST_SYNC_DATE FROM THE SERVER
  static Future<String> getCurrentDateTime({
    String tokenValue = '',
    String apiDomain = '',
  }) async {
    String _currentDateTime = '';
    try {
//      String uname=await Session.getUserName();
      if (apiDomain == '' || apiDomain == null) {
        //Use on app screen
        apiDomain = await Session.getData(Session.apiDomain);
      }
      String url = '${apiDomain}${URLs.GET_CURRENT_DATE_TIME}';

      http.Client client = http.Client();
      final response = await client.get(url, headers: {
        "token": tokenValue != null && tokenValue != ''
            ? tokenValue
            : await Session.getData(Session.accessToken)
      }).timeout(duration);

      if (response.statusCode == 200) {
        DateTime _utcDate = DateTime.parse(
            '${response.body.substring(1, 20).replaceAll('T', ' ')}');

//        DateTime _utcDate = DateTime.utc(now.year, now.month, now.day, now.hour,
//            now.minute, now.millisecond);
        _currentDateTime =
            '${_utcDate.year}-${getFormatDateString(value: _utcDate.month)}-${getFormatDateString(value: _utcDate.day)} ${getFormatDateString(value: _utcDate.hour)}:${getFormatDateString(value: _utcDate.minute)}:${getFormatDateString(value: _utcDate.second)}';
      } else {
        _currentDateTime = 'ERROR';
      }
      return Future.value(_currentDateTime);
    } catch (e) {
      print('Error catch inside DD getCurrentDateTime API FN');
      print(e);
      return Future.value('ERROR');
    }
  }

  ///IT CALLS THE GET_USERS API TO GET LOGGED_IN USER DETAILS
  static Future<List<User>> getLoggedInUserDetails() async {
    try {
      var _users = List<User>();
      String url =
          '${await Session.getData(Session.apiDomain)}${URLs.GET_USERS}?pageNumber=1&pageSize=1&Searchtext=${await Session.getData(Session.userName)}';

      http.Client client = http.Client();
      final response = await client.get(url, headers: {
        "token": await Session.getData(Session.accessToken),
        "Username": await Session.getUserName() //added by Gaurav, 03-08-2020
      }).timeout(duration);

      if (response.statusCode == 200 && response.body != "No Users found") {
        var data = json.decode(response.body);
        _users = data.map<User>((json) => User.fromJson(json)).toList();
      }
      return _users;
    } catch (e) {
      print('Error inside getLoggedInUserDetails FN');
      print(e);
      throw Future.error(e);
    }
  }

  ///IT GETS THE REAL_TIME_PRICING FOR THE SELECTED PRODUCT
  static Future<dynamic> getPricing({
    @required String erpName,
    @required String requestBody,
  }) async {
    try {
      print("getPricing requestBody");
      print(requestBody);
      var ProductPriceList = List<ProductRealTimePrice>();
      String url =
          '${await Session.getData(Session.apiDomain)}${URLs.GET_PRICING}?ERPName=$erpName';
      final http.Response response = await http.post(
        url,
        body: json.decode(json.encode(requestBody)),
        headers: <String, String>{
          'Content-Type': 'application/json',
          "token": await Session.getData(Session.accessToken),
          "Username": await Session.getUserName() //added by Gaurav, 03-08-2020
        },
      ).timeout(duration);

      // print('response.body ${response.body}');

      print('statusCode ${response.statusCode}');
      print('body +${response.body}');

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data.toString().contains('Error')) {
          return Future.value(data);
        } else {
          ProductPriceList = data
              .map<ProductRealTimePrice>(
                  (json) => ProductRealTimePrice.fromJson(json))
              .toList();
          return Future.value(ProductPriceList);
        }
      }
      return Future.value(ProductPriceList);
    } catch (e) {
      print('Error Inside getPricing FN');
      print(e);
      return Future.error(e);
    }
  }

  ///To stop syn with ERP
  static Future<String> updateQuoteById({
    @required String requestBody,
  }) async {
    try {
      String url =
          '${await Session.getData(Session.apiDomain)}${URLs.UPDATE_QUOTE_BY_ID}';
      ;
      String strResult = '';
      final http.Response response = await http.post(
        url,
        body: json.decode(json.encode(requestBody)),
        headers: <String, String>{
          'Content-Type': 'application/json',
          "token": await Session.getData(Session.accessToken),
          "Username": await Session.getUserName() //added by Gaurav, 03-08-2020
        },
      ).timeout(duration);

      if (response.statusCode == 200 && !response.body.contains('Error')) {
        strResult = json.decode(response.body);
      }
      return Future.value(strResult);
    } catch (e) {
      print('Error Inside getPricing FN');
      print(e);
      return Future.error(e);
    }
  }

  static Future<List<EmailFeature>> getEmailFeature() async {
    try {
      var EmailFeatureList = List<EmailFeature>();
      String url =
          '${await Session.getData(Session.apiDomain)}${URLs.GET_EMAIL_FEATURE}';

      final http.Response response = await http.get(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
          "token": await Session.getData(Session.accessToken),
        },
      ).timeout(duration);

      if (response.statusCode == 200 && !response.body.contains('Error')) {
        var data = json.decode(response.body);
        EmailFeatureList = data
            .map<EmailFeature>((json) => EmailFeature.fromJson(json))
            .toList();
      }
      return Future.value(EmailFeatureList);
    } catch (e) {
      print('Error Inside getEmailFeature FN');
      print(e);
      return Future.error(e);
    }
  }

  static Future<dynamic> getStock({
    @required String erpName,
    @required String requestBody,
  }) async {
    try {
      var InventoryList = List<Inventory>();
      String url =
          '${await Session.getData(Session.apiDomain)}${URLs.GET_STOCK}?ERPName=$erpName';

      final http.Response response = await http.post(
        url,
        body: json.decode(json.encode(requestBody)),
        headers: <String, String>{
          'Content-Type': 'application/json',
          "token": await Session.getData(Session.accessToken),
          "Username": await Session.getUserName() //added by Gaurav, 03-08-2020
        },
      ).timeout(Duration(seconds: 60));

      if (response.statusCode == 200 && response.body != "") {
        var data = json.decode(response.body);
        if (data.toString().contains('Error')) {
          return Future.value(data);
        } else {
          if (data != null && data.toString() != '') {
            InventoryList = data
                .map<Inventory>((json) => Inventory.fromJson(json))
                .toList();
            return Future.value(InventoryList);
          }
        }
      }
    } catch (e) {
      print('Error Inside getStock FN');
      print(e);
      return Future.error(e);
    }
  }

  static Future<List<AppVersion>> getAppInfo() async {
    try {
      var AppList = List<AppVersion>();
      String url =
          '${await Session.getData(Session.apiDomain)}${URLs.GET_APP_VERSION}';

      final http.Response response = await http.get(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
          "token": await Session.getData(Session.accessToken),
        },
      ).timeout(duration);

      if (response.statusCode == 200 && !response.body.contains('Error')) {
        var data = json.decode(response.body);
        AppList =
            data.map<AppVersion>((json) => AppVersion.fromJson(json)).toList();
      }
      return Future.value(AppList);
    } catch (e) {
      print('Error Inside getPricing FN');
      print(e);
      return Future.error(e);
    }
  }

  static Future addReport({
    @required String requestBody,
  }) async {
    try {
      var respons = '';
      String url =
          '${await Session.getData(Session.apiDomain)}${URLs.ADD_REPORT}';

      final http.Response response = await http.post(
        url,
        body: json.decode(json.encode(requestBody)),
        headers: <String, String>{
          'Content-Type': 'application/json',
          "token": await Session.getData(Session.accessToken),
          "Username": await Session.getUserName() //added by Gaurav, 03-08-2020
        },
      ).timeout(duration);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        respons = data
            .toString()
            .replaceAll('{', '')
            .replaceAll('}', '')
            .replaceAll('"', '')
            .replaceAll('[', '')
            .replaceAll(']', '');
      }
      return Future.value(respons);
    } catch (e) {
      print('Error Inside addReport FN');
      print(e);
      return Future.error(e);
    }
  }

  static Future getReportStatus({
    @required String reportName,
  }) async {
    try {
      String url =
          '${await Session.getData(Session.apiDomain)}${URLs.GET_REPORT_STATUS}?ReportName=${reportName.trim()}';

      var returnRes;
      final http.Response response = await http.get(
        url,
        headers: <String, String>{
          "token": await Session.getData(Session.accessToken),
          "Username": await Session.getUserName() //added by Gaurav, 03-08-2020
        },
      ).timeout(duration);

      if (response.statusCode == 200 && !response.body.contains('Error')) {
        returnRes = response.body.toString().replaceAll('"', '');
      }
      return Future.value(returnRes);
    } catch (e) {
      print('Error Inside getReportStatus FN');
      print(e);
      return Future.error(e);
    }
  }

  ///IT CALLS THE GET_INVOICES API CALL FOR GETTING INVOICES DATA
  static Future<List<Invoices>> fetchInvoices({
    @required int pageNumber,
    @required int pageSize,
    String customerNo = '',
    String searchFieldContent,
    String selectedInvoiceStatusKey = '',
  }) async {
    var invoiceData = List<Invoices>();
    try {
      String url =
          '${await Session.getData(Session.apiDomain)}/${URLs.GET_INVOICES}?pageNumber=$pageNumber&pageSize=$pageSize';
      if (customerNo != null && customerNo != '') {
        url = '$url&CustomerNo=$customerNo';
      }
      if (selectedInvoiceStatusKey != '') {
        url = '$url&Status=$selectedInvoiceStatusKey';
      }
      if (searchFieldContent != null && searchFieldContent.trim().length > 0) {
        url = '$url&Searchtext=${searchFieldContent.trim()}';
      }

      http.Client client = http.Client();
      final response = await client.get(url, headers: {
        "token": await Session.getData(Session.accessToken),
        "Username": await Session.getData(
            Session.userName), //added by Gaurav, 03-08-2020
      }).timeout(duration);

      if (response.statusCode == 200 && response.body != 'No Invoices found') {
        var data = json.decode(response.body);
        invoiceData =
            data.map<Invoices>((json) => Invoices.fromJson(json)).toList();
      }
//      return invoiceData;
      return Future.value(invoiceData);
    } catch (e) {
      print('Error while fetching Invoices Data from API');
      print(e);
      return Future.error(e);
    }
  }

  //Added by Mayuresh - S, 20-07-2022
  static Future<String> fetchCustomerMails({
    int pageNumber = 1,
    int pageSize = 1,
    List<String> customerNo = const [],
  }) async {
    print("Inside fetchCustomerMails");
    print(customerNo.toString());
    String emails = '';
    try {
      for (String customer in customerNo) {
        var company = Company();

        String url =
            '${await Session.getData(Session.apiDomain)}/${URLs.GET_COMPANIES}?pageNumber=$pageNumber&pageSize=$pageSize';
        if (customerNo != null && customerNo.isNotEmpty) {
          url = '$url&Searchtext=$customer';
        }
        http.Client client = http.Client();
        final response = await client.get(url, headers: {
          "token": await Session.getData(Session.accessToken),
          "Username": await Session.getData(
              Session.userName), //added by Gaurav, 03-08-2020
        }).timeout(duration);
        if (response.statusCode == 200 && response.body != 'No Company found') {
          var data = json.decode(response.body);
          company = Company.fromJson(data.first);
          if (company.contacts.isNotEmpty) {
            String mail = company.contacts
                .firstWhere((element) => element.IsDefault,
                    orElse: () => company.contacts.first)
                .Email;
            print(mail);
            emails += "$mail,";
          }
        }
      }
      return Future.value(emails);
    } catch (e) {
      print('Error while fetching Customers Data from API');
      print(e);
      return Future.error(e);
    }
  }

  static Future<int> getAutoSaveQuoteInterval() async {
    int interval = 60;
    try {
      print("Inside getAutoSaveQuoteInterval");
      String url =
          '${await Session.getData(Session.apiDomain)}${URLs.GET_QUOTE_FEATURE}';
      http.Client client = http.Client();
      final response = await client.get(url, headers: {
        "token": await Session.getData(Session.accessToken),
        "Username": await Session.getData(Session.userName),
      }).timeout(duration);
      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        interval = int.tryParse(data.first["AutoSaveInterval"].toString());
        return Future.value(interval);
      } else {
        print("Error in getAutoSaveQuoteInterval response");
        print(response.body);
        return Future.value(interval);
      }
    } catch (e) {
      print("Error in getAutoSaveQuoteInterval");
      print(e);
      return Future.value(interval);
    }
  }
  //Added by Mayuresh - E
}

///IT ADDS THE 0 TO THE VALUE IF IT's LESS THAN 10 TO MAINTAIN PROPER DATE VALUES
String getFormatDateString({int value}) {
  String _tempVal = '';
  if (value != null && value.toString().length > 0) {
    _tempVal = value < 10 ? '0' + (value).toString() : value.toString();
  }
  return _tempVal;
}

final kHintTextStyle = TextStyle(
  color: Colors.white54,
  fontFamily: 'OpenSans',
);

final kLabelStyle = TextStyle(
  color: Colors.white,
  fontWeight: FontWeight.bold,
  fontFamily: 'OpenSans',
);
//
//final String userName = "USERNAME";
//final String password = "PASSWORD";
//final String accessToken = "ACCESS_TOKEN";

final kBoxDecorationStyle = BoxDecoration(
  color: Color(0xFF6CA8F1),
  borderRadius: BorderRadius.circular(10.0),
  boxShadow: [
    BoxShadow(
      color: Colors.black12,
      blurRadius: 6.0,
      offset: Offset(0, 2),
    ),
  ],
);
