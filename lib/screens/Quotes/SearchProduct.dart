import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:moblesales/helpers/index.dart';
import 'package:moblesales/models/index.dart';
import 'package:moblesales/screens/index.dart';
import 'package:moblesales/utils/index.dart';
import 'AddQuote.dart';

class SearchProduct extends StatelessWidget {
  // This widget is the root of your application.
  final Company selectedCompany;
  final List<ProductQuantity> ProductQuantityList;
  final String PONumber;
  final String Note;
  final bool isRedirectFromAddQuote;
  final String selectedProductCodes;

  SearchProduct(
      {@required this.selectedCompany,
      this.selectedProductCodes,
      this.ProductQuantityList,
      this.PONumber,
      this.Note,
      this.isRedirectFromAddQuote});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Search Product",
      home: SearchProductPage(
        parentBuildContext: context,
        selectedCompany: selectedCompany,
        ProductQuantityList: ProductQuantityList,
        PONumber: PONumber,
        Note: Note,
        selectedProductCodes: selectedProductCodes,
        isRedirectFromAddQuote: isRedirectFromAddQuote,
      ),
    );
  }
}

class SearchProductPage extends StatefulWidget {
  final BuildContext parentBuildContext;
  final Company selectedCompany;
  final List<ProductQuantity> ProductQuantityList;
  final String PONumber;
  final String Note;
  final String selectedProductCodes;
  final bool isRedirectFromAddQuote;
  final TargetPlatform platform;

  SearchProductPage({
    Key key,
    @required this.parentBuildContext,
    @required this.selectedCompany,
    this.ProductQuantityList,
    this.PONumber,
    this.Note,
    this.selectedProductCodes,
    this.isRedirectFromAddQuote,
    this.platform,
  }) : super(key: key);

  @override
  _SearchProductPageState createState() => _SearchProductPageState();
}

class _SearchProductPageState extends State<SearchProductPage> {
  ///HOLDS THE WIDGETS LIST WHICH ARE DISPLAYED
  CommonWidgets _commonWidgets;

  String _scannedBarcodeValue = 'Unknown';

  ///HOLDS PRODUCT_DATABASE HELPER OBJECT
  ProductDBHelper _productDBHelper;

  ///HOLDS PRODUCTS SELECTED FROM LOOKUP
  Quotes listingQuoteObj;

  bool isShowProductCategoryClearButton;
  bool isShowProductIdClearButton;
  bool isShowProductDescClearButton;
  bool isShowProductCodeClearButton;
  bool isDisplyProductQuantityList;

  TextEditingController TECProductDescription;
  TextEditingController TECProductCategory;
  TextEditingController TECProductKey;
  TextEditingController TECProductCode;
  List<ProductQuantity> ProductQuantityList;

  EdgeInsets _cardPadding = const EdgeInsets.fromLTRB(15.0, 8.0, 15.0, 0.0);
  EdgeInsets _cardContentPadding = const EdgeInsets.all(20.0);

  int recordCount = 0;

  @override
  void initState() {
    super.initState();
    TECProductDescription = new TextEditingController();
    TECProductCategory = new TextEditingController();
    TECProductKey = new TextEditingController();
    TECProductCode = new TextEditingController();
    isShowProductCategoryClearButton = false;
    isShowProductIdClearButton = false;
    isShowProductDescClearButton = false;
    isShowProductCodeClearButton = false;
    isDisplyProductQuantityList = false;
    ProductQuantityList = new List();
    _productDBHelper = ProductDBHelper();
    if (widget.selectedProductCodes != null) {
      // print(widget.selectedProductCodes);
    }
  }

  void closeSearchDialog() {
    //  print('closeSearchDialog called');
    //  print('${ProductQuantityList.length}');
  }

