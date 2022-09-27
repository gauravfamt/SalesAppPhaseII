import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:moblesales/helpers/index.dart';
import 'package:moblesales/models/index.dart';
import 'package:moblesales/screens/index.dart';
import 'package:moblesales/utils/Helper/AddressDBHelper.dart';

class QuoteDetails extends StatefulWidget {
  ///HOLDS QUOTE OBJECT WHICH DETAILS NEEDS TO BE DISPLAYED
  final Quotes quoteObj;

  final AddQuote offlineQuoteObj;

  ///TO HIDE/SHOW LOADER UNTIL STANDARD_FIELDS_DATA IS FETCHED FOR THE DETAILS PAGE
  final bool isDetailsFieldsLoading;

  ///IT HOLDS ORDER_DETAIL ENTITY STANDARD FIELDS
  final List<StandardField> detailsOnGridStandardFields;

  ///IT HOLDS ORDER_HEADER ENTITY STANDARD FIELDS
  final List<StandardField> headerOnScreenStandardFields;

  ///HOLDS CURRENCY CAPTION VALUES FOR THE LIST_VIEWS
  final StandardDropDownField currencyCaptionSF;

  QuoteDetails({
    Key key,
    this.quoteObj,
    this.offlineQuoteObj,
    @required this.isDetailsFieldsLoading,
    @required this.headerOnScreenStandardFields,
    @required this.detailsOnGridStandardFields,
    @required this.currencyCaptionSF,
  }) : super(key: key);

  @override
  _QuoteDetailsState createState() => _QuoteDetailsState();
}

class _QuoteDetailsState extends State<QuoteDetails> {
  int _activeMeterIndex;
  ListViewRowsHelper _listViewRowsHelper;
  //Fetches Address from Offline DB
  AddressDBHelper addressDBhelper = new AddressDBHelper();
  String addressString;
  String addressCode;

