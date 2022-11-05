import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:moblesales/helpers/index.dart';
import 'package:moblesales/models/index.dart';

class CommonWidgets {
  ///IT RETURNS THE NETWORK_IMAGE WIDGET ALSO HANDLES THE ERROR TEXT
  ///IF ANY OCCURRED WHILE LOADING/FETCHING THE IMAGE
  Widget getNetworkImageWidget({
    String imgURL,
    double imgHeight,
    String errorCaption,
  }) {
    return Image.network(
      '$imgURL',
      height: imgHeight,
      fit: BoxFit.fill,

      ///SHOWS THE LOADER TILL IMAGE IS LOADED COMPLETELY
      loadingBuilder: (BuildContext context, Widget child,
          ImageChunkEvent loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: SizedBox(
            height: 200.0,
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes
                    : null,
              ),
            ),
          ),
        );
      },

      ///HANDLES ERROR OCCURRED DURING FETCHING OR LOADING THE IMAGE AND SHOWS NO_PREVIEW_TEXT
      errorBuilder:
          (BuildContext context, Object exception, StackTrace stackTrace) {
        return getNoPreviewSizedBox(
          boxHeight: imgHeight,
          captionText: errorCaption,
        );
      },
    );
  }

  Other _Other;

  ///IT RETURNS THE SIZED_BOX FOR SHOWING THE TEXT IF IMAGE IS NOT LOADED
  ///OR ANY ERROR OCCURRED WHILE FETCHING THE IMAGE
  Widget getNoPreviewSizedBox({
    double boxHeight,
    String captionText,
  }) {
    return Image.asset(
      'assets/img/no_img_cropped.png',
      height: 150,
      width: 150,
    );
//      SizedBox(
//      height: boxHeight,
//      child: Center(
//        child: Text(
//          '$captionText',
//          style: TextStyle(color: AppColors.grey),
//        ),
//      ),
//    );
  }

  void connectionChanged(dynamic hasConnection) {
    print('hasConnection ${hasConnection}');
    ConnectionStatus.isOffline = !hasConnection;
    if (ConnectionStatus.isOffline == true) {
      showFlutterToast(toastMsg: ConnectionStatus.NetworkNotAvailble);
    } else {
      showFlutterToast(toastMsg: ConnectionStatus.NewtworkRestored);
    }
  }

  ///IT SHOWS FLUTTER_TOAST WITH THE TOAST MESSAGES PROVIDED
  void showFlutterToast({
    @required String toastMsg,
  }) {
    Fluttertoast.showToast(
      msg: '${toastMsg != null ? toastMsg : ''}',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 4,
      backgroundColor: Colors.black38,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  ///IT RETURNS THE CircularProgressIndicator LOADER
  ///WHICH IS USEFUL FOR LISTING'S PAGINATION AND INITIAL LOADER

  int intFlagForLoader = 0;
  Widget showCommonLoader({
    @required bool isLoaderVisible,
    String loadingText,
    bool showLoadingText = false,
  }) {
    if (isLoaderVisible == true) {
      intFlagForLoader = intFlagForLoader + 1;
      if (intFlagForLoader == 2) {
        isLoaderVisible = false;
        intFlagForLoader = 0;
      }
    } else {
      if (intFlagForLoader != 0) {
        intFlagForLoader = intFlagForLoader - 1;
      }
      if (intFlagForLoader < 0) {
        intFlagForLoader = 0;
      }
    }

    return new Visibility(
      visible: isLoaderVisible,
      child: Center(
        child: Padding(
          padding: showLoadingText
              ? EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 10.0)
              : EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 50.0),
          child: showLoadingText
              ? Column(
                  children: <Widget>[
                    CircularProgressIndicator(
                      backgroundColor: Colors.teal.shade100,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
                      child: Text('$loadingText'),
                    ),
                  ],
                )
              : CircularProgressIndicator(
                  backgroundColor: Colors.teal.shade100,
                ),
        ),
      ),
    );
  }

  ///IT RETURNS THE SEARCH_HANDLER BUTTON
  Widget getCustomSearchActionButton({
    @required Function onPressedHandler,
    @required Widget buttonIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
      child: SizedBox(
        width: 40.0,
        child: RaisedButton(
          padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
          color: AppColors.blue,
          onPressed: onPressedHandler,
          child: buttonIcon,
        ),
      ),
    );
  }

  ///IT RETURNS THE SEARCH_CLEAR BUTTON
  Widget getCustomSearchClearButton({
    @required Function onPressedHandler,
    @required Widget buttonIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
      child: SizedBox(
        width: 40.0,
        child: FlatButton(
          padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
//          color: AppColors.lightGrey,
          onPressed: onPressedHandler,
          child: buttonIcon,
        ),
      ),
    );
  }

  ///IT RETURNS THE COMPANY SEARCH FIELD WHICH OPENS THE CUSTOMER LOOKUP SCREEN
  ///MOSTLY USED IN LISTING SCREENS AND PRODUCT LAST_PRICE_LOOKUP SCREEN
  Widget getListingCompanySelectorWidget({
    @required Function showCompanyDialogHandler,
    @required Function clearSelectedCompanyHandler,
    @required Company selectedCompany,
    bool isForPriceLookupView = false,
    double defaultCardElevation = 0.0,
    EdgeInsets defaultPadding =
        const EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 0.0),
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: isForPriceLookupView
                ? const EdgeInsets.all(0.0)
                : defaultPadding,
            child: Card(
              elevation: isForPriceLookupView ? 3.0 : defaultCardElevation,
              child: GestureDetector(
                onTap: showCompanyDialogHandler,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          '${(selectedCompany != null && selectedCompany.Name != null) ? selectedCompany.Name : '${CommonConstants.CUSTOMER_SEARCH_PLACEHOLDER_MSG}'}',
                          style:
                              TextStyle(color: AppColors.grey, fontSize: 16.0),
                        ),
                      ),
                    ),

                    ///SELECTED CUSTOMER CLEAR BUTTON
                    Visibility(
                      visible: selectedCompany != null &&
                          selectedCompany.Name != null,
                      child: getCustomSearchClearButton(
                        onPressedHandler: clearSelectedCompanyHandler,
                        buttonIcon: Icon(Icons.clear, color: AppColors.grey),
                      ),
                    ),
                    getCustomSearchActionButton(
                      onPressedHandler: showCompanyDialogHandler,
                      buttonIcon: Icon(Icons.search, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  ///IT RETURNS THE PRODUCT SEARCH FIELD WHICH OPENS THE PRODUCTS LOOKUP SCREEN
  ///MOSTLY USED IN LISTING SCREENS AND PRODUCT LAST_PRICE_LOOKUP SCREEN
  Widget getListingProductSelectorWidget({
    @required Function showProductDialogHandler,
    @required Function clearSelectedProductHandler,
    @required Product selectedProduct,
    bool isForPriceLookupView = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: isForPriceLookupView
                ? const EdgeInsets.all(0.0)
                : const EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 0.0),
            child: Card(
              elevation: isForPriceLookupView ? 3.0 : 0.0,
              child: GestureDetector(
                onTap: showProductDialogHandler,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          '${(selectedProduct != null && selectedProduct.ProductCode != null) ? selectedProduct.ProductCode : '${CommonConstants.PRODUCT_SEARCH_PLACEHOLDER_MSG}'}',
                          style:
                              TextStyle(color: AppColors.grey, fontSize: 16.0),
                        ),
                      ),
                    ),

                    ///SELECTED PRODUCT CLEAR BUTTON
                    Visibility(
                      visible: selectedProduct != null &&
                          selectedProduct.ProductCode != null,
                      child: getCustomSearchClearButton(
                        onPressedHandler: clearSelectedProductHandler,
                        buttonIcon: Icon(Icons.clear, color: AppColors.grey),
                      ),
                    ),
                    getCustomSearchActionButton(
                      onPressedHandler: showProductDialogHandler,
                      buttonIcon: Icon(Icons.search, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  ///BUILDS NO DATA WIDGET FOR THE LISTING PAGES
  ///JUST PASS THE TEXT CONTENT AND THE IS_VISIBLE PARAMETER
  Widget buildEmptyDataWidget({
    @required String textMsg,
    @required bool isVisible,
  }) {
    return Visibility(
      visible: isVisible,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
          child: Text(
            '$textMsg',
            style: TextStyle(color: AppColors.black, fontSize: 16.0),
          ),
        ),
      ),
    );
  }

  void showAlertMsg({
    String alertMsg,
    BuildContext context,
    AlertMessageType MessageType,
    Function() onMsgPressed,
  }) {
    if (MessageType == AlertMessageType.SUCCESS) {
      AlertMessage(
        context: context,
        alertMsg: alertMsg,
        alertIcon: Icon(
          Icons.check_circle_outline,
          color: Colors.green,
          size: 50,
        ),
        alertTitle: "SUCCESS",
        onDialogPressed: onMsgPressed,
      );
    } else if (MessageType == AlertMessageType.ERROR) {
      AlertMessage(
        context: context,
        alertMsg: alertMsg,
        alertIcon: Icon(
          Icons.error,
          color: Colors.red,
          size: 50,
        ),
        alertTitle: "ERROR",
        onDialogPressed: onMsgPressed,
      );
    } else if (MessageType == AlertMessageType.INFO) {
      AlertMessage(
        context: context,
        alertMsg: alertMsg,
        alertIcon: Icon(
          Icons.info_outline,
          color: Colors.blue,
          size: 50,
        ),
        alertTitle: "INFORMATION",
        onDialogPressed: onMsgPressed,
      );
    } else if (MessageType == AlertMessageType.WARNING) {
      AlertMessage(
        context: context,
        alertMsg: alertMsg,
        alertIcon: Icon(
          Icons.warning,
          color: Colors.deepOrangeAccent,
          size: 50,
        ),
        alertTitle: "WARNING",
        onDialogPressed: onMsgPressed,
      );
    }
  }

  void ShowSnackBar({
    String alertMsg,
    BuildContext context,
    Icon alertIcon,
    String alertTitle,
  }) {
    final snackBar = SnackBar(
      content: const Text('Yay! A SnackBar!'),
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () {
          // Some code to undo the change.
        },
      ),
    );

    // Find the ScaffoldMessenger in the widget tree
    //
  }

  void AlertMessage({
    String alertMsg,
    BuildContext context,
    Icon alertIcon,
    String alertTitle,
    Function() onDialogPressed,
  }) {
    showDialog(
      useRootNavigator: true,
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        actions: <Widget>[
          RaisedButton(
            onPressed: () {
              if (onDialogPressed != null) {
                onDialogPressed();
              }
              Navigator.of(context, rootNavigator: true).pop('PopupClosed');
            },
            color: AppColors.blue,
            child: Text('OK'),
          )
        ],
        content: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Center(
                child: alertIcon,
              ),
              Text(
                '$alertTitle',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                '$alertMsg',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  final TextStyle _formTFTextStyle = TextStyle(
    color: AppColors.black,
    fontFamily: 'OpenSans',
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

//  Widget commonTextField({
//    @required textValue,
//    label,
//    maxLength = 10,
//    maxLines = 1,
//    isReadOnly = false,
//    isRequired = false,
//    textInputType = TextInputType.text,
//    bool isExpanded = false,
//    EdgeInsets outerPadding = StyleUtils.smallAllPadding,
//  }) {
//    try {
//      Widget _widget = Padding(
//          padding: outerPadding,
//          child: TextFormField(
//            maxLength: maxLength,
//            minLines: maxLines,
//            maxLines: maxLines,
//            readOnly: isReadOnly,
//            controller: new TextEditingController(text: textValue),
//            keyboardType: textInputType,
//            style: _formTFTextStyle,
//            decoration: getFormTFInputDecoration('$label', true),
//            onChanged: (value) {
//              if (value != null && value != '') {
//                setState(() {
//                  textValue = value;
//                });
//
//                print(value);
//              }
//            },
//            validator: (value) {
//              if (isRequired) {
//                if (value.isEmpty) {
//                  return 'Enter the value for $label field';
//                }
//                try {
//                  textValue = value.toString();
//                } catch (e) {
//                  print(
//                      'Error while setting the value for the textEditingController For Header Fields');
//                  print(e);
//                }
//              }
//              return textValue;
//            },
//          ));
//      return isExpanded ? Expanded(child: _widget) : _widget;
//    } catch (e) {
//      print("Error in commonTextField");
//      print(e);
//      return Container(
//        child: Text(e),
//      );
//    }
//  }

  InputDecoration getFormTFInputDecoration(
      String label, bool isShowCounterText) {
    return isShowCounterText
        ? InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(5, 20, 5, 10),
            labelText: '$label',
            labelStyle: TextStyle(
              color: Colors.blue,
              height: 0.5,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          )
        : InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(5, 20, 5, 10),
            labelText: '$label',
            counterText: '',
            labelStyle: TextStyle(
              color: Colors.blue,
              height: 0.5,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          );
  }

  List<Widget> dynamicWidgetStyles(BuildContext context,
      {List<Widget> widgets}) {
    print('Inside dynamicWidgetStyles');
    print(widgets.length);
    try {
      List<Widget> wrapChildren = <Widget>[];
      if (MediaQuery.of(context).size.width > 1000) {
        int chunkSize = 4;
        for (var i = 0; i < widgets.length; i += chunkSize) {
          Widget temp = Row(
            children: widgets.sublist(
                i,
                i + chunkSize > widgets.length
                    ? widgets.length
                    : i + chunkSize),
          );

          wrapChildren.add(temp);
        }
        print(widgets.length);
        return wrapChildren;
      } else if (MediaQuery.of(context).size.width > 750 &&
          MediaQuery.of(context).size.width <= 1000) {
        int chunkSize = 3;
        for (var i = 0; i < widgets.length; i += chunkSize) {
          Widget temp = Row(
            children: widgets.sublist(
                i,
                i + chunkSize > widgets.length
                    ? widgets.length
                    : i + chunkSize),
          );
          wrapChildren.add(temp);
        }
        print(widgets.length);
        return wrapChildren;
      } else if (MediaQuery.of(context).size.width > 300 &&
          MediaQuery.of(context).size.width <= 750) {
        int chunkSize = 2;
        for (var i = 0; i < widgets.length; i += chunkSize) {
          Widget temp = Row(
            children: widgets.sublist(
                i,
                i + chunkSize > widgets.length
                    ? widgets.length
                    : i + chunkSize),
          );
          wrapChildren.add(temp);
        }
        print(widgets.length);
        return wrapChildren;
      } else if (MediaQuery.of(context).size.width <= 300) {
        return widgets;
      } else {
        print(widgets.length);
        return widgets;
      }
    } catch (e) {
      print('Error in preparing Dynamic Widgets');
      print(e);
      print(widgets.length);
      return widgets;
    }
  }
}
