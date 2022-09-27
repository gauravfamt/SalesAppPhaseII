import 'dart:convert';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:moblesales/helpers/index.dart';
import 'package:moblesales/models/index.dart';
import 'package:moblesales/screens/index.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class ProductScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return (MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ProductScreenPage(parentBuildContext: context),
    ));
  }
}

class ProductScreenPage extends StatefulWidget {
  final TargetPlatform platform;

  final BuildContext parentBuildContext;
  ProductScreenPage({this.platform, Key key, @required this.parentBuildContext})
      : super(key: key);
  @override
  ProductScreenPageState createState() => ProductScreenPageState();
}

class ProductScreenPageState extends State<ProductScreenPage> {
  ///HELPS TO BUILD THE LIST_VIEW_ROWS
  ListViewRowsHelper _listViewRowsHelper;

  bool isLargeScreen;

  ///HOLDS THE CURRENCY_CAPTION STANDARD FIELD
  StandardDropDownField _currencyCaption;

  ///IT HOLDS ALL THE COMMON REUSABLE WIDGETS WHICH CAN BE USED THROUGH OUT PROJECT
  CommonWidgets _commonWidgets;

  ///HOLDS THE ERROR CAPTION FOR THE IMAGE
  String imgErrorCaption = 'No Preview Available!';

  ///HOLDS IMAGE HEIGHT
  double imageHeight = 200.0;

  ///USED TO HANDLE THE FULLSCREEN_LOADER JUST SET THE STATE TO THE TRUE TO START
  bool isFullScreenLoading;

  ///HOLDS THE ALL PRODUCTS LIST
  List<Product> products;

  ///HOLDS ALL THE PRODUCTS LIST WHICH ARE SELECTED FOR THE SEND_MAIL
  List<Product> sendMailProductsList;

  ///HOLDS ON_GRID STANDARD_FIELDS FOR THE PRODUCT ENTITY
  List<StandardField> onGridStandardFields;

  ///HOLDS ON_SCREEN STANDARD_FIELDS FOR THE PRODUCT ENTITY
  List<StandardField> onScreenStandardFields;

  ///HANDLES THE SEARCH_TEXT_FIELD CONTENT
  String searchFieldContent;

  ///TO CONFIGURE VISIBILITY OF SEARCH LOADER DISPLAY BELOW SEARCH PANEL
  bool isShowLoader;

  ///API CALL PARAMETERS FOR THE PAGINATION
  int pageNumber;
  int pageSize;

  ///FIELDS WHICH NEEDED TO BE EXCLUDED WHILE DISPLAYING ON THE LIST FROM REFERRING STANDARD_FIELDS
  List<String> excludeStandardFields = ['Image'];

  ///NETWORK_CONNECTION STREAM SUBSCRIPTION TO GET UPDATES WHEN APP IS ONLINE OR OFFLINE
  StreamSubscription _connectionChangeStream;

  ///HOLDS APP ONLINE/OFFLINE STATUS
  bool isOffline = false;

  ///BARCODE INITIAL VALUE FOR SEARCH
  String _scannedBarcodeValue = 'Unknown';

  bool isNextButtonPressed;
  bool isPreviousButtonPressed;

  bool isNextButtonDisabled;
  bool isPreviousButtonDisabled;
  bool isShowPaginationButtons;
  int lastPageNumber;

  ///HANDLES SEARCH TEXT_FIELD DATA
  TextEditingController _searchTFController;

