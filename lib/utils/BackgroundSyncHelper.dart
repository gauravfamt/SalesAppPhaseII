import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:true_time/true_time.dart';
import 'package:moblesales/models/index.dart';
import 'package:moblesales/helpers/index.dart';
import 'package:moblesales/utils/index.dart';

const _methodChannel = MethodChannel('com.example.sqflite/backgrounded');

///PROVIDES COMPANY TABLE CRUD ACTIONS
CompanyDBHelper _companyDBHelper = CompanyDBHelper();

///PROVIDES PRODUCT TABLE CRUD OPERATIONS
ProductDBHelper _productDBHelper = ProductDBHelper();

///PROVIDES SYNC_MASTER TABLE CRUD OPERATIONS
SyncMasterDBHelper _syncMasterDBHelper = SyncMasterDBHelper();

///PROVIDES SALES_SITE TABLE CRUD OPERATIONS
SalesSiteDBHelper _salesSiteDBHelper = SalesSiteDBHelper();

///PROVIDES INVOICING_ELEMENT TABLE CRUD OPERATIONS
InvoicingElementDBHelper _invoicingElementDBHelper = InvoicingElementDBHelper();

///PROVIDES STANDARD_FIELDS TABLE CRUD OPERATIONS
StandardFieldsDBHelper _standardFieldsDBHelper = StandardFieldsDBHelper();

///PROVIDES STANDARD_DROPDOWN_FIELDS TABLE CRUD OPERATIONS
StandardDropDownFieldsDBHelper _standardDropDownFieldsDBHelper =
    StandardDropDownFieldsDBHelper();

///PROVIDES TOKEN_MASTER TABLE CRUD OPERATIONS
TokenDBHelper _tokenDBHelper = TokenDBHelper();

///IT'S THE STANDARD_FIELDS BACKGROUND INSERT UPDATE ENTRY POINT
void sfInsertUpdateBackgroundEntryPoint() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    print('EXECUTING BACKGROUND TASK TO SYNC STANDARD_FIELDS DATA');
    _tokenDBHelper
        .getLocalDBTokens()
        .then((localTokensRes) => {
              if (localTokensRes.length > 0)
                {
                  print(
                      'LocalDB Token Response returned : ${localTokensRes[0].Token}'),
                  handleWmSFLocalDbInsert(
                    tokenValue: localTokensRes[0].Token,
                    apiDomain: localTokensRes[0].ApiDomain,
                    userName: localTokensRes[0].Username,
                  )
                      .then((value) => {
                            print('LocalDB Data insert response received'),
                          })
                      .catchError((e) => {
                            print(
                                'LocalDB StandardFields Data insert ERROR response received'),
                          }),
                }
              else
                {
                  print('As LocalDB Token not Found Not calling the sync'),
                }
            })
        .catchError((e) => {
              print('Error Inside sfInsertUpdateBackgroundEntryPoint'),
              print(e),
              print('As LocalDB Token Not found Not calling sync flow'),
            });
  } catch (e) {
    print('Error inside sfInsertUpdateBackgroundEntryPoint');
    print(e);
  }
}

///IT CALLS METHOD_CHANNEL TO INSERT UPDATE STANDARD FIELDS IN LOCAL_DB
Future<void> backgroundedSFInsertUpdateHandler() {
  final CallbackHandle handle =
      PluginUtilities.getCallbackHandle(sfInsertUpdateBackgroundEntryPoint);
  return _methodChannel.invokeMethod('', [handle.toRawHandle()]);
}

