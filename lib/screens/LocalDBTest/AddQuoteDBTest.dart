import 'dart:async';
import 'package:flutter/material.dart';
import 'package:moblesales/helpers/index.dart';
import 'package:moblesales/models/index.dart';
import 'package:moblesales/screens/index.dart';
import 'package:moblesales/utils/index.dart';

class AddQuoteDBTestScreen extends StatefulWidget {
  @override
  _AddQuoteDBTestScreenState createState() => _AddQuoteDBTestScreenState();
}

class _AddQuoteDBTestScreenState extends State<AddQuoteDBTestScreen> {
  ///HOLDS THE CLASS OBJECT WHICH PROVIDES STANDARD_FIELDS LOCAL TABLE CRUD OPERATIONS
  StandardFieldsDBHelper _standardFieldsDBHelper;

  ///HOLDS THE CLASS OBJECT WHICH CONTAINS THE REUSABLE WIDGETS
  CommonWidgets _commonWidgets;

  ///MAIN ADD_QUOTE_DB_HELPER CLASS OBJECT
  AddQuoteDBHelper _addQuoteDBHelper;

  ///MAIN ADD_QUOTE_HEADER_DB_HELPER CLASS OBJECT
  AddQuoteHeaderDBHelper _addQuoteHeaderDBHelper;

  ///MAIN ADD_QUOTE_DETAIL_DB_HELPER CLASS OBJECT
  AddQuoteDetailDBHelper _addQuoteDetailDBHelper;

  ///HOLDS ALL THE OFFLINE ADDED QUOTES LIST
  List<AddQuote> _addQuotes;

  ///HOLDS STANDARD_FIELDS FOR THE QUOTE_HEADER ON_SCREEN ENTITY
  List<StandardField> _headersOnScreenStandardFields;

  ///HOLDS STANDARD_FIELDS FOR THE QUOTE_DETAIL ON_SCREEN ENTITY
  List<StandardField> _detailsOnScreenStandardFields;

  List<QuoteDetailField> _quoteDetailFields;

  @override
  void initState() {
    super.initState();
    _addQuoteDBHelper = AddQuoteDBHelper();
    _addQuoteHeaderDBHelper = AddQuoteHeaderDBHelper();
    _addQuoteDetailDBHelper = AddQuoteDetailDBHelper();
    _addQuotes = List<AddQuote>();
    _quoteDetailFields = List<QuoteDetailField>();
    _standardFieldsDBHelper = StandardFieldsDBHelper();
    _commonWidgets = CommonWidgets();
    _headersOnScreenStandardFields = List<StandardField>();
    _detailsOnScreenStandardFields = List<StandardField>();
    fetchQuoteHeaderOnScreenFields();
  }

  void fetchQuoteHeaderOnScreenFields() {
    _standardFieldsDBHelper
        .getEntityStandardFieldsData(
          entity: StandardEntity.QUOTE_HEADER,
          showInGrid: false,
          showOnScreen: true,
        )
        .then((value) => {
              ///HERE CHECKING IF STANDARD FIELDS RESPONSE DID'T RECEIVED THEN NOT CALLING THE GET_DATA_API
              if (value.length > 0)
                {
                  ///SORTING THE STANDARD_FIELDS ACCORDING TO SORT_ORDER
                  value.sort((a, b) => a.SortOrder.compareTo(b.SortOrder)),
                  setState(() {
                    _headersOnScreenStandardFields = value;
                  }),

                  ///CALLING THE QUOTE_DETAILS STANDARD FIELDS FETCH API
                  fetchQuoteDetailOnScreenFields(),
                }
              else
                {
                  print(
                      'Standard Fields not available for the OrderHeader Entity '),
                  showErrorToast('Try again later!'),
                }
            })
        .catchError((onError) => {
              print(
                  'Error while fetching OnScreen StandardFields for the OrderHeader Entity on ADD_Quote page'),
              print(onError),
              showErrorToast('Try again later!')
            });
  }

