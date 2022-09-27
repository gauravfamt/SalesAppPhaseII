import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:moblesales/helpers/index.dart';
import 'package:moblesales/models/index.dart';
import 'package:moblesales/screens/index.dart';
import 'package:moblesales/utils/index.dart';

class ProductSearchDialog extends StatefulWidget {
  ///IT HANDLES THE PRODUCT SELECTED EVENT AND RETURNS THE SELECTED PRODUCT TO THE PARENT WIDGET
  final Function(Product product, int position) handleProductSelectedSearch;

  ///IT HANDLES THE CLOSE DIALOG EVENT
  final VoidCallback closeSearchDialog;

  ///USED TO HOLD THE RECORD POSITION FOR THE PRODUCT_LOOKUP
  ///JUST SEND 0 IF NOT_USED IN YOUR SCREEN
  final int recordPosition;

  final TargetPlatform;

  ///TO APPLY DIFFERENT PADDING WHEN WIDGET VIEWED IN LOOKUP'S SEARCH_TEXT_FIELD_UI
  final bool forLookupType;

  ProductSearchDialog({
    @required this.handleProductSelectedSearch,
    @required this.closeSearchDialog,
    @required this.recordPosition,
    @required this.TargetPlatform,
    this.forLookupType = false,
  });

  @override
  _ProductSearchDialogState createState() => _ProductSearchDialogState();
}

class _ProductSearchDialogState extends State<ProductSearchDialog> {
  ///HOLDS THE CLASS OBJECT WHICH CONTAINS THE REUSABLE WIDGETS
  CommonWidgets _commonWidgets;

  ///HOLDS PRODUCT_DATABASE HELPER OBJECT
  ProductDBHelper _productDBHelper;

  ///HOLDS THE LOCALLY FILTERED RESULT FOR THE PRODUCTS
  List<Product> _products;

  ///USED TO SHOW/HIDE LOADER FOR THE PRODUCTS LIST BEFORE DATA GETS LOADED
  bool _showProductSearchLoader;

  ///API PARAMETERS FOR THE PAGINATION PURPOSE
  int pageNumber;
  int pageSize;

  ///HANDLES THE SEARCH_TEXT_FIELD STATE FOR THE ADVANCED SEARCH
  String searchFieldContent;

  ///TO IDENTIFY IF THE LOCAL DATA IS FETCHED FOR THE FIRST TIME
  bool isInitialFetch;

  ///TO IDENTIFY IF THE LOCAL DATA IS SYNCED OR NOT
  bool isLocalDataSynced;

  ///BARCODE INITIAL VALUE FOR SEARCH
  String _scannedBarcodeValue = 'Unknown';

  ///TO IDENTIFY PRODUCT IS SCANNED FROM BARCODE AND NEEDS TO NAVIGATE BACK TO THE ADD_QUOTE_PAGE
  bool isScannedFromBarcode;

  int recordCount;
  int lastPageNumber;

  //To handle pagination wise data
  bool isNextButtonPressed;
  bool isPreviousButtonPressed;
  bool isGoToFirstPageButtonPressed;
  bool isGoToLastPageButtonPressed;

  bool isNextButtonDisabled;
  bool isPreviousButtonDisabled;
  bool isFirstPageButtonDisabled;
  bool isLastPageButtonDisabled;
  bool isShowPaginationButtons;

  TextEditingController _searchTFController;