  Widget getSearchTextField(String placeholder, TextEditingController TEC) {
    return Expanded(
      flex: 2,
      child: Padding(
        padding: const EdgeInsets.all(0.0),
        child: TextField(
          controller: TEC,
          onChanged: (text) {
            ClearButtonVisibility();
          },
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'OpenSans',
          ),
          decoration: InputDecoration(
            hintText: '$placeholder',
            hintStyle: TextStyle(
              color: AppColors.grey,
              fontFamily: 'OpenSans',
            ),
            border: InputBorder.none,
            contentPadding: _cardContentPadding,
          ),
        ),
      ),
    );
  }

  ///IT RESETS THE PRODUCT SELECTED DATA
  void clearSearchTextField(TextEditingController TEC) {
    setState(() {
      TEC.text = '';
      ClearButtonVisibility();
    });
  }

  void ClearButtonVisibility() {
    setState(() {
      // print('ClearButtonVisibility');
      if (TECProductCategory.text.length > 0) {
        isShowProductCategoryClearButton = true;
      } else {
        isShowProductCategoryClearButton = false;
      }

      if (TECProductKey.text.length > 0) {
        isShowProductIdClearButton = true;
      } else {
        isShowProductIdClearButton = false;
      }

      if (TECProductDescription.text.length > 0) {
        isShowProductDescClearButton = true;
      } else {
        isShowProductDescClearButton = false;
      }

      if (TECProductCode.text.length > 0) {
        isShowProductCodeClearButton = true;
      } else {
        isShowProductCodeClearButton = false;
      }
    });
  }

  ///IT SHOWS THE PRODUCT LOOKUP
  void showProductList(String strSearchBy, String strSearchContent) {
    //  print('showProductList');
    showDialog(
      useRootNavigator: true,
      barrierDismissible: false,
      context: context,
      builder: (context) => ProductSearch(
        searchContent: strSearchContent,
        searchBy: strSearchBy,
        ProductQuantityList: ProductQuantityList,
        closeSearchDialog: closeSearchDialog,
      ),
    ).then(
      (value) => (context as Element).reassemble(),
    ); //To refresh gui
  }

  Widget ProductCategory() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: _cardPadding,
            child: Card(
              elevation: 1.0,
              child: Row(
                children: <Widget>[
                  getSearchTextField('Product Category', TECProductCategory),
                  Visibility(
                    visible: isShowProductCategoryClearButton,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
                      child: SizedBox(
                        width: 40.0,
                        child: FlatButton(
                          padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                          onPressed: () {
                            clearSearchTextField(TECProductCategory);
                          },
                          child: Icon(Icons.clear, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
                    child: SizedBox(
                      width: 40.0,
                      child: RaisedButton(
                        padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                        color: AppColors.blue,
                        onPressed: () {
                          showProductList(
                              "ProductCategory", TECProductCategory.text);
                        },
                        child: Icon(Icons.search, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget ProductKey() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: _cardPadding,
            child: Card(
              elevation: 1.0,
              child: Row(
                children: <Widget>[
                  getSearchTextField('Product Key', TECProductKey),
                  Visibility(
                    visible: isShowProductIdClearButton,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
                      child: SizedBox(
                        width: 40.0,
                        child: FlatButton(
                          padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                          onPressed: () {
                            clearSearchTextField(TECProductKey);
                          },
                          child: Icon(Icons.clear, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
                    child: SizedBox(
                      width: 40.0,
                      child: RaisedButton(
                        padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                        color: AppColors.blue,
                        onPressed: () {
                          showProductList('ProductKey', TECProductKey.text);
                        },
                        child: Icon(Icons.search, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget ProductDescription() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: _cardPadding,
            child: Card(
              elevation: 1.0,
              child: Row(
                children: <Widget>[
                  getSearchTextField(
                      'Product Description', TECProductDescription),
                  Visibility(
                    visible: isShowProductDescClearButton,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
                      child: SizedBox(
                        width: 40.0,
                        child: FlatButton(
                          padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                          onPressed: () {
                            clearSearchTextField(TECProductDescription);
                          },
                          child: Icon(Icons.clear, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
                    child: SizedBox(
                      width: 40.0,
                      child: RaisedButton(
                        padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                        color: AppColors.blue,
                        onPressed: () {
                          showProductList(
                              'ProductDescription', TECProductDescription.text);
                        },
                        child: Icon(Icons.search, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget ProductCode() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: _cardPadding,
            child: Card(
              elevation: 1.0,
              child: Row(
                children: <Widget>[
                  getSearchTextField('Product Code', TECProductCode),
                  Visibility(
                    visible: isShowProductCodeClearButton,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
                      child: SizedBox(
                        width: 40.0,
                        child: FlatButton(
                          padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                          onPressed: () {
                            clearSearchTextField(TECProductCode);
                          },
                          child: Icon(Icons.clear, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
                    child: SizedBox(
                      width: 40.0,
                      child: RaisedButton(
                        padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                        color: AppColors.blue,
                        onPressed: () {
                          showProductList('ProductCode', TECProductCode.text);
                        },
                        child: Icon(Icons.search, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> getProductCount(String searchFieldContent) async {
    try {
      if (searchFieldContent != null && searchFieldContent.trim().length > 0) {
        String strWhereClause =
            "and UPCCode LIKE '${'%' + searchFieldContent + '%'}' OR Description LIKE '${'%' + searchFieldContent + '%'}' OR ProductCode LIKE '${'%' + searchFieldContent + '%'}'";
        recordCount = await _productDBHelper.getProductCount(strWhereClause);
      }
    } catch (e) {
      print('Error Inside getProductCount $e ');
    }
  }

  String searchFieldContent;
  Future<void> scanBarcodeNormal() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          "#ff6666", "Cancel", true, ScanMode.BARCODE);
      //  print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = BarcodeScanHelper.PLATFORM_VERSION_ERROR;
    }
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    //BARCODE RESPONSE HARDCODED FOR TESTING PURPOSE OF NAVIGATION TO THE ADD_QUOTE_PAGE
    //barcodeScanRes = "3782940542087";
    if (barcodeScanRes != BarcodeScanHelper.PLATFORM_VERSION_ERROR &&
        barcodeScanRes != '-1') {
      //Added by  Gaurav Gurav 22-01-2021, To remove additional 0 added in barcode value in IOS device eg
      // Original value     BAQP003
      // IOS Device Display 0BAQP003
      // start
      if (Theme.of(context).platform == TargetPlatform.iOS) {
        setState(() {
          recordCount = 0;
          searchFieldContent = barcodeScanRes;
        });
        getProductCount(searchFieldContent);

        if (recordCount == 0) {
          if (searchFieldContent.startsWith('0')) {
            setState(() {
              barcodeScanRes =
                  searchFieldContent.substring(1, searchFieldContent.length);
            });
          }
        } else {
          barcodeScanRes = searchFieldContent;
        }
      }
      //end
      setState(() {
        _scannedBarcodeValue = barcodeScanRes;
        // _commonWidgets.showFlutterToast(toastMsg: 'Barcode Value: $_scannedBarcodeValue');
        //  print('ScannedBarcode Value: $_scannedBarcodeValue');
        //isScannedFromBarcode = true;
      });
      showProductList('BarcodeValue', _scannedBarcodeValue);
    } else if (barcodeScanRes == BarcodeScanHelper.PLATFORM_VERSION_ERROR) {
      _commonWidgets.showFlutterToast(
          toastMsg:
              'Something went wrong while scanning barcode, Please Try again!');
    }
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

  Widget getQuantityWidget(String Quantity) {
    return Text(
      'Quantity : $Quantity',
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
      itemCount: ProductQuantityList.length,
      itemBuilder: (context, position) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(15.0, 2.0, 15.0, 0.0),
          child: Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(2.0)),
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
                          '${ProductQuantityList[position].ProductObject.ProductCode}',
                          1),
                      Expanded(
                        child: getQuantityWidget(
                            ProductQuantityList[position].Quantity.toString()),
                      ),
                    ],
                  ),
                  getListValueWidget(
                      '${ProductQuantityList[position].ProductObject.Description}',
                      2),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void handleAyncPageNavigation() async {
    var result = await Navigator.of(widget.parentBuildContext).push(
      MaterialPageRoute(
        builder: (context) => AddQuotePage(
          addQuoteType: AddQuoteType.NEW_QUOTE,
          ProductQuantityList: ProductQuantityList,
          selectedCompany: widget.selectedCompany,
          PONumber: widget.PONumber,
          Note: widget.Note,
        ),
      ),
    );

    if (result != null) {
      // print('result $result');
      //back to customer selection
      if (result == true)
        //Go to Home Page
        Navigator.pop(widget.parentBuildContext, true);
      else
        //Go to Customer Statement
        Navigator.pop(widget.parentBuildContext, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Product'),
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(widget.parentBuildContext);
            }),
      ),
      body: Container(
        // padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            ProductCode(),
            ProductCategory(),
            ProductDescription(),
            ProductKey(),
            SizedBox(
              height: 10,
            ),
            ProductQuantityList.length > 0
                ? Center(
                    child: getListValueWidget(
                        '${ProductQuantityList.length} Product Selected', 2))
                : Text(''),
            Expanded(
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  _buildList(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                        child: RaisedButton(
                          onPressed: () {
                            scanBarcodeNormal();
                          },
                          child: Text(
                            'Scan',
                            style: TextStyle(color: Colors.white),
                          ),
                          color: AppColors.blue,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                        child: RaisedButton(
                          onPressed: () {
                            int count = ProductQuantityList.length;
//                            for (int i = 0; i < count; i++) {
//                              print(
//                                  'Product Code:${ProductQuantityList[i].ProductObject.ProductCode} | Quantity: ${ProductQuantityList[i].Quantity}');
//                            }
                            if (widget.isRedirectFromAddQuote == false) {
                              handleAyncPageNavigation();
                            } else {
                              //  print('Edit Quote');
                              Navigator.pop(widget.parentBuildContext,
                                  ProductQuantityList);
                            }
                          },
                          child: Text(
                            widget.isRedirectFromAddQuote == false
                                ? "Create Quote"
                                : "Add To Quote",
                            style: TextStyle(color: Colors.white),
                          ),
                          color: AppColors.blue,
                        ),
                      ),
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