///IT'S THE MASTER LOOKUP'S BACKGROUND INSERT UPDATE ENTRY POINT
void lookupInsertUpdateBackgroundEntryPoint() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    print('EXECUTING BACKGROUND TASK TO SYNC LOOKUPS MASTERS DATA');
    alterTabels();
    _tokenDBHelper
        .getLocalDBTokens()
        .then((localTokensRes) => {
              if (localTokensRes.length > 0)
                {
                  print(
                      'LocalDB Token Response returned : ${localTokensRes[0].Token}'),
                  handleWmLocalDbInsert(
                          tokenValue: localTokensRes[0].Token,
                          userName: localTokensRes[0].Username,
                          apiDomain: localTokensRes[0].ApiDomain)
                      .then((value) => {
                            print(
                                'Lookups LocalDB Data insert Final response received'),
                            handleWmSFLocalDbInsert(
                                    tokenValue: localTokensRes[0].Token,
                                    userName: localTokensRes[0].Username,
                                    apiDomain: localTokensRes[0].ApiDomain)
                                .then(
                              (value) =>
                                  print('Standard fields  Data insert Update '),
                            )
                          })
                      .catchError((e) => {
                            print(
                                'LocalDB lookups Data insert Final ERROR response received'),
                          }),
                }
              else
                {
                  print('As LocalDB Token not Found Not calling the sync'),
                }
            })
        .catchError((e) => {
              print('Error Inside lookupInsertUpdateBackgroundEntryPoint'),
              print(e),
              print('As LocalDB Token Not found Not calling sync flow'),
            });
  } catch (e) {
    print('Error inside lookupInsertUpdateBackgroundEntryPoint');
    print(e);
  }
}

void alterTabels() async {
  try{
    print('Alter Table');
    _companyDBHelper.alterCompanyTable();
    _productDBHelper.alterProductTable();
  }
  catch(e){
    print('Error inside alterTabel');
    print(e);
  }
}

///IT CALLS METHOD_CHANNEL TO INSERT UPDATE LOOKUPS IN LOCAL_DB
Future<void> backgroundedLookupInsertUpdateHandler() {
  final CallbackHandle handle =
      PluginUtilities.getCallbackHandle(lookupInsertUpdateBackgroundEntryPoint);
  return _methodChannel.invokeMethod('', [handle.toRawHandle()]);
}