  ///IT FETCHES THE ORDER_DETAIL STANDARD FIELDS FROM THE LOCAL DATABASE FOR ON_SCREEN_SHOW FIELDS SHOW
  void fetchQuoteDetailOnScreenFields() {
    _standardFieldsDBHelper
        .getEntityStandardFieldsData(
          entity: StandardEntity.QUOTE_DETAIL,
          showInGrid: false,
          showOnScreen: true,
        )
        .then((value) => {
              ///HERE CHECKING IF STANDARD FIELDS RESPONSE DID'T RECEIVED THEN NOT CALLING THE GET_DATA_API
              if (value.length > 0)
                {
                  ///SORTING THE STANDARD_FIELDS ACCORDING TO SORT_ORDER
                  value.sort((a, b) => a.SortOrder.compareTo(b.SortOrder)),
                  setState(() {
                    _detailsOnScreenStandardFields = value;
                  }),
                }
              else
                {
                  print(
                      'Standard Fields not available for the Order_detail Entity '),
                  showErrorToast('Try again later!'),
                }
            })
        .catchError((onError) => {
              print(
                  'Error while fetching OnScreen StandardFields for the QuoteDetail Entity on ADD_Quote page'),
              print(onError),
              showErrorToast('Try again later!')
            });
  }

  ///IT GENERATES THE QUOTE HEADERS FIELDS FOR DISPLAYING ON THE UI
  void generateQuoteHeadersFieldsList() {
//    List<AddQuoteHeader> _temp = List<AddQuoteHeader>();
//    _headersOnScreenStandardFields.forEach((singleSF) {
//      _temp.add(
//        AddQuoteHeader(
//          FieldValue: '',
//          FieldName: singleSF.FieldName,
//          LabelName: singleSF.LabelName,
//        ),
//      );
//    });
  }

  ///IT SHOWS THE FLUTTER ERROR TOAST IF API ERROR IS RETURNED
  void showErrorToast(String msg) {
    _commonWidgets.showFlutterToast(toastMsg: msg);
  }

  void fetchQuoteById() async {
    fetchAllQuotes(quoteId: 16);
  }

  void fetchQuoteDetailFields() async {
    try {
      this.setState(() {
        _quoteDetailFields.clear();
      });
      _addQuoteDetailDBHelper
          .getAllDetailFields()
          .then((value) => {
                if (value.length > 0)
                  {
                    this.setState(() {
                      _quoteDetailFields.addAll(value);
                    }),
                  }
              })
          .catchError((e) => {
                print('Error Inside fetchQuoteDetailFields Fn '),
                print(e),
              });
    } catch (e) {
      print('Error Inside fetchQuoteDetailFields Fn ');
      print(e);
    }
  }

  void fetchAllQuotes({
    int quoteId,
  }) async {
    setState(() {
      _addQuotes.clear();
    });
    _addQuoteDBHelper
        .getQuotes(
          quoteId: quoteId,
        )
        .then((value) => {
              if (value.length > 0)
                {
                  print('Quotes Response Received'),
                  this.setState(() {
                    _addQuotes.addAll(value);
                  }),
                }
              else
                {
                  print('No Records present locally for AddQuote!'),
                }
            })
        .catchError((e) => {
              print(
                  '=============================================================================='),
              print(
                  '===============Error inside fetchAllQuotes Fn===================='),
              print(e),
            });
  }

  ///ADD THE SINGLE QUOTE
  void addSingleQuote() async {
    _addQuoteDBHelper
        .addSingleQuote()
        .then((value) => {
              print('addSingleQuote Success Response '),
              print(value),
              print('value.Id: ${value.Id} '),
              this.addQuoteHeader(
                quote: value,
              ),
//              this.fetchAllQuotes(),
            })
        .catchError((e) => {
              print('Error Inside addSingleQuote Fn '),
            });
  }

