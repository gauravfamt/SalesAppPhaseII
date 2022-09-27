import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:downloads_path_provider/downloads_path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:moblesales/helpers/colors.dart';
import 'package:moblesales/helpers/constants.dart';
import 'package:moblesales/helpers/services/connectivity_service.dart';
import 'package:moblesales/models/companies.dart';
import 'package:moblesales/screens/Common/CommonWidgets.dart';
import 'package:moblesales/screens/Common/CustomerSearchDialog.dart';
import 'package:moblesales/utils/Helper/CompanyDBHelper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class CustomerStatements extends StatelessWidget {
  final Company company;
  final int reportType; //1=Customer statement. 2 AR
  CustomerStatements({
    this.company,
    this.reportType,
  });

  @override
  Widget build(BuildContext context) {
    final platform = Theme.of(context).platform;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Customer Statements",
      home: CustomerStatementsPage(
        parentBuildContext: context,
        company: company,
        reportType: reportType,
        platform: platform,
      ),
    );
  }
}

class CustomerStatementsPage extends StatefulWidget {
  final TargetPlatform platform;
  final BuildContext parentBuildContext;
  final Company company;
  final int reportType;

  CustomerStatementsPage({
    Key key,
    @required this.parentBuildContext,
    this.company,
    this.reportType,
    this.platform,
  }) : super(key: key);

  @override
  CustomerStatementsPageState createState() => CustomerStatementsPageState();
}

class CustomerStatementsPageState extends State<CustomerStatementsPage> {
  CommonWidgets _commonWidgets;
  Company fromSelectedCompany;
  Company toSelectedCompany;
  List<Company> companyList;

  TextEditingController tecSelectedCompany;
  TextEditingController tecFromSelectedCompany;
  TextEditingController tecToSelectedCompany;

  TextEditingController tecFromDate;
  TextEditingController tecToDate;

  bool isPrintStatementButtonDisabled;
  bool isCheckStatusButtonDisabled;

  ReceivePort _port = ReceivePort();
  Directory _downloadsDirectory;


  String strerror;
  bool allPermissionGranted = false;
  String savePath;
  bool isShowLoader;
  StreamSubscription _connectionChangeStream;

  bool isOffline=false;

  @override
  void initState() {
    super.initState();
    _commonWidgets = CommonWidgets();
    isOffline=ConnectionStatus.isOffline;
    tecSelectedCompany = TextEditingController();
    tecToSelectedCompany = TextEditingController();
    tecFromSelectedCompany = TextEditingController();
    tecFromDate = TextEditingController();
    tecToDate = TextEditingController();
    companyList = List<Company>();
    isPrintStatementButtonDisabled = false;
    isCheckStatusButtonDisabled = true;
    getSiteCode();
    DefaultSettingsForDownloadTask();
    HandleActionButtonEnableStatus();
   // HandleCheckStatusApiCall();//added by Gaurav Gurav, 09-Aug-2022,
    isShowLoader=false;
    ///GETTING CONNECTION_SERVICE SINGLETON INSTANCE AND SUBSCRIBING TO CONNECTION_CHANGE EVENTS
    ConnectivityService connectionStatus = ConnectivityService.getInstance();
    _connectionChangeStream = connectionStatus.connectionChange.listen(connectionChanged);
  }

  void connectionChanged(dynamic hasConnection) {
    setState(() {
      isOffline = !hasConnection;
    });
    if (isOffline == true) {
      _commonWidgets.showFlutterToast(toastMsg: ConnectionStatus.NetworkNotAvailble);
    }
    else {
      _commonWidgets.showFlutterToast(toastMsg: ConnectionStatus.NewtworkRestored);
    }
    ConnectionStatus.isOffline=isOffline;
  }

