import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:moblesales/helpers/index.dart';
import 'package:moblesales/models/index.dart';

class TableView extends StatelessWidget {
//  final ListViewRowsHelper _listViewRowsHelper = ListViewRowsHelper();

  ///TO MAKE THIS WIDGET GENERIC RECORD_OBJ TYPE IS NOT DEFINED (e.g SalesOrders/Invoice)
  // final recordObj;

  final List ListObject;

  ///IT IS THE RECORD POSITION TO HANDLE THE CLICK ON THE SINGLE RECORD
  // final int recordPosition;

  ///IT IS THE STANDARD_FIELDS_LIST WHICH NEEDS TO SENT TO DISPLAY ONLY ON_GRID_FIELDS
  final List<StandardField> standardFields;

  ///TO HIDE AND SHOW THE VIEW_DETAILS PAGE AND THE DIVIDER FROM THE ROWS
  final bool isActionsEnabled;

  ///IMPORTANT_NOTE:
  ///               PASS THE STANDARD_FIELDS SECTION NAMES WHICH ON_GRID VALUES NEEDED TO BE
  ///               LISTED ON THE FINAL LIST
  ///
  ///IT ONLY ALLOWS THE PROVIDED SECTIONS ON_GRID VALUES ON THE LIST
  ///IF NOT PROVIDED THEN SEND isEntitySectionCheckDisabled ARGUMENT VALUE TO true
  final List<String> allowedEntitySections;

  ///IF THE SECTION NAMES ARE NOT PROVIDED SEND THE VALUE OF THIS VARIABLE TO TRUE
  ///IT WILL CHECK ALL THE SECTION
  final bool isEntitySectionCheckDisabled;

  ///LISTING ACTION BUTTON ROWS ,
  ///EACH ROW MUST CONTAINS ONLY TWO BUTTONS OTHERWISE IT WILL GET CONGESTED ON SMALL DEVICES
  // final List<Row> actionButtonRows;

  final List<Row> Function(int recordPosition) actionButtonRows;

  /// THIS ARGUMENT MUST BE PROVIDED IF IT'S TRUE THEN IT WILL SHOW ONLY ON_GRID_STANDARD_FIELDS,
  /// IF IT's FALSE IT WILL SHOW THE ON_SCREEN FIELDS
  final bool showOnGridFields;

  ///IF NEEDED TO EXCLUDE ANY FIELD TO DISPLAY FROM STANDARD_FIELDS JUST PASS VALUE FOR THIS TO TRUE
  final bool isExcludedFieldEnabled;

  ///IF ANY FIELDS NEEDS TO BE EXCLUDED THEN JUST PASS THE EXCLUDE_FIELD NAMES LIST TO THIS PARAMETER
  final List<String> excludedFieldsList;

  ///HOLDS THE CURRENCY_CAPTION_VALUE
  final String currencyCaption;

  ///
  final bool isCheckBoxVisible;

  final Function(bool isSelected, int recordPosition) handleCheckBoxOnChange;

  final List<DataColumn> _Datacolumn = new List();
  final List<DataRow> _DataRow = List<DataRow>();

  int HeaderCount = 0;

