import 'package:flutter/material.dart';
import 'package:moblesales/helpers/index.dart';

class AdvancedCustomerSearch extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Customer'),
        automaticallyImplyLeading: false,
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            }),
      ),
      body: Container(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            /* _commonWidgets.getListingCompanySelectorWidget(
                showCompanyDialogHandler: this.showCompanyDialog,
                clearSelectedCompanyHandler: this.clearSelectedCompany,
                selectedCompany: this._selectedCompany,
                defaultCardElevation: 3.0,
                defaultPadding: const EdgeInsets.all(0.0),
              ),
              _commonWidgets.getListingCompanySelectorWidget(
                showCompanyDialogHandler: this.showCompanyDialog,
                clearSelectedCompanyHandler: this.clearSelectedCompany,
                selectedCompany: this._selectedCompany,
                defaultCardElevation: 3.0,
                defaultPadding: const EdgeInsets.all(0.0),
              ),*/
            DropdownButton(),
            Row(
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                    child: RaisedButton(
                      onPressed: () {},
                      color: AppColors.blue,
                      child: Text(
                        'Home',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                    child: RaisedButton(
                      onPressed: () {},
                      color: AppColors.blue,
                      child: Text(
                        'Create Quote',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // _commonWidgets.showCommonLoader(isLoaderVisible: isShowLoader),
            //_buildList(),

            ///PAGINATION LOADER
            // _commonWidgets.showCommonLoader(
            //     isLoaderVisible: isShowLoader),
          ],
        ),
      ),
    );
  }
}

//class AdvancedCustomerSearch extends StatefulWidget {
//  @override
//  _AdvancedCustomerSearch createState() => _AdvancedCustomerSearch();
//}

/*
class _AdvancedCustomerSearch extends State<AdvancedCustomerSearch> {
  CommonWidgets _commonWidgets;
  Company _selectedCompany;
  int pageNumber;
  bool isDataRemaining;
  bool isFullScreenLoading;
  bool isShowLoader;

  @override
  void initState() {
    super.initState();
    _commonWidgets = CommonWidgets();
    pageNumber = 1;
    isDataRemaining = true;
    isFullScreenLoading = true;
    isShowLoader = false;
  }

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

  void closeSearchDialog() {
    print('closeSearchDialog called of the InvoiceSearchDialog Page');
  }

  void handleCustomerSelectedSearch(Company selectedCompany) {
    print('Inside handleCustomerSelectedSearch fn of InvoiceSearchDialog Page');
    setState(() {
      _selectedCompany = selectedCompany;
    });
    loadNewSearchData();
  }

  void clearSelectedCompany() {
    setState(() {
      _selectedCompany = null;
    });
    loadNewSearchData();
  }

  void loadNewSearchData() {
    setState(() {
      pageNumber = 1;
      isDataRemaining = false;
    });
    // dataFetch();
  }
*/