  Future<void> initDownloadsDirectoryState() async {
    Directory downloadsDirectory;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      downloadsDirectory = await DownloadsPathProvider.downloadsDirectory;
    } on PlatformException {
      print('Could not get the downloads directory');
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _downloadsDirectory = downloadsDirectory;
    });
  }

  Future<Null> DefaultSettingsForDownloadTask() async {
    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];
      setState(() {});
    });

    FlutterDownloader.registerCallback(downloadCallback);
    if (widget.platform == TargetPlatform.android) {
      initDownloadsDirectoryState();
    }
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send.send([id, status, progress]);
  }

  Future<void> DownLoadTask(String strDwnLink) async {
    if (widget.platform == TargetPlatform.android) {
      var status = await Permission.storage.status;
      print('status $status');
      if (!status.isGranted) {
        status = await Permission.storage.request();
      }
      if (status.isGranted) {
        setState(() {
          allPermissionGranted = true;
          savePath = _downloadsDirectory.path;
        });
      }
    }
    else{
      setState(() {
        allPermissionGranted = true;
      });
    }
    if (allPermissionGranted == true) {
      try{
        print('allPermissionGranted $allPermissionGranted');
        if (widget.platform == TargetPlatform.android){
          final taskId = await FlutterDownloader.enqueue(
            url: strDwnLink,
            savedDir: savePath,
            showNotification: true,
            openFileFromNotification:true, // click on notification to open downloaded file (for Android)
          );
          FlutterDownloader.open(taskId: taskId).then((value) => print('Flutter Downloader ${value.toString()}'));
        }else{
          //const url ='https://referenceglobe.com/userfolders/RG3397/abc.pdf';
          //IOS Device Open PDF in defaulte browser
          if (await canLaunch(strDwnLink)) {
            await launch(strDwnLink,);
          } else {
            throw 'Could not launch $strDwnLink';
          }
        }
        //Download report
        saveReportName('default',true);
        HandleActionButtonEnableStatus();

      }catch(e){
        print('DownLoadTask $e');
      }
    }
  }

  Future<void> HandleActionButtonEnableStatus() async {
    try {
      String strReportCode = '';
      if (widget.reportType == 1) {
        //Customer Statements
        strReportCode = await Session.getData(Session.rptCSCode);
        print('CS Report Code $strReportCode');
      } else {
        // strReportCode=await Session.getARReportCode();
        strReportCode = await Session.getData(Session.rptARCode);
        print('AR Report Code $strReportCode');
      }
      if (strReportCode == 'defaultCSRptCode' ||
          strReportCode == 'defaultARRptCode' ||
          strReportCode == null ||
          strReportCode == '') {
        setState(() {
          isPrintStatementButtonDisabled = false;
          isCheckStatusButtonDisabled = true;
        });
      } else {
        setState(() {
          isPrintStatementButtonDisabled = true;
          isCheckStatusButtonDisabled = false;
        });
      }
    } catch (e) {
      print('Error inside HandleActionButtonEnableStatus ');
      print(e);
    }
  }

  void closeSearchDialog() {
    print('closeSearchDialog called of the Invoices page');
  }

  void handleFromSelectedCompany(Company selectedCompany) {
    print('Inside handleCustomerSelectedSearch fn of Invoice Screen');
    setState(() {
      fromSelectedCompany = selectedCompany;
    });
  }

  void showCompanyDialog() {
    showDialog(
        useRootNavigator: true,
        barrierDismissible: false,
        context: context,
        builder: (context) => CustomerSearchDialog(
              handleCustomerSelectedSearch: this.handleFromSelectedCompany,
              closeSearchDialog: this.closeSearchDialog,
              forLookupType: true,
            ));
  }

  Widget FromAndToCustomer() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: getCompanyLookupTF(
            label: 'From Customer',
            txtEdtCntrlr: tecFromSelectedCompany,
            objCompany: fromSelectedCompany,
          ),
        ),
        SizedBox(
          width: 4,
        ),
        Expanded(
          child: getCompanyLookupTF(
            label: 'To Customer',
            txtEdtCntrlr: tecToSelectedCompany,
            objCompany: toSelectedCompany,
          ),
        ),
      ],
    );
  }

  Widget FromAndToDate() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: getDatePicker(
            label: 'As of Date',
            txtEdtnCntrlr: tecToDate,
          ),
        ),
      ],
    );
  }

  Widget getCompanyLookupTF(
      {String label, TextEditingController txtEdtCntrlr, Company objCompany}) {
    return Card(
      child: TextFormField(
        readOnly: true,
        controller: txtEdtCntrlr,
        style: _formTFTextStyle,
        decoration: getFormTFInputDecoration('$label'),
        onTap: () {
          showDialog(
            useRootNavigator: true,
            barrierDismissible: false,
            context: context,
            builder: (context) => CustomerSearchDialog(
              handleCustomerSelectedSearch: (Company companyObj) {
                if (label == 'From Customer' || label == 'To Customer') {
                  setState(() {
                    tecSelectedCompany.text = '';
                  });
                } else {
                  setState(() {
                    tecFromSelectedCompany.text = '';
                    tecToSelectedCompany.text = '';
                  });
                }
                setState(() {
                  txtEdtCntrlr.text = companyObj.CustomerNo;
                  objCompany = companyObj;
                  if (label == 'Select Customer') {
                    txtEdtCntrlr.text =
                        '${companyObj.Name} (${companyObj.CustomerNo})';
                  }
                });
              },
              closeSearchDialog: this.closeSearchDialog,
              forLookupType: true,
            ),
          );
        },
      ),
    );
  }

  Widget getDatePicker({
    String label,
    TextEditingController txtEdtnCntrlr,
  }) {
    return Card(
      elevation: 1,
      child: TextFormField(
        readOnly: true,
        controller: txtEdtnCntrlr,
        onTap: () {
          showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: new DateTime(1700),
            lastDate: DateTime.now().add(new Duration(days:3650))
          ).then(
            (date) => {
              print('Selected Date $date'),

              ///UPDATING DATE TO ITS SPECIFIC FIELD_VALUE
              if (date != null)
                {
                  setState(() {
                    txtEdtnCntrlr.text = Other().DateFormater.format(date);
                  }),
                }
            },
          );
        },
        style: _formTFTextStyle,
        decoration: getFormTFInputDecoration(label),
      ),
    );
  }

  final TextStyle _formTFTextStyle = TextStyle(
    color: AppColors.black,
    fontFamily: 'OpenSans',
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  InputDecoration getFormTFInputDecoration(String label) {
    return InputDecoration(
      contentPadding: EdgeInsets.fromLTRB(5, 10, 5, 10),
      labelText: '$label',
      border: InputBorder.none,
      labelStyle: TextStyle(
        color: Colors.blue,
        height: 0.5,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget getListValueWidget(textContent, type) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        '$textContent',
        style: TextStyle(
          color: type == 1 ? Colors.white : AppColors.black,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  saveReportName(String reportName,bool isNavigate) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (widget.reportType == 1) {
        print('CS $reportName');
        prefs.setString(Session.rptCSCode,
            '${reportName == 'default' ? 'defaultCSRptCode' : reportName}');
      } else {
        print('AR $reportName');
        prefs.setString(Session.rptARCode,
            '${reportName == 'default' ? 'defaultARRptCode' : reportName}');
      }
      setState(() {
        isPrintStatementButtonDisabled == true;
        isCheckStatusButtonDisabled == false;
      });
     // Back to Main Screen
      if(isNavigate==true){
        Navigator.pop(widget.parentBuildContext, true);
        if (reportName.contains('default')) {
          if(widget.platform == TargetPlatform.android)
            _commonWidgets.showFlutterToast(toastMsg: 'Report downloading…');
        } else {
          _commonWidgets.showFlutterToast(
              toastMsg: 'Report request send successfully');
        }
      }

    } catch (e) {
      print('Error inside saveReportName');
      print(e);
    }
  }

  String salesSite="";
  Future<String> getSiteCode() async {
    salesSite= await Session.getData(Session.salesSite);
    print(salesSite);
    return salesSite;
  }

  Future<void> HandlePrintStatementApiCall() {
    try {
      String requestBody = '{';
      if (widget.reportType == 1) {
        getSiteCode();
        requestBody += '"ReportType":"CS",'; //Customer Statement, CUSSTA, on 22-04-2021
        requestBody += '"SiteFrom":"${salesSite}",';
        requestBody += '"SiteTo":"${salesSite}",';
      } else {
        requestBody += '"ReportType":"AR",'; //AR     BALAGEGRP on 22-04-2021
      }
      if (tecToSelectedCompany.text == '') {
        var temp =
            tecSelectedCompany.text.toString().replaceAll(')', '').split('(');
        requestBody += '"CustomerFrom":"${tecFromSelectedCompany.text}",';
        requestBody += '"CustomerTo":"${tecFromSelectedCompany.text}",';
      } else {
        requestBody += '"CustomerFrom":"${tecFromSelectedCompany.text}",';
        requestBody += '"CustomerTo":"${tecToSelectedCompany.text}",';
      }
      if (tecToDate.text != '') {
        requestBody += '"DateTo":"${tecToDate.text}"';
      }

      requestBody += '}';
      print('strRequest $requestBody');
      if (requestBody != '') {
        print('Request Body: $requestBody');
        var temp;
        ApiService.addReport(
          requestBody: requestBody,
        )
            .then((value) => {
                    setState(() {
                    isShowLoader=false;
                    }),
                  if (value.toString().contains('ReportName'))
                    {
                      print('Got Response:${value}'),
                      temp = value.toString().split(','),
                      temp = temp[1].split(':'),
                      temp[1].toString(),
                      print('Report Name ${temp[1].toString()}'),
                      saveReportName(temp[1].toString().toString(),true),
                      HandleActionButtonEnableStatus(),
                    }else{
                    _commonWidgets.showAlertMsg(alertMsg: value,context:context,MessageType: AlertMessageType.ERROR ),
                  }
                })
            .catchError((e) => {
          setState(() {
            isShowLoader=false;
          }),
                  print('add Report Error Response $e'),
                });
      }
    } catch (e) {
      setState(() {
        isShowLoader=false;
      });
      print('Error in side HandlePrintStatementApiCall $e');
    }
  }

  String strReportName;
  Future<void> HandleCheckStatusApiCall() async {


    try {
      if (widget.reportType == 1) {
        strReportName = await Session.getCustomerStatementReportCode();
        print('CS Report Code $strReportName');
      } else {
        strReportName = await Session.getARReportCode();
        print('AR Report Code $strReportName');
      }
      if(strReportName !="defaultCSRptCode" && strReportName!="defaultARRptCode"){
        ApiService.getReportStatus(reportName: strReportName)
            .then((value) => {
          print(value),
          if (!value.toString().contains('Error'))
            {
              print('Got Response:${value}'),
              if (value.toString().contains('.pdf') ||
                  value.toString().contains('.PDF'))
                {
                  DownLoadTask(value.toString()),
                }
              else if (value.toString().contains('REQUEST_DELETED'))//Adde by gaurav gurav 9-aug-2022
                {
                  _commonWidgets.showAlertMsg(alertMsg:'Your last request was not processed, kindly add new request',
                      context: context,MessageType: AlertMessageType.INFO ),
                  saveReportName('default',false),
                  HandleActionButtonEnableStatus(),
                }
              else
                {
                  _commonWidgets.showAlertMsg(alertMsg:'Report not ready to download, please try again later',
                      context: context,MessageType: AlertMessageType.INFO ),
                }
            }
        })
            .catchError((e) => {
          print('add Report Error Response $e'),
        });
      }
    } catch (e) {
      print('Error in side HandlePrintStatementApiCall $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.reportType == 1
            ? Text('Customer Statement')
            : Text('AR Report'),
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(widget.parentBuildContext);
            }),
      ),
      body: Container(
        padding: const EdgeInsets.all(17.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            FromAndToCustomer(),
            SizedBox(
              height: 5,
            ),
            FromAndToDate(),
            SizedBox(
              height: 5,
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: RaisedButton(
                    onPressed: isPrintStatementButtonDisabled
                        ? null
                        : () {
                            if (tecFromSelectedCompany.text == '' &&
                                tecToSelectedCompany.text == '') {
                              _commonWidgets.showAlertMsg(alertMsg:'Please select Customer',
                                  context: context,MessageType: AlertMessageType.INFO );
                            } else if (tecFromSelectedCompany.text == '') {
                              _commonWidgets.showAlertMsg(alertMsg:'Please select From Customer',
                                  context: context,MessageType: AlertMessageType.INFO );
                            } else {
                              if (tecToDate.text != '') {
                                setState(() {
                                  isShowLoader=true;
                                });
                                isOffline==false? HandlePrintStatementApiCall():
                                    _commonWidgets.showFlutterToast(toastMsg: ConnectionStatus.NetworkNotAvailble);
                              } else {
                                _commonWidgets.showAlertMsg(alertMsg:'Please select As of Date',
                                    context: context,MessageType: AlertMessageType.INFO );
                              }
                            }
                          },
                    child: Text(
                      'Print Statement',
                      style: TextStyle(color: Colors.white),
                    ),
                    color: AppColors.blue,
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                Expanded(
                  child: RaisedButton(
                    onPressed: isCheckStatusButtonDisabled
                        ? null
                        : () {
                      isOffline==false? HandleCheckStatusApiCall():
                      _commonWidgets.showFlutterToast(toastMsg: ConnectionStatus.NetworkNotAvailble);
                          },
                    child: Text(
                      'Download',
                      style: TextStyle(color: Colors.white),
                    ),
                    color: AppColors.blue,
                  ),
                ),


              ],
            ),

            SizedBox(
              height: 5,
            ),
            _commonWidgets.showCommonLoader(
                isLoaderVisible: isShowLoader),
          ],
        ),
      ),
    );
  }
}
