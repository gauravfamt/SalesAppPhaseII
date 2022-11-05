import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moblesales/helpers/index.dart';
import 'package:moblesales/models/index.dart';
import 'package:moblesales/screens/index.dart';
import 'package:moblesales/utils/index.dart';
import 'package:sqflite/sqflite.dart';

class ProductSearch extends StatelessWidget {
  final VoidCallback closeSearchDialog;
  final String searchContent;
  final String searchBy;
  final List<ProductQuantity> ProductQuantityList;

  ProductSearch({
    @required this.searchContent,
    @required this.searchBy,
    @required this.closeSearchDialog,
    this.ProductQuantityList,
  });

  @override
  Widget build(BuildContext context) {
    return (MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Product Search',
      home: ProductSearchPage(
        searchContent: searchContent,
        closeSearchDialog: closeSearchDialog,
        searchBy: searchBy,
        ProductQuantityList: ProductQuantityList,
      ),
    ));
  }
}

class ProductSearchPage extends StatefulWidget {
  ///IT HANDLES THE PRODUCT SELECTED EVENT AND RETURNS THE SELECTED PRODUCT TO THE PARENT WIDGET
  final BuildContext parentBuildContext;
  final String searchContent;
  final String searchBy;
  final List<ProductQuantity> ProductQuantityList;
  final VoidCallback closeSearchDialog;

  ProductSearchPage({
    this.parentBuildContext,
    @required this.searchContent,
    @required this.searchBy,
    @required this.closeSearchDialog,
    this.ProductQuantityList,
  });

  @override
  _ProductSearchPageState createState() => _ProductSearchPageState();
}

class _ProductSearchPageState extends State<ProductSearchPage> {
  ///HOLDS THE CLASS OBJECT WHICH CONTAINS THE REUSABLE WIDGETS
  CommonWidgets _commonWidgets;
  int recordPosition;

  ///HOLDS PRODUCT_DATABASE HELPER OBJECT
  ProductDBHelper _productDBHelper;

  ///HANDLES THE SEARCH_TEXT_FIELD STATE FOR THE ADVANCED SEARCH
  final List<TextEditingController> productQuantityTextEditingController =
      new List();

  //TO IDENTIFY IF THE LOCAL DATA IS FETCHED FOR THE FIRST TIME
  ///TO IDENTIFY IF THE LOCAL DATA IS SYNCED OR NOT
  bool isLocalDataSynced;

  ///HOLDS THE LOCALLY FILTERED RESULT FOR THE PRODUCTS
  List<Product> _products;

  List<ProductQuantity> ProductQuantityList;

  ///USED FOR PAGINATION PURPOSE TO CHECK THE DATA IS REMAINING FOR THE GET
  bool isDataRemaining;
  bool _showProductSearchLoader;

  ///PROVIDES SYNC_MASTER TABLE CRUD OPERATIONS
  SyncMasterDBHelper _syncMasterDBHelper = SyncMasterDBHelper();

  String searchFieldContent;
  String searchBy;

  ///API PARAMETERS FOR THE PAGINATION PURPOSE
  int pageNumber;
  int pageSize;
  List<ProductQuantity> currentProductList;
  List<String> selectedProductList;

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

  int recordCount;
  int lastPageNumber;
  bool loadcurrentProductList; //to assing current product list details
  @override
  void initState() {
    super.initState();
    isLocalDataSynced = false;
    _commonWidgets = CommonWidgets();
    _productDBHelper = ProductDBHelper();
    _products = List<Product>();
    _showProductSearchLoader = true;
    isDataRemaining = true;
    pageNumber = 1;
    lastPageNumber = 0;
    pageSize = Pagination.LOOKUP_PAGE_SIZE;
    searchFieldContent = widget.searchContent;
    searchBy = widget.searchBy;
    ProductQuantityList = widget.ProductQuantityList;
    currentProductList = List<ProductQuantity>();

    isNextButtonDisabled = false;
    isPreviousButtonDisabled = true; //Initialy on 1 page
    isFirstPageButtonDisabled = true;
    isShowPaginationButtons = false;

    recordCount = 0;
    loadcurrentProductList = false;
    //Store in list
    // handleWMAPIProductDataInsert();
    OfflineDataSyncsStatus();
  }

