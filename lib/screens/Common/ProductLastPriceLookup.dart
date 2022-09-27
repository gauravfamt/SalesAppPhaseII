import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:http/http.dart' as http;
import 'package:moblesales/helpers/index.dart';
import 'package:moblesales/models/index.dart';
import 'package:moblesales/screens/index.dart';
import 'package:moblesales/utils/Helper/index.dart';

class ProductLastPriceLookup extends StatefulWidget {
  @override
  _ProductLastPriceLookupState createState() => _ProductLastPriceLookupState();
}

class _ProductLastPriceLookupState extends State<ProductLastPriceLookup> {
  ///HOLDS THE WIDGETS LIST WHICH ARE DISPLAYED
  CommonWidgets _commonWidgets;

  ///HOLDS COMPANY SELECTED FROM LOOKUP
  Company _selectedCompany;

  ///HOLDS PRODUCTS SELECTED FROM LOOKUP
  Product _selectedProduct;

  ///IT HOLDS PRODUCT LAST_PRICE_LOOKUP
  ProductLastPrice _productLastPrice;

  ///PROVIDES LIST_VIEW_WIDGETS
  ListViewRowsHelper _listViewRowsHelper;

  ///SETS TRUE IF PRODUCT PRICE NOT FOUND
  bool _productPriceNotFound;

  ///IT SHOWS PRODUCT LAST PRICE
  bool _showProductLastPrice;

  ///SHOWS THE LOADER TILL LAST_PRICE IS LOADED FORM API
  bool _isLoadingLastPrice;

  ///TO FETCH THE CURRENCY DROPDOWN VALUES
  StandardDropDownFieldsDBHelper _standardDropDownFieldsDBHelper;

  ///HOLDS CURRENCY DROPDOWN FIELD
  StandardDropDownField _standardCurrencyDropDownField;

  ///HOLDS CURRENCY_SYMBOL
  String currencySymbol;

  @override
  void initState() {
    super.initState();
    _isLoadingLastPrice = false;
    _productPriceNotFound = false;
    _showProductLastPrice = false;
    _commonWidgets = CommonWidgets();
    _selectedCompany = Company();
    _selectedProduct = Product();
    _productLastPrice = ProductLastPrice();
    _listViewRowsHelper = ListViewRowsHelper();
    _standardDropDownFieldsDBHelper = StandardDropDownFieldsDBHelper();
    _standardCurrencyDropDownField = StandardDropDownField();
    currencySymbol = '';
    fetchCurrencyDropDownValue();
  }

