import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moblesales/helpers/index.dart';
import 'package:moblesales/models/index.dart';
import 'package:moblesales/screens/index.dart';

class QuotePreviewScreen extends StatefulWidget {
  ///IT HANDLES THE CLOSE DIALOG EVENT
  final VoidCallback closePreviewDialog;

  ///HOLDS QUOTE HEADERS STANDARD_FIELDS FOR PREVIEW
  final List<StandardField> quoteHeaderPreviewStandardFields;

  ///HOLDS QUOTE DETAILS STANDARD_FIELDS FOR PREVIEW
  final List<StandardField> quoteDetailPreviewStandardFields;

  ///HOLDS ALL THE MAIN QUOTE OBJECT WHICH CONTAINS THE QUOTE_HEADERS AND QUOTE_DETAILS LIST
  final AddQuote addQuoteObj;

  ///HOLDS THE CURRENCY SYMBOL TO SHOW ON DISPLAY
  final String currencySymbol;

  ///HOLDS TOTAL WEIGHT FOR PREVIEW
  final double totalWeight;

  ///HOLDS TOTAL QUANTITY FOR PREVIEW
  final int totalQuantity;

  QuotePreviewScreen({
    @required this.closePreviewDialog,
    @required this.quoteDetailPreviewStandardFields,
    @required this.quoteHeaderPreviewStandardFields,
    @required this.addQuoteObj,
    @required this.currencySymbol,
    @required this.totalWeight,
    @required this.totalQuantity,
  });

  @override
  _QuotePreviewScreenState createState() => _QuotePreviewScreenState();
}

class _QuotePreviewScreenState extends State<QuotePreviewScreen> {
  ///CONTAINS THE RE-USABLE WIDGETS WHICH HELPS TO BUILD THE LIST_VIEWS
  ListViewRowsHelper _listViewRowsHelper;

  ///USED FOR THE QUOTE DETAILS PREVIEW SECTION SLIDING IF MULTIPLE QUOTE DETAILS ARE ADDED
  final _pageController = PageController(viewportFraction: 0.8);

  ///TO IDENTIFY WHETHER TO SHOW TOTAL_WEIGHT OR NOT
  bool isTotalWeightVisible;

  ///TO IDENTIFY WHETHER TO SHOW TOTAL_QUANTITY OR NOT
  bool isTotalQuantityVisible;

  @override
  void initState() {
    super.initState();
    _listViewRowsHelper = ListViewRowsHelper();
    isTotalWeightVisible = true;
    isTotalQuantityVisible = true;

    widget.quoteDetailPreviewStandardFields
        .removeWhere((element) => element.FieldName == 'Weight');
    widget.quoteDetailPreviewStandardFields
        .removeWhere((element) => element.FieldName == 'TotalWeight');
  }

  ///IT RETURNS THE QUOTE PREVIEW TITLE CONTENTS i.e. CustomerNo, QuoteNo, QuoteDate Etc.
  Widget getTitleSectionContent() {
    return Container(
      child: _listViewRowsHelper.getQuotePreviewRow(
        addQuoteObj: widget.addQuoteObj,
        previewSectionName: 'Title',
        standardFields: widget.quoteHeaderPreviewStandardFields,
        showQuoteHeaderFields: true,
        currencySymbol: widget.currencySymbol,
      ),
    );
  }

  ///IT BUILDS QUOTE HEADER PREVIEW CONTENTS
  Widget buildQuoteHeadersPreviewContent() {
    return Container(
      child: ExpandedWidget(
        initialExpanded: true,
        headerValue: 'Quote Header',
        childWidget: _listViewRowsHelper.getQuotePreviewRow(
          addQuoteObj: widget.addQuoteObj,
          previewSectionName: 'Header',
          standardFields: widget.quoteHeaderPreviewStandardFields,
          showQuoteHeaderFields: true,
          currencySymbol: widget.currencySymbol,
        ),
      ),
    );
  }

  ///BUILDS THE QUOTE_DETAIL SECTION HORIZONTAL_SCROLLABLE
  /*Widget buildQuoteDetailsPreviewContentList() {
    return Column(
      children: List.generate(
        widget.addQuoteObj.QuoteDetail.length,
            (pos) => ExpandedWidget(
              headerValue: 'Product ${pos + 1}',
              initialExpanded: false,
              childWidget: Container(
                  padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0),
                  child: Column(
                    children: _listViewRowsHelper.getSingleDetailPreviewRows(
                      singleQuoteDetail: widget.addQuoteObj.QuoteDetail[pos],
                      showQuoteHeaderFields: false,
                      previewSectionName: 'Detail',
                      standardFields: widget.quoteDetailPreviewStandardFields,
                      currencySymbol: widget.currencySymbol,
                    ),
                  ),
              ),
            ),
      ),
    );*/

