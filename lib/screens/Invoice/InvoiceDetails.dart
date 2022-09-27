import 'package:flutter/material.dart';
import 'package:moblesales/helpers/index.dart';
import 'package:moblesales/models/index.dart';
import 'package:moblesales/screens/index.dart';

class InvoiceDetailsPage extends StatefulWidget {
  ///HOLDS SALES_ORDER OBJECT WHICH DETAILS NEEDS TO BE DISPLAYED
  final Invoices invoiceObj;

  ///IT HOLDS ORDER_HEADER ENTITY STANDARD FIELDS
  final List<StandardField> headerOnScreenStandardFields;

  ///IT HOLDS ORDER_DETAIL ENTITY STANDARD FIELDS
  final List<StandardField> detailsOnScreenStandardFields;

  final StandardDropDownField currencyCaptionSF;

  InvoiceDetailsPage({
    Key key,
    @required this.invoiceObj,
    @required this.detailsOnScreenStandardFields,
    @required this.headerOnScreenStandardFields,
    @required this.currencyCaptionSF,
  }) : super(key: key);

  @override
  _InvoiceDetailsPageState createState() => _InvoiceDetailsPageState();
}

class _InvoiceDetailsPageState extends State<InvoiceDetailsPage> {
  ListViewRowsHelper _listViewRowsHelper;

  @override
  void initState() {
    super.initState();
    _listViewRowsHelper = ListViewRowsHelper();
    //print('init');
  }

  @override
  void dispose() {
    super.dispose();
  }

  int _activeMeterIndex;

  Widget buildInvoiceDetailsList() {
    //print('Invoice Details');
    return Card(
      elevation: 2,
      child: ExpansionTile(
        initiallyExpanded: false,
        title: Text('Invoice Details'),
        children: <Widget>[ Card(
          elevation: 2,
          child: Column(
            children: List.generate(
              widget.invoiceObj.invoiceDetails.length,
              (pos) => Padding(
                padding: const EdgeInsets.fromLTRB(2.0, 2.0, 2.0, 0.0),
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
                          '${Other().parseHtmlString(widget.invoiceObj.invoiceDetails[pos].Description)} (${widget.invoiceObj.invoiceDetails[pos].Item})',
                        ),
                      ),
                      body: Column(
                        children: _listViewRowsHelper.getRowCardContents(
                          classObj: widget.invoiceObj.invoiceDetails[pos],
                          isEntitySectionCheckDisabled: true,
                          showOnGridFields: false,
                          standardFields: widget.detailsOnScreenStandardFields,
                          isExcludedFieldEnabled: false,
                          currencyCaption: widget.currencyCaptionSF.Caption,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        )],
      ),
    );
  }

  ///IT RETURNS ORDER_HEADER SECTION
  Widget getInvoiceHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _listViewRowsHelper.getRowCardContents(
        classObj: widget.invoiceObj,
        isEntitySectionCheckDisabled: true,
        showOnGridFields: false,
        standardFields: widget.headerOnScreenStandardFields,
        isExcludedFieldEnabled: false,
        currencyCaption: widget.currencyCaptionSF.Caption,
      ),
    );
  }

  ///IT RETURNS ORDER_DETAILS SECTION
  Widget getInvoiceDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Visibility(
          visible: (widget.detailsOnScreenStandardFields.length < 1 &&
              widget.invoiceObj.invoiceDetails.length < 1),
          child: Padding(
            padding: const EdgeInsets.all(50.0),
            child: Text(
              'No Data Found For order details',
              style: TextStyle(color: AppColors.black, fontSize: 16.0),
            ),
          ),
        ),
        buildInvoiceDetailsList(),
      ],
    );
  }

  ///IT RETURNS THE MAIN BODY SECTION FOR THE ORDER_DETAILS PAGE CONSISTING OF TWO EXPANDED WIDGETS
  Widget getDetailsPageBody() {
    return Container(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        child: ListView(
          children: <Widget>[
            Card(
              elevation: 2,
              child: ExpansionTile(
                title: Text('Invoice Header'),
                children: <Widget>[ Card(elevation: 2, child: getInvoiceHeaderSection())],
                initiallyExpanded: true,
              ),
            ),
            getInvoiceDetailsSection(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppBarTitles.INVOICE_DETAILS),
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            }),
      ),
      body: getDetailsPageBody(),
    );
  }
}