///IT CALLS BOTH QUOTE HEADER/DETAIL STANDARD FIELDS API DATA INSERT FUNCTIONS
Future handleWmSFLocalDbInsert({
  String tokenValue = '',
  String apiDomain = '',
  String userName = '',
}) async {
  try {
    print('Token Value Inside handleWmSFLocalDbInsert $tokenValue');
    if (tokenValue == null) tokenValue = '';
    var _lookUpData = await handleWmLocalDbInsert(
        tokenValue: tokenValue, userName: userName, apiDomain: apiDomain);
    print('lookUp Data insert Response $_lookUpData');

    ///INSERTING QUOTE_HEADER_STANDARD_FIELDS
    var _quoteHeaderSFForGridInsertRes =
        await handleWMAPIStandardFieldsDataInsert(
      entity: StandardEntity.QUOTE_HEADER,
      showInGrid: true,
      showOnScreen: false,
      tokenValue: tokenValue,
      apiDomain: apiDomain,
    );
    print(
        'QuoteHeaders Data showInGrid  insert Response $_quoteHeaderSFForGridInsertRes');

    var _quoteHeaderSFForScreenInsertRes =
        await handleWMAPIStandardFieldsDataInsert(
      entity: StandardEntity.QUOTE_HEADER,
      showInGrid: false,
      showOnScreen: true,
      tokenValue: tokenValue,
      apiDomain: apiDomain,
    );

    var _quoteHeaderSFForScreenInsertRes1 =
        await handleWMAPIStandardFieldsDataInsert(
      entity: StandardEntity.QUOTE_HEADER,
      showInGrid: false,
      showOnScreen: false,
      tokenValue: tokenValue,
      apiDomain: apiDomain,
    );
    print(
        'QuoteHeaders showOnScreen Data showInGrid  insert Response $_quoteHeaderSFForScreenInsertRes');

    ///INSERTING QUOTE_DETAILS_STANDARD_FIELDS
    var _quoteDetailsSFForGridInsertRes =
        await handleWMAPIStandardFieldsDataInsert(
      entity: StandardEntity.QUOTE_DETAIL,
      tokenValue: tokenValue,
      showOnScreen: false,
      showInGrid: true,
      apiDomain: apiDomain,
    );

    var _quoteDetailsSFForGridInsertRes1 =
        await handleWMAPIStandardFieldsDataInsert(
      entity: StandardEntity.QUOTE_DETAIL,
      tokenValue: tokenValue,
      showOnScreen: false,
      showInGrid: false,
      apiDomain: apiDomain,
    );
    print(
        'QuoteDetails showInGrid Data insert Response $_quoteDetailsSFForGridInsertRes');

    var _quoteDetailsSFForScreenInsertRes =
        await handleWMAPIStandardFieldsDataInsert(
      entity: StandardEntity.QUOTE_DETAIL,
      tokenValue: tokenValue,
      showOnScreen: true,
      showInGrid: false,
      apiDomain: apiDomain,
    );
    var _quoteDetailsSFForScreenInsertRes1 =
        await handleWMAPIStandardFieldsDataInsert(
      entity: StandardEntity.QUOTE_DETAIL,
      tokenValue: tokenValue,
      showOnScreen: false,
      showInGrid: false,
      apiDomain: apiDomain,
    );
    print('QuoteDetails showOnScreen Data insert Response $_quoteDetailsSFForScreenInsertRes');

    ///INSERTING CURRENCY_STANDARD_DROP_DOWN_FIELDS
    var _quoteCurrencyDropdownSFInsertRes =
        await handleWMAPIStandardDropDownFieldsDataInsert(
      entity: StandardEntity.CURRENCY_DROPDOWN_ENTITY,
      searchText: DropdownSearchText.CURRENCY_DROPDOWN_SEARCH_TEXT,
      tokenValue: tokenValue,
      apiDomain: apiDomain,
    );
    print(
        'Currency StandardDropDownFields Data insert Response $_quoteCurrencyDropdownSFInsertRes');

    ///INSERTING ERP_STANDARD_DROP_DOWN_FIELDS
    var _erpDropdownSFInsertRes =
        await handleWMAPIStandardDropDownFieldsDataInsert(
      entity: StandardEntity.ERP_DROPDOWN_ENTITY,
      searchText: '',
      tokenValue: tokenValue,
      apiDomain: apiDomain,
    );
    print('ERP StandardDropDownFields Data insert Response $_erpDropdownSFInsertRes');

    ///INSERTING TAX_STANDARD_DROP_DOWN_FIELDS
    var _taxDropdownSFInsertRes =
        await handleWMAPIStandardDropDownFieldsDataInsert(
      entity: StandardEntity.TAX_DROPDOWN_ENTITY,
      searchText: '',
      tokenValue: tokenValue,
      apiDomain: apiDomain,
    );
    print('TAX StandardDropDownFields Data insert Response $_taxDropdownSFInsertRes');

    ///INSERTING QUOTE_DROPDOWN_ENTITY
    var _quoteDropdownSFInsertRes =
        await handleWMAPIStandardDropDownFieldsDataInsert(
      entity: StandardEntity.QUOTE_DROPDOWN_ENTITY,
      searchText: '',
      tokenValue: tokenValue,
      apiDomain: apiDomain,
    );

    print(
        'Quote Status StandardDropDownFields Data insert Response $_quoteDropdownSFInsertRes');
    return Future.value(true);
  } catch (e) {
    print('Error inside handleWmSFLocalDbInsert function ');
    print(e);
    return Future.value(false);
  }
}
///THIS FUNCTION HANDLES THE STANDARD_FIELDS DATA INSERT FROM API TO THE LOCAL_DB
Future handleWMAPIStandardFieldsDataInsert(
    {String entity,
    String tokenValue = '',
    String apiDomain = '',
    bool showOnScreen,
    bool showInGrid}) async {
  print('Inside handleWMAPIStandardFieldsDataInsert Fn --==== :');
  try {
    List<StandardField> standardFieldRes = await ApiService.getStandardFields(
      entity: entity,
      showOnScreen: showOnScreen,
      showInGrid: showInGrid,
      tokenValue: tokenValue,
      apiDomain: apiDomain,
    );
    if (standardFieldRes.length > 0) {
      print('StandardFields Response records: ${standardFieldRes.length} for $entity Entity');

      Database _db = await DBProvider.db.database;
      if (_db != null) {
        //var deleteRes= await _standardFieldsDBHelper.removeStandardFieldEntitiwise(entity);
       // print('old standard field id deleted for $entity entity into localDB');
        print('Proceeding to insert StandardFields data  for $entity entity into localDB');
        var addSFRes = await _standardFieldsDBHelper.addStandardFields(standardFieldRes);
        print(
            '$entity entity StandardFields data Insert into Local Database is successful!');
        return Future.value(true);
      } else {
        print('Database Object not found for Standard Fields local insertion ');
        return Future.value(true);
      }
    } else {
      print('StandardFields Data not found ');
      return Future.value(false);
    }
  } catch (e) {
    print('Error inside handleWMAPIProductDataInsert function ');
    print(e);
    return Future.value(false);
  }
}