  int _activeMeterIndex;

  Widget buildQuoteDetailsPreviewContentList() {
    return Container(
      child: ExpandedWidget(
        initialExpanded: false,
        headerValue: 'Quote Details',
        childWidget: Column(
            children: List.generate(
          widget.addQuoteObj.QuoteDetail.length,
          (pos) => Padding(
            padding: const EdgeInsets.fromLTRB(2.0, 12.0, 2.0, 0.0),
            child: ExpansionPanelList(
              expansionCallback: (int index, bool status) {
                setState(() {
                  _activeMeterIndex = _activeMeterIndex == pos ? null : pos;
                });
              },
              children: [
                new ExpansionPanel(
                  canTapOnHeader: true,
                  isExpanded: _activeMeterIndex == pos,
                  headerBuilder: (BuildContext context, bool isExpanded) =>
                      Padding(
                    padding: const EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 10.0),
                    child: Text(
                      '${widget.addQuoteObj.QuoteDetail[pos].product.Description} (${widget.addQuoteObj.QuoteDetail[pos].product.ProductCode})',
                    ),
                  ),
                  body: Column(
                    children: _listViewRowsHelper.getSingleDetailPreviewRows(
                      singleQuoteDetail: widget.addQuoteObj.QuoteDetail[pos],
                      showQuoteHeaderFields: false,
                      previewSectionName: 'Detail',
                      standardFields: widget.quoteDetailPreviewStandardFields,
                      currencySymbol: widget.currencySymbol,
                    ),
                  ),
                ),
              ],
            ),
          ),
        )),
      ),
    );
  }

  ///IT RETURNS THE QUOTE PREVIEW TITLE CONTENTS i.e. DocumentTotal, TotalWeight  Etc.
  Widget getTotalSectionPreviewContent() {
    String WeightUOM = '';
    if (widget.addQuoteObj.QuoteDetail.length > 0) {
      for (int i = 0; i < widget.addQuoteObj.QuoteDetail.length; i++) {
        if (widget.addQuoteObj.QuoteDetail[i].product.WeightUOM != '' &&
            widget.addQuoteObj.QuoteDetail[i].product.WeightUOM != 'null' &&
            widget.addQuoteObj.QuoteDetail[i].product.WeightUOM != null) {
          WeightUOM = widget.addQuoteObj.QuoteDetail[i].product.WeightUOM;
          break;
        }
      }
    }

    return Container(
      child: Column(
        children: <Widget>[
          ///DECIDES IF TO SHOW TOTAL_QUANTITY_OR NOT
          Visibility(
            visible: isTotalQuantityVisible,
            child: _listViewRowsHelper.getQuoteDetailSectionPreviewRowContent(
              keyText: 'Total Quantity',
              keyValue: '${widget.totalQuantity}',
              keyTextStyle: TextStyle(color: AppColors.black, fontSize: 15),
            ),
          ),

          ///DECIDES IF TO SHOW TOTAL_WEIGHT_OR NOT
          Visibility(
            visible: isTotalWeightVisible,
            child: Card(
              color: Colors.cyan,
              child: _listViewRowsHelper.getQuoteDetailSectionPreviewRowContent(
                keyText: 'Total Weight',
                keyValue: '${widget.totalWeight.toStringAsFixed(2)}' +
                    ' ' +
                    ' $WeightUOM',
                keyTextStyle: TextStyle(color: AppColors.black, fontSize: 15),
              ),
            ),
          ),

          ///SHOWS THE DOCUMENT_TOTAL SECTION
          _listViewRowsHelper.getQuotePreviewRow(
            addQuoteObj: widget.addQuoteObj,
            previewSectionName: 'Total',
            standardFields: widget.quoteHeaderPreviewStandardFields,
            showQuoteHeaderFields: true,
            currencySymbol: widget.currencySymbol,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quote Preview'),
        automaticallyImplyLeading: false,
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: FlatButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'OK',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        height: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              ///HEADER TEXT
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Sales Quote',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              getTitleSectionContent(),

              ///QUOTE_HEADERS_PREVIEW_SECTION
              buildQuoteHeadersPreviewContent(),

              buildQuoteDetailsPreviewContentList(),

              SizedBox(
                height: 5,
              ),
              getTotalSectionPreviewContent(),

              ///FOOTER TEXT
              Center(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 30.0),
                  child: Text(
                    'Quote subject to approval',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
