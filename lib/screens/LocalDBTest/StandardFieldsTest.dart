import 'dart:async';
import 'package:flutter/material.dart';
import 'package:moblesales/helpers/index.dart';
import 'package:moblesales/models/index.dart';
import 'package:moblesales/utils/index.dart';

class StandardFieldsTestScreen extends StatefulWidget {
  @override
  _StandardFieldsTestScreenState createState() =>
      _StandardFieldsTestScreenState();
}

class _StandardFieldsTestScreenState extends State<StandardFieldsTestScreen> {
  List<StandardField> standardFields;
  StandardFieldsDBHelper _standardFieldsDBHelper;

  @override
  void initState() {
    super.initState();
    standardFields = List<StandardField>();
    _standardFieldsDBHelper = StandardFieldsDBHelper();
  }

  void handleGetStandardFields() {
    try {
      this.setState(() {
        standardFields.clear();
      });
      _standardFieldsDBHelper
          .getStandardFieldsData()
          .then((sfRes) => {
                if (sfRes.length > 0)
                  {
                    this.setState(() {
                      standardFields.addAll(sfRes);
                    }),
                  }
                else
                  {
                    print(
                        'Empty Response received from LocalDatabase for StandardFields'),
                  }
              })
          .catchError((e) => {
                print('Error while getting StandardFields Data from LocalDB'),
                print(e),
              });
    } catch (e) {
      print('Inside handleGetStandardFields Fn Error Catch Block ');
      print(e);
    }
  }

  void insertAPIQuoteHeaderStandardFields() {
    try {
      ApiService.getStandardFields(
        entity: StandardEntity.QUOTE_HEADER,
        showInGrid: false,
        showOnScreen: true,
      )
          .then((sfRes) => {
                print('getStandardFields Response For QuoteHeader Entity'),
                if (sfRes != null && sfRes.length > 0)
                  {
                    _standardFieldsDBHelper
                        .addStandardFields(sfRes)
                        .then((value) => {
                              print(
                                  'StandardFields Insert to LocalDB Success Res'),
                              this.handleGetStandardFields(),
                            })
                        .catchError((e) => {
                              print(
                                  'StandardFields Insert to LocalDB Error Res '),
                              print(e),
                            }),
                  }
                else
                  {print('StandardFields Data Not Received')}
              })
          .catchError((e) => {
                print(
                    'Error while getting StandardFields data for localDatabase insert'),
                print(e),
              });
    } catch (e) {
      print('Inside handleAPIStandardFieldsInsert Fn Error Catch Block ');
      print(e);
    }
  }

  void insertAPIQuoteDetailStandardFields() {
    try {
      ApiService.getStandardFields(
        entity: StandardEntity.QUOTE_DETAIL,
        showInGrid: false,
        showOnScreen: true,
      )
          .then((sfRes) => {
                print('getStandardFields Response For QuoteDetail Entity'),
                if (sfRes != null && sfRes.length > 0)
                  {
                    _standardFieldsDBHelper
                        .addStandardFields(sfRes)
                        .then((value) => {
                              print(
                                  'StandardFields Insert to LocalDB Success Res'),
                              this.handleGetStandardFields(),
                            })
                        .catchError((e) => {
                              print(
                                  'StandardFields Insert to LocalDB Error Res '),
                              print(e),
                            }),
                  }
                else
                  {print('StandardFields Data Not Received')}
              })
          .catchError((e) => {
                print(
                    'Error while getting StandardFields data for localDatabase insert'),
                print(e),
              });
    } catch (e) {
      print('Inside handleAPIStandardFieldsInsert Fn Error Catch Block ');
      print(e);
    }
  }

  ///IT UPDATES ALL THE STANDARD FIELDS ON_SHOW_PREVIEW TO TRUE
  void updateAllShowOnPreview() async {
    try {
      _standardFieldsDBHelper
          .updateAllShowOnPreview()
          .then((value) => {
                this.handleGetStandardFields(),
              })
          .catchError((e) => {
                print('NOT ABLE TO UPDATE PREVIEW FIELDS '),
              });
    } catch (e) {
      print('Error Inside updateAllShowOnPreview Fn ');
      print(e);
    }
  }

  void handleDeleteTableData() {
    print('Inside FN handleDeleteTableData');
    try {
      _standardFieldsDBHelper.deleteALLRows().then(
            (deleteRes) => {
              print('deleteRes'),
              print(deleteRes),
              this.handleGetStandardFields(),
            },
          );
    } catch (e) {
      print('Error inside handleDeleteTableData ');
      print(e);
    }
  }

