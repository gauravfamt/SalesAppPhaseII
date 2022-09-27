import 'dart:async';

import 'package:flutter/material.dart';
import 'package:moblesales/helpers/index.dart';
import 'package:moblesales/models/index.dart';
import 'package:moblesales/screens/index.dart';
import 'package:moblesales/utils/index.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class InventoryScreen extends StatelessWidget {
  InventoryScreen({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return (MaterialApp(
      debugShowCheckedModeBanner: false,
      home: InventoryScreenPage(
        parentBuildContext: context,
      ),
    ));
  }
}

class InventoryScreenPage extends StatefulWidget {
  final BuildContext parentBuildContext;

  InventoryScreenPage({
    Key key,
    @required this.parentBuildContext,
  }) : super(key: key);

  @override
  InventoryScreenPageState createState() => InventoryScreenPageState();
}

class InventoryScreenPageState extends State<InventoryScreenPage> {
  CommonWidgets _commonWidgets;

  ///TO FETCH THE ERP VALUES
  StandardDropDownFieldsDBHelper _standardDropDownFieldsDBHelper;

  ///HOLDS ERP DROPDOWN FIELD
  StandardDropDownField _standardERPDropDownField;

  ///USED TO HANDLE THE FULLSCREEN_LOADER JUST SET THE STATE TO THE TRUE TO START
  bool isFullScreenLoading;

  bool isDataRemaining;

  bool isShowLoader;
  int pageNumber;

  int pageSize;

  String strMsg = '';

  List<InventoryData> InventoryList = List<InventoryData>();
  List<Inventory> _fetchedInventoryData = List<Inventory>();

  Product _fromSelectedProduct = Product();
  Product _toSelectedProduct = Product();
  ProductDBHelper _productDBHelper;
  String _salesSite;
  String Products = '';
  bool isLargeScreen;

  TextEditingController tecFromProduct;
  TextEditingController tecToProduct;

  ///NETWORK_CONNECTION STREAM SUBSCRIPTION TO GET UPDATES WHEN APP IS ONLINE OR OFFLINE
  StreamSubscription _connectionChangeStream;

  bool isOffline = false;

  @override
  void initState() {
    super.initState();
    isDataRemaining = true;
    isShowLoader = false;

    pageNumber = 1;
    pageSize = Pagination.LIST_PAGE_SIZE;
    InventoryList = new List<InventoryData>();
    _fetchedInventoryData = new List<Inventory>();
    _productDBHelper = ProductDBHelper();
    _commonWidgets = CommonWidgets();
    isFullScreenLoading = false;
    _standardDropDownFieldsDBHelper = StandardDropDownFieldsDBHelper();
    _standardERPDropDownField = StandardDropDownField();
    _salesSite = '';
    tecFromProduct = TextEditingController();
    tecToProduct = TextEditingController();

    ConnectivityService connectionStatus = ConnectivityService.getInstance();
    _connectionChangeStream =
        connectionStatus.connectionChange.listen(connectionChanged);
    isOffline = ConnectionStatus.isOffline;
    fetchERPDropDownValue();
    fetchSalesSite();
  }

  void connectionChanged(dynamic hasConnection) {
    setState(() {
      isOffline = !hasConnection;
    });
    if (isOffline == true) {
      _commonWidgets.showFlutterToast(
          toastMsg: ConnectionStatus.NetworkNotAvailble);
    } else {
      _commonWidgets.showFlutterToast(
          toastMsg: ConnectionStatus.NewtworkRestored);
    }
    ConnectionStatus.isOffline = isOffline;
  }

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
                    print('ERP ${_standardERPDropDownField.Code}');
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