  ///IT ADDS THE QUOTE_HEADER TO THE ADD_QUOTE
  void addQuoteHeader({
    AddQuote quote,
  }) async {
    print(
        'Inserting Initial Default AddQuoteHeader Inside addQuoteHeader Function');
    try {
      List<QuoteHeaderField> _temp = List<QuoteHeaderField>();
      String _quoteHeaderRefId = RandomKeyGenerator.createCryptoRandomString();

      ///HERE ADDING THE _quoteHeaderRefId OF THE QUOTE_HEADER TO THE QuoteHeaderIds FIELD
      /// OF ADD QUOTE TO UPDATE IN DATABASE TO MAINTAIN THE RELATION_SHIP BETWEEN
      /// ADD_QUOTE AND ADD_QUOTE_HEADER
      quote.QuoteHeaderIds = getFormattedIdsString(
        splitText: ',',
        stringToSplit: quote.QuoteHeaderIds,
        newStringToAppend: '$_quoteHeaderRefId',
      );
      print('Updated quote.QuoteHeaderIds : ${quote.QuoteHeaderIds}');

      _headersOnScreenStandardFields.forEach((singleSF) {
        _temp.add(
          QuoteHeaderField(
            AddQuoteID: quote.Id,
            FieldName: singleSF.FieldName,
            LabelName: singleSF.LabelName,
            FieldValue: '',
            HeaderReferenceId: '$_quoteHeaderRefId',
          ),
        );
      });
      if (_temp.length > 0) {
        _addQuoteHeaderDBHelper
            .insertQuoteHeaderFields(
              headerFields: _temp,
              quoteHeaderReferenceId: _quoteHeaderRefId,
              quote: quote,
            )
            .then((value) => {
                  print('QuoteHeader Fields Insert Response '),
                  print(value),
                  quote.QuoteHeader.add(value),
                  addQuoteDetail(
                    quote: quote,
                  ),
                })
            .catchError((e) => {
                  print('QuoteHeader Fields Insert Error Response '),
                  print(e),
                  deleteQuoteByID(quoteId: quote.Id),
                });
      } else {
        print('_temp fields not Present for insertion ');
      }
    } catch (e) {
      print('Error Inside addQuoteHeader ');
      print(e);
      deleteQuoteByID(quoteId: quote.Id);
    }
  }

  ///IT ADDS THE QUOTE_DETAIL TO THE ADD_QUOTE OBJECT
  void addQuoteDetail({
    AddQuote quote,
  }) async {
    print(
        'Inserting Initial Default addQuoteDetail Inside addQuoteDetail Function');
    try {
      List<QuoteDetailField> _temp = List<QuoteDetailField>();
      String _quoteDetailRefId = RandomKeyGenerator.createCryptoRandomString();

      ///HERE ADDING THE _quoteHeaderRefId OF THE QUOTE_DETAIL TO THE QuoteDetailsIds FIELD
      /// OF ADD QUOTE TO UPDATE IN DATABASE TO MAINTAIN THE RELATION_SHIP BETWEEN
      /// ADD_QUOTE AND ADD_QUOTE_HEADER
      quote.QuoteDetailIds = getFormattedIdsString(
        splitText: ',',
        stringToSplit: quote.QuoteDetailIds,
        newStringToAppend: '$_quoteDetailRefId',
      );
      print('Updated quote.QuoteDetailIds : ${quote.QuoteDetailIds}');

      _detailsOnScreenStandardFields.forEach((singleSF) {
        _temp.add(
          QuoteDetailField(
            AddQuoteID: quote.Id,
            FieldName: singleSF.FieldName,
            LabelName: singleSF.LabelName,
            FieldValue: '',
            DetailReferenceId: '$_quoteDetailRefId',
          ),
        );
      });
      if (_temp.length > 0) {
        _addQuoteDetailDBHelper
            .insertQuoteDetailFields(
              detailFields: _temp,
              quoteDetailReferenceId: _quoteDetailRefId,
              quote: quote,
            )
            .then((value) => {
                  print('QuoteDetail Fields Insert Response '),
                  print(value),
                  quote.QuoteDetail.add(value),
                  this.setState(() {
                    _addQuotes.add(quote);
                  }),
                  this.fetchAllQuotes(),
                })
            .catchError((e) => {
                  print('QuoteDetails Fields Insert Error Response '),
                  print(e),
                  deleteQuoteByID(quoteId: quote.Id),
                });
      } else {
        print('_temp fields not Present for insertion ');
      }
    } catch (e) {
      print('Error Inside addQuoteDetail ');
      print(e);
      deleteQuoteByID(quoteId: quote.Id);
    }
  }

  ///IT SPLITS THE COMMA SEPARATED STRING AND BUILDS NEW STRING WITH
  ///NEW ID PROVIDED TO ATTACH THE MAIN ID'S STRING
  String getFormattedIdsString({
    String stringToSplit,
    String splitText,
    String newStringToAppend,
  }) {
    String _finalString = '';
    try {
      List<String> _list = stringToSplit.trim().split(splitText);
      _list.forEach((singleStr) {
        if (singleStr != null && singleStr.trim().length > 0)
          _finalString += '${singleStr.trim()},';
      });
      if (_finalString.trim().length > 0) {
        _finalString += newStringToAppend;
      } else {
        _finalString += newStringToAppend;
      }

      print('_finalString: $_finalString');
      return _finalString;
    } catch (e) {
      print('Error Inside getFormattedIdsString FN ');
      print(e);
      throw ErrorDescription('Error While Splitting');
    }
  }