///THIS FUNCTION HANDLES THE STANDARD_FIELDS DATA INSERT FROM API TO THE LOCAL_DB
Future handleWMAPIStandardDropDownFieldsDataInsert({
  @required String entity,
  @required String searchText,
  String tokenValue = '',
  String apiDomain = '',
}) async {
  print('Inside handleWMAPIStandardDropDownFieldsDataInsert Fn :');
  try {
    List<StandardDropDownField> standardDropDownFieldRes =
        await ApiService.getStandardDropdownFields(
            entity: entity,
            searchText: searchText,
            tokenValue: tokenValue,
            apiDomain: apiDomain);
    if (standardDropDownFieldRes.length > 0) {
      print(
          'StandardDropDownFields Response records: ${standardDropDownFieldRes.length} for $entity Entity');
      Database _db = await DBProvider.db.database;
      if (_db != null) {
        print(
            'Proceeding to insert StandardDropDownFields data  for $entity entity into localDB');
        var addSFRes = await _standardDropDownFieldsDBHelper
            .addStandardDropDownFields(standardDropDownFieldRes);
        print(
            '$entity entity StandardDropDownFields data Insert into Local Database is successful!');
        return Future.value(true);
      } else {
        print(
            'Database Object not found for Standard DropDown Fields local insertion ');
        return Future.value(true);
      }
    } else {
      print('StandardDropDownFields Data not found ');
      return Future.value(false);
    }
  } catch (e) {
    print('Error inside handleWMAPIStandardDropDownFieldsDataInsert function ');
    print(e);
    return Future.value(false);
  }
}

