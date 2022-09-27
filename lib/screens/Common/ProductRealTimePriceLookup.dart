import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:moblesales/helpers/index.dart';
import 'package:moblesales/models/index.dart';
import 'package:moblesales/screens/index.dart';
import 'package:moblesales/utils/index.dart';

import 'CommonWidgets.dart';

class ProductRealTimePriceLookup extends StatefulWidget {
  ///IT HANDLES THE CLOSE DIALOG EVENT
  final VoidCallback closeSearchDialog;

  ///USED TO RESET THE QUOTES/PRODUCTS DATA SELECTED FOR THE SEND_MAIL
  final VoidCallback resetSendMailData;

  ///STRING ARRAY FOR JSON TO SEND TO APPEND TO THE API BODY DATA
  final List<Product> productData;

  ProductRealTimePriceLookup({
    @required this.closeSearchDialog,
    @required this.resetSendMailData,
    @required this.productData,
  });

  @override
  _ProductRealTimePriceLookupState createState() =>
      _ProductRealTimePriceLookupState();
}

class _ProductRealTimePriceLookupState
    extends State<ProductRealTimePriceLookup> {
  CommonWidgets _commonWidgets;

  ///HOLDS COMPANY SELECTED FROM LOOKUP
  Company _selectedCompany;

  ///HOLDS ProductRealTimePrice
  List<ProductRealTimePriceData> _productRealTimePrice;

  List<ProductRealTimePrice> _fetchedRealTimePrice;

  ProductDBHelper _productDBHelper;

  List<Product> _selectedProduct;

  ///TO FETCH THE CURRENCY DROPDOWN VALUES
  StandardDropDownFieldsDBHelper _standardDropDownFieldsDBHelper;

  ///HOLDS CURRENCY DROPDOWN FIELD
  StandardDropDownField _standardCurrencyDropDownField;

  ///HOLDS ERP DROPDOWN FIELD
  StandardDropDownField _standardERPDropDownField;

  ///HOLDS CURRENCY_SYMBOL
  String currencySymbol;

  String userSalesSiteCode;

  bool isShowLoader;

  void initState() {
    isShowLoader = false;
    _commonWidgets = CommonWidgets();
    _selectedCompany = Company();
    currencySymbol = "";
    userSalesSiteCode = "";
    _standardDropDownFieldsDBHelper = new StandardDropDownFieldsDBHelper();
    _standardCurrencyDropDownField = new StandardDropDownField();
    _standardERPDropDownField = new StandardDropDownField();
    _fetchedRealTimePrice = new List<ProductRealTimePrice>();
    _productRealTimePrice = new List<ProductRealTimePriceData>();
    _productDBHelper = ProductDBHelper();
    fetchCurrencyDropDownValue();
    fetchERPDropDownValue();
    setUserSalesSite();
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
                      'Currency DropDown Entry not present at localDB for ProductRealTimePriceLookup'),
                }
            })
        .catchError((e) => {
              print(
                  'Error while fetching currency dropdown fields from LocalDB for ProductRealTimePriceLookup'),
              print(e),
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
                }
              else
                {
                  print(
                      'ERP DropDown Entry not present at localDB for REAL-TIME-PRICING AND QUANTITY '),
                }
            })
        .catchError((e) => {
              print(
                  'Error while fetching ERP dropdown fields from LocalDB for REAL_TIME_PRICING AND QUANTITY'),
              print(e),
            });
  }

  Future<void> setUserSalesSite() async {
    userSalesSiteCode = await Session.getSalesSiteCode();
  }

  Widget getListValueWidget(textContent, type) {
    return Text(
      '$textContent',
      style: TextStyle(
        color: type == 1 ? AppColors.blue : AppColors.black,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    );
  }

  Widget getPriceWidget(String Price) {
    return Text(
      'Price: $currencySymbol $Price',
      textAlign: TextAlign.end,
      style: TextStyle(
        color: Colors.black,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: ScrollPhysics(),
      itemCount: _productRealTimePrice.length,
      itemBuilder: (context, position) {
        return Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(2.0)),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    getListValueWidget(
                        _productRealTimePrice[position]
                            .ProductObject
                            .ProductCode,
                        1),
                    Expanded(
                      child: getPriceWidget(
                          _productRealTimePrice[position].Price.toString()),
                    ),
                  ],
                ),
                SizedBox(
                  height: 5.0,
                ),
                getListValueWidget(
                    '${_productRealTimePrice[position].ProductObject.Description}',
                    2),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<List<ProductRealTimePriceData>> preperData() async {
    try {
      var productCodes = '';
      var productRealTimePriceData = List<ProductRealTimePriceData>();
      var productData = List<Product>();
      for (int i = 0; i < _fetchedRealTimePrice.length; i++) {
        if (productCodes == '') {
          productCodes = "'${_fetchedRealTimePrice[i].ProductCode.toString()}'";
        } else {
          productCodes +=
              ",'${_fetchedRealTimePrice[i].ProductCode.toString()}'";
        }
      }

      print('Product Codes $productCodes');
      productData = await _productDBHelper.getProductsDetailsForInventory(
        productCodes: productCodes,
      );
      print('Length: ${productData.length}');

      for (int i = 0; i < productData.length; i++) {
        var requiredData = _fetchedRealTimePrice.firstWhere(
            (e) => e.ProductCode == productData[i].ProductCode,
            orElse: () => null);
        if (requiredData != null) {
          productRealTimePriceData.add(new ProductRealTimePriceData(
              productData[i], double.parse(requiredData.Price.toString())));
        }
      }
      return productRealTimePriceData;
    } catch (e) {
      print('Error inside prepareInventoryData Response ');
      print(e);
    }
  }

  void dataFetch() {
    preperData().then((realTimePriceData) => {
          setState(() {
            _productRealTimePrice.addAll(realTimePriceData);
            _productRealTimePrice.sort((a, b) => a.ProductObject.ProductCode
                .compareTo(b.ProductObject.ProductCode));
            isShowLoader = false;
          }),
        });
  }

  void updateDataBase() {
    try {
      for (int i = 0; i < _fetchedRealTimePrice.length; i++) {
        var result = _productDBHelper.updateProductBasePrice(
            _fetchedRealTimePrice[i].Price.toString(),
            _fetchedRealTimePrice[i].ProductCode.toString());
        print('result $result');
      }
    } catch (ex) {}
  }

  void GetProductRealTimeAPIData() async {
    try {
      print('inside GetProductRealTimeAPIData');
      String _salesSite = userSalesSiteCode;
      String _customer = _selectedCompany.CustomerNo;
      String _currency = _standardCurrencyDropDownField.Code;
      String _erpName = _standardERPDropDownField.Code;

      print('salesSite $_salesSite');
      print('customer $_customer');
      print('currency $_currency');
      print('erpName $_erpName');
      print('idsData : ${widget.productData.length}');
      try {
        String strFlag = '';
        String requestBody = '{';
        requestBody += '"CustomerNo" : "${_customer}",';
        requestBody += '"SalesSite" : "${_salesSite}",';
        requestBody += '"Currency" : "${_currency}",';
        requestBody += '"QuoteDetailsGrid" : [{';
        requestBody += '"QuoteDetail" : [';
        for (int i = 0; i < widget.productData.length; i++) {
          print('requestBody : ${requestBody}');
          print('product : ${widget.productData[i].ProductCode.toString()}');
          if (strFlag == '') {
            strFlag = 'val';
            requestBody += '{';
            requestBody +=
                '"ProductCode" : "${widget.productData[i].ProductCode.toString()}",';
            requestBody += '"Quantity" : "1"';
          } else {
            requestBody += ',{';
            requestBody +=
                '"ProductCode" : "${widget.productData[i].ProductCode.toString()}",';
            requestBody += '"Quantity" : "1"';
          }
          requestBody += '}';
        }
        requestBody += ']';
        requestBody += '}]';
        requestBody += '}';
        print('Request Body: $requestBody');

        ApiService.getPricing(
          erpName: _erpName,
          requestBody: requestBody,
        )
            .then((value) => {
                  if (!value.toString().contains('Error'))
                    {
                      print('ProductReal $value'),
                      if (value.isNotEmpty)
                        {
                          setState(() {
                            _fetchedRealTimePrice.addAll(value);
                          }),
                          updateDataBase(),
                          dataFetch(),
                        }
                      else
                        {
                          _commonWidgets.showAlertMsg(
                              alertMsg: value
                                  .toString()
                                  .replaceAll('"', '')
                                  .replaceAll('[', '')
                                  .replaceAll(']', '')
                                  .replaceAll('}', '')
                                  .replaceAll('{', ''),
                              MessageType: AlertMessageType.ERROR,
                              context: context),
                          setState(() {
                            isShowLoader = false;
                          }),
                        }
                    }
                  else
                    {
                      _commonWidgets.showAlertMsg(
                          alertMsg: value
                              .toString()
                              .replaceAll('"', '')
                              .replaceAll('[', '')
                              .replaceAll(']', '')
                              .replaceAll('}', '')
                              .replaceAll('{', ''),
                          MessageType: AlertMessageType.ERROR,
                          context: context),
                      setState(() {
                        isShowLoader = false;
                      }),
                    }
                })
            .catchError((e) => {
                  print('Pricing API Error Response $e'),
                });
      } catch (e) {
        print(
            'Error while calling multiple realtime APIs So calling normal flow');
        print(e);
      }
    } catch (e) {
      print('Error inside GetProductRealTimeAPIData FN ');
      print(e);
    }
  }

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

  void handleProductRealTimePriceClick() async {
    if (_selectedCompany.CustomerNo == null) {
      _commonWidgets.showFlutterToast(toastMsg: 'Select Customer');
    } else {
      GetProductRealTimeAPIData();
    }
  }

  ///IT RESETS THE COMPANY SELECTED DATA
  void clearSelectedCompany() {
    setState(() {
      _selectedCompany = Company();
      _productRealTimePrice = new List<ProductRealTimePriceData>();
    });
  }

  ///It handles the Selected Company Response for the search
  void handleCustomerSelectedSearch(Company selectedCompany) {
    print('Inside handleCustomerSelectedSearch fn of product price lookup');
    setState(() {
      _selectedCompany = selectedCompany;
      isShowLoader = true;
      _productRealTimePrice = new List<ProductRealTimePriceData>();
      GetProductRealTimeAPIData();
    });
  }

  void closeSearchDialog() {
    print('Lookup Dialog closed');
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

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return AlertDialog(
      title: Center(child: Text('Real Time Price')),
      actionsPadding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
      insetPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      actionsOverflowDirection: VerticalDirection.down,
      actions: <Widget>[
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

            _commonWidgets.getListingCompanySelectorWidget(
              showCompanyDialogHandler: showCompanyDialog,
              clearSelectedCompanyHandler: clearSelectedCompany,
              selectedCompany: _selectedCompany,
              isForPriceLookupView: true,
            ),

            ///SHOWS CUSTOMER SEARCH
            ///LOADER FOR LAST PRICE API CALL RESPONSE
            Expanded(
                child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                SizedBox(height: 5.0),

                ///FIRST TIME LOADING DATA LOADER
                _commonWidgets.showCommonLoader(isLoaderVisible: isShowLoader),

                ///IT SHOWS THE NO DATA PRESENT MESSAGE
                _commonWidgets.buildEmptyDataWidget(
                  textMsg: 'No data found',
                  isVisible: _productRealTimePrice.length < 1 &&
                      _selectedCompany.CustomerNo == "" &&
                      !isShowLoader,
                ),

                ///BUILDS INVOICES LIST
                _buildList(),
              ],
            )),
          ],
        ),
      ),
    );
  }
}
