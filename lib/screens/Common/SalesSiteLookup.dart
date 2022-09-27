import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:moblesales/helpers/index.dart';
import 'package:moblesales/models/index.dart';
import 'package:moblesales/screens/index.dart';
import 'package:moblesales/utils/index.dart';

class SalesSiteLookup extends StatefulWidget {
  final Function(SalesSite selectedSalesSite) handleSalesSiteChange;
  final VoidCallback closeSearchDialog;

  ///TO APPLY DIFFERENT PADDING WHEN WIDGET VIEWED IN LOOKUP'S SEARCH_TEXT_FIELD_UI
  final bool forLookupType;
  SalesSiteLookup({
    @required this.handleSalesSiteChange,
    @required this.closeSearchDialog,
    this.forLookupType = false,
  });
  @override
  _SalesSiteLookupState createState() => _SalesSiteLookupState();
}

class _SalesSiteLookupState extends State<SalesSiteLookup> {
  ///HOLDS THE CLASS OBJECT WHICH CONTAINS THE REUSABLE WIDGETS
  CommonWidgets _commonWidgets;

  ///HOLDS SALES_SITE_DATABASE HELPER OBJECT
  SalesSiteDBHelper _salesSiteDBHelper;

  ///HOLDS ALL THE SALES_SITES LIST ALSO USED DURING THE LOCAL SEARCH
  List<SalesSite> _salesSites;

  ///TO HIDE?SHOW THE LOADER TILL SALES_SITE LIST GETS LOADED
  bool _showSalesSiteSearchLoader;

  ///USED FOR PAGINATION PURPOSE TO CHECK THE DATA IS REMAINING FOR THE GET
  bool isDataRemaining;

  ///TO SHOW THE LOADER WHILE PAGINATION DATA IF BEING FETCHED
  bool isShowPaginationLoader;

  ///API PARAMETERS FOR THE PAGINATION PURPOSE
  int pageNumber;
  int pageSize;

  ///HANDLES THE SEARCH_TEXT_FIELD STATE FOR THE ADVANCED SEARCH
  String searchFieldContent;

  ///TO IDENTIFY IF THE LOCAL DATA IS FETCHED FOR THE FIRST TIME
  bool isInitialFetch;

  ///TO IDENTIFY IF THE LOCAL DATA IS SYNCED OR NOT
  bool isLocalDataSynced;

  @override
  void initState() {
    super.initState();
    isInitialFetch = true;
    isLocalDataSynced = true;
    _commonWidgets = CommonWidgets();
    _salesSiteDBHelper = SalesSiteDBHelper();
    _salesSites = List<SalesSite>();
    _showSalesSiteSearchLoader = true;
    isShowPaginationLoader = false;
    isDataRemaining = true;
    pageNumber = 1;
    searchFieldContent = null;
    pageSize = Pagination.LOOKUP_PAGE_SIZE;

    dataFetch();
  }

  ///IT FETCHES SALES_SITE OFFLINE DATA FOR LOOKUP
  Future<List<SalesSite>> fetchOfflineSalesSiteData() async {
    var salesSiteData = List<SalesSite>();
    try {
      //Site Data Come From login
      //searchFieldContent=await Session.getSalesSiteCode();
      salesSiteData = await _salesSiteDBHelper.getSalesSitePaginationData(
        pageNo: pageNumber,
        pageSize: pageSize,
        searchText:
            (searchFieldContent != null && searchFieldContent.trim().length > 0)
                ? searchFieldContent
                : '',
      );
      if (isInitialFetch)
        showInitialEmptyDataToast(initialFetchCount: salesSiteData.length);
      return salesSiteData;
    } catch (e) {
      print('Error inside fetchOfflineSalesSiteData Response ');
      print(e);
      if (isInitialFetch)
        showInitialEmptyDataToast(initialFetchCount: salesSiteData.length);
      return salesSiteData;
    }
  }

