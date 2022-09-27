import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:moblesales/helpers/index.dart';
import 'package:moblesales/screens/index.dart';

class SendMailDialog extends StatefulWidget {
  ///IT HANDLES THE CLOSE DIALOG EVENT
  final VoidCallback closeSearchDialog;

  ///USED TO RESET THE QUOTES/PRODUCTS DATA SELECTED FOR THE SEND_MAIL
  final VoidCallback resetSendMailData;

  ///TO SET API BODY PARAMETERS FOR THE PRODUCT OT THE SALES_ORDERS
  final String forType;

  ///STRING ARRAY FOR JSON TO SEND TO APPEND TO THE API BODY DATA
  final String idsData;

  ///SECONDARY STRING ARRAY FOR JSON TO DISPLAY ON TEXTBOX
  final String secondaryIdsData;

  SendMailDialog({
    @required this.forType,
    @required this.closeSearchDialog,
    @required this.resetSendMailData,
    @required this.idsData,
    this.secondaryIdsData = '',
  });

  @override
  _SendMailDialogState createState() => _SendMailDialogState();
}

class _SendMailDialogState extends State<SendMailDialog> {
  ///IT HOLDS ALL THE COMMON REUSABLE WIDGETS WHICH CAN BE USED THROUGH OUT PROJECT
  CommonWidgets _commonWidgets;

  ///HOLDS TEMPLATE VALUE FOR THE SEND_MAIL API CALL
  String _templateValue;

  ///HOLDS FILE_TYPE VALUE FOR THE SEND_MAIL API CALL
  String _fileTypeValue;

  ///HANDLES THE FORM GLOBAL KEY FOR THE VALIDATIONS
  final _formKey = GlobalKey<FormState>();

  ///HANDLES THE FORM GLOBAL KEY FOR THE VALIDATIONS OF INVOICES
  final _invoiceFormKey = GlobalKey<FormState>();

  ///HOLDS TEXT_FORM_FIELD_CONTROLLER
  TextEditingController _toMailIdsFieldController;

  ///HOLDS TEXT_FORM_FIELD_CONTROLLER
  TextEditingController _invoiceIdsFieldController;

  ///HOLDS COMMA SEPARATED EMAIL-ID's
  String toMailIds;

  ///TO IDENTIFY SEND_EMAIL CLICKED AND TO FREEZE THE CANCEL AND SUBMIT BUTTON FROM AGAIN PRESSING
  ///SHOWING LOADER AND TO MAKE TEXT_FORM_FIELD READONLY
  bool isSendEmailClicked;

  ///SHOWS THE SEND MAIL SUCCESS OR ERROR RESPONSE
  String sendMainResponse;

  ///HOLDS COMMA SEPARATED INVOICE DOCUMENT_NO's
  String invoiceDocumentNos;