///IT CALLS BOTH COMPANY AND PRODUCT DATA INSERT FUNCTIONS
Future handleWmLocalDbInsert({
  String tokenValue = '',
  String userName = '',
  String apiDomain = '',
}) async {
  try {
    ///FETCHING ALL THE MASTERS RECORDS TO SEND LAST_SYNC_DATES TO FETCH API RESPONSES
    List<SyncMaster> _syncMasters =
        await _syncMasterDBHelper.getAllSyncMasters();
    print("created _syncMasters");

    ///GETTING PRODUCT TABLE SYNC_MASTER ENTRY
    SyncMaster _productSyncMaster = _syncMasters.firstWhere(
        (element) => element.TableName == _productDBHelper.tableName);
    print("created _productSyncMaster");

    ///GETTING COMPANY TABLE SYNC_MASTER ENTRY
    SyncMaster _companySyncMaster = _syncMasters.firstWhere(
        (element) => element.TableName == _companyDBHelper.tableName);

    print("created _companySyncMaster");

    ///GETTING INVOICING ELEMENTS TABLE SYNC_MASTER ENTRY
    SyncMaster _invoicingElementsSyncMaster = _syncMasters.firstWhere(
        (element) => element.TableName == _invoicingElementDBHelper.tableName);
    print("created _invoicingElementsSyncMaster");

    ///GETTING COMPANY TABLE SYNC_MASTER ENTRY
//    SyncMaster _salesSiteSyncMaster = _syncMasters.firstWhere(
//        (element) => element.TableName == _salesSiteDBHelper.tableName);

    ///PRODUCTS TABLE CRUD
    print(
        'Calling handleWMAPIProductDataInsert Fn To Insert Products data insertion to the local Db');
    var _productsInsertRes = await handleWMAPIProductDataInsert(
      productSyncMaster: _productSyncMaster,
      tokenValue: tokenValue,
      apiDomain: apiDomain,
    );

    ///COMPANY TABLE CRUD
    print('Products Data Inserted, Now inserting Companies Data ');
    print(_productsInsertRes);
    var _companiesInsertRes = await handleWMAPICompanyDataInsert(
      companySyncMaster: _companySyncMaster,
      tokenValue: tokenValue,
      Username: userName,
      apiDomain: apiDomain,
    );
    print(
        'Companies Data Inserted response received, returning final response');
    print(_companiesInsertRes);

    ///INVOICING ELEMENTS TABLE CRUD
    var _invoicingElementsInsertRes =
        await handleWMAPIInvoicingElementsDataInsert(
      invoicingElementSyncMaster: _invoicingElementsSyncMaster,
      tokenValue: tokenValue,
      apiDomain: apiDomain,
    );
    print(
        'Invoicing Elements Data Inserted response received, returning final response');
    print(_invoicingElementsInsertRes);

    ///SALES_SITE TABLE CRUD
//    var _salesSiteInsertRes = await handleWMAPISalesSiteDataInsert(
//      salesSiteSyncMaster: _salesSiteSyncMaster,
//      tokenValue: tokenValue,
//    );
//    print(
//        'SalesSite Data Inserted response received, returning final response');
//    print(_salesSiteInsertRes);

    return Future.value(true);
  } catch (e) {
    print('Error inside handleWmLocalDbInsert function ');
    print(e);
    return Future.value(false);
  }
}

///IT RETURNS THE API STANDARD FORMATTED UTC_LAST_SYNC_DATE
Future<String> getLastSyncDateForSave() async {
  try {
    bool _trueTimeInitialized =
        await TrueTime.init(ntpServer: 'time.google.com');
    print('_trueTimeInitialized: $_trueTimeInitialized');
    String _lastSyncDateUTC = '';
    if (_trueTimeInitialized) {
      print(
          'TrueTime.now Initialized preparing UTC Date for lastSyncDate value');
      DateTime now = await TrueTime.now();
      DateTime _utcDate = DateTime.utc(
          now.year, now.month, now.day, now.hour, now.minute, now.millisecond);
      _lastSyncDateUTC =
          '${_utcDate.year}-${getFormatDateString(value: _utcDate.month)}-${getFormatDateString(value: _utcDate.day)} ${getFormatDateString(value: _utcDate.hour)}:${getFormatDateString(value: _utcDate.minute)}:${getFormatDateString(value: _utcDate.second)}';
      print('LastSyncDate API Standard UTC FORMAT :$_lastSyncDateUTC');
      return Future.value('$_lastSyncDateUTC');
    } else {
      print('True Time not initialized!');
      print('So Getting date from normal normal dateTime functions');
      DateTime now = DateTime.now();
      DateTime _utcDate = DateTime.utc(
          now.year, now.month, now.day, now.hour, now.minute, now.millisecond);
      _lastSyncDateUTC =
          '${_utcDate.year}-${getFormatDateString(value: _utcDate.month)}-${getFormatDateString(value: _utcDate.day)} ${getFormatDateString(value: _utcDate.hour)}:${getFormatDateString(value: _utcDate.minute)}:${getFormatDateString(value: _utcDate.second)}';
      print(
          'LastSyncDate API Standard UTC FORMAT FROM NORMAL DATETIME :$_lastSyncDateUTC');
      return Future.value('$_lastSyncDateUTC');
//      return Future.value(BackgroundServiceHelper.LAST_SYNC_DATE_ERROR_CODE);
    }
  } catch (e) {
    print('Error Inside getLastSyncDateForSave Fn ');
    print(e);
    return Future.value(BackgroundServiceHelper.LAST_SYNC_DATE_ERROR_CODE);
  }
}

