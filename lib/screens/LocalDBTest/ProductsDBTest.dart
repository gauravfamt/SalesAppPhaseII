import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:moblesales/models/index.dart';
import 'package:moblesales/utils/index.dart';

class ProductDBTest extends StatefulWidget {
  @override
  _ProductDBTestState createState() => _ProductDBTestState();
}

class _ProductDBTestState extends State<ProductDBTest> {
  ///HOLDS ALL THE PRODUCTS LIST FOR SHOWING ON UI
  List<Product> _products;

  ///HOLDS PRODUCT DB HELPER FOR FETCHING FROM THE LOCAL_DATABASE
  ProductDBHelper _productDBHelper;

  ///TIMERS
  Duration _productsFetchMSTime;
  Duration _productsLocalDeleteMSTime;
  Duration _productsLocalInsertMSTime;
  @override
  void initState() {
    super.initState();
    _products = List<Product>();
    _productDBHelper = ProductDBHelper();
    _productsFetchMSTime = Duration(microseconds: 0);
    _productsLocalDeleteMSTime = Duration(microseconds: 0);
    _productsLocalInsertMSTime = Duration(microseconds: 0);
    fetchAllProducts();
  }

  ///FETCHES ALL THE PRODUCTS
  void fetchAllProducts() {
    try {
      this.setState(() {
        _products.clear();
      });
      print('fetchAllProducts called');
      _productDBHelper.getAllProducts().then(
            (productsRes) => {
              print('productsRes'),
              if (productsRes.length > 0)
                this.setState(() {
                  _products.addAll(productsRes);
                }),
            },
          );
    } catch (e) {
      print('Error indide productsRes function ');
      print(e);
    }
  }

  ///ADDS SINGLE DUMMY PRODUCT TO THE LOCAL_DB
  void handleNewProductInsert() {
    try {
      Product _product = Product(
        ProductCode: 'P01, tehre',
        Description: 'P01_DESC',
        Status: 'ENABLED',
        ProductCategory: 'ALL',
        BasePrice: 10.0,
        BaseUnit: 'EUR',
        Weight: 10.0,
        IsTaxable: 'YES',
        UPCCode: '12345678',
        CreatedDate: DateTime.now(),
        UpdatedDate: DateTime.now(),
      );

      _productDBHelper.newProduct(_product).then(
            (value) => {
              print('Created Product res '),
              print(value),
              this.fetchAllProducts(),
            },
          );
    } catch (e) {
      print('Error inside handleNewProductInsert function ');
      print(e);
    }
  }

  ///DELETES ALL THE TABLE DATA
  void handleDeleteTableData() {
    print('Inside FN handleDeleteTableData for product');
    try {
//      DBProvider.db.database.then((db) => {
//            db.delete(_productDBHelper.tableName).then(
//                  (deleteRes) => {
//                    print('deleteRes'),
//                    print(deleteRes),
//                    this.fetchAllProducts(),
//                  },
//                ),
//          });
      _productDBHelper.deleteALLRows().then(
            (deleteRes) => {
              print('deleteRes'),
              print(deleteRes),
              this.fetchAllProducts(),
            },
          );
    } catch (e) {
      print('Error inside handleDeleteTableData  for product');
      print(e);
    }
  }

  ///HANDLES MULTIPLE DUMMY PRODUCTS INSERT
  void handleMultipleProductsInsert() {
    try {
      List<Product> _productsList = [
        Product(
          Id: 3,
          ProductCode: 'P022',
          Description: 'P02_DESC',
          Status: 'DISABLED',
          ProductCategory: 'ALL_IGNORE',
          BasePrice: 10.0,
          BaseUnit: 'EUR',
          Weight: 10.0,
          IsTaxable: 'YES',
          UPCCode: '12345678',
          CreatedDate: DateTime.now(),
          UpdatedDate: DateTime.now(),
        ),

      ];
      _productDBHelper.addProducts(_productsList).then(
            (value) => {
              print('multiple Dummy Products Insert res '),
              print(value),
              this.fetchAllProducts(),
            },
          );
    } catch (e) {
      print('Error inside handleMultipleProductsInsert function ');
      print(e);
    }
  }

  ///IT RETURNS THE PRODUCTS DATA AND RETURNS THE DATA IN PAGES AND PAGE SIZE REQUESTED
  void getProductsPaginationData() {
    setState(() {
      _products.clear();
    });
    _productDBHelper
        .getProductsPaginationData(
          pageNo: 1,
          pageSize: 10,
          searchText: 'Sprockets',
        )
        .then((value) => {
              print('products Limited response Received '),
              this.setState(() {
                _products.addAll(value);
              }),
            })
        .catchError((e) => {
              print('Error inside handleLimitQuery for Products'),
              print(e),
            });
  }

