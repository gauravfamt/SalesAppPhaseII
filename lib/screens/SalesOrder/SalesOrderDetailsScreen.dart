import 'package:flutter/material.dart';
import 'package:moblesales/helpers/index.dart';
import 'package:moblesales/models/index.dart';
import 'package:moblesales/screens/index.dart';

class SalesOrderDetails extends StatefulWidget {
  ///HOLDS SALES_ORDER OBJECT WHICH DETAILS NEEDS TO BE DISPLAYED
  final SalesOrders salesOrderObj;

  ///IT HOLDS ORDER_HEADER ENTITY STANDARD FIELDS
  final List<StandardField> headerOnScreenStandardFields;

  ///IT HOLDS ORDER_DETAIL ENTITY STANDARD FIELDS
  final List<StandardField> detailsOnScreenStandardFields;

  final StandardDropDownField currencyCaptionSF;

  SalesOrderDetails({
    Key key,
    @required this.salesOrderObj,
    @required this.detailsOnScreenStandardFields,
    @required this.headerOnScreenStandardFields,
    @required this.currencyCaptionSF,
  }) : super(key: key);

  @override
  _SalesOrderDetailsState createState() => _SalesOrderDetailsState();
}

class _SalesOrderDetailsState extends State<SalesOrderDetails> {
  ///USED TO FOR BUILDING THE LISTING ROWS
  ListViewRowsHelper _listViewRowsHelper;

  @override
  void initState() {
    super.initState();
    _listViewRowsHelper = ListViewRowsHelper();
  }

  int _activeMeterIndex;

  Widget buildOrderDetailsList() {
    return Card(
      elevation: 2,
      child: ExpansionTile(
        initiallyExpanded: false,
        title: Text('Order Details'),
        children: <Widget>[
          Card(
            elevation: 2,
            child: Column(
              children: List.generate(
                widget.salesOrderObj.orderdetails.length,
                (pos) => Padding(
                  padding: const EdgeInsets.fromLTRB(2.0, 2.0, 2.0, 0.0),
                  child: ExpansionPanelList(
                    expansionCallback: (int index, bool status) {
                      setState(() {
                        _activeMeterIndex =
                            _activeMeterIndex == pos ? null : pos;
                      });
                    },
                    children: [
                      new ExpansionPanel(
                        canTapOnHeader: true,
                        isExpanded: _activeMeterIndex == pos,
                        headerBuilder:
                            (BuildContext context, bool isExpanded) => Padding(
                          padding:
                              const EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 10.0),
                          child: Text(
                            '${widget.salesOrderObj.orderdetails[pos].Description} (${widget.salesOrderObj.orderdetails[pos].ProductCode})',
                          ),
                        ),
                        body: Column(
                          children: _listViewRowsHelper.getRowCardContents(
                            classObj: widget.salesOrderObj.orderdetails[pos],
                            isEntitySectionCheckDisabled: true,
                            showOnGridFields: false,
                            standardFields:
                                widget.detailsOnScreenStandardFields,
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
          )
        ],
      ),
    );
  }

  ///IT BUILDS THE ORDER_DETAILS SECTION ROWS
  List<Widget> buildDetailsSectionRows() {
    List<Widget> _widgetsList = List<Widget>();
    for (var i = 0; i < widget.salesOrderObj.orderdetails.length; i++) {
      ///HERE GETTING THE SINGLE ROW CARD WITH IT's CONTENTS
      _widgetsList.add(
        _listViewRowsHelper.getRowCard(
          classObj: widget.salesOrderObj.orderdetails[i],
          isEntitySectionCheckDisabled: true,
          showOnGridFields: false,
          standardFields: widget.detailsOnScreenStandardFields,
          isExcludedFieldEnabled: false,
          currencyCaption: widget.currencyCaptionSF.Caption,
        ),
      );
    }
    return _widgetsList;
  }

  ///IT RETURNS ORDER_HEADER SECTION
  Widget getOrderHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _listViewRowsHelper.getRowCardContents(
        classObj: widget.salesOrderObj,
        isEntitySectionCheckDisabled: true,
        showOnGridFields: false,
        standardFields: widget.headerOnScreenStandardFields,
        isExcludedFieldEnabled: false,
        currencyCaption: widget.currencyCaptionSF.Caption,
      ),
    );
  }

  ///IT RETURNS ORDER_DETAILS SECTION
  Widget getOrderDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Visibility(
          visible: (widget.detailsOnScreenStandardFields.length < 1 &&
              widget.salesOrderObj.orderdetails.length < 1),
          child: Padding(
            padding: const EdgeInsets.all(50.0),
            child: Text(
              'No Data Found For order details',
              style: TextStyle(color: AppColors.black, fontSize: 16.0),
            ),
          ),
        ),
        buildOrderDetailsList(),
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
                title: Text('Order Header'),
                children: <Widget>[
                  Card(elevation: 2, child: getOrderHeaderSection())
                ],
                initiallyExpanded: true,
              ),
            ),
            getOrderDetailsSection(),
//          ExpandedWidget(
//            headerValue: 'Order Details',
//            childWidget: getOrderDetailsSection(),
//            initialExpanded: true,
//          ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return (MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Invoice Details',
      home: Scaffold(
        appBar: AppBar(
          title: Text(AppBarTitles.SALES_ORDER_DETAILS),
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              }),
        ),
        body: getDetailsPageBody(),
      ),
    ));
  }
}