  TableView({
    @required this.standardFields,
    @required this.isActionsEnabled,
    this.allowedEntitySections,
    @required this.isEntitySectionCheckDisabled,
    @required this.actionButtonRows,
    @required this.showOnGridFields,
    @required this.isExcludedFieldEnabled,
    this.excludedFieldsList,
    this.currencyCaption,
    this.isCheckBoxVisible,
    this.handleCheckBoxOnChange,
    this.ListObject,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        CreateTable(),
      ],
    );
  }

  List<DataColumn> GetColumn() {
    var recordObj = ListObject[0];
    //  print('Get Column');

    if (isCheckBoxVisible == true) {
      //  print('isCheckBoxVisible');
      _Datacolumn.add(DataColumn(
        label: Text(''), //For Add Checkbox
      ));
    }
    for (int sf = 0; sf < standardFields.length; sf++) {
      if ((isEntitySectionCheckDisabled ||
              allowedEntitySections //CHECK FOR DISPLAYING ONLY ALLOWED SECTION CONTENTS OR ALL CONTENTS
                  .contains(standardFields[sf].SectionName)) &&
          (showOnGridFields == true &&
                  standardFields[sf]
                      .ShowInGrid || //CHECK FOR DISPLAYING ON_SCREEN OR ON_GRID FIELDS
              showOnGridFields == false &&
                  standardFields[sf]
                      .ShowOnScreen) && // FINAL CHECK FOR DISPLAYING ONLY FIELDS WHICH ARE PRESENT IN STANDARD_FIELDS LIST
          recordObj.toJson().containsKey(standardFields[sf].FieldName) &&
          (isExcludedFieldEnabled ==
                  false || //CHECK TO CHECK IF ANY FIELDS NEEDS TO BE EXCLUDED FROM DISPLAYING ON VIEW
              (isExcludedFieldEnabled == true &&
                  excludedFieldsList != null &&
                  excludedFieldsList.length > 0 &&
                  !excludedFieldsList
                      .contains(standardFields[sf].FieldName)))) {
        _Datacolumn.add(DataColumn(
          tooltip: '${standardFields[sf].FieldName}',
          label: Text(
            '${standardFields[sf].LabelName}',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              letterSpacing: 1,
            ),
          ),
        ));
      }
    }
    if (isCheckBoxVisible == true) {
      // print('isCheckBoxVisible');
      _Datacolumn.add(DataColumn(
        label: Text('Report Status',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              letterSpacing: 1,
            )), //For Add Checkbox
      ));
    }
    if (isActionsEnabled == true) {
      //  print('isActionsEnabled');
      _Datacolumn.add(DataColumn(
        label: Text(''), //For Add button
      ));
    }

    HeaderCount = _Datacolumn.length;
    return _Datacolumn;
  }

  Widget CreateTable() {
    GetColumn();
//    print('standardFields.lengt ${standardFields.length}');
//    print('Length :${ListObject.length}');
//    print('Header Count :${HeaderCount}');
    if (isCheckBoxVisible == true) {
      HeaderCount = HeaderCount - 1;
    }
    // print('crete Rows');
    for (int i = 0; i < ListObject.length; i++) {
      List<DataCell> _DataCell = [];
      var Obj = ListObject[i];
      if (isCheckBoxVisible == true) {
        //   print('isCheckBoxVisible');
        _DataCell.add(DataCell(
          Row(
            children: <Widget>[
              Checkbox(
                activeColor: AppColors.blue,
                value: Obj.IsSelected,
                onChanged: Obj.IsReportAvailable == false
                    ? null
                    : (isChecked) {
                        //   print('Checkbox clicked: ');
                        if (handleCheckBoxOnChange != null)
                          handleCheckBoxOnChange(isChecked, i);
                      },
              ),
            ],
          ),
        ));
      }

      for (int j = 0; j < HeaderCount; j++) {
        if (j == HeaderCount - 2 && isCheckBoxVisible == true) {
          //Render buttons add at last row
          _DataCell.add(DataCell(
            Row(
              children: <Widget>[
                Obj.IsReportAvailable == true
                    ? Text(
                        'Downloded',
                        style: TextStyle(
                          //fontWeight: FontWeight.bold,
                          fontSize: 10,
                          // color: AppColors.blue,
                        ),
                      )
                    : Text(
                        'Not Downloaded',
                        style: TextStyle(
                          //fontWeight: FontWeight.bold,
                          fontSize: 10,
                          //color: AppColors.blue,
                        ),
                      ),
              ],
            ),
          ));
        } else if (j == HeaderCount - 1) {
          //Render buttons add at last row
          _DataCell.add(DataCell(
            Column(
              children: actionButtonRows(i),
            ),
          ));
        } else {
          //Modified by Gaurav, 19-01-2021
          String strValue;
          if (isCheckBoxVisible == true) {
            strValue = Obj.toJson()[_Datacolumn[j + 1].tooltip].toString();
          } else {
            strValue = Obj.toJson()[_Datacolumn[j].tooltip].toString();
          }
          _DataCell.add(DataCell(Text(
            '${attachCurrencyCode(
              value: strValue, //tooltip == Standard field name
              fieldName: _Datacolumn[j].tooltip,
              currencyCaption: currencyCaption,
            )}',
            style: TextStyle(
              fontSize: 16,
            ),
          )));
        }
      }
      _DataRow.add(
        DataRow(cells: _DataCell),
      );
    }
    // print('Length ${_DataRow.length}');
    return Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: DataTable(
            columns: _Datacolumn,
            rows: _DataRow,
          ),
        ),
      ),
    );
  }

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
    } else if (value.toLowerCase() == 'true') {
      _newValue = 'Yes';
    } else if (value.toLowerCase() == 'false') {
      _newValue = 'No';
    } else {
      _newValue = value != null && value != 'null' ? value : '';
    }
    return _newValue;
  }
}
