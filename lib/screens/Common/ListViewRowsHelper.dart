import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:moblesales/helpers/index.dart';
import 'package:moblesales/models/index.dart';

class ListViewRowsHelper {
  ///IMPORTANT NOTE :
  ///     HERE CURRENTLY IT's CHECKING FOR THE ON_GRID FIELDS
  ///     FOR SHOWING ON_SCREEN FIELDS JUST PASS THE IDENTIFICATION PARAMETER TO THE WIDGET
  ///     AND UPDATE THE CODE HERE FOR HANDLING THE ONSCREEN FIELDS FOR THE WIDGET
  ///
  ///IT RETURNS LIST ROW CARD CONTENTS LIST IF ONLY THEIR SHOW_IN_GRID VALUES ARE TRUE
  List<Widget> getRowCardContents({
    @required classObj,
    List<String> allowedEntitySections,
    @required bool isEntitySectionCheckDisabled,
    @required List<StandardField> standardFields,
    @required bool showOnGridFields,
    @required bool isExcludedFieldEnabled,
    List<String> excludedFieldsList,
    @required String currencyCaption,
    bool isProfile = false,
    bool isProduct = false,
  }) {
    List<Widget> _widgetsList = List<Widget>();
    try {
      if (isEntitySectionCheckDisabled == true ||
          allowedEntitySections != null) {
        for (var sf = 0; sf < standardFields.length; sf++) {
          if ((isEntitySectionCheckDisabled ||
                  allowedEntitySections //CHECK FOR DISPLAYING ONLY ALLOWED SECTION CONTENTS OR ALL CONTENTS
                      .contains(standardFields[sf].SectionName)) &&
              (showOnGridFields == true &&
                      standardFields[sf]
                          .ShowInGrid || //CHECK FOR DISPLAYING ON_SCREEN OR ON_GRID FIELDS
                  showOnGridFields == false &&
                      standardFields[sf]
                          .ShowOnScreen) && // FINAL CHECK FOR DISPLAYING ONLY FIELDS WHICH ARE PRESENT IN STANDARD_FIELDS LIST
              classObj.toJson().containsKey(standardFields[sf].FieldName) &&
              (isExcludedFieldEnabled ==
                      false || //CHECK TO CHECK IF ANY FIELDS NEEDS TO BE EXCLUDED FROM DISPLAYING ON VIEW
                  (isExcludedFieldEnabled == true &&
                      excludedFieldsList != null &&
                      excludedFieldsList.length > 0 &&
                      !excludedFieldsList
                          .contains(standardFields[sf].FieldName)))) {
            if (isProduct == true) {
              if (classObj.toJson()[standardFields[sf].FieldName] != '') {
                if (standardFields[sf].FieldName != 'Weight') {
                  _widgetsList.add(
                    getRowContentWidget(
                        standardFields[sf].LabelName,
                        attachCurrencyCode(
                          value:
                              '${classObj.toJson()[standardFields[sf].FieldName]}',
                          fieldName: standardFields[sf].FieldName,
                          currencyCaption: currencyCaption,
                        ),
                        isProfile,
                        isProduct),
                  );
                }
              }
            } else {
              _widgetsList.add(
                getRowContentWidget(
                    standardFields[sf].LabelName,
                    attachCurrencyCode(
                      value:
                          '${classObj.toJson()[standardFields[sf].FieldName]}',
                      fieldName: standardFields[sf].FieldName,
                      currencyCaption: currencyCaption,
                    ),
                    isProfile,
                    isProduct),
              );
            }
          }
        }

        // Added By Gaurav, 21-09-2021
        var key = 'IsReportAvailable';
        var value = '';
        if (classObj.toJson().containsKey(key)) {
          if (classObj.toJson()[key] == true) {
            value = 'Downloaded';
          } else {
            value = 'Not Downloaded';
          }
          _widgetsList.add(
            getRowContentWidget(
                'Report Status',
                attachCurrencyCode(
                  value: value,
                  fieldName: 'Report Status',
                  currencyCaption: currencyCaption,
                ),
                isProfile,
                isProduct),
          );
        }
        //end
      } else {
        ///NOTE : TO DISPLAY THE LIST PROVIDE ALLOWED SECTION NAMES FOR THE WIDGET
        print(
            '------PROVIDE the allowedEntitySections String List to only display allowed Section contents in the list -------------');
      }
      return _widgetsList;
    } catch (e) {
      print('Error inside getRowCardContents Fn ');
      print(e);
      return [];
    }
  }

