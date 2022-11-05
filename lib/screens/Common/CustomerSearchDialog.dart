import 'package:flutter/material.dart';
import 'package:moblesales/helpers/index.dart';
import 'package:moblesales/models/index.dart';
import 'package:moblesales/screens/index.dart';
import 'package:moblesales/utils/index.dart';
import 'dart:async';
import 'package:sqflite/sqflite.dart';

class CustomerSearchDialog extends StatefulWidget {
  final Function(Company company) handleCustomerSelectedSearch;
  final VoidCallback closeSearchDialog;

  ///TO APPLY DIFFERENT PADDING WHEN WIDGET VIEWED IN LOOKUP'S SEARCH_TEXT_FIELD_UI
  final bool forLookupType;

  CustomerSearchDialog({
    @required this.handleCustomerSelectedSearch,
    @required this.closeSearchDialog,
    this.forLookupType = false,
  });

  @override
  _CustomerSearchDialogState createState() => _CustomerSearchDialogState();
}

class _CustomerSearchDialogState extends State<CustomerSearchDialog> {
  ///HOLDS THE CLASS OBJECT WHICH CONTAINS THE REUSABLE WIDGETS
  CommonWidgets _commonWidgets;

  ///HOLDS COMPANY_DATABASE HELPER OBJECT
  CompanyDBHelper _companyDBHelper;

  ///HOLDS ALL THE COMPANIES LIST ALSO USED DURING THE LOCAL SEARCH
  List<Company> _companies;

  ///TO HIDE?SHOW THE LOADER TILL COMPANY LIST GETS LOADED
  bool _showCompanySearchLoader;

  ///USED FOR PAGINATION PURPOSE TO CHECK THE DATA IS REMAINING FOR THE GET
  bool isDataRemaining;

  ///API PARAMETERS FOR THE PAGINATION PURPOSE
  int pageNumber;
  int pageSize;

  ///HANDLES THE SEARCH_TEXT_FIELD STATE FOR THE ADVANCED SEARCH
  String searchFieldContent;

  ///TO IDENTIFY IF THE LOCAL DATA IS FETCHED FOR THE FIRST TIME
  bool isInitialFetch;

  ///TO IDENTIFY IF THE LOCAL DATA IS SYNCED OR NOT
  bool isLocalDataSynced;

  ///PROVIDES SYNC_MASTER TABLE CRUD OPERATIONS
  SyncMasterDBHelper _syncMasterDBHelper = SyncMasterDBHelper();

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

  @override
  void initState() {
    super.initState();
    isInitialFetch = true;
    isLocalDataSynced = true;
    _commonWidgets = CommonWidgets();
    _companyDBHelper = CompanyDBHelper();
    _companies = List<Company>();
    _showCompanySearchLoader = true;
    pageNumber = 1;
    searchFieldContent = null;
    pageSize = Pagination.LOOKUP_PAGE_SIZE;

    isNextButtonDisabled = false;
    isPreviousButtonDisabled = true; //Initialy on 1 page
    isFirstPageButtonDisabled = true;
    isShowPaginationButtons = false;

    recordCount = 0;
    lastPageNumber = 0;
    print('Customer Search Dialog');
    OfflineDataSyncsStatus();
    dataFetch();
  }

  @override
  void dispose() {
    super.dispose();
  }

  ///THIS FUNCTION HANDLES THE COMPANIES DATA INSERT FROM API TO THE LOCAL_DB
  Future handleWMAPICompanyDataInsert() async {
    print('Inside Global handleWMAPICompanyDataInsert Fn :');
    try {
      List<SyncMaster> _syncMasters =
          await _syncMasterDBHelper.getAllSyncMasters();
      String apiDomain = await Session.getData(Session.apiDomain);
      String accessToken = await Session.getData(Session.accessToken);
      String Username = await Session.getData(Session.userName);

      SyncMaster companySyncMaster = _syncMasters.firstWhere(
          (element) => element.TableName == _companyDBHelper.tableName);
      String _lastSyncDateUTCForSave = await ApiService.getCurrentDateTime(
        tokenValue: accessToken,
        apiDomain: apiDomain,
      );
      print(
          '_lastSyncDateUTC For Local Company Master Table: $_lastSyncDateUTCForSave');
      if (_lastSyncDateUTCForSave != 'ERROR') {
        List<Company> apiCompaniesRes = await _companyDBHelper.fetchCompanies(
          lastSyncDate: companySyncMaster.LastSyncDate,
          tokenValue: accessToken,
          apiDomain: apiDomain,
          Username: Username,
        );
        print('Companies API response received ');

        if (apiCompaniesRes.length > 0) {
          print('Companies Response records: ${apiCompaniesRes.length}');
          Database _db = await DBProvider.db.database;
          if (_db != null) {
            print('Proceeding to insert Company data into localDB');
            var addCompaniesRes =
                await _companyDBHelper.addCompanies(apiCompaniesRes);
            print('Companies Insert into Local Database is successful!');
            var lastSyncDateUpdateRes =
                await _syncMasterDBHelper.updateMasterTableLastSyncDateByName(
              lastSyncDate: _lastSyncDateUTCForSave,
              masterTableName: _companyDBHelper.tableName,
            );
            print('Company Table LastSyncDate Updated Response ');
            print(lastSyncDateUpdateRes);
            dataFetch();
            return Future.value(true);
          } else {
            print('Database Object not found for local insertion ');
            dataFetch();
            return Future.value(true);
          }
        } else {
          print('Companies Data not found from api');
          var lastSyncDateUpdateRes =
              await _syncMasterDBHelper.updateMasterTableLastSyncDateByName(
            lastSyncDate: _lastSyncDateUTCForSave,
            masterTableName: _companyDBHelper.tableName,
          );
          print(
              'Company Table LastSyncDate Updated after api success Response but no updated data found ');
          print(lastSyncDateUpdateRes);
          dataFetch();
          return Future.value(true);
        }
      } else {
        print(
            'Company Last_Sync_Date not available to update locally so cancelling the Companies sync');
        dataFetch();
        return Future.value(false);
      }
    } catch (e) {
      print('Error inside handleWMAPICompanyDataInsert function ');
      print(e);
      dataFetch();
      return Future.value(false);
    }
  }