  bool isAllProductSelected;
  @override
  void initState() {
    super.initState();
    isShowLoader = true;
    pageNumber = 1;
    pageSize = Pagination.GRID_PAGE_SIZE;
    products = List<Product>();
    sendMailProductsList = List<Product>();
    onGridStandardFields = List<StandardField>();
    onScreenStandardFields = List<StandardField>();
    searchFieldContent = null;
    _listViewRowsHelper = ListViewRowsHelper();
    _commonWidgets = CommonWidgets();
    isFullScreenLoading = false;
    _currencyCaption = StandardDropDownField();
    _searchTFController = TextEditingController();

    isNextButtonDisabled = false;
    isPreviousButtonDisabled = true;
    isShowPaginationButtons = true;
    lastPageNumber = 0;
    isAllProductSelected = false;
    isOffline = ConnectionStatus.isOffline;

    ///GETTING CONNECTION_SERVICE SINGLETON INSTANCE AND SUBSCRIBING TO CONNECTION_CHANGE EVENTS
    ConnectivityService connectionStatus = ConnectivityService.getInstance();
    _connectionChangeStream =
        connectionStatus.connectionChange.listen(connectionChanged);
    fetchCurrencyStandardField();
    fetchOnGridStandardFields();
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

  ///SETS THE CONNECTION STATUS DEPENDING ON THE CONNECTION_SERVICE SUBSCRIPTION LISTEN EVENTS

  ///IT FETCHES THE CURRENCY STANDARD FIELD
  void fetchCurrencyStandardField() {
    ApiService.getCurrencyStandardDropdownFields()
        .then((value) => {
              if (value.length > 0)
                {
                  _currencyCaption = value[0],
                }
              else
                print('No StandardFields received for the Currency '),
            })
        .catchError((err) {
      print('Error while fetching Currency Standard fields');
      print(err);
    });
  }

  ///IT FETCHES THE STANDARD FIELDS FOR ON_GRID_SHOW FIELDS SHOW IN LIST UI
  void fetchOnGridStandardFields() {
    ApiService.getStandardFields(
      entity: StandardEntity.PRODUCT,
      showInGrid: true,
      showOnScreen: false,
    )
        .then((value) => {
              if (mounted)
                {
                  ///HERE CHECKING IF STANDARD FIELDS RESPONSE DID'T RECEIVED THEN NOT CALLING THE GET_DATA_API
                  if (value.length > 0)
                    {
                      value.sort((a, b) => a.SortOrder.compareTo(b.SortOrder)),
                      setState(() {
                        onGridStandardFields = value;
                      }),
                      dataFetch()
                    }
                  else
                    {
                      setState(() {
                        isShowLoader = false;
                      }),
                      _commonWidgets.showFlutterToast(
                          toastMsg: ConnectionStatus.NetworkNotAvailble),
                    }
                },
            })
        .catchError((onError) => {
              print(
                  'Error while fetching OnGrid StandardFields for the Product Entity'),
              print(onError),
              if (mounted)
                setState(() {
                  isShowLoader = false;
                }),
            });
  }

  ///IT FETCHES THE STANDARD FIELDS FOR ON_SCREEN_SHOW FIELDS SHOW IN DETAILS SCREEN UI
  void fetchOnScreenStandardFields({
    int recordPosition,
  }) {
    ApiService.getStandardFields(
      entity: StandardEntity.PRODUCT,
      showInGrid: false,
      showOnScreen: true,
    )
        .then((value) => {
              ///HERE CHECKING IF STANDARD FIELDS RESPONSE DID'T RECEIVED THEN NOT CALLING THE GET_DATA_API
              if (value.length > 0)
                {
                  value.sort((a, b) => a.SortOrder.compareTo(b.SortOrder)),
                  setState(() {
                    onScreenStandardFields = value;
                    isFullScreenLoading = false;
                  }),

                  ///NAVIGATING TO THE QUOTE_DETAILS PAGE
                  Navigator.of(widget.parentBuildContext).push(
                    MaterialPageRoute(
                      builder: (context) => ProductDetailsPage(
                        productObj: products[recordPosition],
                        detailsOnScreenStandardFields: onScreenStandardFields,
                        currencyCaptionSF: _currencyCaption,
                      ),
                    ),
                  ),
                }
              else
                {
                  handleDetailsAPIError(
                    toastMsg: 'Try Again Later!',
                  ),
                }
            })
        .catchError((onError) => {
              print(
                  'Error while fetching OnGrid StandardFields for the Product Entity'),
              print(onError),
              handleDetailsAPIError(
                toastMsg: 'Try Again Later!',
              ),
            });
  }

  ///HANDLES THE ERROR EVENTS FOR CLOSING THE LOADERS AND SHOWING THE TOASTS
  void handleDetailsAPIError({
    String toastMsg,
  }) {
    setState(() {
      isFullScreenLoading = false;
    });
    _commonWidgets.showFlutterToast(toastMsg: '$toastMsg');
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
      //Added by  Gaurav Gurav 22-01-2021
      //start
      if (Theme.of(context).platform == TargetPlatform.iOS) {
        setState(() {
          RecordCount = 0;
          searchFieldContent = barcodeScanRes;
          handleTextFieldSearch(searchFieldContent);
        });
        if (RecordCount == 0) {
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
      });
      handleTextFieldSearch(_scannedBarcodeValue);
    } else if (barcodeScanRes == BarcodeScanHelper.PLATFORM_VERSION_ERROR) {
      _commonWidgets.showFlutterToast(
          toastMsg:
              'Something went wrong while scanning barcode, Please Try again!');
    }
  }