  ///IT FETCHES PRODUCTS DATA FROM API AND THEN INSERT IT TO THE LOCAL DB
  void handleAPIProductDataInsert() {
    try {
      setState(() {
        _productsFetchMSTime = Duration(microseconds: 0);
        _productsLocalDeleteMSTime = Duration(microseconds: 0);
        _productsLocalInsertMSTime = Duration(microseconds: 0);
      });
      var _apiDataFetchStartTime = DateTime.now();
      var _apiDataFetchEndTime;
      var _localDataDeleteStartTime;
      var _localDataDeleteEndTime;
      var _localDataInsertStartTime;
      var _localDataInsertEndTime;
      _productDBHelper.fetchProducts().then((apiProductsRes) => {
            print('fetchProducts Response received from API'),
            _apiDataFetchEndTime = DateTime.now(),
            this.setState(() {
              _productsFetchMSTime =
                  _apiDataFetchEndTime.difference(_apiDataFetchStartTime);
            }),
            print('_productsFetchMSTime.inMilliseconds'),
            print(_productsFetchMSTime.inMilliseconds),
            if (apiProductsRes.length > 0)
              {
                print('First Deleting LocalDatabase data '),
                _localDataDeleteStartTime = DateTime.now(),
                _productDBHelper.deleteALLRows().then((value) => {
                      _localDataDeleteEndTime = DateTime.now(),
                      this.setState(() {
                        _productsLocalDeleteMSTime = _localDataDeleteEndTime
                            .difference(_localDataDeleteStartTime);
                      }),
                      print('_productsLocalDeleteMSTime.inMilliseconds'),
                      print(_productsLocalDeleteMSTime.inMilliseconds),
                      _localDataInsertStartTime = DateTime.now(),
                      _productDBHelper.addProducts(apiProductsRes).then(
                            (value) => {
                              _localDataInsertEndTime = DateTime.now(),
                              this.setState(() {
                                _productsLocalInsertMSTime =
                                    _localDataInsertEndTime
                                        .difference(_localDataInsertStartTime);
                              }),
                              print(
                                  '_productsLocalInsertMSTime.inMilliseconds'),
                              print(_productsLocalInsertMSTime.inMilliseconds),
                              print('Created multiple Products res received'),
                              this.fetchAllProducts(),
                            },
                          ),
                    }),
              }
            else
              {
                print('No Products list received from api call'),
              }
          });
    } catch (e) {
      print('Error inside handleAPIProductDataInsert function ');
      print(e);
    }
  }

  ///HANDLES ALL THE RAISED BUTTONS FOR ON_PRESSED FUNCTIONS AND LABELS_TEXT
  Widget getRaisedButton({
    String label,
    Function onPressedFn,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: RaisedButton(
          onPressed: () {
            onPressedFn();
          },
          child: Text('$label'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Screen'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                  child: Center(
                      child: Padding(
                padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                child: Text(
                  'PRODUCTS CRUD',
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                ),
              ))),
            ],
          ),
          Row(
            children: <Widget>[
              Expanded(
                  child: Center(
                      child: Padding(
                padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                child: Text(
                  'Total PRODUCTS DATA : ${_products.length}',
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                ),
              ))),
            ],
          ),
          Row(
            children: <Widget>[
              getRaisedButton(
                label: 'Dummy Data Insert',
                onPressedFn: handleNewProductInsert,
              ),
              getRaisedButton(
                label: 'Fetch Products Data',
                onPressedFn: fetchAllProducts,
              ),
            ],
          ),
          Row(
            children: <Widget>[
              getRaisedButton(
                label: 'DELETE TABLE DATA',
                onPressedFn: handleDeleteTableData,
              ),
              getRaisedButton(
                label: 'ADD MULTIPLE PRODUCTS',
                onPressedFn: handleMultipleProductsInsert,
              ),
            ],
          ),
          Row(
            children: <Widget>[
              getRaisedButton(
                label: 'Insert_API_Products',
                onPressedFn: handleAPIProductDataInsert,
              ),
              getRaisedButton(
                label: 'Limit Query',
                onPressedFn: getProductsPaginationData,
              ),
            ],
          ),

          ///TIMERS ROWS START
          Row(
            children: <Widget>[
              Expanded(
                  child: Center(
                      child: Padding(
                padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                child: Text(
                  'API DATA FETCH TIMING : $_productsFetchMSTime',
                  style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
                ),
              ))),
            ],
          ),
          Row(
            children: <Widget>[
              Expanded(
                  child: Center(
                      child: Padding(
                padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                child: Text(
                  'LOCAL_DB DATA_DELETE TIMING : $_productsLocalDeleteMSTime',
                  style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
                ),
              ))),
            ],
          ),
          Row(
            children: <Widget>[
              Expanded(
                  child: Center(
                      child: Padding(
                padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                child: Text(
                  'API DATA LOCAL INSERT TIMING : $_productsLocalInsertMSTime',
                  style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
                ),
              ))),
            ],
          ),

          ///TIMERS ROWS END
          Expanded(
            child: ListView.builder(
              itemCount: _products.length,
              itemBuilder: (context, position) {
                return Column(
                  children: <Widget>[
                    Divider(
                      color: Colors.teal,
                      thickness: 2.0,
                    ),
                    Text('${_products[position].Id}'),
                    Text('${_products[position].ProductCode}'),
                    Text('${_products[position].Description}'),
                    Text('${_products[position].Status}'),
                    Text('${_products[position].ProductCategory}'),
                    Text('${_products[position].BasePrice}'),
                    Text('${_products[position].BaseUnit}'),
                    Text('${_products[position].Weight}'),
                    Text('${_products[position].IsTaxable}'),
                    Text('${_products[position].UPCCode}'),
                    Text('${_products[position].CreatedDate}'),
                    Text('${_products[position].UpdatedDate}'),
//                    Text('${_products[position].Image}'),
                    Divider(
                      color: Colors.teal,
                      thickness: 2.0,
                    ),
                  ],
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
