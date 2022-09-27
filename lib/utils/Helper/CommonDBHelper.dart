import 'package:moblesales/utils/index.dart';

class CommonDBHelper {
  ///IT CLEARS ALL THE LOCAL_DATABASE_TABLE_ROWS
  Future deleteTablesOnLogout() async {
    try {
      AddQuoteDBHelper _addQuoteDBHelper = AddQuoteDBHelper();
      AddQuoteHeaderDBHelper _addQuoteHeaderDBHelper = AddQuoteHeaderDBHelper();
      AddQuoteDetailDBHelper _addQuoteDetailDBHelper = AddQuoteDetailDBHelper();

      var quoteHeadersDeleteRes = await _addQuoteHeaderDBHelper.deleteALLRows();
      print('All quoteHeadersDeleteRes : $quoteHeadersDeleteRes');
      var quoteDetailsDeleteRes = await _addQuoteDetailDBHelper.deleteALLRows();
      print('All quoteDetailsDeleteRes : $quoteDetailsDeleteRes');
      var quoteDeleteRes = await _addQuoteDBHelper.deleteALLRows();
      print('All quoteDeleteRes : $quoteDeleteRes');
      return Future.value('SUCCESS');
    } catch (e) {
      print('Error Inside deleteTablesOnLogout FN ');
      print(e);
      return Future.value('ERROR');
    }
  }

  Future deleteAllTablesData() async {
    try {
      CompanyDBHelper _companyDBHelper = CompanyDBHelper();
      AddressDBHelper _addressDBHelper = AddressDBHelper();
      ProductDBHelper _productDBHelper = ProductDBHelper();
      AddQuoteDBHelper _addQuoteDBHelper = AddQuoteDBHelper();
      SyncMasterDBHelper _syncMasterDBHelper = SyncMasterDBHelper();
      AddQuoteHeaderDBHelper _addQuoteHeaderDBHelper = AddQuoteHeaderDBHelper();
      AddQuoteDetailDBHelper _addQuoteDetailDBHelper = AddQuoteDetailDBHelper();
      StandardFieldsDBHelper _standardFieldsDBHelper = StandardFieldsDBHelper();

      ///CODE COMMENTED TO DELETE ALL THE LOOKUP's SYNCED DATA AS IT IS COMMON FOR ALL THE
      ///LOGIN's
      var companiesDeleteRes = await _companyDBHelper.deleteALLRows();
      print('All companiesDeleteRes : $companiesDeleteRes');
      var adressesDeleteRes = await _addressDBHelper.deleteALLRows();
      print('All adressesDeleteRes : $adressesDeleteRes');
      var productsDeleteRes = await _productDBHelper.deleteALLRows();
      print('All productsDeleteRes : $productsDeleteRes');
      var standardFieldsDeleteRes =
          await _standardFieldsDBHelper.deleteALLRows();
      print('All standardFieldsDeleteRes : $standardFieldsDeleteRes');
      var quoteHeadersDeleteRes = await _addQuoteHeaderDBHelper.deleteALLRows();
      print('All quoteHeadersDeleteRes : $quoteHeadersDeleteRes');
      var quoteDetailsDeleteRes = await _addQuoteDetailDBHelper.deleteALLRows();
      print('All quoteDetailsDeleteRes : $quoteDetailsDeleteRes');
      var quoteDeleteRes = await _addQuoteDBHelper.deleteALLRows();
      print('All quoteDeleteRes : $quoteDeleteRes');
      var syncMasterResetRes = await _syncMasterDBHelper
          .resetAllMastersTableLastSyncDate(lastSyncDate: '');
      print('All syncMasterResetRes : $syncMasterResetRes');
      return Future.value('SUCCESS');
    } catch (e) {
      print('Error Inside deleteAllTablesData FN ');
      print(e);
      return Future.value('ERROR');
    }
  }
}