  @override
  void initState() {
    super.initState();
    isInitialFetch = true;
    isLocalDataSynced = true;
    _commonWidgets = CommonWidgets();
    _productDBHelper = ProductDBHelper();
    _products = List<Product>();
    _showProductSearchLoader = true;

    pageNumber = 1;
    searchFieldContent = null;
    pageSize = Pagination.LOOKUP_PAGE_SIZE;
    _searchTFController = TextEditingController();
    isScannedFromBarcode = false;

    isNextButtonDisabled = false;
    isPreviousButtonDisabled = true; //Initialy on 1 page
    isFirstPageButtonDisabled = true;
    isShowPaginationButtons = false;
    recordCount = 0;
    lastPageNumber = 0;
    OfflineDataSyncsStatus();
    dataFetch();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> OfflineDataSyncsStatus() async {
    try {
      recordCount = await _productDBHelper.getProductCount('');
      lastPageNumber = (recordCount / pageSize).ceil();
      if (recordCount > 0) {
        setState(() {
          isLocalDataSynced = true;

          dataFetch();
        });
      } else {
        setState(() {
          isLocalDataSynced = false;
        });
      }
    } catch (e) {
      print('Error Inside OfflineDataSyncsStatus $e ');
    }
  }

  Future<void> getProductCount() async {
    try {
      if (searchFieldContent != null && searchFieldContent.trim().length > 0) {
        String strWhereClause =
            "and UPCCode LIKE '${'%' + searchFieldContent + '%'}' OR Description LIKE '${'%' + searchFieldContent + '%'}' OR ProductCode LIKE '${'%' + searchFieldContent + '%'}'";
        recordCount = await _productDBHelper.getProductCount(strWhereClause);
        lastPageNumber = (recordCount / pageSize).ceil();
      }
    } catch (e) {
      print('Error Inside getProductCount $e ');
    }
  }

  ///IT FETCHES PRODUCTS OFFLINE DATA FOR LOOKUP
  Future<List<Product>> fetchOfflineProductsData() async {
    var productData = List<Product>();
    try {
      getProductCount();
      productData = await _productDBHelper.getProductsPaginationData(
        pageNo: pageNumber,
        pageSize: pageSize,
        searchText:
            (searchFieldContent != null && searchFieldContent.trim().length > 0)
                ? searchFieldContent
                : '',
      );
      return productData;
    } catch (e) {
      print('Error inside fetchOfflineProductsData Response ');
      print(e);
      return productData;
    }
  }

  ///ITE FETCHES THE DATA FOR THE PRODUCTS LIST
  void dataFetch() {
    if ((isGoToLastPageButtonPressed == true || isNextButtonPressed == true) &&
        pageNumber == lastPageNumber) {
      print('Last Page Number: $pageNumber');
    } else {
      if (isNextButtonPressed == true) {
        pageNumber = pageNumber + 1;
      } else if (isPreviousButtonPressed == true) {
        if (pageNumber > 1) {
          pageNumber = pageNumber - 1;
        }
      } else if (isGoToFirstPageButtonPressed == true) {
        pageNumber = 1;
      } else if (isGoToLastPageButtonPressed == true) {
        pageNumber = (recordCount / pageSize).ceil();
      }
      if (pageNumber == 1) {
        isPreviousButtonDisabled = true;
        isFirstPageButtonDisabled = true;
      }
      fetchOfflineProductsData().then((productsDataRes) => {
            setState(() {
              int newRecordCount = productsDataRes.length;
              _products.clear();
              _products.addAll(productsDataRes);
              _showProductSearchLoader = false;
              if (newRecordCount < pageSize) {
                isNextButtonDisabled = true;
                isLastPageButtonDisabled = true;
                if (isPreviousButtonDisabled == true) {
                  isShowPaginationButtons = false;
                } else {
                  isShowPaginationButtons = true;
                }
              } else {
                if (lastPageNumber == pageNumber) {
                  //for newRecordCount==pageSize
                  isNextButtonDisabled = true;
                  isLastPageButtonDisabled = true;
                }
                isShowPaginationButtons = true;
              }
            }),

            ///IF PRODUCT SEARCHED FROM THE BARCODE_SCANNER AND PRODUCT FOUND THEN DIRECTLY NAVIGATING TO THE ADD_QUOTE_SCREEN
            if (isScannedFromBarcode == true && _products.length > 0)
              {
                this.setState(() {
                  isScannedFromBarcode = false;
                }),
                widget.handleProductSelectedSearch(
                    _products[0], widget.recordPosition),
                handleProductSelected(_products[0]),
              }
            else if (isScannedFromBarcode == true)
              {
                ///IF PRODUCT SCANNED FROM BARCODE_SCANNER AND NO RESULTS PRESENT THEN DISABLING isScannedFromBarcode State
                this.setState(() {
                  isScannedFromBarcode = false;
                }),
              }
          });
    }
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> scanBarcodeNormal() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          "#ff6666", "Cancel", true, ScanMode.BARCODE);
      print(barcodeScanRes);
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
      //Added by  Gaurav Gurav 22-01-2021// start
      if (Theme.of(context).platform == TargetPlatform.iOS) {
        setState(() {
          recordCount = 0;
          searchFieldContent = barcodeScanRes;
        });
        getProductCount();

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
      } //end
      setState(() {
        _scannedBarcodeValue = barcodeScanRes;
        _searchTFController.text = barcodeScanRes;
        isScannedFromBarcode = true;
      });
      handleTextFieldSearch(_scannedBarcodeValue);
    } else if (barcodeScanRes == BarcodeScanHelper.PLATFORM_VERSION_ERROR) {
      _commonWidgets.showFlutterToast(
          toastMsg:
              'Something went wrong while scanning barcode, Please Try again!');
    }
  }

  ///IT HANDLES THE SEARCH_TEXT_FIELD SEARCH CLICK CHANGES AND LOADS THE NEW DATA ACCORDINGLY
  void handleTextFieldSearch(String searchText) {
    if (isLocalDataSynced) {
      setState(() {
        searchFieldContent = searchText;
      });
      loadNewSearchData();
    } else {
      _commonWidgets.showFlutterToast(
          toastMsg: '${CommonConstants.GO_TO_SETTING_AND_SYNC_DATA}');
    }
  }

  ///IT HANDLES THE SEARCH_TEXT_FIELD CANCEL/CLEAR CLICK CHANGES AND LOADS THE NEW DATA ACCORDINGLY
  void clearTextFieldSearch() {
    setState(() {
      searchFieldContent = '';
      _scannedBarcodeValue = '';
    });
    loadNewSearchData();
  }

  ///IT CALLS THE DATA_FETCH FUNCTION TO LOAD THE NEW LIST AS PER SEARCH PARAMETERS ALSO
  ///IT CLEARS THE EXISTING STATES
  void loadNewSearchData() {
    setState(() {
      _products.clear(); //= List<Quotes>();
      pageNumber = 1;
      isNextButtonPressed = false;
      isPreviousButtonPressed = false;
      isNextButtonDisabled = false;
      isLastPageButtonDisabled = false;
      isPreviousButtonDisabled = true;
      isFirstPageButtonDisabled = true;
      _showProductSearchLoader = true;
    });
    dataFetch();
  }

  ///It returns the ProductList title widget
  Widget getListTitleWidget(textContent) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 5.0),
      child: Text(
        '$textContent',
        style: TextStyle(
          color: AppColors.grey, //Colors.teal.shade200,
          fontSize: 14,
        ),
      ),
    );
  }

  ///It returns the Product Value widget
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

  ///It handles the Selected Product Response for the search
  void handleProductSelected(Product selectedProduct) {
    Navigator.of(context, rootNavigator: true).pop('PopupClosed');
  }

  ///IT BUILDS THE PRODUCTS_LIST FOR THE SELECTION
  Widget _buildList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: ScrollPhysics(),
      itemCount: _products.length,
      itemBuilder: (context, position) {
        return GestureDetector(
          onTap: () {
            print('List View OnTap Closing the popup');
            widget.handleProductSelectedSearch(
                _products[position], widget.recordPosition);
            handleProductSelected(_products[position]);
          },
          child: Card(
            elevation: 0.0,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            getListValueWidget(
                                _products[position].ProductCode, 1),
                            SizedBox(height: 10),
                            getListValueWidget(
                                '${_products[position].Description}', 2),
//                                      getListValueWidget(
//                                          '${_products[position].UPCCode}', 2),
                            Padding(
                              padding:
                                  EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0),
                              child: Divider(
                                color: AppColors.grey,
                                thickness: 1.0,
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Center(child: Text('Product Details')),
      actionsPadding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
      insetPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      actions: <Widget>[
        Visibility(
          visible: isShowPaginationButtons,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
            child: Row(
              //crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
                  child: RaisedButton(
                    onPressed: isFirstPageButtonDisabled == true
                        ? null
                        : () {
                            setState(() {
                              isGoToFirstPageButtonPressed = true;
                              isGoToLastPageButtonPressed = false;
                              isNextButtonPressed = false;
                              isPreviousButtonPressed = false;
                              dataFetch();
                              isNextButtonDisabled = false;
                              isLastPageButtonDisabled = false;
                            });
                          },
                    color: Colors.blue,
                    child: Icon(
                      Icons.first_page,
                      color: Colors.white,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
                  child: RaisedButton(
                    onPressed: isPreviousButtonDisabled == true
                        ? null
                        : () {
                            setState(() {
                              isPreviousButtonPressed = true;
                              isNextButtonPressed = false;
                              isGoToFirstPageButtonPressed = false;
                              isGoToLastPageButtonPressed = false;
                              dataFetch();
                              isNextButtonDisabled = false;
                              isLastPageButtonDisabled = false;
                            });
                          },
                    color: Colors.blue,
                    child: Icon(
                      Icons.navigate_before,
                      color: Colors.white,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
                  child: RaisedButton(
                    onPressed: isNextButtonDisabled == true
                        ? null
                        : () {
                            setState(() {
                              isNextButtonPressed = true;
                              isPreviousButtonPressed = false;
                              isGoToFirstPageButtonPressed = false;
                              isGoToLastPageButtonPressed = false;
                              dataFetch();
                              isPreviousButtonDisabled = false;
                              isFirstPageButtonDisabled = false;
                            });
                          },
                    color: Colors.blue,
                    child: Icon(
                      Icons.navigate_next,
                      color: Colors.white,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 0.0),
                  child: RaisedButton(
                    onPressed: isLastPageButtonDisabled == true
                        ? null
                        : () {
                            setState(() {
                              isGoToLastPageButtonPressed = true;
                              isGoToFirstPageButtonPressed = false;
                              isNextButtonPressed = false;
                              isPreviousButtonPressed = false;
                              dataFetch();
                              isPreviousButtonDisabled = false;
                              isFirstPageButtonDisabled = false;
                            });
                          },
                    color: Colors.blue,
                    child: Icon(
                      Icons.last_page,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        FlatButton(
          onPressed: () {
            widget.closeSearchDialog();
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
                    showBarcodeScanner: true,
                    barcodeScannerHandler: scanBarcodeNormal,
                    placeHolder: 'Search Product',
                  ),
                ),
              ],
            ),

            Expanded(
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  Visibility(
                    visible: !isLocalDataSynced,
                    child: Text(
                        BackgroundServiceHelper.SYNC_INITIAL_LOOKUPS_DATA_MSG),
                  ),

                  ///IT SHOWS THE INITIAL DATA FETCH LOADER
                  _commonWidgets.showCommonLoader(
                    isLoaderVisible: _showProductSearchLoader,
                  ),

                  ///NO DATA WIDGET
                  _commonWidgets.buildEmptyDataWidget(
                    textMsg: CommonConstants.NO_DATA_FOUND,
                    isVisible: _products.length < 1 && isLocalDataSynced,
                  ),

                  ///IT BUILDS THE PRODUCTS LIST UI
                  Visibility(visible: isLocalDataSynced, child: _buildList()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
