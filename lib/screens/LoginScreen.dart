import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:moblesales/main.dart';
import 'package:moblesales/models/index.dart';
import 'package:moblesales/screens/index.dart';
import 'package:moblesales/utils/index.dart';
import 'package:moblesales/helpers/index.dart';

//void main() => runApp(Login());

class Login extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    debugPrint("Login");
    /*SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values); //comment error
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
        // statusBarColor is used to set Status bar color in Android devices.
        statusBarColor: Colors.blue,
        // To make Status bar icons color white in Android devices.
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.blue,
        // statusBarBrightness is used to set Status bar icon color in iOS.
        statusBarBrightness: Brightness.light
        // Here light means dark color Status bar icons.
        ));*/
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Login",
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //Uncomment for Release
  final TextEditingController userNameController = new TextEditingController();
  final TextEditingController passwordController = new TextEditingController();
  final TextEditingController apiDomainController = new TextEditingController();
  //Comment for Release, By Mayuresh - S
  // final TextEditingController userNameController =
  //     new TextEditingController(text: "x3model@gmail.com");
  // final TextEditingController passwordController =
  //     new TextEditingController(text: "user@portal");
  // final TextEditingController apiDomainController =
  //     new TextEditingController(text: "http://49.248.14.237:8185/api/v1.0/");
  //Mayuresh - E
  bool isVisible = true;

  /// FOR SHOWING FULLSCREEN LOADER
  bool isFullScreenLoading;

  CommonWidgets _commonWidgets;

  bool _isFirstTimeLogedIn;

  CompanyDBHelper _companyDBHelper;
  AddressDBHelper _addressDBHelper;
  SyncMasterDBHelper _syncMasterDBHelper;
  CommonDBHelper _commonDBHelper;

  @override
  void initState() {
    super.initState();
    isFullScreenLoading = false;
    _commonWidgets = CommonWidgets();
    _isFirstTimeLogedIn = true;
    _companyDBHelper = CompanyDBHelper();
    _addressDBHelper = AddressDBHelper();
    _syncMasterDBHelper = SyncMasterDBHelper();
    _commonDBHelper = CommonDBHelper();
    isFirstTimeLogIn();
  }

  Future<void> isFirstTimeLogIn() async {
    String strApiDomain = await Session.getData(Session.apiDomain);
    print('strApiDomain $strApiDomain');
    if (strApiDomain == null || strApiDomain == '' || strApiDomain == 'null') {
      setState(() {
        _isFirstTimeLogedIn = true;
      });
    } else {
      setState(() {
        apiDomainController.text = strApiDomain;
        _isFirstTimeLogedIn = false;
      });
    }
  }

  signIn(String userName, String password, String apiDomain) async {
    try {
//    final queryParams = {'username': userName, 'password': password};
//debugPrint("http://192.168.0.165:92/api/v1.0/Login?username=admin@greytrix.com&password=admin@1234");
      setState(() {
        isFullScreenLoading = true;
      });
      print('${apiDomain}${URLs.LOGIN}?username=$userName&password=$password');
      final http.Response response = await http.post(
        '${apiDomain}${URLs.LOGIN}?username=$userName&password=$password',
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      ).timeout(duration);

      print('response.statusCode ${response.statusCode}');
      print('response.body ${response.body}');
      if (response.statusCode == 200) {
        var loginResponse = LoginResponse.fromJson(json.decode(response.body));
        print(loginResponse);
        //Remove Existing customer details if new user loged in
        String strExistingUserName = await Session.getData(Session.userName);
        String strExistingIP = await Session.getData(Session.apiDomain);

        if (strExistingIP != null &&
            strExistingIP != apiDomainController.text) {
          //Logi with new IP, delete all offline data
          var deleteRes = await _commonDBHelper.deleteAllTablesData();
          print('allTables data deleteRes : $deleteRes');
        } else if (strExistingUserName != null &&
            strExistingUserName != userNameController.text) {
          //Login with different user name
          var companiesDeleteRes = await _companyDBHelper.deleteALLRows();
          print('All companiesDeleteRes : $companiesDeleteRes');
          var adressesDeleteRes = await _addressDBHelper.deleteALLRows();
          print('All adressesDeleteRes : $adressesDeleteRes');
          var syncMasterResetRes =
              await _syncMasterDBHelper.updateMasterTableLastSyncDateByName(
            lastSyncDate: '',
            masterTableName: _companyDBHelper.tableName,
          );
          print('All syncMasterResetRes : $syncMasterResetRes');
        }
        saveSession(userName, password, loginResponse.AccessToken, apiDomain);
      } else if (response.statusCode == 404 &&
          (response.body.contains("File or directory not found") ||
              response.body.contains("Server Error"))) {
        //To avoid disply html content return due to enter inccorect api domain
        setState(() {
          isFullScreenLoading = false;
        });
        Fluttertoast.showToast(
            msg: 'Please check api domain ',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.black38,
            textColor: Colors.white,
            fontSize: 16.0);
      } else {
        setState(() {
          isFullScreenLoading = false;
        });
        debugPrint("Failed to login!");
        String msg =
            "The user name, password or api's domain you entered isn't correct. Try entering it again.";
        if (response.body != null && response.body.toString().isNotEmpty) {
          msg = response.body
              .toString()
              .replaceAll('{', '')
              .replaceAll('}', '')
              .replaceAll('"', '')
              .replaceAll('Error', '')
              .replaceAll(':', '');
        }
        Fluttertoast.showToast(
            msg: msg,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.black38,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    } catch (e) {
      print('Error While sign_in');
      print(e);
      setState(() {
        isFullScreenLoading = false;
      });
      _commonWidgets.showFlutterToast(
        toastMsg: 'Failed To Login!',
      );
    }
  }

  saveSession(String userName, String password, String accessToken,
      String apiDomain) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(Session.userName, userName);
    prefs.setString(Session.accessToken, accessToken);
    prefs.setString(Session.password, password);
    prefs.setString(Session.apiDomain, apiDomain);

    ApiService.getLoggedInUserDetails()
        .then((users) => {
              if (users.length > 0)
                {
                  print('Setting the LoggedIn User UserCode '),
                  print('Sales Site:${users[0].SalesSite} '),
                  prefs.setString(Session.userCode, '${users[0].UserCode}'),
                  prefs.setString(Session.salesSite, '${users[0].SalesSite}'),
                  prefs.setString(Session.realName, '${users[0].RealName}'),
                  this.navigateToMainScreen(),
                }
              else
                {
                  print('No User Found Found for the username'),
                  this.navigateToMainScreen(),
                }
            })
        .catchError((e) => {
              print(
                  'Error while getting the LoggedIn User information for getting the UserCode'),
              print(e),
              this.navigateToMainScreen(),
            });
  }

  ///IT NAVIGATES TO THE MAIN SCREEN
  void navigateToMainScreen() {
    setState(() {
      isFullScreenLoading = false;
    });
    Navigator.of(context).pushAndRemoveUntil(

        ///DIRECTLY NAVIGATION TO THE MAIN_SCREEN COMMENTED AS NEEDED TO SYNC LOOKUP'S DATA AFTER LOGIN
//        MaterialPageRoute(builder: (BuildContext context) => MainScreen()),
        ///HERE NAVIGATING TO THE MY_APP AS IT HANDLES THE LOOKUP'S DATA SYNC,
        /// AND THEN NAVIGATE TO THE MAIN_SCREEN AGAIN
        MaterialPageRoute(builder: (BuildContext context) => MyAPP()),
        (Route<dynamic> route) => false);
  }

  Widget _buildUserNameTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Login',
          style: TextStyle(
            color: Colors.black,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10.0),
        Text(
          'Welcome Back,',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 2.0),
        Text(
          'Please login to your account',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 50.0),
        Container(
          alignment: Alignment.centerLeft,
          height: 60.0,
          child: TextFormField(
            controller: userNameController,
            keyboardType: TextInputType.emailAddress,
            obscureText: false,
            style: TextStyle(
              color: Colors.black,
              fontFamily: 'OpenSans',
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(5, 20, 5, 10),
              labelText: 'USER NAME',
              labelStyle: TextStyle(
                color: Colors.blue,
                height: 0.5,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordTF() {
    void _toggleVisibility() {
      setState(() {
        if (isVisible == true) {
          isVisible = false;
        } else {
          isVisible = true;
        }
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          alignment: Alignment.centerLeft,
          height: 60.0,
          child: TextFormField(
            controller: passwordController,
            style: TextStyle(
              color: Colors.black,
              fontFamily: 'OpenSans',
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(5, 20, 5, 10),
              suffixIcon: Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: IconButton(
                  onPressed: () {
                    _toggleVisibility();
                  },
                  icon: isVisible
                      ? Icon(Icons.visibility_off, size: 20)
                      : Icon(Icons.visibility, size: 20),
                ),
              ),
              labelText: 'PASSWORD',
              labelStyle: TextStyle(
                color: Colors.blue,
                height: 0.5,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            obscureText: isVisible ? true : false,
          ),
        ),
      ],
    );
  }

  Widget _buildApiDomainTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          alignment: Alignment.centerLeft,
          height: 60.0,
          child: TextFormField(
            //  readOnly:_isFirstTimeLogedIn?false:true,
            controller: apiDomainController,
            keyboardType: TextInputType.url,
            obscureText: false,
            style: TextStyle(
              color: Colors.black,
              fontFamily: 'OpenSans',
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(5, 20, 5, 10),
              labelText: "API'S DOMAIN",
              labelStyle: TextStyle(
                color: Colors.blue,
                height: 0.5,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            validator: (value) {
              if (value.length < 5) {
                return 'Please enter a valid Domain';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  bool IsDomainValidate(String strDomain) {
    bool _validURL = Uri.parse(strDomain).isAbsolute;
    print('_validURL $_validURL');
    if (_validURL == true) {
      if (!strDomain.endsWith('/'))
        //To avoid api error, ocuure due to absence of / at end of url
        strDomain += '/';
      apiDomainController.text = strDomain;
    }
    return _validURL;
  }

  Widget _buildLoginBtn() {
    return Container(
        alignment: Alignment.topLeft,
        padding: EdgeInsets.symmetric(vertical: 40.0),
        child: RaisedButton(
          padding: EdgeInsets.all(12),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(
                child: Text(
                  'LOGIN',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
              Icon(
                Icons.arrow_forward,
                color: Colors.white,
              ),
            ],
          ),
          color: Colors.blue,
          onPressed: () {
            debugPrint("pressed");
            if (userNameController.text == "" ||
                passwordController.text == "" ||
                apiDomainController.text == "") {
              Fluttertoast.showToast(
                  msg: "Please fill all fields!",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.black38,
                  textColor: Colors.white,
                  fontSize: 16.0);
            } else if (IsDomainValidate(apiDomainController.text) == false) {
              Fluttertoast.showToast(
                  msg: "Please enter a valid Domain!",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.black38,
                  textColor: Colors.white,
                  fontSize: 16.0);
            } else {
              signIn(userNameController.text.trimRight(),
                  passwordController.text, apiDomainController.text);
            }
//          _navigateHome(context);
          },
        ));
  }

  void _forgotPasswordPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (BuildContext context) {
        return Scaffold(
          body: AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.light,
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Stack(
                children: <Widget>[
                  Container(
                    height: double.infinity,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        //Colors.white,
                        colors: [
                          Colors.white,
                          Colors.white,
                          Colors.white,
                          Colors.white,
                          //Color(0xFF73AEF5),
                          //Color(0xFF61A4F1),
                          //Color(0xFF478DE0),
                          //Color(0xFF398AE5),
                        ],
                        stops: [0.1, 0.4, 0.7, 0.9],
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Container(
                        padding:
                            EdgeInsets.only(top: 30.0, left: 5.0, right: 5.0),
                        alignment: Alignment.topCenter,
                        child: RotatedBox(
                          quarterTurns: 3,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: double.infinity,
                          child: Center(
                            child: SingleChildScrollView(
                              physics: AlwaysScrollableScrollPhysics(),
                              padding: EdgeInsets.symmetric(
                                horizontal: 20.0,
                                vertical: 40.0,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  SizedBox(height: 30.0),
                                  _buildForgotPassword(),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildForgotPassword() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Forgot your password?',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10.0),
        Text(
          "Confirm your user name and we'll send the instructions.",
          style: TextStyle(
            color: Colors.grey,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(
          height: 40.0,
        ),
        Container(
          alignment: Alignment.centerLeft,
          height: 60.0,
          child: TextField(
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(
                color: Colors.black,
                fontFamily: 'OpenSans',
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(5, 20, 5, 10),
                labelText: 'USER NAME',
                labelStyle: TextStyle(
                  color: Colors.blue,
                  height: 0.5,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              )),
        ),
        const SizedBox(
          height: 30.0,
        ),
        RaisedButton(
          padding: EdgeInsets.all(10),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Text(
                'SUBMIT',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(
                width: 240.0,
              ),
              Icon(
                Icons.arrow_forward,
                color: Colors.white,
              ),
            ],
          ),
          color: Colors.blue,
          onPressed: () {
            print("Send Password");
          },
        ),
      ],
    );
  }

  Widget _buildForgotPasswordTF() {
    return Container(
      alignment: Alignment.topLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          FlatButton(
            padding: EdgeInsets.all(0),
            child: Text(
              'FORGOT PASSWORD ?',
              style: TextStyle(color: Colors.blue, fontSize: 16),
            ),
            onPressed: () {
              debugPrint("pressed");
              _forgotPasswordPage(context);
            },
          ),
        ],
      ),
    );
  }

//  Widget _buildSignUPTF() {
//    return Center();
//  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isFullScreenLoading,
      opacity: FullScreenLoader.OPACITY,
      progressIndicator: FullScreenLoader.PROGRESS_INDICATOR,
      child: Scaffold(
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: <Widget>[
              Container(
                height: double.infinity,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    //Colors.white,
                    colors: [
                      Colors.white,
                      Colors.white,
                      Colors.white,
                      Colors.white,
                    ],
                    stops: [0.1, 0.4, 0.7, 0.9],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(top: 30.0, left: 5.0, right: 5.0),
                    alignment: Alignment.topCenter,
                    child: RotatedBox(
                      quarterTurns: 3,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: double.infinity,
                      child: Center(
                        child: SingleChildScrollView(
                          physics: AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.0,
                            vertical: 40.0,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
//                            Image.asset(
//                              'images/pocket_1024.png',
//                              color: Colors.lightBlueAccent,
//                              width: 150,
//                              height: 150,
//                            ),
                              SizedBox(height: 30.0),
                              _buildUserNameTF(),
                              SizedBox(
                                height: 30.0,
                              ),
                              _buildPasswordTF(),
                              SizedBox(
                                height: 30.0,
                              ),
                              _buildApiDomainTF(),
                              _buildLoginBtn(),
//                              _buildForgotPasswordTF(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

//  void _navigateHome(BuildContext context) {
//    Navigator.pop(context);
//    Navigator.of(context).push(MaterialPageRoute(builder: (context) => SecondRoute()));
//    Navigator.push(
//      context,
//      MaterialPageRoute(builder: (context) => Profile()),
//    );
//    Navigator.of(context).push(
//      MaterialPageRoute<void>(builder: (BuildContext context) {
//        return Scaffold(
//          body: Profile()
//        );
//      })
//    );
//  }
}