  @override
  void dispose() {
    super.dispose();
  }

  ///THIS FUNCTION HANDLES THE PRODUCTS DATA INSERT FROM API TO THE LOCAL_DB
  Future handleWMAPIProductDataInsert() async {
    try {
      List<SyncMaster> _syncMasters =
          await _syncMasterDBHelper.getAllSyncMasters();
      String apiDomain = await Session.getData(Session.apiDomain);
      String accessToken = await Session.getData(Session.accessToken);

      SyncMaster productSyncMaster = _syncMasters.firstWhere(
          (element) => element.TableName == _productDBHelper.tableName);

      String _lastSyncDateUTCForSave = await ApiService.getCurrentDateTime(
          tokenValue: accessToken, apiDomain: apiDomain);

      if (_lastSyncDateUTCForSave != 'ERROR') {
        List<Product> apiProductsRes = await _productDBHelper.fetchProducts(
          lastSyncDate: productSyncMaster.LastSyncDate,
          tokenValue: accessToken,
          apiDomain: apiDomain,
        );

        if (apiProductsRes.length > 0) {
          Database _db = await DBProvider.db.database;
          if (_db != null) {
            var addProductsRes =
                await _productDBHelper.addProducts(apiProductsRes);
            print('Products Insert into Local Database is successful!');

            var lastSyncDateUpdateRes =
                await _syncMasterDBHelper.updateMasterTableLastSyncDateByName(
              lastSyncDate: _lastSyncDateUTCForSave,
              masterTableName: _productDBHelper.tableName,
            );
            print('Product Table LastSyncDate Updated Response ');

            dataFetch();
            return Future.value(true);
          } else {
            print('Database Object not found for local insertion ');
            dataFetch();
            return Future.value(true);
          }
        } else {
          print('Products Data not found ');
          var lastSyncDateUpdateRes =
              await _syncMasterDBHelper.updateMasterTableLastSyncDateByName(
            lastSyncDate: _lastSyncDateUTCForSave,
            masterTableName: _productDBHelper.tableName,
          );

          dataFetch();
          return Future.value(true);
        }
      } else {
        print(
            'Product Last_Sync_Date not availabe to update locally so cancelling the Products sync');
        dataFetch();
        return Future.value(true);
      }
    } catch (e) {
      print('Error inside handleWMAPIProductDataInsert function ');
      print(e);
      dataFetch();
      return Future.value(false);
    }
  }

