import 'dart:async';
import 'package:moblesales/helpers/index.dart';
import 'package:moblesales/utils/index.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:path/path.dart';

class DBProvider {
  DBProvider._();
  static final DBProvider db = DBProvider._();
  static Database _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database;
    } else {
      print('Need to Initialize Database ');
    }
    _database = await initDB();
    return _database;
  }

  ///INITIALIZING DATABASE IF DATABASE IS NOT SETUP FOR THE FIRST TIME
  ///AND IF THE DATABASE IS NOT PRESENT IN THE LOCALLY THEN IT CREATES THE LOCAL_DATABASE WITH
  ///TABLES PROVIDED FOR CREATE
  initDB() async {
    return await openDatabase(
      join(
        await getDatabasesPath(),
        '${LocalDatabase.DATABASE_NAME}',
      ),
      onCreate: (db, version) async {
        print('Inside ON_CREATE Database!');

        ///CREATING TOKEN_HELPER TABLE TO STORE TOKEN AFTER USER LOGGED IN
        await db.execute(TokenDBHelper().getTableCreateQuery());
        print('TokenMaster Table created');

        ///CREATING ADDRESS_TABLE TABLE TO STORE TOKEN AFTER USER LOGGED IN
        await db.execute(AddressDBHelper().getTableCreateQuery());
        print('Address Table created');

        ///CREATING THE COMPANY_TABLE
        await db.execute(CompanyDBHelper().getTableCreateQuery());
        print('Company Table created');

//        var sqltQuery = " PRAGMA table_info(Company) ";
//        print('Company ${sqltQuery}');
//        var ress = await db.rawQuery(sqltQuery);
//        print('ress ${ress}');
//        if(!ress.toString().contains('DefaultShippAdd')){
//          sqltQuery="alter table Company add column DefaultShippAdd TEXT ";
//          await db.execute(sqltQuery);
//          print('Company Table altered');
//        }

        ///CREATING THE PRODUCT_TABLE
        await db.execute(ProductDBHelper().getTableCreateQuery());
        print('Product Table created');

        ///CREATING THE SALES_SITE_TABLE
        await db.execute(SalesSiteDBHelper().getTableCreateQuery());
        print('SalesSite Table created');

        ///CREATING THE STANDARD_FIELDS_TABLE
        await db.execute(StandardFieldsDBHelper().getTableCreateQuery());
        print('StandardField Table created');



        ///CREATING THE STANDARD_DROPDOWN_FIELDS_TABLE
        await db .execute(StandardDropDownFieldsDBHelper().getTableCreateQuery());
        print('StandardDropDownFields Table created');

        ///CREATING THE ADD_QUOTE_TABLE
        await db.execute(AddQuoteDBHelper().getTableCreateQuery());
        print('ADD_QUOTE Table created');

        ///CREATING THE QUOTE_DETAIL_TABLE
        await db.execute(AddQuoteDetailDBHelper().getTableCreateQuery());
        print('QuoteDetail Table created');

        ///CREATING THE QUOTE_HEADER_TABLE
        await db.execute(AddQuoteHeaderDBHelper().getTableCreateQuery());
        print('QuoteHeader Table created');

        ///CREATING THE INVOICING_ELEMENT_TABLE
        await db.execute(InvoicingElementDBHelper().getTableCreateQuery());
        print('Invoice Element Table created');

        ///CREATING THE SALES INVOICING_ELEMENT_TABLE
        await db.execute(SalesInvoicingElementDBHelper().getTableCreateQuery());
        print('Sales Invoice Element Table created');

        SyncMasterDBHelper _syncMasterDBHelper = SyncMasterDBHelper();

        ///CREATING THE SYNC_MASTER_TABLE
        await db.execute(_syncMasterDBHelper.getTableCreateQuery());
        print('SyncMaster Table created');

        ///GETTING SYNC_MASTER TABLE DEFAULT ENTRIES
        String _syncMasterDefaultsInsertQuery =
            _syncMasterDBHelper.getSyncMasterEntriesInsertQuery();
        if (_syncMasterDefaultsInsertQuery != null &&
            _syncMasterDefaultsInsertQuery.length > 0) {
          print('Inserting SyncMaster Default Entries');
          await db.execute(_syncMasterDefaultsInsertQuery);
          print('SyncMaster Table Default entries created');
        }
      },
      // onUpgrade: (db, oldVersion, newVersion) {
      // },
      version: 1,
    );
  }
}
