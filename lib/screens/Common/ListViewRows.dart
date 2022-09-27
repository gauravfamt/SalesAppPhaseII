import 'package:flutter/material.dart';
import 'package:moblesales/helpers/index.dart';
import 'package:moblesales/models/index.dart';
import 'package:moblesales/screens/index.dart';

class ListViewRows extends StatelessWidget {
  final ListViewRowsHelper _listViewRowsHelper = ListViewRowsHelper();

  ///TO MAKE THIS WIDGET GENERIC RECORD_OBJ TYPE IS NOT DEFINED (e.g SalesOrders/Invoice)
  final recordObj;

  ///IT IS THE RECORD POSITION TO HANDLE THE CLICK ON THE SINGLE RECORD
  final int recordPosition;

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
  final List<Row> actionButtonRows;

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

  ListViewRows({
    @required this.recordObj,
    @required this.standardFields,
    @required this.recordPosition,
    @required this.isActionsEnabled,
    this.allowedEntitySections,
    @required this.isEntitySectionCheckDisabled,
    @required this.actionButtonRows,
    @required this.showOnGridFields,
    @required this.isExcludedFieldEnabled,
    this.excludedFieldsList,
    this.currencyCaption,
    this.isCheckBoxVisible = false,
    this.handleCheckBoxOnChange,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
                0.0, 0.0, 0.0, 15.0), //CARDS OUTSIDE PADDING
            child: Card(
              elevation: 0.0,
              color: !isCheckBoxVisible
                  ? Colors
                      .white //IF CHECKBOX NOT VISIBLE THEN DEFAULT WHITE_COLOR
                  : (recordObj.IsSelected
                      ? Colors.grey
                          .shade200 //IF CHECKBOX VISIBLE AND SELECTED THEN GREY SHADE COLOR
                      : Colors
                          .white), //IF CHECKBOX VISIBLE AND NOT SELECTED THEN DEFAULT WHITE COLOR
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                          0.0, 10.0, 0.0, 10.0), //CARDS CONTENTS INSIDE PADDING
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          ///IF CHECKBOX_IS VISIBLE THEN SHOWING THE CHECKBOX ALONG_SIDE
                          ///WITH ROW CONTENTS
                          isCheckBoxVisible
                              ? Row(
                                  children: <Widget>[
                                    Expanded(
                                      flex: 1,
                                      child: Column(
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                15.0, 0.0, 0.0, 0.0),
                                            child: Checkbox(
                                              activeColor: AppColors.blue,
                                              value: recordObj.IsSelected,
                                              onChanged:
                                                  recordObj.IsReportAvailable ==
                                                          false
                                                      ? null
                                                      : (isChecked) {
                                                          print(
                                                              'Checkbox clicked: ${recordObj.IsReportAvailable} ');
                                                          if (handleCheckBoxOnChange !=
                                                              null)
                                                            handleCheckBoxOnChange(
                                                                isChecked,
                                                                recordPosition);
                                                        },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 15,
                                      child: GestureDetector(
                                        onTap:
                                            recordObj.IsReportAvailable == false
                                                ? null
                                                : () {
                                                    print(
                                                        'Gesture detector for Checkbox clicked: ');
                                                    if (handleCheckBoxOnChange !=
                                                        null)
                                                      handleCheckBoxOnChange(
                                                          !recordObj.IsSelected,
                                                          recordPosition);
                                                  },
                                        child: Column(
                                          children: <Widget>[
                                            ///IT RETURNS THE ROW_CONTENTS FOR THE SINGLE ROW
                                            ..._listViewRowsHelper
                                                .getRowCardContents(
                                              standardFields: standardFields,
                                              showOnGridFields:
                                                  showOnGridFields,
                                              isEntitySectionCheckDisabled:
                                                  isEntitySectionCheckDisabled,
                                              classObj: recordObj,
                                              allowedEntitySections:
                                                  allowedEntitySections,
                                              isExcludedFieldEnabled:
                                                  isExcludedFieldEnabled,
                                              excludedFieldsList:
                                                  excludedFieldsList,
                                              currencyCaption: currencyCaption,
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                )
                              :

                              ///IF CHECKBOX IS NOT VISIBLE THEN SHOWING NORMAL ROWS VIEW
                              Column(
                                  children: <Widget>[
                                    ..._listViewRowsHelper.getRowCardContents(
                                      standardFields: standardFields,
                                      showOnGridFields: showOnGridFields,
                                      isEntitySectionCheckDisabled:
                                          isEntitySectionCheckDisabled,
                                      classObj: recordObj,
                                      allowedEntitySections:
                                          allowedEntitySections,
                                      isExcludedFieldEnabled:
                                          isExcludedFieldEnabled,
                                      excludedFieldsList: excludedFieldsList,
                                      currencyCaption: currencyCaption,
                                    ),
                                  ],
                                ),

                          ///HERE IF NAVIGATION IS NOT NEEDED THE HIDING THE DIVIDER WIDGET
                          Visibility(
                            visible: isActionsEnabled,
                            child: Column(
                              children: <Widget>[
                                Divider(
                                  thickness: 2.0,
                                  color: AppColors.grey,
                                ),

                                ///HERE IF THE ACTIONS ARE ALLOWED
                                ///THEN LISTING THE ACTIONS PROVIDED BY THE PARENT WIDGET
                                ...actionButtonRows
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
