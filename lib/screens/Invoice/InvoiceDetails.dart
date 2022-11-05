import 'package:flutter/material.dart';
import 'package:moblesales/helpers/index.dart';
import 'package:moblesales/models/QuoteInvElement.dart';
import 'package:moblesales/models/index.dart';
import 'package:moblesales/screens/index.dart';
import 'package:moblesales/utils/Helper/AddQuote/QuoteInvoicingElementDBHelper.dart';
import 'package:moblesales/utils/Helper/InvoiceElementDBHelper.dart';

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

  //change
  InvoicingElementDBHelper invoicingElementDBHelper = new InvoicingElementDBHelper();//change
  List<QuoteInvElement> quoteInvElement=[];//change
  QuoteInvoicingElementDBHelper  quoteInvoicingElementDBHelper=new QuoteInvoicingElementDBHelper();//change

  @override
  void initState() {
    super.initState();
    _listViewRowsHelper = ListViewRowsHelper();
    fetchInvoicingElements();
    //print('init');
  }

  @override
  void dispose() {
    super.dispose();
  }

  int _activeMeterIndex;

  void fetchInvoicingElements() {
    try {
      print('fetchInvoicingElements');
      invoicingElementDBHelper.getAllInvoiceElements().then((invElementsRes) {
        if(widget.invoiceObj !=null){
          for (InvoicingElement element in invElementsRes) {
            var objQuoteInvElm = widget.invoiceObj.quoteInvoicingElement.firstWhere(
                    (e) => e.InvoicingElementCode.toString() == element.code.toString(),
                orElse: () => null);
            if (objQuoteInvElm != null) {
              setState(() {
                if(objQuoteInvElm.InvoicingElementValue!=0)
                quoteInvElement.add(new QuoteInvElement(invoicingElement:element,quoteHeaderId: 0,invoicingElementvalue: objQuoteInvElm.InvoicingElementValue ) );
              });
            }
            else{
              print('objQuoteInvElm null');
            }
          }
        }
      }).catchError((err) {
        print('Error while fetching Invoicing Elements from LocalDB');
        print(err);
      });
    } catch (e) {
      print("Error in fetchInvoicingElements");
      print(e);
    }
  }

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

  Widget getQuoteInvoicingElement() {
    return Column(
      children:
      buildInvoicingElement(quoteInvElement),
    );
  }

  List<Widget> buildInvoicingElement(List<QuoteInvElement> listObj) {
    List<Widget> _widgetsList = List<Widget>();
    for (var i = 0; i < listObj.length; i++) {
      _widgetsList.add(_buildInvoicingElementRow(listObj[i]));
    }
    return _widgetsList;
  }

  Widget _buildInvoicingElementRow(QuoteInvElement QIE) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15.0, 5.0, 10.0, 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Text(
              '${QIE.invoicingElement.description}',
              style: TextStyle(
                color: AppColors.grey,
                fontSize: 15,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text('\$ ${QIE.invoicingElementvalue}',
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
            widget.invoiceObj.quoteInvoicingElement.length>0?
            Card(
              elevation: 2,
              child: ExpansionTile(
                title: Text('Invoicing Element'),
                initiallyExpanded: false,
                children: <Widget>[ Card(elevation: 2, child: getQuoteInvoicingElement()),],
              ),
            ):Column(),
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