  void addQuoteDetailToExistingQuote() async {
    try {
      if (_addQuotes.length > 0) {
        addQuoteDetail(
          quote: _addQuotes[0],
        );
      }
    } catch (e) {
      print('Error Inside addQuoteDetailToExistingQuote Fn ');
      print(e);
    }
  }

  void deleteQuoteByID({
    int quoteId,
  }) async {
    try {
      var _quoteHeaderDeleteRes =
          await _addQuoteHeaderDBHelper.deleteRowByQuoteId(addQuoteId: quoteId);
      print('Quote Headers Delete By QuoteID Res $_quoteHeaderDeleteRes');
      var _quoteDetailDeleteRes =
          await _addQuoteDetailDBHelper.deleteRowByQuoteId(addQuoteId: quoteId);
      print('Quote Details Delete By QuoteID Res $_addQuoteDetailDBHelper');
      var _quoteDeleteRes =
          await _addQuoteDBHelper.deleteRowById(addQuoteId: quoteId);
      print('Quote Delete By QuoteID Res $_quoteDeleteRes');
    } catch (e) {
      print('Error Inside deleteQuoteByID Fn ');
      print(e);
    }
  }

  ///DELETES ALL THE OFFLINE QUOTES FROM LOCAL DATABASE
  void deleteAllQuotes() async {
    try {
      ///DELETING QUOTE_HEADERS
      var _headerDeleteRes = await _addQuoteHeaderDBHelper.deleteALLRows();
      print('Quote Header Rows Deleted Response $_headerDeleteRes');

      ///DELETING QUOTE_DETAILS
      var _detailDeleteRes = await _addQuoteDetailDBHelper.deleteALLRows();
      print('Quote Detail Rows Deleted Response $_detailDeleteRes');

      ///DELETING ADD_QUOTE
      var _addQuoteDeleteRes = await _addQuoteDBHelper.deleteALLRows();
      print('Add Quote Rows Deleted Response $_addQuoteDeleteRes');

      fetchAllQuotes();
    } catch (e) {
      print('Error Inside deleteAllQuotes');
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

  ///IT BUILDS HEADER LIST
  List<Widget> buildQuoteHeaderList({
    List<AddQuoteHeader> quoteHeaders,
  }) {
    List<Widget> _list = List<Widget>();
    quoteHeaders.forEach(
      (singleQuoteHeader) {
        _list.add(
          Text('============${singleQuoteHeader.HeaderReferenceId}========='),
        );
        if (singleQuoteHeader.QuoteHeaderFields.length > 0) {
          singleQuoteHeader.QuoteHeaderFields.forEach(
            (singleField) {
              _list.add(getHeaderRowWidget(headerField: singleField));
            },
          );
        }
      },
    );
    return _list;
  }

  ///IT RETURNS HEADER KEY_VALUE PAIR ROW WIDGET
  Widget getHeaderRowWidget({
    QuoteHeaderField headerField,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Center(child: Text('${headerField.FieldName}')),
        ),
        Expanded(
          child: Center(child: Text('${headerField.FieldValue}')),
        ),
        Expanded(
          child: Center(child: Text('IsRequired : ${headerField.IsRequired}')),
        ),
        Expanded(
          child: Center(child: Text('IsReadonly : ${headerField.IsReadonly}')),
        ),
      ],
    );
  }

  List<Widget> buildQuoteDetailList({
    List<AddQuoteDetail> quoteDetails,
  }) {
    List<Widget> _list = List<Widget>();
    quoteDetails.forEach(
      (singleQuoteDetail) {
        _list.add(
          Text('============${singleQuoteDetail.DetailReferenceId}========='),
        );

        if (singleQuoteDetail.QuoteDetailFields.length > 0) {
          singleQuoteDetail.QuoteDetailFields.forEach(
            (singleField) {
              _list.add(getDetailRowWidget(detailField: singleField));
            },
          );
        } else {
          print('Quote QuoteDetailFields Not Present for the QuoteDetail');
        }
      },
    );
    return _list;
  }

