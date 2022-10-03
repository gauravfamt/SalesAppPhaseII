import 'package:expandable/expandable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moblesales/helpers/index.dart';
import 'package:moblesales/models/index.dart';
import 'package:moblesales/screens/index.dart';

class CompanyDetails extends StatelessWidget {
  final Company companyData;
  final List<StandardField> addressesStandardFields;
  final List<StandardField> contactsStandardFields;
  final StandardDropDownField currencyCaptionStandardField;
  CompanyDetails({
    Key key,
    @required this.companyData,
    @required this.addressesStandardFields,
    @required this.contactsStandardFields,
    @required this.currencyCaptionStandardField,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return (MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Customer Details',
      home: CompanyDetailsPage(
        companyData: companyData,
        addressesStandardFields: addressesStandardFields,
        contactsStandardFields: contactsStandardFields,
        currencyCaptionStandardField: currencyCaptionStandardField,
        parentBuildContext: context,
      ),
    ));
  }
}

class CompanyDetailsPage extends StatefulWidget {
  final Company companyData;
  final List<StandardField> addressesStandardFields;
  final List<StandardField> contactsStandardFields;
  final StandardDropDownField currencyCaptionStandardField;
  final BuildContext parentBuildContext;

  CompanyDetailsPage({
    Key key,
    @required this.companyData,
    @required this.parentBuildContext,
    @required this.addressesStandardFields,
    @required this.contactsStandardFields,
    @required this.currencyCaptionStandardField,
  }) : super(key: key);
  @override
  _CompanyDetailsPageState createState() => _CompanyDetailsPageState();
}