///IT ADDS THE 0 TO THE VALUE IF IT's LESS THAN 10 TO MAINTAIN PROPER DATE VALUES
String getFormatDateString({int value}) {
  String _tempVal = '';
  if (value != null && value.toString().length > 0) {
    _tempVal = value < 10 ? '0' + (value).toString() : value.toString();
  }
  return _tempVal;
}

///THIS FUNCTION HANDLES THE PRODUCTS DATA INSERT FROM API TO THE LOCAL_DB
Future handleWMAPIProductDataInsert(
    {SyncMaster productSyncMaster,
    String tokenValue = '',
    String apiDomain = ''}) async {
  print('Inside Global handleWMAPIProductDataInsert Fn :');
  try {
    String _lastSyncDateUTCForSave = await ApiService.getCurrentDateTime(
        tokenValue: tokenValue, apiDomain: apiDomain);
    print(
        '_lastSyncDateUTC For Local Product Master Table: $_lastSyncDateUTCForSave');
    if (_lastSyncDateUTCForSave != 'ERROR') {
      List<Product> apiProductsRes = await _productDBHelper.fetchProducts(
        lastSyncDate: productSyncMaster.LastSyncDate,
        tokenValue: tokenValue,
        apiDomain: apiDomain,
      );
      print('Products API response received ');

      if (apiProductsRes.length > 0) {
        print('Products Response records: ${apiProductsRes.length}');
        Database _db = await DBProvider.db.database;
        if (_db != null) {
          print('Proceeding to insert Product data into localDB');
          var addProductsRes =
              await _productDBHelper.addProducts(apiProductsRes);
          print('Products Insert into Local Database is successful!');

          var lastSyncDateUpdateRes =
              await _syncMasterDBHelper.updateMasterTableLastSyncDateByName(
            lastSyncDate: _lastSyncDateUTCForSave,
            masterTableName: _productDBHelper.tableName,
          );
          print('Product Table LastSyncDate Updated Response ');
          print(lastSyncDateUpdateRes);
          return Future.value(true);
        } else {
          print('Database Object not found for local insertion ');
          return Future.value(true);
        }
      } else {
        print('Products Data not found ');
        var lastSyncDateUpdateRes =
            await _syncMasterDBHelper.updateMasterTableLastSyncDateByName(
          lastSyncDate: _lastSyncDateUTCForSave,
          masterTableName: _productDBHelper.tableName,
        );
        print(
            'Product Table LastSyncDate Updated after api success Response but no updated data found');
        print(lastSyncDateUpdateRes);
        return Future.value(true);
      }
    } else {
      print(
          'Product Last_Sync_Date not availabe to update locally so cancelling the Products sync');
      return Future.value(true);
    }
  } catch (e) {
    print('Error inside handleWMAPIProductDataInsert function ');
    print(e);
    return Future.value(false);
  }
}

