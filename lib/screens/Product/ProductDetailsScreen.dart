import 'package:flutter/material.dart';
import 'package:moblesales/helpers/index.dart';
import 'package:moblesales/models/index.dart';
import 'package:moblesales/screens/index.dart';

class ProductDetailsPage extends StatefulWidget {
  ///HOLDS QUOTE OBJECT WHICH DETAILS NEEDS TO BE DISPLAYED
  final Product productObj;

  ///IT HOLDS ORDER_DETAIL ENTITY STANDARD FIELDS
  final List<StandardField> detailsOnScreenStandardFields;
  final StandardDropDownField currencyCaptionSF;
  ProductDetailsPage({
    Key key,
    @required this.productObj,
    @required this.detailsOnScreenStandardFields,
    @required this.currencyCaptionSF,
  }) : super(key: key);

  @override
  _ProductDetailsPageState createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  ///HELPS TO BUILD THE LIST_VIEW_ROWS
  ListViewRowsHelper _listViewRowsHelper;

  ///IT HOLDS ALL THE COMMON REUSABLE WIDGETS WHICH CAN BE USED THROUGH OUT PROJECT
  CommonWidgets _commonWidgets;

  ///HOLDS THE ERROR CAPTION FOR THE IMAGE
  String imgErrorCaption = 'No Preview Available!';

  ///HOLDS IMAGE HEIGHT
  double imageHeight = 200.0;

  ///FIELDS WHICH NEEDED TO BE EXCLUDED WHILE DISPLAYING ON THE LIST FROM REFERRING STANDARD_FIELDS
  List<String> excludeStandardFields = ['Image'];
  @override
  void initState() {
    super.initState();
    _listViewRowsHelper = ListViewRowsHelper();
    _commonWidgets = CommonWidgets();
  }

  ///IT RETURNS THE PRODUCT IMAGE FOR THE DETAILS SECTION
  Widget getProductImageWidget() {
    return widget.productObj.Image != null
        ? _commonWidgets.getNetworkImageWidget(
            imgURL: widget.productObj.Image,
            imgHeight: imageHeight,
            errorCaption: imgErrorCaption,
          )
        : _commonWidgets.getNoPreviewSizedBox(
            boxHeight: imageHeight,
            captionText: imgErrorCaption,
          );
  }

  ///ITE RETURNS THE WIDGET FOR BODY_CONTENT
  Widget getDetailsScreenBody() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: ListView(
        children: <Widget>[
          ///SETTING THE PRODUCT IMAGE WIDGET
          getProductImageWidget(),

          ///GETTING THE ON_SCREEN STANDARD_FIELDS FOR THE SHOWING THE DETAILS
          ..._listViewRowsHelper.getRowCardContents(
            standardFields: widget.detailsOnScreenStandardFields,
            showOnGridFields: false,
            isExcludedFieldEnabled: true,
            classObj: widget.productObj,
            isEntitySectionCheckDisabled: true,
            excludedFieldsList: excludeStandardFields,
            currencyCaption: widget.currencyCaptionSF.Caption,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppBarTitles.PRODUCT_DETAILS),
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            }),
      ),
      body: getDetailsScreenBody(),
    );
  }
}