  ///FETCHES ONLY QUOTE_HEADER FIELDS
  void fetchQuoteHeaderSF() {
    try {
      this.setState(() {
        standardFields.clear();
      });
      _standardFieldsDBHelper
          .getEntityStandardFieldsData(
            entity: StandardEntity.QUOTE_HEADER,
            showInGrid: false,
            showOnScreen: true,
          )
          .then((sfRes) => {
                if (sfRes.length > 0)
                  {
                    this.setState(() {
                      standardFields.addAll(sfRes);
                    }),
                  }
                else
                  {
                    print(
                        'Empty Response received from LocalDatabase for StandardFields in fetchQuoteHeaderSF FN'),
                  }
              })
          .catchError((e) => {
                print(
                    'Error while getting fetchQuoteHeaderSF Data from LocalDB'),
                print(e),
              });
    } catch (e) {
      print('Inside fetchQuoteHeaderSF Fn Error Catch Block ');
      print(e);
    }
  }

  ///FETCHES ONLY QUOTE_DETAIL STANDARD FIELDS
  void fetchQuoteDetailSF() {
    try {
      this.setState(() {
        standardFields.clear();
      });
      _standardFieldsDBHelper
          .getEntityStandardFieldsData(
            entity: StandardEntity.QUOTE_DETAIL,
            showInGrid: false,
            showOnScreen: true,
          )
          .then((sfRes) => {
                if (sfRes.length > 0)
                  {
                    this.setState(() {
                      standardFields.addAll(sfRes);
                    }),
                  }
                else
                  {
                    print(
                        'Empty Response received from LocalDatabase for StandardFields in fetchQuoteDetailSF FN'),
                  }
              })
          .catchError((e) => {
                print(
                    'Error while getting fetchQuoteDetailSF Data from LocalDB'),
                print(e),
              });
    } catch (e) {
      print('Inside fetchQuoteDetailSF Fn Error Catch Block ');
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
                    'STANDARD FIELDS CRUD',
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
                    'Total STANDARD_FIELDS DATA : ${standardFields.length}',
                    style:
                        TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
                ))),
              ],
            ),
            Row(
              children: <Widget>[
                getRaisedButton(
                  label: 'Fetch All StandardFields',
                  onPressedFn: handleGetStandardFields,
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
                  label: 'Fetch QuoteHeader Entity Fields',
                  onPressedFn: fetchQuoteHeaderSF,
                ),
                getRaisedButton(
                  label: 'Fetch QuoteDetail Entity Fields',
                  onPressedFn: fetchQuoteDetailSF,
                ),
              ],
            ),
            Row(
              children: <Widget>[
                getRaisedButton(
                  label: 'Insert API QuoteHeader Entity SF',
                  onPressedFn: insertAPIQuoteHeaderStandardFields,
                ),
                getRaisedButton(
                  label: 'Insert API QuoteDetail Entity SF',
                  onPressedFn: insertAPIQuoteDetailStandardFields,
                ),
              ],
            ),
//            Row(
//              children: <Widget>[
//                getRaisedButton(
//                  label: 'Set ALL ShowOnPreview true',
//                  onPressedFn: updateAllShowOnPreview,
//                ),
//              ],
//            ),
            Expanded(
              child: ListView.builder(
                itemCount: standardFields.length,
                itemBuilder: (context, position) {
                  return Column(
                    children: <Widget>[
                      Divider(
                        color: Colors.teal,
                        thickness: 2.0,
                      ),
                      Text('Id: ${standardFields[position].Id}'),
                      Text('TenantId: ${standardFields[position].TenantId}'),
                      Text('Entity: ${standardFields[position].Entity}'),
                      Text(
                          'SectionName: ${standardFields[position].SectionName}'),
                      Text('LabelName : ${standardFields[position].LabelName}'),
                      Text('FieldName : ${standardFields[position].FieldName}'),
                      Text(
                          'StandardFieldOn: ${standardFields[position].StandardFieldOn}'),
                      Text(
                          'ShowOnScreen: ${standardFields[position].ShowOnScreen}'),
                      Text(
                          'ShowInGrid:  ${standardFields[position].ShowInGrid}'),
                      Text('SortOrder:  ${standardFields[position].SortOrder}'),
                      Text(
                          'ShowOnPreview:  ${standardFields[position].ShowOnPreview}'),
                      Text(
                          'IsReadonly:  ${standardFields[position].IsReadonly}'),
                      Text(
                          'IsRequired:  ${standardFields[position].IsRequired}'),
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