///THIS FUNCTION HANDLES THE COMPANIES DATA INSERT FROM API TO THE LOCAL_DB
Future handleWMAPICompanyDataInsert({
  SyncMaster companySyncMaster,
  String tokenValue = '',
  String apiDomain = '',
  String Username = '',
}) async {
  print('Inside Global handleWMAPICompanyDataInsert Fn :');
  try {
    String _lastSyncDateUTCForSave = await ApiService.getCurrentDateTime(
      tokenValue: tokenValue,
      apiDomain: apiDomain,
    );
    print(
        '_lastSyncDateUTC For Local Company Master Table: $_lastSyncDateUTCForSave');
    if (_lastSyncDateUTCForSave != 'ERROR') {
      List<Company> apiCompaniesRes = await _companyDBHelper.fetchCompanies(
        lastSyncDate: companySyncMaster.LastSyncDate,
        tokenValue: tokenValue,
        apiDomain: apiDomain,
        Username: Username,
      );
      print('Companies API response received ');

      if (apiCompaniesRes.length > 0) {
        print('Companies Response records: ${apiCompaniesRes.length}');
        Database _db = await DBProvider.db.database;
        if (_db != null) {
          print('Proceeding to insert Company data into localDB');
          var addCompaniesRes =
              await _companyDBHelper.addCompanies(apiCompaniesRes);
          print('Companies Insert into Local Database is successful!');
          var lastSyncDateUpdateRes =
              await _syncMasterDBHelper.updateMasterTableLastSyncDateByName(
            lastSyncDate: _lastSyncDateUTCForSave,
            masterTableName: _companyDBHelper.tableName,
          );
          print('Company Table LastSyncDate Updated Response ');
          print(lastSyncDateUpdateRes);
          return Future.value(true);
        } else {
          print('Database Object not found for local insertion ');
          return Future.value(true);
        }
      } else {
        print('Companies Data not found from api');
        var lastSyncDateUpdateRes =
            await _syncMasterDBHelper.updateMasterTableLastSyncDateByName(
          lastSyncDate: _lastSyncDateUTCForSave,
          masterTableName: _companyDBHelper.tableName,
        );
        print(
            'Company Table LastSyncDate Updated after api success Response but no updated data found ');
        print(lastSyncDateUpdateRes);
        return Future.value(true);
      }
    } else {
      print(
          'Company Last_Sync_Date not available to update locally so cancelling the Companies sync');
      return Future.value(false);
    }
  } catch (e) {
    print('Error inside handleWMAPICompanyDataInsert function ');
    print(e);
    return Future.value(false);
  }
}

///THIS FUNCTION HANDLES THE SALES_SITE DATA INSERT FROM API TO THE LOCAL_DB
//Future handleWMAPISalesSiteDataInsert({
//  SyncMaster salesSiteSyncMaster,
//  String tokenValue = '',
//}) async {
//  print('Inside Global handleWMAPISalesSiteDataInsert Fn :');
//  try {
//    String _lastSyncDateUTCForSave = await ApiService.getCurrentDateTime(
//      tokenValue: tokenValue,
//    );
//    print(
//        '_lastSyncDateUTC For Local SalesSite Master Table: $_lastSyncDateUTCForSave');
//    if (_lastSyncDateUTCForSave != 'ERROR') {
//      List<SalesSite> apiSalesSitesRes =
//          await _salesSiteDBHelper.fetchSalesSites(
//        lastSyncDate: salesSiteSyncMaster.LastSyncDate,
//        tokenValue: tokenValue,
//      );
//      print('SalesSite API response received ');
//
//      if (apiSalesSitesRes.length > 0) {
//        print('SalesSite Response records: ${apiSalesSitesRes.length}');
//        Database _db = await DBProvider.db.database;
//        if (_db != null) {
//          print('Proceeding to insert SalesSite data into localDB');
//          var addSalesSiteRes =
//              await _salesSiteDBHelper.addSalesSites(apiSalesSitesRes);
//          print('SalesSite Insert into Local Database is successful!');
//          var lastSyncDateUpdateRes =
//              await _syncMasterDBHelper.updateMasterTableLastSyncDateByName(
//            lastSyncDate: _lastSyncDateUTCForSave,
//            masterTableName: _salesSiteDBHelper.tableName,
//          );
//          print('SalesSite Table LastSyncDate Updated Response ');
//          print(lastSyncDateUpdateRes);
//          return Future.value(true);
//        } else {
//          print('Database Object not found for local insertion of SalesSite');
//          return Future.value(true);
//        }
//      } else {
//        print('SalesSite Data not found from api');
//        var lastSyncDateUpdateRes =
//            await _syncMasterDBHelper.updateMasterTableLastSyncDateByName(
//          lastSyncDate: _lastSyncDateUTCForSave,
//          masterTableName: _salesSiteDBHelper.tableName,
//        );
//        print(
//            'SalesSite Table LastSyncDate Updated Response if api response is success but no updated data found ');
//        print(lastSyncDateUpdateRes);
//        return Future.value(true);
//      }
//    } else {
//      print(
//          'SalesSite Last_Sync_Date not available to update locally so cancelling the SalesSite sync');
//      return Future.value(false);
//    }
//  } catch (e) {
//    print('Error inside handleWMAPISalesSiteDataInsert function ');
//    print(e);
//    return Future.value(false);
//  }
//}

