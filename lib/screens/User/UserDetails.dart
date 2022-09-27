import 'package:flutter/material.dart';
import 'package:moblesales/helpers/index.dart';
import 'package:moblesales/models/index.dart';

class UserDetails extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return (MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'User Details',
      home: UserDetailsPage(
          userData: ModalRoute.of(context).settings.arguments,
          parentBuildContext: context),
    ));
  }
}

class UserDetailsPage extends StatefulWidget {
  final User userData;
  final BuildContext parentBuildContext;

  UserDetailsPage(
      {Key key, @required this.userData, @required this.parentBuildContext})
      : super(key: key);
  @override
  _UserDetailsPageState createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage>
    with TickerProviderStateMixin {
  User userData;
  bool isInitialState = false;

  ///Holds loader hide/show state
  EdgeInsets userDetailsPadding = EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 8.0);

  @override
  void initState() {
    super.initState();
    userData = User();
    isInitialState = true;
  }

  @override
  void dispose() {
    super.dispose();
  }

  ///It checks if the text Content needed to display is valid or not
  bool isValidText(content) {
    if (content != null && content != '') {
      return true;
    } else {
      return false;
    }
  }

  String _getUserAddress() {
    try {
      String areCode =
          '${isValidText(userData.UserCode) ? userData.UserCode + ', ' : ''}';
      String city = '${isValidText(userData.City) ? userData.City + ', ' : ''}';
      String state =
          '${isValidText(userData.State) ? userData.State + ', ' : ''}';
      String country =
          '${isValidText(userData.Country) ? userData.Country + ', ' : ''}';
      return '${areCode + city + state + country}';
    } catch (e) {
      print('Address Not found error ');
      print(e);
      return '';
    }
  }

  Widget _getUserDetailsWidget(keyText, keyValue) {
    return Padding(
      padding: userDetailsPadding,
      child: Row(
        children: <Widget>[
          Expanded(
//            flex: 1,
            child: Text(
              '$keyText',
              style: TextStyle(color: AppColors.grey, fontSize: 15),
            ),
          ),
          Expanded(
//            flex: 2,
            child: Text(
              '$keyValue',
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

  @override
  Widget build(BuildContext context) {
    if (isInitialState) {
      setState(() {
        userData = widget.userData;
        isInitialState = false;
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("User Details"),
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(widget.parentBuildContext);
            }),
      ),
      body: Container(
        padding: EdgeInsets.all(15.0),
        child: Column(
          children: <Widget>[
            Card(
              elevation: 0.0,
              child: Padding(
                padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
//                    _getUserDetailsWidget('User Code:', userData.UserCode),
//                    _getUserDetailsWidget('User Name:', userData.Name),
//                    _getUserDetailsWidget('Company:', userData.Company),
//                    _getUserDetailsWidget('Phone Number:', userData.PhoneNo),
//                    _getUserDetailsWidget('Email:', userData.Email),
//                    _getUserDetailsWidget('Address: ', _getUserAddress()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
