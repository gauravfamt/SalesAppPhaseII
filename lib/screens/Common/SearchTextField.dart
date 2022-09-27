import 'package:flutter/material.dart';
import 'package:moblesales/helpers/index.dart';
import 'package:moblesales/screens/index.dart';

class SearchTextField extends StatefulWidget {
  ///HOLDS THE SEARCH STRING
  final String searchFieldContent;

  final String placeHolder;

  ///FUNCTION WHICH HANDLES THE SEARCH TEXT SEARCH BUTTON CLICKED
  final Function(String searchContent) handleTextFieldSearch;

  ///FUNCTION WHICH HANDLES THE CLEAR SEARCH BUTTON CLICK
  final VoidCallback clearTextFieldSearch;

  ///TO APPLY DIFFERENT PADDING WHEN WIDGET VIEWED IN LOOKUP'S UI
  final bool forLookupType;

  ///TO SHOW SEARCH TEXT CARD
  final bool isShowSearchCard;

  ///TO SHOW BARCODE SCANNER OPTION
  final bool showBarcodeScanner;

  ///FUNCTION WHICH HANDLES THE BARCODE SCANNER BUTTON CLICK
  final VoidCallback barcodeScannerHandler;

  ///HOLDS TEXT_FIELD_CONTROLLER
  final TextEditingController searchTFController;

  SearchTextField({
    @required this.searchFieldContent,
    @required this.handleTextFieldSearch,
    @required this.clearTextFieldSearch,
    this.forLookupType = false,
    this.searchTFController,
    this.isShowSearchCard = false,
    this.showBarcodeScanner = false,
    this.barcodeScannerHandler,
    this.placeHolder = '',
  });

  @override
  _SearchTextFieldState createState() => _SearchTextFieldState();
}

class _SearchTextFieldState extends State<SearchTextField> {
  ///HOLDS THE CLASS OBJECT WHICH CONTAINS THE REUSABLE WIDGETS
  CommonWidgets _commonWidgets;

  TextEditingController searchTFController;

  ///HOLDS CARD PADDING
  EdgeInsets _cardPadding;

  ///HOLDS CARD CONTENT PADDING
  EdgeInsets _cardContentPadding;

  ///HOLDS SEARCH_TEXT_FIELD SEARCH/CANCEL ICON PADDING
  EdgeInsets _searchActionIconPadding;

  String _previusSearch = '*';

  @override
  void initState() {
    super.initState();
    _commonWidgets = CommonWidgets();
    searchTFController = widget.searchTFController != null
        ? widget.searchTFController
        : TextEditingController();
    if (widget.forLookupType) {
      //PADDING IF TEXT_FIELD OPENED FOR LOOKUP VIEW
      _cardPadding = const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 5.0);
      _cardContentPadding = const EdgeInsets.all(0.0);
      _searchActionIconPadding = const EdgeInsets.fromLTRB(0.0, 0.0, 5.0, 0.0);
    } else {
      //PADDING IF SEARCH_TEXT_FIELD OPENED IN NORMAL LISTING VIEW
      _cardContentPadding = const EdgeInsets.all(20.0);
      _cardPadding = const EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 0.0);
      _searchActionIconPadding = const EdgeInsets.fromLTRB(0.0, 0.0, 15.0, 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          child: Expanded(
            child: Padding(
              padding: _cardPadding,
              child: Card(
                elevation: widget.isShowSearchCard ? 3.0 : 0.0,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: widget.isShowSearchCard
                            ? const EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0)
                            : const EdgeInsets.all(0.0),
                        child: TextField(
                          controller: searchTFController,
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'OpenSans',
                          ),
                          decoration: InputDecoration(
                            hintText:
                                '${widget.placeHolder != "" ? widget.placeHolder : CommonConstants.SEARCH_PLACEHOLDER_MSG}',
                            hintStyle: TextStyle(
                              color: AppColors.grey,
                              fontFamily: 'OpenSans',
                            ),
                            border: InputBorder.none,
                            contentPadding: _cardContentPadding,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                        flex: 0,
                        child: Padding(
//                          padding: _searchActionIconPadding,
                          padding: EdgeInsets.all(0.0),
                          child: Row(
                            children: <Widget>[
                              ///CLEAR SEARCH BUTTON
                              Visibility(
                                visible: widget.searchFieldContent != null &&
                                    widget.searchFieldContent.trim().length > 0,
                                child:
                                    _commonWidgets.getCustomSearchClearButton(
                                  onPressedHandler: () {
                                    print(
                                        'Search TextField Cancel Btn Pressed');
                                    searchTFController.clear();
                                    _previusSearch = '*';
                                    widget.clearTextFieldSearch();
                                  },
                                  buttonIcon: Icon(
                                    Icons.clear,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),

                              ///SEARCH BUTTON
                              _commonWidgets.getCustomSearchActionButton(
                                onPressedHandler: () {
                                  print('Search TextField Search Btn Pressed');

                                  ///HERE IF VALUE IS NOT PRESENT THEN RETURNING EMPTY STRING VALUE
                                  String _textValue =
                                      searchTFController.text != null &&
                                              searchTFController.text
                                                      .trim()
                                                      .length >
                                                  0
                                          ? searchTFController.text
                                          : '';
                                  print('Text Value $_textValue ');
//                                 if(_textValue.length>0 )//<<--To avoid duplicate data which was displyed in list, Added by Gaurav. 10-07-2020
//                                    {
//                                     _previusSearch=_textValue;
//                                     widget.handleTextFieldSearch(_textValue);
//                                    }
                                  widget.handleTextFieldSearch(_textValue);
                                },
                                buttonIcon: Icon(
                                  Icons.search,
                                  color: Colors.white,
                                ),
                              ),

                              ///BARCODE SCANNER BUTTON
                              Visibility(
                                visible: widget.showBarcodeScanner,
                                child:
                                    _commonWidgets.getCustomSearchActionButton(
                                  onPressedHandler:
                                      widget.barcodeScannerHandler,
                                  buttonIcon:
                                      Image.asset('assets/img/scan_white.png'),
                                ),
                              ),
                            ],
                          ),
                        ))
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
