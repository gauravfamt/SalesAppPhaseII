import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:moblesales/helpers/index.dart';
import 'package:moblesales/models/index.dart';
import 'dart:convert';
import 'dart:async';

import 'package:moblesales/screens/index.dart';

class InvoiceSearchDialog extends StatefulWidget {
  final bool forLookupType;

  ///IT HANDLES THE PRODUCT SELECTED EVENT AND RETURNS THE SELECTED PRODUCT TO THE PARENT WIDGET
  final Function(String selectedDocumentNos) setSelectedDocumentNoForMail;

  InvoiceSearchDialog({
    @required this.setSelectedDocumentNoForMail,
    this.forLookupType = false,
  });

  @override
  _InvoiceSearchDialogState createState() => _InvoiceSearchDialogState();
}

class _InvoiceSearchDialogState extends State<InvoiceSearchDialog> {
  ///HOLDS THE CLASS OBJECT WHICH CONTAINS THE REUSABLE WIDGETS
  CommonWidgets _commonWidgets;

  ///TO HIDE?SHOW THE LOADER TILL COMPANY LIST GETS LOADED
  bool isShowLoader;

  ///IT HOLDS ALL THE INVOICES LIST
  List<Invoices> invoices;

  ///USED FOR PAGINATION PURPOSE TO CHECK THE DATA IS REMAINING FOR THE GET
  bool isDataRemaining;

  ///TO SHOW THE LOADER WHILE PAGINATION DATA IF BEING FETCHED
  bool isShowPaginationLoader;

  ///API PARAMETERS FOR THE PAGINATION PURPOSE
  int pageNumber;
  int pageSize;

  ///HANDLES THE SEARCH_TEXT_FIELD STATE FOR THE ADVANCED SEARCH
  String searchFieldContent;

  ///IT HOLDS THE SELECTED COMPANY/CUSTOMER FOR THE ADVANCED SEARCH
  Company _selectedCompany;

  TextEditingController _searchTFController;

  ///HOLDS MULTIPLE DOCUMENT_NO's FOR SENDING MAIL
  String invoiceDocumentNos;

  bool isLargeScreen;

  @override
  void initState() {
    super.initState();
    invoiceDocumentNos = '';
    _commonWidgets = CommonWidgets();
    isShowLoader = true;
    isShowPaginationLoader = false;
    isDataRemaining = true;
    pageNumber = 1;

    pageSize = Pagination.LOOKUP_PAGE_SIZE;
    invoices = List<Invoices>();
    searchFieldContent = '';
    _searchTFController = TextEditingController();
    _selectedCompany = Company();
    isLargeScreen = false;
    dataFetch();
  }

  @override
  void dispose() {
    super.dispose();
  }