  ///IT CALLS TEH API TO FETCH THE PRODUCTS LIST
  Future<List<Product>> fetchProducts() async {
    try {
      var productData = List<Product>();
      //added isCataloProduct=true, 23-02-2021
      String url =
          '${await Session.getData(Session.apiDomain)}/${URLs.GET_PRODUCTS}?isCatalogProduct=true&pageNumber=$pageNumber&pageSize=$pageSize';
      if (searchFieldContent != null && searchFieldContent.trim().length > 0) {
        url = '$url&Searchtext=${searchFieldContent.trim()}';
      }
      print('$url');
      http.Client client = http.Client();
      final response = await client.get(url, headers: {
        "token": await Session.getData(Session.accessToken)
      }).timeout(duration);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        productData =
            data.map<Product>((json) => Product.fromJson(json)).toList();
      }
      return productData;
    } catch (e) {
      print('Erro inside fetchProducts FN');
      print(e);
      throw Future.error(e);
    }
  }

  ///IT CALLS THE FETCH_PRODUCTS FN FOR GETTING DATA THROUGH API AND ALSO HANDLES THE PAGINATION
  int RecordCount = 0;
  void dataFetch() {
//      if(isNextButtonPressed==true){
//        if(pageNumber==1){
//          pageNumber=pageNumber+1;
//        }
//        pageNumber = pageNumber + 1;
//        print('On Next pageNumber $pageNumber');
//      }
//      else if(isPreviousButtonPressed==true){
//          print('On Prev pageNumber $pageNumber');
//          if(pageNumber>1){
//            pageNumber = pageNumber - 1;
//            print('After Prev pageNumber $pageNumber');
//            if(pageNumber==2){
//              isPreviousButtonDisabled=true;
//            }
//          }
//      }
    if (isNextButtonPressed == true && lastPageNumber != pageNumber) {
      pageNumber = pageNumber + 1;
    } else if (isPreviousButtonPressed == true) {
      if (pageNumber > 1) {
        pageNumber = pageNumber - 1;
        if (pageNumber == 1) {
          isPreviousButtonDisabled = true;
        }
      }
    }
    fetchProducts()
        .then((productDataRes) => {
              setState(() {
                //  pageNumber = pageNumber + 1; //<--To get next record set
                RecordCount = productDataRes.length;
                products.clear();
                products.addAll(productDataRes);
                isShowLoader = false;
                if (RecordCount < pageSize) {
                  lastPageNumber = pageNumber;
                  isNextButtonDisabled = true;
                  if (isPreviousButtonDisabled == true) {
                    isShowPaginationButtons = false;
                  } else {
                    isShowPaginationButtons = true;
                  }
                } else {
                  isShowPaginationButtons = true;
                  lastPageNumber = 0;
                  isNextButtonDisabled = false;
                }
                //Configure checkbox on pagination
                int selctedProductCount = 0;
                if (sendMailProductsList != null &&
                    products != null &&
                    sendMailProductsList.length > 0 &&
                    products.length > 0) {
                  for (int i = 0; i < products.length; i++) {
                    var product = sendMailProductsList.firstWhere(
                        (e) => e.ProductCode == products[i].ProductCode,
                        orElse: () => null);
                    if (product != null) {
                      selctedProductCount = selctedProductCount + 1;
                      products[i].isSelected = true;
                    } else {
                      products[i].isSelected = false;
                    }
                  }
                }
                if (selctedProductCount == products.length) {
                  isAllProductSelected = true;
                } else {
                  isAllProductSelected = false;
                }
              })
            })
        .catchError((onError) => {
              setState(() {
                isShowLoader = false;
              }),
            });
  }

  ///IT HANDLES THE SEARCH_TEXT_FIELD CLICK EVENT CHANGES AND LOADS THE NEW DATA ACCORDINGLY
  void handleTextFieldSearch(String searchText) {
    setState(() {
      searchFieldContent = searchText;
    });
    loadNewSearchData();
  }

  ///It handles the SearchTextField Cancel/Clear click changes and Loads the new data accordingly
  void clearTextFieldSearch() {
    setState(() {
      searchFieldContent = '';
    });
    loadNewSearchData();
  }

  ///It clears the common search states and loads new data as per the search parameters
  void loadNewSearchData() {
    setState(() {
      products.clear(); //= List<SalesOrders>();
      pageNumber = 1;
      isShowLoader = true;
      isNextButtonPressed = false;
      isPreviousButtonPressed = false;
      isNextButtonDisabled = false;
      isPreviousButtonDisabled = true;
      lastPageNumber = 0;
    });
    dataFetch();
  }

  ///IT RETURNS THE SINGLE PRODUCT ROW CONTAINING OF THE IMAGE AND THE PRODUCT STANDARD_FIELDS
  Widget getProductSingleRow({
    int recordPosition,
  }) {
    ///HERE LIST_VIEW_ROWS COMMON CODE IS NOT USED FOR LIST_VIEW AS HERE IMAGES ALSO NEEDS To BE DISPLAYED
    return getColumnCardView(
      recordPosition: recordPosition,
    );

//    return getRowCardView(
//      recordPosition: recordPosition,
//    );
  }

  ///It handles the Details Page Navigation
  void handleDetailsPageNavigation(int recordPosition) {
    ///SETTING SHOW LOADING STATE TRUE FOR DETAILS PAGE STATE
    setState(() {
      isFullScreenLoading = true;
      onScreenStandardFields = List<StandardField>();
    });

    ///FETCHING THE STANDARD_FIELDS FOR THE DETAILS PAGE ON_GRID FIELDS DISPLAY
    fetchOnScreenStandardFields(
      recordPosition: recordPosition,
    );
  }

  ///IT RETURNS TEH ACTIONS BUTTONS FOR THE LIST VIEW
  /// NOTE: HERE AS IT WILL BE DISPLAYED IN LIST VIEW
  ///       KEEP ONLY TWO BUTTONS INSIDE THE SINGLE ROW
  ///       OTHERWISE IT'LL LOOK CONGESTED IN THE LIST VIEW
  List<Row> getActionButtonRows({
    int recordPosition,
  }) {
    List<Row> rowsList = List<Row>();

    ///ADDING THE FIRST ROW WITH ONE BUTTON FOR THE NAVIGATION
    rowsList.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          _listViewRowsHelper.getActionButton(
            'View Details',
            recordPosition,
            handleDetailsPageNavigation,
            AppColors.blue,
          ),
        ],
      ),
    );
    return rowsList;
  }

  void handleCheckBoxOnChange(bool isCheckedValue, int rowPosition) {
    List<Product> tempSendMailProductsList = List<Product>();
    setState(() {
      products[rowPosition].isSelected = isCheckedValue;
      if (isCheckedValue) {
        ///ADDING SELECTED QUOTE TO SEND_MAIL_LIST
        sendMailProductsList.add(products[rowPosition]);
      } else {
        ///REMOVING DESELECTED PRODUCT FROM THE SEND_MAIL_LIST
        sendMailProductsList.forEach((singleSalesOrderList) {
          if (singleSalesOrderList.ProductCode !=
              products[rowPosition].ProductCode)
            tempSendMailProductsList.add(singleSalesOrderList);
        });
        sendMailProductsList.clear();

        ///ADDING THE UPDATED SALES_QUOTE_SEND_MAIL_LIST
        if (tempSendMailProductsList.length > 0)
          sendMailProductsList.addAll(tempSendMailProductsList);
      }
    });
  }

  ///ITE BUILDS THE LISTING VIEW IN COLUMN_LIST_VIEW FORMAT
  ///IF ROW_LIST VIEW IS NOT NEEDED THEN USE THE THIS CODE IN getProductSingleRow FN
  Widget getColumnCardView({
    int recordPosition,
  }) {
    return Card(
      color: products[recordPosition].isSelected
          ? Colors.grey
              .shade200 //IF CHECKBOX VISIBLE AND SELECTED THEN GREY SHADE COLOR
          : Colors.white,
      child: ListTile(
        contentPadding: EdgeInsets.all(0.0),
        title: Column(
          children: <Widget>[
            Container(
              alignment: Alignment.centerLeft,
              child: Checkbox(
                activeColor: AppColors.blue,
                value: products[recordPosition].isSelected,
                onChanged: (isChecked) {
                  handleCheckBoxOnChange(
                    isChecked,
                    recordPosition,
                  );
                },
              ),
            ),

            ///BINDING THE IMAGE AND ALSO PREVIEW ERROR TEXT IF IMAGE NOT AVAILABLE
            products[recordPosition].Image != null
                ? _commonWidgets.getNetworkImageWidget(
                    imgURL: products[recordPosition].Image,
                    imgHeight: imageHeight,
                    errorCaption: imgErrorCaption,
                  )
                : Image.asset(
                    'assets/img/no_img_cropped.png',
                    height: 150,
                    width: 150,
                  ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
              child: Column(children: [
                Row(
                  children: <Widget>[
//                    Expanded(
//                      flex: 1,
//                      child: Padding(
//                        padding: const EdgeInsets.fromLTRB(15.0, 0.0, 0.0, 0.0),
//                        child: Checkbox(
//                          activeColor: AppColors.blue,
//                          value: products[recordPosition].isSelected,
//                          onChanged: (isChecked) {
//                            handleCheckBoxOnChange(
//                              isChecked,
//                              recordPosition,
//                            );
//                          },
//                        ),
//                      ),
//                    ),
                    Expanded(
//                      flex: 15,
                      child: InkWell(
                        onTap: () {
                          handleCheckBoxOnChange(
                            !products[recordPosition].isSelected,
                            recordPosition,
                          );
                        },
                        child: Column(
                          children: <Widget>[
                            ..._listViewRowsHelper.getRowCardContents(
                              classObj: products[recordPosition],
                              isEntitySectionCheckDisabled: true,
                              showOnGridFields: true,
                              standardFields: onGridStandardFields,
                              isExcludedFieldEnabled: true,
                              excludedFieldsList: excludeStandardFields,
                              currencyCaption: _currencyCaption.Caption,
                              isProfile: false,
                              isProduct: true,
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
//                ..._listViewRowsHelper.getRowCardContents(
//                  classObj: products[recordPosition],
//                  isEntitySectionCheckDisabled: true,
//                  showOnGridFields: true,
//                  standardFields: onGridStandardFields,
//                  isExcludedFieldEnabled: true,
//                  excludedFieldsList: excludeStandardFields,
//                  currencyCaption: _currencyCaption.Caption,
//                ),
                ///COMMENTED AS VIEW_DETAILS NOT NEEDED FOR THE PRODUCTS CATALOGUE PAGE
//                Divider(
//                  thickness: 2.0,
//                  color: AppColors.grey,
//                ),
//                ...getActionButtonRows(
//                  recordPosition: recordPosition,
//                )
              ]),
            ),
          ],
        ),
      ),
    );
  }

  ///ITE BUILDS THE LISTING VIEW IN ROWS_ LIST_VIEW FORMAT
  ///IF COLUMN_LIST VIEW IS NOT NEEDED THEN USE THE THIS CODE IN getProductSingleRow FN
  Widget getRowCardView({
    int recordPosition,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0),
        child: ListTile(
          title: Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Image.network(
//                    'https://images-na.ssl-images-amazon.com/images/I/81PLqxtrJ3L._SX466_.jpg'
//                  'https://i.dell.com/sites/csimages/Video_Imagery/all/xps_7590_touch.png',
                    'https://cdn.mos.cms.futurecdn.net/ahevYTh9pWRzkNPF85MQhb.jpg'),
              ),
              Expanded(
                flex: 3,
                child: Column(
                  children: _listViewRowsHelper.getRowCardContents(
                    classObj: products[recordPosition],
                    isEntitySectionCheckDisabled: true,
                    showOnGridFields: true,
                    standardFields: onGridStandardFields,
                    isExcludedFieldEnabled: true,
                    excludedFieldsList: excludeStandardFields,
                    currencyCaption: _currencyCaption.Caption,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ///BUILDS PRODUCTS LIST
  Widget _buildList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: ScrollPhysics(),
      itemCount: products.length,
      padding: const EdgeInsets.all(15.0),
      itemBuilder: (context, position) {
        return getProductSingleRow(
          recordPosition: position,
        );
      },
    );
  }

  Widget _buildGrid() {
    return GridView.count(
      padding: const EdgeInsets.all(15.0),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      crossAxisCount: 3,
      physics: ScrollPhysics(), // to disable GridView's scrolling
      shrinkWrap: true,
      childAspectRatio: 0.5,
      children: List.generate(products.length, (index) {
        return getProductSingleRow(
          recordPosition: index,
        );
      }),
    );
  }

  void handleFeatureButtonClick() {
    if (sendMailProductsList.length < 1) {
      _commonWidgets.showAlertMsg(
          alertMsg: 'Select at least one product for sending mail',
          context: context,
          MessageType: AlertMessageType.INFO);
    } else if (isOffline == true) {
      _commonWidgets.showFlutterToast(
          toastMsg: ConnectionStatus.NetworkNotAvailble);
      resetSendMailData();
    } else {
      showSendMailDialog();
    }
  }

  Widget getFeatureButtonButtonWidget() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: RaisedButton(
              color: AppColors.blue,
              onPressed: () {
                handleFeatureButtonClick();
              },
              child: Text(
                'Send Mail',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  ///IT RESETS THE SEND_MAIL DATA
  void resetSendMailData() {
    setState(() {
      products.forEach((element) {
        element.isSelected = false;
      });
      sendMailProductsList.clear();
      isFullScreenLoading = false;
    });
  }

  ///IT SHOWS THE SEND_MAIL SCREEN
  void showSendMailDialog() {
    try {
      String idsData = '';
      sendMailProductsList.forEach((element) {
        idsData += '${element.ProductCode}|';
      });
      idsData = idsData.substring(0, idsData.lastIndexOf('|'));
      showDialog(
        useRootNavigator: true,
        barrierDismissible: false,
        context: context,
        builder: (context) => SendMailDialog(
          forType: SendMailHelper.TEMPLATE_PRODUCT,
          closeSearchDialog: () {},
          resetSendMailData: resetSendMailData,
          idsData: idsData,
        ),
      );
    } catch (e) {
      print('Error in showSendMailDialog fn inside for Products send mail ');
      print(e);
    }
  }

  void showRealTimePriceLookup() {
    try {
      showDialog(
        useRootNavigator: true,
        barrierDismissible: false,
        context: context,
        builder: (context) => ProductRealTimePriceLookup(
          closeSearchDialog: () {},
          resetSendMailData: resetSendMailData,
          productData: sendMailProductsList,
        ),
      );
    } catch (e) {
      print(
          'Error in showRealTimePriceLookup fn inside for Products send mail ');
      print(e);
    }
  }

  void handleProductRealTimePriceButtonClick() {
    if (sendMailProductsList.length < 1) {
      _commonWidgets.showAlertMsg(
          alertMsg: 'Select at least one product',
          context: context,
          MessageType: AlertMessageType.INFO);
    } else if (isOffline == true) {
      _commonWidgets.showFlutterToast(
          toastMsg: ConnectionStatus.NetworkNotAvailble);
      resetSendMailData();
    } else {
      showRealTimePriceLookup();
    }
  }

  Widget getRealTimePricingWidget() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 10.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: RaisedButton(
              color: AppColors.blue,
              onPressed: () {
                handleProductRealTimePriceButtonClick();
              },
              child: Text(
                'Get Real Time Pricing',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void handleCheckAll(bool isCheckedValue) {
    setState(() {
      if (isCheckedValue) {
        isAllProductSelected = true;
        for (int i = 0; i < products.length; i++) {
          products[i].isSelected = true;
          var data = sendMailProductsList.firstWhere(
              (element) => element.ProductCode == products[i].ProductCode,
              orElse: () => null);
          if (data == null) {
            sendMailProductsList.add(products[i]);
          }
        }
      } else {
        isAllProductSelected = false;
        for (int i = 0; i < products.length; i++) {
          products[i].isSelected = false;
        }
        if (sendMailProductsList.length == products.length) {
          sendMailProductsList = new List<Product>();
        } else {
          if (sendMailProductsList != null &&
              products != null &&
              sendMailProductsList.length > 0 &&
              products.length > 0) {
            for (int i = 0; i < products.length; i++) {
              var product = sendMailProductsList.firstWhere(
                  (e) => e.ProductCode == products[i].ProductCode,
                  orElse: () => null);
              sendMailProductsList.remove(product);
            }
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    isLargeScreen = isLargeScreenAvailable(context);
    return ModalProgressHUD(
      inAsyncCall: isFullScreenLoading,
      opacity: 0.5,
      progressIndicator: CircularProgressIndicator(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppBarTitles.PRODUCTS),
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(widget.parentBuildContext);
              }),
        ),

        ///NOTIFICATION LISTENER ADDED TO LISTEN TO THE BOTTOM PAGE SCROLL
        ///TO LOAD NEW PAGE DATA FROM API
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SearchTextField(
              searchFieldContent: searchFieldContent,
              clearTextFieldSearch: clearTextFieldSearch,
              handleTextFieldSearch: handleTextFieldSearch,
              showBarcodeScanner: true,
              searchTFController: _searchTFController,
              barcodeScannerHandler: scanBarcodeNormal,
              placeHolder: 'Search Product',
            ),

            ///IT BUILDS THE FEATURE WIDGET FOR SEND MAIL
            getFeatureButtonButtonWidget(),

            getRealTimePricingWidget(),
            Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Checkbox(
                    activeColor: AppColors.blue,
                    value: isAllProductSelected,
                    onChanged: (isChecked) {
                      handleCheckAll(
                        isChecked,
                      );
                    },
                  ),
                ),
                Expanded(
                  child: isAllProductSelected == true
                      ? Text("Deselect All")
                      : Text("Select All"),
                ),
                Expanded(
                    flex: 2,
                    child: sendMailProductsList.length > 0
                        ? Text(
                            '${sendMailProductsList.length} Product Selected',
                            textAlign: TextAlign.center,
                          )
                        : Text("")),
                Expanded(
                    child: sendMailProductsList.length > 0
                        ? FlatButton(
                            onPressed: () {
                              setState(() {
                                sendMailProductsList = new List<Product>();
                                handleCheckAll(
                                  false,
                                );
                              });
                            },
                            child: Text(
                              "Clear",
                              textAlign: TextAlign.end,
                            ),
                          )
                        : Text("")),
              ],
            ),
            Expanded(
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  ///FIRST TIME LOADING DATA LOADER
                  _commonWidgets.showCommonLoader(
                      isLoaderVisible: isShowLoader),

                  ///IT SHOWS THE NO DATA PRESENT MESSAGE
                  _commonWidgets.buildEmptyDataWidget(
                    textMsg: 'No Data Found!',
                    isVisible: products.length < 1 && !isShowLoader,
                  ),

                  ///BUILDS PRODUCTS LIST
                  isLargeScreen ? _buildGrid() : _buildList(),

                  ///PAGINATION LOADER
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomAppBar(
          child: Visibility(
            visible: isShowPaginationButtons,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 10.0),
              child: Row(
                //crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                    child: RaisedButton(
                      onPressed: isPreviousButtonDisabled == true
                          ? null
                          : () {
                              setState(() {
                                isPreviousButtonPressed = true;
                                isNextButtonPressed = false;
                                dataFetch();
                                isNextButtonDisabled = false;
                              });
                            },
                      color: Colors.blue,
                      child: Icon(
                        Icons.navigate_before,
                        color: Colors.white,
                      ),
//                        child: Text(
//                          'Previous',
//                          style: TextStyle(color: Colors.white),
//                        ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                    child: RaisedButton(
                      onPressed: isNextButtonDisabled == true
                          ? null
                          : () {
                              setState(() {
                                isNextButtonPressed = true;
                                isNextButtonDisabled = true;
                                isPreviousButtonPressed = false;
                                dataFetch();
                                isPreviousButtonDisabled = false;
                              });
                            },
                      color: Colors.blue,
//                        child: Text(
//                          'Next',
//                          style: TextStyle(color: Colors.white),
//                        ),
                      child: Icon(
                        Icons.navigate_next,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