class _CompanyDetailsPageState extends State<CompanyDetailsPage>
    with TickerProviderStateMixin {
  ListViewRowsHelper _listViewRowsHelper;
  @override
  void initState() {
    super.initState();
    _listViewRowsHelper = ListViewRowsHelper();
  }

  @override
  void dispose() {
    super.dispose();
  }

  ///IT RETURNS THE ACTUAL LIST ROWS CARD CONTENTS IN THE KEY VALUE PAIR
  Widget _getRowContentWidget(keyText, keyValue, bool keyValueVisibility) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          15.0, 5.0, 15.0, 5.0), //Record Contents padding
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Text(
              '$keyText',
              style: TextStyle(color: AppColors.grey, fontSize: 15),
            ),
          ),
          Expanded(
            child: Text(
              '${keyValue != null ? keyValue : '-'}',
              style: TextStyle(
                  color: AppColors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getRowContentWidgetForAddress(
      keyText, keyValue, bool keyValueVisibility) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          15.0, 5.0, 15.0, 5.0), //Record Contents padding
      child: Row(
        children: <Widget>[
          Expanded(
            //flex:1,
            child: Text(
              '$keyText',
              style: TextStyle(
                  color: AppColors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  ///IT RETURNS THE EXPANDED_WIDGET IT REQUIRES HEADER_TEXT_VALUE AND
  ///CHILD_WIDGET WHICH WILL BE DISPLAYED IN EXPANDED_PANEL
  Widget getExpandedWidget(String headerValue, Widget childWidget) {
    return ExpandableNotifier(
      initialExpanded: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 0.0),
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: ScrollOnExpand(
            scrollOnExpand: true,
            scrollOnCollapse: false,
            child: ExpandablePanel(
              theme: const ExpandableThemeData(
                headerAlignment: ExpandablePanelHeaderAlignment.center,
                tapBodyToCollapse: true,
              ),
              header: Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    headerValue,
                    style: TextStyle(
                      color: AppColors.grey,
                      fontSize: 15.0,
                    ),
                  )),
              expanded: Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: childWidget,
              ),
              builder: (_, collapsed, expanded) {
                return Padding(
                  padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                  child: Expandable(
                    collapsed: collapsed,
                    expanded: expanded,
                    theme: const ExpandableThemeData(crossFadePoint: 0),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  ///IT HANDLES THE PROCESSING_INFORMATION CONTENT
  Widget getProcessingInformationExpandedContent() {
    return Column(
      children: <Widget>[
        _getRowContentWidget(
            'Credit Limit',
            _listViewRowsHelper.attachCurrencyCode(
                value: '${widget.companyData.CreditLimit.toStringAsFixed(2)}',
                currencyCaption: widget.currencyCaptionStandardField.Caption,
                fieldName: 'CreditLimit'),
            true),
        _getRowContentWidget(
            'Balance',
            _listViewRowsHelper.attachCurrencyCode(
                value: '${widget.companyData.Balance.toStringAsFixed(2)}',
                currencyCaption: widget.currencyCaptionStandardField.Caption,
                fieldName: 'Balance'),
            true),
      ],
    );
  }

  ///IT HANDLES THE OTHER_INFO. EXPANDED CONTENT
  Widget getOtherInformationExpandedContent() {
    return Container();
  }

  ///IT RETURNS THE ADDRESS INFORMATION WIDGET
  ///
  /// forType - 1 : BILLING_ADDRESS
  /// forType - 2 : SHIPPING_ADDRESS
  ///
  /// IF PROVIDED TYPE ADDRESS IS NOT PRESENT TN THE ADDRESSES LIST
  /// THEN IT RETURNS WIDGET WITH THE FIRST_ADDRESS IN THE ADDRESSES LIST
  Widget getAddressInformationWidget(int forType) {
    ///TO CHECK IF SPECIFIED ADDRESS_TYPE EXIST OR NOT
    bool isAddressExist = false;

    ///TO HOLD THE SINGLE ADDRESS FOR SHOWING ON UI
    Address singleAddressObj;

    ///HOLDS THE WIDGET WHICH NEEDS TO BE RETURNED BY THE FUNCTION
    Widget _widget;
    try {
      for (var i = 0; i < widget.companyData.addresses.length; i++) {
        ///HERE CHECKING IF BILLING_ADDRESS PRESENT OR NOT
        if (forType == 1 &&
            widget.companyData.addresses[i].IsShipping == false) {
          singleAddressObj = widget.companyData.addresses[i];
          isAddressExist = true;
          break;
        } else if (forType == 2 &&
            widget.companyData.addresses[i].IsShipping == true &&
            widget.companyData.DefaultShippAdd ==
                widget.companyData.addresses[i].Code) {
          ///HERE CHECKING IF SHIPPING_ADDRESS PRESENT OR NOT
          singleAddressObj = widget.companyData.addresses[i];
          isAddressExist = true;
          break;
        }
      }

      ///IF ADDRESS FOUND THEN RETURNING ITS ROWS
      if (isAddressExist == true) {
        _widget = Column(
          children: <Widget>[...getAddressesRows(singleAddressObj)],
        );
      } else if (widget.companyData.addresses.length > 0) {
        ///IF SPECIFIED ADDRESS_TYPE NOI_FOUND THEN RETURNING FIRST ADDRESS FROM ADDRESSES LIST
        _widget = Column(
          children: <Widget>[
            ...getAddressesRows(widget.companyData.addresses[0])
          ],
        );
      } else {
        ///IF ADDRESSES LIST IS EMPTY THEN RETURNING THE EMPTY CONTAINER
        _widget = Container(
          child: Center(
            child: Text(
              'No Address Found!',
              style: TextStyle(
                fontSize: 12.0,
                color: AppColors.grey,
              ),
            ),
          ),
        );
      }
      return _widget;
    } catch (e) {
      //print('Error inside getAddressInformationWidget Fn ');
      //print(e);
      return Container();
    }
  }

  List<Widget> getAddressesRows(singleAddressObj) {
    List<Widget> _widgetsList = List<Widget>();
    try {
      List<StandardField> _sortedStandardFields =
          widget.addressesStandardFields;
      _sortedStandardFields.sort((a, b) =>
          a.SortOrder.compareTo(b.SortOrder));

      ///CHECKING ONLY IF STANDARD_FIELDS ARE DISPLAYED ON THE UI
      for (var sf = 0; sf < _sortedStandardFields.length; sf++) {
        StandardField _standardField = _sortedStandardFields[sf];
        print('---------${_standardField.FieldName}');
        ///HERE CHECKING IF SHOW_ON_GRID IS TRUE
        ///THEN IF KEY EXISTS IN THE PROVIDED OBJECT IT's VALUE MUST NOT BE NULL
        if (_standardField.SectionName == 'Address' &&
            _standardField.ShowInGrid == true &&
            singleAddressObj.toJson().containsKey(_standardField.FieldName) &&
            singleAddressObj.toJson()[_standardField.FieldName] != null &&
            singleAddressObj.toJson()[_standardField.FieldName]
                    .toString()
                    .trim()
                    .length >
                0) {
          ///IF ON_GRID VALUE IS TRUE THEN RETURNING THE ADDRESS ROWS
          _widgetsList.add(
            _getRowContentWidgetForAddress(
                singleAddressObj.toJson()[_standardField.FieldName], '', false),
          );
        }
      }
      return _widgetsList;
    } catch (e) {
      //print('Error inside the getAddressesRows Function ');
      //print(e);
      _widgetsList.add(Text('No Address Found!'));
      return _widgetsList;
    }
  }

  ///IT RETURNS THE CUSTOMER_INFORMATION TAB VIEW CONTENT
  Widget _getCustomerInfoTabBarView() {
    return Container(
      child: ListView(
        children: <Widget>[
          getExpandedWidget(
            'Account Information',
            _getRowContentWidget(
                'Customer Name', widget.companyData.Name, true),
          ),
          getExpandedWidget(
            'Billing Address Information',
            getAddressInformationWidget(1),
          ),
          getExpandedWidget(
            'Shipping Address Information',
            getAddressInformationWidget(2),
//            Text('data'),
          ),
          getExpandedWidget(
            'Processing Information',
            getProcessingInformationExpandedContent(),
          ),
//          getExpandedWidget(
//            'Other Information',
//            getOtherInformationExpandedContent(),
//          ),
        ],
      ),
    );
  }

  ///IT RETURNS THE CUSTOMER_ADDRESSES TAB VIEW CONTENT
  Widget _getCustomerAddressesTabBarView() {
    String strDefaultBillAdd = widget.companyData.DefaultBillAdd;
    String strDefaultShipAdd = widget.companyData.DefaultShippAdd;
    widget.companyData.addresses.forEach((element) {
      if (element.Code == strDefaultBillAdd) {
        element.DefaultBilling = 'Yes';
      } else {
        element.DefaultBilling = 'No';
      }

      if (element.Code == strDefaultShipAdd) {
        element.DefaultShipping = 'Yes';
      } else {
        element.DefaultShipping = 'No';
      }
    });

    return Container(
      child: widget.companyData.addresses.length == 0
          ? Center(
              child: Text(
                'No Additional Addresses Found!',
                style: TextStyle(
                  fontSize: 18.0,
                  color: AppColors.grey,
                ),
              ),
            )
          : ListView.builder(
              itemCount: widget.companyData.addresses.length,
              padding: const EdgeInsets.fromLTRB(
                  5.0, 15.0, 0.5, 0), //Complete ListView Outside padding
              itemBuilder: (context, position) {
                return Container(
                  child: ListViewRows(
                    standardFields: widget.addressesStandardFields,
                    recordObj: widget.companyData.addresses[position],
                    recordPosition: position,
                    isActionsEnabled: false,
                    isEntitySectionCheckDisabled: false,
                    allowedEntitySections:
                        AllowedEntitySections.COMPANY_VIEW_ADDRESS_SECTIONS,
                    actionButtonRows: List<Row>(),
                    showOnGridFields: true,
                    isExcludedFieldEnabled: false,
                    currencyCaption:
                        widget.currencyCaptionStandardField.Caption != null
                            ? widget.currencyCaptionStandardField.Caption
                            : null,
                  ),
                );
              },
            ),
    );
  }

  ///IT RETURNS THE CUSTOMER_CONTACTS TAB VIEW CONTENT
  Widget _getCustomerContactsTabBarView() {
    return Container(
      child: widget.companyData.contacts.length == 0
          ? Center(
              child: Text(
                'No Contacts Found!',
                style: TextStyle(
                  fontSize: 18.0,
                  color: AppColors.grey,
                ),
              ),
            )
          : ListView.builder(
              itemCount: widget.companyData.contacts.length,
              padding: const EdgeInsets.fromLTRB(
                  5.0, 15.0, 5.0, 0), //Complete ListView Outside padding
              itemBuilder: (context, position) {
                return Container(
                  child: ListViewRows(
                    standardFields: widget.contactsStandardFields,
                    recordObj: widget.companyData.contacts[position],
                    recordPosition: position,
                    isActionsEnabled: false,
                    isEntitySectionCheckDisabled: true,
                    actionButtonRows: List<Row>(),
                    showOnGridFields: true,
                    isExcludedFieldEnabled: false,
                  ),
                );
              },
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppBarTitles.CUSTOMER_PROFILE_DETAILS),
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(widget.parentBuildContext);
              }),
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Customer Information'),
              Tab(text: 'Additional Addresses'),
              Tab(text: 'Contacts'),
            ],
          ),
        ),
        body: TabBarView(children: [
          _getCustomerInfoTabBarView(),
          _getCustomerAddressesTabBarView(),
          _getCustomerContactsTabBarView(),
        ]),
      ),
    );
  }
}