  @override
  void initState() {
    addressString = '';
    addressCode = widget.offlineQuoteObj == null
        ? widget.quoteObj.ShippingAddressCode
        : widget.offlineQuoteObj.QuoteHeader.first.QuoteHeaderFields
            .firstWhere((element) => element.FieldName == 'ShippingAddressCode')
            .FieldValue;
    fetchAddressValue(
        addressCode,
        widget.offlineQuoteObj == null
            ? widget.quoteObj.CustomerNo
            : widget.offlineQuoteObj.QuoteHeader.first.QuoteHeaderFields
                .firstWhere((element) => element.FieldName == 'CustomerNo')
                .FieldValue,
        widget.offlineQuoteObj == null ? "Online" : "Offline");
    _listViewRowsHelper = ListViewRowsHelper();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return (MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quote Details',
      home: Scaffold(
        appBar: AppBar(
          title: Text(AppBarTitles.QUOTES_DETAILS),
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                this.setState(() {
                  if (widget.offlineQuoteObj == null) {
                    widget.quoteObj.ShippingAddressCode = addressCode;
                    print(widget.quoteObj.ShippingAddressCode);
                  } else {
                    widget.offlineQuoteObj.QuoteHeader.first.QuoteHeaderFields
                        .firstWhere((element) =>
                            element.FieldName == 'ShippingAddressCode')
                        .FieldValue = addressCode;
                    print(widget
                        .offlineQuoteObj.QuoteHeader.first.QuoteHeaderFields
                        .firstWhere((element) =>
                            element.FieldName == 'ShippingAddressCode')
                        .FieldValue);
                  }
                });
                Navigator.pop(context);
              }),
        ),
        body: widget.offlineQuoteObj == null
            ? getDetailsPageBody()
            : getOfflineQuoteDetailsPageBody(),
      ),
    ));
  }

  ///IT RETURNS QUOTE_DETAILS_PAGE BODY
  Widget getDetailsPageBody() {
    return Container(
      ///FIRST IS THE STANDARD_FIELDS_DATA IS NOT LOADED YET TILL THEN SHOWING LOADER
      child: widget.isDetailsFieldsLoading
          ? Center(
              child: Padding(
                padding: EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 50.0),
                child: CircularProgressIndicator(
                  backgroundColor: Colors.teal.shade100,
                ),
              ),
            )
          :
          //HERE CHECKING IF STANDARD FIELDS DATA AND ORDER DETAILS DATA IS AVAILABLE OR NOT
          (widget.detailsOnGridStandardFields.length < 1 &&
                  widget.quoteObj.Quotedetail.length < 1)
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(50.0),
                      child: Text(
                        'No Data Found For order details',
                        style:
                            TextStyle(color: AppColors.black, fontSize: 16.0),
                      ),
                    )
                  ],
                )
              : Container(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                    child: ListView(
                      children: <Widget>[
                        Card(
                          elevation: 2,
                          child: ExpansionTile(
                            title: Text('Quote Header'),
                            initiallyExpanded: true,
                            children: <Widget>[ getQuoteHeaderSection()],
                          ),
                        ),
                        Card(
                          elevation: 2,
                          child: ExpansionTile(
                              initiallyExpanded: false,
                              title: Text('Quote Details'),
                              children: <Widget>[
                                Card(
                                  elevation: 2,
                                  child: Column(
                              children: List.generate(
                                    widget.quoteObj.Quotedetail.length,
                                    (pos) => Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                        2.0, 2.0, 2.0, 2.0),
                                          child: ExpansionPanelList(
                                            expansionCallback:
                                                (int index, bool status) {
                                              setState(() {
                                                _activeMeterIndex =
                                                    _activeMeterIndex == pos
                                                        ? null
                                                        : pos;
                                              });
                                            },
                                            children: [
                                              new ExpansionPanel(
                                                canTapOnHeader: true,
                                                isExpanded: _activeMeterIndex == pos,
                                                headerBuilder: (BuildContext context,
                                                        bool isExpanded) =>
                                                    Padding(
                                                  padding: const EdgeInsets.fromLTRB(
                                                      10.0, 5.0, 0.0, 5.0),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                    children: <Widget>[
                                                      Padding(
                                                        padding: StyleUtils
                                                            .smallVerticalPadding,
                                                        child: Text(
                                                          '${widget.quoteObj.Quotedetail[pos].Description} (${widget.quoteObj.Quotedetail[pos].ProductCode})',
                                                        ),
                                                      ),
                                                      //Added by Mayuresh Started, Showing Qty & Ext Amt on Line Level, 07-19-2022
                                                      Padding(
                                                        padding: StyleUtils
                                                            .smallVerticalPadding,
                                                        child: Text(
                                                          'Qty: ${widget.quoteObj.Quotedetail[pos].Quantity}',
                                                          style: StyleUtils
                                                              .smallboldStyle,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: StyleUtils
                                                            .smallVerticalPadding,
                                                        child: Text(
                                                          'Ext Amount: ${widget.quoteObj.Quotedetail[pos].ExtAmount}',
                                                          style: StyleUtils
                                                              .smallboldStyle,
                                                        ),
                                                      ),
                                                      //Added by Mayuresh Ends
                                                    ],
                                                  ),
                                                ),
                                                body: Container(
                                                  child: ListViewRows(
                                                    isActionsEnabled: false,
                                                    standardFields: widget
                                                        .detailsOnGridStandardFields,
                                                    recordObj: widget
                                                        .quoteObj.Quotedetail[pos],
                                                    recordPosition: pos,
                                                    isEntitySectionCheckDisabled:
                                                        true,
                                                    actionButtonRows: List<Row>(),
                                                    showOnGridFields: true,
                                                    isExcludedFieldEnabled: false,
                                                    currencyCaption: widget
                                                        .currencyCaptionSF.Caption,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )),
                            ),
                                )],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget getOfflineQuoteHeaderSection() {
    return Column(
      children:
          buildRows(widget.offlineQuoteObj.QuoteHeader[0].QuoteHeaderFields),
    );
  }

  Widget getQuoteHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _listViewRowsHelper.getRowCardContents(
        classObj: widget.quoteObj,
        isEntitySectionCheckDisabled: true,
        showOnGridFields: false,
        standardFields: widget.headerOnScreenStandardFields,
        isExcludedFieldEnabled: false,
        currencyCaption: widget.currencyCaptionSF.Caption,
      ),
    );
  }

  Widget getOfflineQuoteDetailsPageBody() {
    return Container(
      ///FIRST IS THE STANDARD_FIELDS_DATA IS NOT LOADED YET TILL THEN SHOWING LOADER
      child: widget.isDetailsFieldsLoading
          ? Center(
              child: Padding(
                padding: EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 50.0),
                child: CircularProgressIndicator(
                  backgroundColor: Colors.teal.shade100,
                ),
              ),
            )
          :
          //HERE CHECKING IF STANDARD FIELDS DATA AND ORDER DETAILS DATA IS AVAILABLE OR NOT
          (widget.detailsOnGridStandardFields.length < 1 &&
                  widget.quoteObj.Quotedetail.length < 1)
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(50.0),
                      child: Text(
                        'No Data Found For order details',
                        style:
                            TextStyle(color: AppColors.black, fontSize: 16.0),
                      ),
                    ),

                  ],
                )
              : Container(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                    child: ListView(
                      children: <Widget>[
                        Card(
                          elevation: 2,
                          child: ExpansionTile(
                            title: Text('Quote Header'),
                            initiallyExpanded: true,
                            children: <Widget>[
                              Card(elevation: 2, child: getOfflineQuoteHeaderSection()),
                            ],
                          ),
                        ),
//                      ExpandedWidget(
//                        headerValue: '',
//                        childWidget: getOfflineQuoteHeaderSection(),
//                        initialExpanded: true,
//                      ),
                        Card(
                          elevation: 2,
                          child: ExpansionTile(
                            title: Text('Quote Details'),
                            children: <Widget>[
                              Card(
                                elevation: 2,
                                child: Column(
                                  children: List.generate(
                                      widget.offlineQuoteObj.QuoteDetail.length,
                                          (pos) => Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            2.0, 2.0, 2.0, 2.0),
                                        child: ExpansionPanelList(
                                          expansionCallback:
                                              (int index, bool status) {
                                            setState(() {
                                              _activeMeterIndex =
                                              _activeMeterIndex == pos
                                                  ? null
                                                  : pos;
                                            });
                                          },
                                          children: [
                                            new ExpansionPanel(
                                              canTapOnHeader: true,
                                              isExpanded: _activeMeterIndex == pos,
                                              headerBuilder: (BuildContext context,
                                                  bool isExpanded) =>
                                                  Padding(
                                                    padding: const EdgeInsets.fromLTRB(
                                                        10.0, 5.0, 0.0, 10.0),
                                                    child: getProductName(widget
                                                        .offlineQuoteObj
                                                        .QuoteDetail[pos]
                                                        .QuoteDetailFields),
                                                  ),
                                              body: Container(
                                                child: Column(
                                                  children: buildRows(widget
                                                      .offlineQuoteObj
                                                      .QuoteDetail[pos]
                                                      .QuoteDetailFields),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )),
                                ),
                              ),
                            ],

                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget getProductName(List<QuoteDetailField> QuoteDetailsFields) {
    String productCode = '';
    String productName = '';
    String productQty = '';
    String productExtAmt = '';
    for (int i = 0; i < QuoteDetailsFields.length; i++) {
      if (QuoteDetailsFields[i].FieldName == "ProductCode") {
        productCode = QuoteDetailsFields[i].FieldValue;
      } else if (QuoteDetailsFields[i].FieldName == "Description") {
        productName = QuoteDetailsFields[i].FieldValue;
      } else if (QuoteDetailsFields[i].FieldName == "Quantity") {
        productQty = QuoteDetailsFields[i].FieldValue;
      } else if (QuoteDetailsFields[i].FieldName == "ExtAmount") {
        productExtAmt = QuoteDetailsFields[i].FieldValue;
      }
    }
    //Added by Mayuresh Started, Showing Qty & Ext Amt on Line Level, 07-19-2022
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: StyleUtils.smallVerticalPadding,
          child: Text(
            '${productName} (${productCode})',
          ),
        ),
        Padding(
          padding: StyleUtils.smallVerticalPadding,
          child: Text(
            'Qty: ${productQty}',
            style: StyleUtils.smallboldStyle,
          ),
        ),
        Padding(
          padding: StyleUtils.smallVerticalPadding,
          child: Text(
            'Ext Amount: ${productExtAmt}',
            style: StyleUtils.smallboldStyle,
          ),
        ),
      ],
    );
    //Added by Mayuresh Ends
  }

  //Bind offline quote details
  List<Widget> buildRows(List listObj) {
    List<Widget> _widgetsList = List<Widget>();
    for (var i = 0; i < listObj.length; i++) {
      print('--${listObj[i].FieldName}');
      // //Hides CustomerName from Quote Header Details Screen, but shows in the List screen
      if (listObj[i].FieldName != 'OtherParam') {
        //Check which details should disply on grid
        var displayOnScreen = listObj.firstWhere(
            (e) => e.FieldName == listObj[i].FieldName,
            orElse: () => null);
        if (displayOnScreen != null) {
          _widgetsList.add(_buildRowDetails(listObj[i]));
        }
      }
    }
    return _widgetsList;
  }

  //Bind offline quote header details
  Widget _buildRowDetails(var RowDetailsField) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15.0, 5.0, 10.0, 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Text(
              '${RowDetailsField.LabelName}',
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
              RowDetailsField.FieldName == "DocumentDate"
                  ? '${Other().DisplayDate(RowDetailsField.FieldValue)}'
                  : RowDetailsField.FieldName == "BasePrice" ||
                          RowDetailsField.FieldName == "ExtAmount" ||
                          RowDetailsField.FieldName == "DocumentTotal"
                      ? '${HtmlUnescape().convert(widget.currencyCaptionSF.Caption)} ' +
                          '${RowDetailsField.FieldValue}'
                      : '${RowDetailsField.FieldValue}',
              style: TextStyle(
                  color: AppColors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.bold),
            ),
          ),
          //_buildOfflineHeaderList(position),
        ],
      ),
    );
  }

  fetchAddressValue(
      String addressCode, String customerCode, String quoteType) async {
    try {
      await addressDBhelper
          .getAddressByCode(
              addressCode: addressCode, customerCode: customerCode)
          .then((value) {
        this.setState(() {
          if (quoteType.toString().toLowerCase().replaceAll(' ', '') ==
              'online') {
            // addressString = formatAddress(value);
            widget.quoteObj.ShippingAddressCode = formatAddress(value);
            // print(widget.quoteObj.ShippingAddressCode);
          } else {
            // addressString = formatAddress(value);
            widget.offlineQuoteObj.QuoteHeader.first.QuoteHeaderFields
                .firstWhere(
                    (element) => element.FieldName == 'ShippingAddressCode')
                .FieldValue = formatAddress(value);
            // print(widget.offlineQuoteObj.QuoteHeader.first.QuoteHeaderFields
            //     .firstWhere(
            //         (element) => element.FieldName == 'ShippingAddressCode')
            //     .FieldValue);
          }
        });
      });
    } catch (e) {
      print('Error in QuoteDetails.fetchAddressValue');
      print(e);
    }
  }

  String formatAddress(Address address) {
    try {
      String formattedString = '';
      formattedString += address.Address1 + ' ';
      formattedString += address.City + ' ';
      formattedString += address.State + ' ';
      formattedString += address.PostCode + ' ';
      formattedString += address.Country + ' ';

      return formattedString;
    } catch (e) {
      print('Error in QuoteDetails.formatAddress');
      print(e);
    }
  }
}