  ///It returns the Product Value widget
  void fetchSalesSite() {
    try {
      setState(() async {
        _salesSite = await Session.getSalesSiteCode();
        print('Sales Site $_salesSite');
      });
    } catch (e) {}
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

  Widget getStockWidget(String stock) {
    return Text(
      '$stock',
      textAlign: TextAlign.end,
      style: TextStyle(
        color: Colors.black,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  InputDecoration getFormTFInputDecoration(String label) {
    return InputDecoration(
      contentPadding: EdgeInsets.fromLTRB(5, 10, 5, 10),
      labelText: '$label',
      border: InputBorder.none,
      labelStyle: TextStyle(
        color: Colors.blue,
        height: 0.5,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  final TextStyle _formTFTextStyle = TextStyle(
    color: AppColors.black,
    fontFamily: 'OpenSans',
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  Widget getProductLookupTF(
      {String label,
      TextEditingController txtEdtCntrlr,
      int quoteDetailPosition,
      int quoteDetailFieldPosition,
      Product objProduct}) {
    return Card(
      child: TextFormField(
        decoration: getFormTFInputDecoration('$label'),
        style: _formTFTextStyle,
        readOnly: true,
        controller: txtEdtCntrlr,
        onTap: () {
          showDialog(
            useRootNavigator: true,
            barrierDismissible: false,
            context: context,
            builder: (context) => ProductSearchDialog(
              handleProductSelectedSearch:
                  (Product productObj, int quotePosition) {
                setState(() {
                  print('${productObj.ProductCode}');
                  txtEdtCntrlr.text = productObj.ProductCode;
                  objProduct = productObj;
                });
              },
              closeSearchDialog: this.closeSearchDialog,
              recordPosition: quoteDetailPosition,
              forLookupType: true,
            ),
          );
        },
      ),
    );
  }

  Widget FromAndToProduct() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: getProductLookupTF(
            label: 'From Product',
            txtEdtCntrlr: tecFromProduct,
            objProduct: _fromSelectedProduct,
          ),
        ),
        SizedBox(
          width: 2,
        ),
        Expanded(
          child: getProductLookupTF(
            label: 'To Product',
            txtEdtCntrlr: tecToProduct,
            objProduct: _toSelectedProduct,
          ),
        ),
        SizedBox(
          width: 2,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 0.0),
          child: SizedBox(
            width: 40.0,
            child: RaisedButton(
              padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
              color: AppColors.blue,
              onPressed: () {
                if (tecFromProduct.text != '' || tecToProduct.text != '') {
                  isOffline == true
                      ? _commonWidgets.showFlutterToast(
                          toastMsg: ConnectionStatus.NetworkNotAvailble)
                      : loadNewSearchData();
                } else {
                  _commonWidgets.showAlertMsg(
                      alertMsg: 'Please select product',
                      context: context,
                      MessageType: AlertMessageType.INFO);
                }
              },
              child: Icon(Icons.search, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: ScrollPhysics(),
      itemCount: InventoryList.length,
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
                getListValueWidget(
                    InventoryList[position].ProductObject.ProductCode, 1),
                getListValueWidget(
                    '${InventoryList[position].ProductObject.Description}', 2),
                SizedBox(
                  height: 5.0,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Text('On Hand',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        )),
                    Expanded(
                      child: getStockWidget(
                          InventoryList[position].QtyOnHand.toString()),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Text('After Order',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        )),
                    Expanded(
                      child: getStockWidget(
                          InventoryList[position].QtyAfterOrder.toString()),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Text('After Allocation',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        )),
                    Expanded(
                      child: getStockWidget(InventoryList[position]
                          .QtyAfterAllocation
                          .toString()),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildListForTab() {
    return ListView.builder(
      shrinkWrap: true,
      physics: ScrollPhysics(),
      itemCount: InventoryList.length,
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
                getListValueWidget(
                    InventoryList[position].ProductObject.ProductCode, 1),
                getListValueWidget(
                    '${InventoryList[position].ProductObject.Description}', 2),
                SizedBox(
                  height: 7.0,
                ),
                SizedBox(
                  height: 7.0,
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(2.0)),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Column(
                            children: <Widget>[
                              Center(
                                child: Text(
                                  "On Hand",
                                ),
                              ),
                              getListValueWidget(
                                  InventoryList[position].QtyOnHand, 2),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 2.0,
                    ),
                    Expanded(
                      flex: 1,
                      child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(2.0)),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Column(
                            children: <Widget>[
                              Center(
                                child: Text(
                                  "After Order",
                                ),
                              ),
                              getListValueWidget(
                                  InventoryList[position].QtyAfterOrder, 2),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 2.0,
                    ),
                    Expanded(
                      flex: 1,
                      child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(2.0)),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Column(
                            children: <Widget>[
                              Center(
                                child: Text(
                                  "After Allocation",
                                ),
                              ),
                              getListValueWidget(
                                  InventoryList[position].QtyAfterAllocation,
                                  2),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void closeSearchDialog() {
    print('Lookup Dialog closed');
  }

  Future<void> fetchInventoryData() async {
    try {
      print('fetching Inventory Data');
      String productCodes = '';
      String strProcuctData = '';
      String requestBody = '{';
      requestBody += '"SalesSite" : "${_salesSite}",';
      requestBody += '"ProductList" : [';
      if (tecFromProduct != null && tecFromProduct.text != '') {
        strProcuctData += '{';
        strProcuctData += '"ProductCode" : "${tecFromProduct.text}"';
        strProcuctData += '}';
      }
      if (tecToProduct != null && tecToProduct.text != '') {
        if (strProcuctData != '') {
          strProcuctData += ',{';
          strProcuctData += '"ProductCode" : "${tecToProduct.text}"';
          strProcuctData += '}';
        } else {
          strProcuctData += '{';
          strProcuctData += '"ProductCode" : "${tecToProduct.text}"';
          strProcuctData += '}';
        }
      }
      requestBody += strProcuctData;
      requestBody += ']';
      requestBody += '}';
      if (strProcuctData != '') {
        print('Request Bodys: $requestBody');
        ApiService.getStock(
          erpName: _standardERPDropDownField.Code,
          requestBody: requestBody,
        )
            .then((value) => {
                  // print(value),
                  if (!value.toString().contains('Error'))
                    {
                      // print('Got Response:${value}'),
                      if (value != null)
                        {
                          setState(() {
                            _fetchedInventoryData.addAll(value);
                          }),
                        },
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
                })
            .catchError((e) => {
                  print('Inventory  Error Response $e'),
                });
        return productCodes;
      }
    } catch (e) {
      print('Error inside prepareInventoryData Response ');
      print(e);
    }
  }

  Future<List<InventoryData>> preperInventoryData() async {
    try {
      var productCodes = '';
      var inventoryData = List<InventoryData>();
      var productData = List<Product>();
      for (int i = 0; i < _fetchedInventoryData.length; i++) {
        if (productCodes == '') {
          productCodes = "'${_fetchedInventoryData[i].ProductCode.toString()}'";
        } else {
          productCodes +=
              ",'${_fetchedInventoryData[i].ProductCode.toString()}'";
        }
      }
      // print('Product Codes $productCodes');
      productData = await _productDBHelper.getProductsDetailsForInventory(
        productCodes: productCodes,
      );
      // print('Length: ${productData.length}');
      for (int i = 0; i < productData.length; i++) {
        var requiredData = _fetchedInventoryData.firstWhere(
            (e) => e.ProductCode == productData[i].ProductCode,
            orElse: () => null);
        if (requiredData != null) {
          inventoryData.add(new InventoryData(
              productData[i],
              int.parse(requiredData.QtyOnHand.toString()),
              int.parse(requiredData.QtyAfterOrder.toString()),
              int.parse(requiredData.QtyAfterAllocation.toString())));
        }
      }
      return inventoryData;
    } catch (e) {
      print('Error inside prepareInventoryData Response ');
      print(e);
    }
  }

  void loadNewSearchData() {
    setState(() {
      InventoryList.clear();
      _fetchedInventoryData.clear();
      pageNumber = 1;
      isDataRemaining = true;
      isShowLoader = true;
    });
    fetchInventoryData();
  }

  void dataFetch() {
    print('dataFetch $isDataRemaining');
    if (isDataRemaining) {
      preperInventoryData().then((inventoryData) => {
            setState(() {
              pageNumber = pageNumber + 1; //<--To get next record set
              int newRecordCount = inventoryData.length;
              InventoryList.addAll(inventoryData);
              InventoryList.sort((a, b) => a.ProductObject.ProductCode
                  .compareTo(b.ProductObject.ProductCode));
              isShowLoader = false;

              if (newRecordCount < pageSize) {
                isDataRemaining = false;
              }
            }),
          });
    } else {
      setState(() {
        isShowLoader = false;
      });
      _commonWidgets.showFlutterToast(toastMsg: 'No more data');
    }
  }

  @override
  Widget build(BuildContext context) {
    isLargeScreen = isLargeScreenAvailable(context);
    return ModalProgressHUD(
      inAsyncCall: isFullScreenLoading,
      opacity: FullScreenLoader.OPACITY,
      progressIndicator: FullScreenLoader.PROGRESS_INDICATOR,
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppBarTitles.INVENTORY),
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(widget.parentBuildContext);
              }),
        ),
        body: Container(
          padding: const EdgeInsets.all(17.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              FromAndToProduct(),
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    SizedBox(height: 5.0),

                    ///FIRST TIME LOADING DATA LOADER
                    _commonWidgets.showCommonLoader(
                        isLoaderVisible: isShowLoader),

                    ///IT SHOWS THE NO DATA PRESENT MESSAGE
                    _commonWidgets.buildEmptyDataWidget(
                      textMsg: 'No data found',
                      isVisible: InventoryList.length < 1 && !isShowLoader,
                    ),

                    ///BUILDS INVOICES LIST
                    ///
                    isLargeScreen ? _buildListForTab() : _buildList(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
