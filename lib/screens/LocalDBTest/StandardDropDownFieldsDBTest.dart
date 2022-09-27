import 'dart:async';
import 'package:flutter/material.dart';
import 'package:moblesales/helpers/index.dart';
import 'package:moblesales/models/index.dart';
import 'package:moblesales/utils/Helper/index.dart';

class StandardDropDownFieldsDBTestScreen extends StatefulWidget {
  @override
  _StandardDropDownFieldsDBTestScreenState createState() =>
      _StandardDropDownFieldsDBTestScreenState();
}

class _StandardDropDownFieldsDBTestScreenState
    extends State<StandardDropDownFieldsDBTestScreen> {
  List<StandardDropDownField> _standardDropDownFields;
  StandardDropDownFieldsDBHelper _standardDropDownFieldsDBHelper;

  @override
  void initState() {
    super.initState();
    _standardDropDownFields = List<StandardDropDownField>();
    _standardDropDownFieldsDBHelper = StandardDropDownFieldsDBHelper();
    handleGetStandardDropDownFields();
  }

  void handleGetStandardDropDownFields() {
    try {
      this.setState(() {
        _standardDropDownFields.clear();
      });
      _standardDropDownFieldsDBHelper
          .getStandardDropDownFieldsData()
          .then((sfRes) => {
                if (sfRes.length > 0)
                  {
                    this.setState(() {
                      _standardDropDownFields.addAll(sfRes);
                    }),
                  }
                else
                  {
                    print(
                        'Empty Response received from LocalDatabase for StandardDropDownFields'),
                  }
              })
          .catchError((e) => {
                print(
                    'Error while getting StandardDropDownFields Data from LocalDB'),
                print(e),
              });
    } catch (e) {
      print('Inside handleGetStandardDropDownFields Fn Error Catch Block ');
      print(e);
    }
  }

  void insertAPIStandardDropDownFields() {
    try {
      ApiService.getStandardDropdownFields(
        entity: StandardEntity.CURRENCY_DROPDOWN_ENTITY,
        searchText: DropdownSearchText.CURRENCY_DROPDOWN_SEARCH_TEXT,
      )
          .then((sfRes) => {
                print(
                    'getStandardDropDownFields Response For QuoteHeader Entity'),
                if (sfRes != null && sfRes.length > 0)
                  {
                    _standardDropDownFieldsDBHelper
                        .addStandardDropDownFields(sfRes)
                        .then((value) => {
                              print(
                                  'StandardDropDownFields Insert to LocalDB Success Res'),
                              this.handleGetStandardDropDownFields(),
                            })
                        .catchError((e) => {
                              print(
                                  'StandardFields Insert to LocalDB Error Res '),
                              print(e),
                            }),
                  }
                else
                  {print('StandardDropDownFields Data Not Received')}
              })
          .catchError((e) => {
                print(
                    'Error while getting StandardDropDownFields data for localDatabase insert'),
                print(e),
              });
    } catch (e) {
      print('Inside insertAPIStandardDropDownFields Fn Error Catch Block ');
      print(e);
    }
  }

  void handleDeleteTableData() {
    print('Inside FN handleDeleteTableData');
    try {
      _standardDropDownFieldsDBHelper.deleteALLRows().then(
            (deleteRes) => {
              print('deleteRes'),
              print(deleteRes),
              this.handleGetStandardDropDownFields(),
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
          child: Center(child: Text('$label')),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Standard Fields Test'),
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
                    'STANDARD DROP DOWN FIELDS CRUD',
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
                    'Total standard-DropDown DATA : ${_standardDropDownFields.length}',
                    style:
                        TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
                ))),
              ],
            ),
            Row(
              children: <Widget>[
                getRaisedButton(
                  label: 'Fetch Standard DropDown Fields',
                  onPressedFn: handleGetStandardDropDownFields,
                ),
                getRaisedButton(
                  label: 'DELETE TABLE DATA',
                  onPressedFn: handleDeleteTableData,
                ),
              ],
            ),
            Row(
              children: <Widget>[
                getRaisedButton(
                  label: 'Insert API Currency DROPDOWN SF',
                  onPressedFn: insertAPIStandardDropDownFields,
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _standardDropDownFields.length,
                itemBuilder: (context, position) {
                  return Column(
                    children: <Widget>[
                      Divider(
                        color: Colors.teal,
                        thickness: 2.0,
                      ),
                      Text('Id: ${_standardDropDownFields[position].Id}'),
                      Text(
                          'Entity: ${_standardDropDownFields[position].Entity}'),
                      Text(
                          'Caption: ${_standardDropDownFields[position].Caption}'),
                      Text('Code: ${_standardDropDownFields[position].Code}'),
                      Text(
                          'Dropdown: ${_standardDropDownFields[position].Dropdown}'),
                      Text(
                          'TenantId: ${_standardDropDownFields[position].TenantId}'),
                      Text(
                          'CreatedDate: ${_standardDropDownFields[position].CreatedDate}'),
                      Text(
                          'UpdatedDate: ${_standardDropDownFields[position].UpdatedDate}'),
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