  Future<void> OfflineDataSyncsStatus() async {
    try {
      recordCount = await _companyDBHelper.getCompanyCount('');
      lastPageNumber = (recordCount / pageSize).ceil();
      print('company count $recordCount');
      if (recordCount > 0) {
        setState(() {
          isLocalDataSynced = true;
          fetchOfflineCompaniesData();
        });
      } else {
        setState(() {
          isLocalDataSynced = false;
        });
      }
    } catch (e) {
      print('Error Inside OfflineDataSyncsStatus $e ');
      setState(() {
        isLocalDataSynced = false;
      });
    }
  }

  Future<void> getCompanyCount() async {
    try {
      if (searchFieldContent != null && searchFieldContent.trim().length > 0) {
        String strWhereClause =
            " and Name LIKE '${'%' + searchFieldContent + '%'}' OR CustomerNo LIKE '${'%' + searchFieldContent + '%'}'";
        recordCount = await _companyDBHelper.getCompanyCount(strWhereClause);
        lastPageNumber = (recordCount / pageSize).ceil();
      }
      print('Record Count $recordCount');
    } catch (e) {
      print('Error Inside getCompanyCount $e ');
    }
  }

  ///IT FETCHES COMPANY OFFLINE DATA FOR LOOKUP
  Future<List<Company>> fetchOfflineCompaniesData() async {
    var companyData = List<Company>();
    try {
      getCompanyCount();
      companyData = await _companyDBHelper.getCompaniesPaginationData(
        pageNo: pageNumber,
        pageSize: pageSize,
        searchText:
            (searchFieldContent != null && searchFieldContent.trim().length > 0)
                ? searchFieldContent
                : '',
      );
      return companyData;
    } catch (e) {
      print('Error inside fetchOfflineCompaniesData Response ');
      print(e);
      return companyData;
    }
  }

  ///IT HANDLES THE PAGINATION PARAMETER ALSO DECIDES TO CALL THE API OR NOT
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
      fetchOfflineCompaniesData().then((companiesDataRes) => {
            setState(() {
              int newRecordCount = companiesDataRes.length;
              _companies.clear();
              _companies.addAll(companiesDataRes);
              _showCompanySearchLoader = false;
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
            })
          });
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

  ///It returns the companyList Value widget
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

  ///It handles the Selected Company Response for the search
  void handleCustomerSelected(Company selectedCompany) {
    Navigator.of(context, rootNavigator: true).pop('PopupClosed');
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
    });
    loadNewSearchData();
  }

  ///IT CALLS THE DATA_FETCH FUNCTION TO LOAD THE NEW LIST AS PER SEARCH PARAMETERS ALSO
  ///IT CLEARS THE EXISTING STATES
  void loadNewSearchData() {
    setState(() {
      _companies.clear();
      pageNumber = 1;
      isNextButtonPressed = false;
      isPreviousButtonPressed = false;
      isNextButtonDisabled = false;
      isLastPageButtonDisabled = false;
      isPreviousButtonDisabled = true;
      isFirstPageButtonDisabled = true;
      _showCompanySearchLoader = true;
    });
    dataFetch();
  }

  ///IT BUILDS THE COMPANY_LIST FOR THE SELECTION
  Widget _buildList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: ScrollPhysics(),
      itemCount: _companies.length,
      itemBuilder: (context, position) {
        return GestureDetector(
          onTap: () {
            print('List View OnTap Closing the popup');
            widget.handleCustomerSelectedSearch(_companies[position]);
            handleCustomerSelected(_companies[position]);
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
                                _companies[position].CustomerNo, 1),
                            SizedBox(height: 10),
//                                        getListTitleWidget('Customer Name'),
                            getListValueWidget(
                                '${_companies[position].Name}', 2),
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
      title: Center(child: Text('Customer Details')),
      actionsPadding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
      insetPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      actionsOverflowDirection: VerticalDirection.down,
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
        height: double.infinity,
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
              placeHolder: 'Search Customer',
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
                    isLoaderVisible: _showCompanySearchLoader,
                  ),

                  ///NO DATA WIDGET
                  _commonWidgets.buildEmptyDataWidget(
                    textMsg: CommonConstants.NO_DATA_FOUND,
                    isVisible: _companies.length < 1 && isLocalDataSynced,
                  ),

                  ///IT BUILDS THE COMPANIES LIST UI
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