  Future<void> OfflineDataSyncsStatus() async {
    try {
      recordCount = await _productDBHelper.getProductCount('');
      lastPageNumber = (recordCount / pageSize).ceil();
      if (recordCount > 0) {
        setState(() {
          isLocalDataSynced = true;
          print('isLocalDataSynced $isLocalDataSynced');
          //handleWMAPIProductDataInsert();
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
      String strWhereClause = '';
      if (searchBy == "ProductKey") {
        strWhereClause = " and ProductKey='$searchFieldContent'";
      } else if (searchBy == "ProductCode") {
        strWhereClause =
            " and ProductCode LIKE '${'%' + searchFieldContent + '%'}'";
      } else if (searchBy == "ProductCategory") {
        strWhereClause =
            " and ProductCategory LIKE '${'%' + searchFieldContent + '%'}'";
      } else if (searchBy == "ProductDescription") {
        strWhereClause =
            " and ProductDescription LIKE '${'%' + searchFieldContent + '%'}'";
      }
      print('Product Query: $strWhereClause');
      recordCount = await _productDBHelper.getProductCount(strWhereClause);
      lastPageNumber = (recordCount / pageSize).ceil();
      print('Record Count $recordCount');
      print('lastPageNumber $lastPageNumber');
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
        searchBy: searchBy,
        searchText:
            (searchFieldContent != null && searchFieldContent.trim().length > 0)
                ? searchFieldContent
                : '',
      );
      if (productData.length < 1) {
        setState(() {
          _showProductSearchLoader = false;
        });
      }
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
      productQuantityTextEditingController.clear(); //initilise on new page
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
              loadcurrentProductList = true;
            }),
          });
    }
  }

  ///It returns the Product Value widget
  Widget getListValueWidget(textContent, type) {
    return Text(
      '$textContent',
      textAlign: TextAlign.start,
      style: TextStyle(
        color: type == 1 ? AppColors.blue : AppColors.black,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    );
  }

  ///It returns the Quantity box
  Widget getQuantityBoxWidget(position, String ProductCode) {
    //To dispaly saved quantity
    if (loadcurrentProductList == true) {
      if (currentProductList.isNotEmpty) {
        var product = currentProductList.firstWhere(
            (e) => e.ProductObject.ProductCode == ProductCode,
            orElse: () => null);
        if (product != null && product.Quantity != null) {
          productQuantityTextEditingController[position].text =
              product.Quantity.toString();
        } else {
          productQuantityTextEditingController[position].text = '';
        }
      }
    }

    return SizedBox(
      width: 60,
      child: Card(
        borderOnForeground: true,
        elevation: 4,
        child: Center(
          child: TextFormField(
            controller: productQuantityTextEditingController[position],
            inputFormatters: <TextInputFormatter>[
              WhitelistingTextInputFormatter.digitsOnly, //To accept digit only
            ],
            keyboardType: TextInputType.number,
            obscureText: false,
            textAlign: TextAlign.center,
            maxLength: 10,
            onChanged: (text) {
              if (text != null && text != "0") {
                text = text.replaceAll(new RegExp(r'[^0-9]'), '');
                setState(() {
                  loadcurrentProductList = false;
                  currentProductList.removeWhere((element) =>
                      element.ProductObject.ProductCode ==
                      _products[position].ProductCode);
                  currentProductList.add(
                      ProductQuantity(_products[position], int.parse(text)));
                });
              }
            },
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
              counterText: '',
              hintText: '0',
              border: InputBorder.none,
              labelStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  ///IT BUILDS THE PRODUCTS_LIST FOR THE SELECTION
  Widget _buildList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: ScrollPhysics(),
      itemCount: _products.length,
      itemBuilder: (context, position) {
        productQuantityTextEditingController.add(new TextEditingController(text: ''));
        return Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(2.0)),
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        flex: 2,
                        child: getListValueWidget(
                            _products[position].ProductCode, 1),
                      ),
                      Expanded(
                        flex: 1,
                        child: getQuantityBoxWidget(
                            position, _products[position].ProductCode),
                      ),
                    ]),
                getListValueWidget(
                    '${Other().parseHtmlString(_products[position].Description)}',
                    2),
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
      title: Text('Product List'),
      actionsPadding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
      insetPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      actionsOverflowDirection: VerticalDirection.down,
      actions: <Widget>[
        Visibility(
          visible: isShowPaginationButtons,
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
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            RaisedButton(
              onPressed: _products.length < 1
                  ? null
                  : () {
                      int count = currentProductList.length;
                      if (count > 0) {
                        currentProductList.forEach((Product) {
                          //remove if exist
//                ProductQuantityList.removeWhere((element) =>
//                element.ProductObject.ProductCode ==
//                    Product.ProductObject.ProductCode);
                          //Add new
                          ProductQuantityList.add(ProductQuantity(
                              Product.ProductObject, Product.Quantity));
                        });
                        Navigator.of(context, rootNavigator: true)
                            .pop('PopupClosed');
                      } else {
                        _commonWidgets.showAlertMsg(
                            alertMsg:
                                "Please enter at least single product's Quantity",
                            context: context,
                            MessageType: AlertMessageType.INFO);
                      }
                    },
              child: Text(
                'Add To Cart',
                style: TextStyle(color: Colors.white),
              ),
              color: AppColors.blue,
            ),
            SizedBox(
              width: 8,
            ),
            RaisedButton(
              onPressed: () {
                widget.closeSearchDialog();
                Navigator.of(context, rootNavigator: true).pop('PopupClosed');
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.white),
              ),
              color: AppColors.blue,
            ),
          ],
        ),
      ],
      content: Container(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  Visibility(
                    visible: !isLocalDataSynced,
                    child: Text(
                        BackgroundServiceHelper.SYNC_INITIAL_LOOKUPS_DATA_MSG),
                  ),

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