  ///IT ATTACHES THE CURRENCY SYMBOL IF THE FIELD_NAME MATCHES WITH THE CURRENCY_FIELDS MAINTAINED
  ///INSIDE THE COMMON CONSTANTS FILE
  String attachCurrencyCode({
    String value,
    String fieldName,
    String currencyCaption,
  }) {
    String _newValue;

    ///IF VALUE IS NOT NULL AND FIELD IS CURRENCY FIELD THEN ADDING THE CURRENCY SIGN PROVIDED
    if (value != null &&
        CurrencyFields.contains(fieldName) &&
        currencyCaption != null &&
        currencyCaption != '') {
      _newValue = '${HtmlUnescape().convert(currencyCaption)} ' + value;
    } else {
      if (value.toLowerCase() == 'true') {
        _newValue = 'Yes';
      } else if (value.toLowerCase() == 'false') {
        _newValue = 'No';
      } else {
        _newValue = value != null && value != 'null' ? value : '';
      }
    }

    return _newValue;
  }

  ///IT RETURNS THE ACTUAL LIST ROWS CARD CONTENTS IN THE KEY VALUE PAIR
  Widget getRowContentWidget(
      keyText, keyValue, bool isProfile, bool isProduct) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(
            15.0, 5.0, 10.0, 5.0), //Card Record Contents padding
        child: isProfile
            ? Container(
                width: double.infinity,
                padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '$keyText',
                      style: TextStyle(color: AppColors.blue, fontSize: 12),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      '${keyValue != null ? '$keyValue' : '-'}',
                      style: TextStyle(
                          color: AppColors.black,
                          fontSize: 17,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Divider(
                      height: 1,
                      color: AppColors.lightGrey,
                    )
                  ],
                ),
              )
            : isProduct
                ? Text(
                    ' ${keyValue != null ? '$keyValue' : '-'}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: AppColors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          '$keyText',
                          style: TextStyle(
                            color: AppColors.grey,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Expanded(
                        child: Text(
                          '${keyValue != null ? '$keyValue' : '-'}',
                          style: TextStyle(
                              color: AppColors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ));
  }

  Widget getForProfile() {}

  Widget getRowCard({
    classObj,
    List<String> allowedEntitySections,
    bool isEntitySectionCheckDisabled,
    List<StandardField> standardFields,
    bool showOnGridFields,
    bool isExcludedFieldEnabled,
    List<String> excludedFieldsList,
    String currencyCaption,
  }) {
    print('have Checkbox');
    return Card(
      elevation: 1.0,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  0.0, 10.0, 0.0, 10.0), //CARDS CONTENTS INSIDE PADDING
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  ...getRowCardContents(
                    classObj: classObj,
                    isEntitySectionCheckDisabled: isEntitySectionCheckDisabled,
                    showOnGridFields: showOnGridFields,
                    standardFields: standardFields,
                    isExcludedFieldEnabled: isExcludedFieldEnabled,
                    excludedFieldsList:
                        excludedFieldsList != null ? excludedFieldsList : [],
                    currencyCaption: currencyCaption,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  ///IT HANDLES ALL THE BUTTONS UI AND ACTIONS FOR THE LIST VIEW
  ///IT REQUIRES
  ///           title : BUTTON_TITLE
  ///           recordPosition:  RECORD_CLICK_POSITION FROM THE LIST
  ///           clickAction : FUNCTION NAVE TO PERFORM THE SPECIFIC ACTION ON THE CLICK
  Widget getActionButton(
    String title,
    int recordPosition,
    Function clickAction,
    Color buttonColor,
  ) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
        child: RaisedButton(
          onPressed: () {
            print('Action Button Clicked for row $recordPosition');
            clickAction(recordPosition);
          },
          color: buttonColor,
          child: Text(
            '$title',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget getQuotePreviewRow({
    AddQuote addQuoteObj,
    List<StandardField> standardFields,
    String previewSectionName,
    bool showQuoteHeaderFields,
    String currencySymbol,
  }) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
                0.0, 10.0, 0.0, 10.0), //CARDS CONTENTS INSIDE PADDING
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: getQuotePreviewRowCardContents(
                addQuoteObj: addQuoteObj,
                standardFields: standardFields,
                previewSectionName: previewSectionName,
                showQuoteHeaderFields: showQuoteHeaderFields,
                currencySymbol: currencySymbol,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget getQuoteDetailSectionPreviewRow({
    AddQuote addQuoteObj,
    List<StandardField> standardFields,
    String previewSectionName,
    bool showQuoteHeaderFields,
    String currencySymbol,
  }) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
                0.0, 10.0, 0.0, 10.0), //CARDS CONTENTS INSIDE PADDING
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: getQuotePreviewRowCardContents(
                addQuoteObj: addQuoteObj,
                standardFields: standardFields,
                previewSectionName: previewSectionName,
                showQuoteHeaderFields: showQuoteHeaderFields,
                currencySymbol: currencySymbol,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String getQuotePreviewCurrencyFieldValue({
    @required String fieldName,
    @required String currencyValue,
    @required String value,
  }) {
    String _value = '';
    if (CurrencyFields.contains(fieldName)) {
      _value = '$currencyValue $value';
    } else {
      _value = value;
    }
    return _value;
  }

  ///IT RETURNS LIST ROW CARD CONTENTS LIST IF ONLY THEIR SHOW_ON_PREVIEW VALUES ARE TRUE
  List<Widget> getQuotePreviewRowCardContents({
    AddQuote addQuoteObj,
    List<StandardField> standardFields,
    String previewSectionName,
    bool showQuoteHeaderFields,
    String currencySymbol,
  }) {
    List<Widget> _widgetsList = List<Widget>();
    try {
      if (showQuoteHeaderFields) {
        addQuoteObj.QuoteHeader.forEach((singleQuoteHeader) {
          for (var sf = 0; sf < standardFields.length; sf++) {
            if (previewSectionName == standardFields[sf].SectionName) {
              for (var qhf = 0;
                  qhf < singleQuoteHeader.QuoteHeaderFields.length;
                  qhf++) {
                QuoteHeaderField _quoteHeaderField =
                    singleQuoteHeader.QuoteHeaderFields[qhf];
                if (_quoteHeaderField.FieldName ==
                    standardFields[sf].FieldName) {
                  var _fieldValue = _quoteHeaderField.FieldValue;

                  ///IF FIELD IS DOCUMENT_DATE THEN SHOWING THE TRANSFORMED DATE
                  if (previewSectionName == "Title" &&
                      standardFields[sf].FieldName == "DocumentDate")
                    // _fieldValue = transformDate(dateValue: _quoteHeaderField.FieldValue);
                    _fieldValue =
                        Other().DisplayDate(_quoteHeaderField.FieldValue);
                  _widgetsList.add(
                    getQuotePreviewRowContentWidget(
                        keyText: standardFields[sf].LabelName,
//                        keyValue: _quoteHeaderField.FieldValue,
                        keyValue: getQuotePreviewCurrencyFieldValue(
                          fieldName: standardFields[sf].FieldName,
                          currencyValue: currencySymbol,
                          value: _fieldValue,
                        ),
                        keyTextStyle: TextStyle(
                          color: AppColors.grey,
                          fontSize: 15,
                        )),
                  );
                  break;
                }
              }
            }
          }
        });
      } else {
        addQuoteObj.QuoteDetail.forEach((singleQuoteDetail) {
          List<Widget> _detailsRows = List<Widget>();
          for (var sf = 0; sf < standardFields.length; sf++) {
            if (previewSectionName == standardFields[sf].SectionName) {
              for (var qdf = 0;
                  qdf < singleQuoteDetail.QuoteDetailFields.length;
                  qdf++) {
                QuoteDetailField _quoteDetailField =
                    singleQuoteDetail.QuoteDetailFields[qdf];
                if (_quoteDetailField.FieldName ==
                    standardFields[sf].FieldName) {
                  _detailsRows.add(
                    getQuoteDetailSectionPreviewRowContent(
                      keyText: standardFields[sf].LabelName,
//                      keyValue: _quoteDetailField.FieldValue,
                      keyValue: getQuotePreviewCurrencyFieldValue(
                        fieldName: standardFields[sf].FieldName,
                        currencyValue: currencySymbol,
                        value: _quoteDetailField.FieldValue,
                      ),
                      keyTextStyle:
                          TextStyle(color: AppColors.grey, fontSize: 15),
                    ),
                  );
                  break;
                }
              }
            }
          }

          if (_detailsRows.length > 0) {
            _widgetsList.add(
              getPreviewDetailsRowCard(
                singleDetailFields: _detailsRows,
              ),
            );
          }
        });
      }
      return _widgetsList;
    } catch (e) {
      print('Error inside getQuotePreviewRowCardContentsFn ');
      print(e);
      return [];
    }
  }

  List<Widget> getSingleDetailPreviewRows({
    AddQuoteDetail singleQuoteDetail,
    List<StandardField> standardFields,
    String previewSectionName,
    bool showQuoteHeaderFields,
    String currencySymbol,
  }) {
    List<Widget> _detailsRows = List<Widget>();
    for (var sf = 0; sf < standardFields.length; sf++) {
      if (previewSectionName == standardFields[sf].SectionName) {
        for (var qdf = 0;
            qdf < singleQuoteDetail.QuoteDetailFields.length;
            qdf++) {
          QuoteDetailField _quoteDetailField =
              singleQuoteDetail.QuoteDetailFields[qdf];
          if (_quoteDetailField.FieldName == standardFields[sf].FieldName) {
            _detailsRows.add(
              getQuoteDetailSectionPreviewRowContent(
                keyText: standardFields[sf].LabelName,
//                keyValue: _quoteDetailField.FieldValue,
                keyValue: getQuotePreviewCurrencyFieldValue(
                  fieldName: standardFields[sf].FieldName,
                  currencyValue: currencySymbol,
                  value: _quoteDetailField.FieldValue,
                ),
                keyTextStyle: TextStyle(color: AppColors.grey, fontSize: 15),
              ),
            );
            break;
          }
        }
      }
    }

    return _detailsRows;
  }

  Widget getPreviewDetailsRowCard({
    List<Widget> singleDetailFields,
  }) {
    return Container(
      child: Card(
        child: Column(
          children: singleDetailFields,
        ),
      ),
    );
  }

  ///IT RETURNS THE ACTUAL LIST ROWS CARD CONTENTS IN THE KEY VALUE PAIR
  Widget getQuotePreviewRowContentWidget({
    @required String keyText,
    @required keyValue,
    @required TextStyle keyTextStyle,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          15.0, 5.0, 15.0, 5.0), //Card Record Contents padding
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              '$keyText',
              style: keyTextStyle,
            ),
          ),
          Expanded(
            child: Text(
              '${keyValue != null ? '$keyValue' : '-'}',
              style: TextStyle(
                color: AppColors.black,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  ///IT RETURNS THE ACTUAL LIST ROWS CARD CONTENTS IN THE KEY VALUE PAIR
  Widget getQuoteDetailSectionPreviewRowContent({
    @required String keyText,
    @required keyValue,
    @required TextStyle keyTextStyle,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          15.0, 5.0, 15.0, 5.0), //Card Record Contents padding
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              '$keyText',
              style: keyTextStyle,
            ),
          ),
          Expanded(
            child: Text(
              '${keyValue != null ? '$keyValue' : '-'}',
              style: TextStyle(
                color: AppColors.black,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