///THIS FUNCTION HANDLES THE COMPANIES DATA INSERT FROM API TO THE LOCAL_DB
Future handleWMAPIInvoicingElementsDataInsert({
  SyncMaster invoicingElementSyncMaster,
  String tokenValue = '',
  String apiDomain = '',
}) async {
  print('Inside Global handleWMAPIInvoicingElementsDataInsert Fn :');
  try {
    String _lastSyncDateUTCForSave = await ApiService.getCurrentDateTime(
      tokenValue: tokenValue,
      apiDomain: apiDomain,
    );
    print(
        '_lastSyncDateUTC For Local Invoicing Element Master Table: $_lastSyncDateUTCForSave');
    if (_lastSyncDateUTCForSave != 'ERROR') {
      List<InvoicingElement> apiElementsRes =
          await _invoicingElementDBHelper.fetchInvoicingElements(
        lastSyncDate: invoicingElementSyncMaster.LastSyncDate,
        tokenValue: tokenValue,
        apiDomain: apiDomain,
      );
      print('Companies API response received ');

      if (apiElementsRes.length > 0) {
        print('Invoicing Elements Response records: ${apiElementsRes.length}');
        Database _db = await DBProvider.db.database;
        if (_db != null) {
          print('Proceeding to insert Company data into localDB');
          var addElementsRes = await _invoicingElementDBHelper
              .addInvoicingElements(apiElementsRes);
          print('Invoicing Elements Insert into Local Database is successful!');
          var lastSyncDateUpdateRes =
              await _syncMasterDBHelper.updateMasterTableLastSyncDateByName(
            lastSyncDate: _lastSyncDateUTCForSave,
            masterTableName: _invoicingElementDBHelper.tableName,
          );
          print('Invoicing Elements Table LastSyncDate Updated Response ');
          print(lastSyncDateUpdateRes);
          return Future.value(true);
        } else {
          print('Database Object not found for local insertion ');
          return Future.value(true);
        }
      } else {
        print('Invoicing Elements Data not found from api');
        var lastSyncDateUpdateRes =
            await _syncMasterDBHelper.updateMasterTableLastSyncDateByName(
          lastSyncDate: _lastSyncDateUTCForSave,
          masterTableName: _invoicingElementDBHelper.tableName,
        );
        print(
            'Invoicing Elements Table LastSyncDate Updated after api success Response but no updated data found ');
        print(lastSyncDateUpdateRes);
        return Future.value(true);
      }
    } else {
      print(
          'Invoicing Elements Last_Sync_Date not available to update locally so cancelling the Invoicing Elements sync');
      return Future.value(false);
    }
  } catch (e) {
    print('Error inside handleWMAPIInvoicingElementsDataInsert function ');
    print(e);
    return Future.value(false);
  }
}