  @override
  void initState() {
    super.initState();
    toMailIds = '';
    sendMainResponse = '';
    invoiceDocumentNos = '';
    _commonWidgets = CommonWidgets();
    _toMailIdsFieldController = TextEditingController();
    _invoiceIdsFieldController = TextEditingController();
    isSendEmailClicked = false;
    switch (widget.forType) {
      case 'SalesOrder':
        _templateValue = SendMailHelper.TEMPLATE_SALES_ORDER;
        _fileTypeValue = SendMailHelper.FILE_TYPE_SALES_ORDER;
        break;
      case 'Product':
        _templateValue = SendMailHelper.TEMPLATE_PRODUCT;
        _fileTypeValue = SendMailHelper.FILE_TYPE_PRODUCT;
        break;
      default:
        _templateValue = null;
        _fileTypeValue = null;
        break;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _toMailIdsFieldController.dispose();
    _invoiceIdsFieldController.dispose();
  }

  ///IT CHECKS IF SEND_MAIL ID's DATA PRESENT FOR SENDING THE MAIL OR NOT
  void handleSalesOrderInvoicesData() {
    if (_invoiceFormKey.currentState.validate()) {
      setState(() {
        isSendEmailClicked = true;
      });
      handleSendMailAPI();
    }
  }

  ///IT CALLS THE SEND_MAIL_API
  void handleSendMailAPI() {
    String errorMsg = '';
    try {
      ///CHECKING IF THE VALID DATA IS PRESENT FOR SENDING THE MAIL OR NOT
      if (widget.idsData != null && widget.idsData.length > 0) {
        ApiService.sendMail(
          toMailIds: toMailIds.trim(),
          fileType: _fileTypeValue,
          template: _templateValue,
          data: widget.idsData.trim(),
        )
            .then((sendMailRes) => {
                  this.setState(() {
                    if (sendMailRes.toUpperCase().contains('SUCCESS')) {
                      sendMainResponse = 'Mail Sent Successfully';
                      isSendEmailClicked = false;
                    } else {
                      sendMainResponse = sendMailRes.replaceAll('"', '');
                      isSendEmailClicked = false;
                    }
                  }),

//                  if (sendMailRes == 'SUCCESS')
//                    {
//                      this.setState(() {
//                        sendMainResponse = 'Mail Sent Successfully';
//                        isSendEmailClicked = false;
//                      }),
//                    }
//                  else
//                    {
//                      this.setState(() {
//                        sendMainResponse = sendMailRes;
//                        isSendEmailClicked = false;
//                      }),
//                    }
                })
            .catchError((e) => {
                  print('Send Mail Error response : '),
                  print(e),
                  errorMsg = "Internal server error please try again later",
                  if (e != null)
                    {
                      errorMsg = e.toString(),
                    },
                  this.setState(() {
//                    sendMainResponse =
//                        'Something went wrong while sending mail, Please try again later';
                    sendMainResponse = errorMsg;
                    isSendEmailClicked = false;
                  }),
                });
      } else {
        this.setState(() {
          sendMainResponse =
              'Please provide the valid ${widget.forType == SendMailHelper.TEMPLATE_SALES_ORDER ? 'Invoices' : 'Products'} information for sending mail';
          isSendEmailClicked = false;
        });
      }
    } catch (e) {
      print('Error Inside handleSendMailAPI ');
      print(e);
      errorMsg = "Internal server error please try again later";
      if (e != null && e.toString().isNotEmpty) {
        errorMsg = e.toString();
      }
      this.setState(() {
        sendMainResponse = errorMsg;
        isSendEmailClicked = false;
      });
    }
  }

  ///IT SETS THE SELECTED INVOICE DOCUMENT_NO'S ID's
  void setSelectedDocumentNoForMail(String selectedDocumentNos) {
    setState(() {
      invoiceDocumentNos = selectedDocumentNos;
    });
    _invoiceIdsFieldController.text = selectedDocumentNos;
    _invoiceFormKey.currentState.validate();
  }

  bool isLargeScreen;
  @override
  Widget build(BuildContext context) {
    isLargeScreen = isLargeScreenAvailable(context);
    _invoiceIdsFieldController.text = widget.idsData;
    _toMailIdsFieldController.text = widget.secondaryIdsData;

    return AlertDialog(
      title: Center(child: Text('Send Mail')),
      actionsPadding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
      insetPadding: isLargeScreen
          ? EdgeInsets.symmetric(horizontal: 40.0, vertical: 40.0)
          : EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      actions: <Widget>[
        Visibility(
          visible:
              false, // widget.forType == SendMailHelper.TEMPLATE_SALES_ORDER,
          child: RaisedButton(
            child: Text(
              'Select invoices',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            color: AppColors.blue,
            onPressed: () {
              showDialog(
                useRootNavigator: true,
                barrierDismissible: false,
                context: context,
                builder: (context) => InvoiceSearchDialog(
                  forLookupType: true,
                  setSelectedDocumentNoForMail: setSelectedDocumentNoForMail,
                ),
              );
            },
          ),
        ),
        RaisedButton(
          color: AppColors.blue,
          disabledColor: AppColors.grey,
          disabledTextColor: Colors.white,
          onPressed: isSendEmailClicked
              ? null
              : () {
                  if (_formKey.currentState.validate()) {
                    if (widget.forType != SendMailHelper.TEMPLATE_SALES_ORDER) {
                      setState(() {
                        isSendEmailClicked = true;
                      });
                      handleSendMailAPI();
                    } else
                      handleSalesOrderInvoicesData();
                  }
                },
          child: Text(
            'Send Mail',
            style: TextStyle(
              fontSize: 16.0,
            ),
          ),
        ),
        RaisedButton(
          onPressed: () {
            widget.closeSearchDialog();
            Navigator.of(context, rootNavigator: true).pop('PopupClosed');
          },
          child: Text(
            'Close',
            style: TextStyle(color: AppColors.grey, fontSize: 16.0),
          ),
        ),
      ],
      content: Container(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Form(
                key: _formKey,
                child: TextFormField(
                  readOnly: isSendEmailClicked,
                  controller: _toMailIdsFieldController,
                  keyboardType: TextInputType.multiline,
                  minLines: 1,
                  maxLines: 5,
                  onChanged: (value) {
                    _formKey.currentState.validate();
                    if (value != null && value.trim().length > 0) {
                      setState(() {
                        sendMainResponse = '';
                      });
                    }
                  },
                  validator: (value) {
                    setState(() {
                      toMailIds = '';
                      sendMainResponse = '';
                    });

                    ///CHECKING IF PROVIDED INPUT IS NOT EMPTY
                    if (value.isEmpty) {
                      this.setState(() {
                        isSendEmailClicked = false;
                      });
                      return 'Enter at least a single Email Id';
                    } else {
                      ///CHECKING IF ALL THE COMMA SEPARATED EMAIL-ID'S ARE VALID
                      bool isValid = true;
                      String invalidErrMsg = '';
                      String _tempToMailIds = '';
                      List<String> _validEmailIds = List<String>();
                      List<String> _emailIds = value.split(',');
                      _emailIds.forEach((element) {
                        if (element.trim().length < 1) {
                          isValid = false;
                        } else {
                          ///CHECKING EACH EMAIL_ID ENTERED IS VALID OR NOT
                          if (!isValidEmailFormat(value: element.trim())) {
                            isValid = false;
                          } else {
                            isValid = true;
                            _validEmailIds.add(element);
                            _tempToMailIds += '${element.trim()}|';
                          }
                        }
                      });
                      invalidErrMsg += 'Provide valid Email-Ids';
                      if (_validEmailIds.length < 1) {
                        this.setState(() {
                          isSendEmailClicked = false;
                        });
                        return invalidErrMsg;
                      } else {
                        _tempToMailIds = _tempToMailIds.substring(
                            0, _tempToMailIds.lastIndexOf('|'));

                        setState(() {
                          toMailIds = _tempToMailIds;
                        });
                        if (isValid == false) {
                          return invalidErrMsg;
                        } else {
                          return null;
                        }
                      }
                    }
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.grey,
                      ),
                    ),
                    hintText:
                        'Enter email-id e.g. user1@gmail.com, user2@gmail.com ',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 0.0),
                child: Text(
                  'Note: Multiple Email Ids separated by commas',
                  style: TextStyle(
                    color: AppColors.grey,
                  ),
                ),
              ),

              ///INVOICES SELECTOR IF SEND_EMAIL OPENED FORM THE SALES_ORDERS SCREEN
              Visibility(
                visible: widget.forType == SendMailHelper.TEMPLATE_SALES_ORDER,
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 10,
                    ),
                    Form(
                      key: _invoiceFormKey,
                      child: TextFormField(
                        readOnly: true,
                        controller: _invoiceIdsFieldController,
                        keyboardType: TextInputType.multiline,
                        minLines: 3,
                        maxLines: 5,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.grey,
                            ),
                          ),
                          hintText:
                              'Select invoices from the Select Invoices button',
                        ),
                        validator: (value) {
                          if (_invoiceIdsFieldController.text.isEmpty) {
                            return 'Select at least single invoice for sending mail';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ),

              ///API CALL LOADER LOADS WHILE SEND MAIL API RESPONSE RETURNED
              _commonWidgets.showCommonLoader(
                isLoaderVisible: isSendEmailClicked,
                loadingText: 'Please wait while sending mail',
                showLoadingText: true,
              ),

              ///SHOWS THE SEND MAIL RESPONSE ERROR OR THE SUCCESS
              Visibility(
                visible: sendMainResponse.length > 1 ? true : false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 25.0, 0.0, 0.0),
                    child: Text(
                      '$sendMainResponse',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
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