  @override
  void dispose() {
    super.dispose();
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
                }
              else
                {
                  print(
                      'Currency DropDown Entry not present at localDB for ProductLastPriceLookup'),
                }
            })
        .catchError((e) => {
              print(
                  'Error while fetching currency dropdown fields from LocalDB for ProductLastPriceLookup'),
              print(e),
            });
  }

  ///IT RETURNS THE TITLE WIDGET
  Widget getTitleWidget({
    @required String title,
    @required EdgeInsets titlePadding,
  }) {
    return Padding(
      padding: titlePadding,
      child: Text(
        '$title',
        style: TextStyle(
          color: AppColors.grey,
          fontSize: 15,
        ),
      ),
    );
  }

  ///It closes the Dialog On CLose Btn click
  void closeSearchDialog() {
    print('Lookup Dialog closed');
  }

  ///It handles the Selected Company Response for the search
  void handleCustomerSelectedSearch(Company selectedCompany) {
    print('Inside handleCustomerSelectedSearch fn of product price lookup');
    setState(() {
      _selectedCompany = selectedCompany;
    });
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
      ),
    );
  }

  ///IT RESETS THE COMPANY SELECTED DATA
  void clearSelectedCompany() {
    setState(() {
      _selectedCompany = Company();
      _productLastPrice = ProductLastPrice();
      _showProductLastPrice = false;
      _productPriceNotFound = false;
    });
  }

  ///IT RESETS THE PRODUCT SELECTED DATA
  void clearSelectedProduct() {
    setState(() {
      _selectedProduct = Product();
      _productLastPrice = ProductLastPrice();
      _showProductLastPrice = false;
      _productPriceNotFound = false;
    });
  }

  ///IT SETS THE STATE FOR SELECTED PRODUCT FOR THE QUOTE DETAILS
  void handleProductChange(Product productObj, int quotePosition) {
    setState(() {
      _selectedProduct = productObj;
    });
  }

  ///IT SHOWS THE PRODUCT LOOKUP
  void showProductLookup() {
    showDialog(
      useRootNavigator: true,
      barrierDismissible: false,
      context: context,
      builder: (context) => ProductSearchDialog(
        handleProductSelectedSearch: this.handleProductChange,
        closeSearchDialog: this.closeSearchDialog,
        recordPosition: 0,
        forLookupType: true,
      ),
    );
  }

  ///IT BUILDS PRODUCT LAST PRICE UI
  Widget buildProductLastPriceWidget() {
    return Card(
      child: Column(
        children: <Widget>[
          _listViewRowsHelper.getRowContentWidget(
              'Product Code', _selectedProduct.ProductCode, false, false),
          _listViewRowsHelper.getRowContentWidget(
              'Description', _selectedProduct.Description, false, false),
          _listViewRowsHelper.getRowContentWidget('Last Price',
              '$currencySymbol ${_productLastPrice.LastPrice}', false, false),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Center(child: Text('Last Price')),
      actionsPadding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
      insetPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      actionsOverflowDirection: VerticalDirection.down,
      actions: <Widget>[
        RaisedButton(
          color: AppColors.blue,
          child: Text("Product's Last Price"),
          onPressed: handleProductLastPriceClick,
        ),
        RaisedButton(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop('PopupClosed');
          },
        ),
      ],
      content: Container(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ///CUSTOMER TITLE
            getTitleWidget(
              title: 'Select Customer No. *',
              titlePadding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0),
            ),

            ///SHOWS CUSTOMER SEARCH
            _commonWidgets.getListingCompanySelectorWidget(
              showCompanyDialogHandler: showCompanyDialog,
              clearSelectedCompanyHandler: clearSelectedCompany,
              selectedCompany: _selectedCompany,
              isForPriceLookupView: true,
            ),

            ///PRODUCT TITLE
            getTitleWidget(
              title: 'Select Product *',
              titlePadding: EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 10.0),
            ),

            ///SHOWS PRODUCT SEARCH
            _commonWidgets.getListingProductSelectorWidget(
              showProductDialogHandler: showProductLookup,
              clearSelectedProductHandler: clearSelectedProduct,
              selectedProduct: _selectedProduct,
              isForPriceLookupView: true,
            ),

            ///LOADER FOR LAST PRICE API CALL RESPONSE
            _commonWidgets.showCommonLoader(
              isLoaderVisible: _isLoadingLastPrice,
            ),

            ///LAST PRICE RESPONSE FROM API CALL
            Visibility(
              visible: _productPriceNotFound,
              child: Center(
                  child: Padding(
                padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                child: Text(
                  "Product's last price not found",
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
              )),
            ),
            Visibility(
              visible: _showProductLastPrice,
              child: buildProductLastPriceWidget(),
            ),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  ///IT HANDLES THE PRODUCT LAST PRICE VALUE FETCH FROM API
  void handleProductLastPriceClick() async {
    if (_selectedCompany.CustomerNo == null) {
      _commonWidgets.showFlutterToast(toastMsg: 'Select Customer');
    } else if (_selectedProduct.ProductCode == null) {
      _commonWidgets.showFlutterToast(toastMsg: 'Select Product');
    } else {
      setState(() {
        _productPriceNotFound = false;
        _showProductLastPrice = false;
        _isLoadingLastPrice = true;
        _productLastPrice = ProductLastPrice();
      });
      ApiService.getProductLastPrice(
        customerCode: _selectedCompany.CustomerNo,
        productCode: _selectedProduct.ProductCode,
      )
          .then((value) => {
                if (value.length > 0)
                  {
                    this.setState(() {
                      _isLoadingLastPrice = false;
                      _productLastPrice = value[0];
                      _showProductLastPrice = true;
                    }),
                  }
                else
                  {
                    setLastPriceLoadError(),
                  },
              })
          .catchError((e) => {
                print('Error Inside handleProductLastPriceClick Fn '),
                print(e),
                setLastPriceLoadError(),
              });
    }
  }

  void setLastPriceLoadError() {
    this.setState(() {
      _isLoadingLastPrice = false;
      _productPriceNotFound = true;
    });
  }
}
