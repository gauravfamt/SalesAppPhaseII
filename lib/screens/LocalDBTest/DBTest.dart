import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:moblesales/helpers/index.dart';
import 'package:moblesales/models/index.dart';
import 'package:moblesales/utils/index.dart';

class DBTest extends StatefulWidget {
  @override
  _DBTestState createState() => _DBTestState();
}

class _DBTestState extends State<DBTest> {
  List<Company> companies;
  CompanyDBHelper _companyDBHelper;
  StreamSubscription _connectionChangeStream;
  bool isOffline = false;
  @override
  void initState() {
    super.initState();
    companies = List<Company>();
    _companyDBHelper = CompanyDBHelper();
//    fetchAllCompanies();
    ConnectivityService connectionStatus = ConnectivityService.getInstance();
    _connectionChangeStream =
        connectionStatus.connectionChange.listen(connectionChanged);
  }

  void connectionChanged(dynamic hasConnection) {
    print('Inside connectionChanged hasConnection: $hasConnection');
    setState(() {
      isOffline = !hasConnection;
    });
  }

  void fetchAllCompanies() {
    try {
      this.setState(() {
        companies.clear();
      });
      print('fetchAllCompanies called');
      _companyDBHelper.getAllCompaniesWithAddresses().then(
            (companiesRes) => {
              print('companiesRes'),
//              print(companiesRes),
              this.setState(() {
                companies.addAll(companiesRes);
              }),
            },
          );
    } catch (e) {
      print('Error indide fetchAllCompanies function ');
      print(e);
    }
  }

  void handleNewCompanyInsert() {
    try {
      Fluttertoast.showToast(
        msg:
            "THIS FUNCTIONALITY IS COMMENTED CURRENTLY AS LOCAL DATABASE DOES NOT HAVE ADDRESSES AND CONTACTS  FIELDS ITS BREAKING ",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 5,
        backgroundColor: Colors.black38,
        textColor: Colors.white,
        fontSize: 16.0,
      );
//      Company company = Company(
//        Name: 'One,',
//        Balance: 20.0,
//        CreditLimit: 9.0,
//        CustomerNo: '01',
//        CurrencyCode: 'INR',
//        DefaultBillAdd: 'TEst',
//        SalesRep: "OWN",
//        TenantId: 01,
//        TotalBalance: 10.0,
//        Type: 'huedh',
//      );
//      _companyDBHelper.newCompany(company).then(
//            (value) => {
//              print('Created Company res '),
//              print(value),
//              this.fetchAllCompanies(),
//            },
//          );
    } catch (e) {
      print('Error inside handleNewCompanyInsert function ');
      print(e);
    }
  }

  void handleLimitQuery() {
    setState(() {
      companies.clear();
    });
    _companyDBHelper
        .getCompaniesPaginationData(
          pageNo: 1,
          pageSize: 10,
//          searchText: 'kin',
        )
        .then((value) => {
              print('Companies Limited response Received '),
              this.setState(() {
                companies.addAll(value);
              }),
            })
        .catchError((e) => {
              print('Error inside handleLimitQuery'),
              print(e),
            });
  }

  void handleAPICompanyDataInsert() {
    try {
      print('handleAPICompanyDataInsert Code Commented currently');
      _companyDBHelper.fetchCompanies().then((apiCompaniesRes) => {
            print('fetchCompanies Response received from API'),
            if (apiCompaniesRes.length > 0)
              {
                _companyDBHelper.addCompanies(apiCompaniesRes).then(
                      (value) => {
                        print('Created multiple Companies res received'),
                        this.fetchAllCompanies(),
                      },
                    ),
              }
            else
              {
                print('No companies list received from api call'),
              }
          });
    } catch (e) {
      print('Error inside handleAPICompanyDataInsert function ');
      print(e);
    }
  }

  void handleMultipleCompanyInsert() {
    try {
      List<Company> companies = [
        Company(
          Name: 'One,',
          Balance: 20.0,
          CreditLimit: 9.0,
          CustomerNo: '01',
          CurrencyCode: 'INR',
          DefaultBillAdd: 'TEst',
          SalesRep: "OWN",
          TenantId: 01,
          TotalBalance: 10.0,
          Type: 'huedh',
        ),
        Company(
          Name: 'Two',
          Balance: 20.0,
          CreditLimit: 9.0,
          CustomerNo: '01',
          CurrencyCode: 'INR',
          DefaultBillAdd: 'TEst',
          SalesRep: "OWN",
          TenantId: 01,
          TotalBalance: 10.0,
          Type: 'huedh',
        ),
      ];
      _companyDBHelper.addCompanies(companies).then(
            (value) => {
              print('Created multiple Companies res '),
              print(value),
              this.fetchAllCompanies(),
            },
          );
    } catch (e) {
      print('Error inside handleMultipleCompanyInsert function ');
      print(e);
    }
  }

  void handleDeleteTableData() {
    print('Inside FN handleDeleteTableData');
    try {
//      DBProvider.db.database.then((db) => {
//            db.delete('Company').then(
//                  (deleteRes) => {
//                    print('deleteRes'),
//                    print(deleteRes),
//                    this.fetchAllCompanies(),
//                  },
//                ),
//          });
      _companyDBHelper.deleteALLRows().then(
            (deleteRes) => {
              print('deleteRes'),
              print(deleteRes),
              this.fetchAllCompanies(),
            },
          );
    } catch (e) {
      print('Error inside handleDeleteTableData ');
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
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('DBTest'),
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
                    'COMPANIES CRUD',
                    style:
                        TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
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
                    'Total COMPANIES DATA : ${companies.length}',
                    style:
                        TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
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
                    'Is App Offline : $isOffline',
                    style:
                        TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
                ))),
              ],
            ),
            Row(
              children: <Widget>[
                getRaisedButton(
                  label: 'Dummy Data Insert',
                  onPressedFn: handleNewCompanyInsert,
                ),
                getRaisedButton(
                  label: 'Fetch Companies Data',
                  onPressedFn: fetchAllCompanies,
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
                  label: 'ADD MULTIPLE COMPANIES',
                  onPressedFn: handleMultipleCompanyInsert,
                ),
              ],
            ),
            Row(
              children: <Widget>[
                getRaisedButton(
                  label: 'Insert_API_Companies',
                  onPressedFn: handleAPICompanyDataInsert,
                ),
                getRaisedButton(
                  label: 'Limit Query',
                  onPressedFn: handleLimitQuery,
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: companies.length,
                itemBuilder: (context, position) {
                  return Column(
                    children: <Widget>[
                      Divider(
                        color: Colors.teal,
                        thickness: 2.0,
                      ),
                      Text('${companies[position].Id}'),
                      Text('${companies[position].Name}'),
                      Text('${companies[position].CustomerNo}'),
                      Text('${companies[position].TenantId}'),
                      Text('${companies[position].CurrencyCode}'),
                      Text('${companies[position].CreditLimit}'),
                      Text('${companies[position].Balance}'),
                      Text('${companies[position].DefaultBillAdd}'),
                      Text('${companies[position].Type}'),
                      Text('${companies[position].SalesRep}'),
                      Text('${companies[position].TotalBalance}'),
                      ...companies[position]
                          .addresses
                          .map((e) => Text('${e.Address1}'))
                          .toList(),
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
      ),
    );
  }
}