  ///IT SHOWS THE FLUTTER TOAST IF THE LOOKUP DATA INITIALLY EMPTY
  void showInitialEmptyDataToast({int initialFetchCount}) {
    setState(() {
      isInitialFetch = false;
    });
    if (initialFetchCount < 1) {
      setState(() {
        isLocalDataSynced = false;
      });
    }
  }

  ///IT HANDLES THE PAGINATION PARAMETER ALSO DECIDES TO CALL THE API OR NOT
  void dataFetch() {
    if (isDataRemaining) {
      fetchOfflineSalesSiteData().then((salesSiteDataRes) => {
            setState(() {
              pageNumber = pageNumber + 1; //<--To get next record set
              int newRecordCount = salesSiteDataRes.length;
              _salesSites.addAll(salesSiteDataRes);
              _showSalesSiteSearchLoader = false;
              isShowPaginationLoader = false;
              if (newRecordCount < pageSize) {
                isDataRemaining = false;
              }
            })
          });
    } else {
      setState(() {
        _showSalesSiteSearchLoader = false;
        isShowPaginationLoader = false;
      });
      _commonWidgets.showFlutterToast(toastMsg: "No more data");
    }
  }

  ///It returns the companyList title widget
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

  ///It returns the SalesSiteList Value widget
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

  ///It handles the Selected SalesSite Response for the search
  void handleSalesSiteSelected(SalesSite selectedSalesSite) {
    Navigator.of(context, rootNavigator: true).pop('PopupClosed');
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
      _salesSites.clear();
      pageNumber = 1;
      isDataRemaining = true;
      _showSalesSiteSearchLoader = true;
    });
    dataFetch();
  }

  ///IT BUILDS THE SALES_SITE_LIST FOR THE SELECTION
  Widget _buildList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: ScrollPhysics(),
      itemCount: _salesSites.length,
      itemBuilder: (context, position) {
        return GestureDetector(
          onTap: () {
            print('List View OnTap Closing the popup');
            widget.handleSalesSiteChange(_salesSites[position]);
            handleSalesSiteSelected(_salesSites[position]);
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
//                                          getListTitleWidget('Customer Code'),
                            getListValueWidget(
                                _salesSites[position].SiteCode, 1),
                            SizedBox(height: 10),
//                                        getListTitleWidget('Customer Name'),
                            getListValueWidget(
                                '${_salesSites[position].SiteName}', 2),
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
      actionsPadding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
      insetPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      actions: <Widget>[
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
            SearchTextField(
              searchFieldContent: searchFieldContent,
              clearTextFieldSearch: clearTextFieldSearch,
              handleTextFieldSearch: handleTextFieldSearch,
              forLookupType: widget.forLookupType,
              isShowSearchCard: true,
            ),
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification scrollInfo) {
                  if (!isShowPaginationLoader &&
                      scrollInfo.metrics.pixels ==
                          scrollInfo.metrics.maxScrollExtent) {
                    dataFetch(); //<-- start loading data
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
                    Visibility(
                      visible: !isLocalDataSynced,
                      child: Text(BackgroundServiceHelper
                          .SYNC_INITIAL_LOOKUPS_DATA_MSG),
                    ),

                    ///IT SHOWS THE INITIAL DATA FETCH LOADER
                    _commonWidgets.showCommonLoader(
                      isLoaderVisible: _showSalesSiteSearchLoader,
                    ),

                    ///NO DATA WIDGET
                    _commonWidgets.buildEmptyDataWidget(
                      textMsg: _showSalesSiteSearchLoader
                          ? CommonConstants.LOADING_DATA
                          : CommonConstants.NO_DATA_FOUND,
                      isVisible: _salesSites.length < 1 && isLocalDataSynced,
                    ),

                    ///IT BUILDS THE COMPANIES LIST UI
                    _buildList(),

                    ///IT SHOWS THE PAGINATION LOADER
                    _commonWidgets.showCommonLoader(
                      isLoaderVisible:
                          isShowPaginationLoader && !_showSalesSiteSearchLoader,
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