  ///IT RETURNS DETAIL KEY_VALUE PAIR ROW WIDGET
  Widget getDetailRowWidget({
    QuoteDetailField detailField,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Center(child: Text('${detailField.LabelName}')),
        ),
        Expanded(
          child: Center(child: Text('${detailField.FieldValue}')),
        ),
        Expanded(
          child: Center(child: Text('IsRequired : ${detailField.IsRequired}')),
        ),
        Expanded(
          child: Center(child: Text('IsReadonly : ${detailField.IsReadonly}')),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('ADD QUOTE TEST'),
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
                    'ADD_QUOTE CRUD',
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
                        'Total OFFLINE Quotes DATA : ${_addQuotes.length}',
                        style: TextStyle(
                            fontSize: 20.0, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                getRaisedButton(
                  label: 'Fetch All Quotes',
                  onPressedFn: fetchAllQuotes,
                ),
                getRaisedButton(
                  label: 'Delete All Quotes',
                  onPressedFn: deleteAllQuotes,
                ),
              ],
            ),
            Row(
              children: <Widget>[
                getRaisedButton(
                  label: 'Add SingleQuote',
                  onPressedFn: addSingleQuote,
                ),
                getRaisedButton(
                  label: 'Generate RandomKey',
                  onPressedFn: () {
                    print(
                        'RandomKeyGenerator.createCryptoRandomString() : ${RandomKeyGenerator.createCryptoRandomString()}');
                  },
                ),
              ],
            ),
            Row(
              children: <Widget>[
                getRaisedButton(
                  label: 'Add QuoteDetail To Existing Quote',
                  onPressedFn: addQuoteDetailToExistingQuote,
                ),
                getRaisedButton(
                  label: 'Fetch Quote By ID',
                  onPressedFn: fetchQuoteById,
                ),
              ],
            ),
            Row(
              children: <Widget>[
                getRaisedButton(
                  label: 'Fetch Quote Detail Fields',
                  onPressedFn: fetchQuoteDetailFields,
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _addQuotes.length,
                itemBuilder: (context, position) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
                    child: Card(
                      child: Column(
                        children: <Widget>[
                          Text('ID: ${_addQuotes[position].Id}'),
                          Text(
                              'CreatedDate : ${transformDate(dateValue: '${_addQuotes[position].CreatedDate}', includeTime: true)}'),
                          Text(
                              'UpdatedDate: ${transformDate(dateValue: '${_addQuotes[position].UpdatedDate}', includeTime: true)}'),
                          Text(
                              'QuoteHeaderIds: ${_addQuotes[position].QuoteHeaderIds}'),
                          Text(
                              'QuoteDetailIds: ${_addQuotes[position].QuoteDetailIds}'),
                          Card(
                            child: Container(
                              color: AppColors.grey,
                              width: double.infinity,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    0.0, 10.0, 0.0, 10.0),
                                child: Column(
                                  children: <Widget>[
                                    Text(
                                        '============= Quote Headers ============='),
                                    Text(
                                        'QuoteHeader Length :${_addQuotes[position].QuoteHeader.length}'),
                                    ...buildQuoteHeaderList(
                                      quoteHeaders:
                                          _addQuotes[position].QuoteHeader,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Card(
                            child: Container(
                              color: AppColors.grey,
                              width: double.infinity,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    0.0, 10.0, 0.0, 10.0),
                                child: Column(
                                  children: <Widget>[
                                    Text(
                                        '============= Quote Details ============='),
                                    Text(
                                        'QuoteDetail Length :${_addQuotes[position].QuoteDetail.length}'),
                                    ...buildQuoteDetailList(
                                      quoteDetails:
                                          _addQuotes[position].QuoteDetail,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Text('All Offline QUOTE_DETAILS Fields '),
            Expanded(
              child: ListView.builder(
                itemCount: _quoteDetailFields.length,
                itemBuilder: (context, position) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
                    child: Card(
                      child: Column(
                        children: <Widget>[
                          Text('ID: ${_quoteDetailFields[position].FieldName}'),
                          Text(
                              'AddQuoteID: ${_quoteDetailFields[position].AddQuoteID}'),
                          Text(
                              'LabelName: ${_quoteDetailFields[position].LabelName}'),
                          Text(
                              'DetailReferenceId: ${_quoteDetailFields[position].DetailReferenceId}'),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