  ///It fetches the initial data for the invoices state
  void dataFetch() {
    pageSize = isLargeScreen
        ? Pagination.TABLE_PAGE_SIZE
        : Pagination.LOOKUP_PAGE_SIZE;
    print('pageSize $pageSize');
    print('isLargeScreen $isLargeScreen');
    if (isDataRemaining) {
      ApiService.fetchInvoices(
        pageNumber: pageNumber,
        pageSize: pageSize,
        customerNo:
            _selectedCompany != null && _selectedCompany.CustomerNo != null
                ? _selectedCompany.CustomerNo
                : '',
        searchFieldContent: searchFieldContent,
        selectedInvoiceStatusKey: '',
      )
          .then((invoicesDataRes) => {
                print('got fetchInvoices response in InvoiceSearchDialog'),
                if (mounted)
                  setState(() {
                    pageNumber = pageNumber + 1; //<--To get next record set
                    int newRecordCount = invoicesDataRes.length;
                    invoices.addAll(invoicesDataRes);
                    isShowLoader = false;
                    isShowPaginationLoader = false;
                    if (newRecordCount < pageSize) {
                      isDataRemaining = false;
                    }
                  })
              })
          .catchError((e) => {
                if (mounted)
                  {
                    setState(() {
                      isShowLoader = false;
                      isShowPaginationLoader = false;
                    }),
                    _commonWidgets.showFlutterToast(toastMsg: 'No more data'),
                  }
              });
    } else {
      if (mounted) {
        setState(() {
          isShowLoader = false;
          isShowPaginationLoader = false;
        });
        _commonWidgets.showFlutterToast(toastMsg: 'No more data');
      }
    }
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
      invoiceDocumentNos = '';
      invoices.clear();
      pageNumber = 1;
      isDataRemaining = true;
      isShowLoader = true;
    });
    dataFetch();
  }

  ///BUILDS THE ROW OF THE KEY VALUE PAIR
  Widget buildSingleRow({
    @required keyText,
    @required keyValue,
  }) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            '$keyText',
            style: TextStyle(
              color: AppColors.grey,
            ),
          ),
        ),
        Expanded(
          child: Text(
            '$keyValue',
            style: TextStyle(
              color: AppColors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  ///IT BUILDS THE PRODUCTS_LIST FOR THE SELECTION
  Widget _buildList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: ScrollPhysics(),
      itemCount: invoices.length,
      itemBuilder: (context, position) {
        return Card(
          color: invoices[position].IsSelected
              ? Colors.grey.shade200 //IF CHECKBOX IS SELECTED
              : Colors.white, //IF CHECKBOX NOT SELECTED,
          child: ListTile(
            onTap: () {
              String _tempDocumentNoIds = invoiceDocumentNos;
              if (!invoices[position].IsSelected == true) {
                ///ADDING SELECTED INVOICES TO THE LIST
                _tempDocumentNoIds += '${invoices[position].DocumentNo}|';
              } else {
                ///REMOVING DESELECTED INVOICES FROM THE LIST
                _tempDocumentNoIds = _tempDocumentNoIds.replaceAll(
                    '${invoices[position].DocumentNo}|', '');
              }
              setState(() {
                invoices[position].IsSelected = !invoices[position].IsSelected;
                invoiceDocumentNos = _tempDocumentNoIds;
              });
            },
//            leading: Padding(
//              padding: const EdgeInsets.all(0.0),
//              child: Checkbox(
//                value: invoices[position].IsSelected,
//                onChanged: null,
//              ),
//            ),
            subtitle: Row(
              children: <Widget>[
                SizedBox(
                  width: 20.0,
                  child: Checkbox(
                    value: invoices[position].IsSelected,
                    onChanged: null,
                  ),
                ),
                SizedBox(
                  width: 10.0,
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      buildSingleRow(
                        keyText: 'Invoice No',
                        keyValue: '${invoices[position].DocumentNo}',
                      ),
                      SizedBox(
                        height: 3,
                      ),
                      buildSingleRow(
                        keyText: 'Customer No',
                        keyValue: '${invoices[position].CustomerNo}',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
      ),
    );
  }

  ///It closes the CompanySearch Dialog On CLose Btn click
  void closeSearchDialog() {
    print('closeSearchDialog called of the InvoiceSearchDialog Page');
  }

  ///It handles the Selected Company Response for the search
  void handleCustomerSelectedSearch(Company selectedCompany) {
    print('Inside handleCustomerSelectedSearch fn of InvoiceSearchDialog Page');
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

  @override
  Widget build(BuildContext context) {
    isLargeScreen = isLargeScreenAvailable(context);
    return AlertDialog(
      actionsPadding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
      insetPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      title: Center(
        child: Text('Invoices'),
      ),
      actions: <Widget>[
        RaisedButton(
          color: AppColors.blue,
          onPressed: () {
            String finalInvoiceDocumentNos = invoiceDocumentNos;
            if (invoiceDocumentNos.length > 0) {
              finalInvoiceDocumentNos = finalInvoiceDocumentNos.substring(
                  0, finalInvoiceDocumentNos.lastIndexOf('|'));
              widget.setSelectedDocumentNoForMail(finalInvoiceDocumentNos);
              Navigator.of(context, rootNavigator: true).pop('PopupClosed');
            } else {
              _commonWidgets.showAlertMsg(
                  alertMsg: 'Select at least single invoice for sending mail',
                  context: context,
                  MessageType: AlertMessageType.INFO);
            }
          },
          child: Text(
            'Add',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.0,
            ),
          ),
        ),
        RaisedButton(
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop('PopupClosed');
          },
          child: Text(
            'Close',
            style: TextStyle(color: AppColors.grey, fontSize: 16.0),
          ),
        ),
      ],
      content: Container(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ///CUSTOMER SELECTOR WIDGET
            _commonWidgets.getListingCompanySelectorWidget(
              showCompanyDialogHandler: this.showCompanyDialog,
              clearSelectedCompanyHandler: this.clearSelectedCompany,
              selectedCompany: this._selectedCompany,
              defaultCardElevation: 3.0,
              defaultPadding: const EdgeInsets.all(0.0),
            ),

            ///SEARCH_TEXT_FIELD ALONG WITH BARCODE_SCANNER BUTTON FOR PRODUCT SEARCH
            Row(
              children: <Widget>[
                Expanded(
                  flex: 4,
                  child: SearchTextField(
                    searchFieldContent: searchFieldContent,
                    clearTextFieldSearch: clearTextFieldSearch,
                    handleTextFieldSearch: handleTextFieldSearch,
                    forLookupType: widget.forLookupType,
                    searchTFController: _searchTFController,
                    isShowSearchCard: true,
                    showBarcodeScanner: false,
                    placeHolder: 'Search Invoice',
                  ),
                ),
              ],
            ),

            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification scrollInfo) {
                  if (!isShowPaginationLoader &&
                      scrollInfo.metrics.pixels ==
                          scrollInfo.metrics.maxScrollExtent) {
                    dataFetch(); //<-- start loading data
                    if (mounted)
                      setState(() {
                        if (isDataRemaining == true) {
                          isShowPaginationLoader = true;
                        }
                      });
                  }
                  return true;
                },
                child: ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    ///IT SHOWS THE INITIAL DATA FETCH LOADER
                    _commonWidgets.showCommonLoader(
                      isLoaderVisible: isShowLoader,
                    ),

                    ///NO DATA WIDGET
                    _commonWidgets.buildEmptyDataWidget(
                      textMsg: isShowLoader
                          ? CommonConstants.LOADING_DATA
                          : CommonConstants.NO_DATA_FOUND,
                      isVisible: invoices.length < 1,
                    ),

                    ///IT BUILDS THE PRODUCTS LIST UI
                    _buildList(),

                    ///IT SHOWS THE PAGINATION LOADER
                    _commonWidgets.showCommonLoader(
                      isLoaderVisible: isShowPaginationLoader && !isShowLoader,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
