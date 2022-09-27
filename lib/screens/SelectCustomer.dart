import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:moblesales/helpers/index.dart';
import 'package:moblesales/models/index.dart';
import 'package:moblesales/screens/index.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'CustomerProfiles/CustomerProfiles.dart';
import 'MainScreen.dart';
import 'Quotes/SearchProduct.dart';

class SelectCustomer extends StatelessWidget {
  // This widget is the root of your application.
  final String pageNameToNavigate;
  final bool isFromQuoteScreen;

  SelectCustomer({
    Key key,
    @required this.pageNameToNavigate,
    this.isFromQuoteScreen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Select Customer",
      home: SelectCustomerPage(
        parentBuildContext: context,
        pageNameToNavigate: pageNameToNavigate,
        isFromQuoteScreen: isFromQuoteScreen,
      ),
    );
  }
}

class SelectCustomerPage extends StatefulWidget {
  final BuildContext parentBuildContext;
  final String pageNameToNavigate;
  final bool isFromQuoteScreen;

  SelectCustomerPage(
      {Key key,
      @required this.parentBuildContext,
      @required this.pageNameToNavigate,
      this.isFromQuoteScreen})
      : super(key: key);

  @override
  _SelectCustomerPageState createState() => _SelectCustomerPageState();
}

class _SelectCustomerPageState extends State<SelectCustomerPage> {
  ///USED TO HANDLE THE FULLSCREEN_LOADER JUST SET THE STATE TO THE TRUE TO START
  bool isFullScreenLoading;

  ///HOLDS TEXT_FIELD_CONTROLLER
  final TextEditingController searchCompanyNumberController =
      new TextEditingController();

  ///HOLDS TEXT_FIELD_CONTROLLER
  final TextEditingController searchCompanyNameController =
      new TextEditingController();

  ///HOLDS TEXT_FIELD_CONTROLLER
  final TextEditingController searchCompanyCityController =
      new TextEditingController();

  ///HOLDS TEXT_FIELD_CONTROLLER
  final TextEditingController searchCompanyZipController =
      new TextEditingController();

  ///HOLDS TEXT_FIELD_CONTROLLER
  final TextEditingController poNumberController = new TextEditingController();

  ///HOLDS TEXT_FIELD_CONTROLLER
  final TextEditingController notesController = new TextEditingController();

  ///HANDLES THE SEARCH_TEXT_FIELD STATE FOR THE ADVANCED SEARCH
  String searchFieldContentCompanyNumber;

  ///HANDLES THE SEARCH_TEXT_FIELD STATE FOR THE ADVANCED SEARCH
  String searchFieldContentCompanyName;

  ///HANDLES THE SEARCH_TEXT_FIELD STATE FOR THE ADVANCED SEARCH
  String searchFieldContentCompanyCity;

  ///HANDLES THE SEARCH_TEXT_FIELD STATE FOR THE ADVANCED SEARCH
  String searchFieldContentCompanyZip;

  ///IT HOLDS THE SELECTED COMPANY/CUSTOMER FOR THE ADVANCED SEARCH
  Company _selectedCompany;

  ///IT HOLDS ALL THE COMMON REUSABLE WIDGETS WHICH CAN BE USED THROUGH OUT PROJECT
  CommonWidgets _commonWidgets;

  ///IT HOLDS THE BILLING ADDRESS LIST FOR SHOWING DROPDOWN
  List<String> addressBillingList;

  ///IT HOLDS THE SELECTED BILLING ADDRESS
  String _selectedBillingAddress;

  ///IT HOLDS THE SHIPPING ADDRESS LIST FOR SHOWING DROPDOWN
  Map<String, dynamic> addressShippingList;
  // List<String> addressShippingList;

  ///IT HOLDS THE SELECTED SHIPPING ADDRESS
  String _selectedShippingAddress;

  ///It closes the CompanySearch Dialog On CLose Btn click
  void closeSearchDialog() {
    print('closeSearchDialog called of the Invoices page');
  }

  void handleCustomerSelectedSearch(Company selectedCompany) {
    print('Inside handleCustomerSelectedSearch fn of Invoice Screen');
    print('customer number: ${selectedCompany.CustomerNo}');
    print('customer address length: ${selectedCompany.addresses.length}');
    setState(() {
      _selectedCompany = selectedCompany;
      searchCompanyNumberController.text = selectedCompany.CustomerNo;
      searchFieldContentCompanyNumber = selectedCompany.CustomerNo;
      searchCompanyNameController.text = selectedCompany.Name;
      searchFieldContentCompanyName = selectedCompany.Name;
      addressBillingList = List<String>();
      if (selectedCompany.addresses.isNotEmpty) {
        // check for billing
        var addressBilling = List<Address>();
        var addressShipping = List<Address>();
        for (var i = 0; i < selectedCompany.addresses.length; i++) {
          if (!selectedCompany.addresses[i].IsShipping) {
            addressBilling.add(selectedCompany.addresses[i]);
          } else {
            addressShipping.add(selectedCompany.addresses[i]);
          }
        }
        if (addressBilling.isEmpty) {
          addressBilling.add(addressShipping[0]);
        }
        if (addressShipping.isEmpty) {
          addressShipping.add(addressBilling[0]);
        }
        addressBillingList = buildBillingAddressDropdownList(addressBilling);
        addressShippingList = buildShippingAddressDropdownList(addressShipping);
      } else {
        addressBillingList = buildBillingAddressDropdownList(List<Address>());
        addressShippingList = buildShippingAddressDropdownList(List<Address>());
      }
      _selectedBillingAddress = addressBillingList[0];
      _selectedShippingAddress = addressShippingList.values.first;
      //Sets Shipping Address Value in the Company
      _selectedCompany.DefaultShippAdd = _selectedShippingAddress;
    });
  }

  ///It resets the search Data
  void clearSelectedCompany() {
    setState(() {
      _selectedCompany = null;
    });
//    loadNewSearchData();
  }

  ///It Shows the customerSearch Dialog for selecting the customer for getting specified Customer's data
  void showCompanyDialog(String searchString, CustomerSearch type) {
    print('inside showDialog');
//    if (searchString != null && searchString
//        .trim()
//        .length > 0) {
    print('inside showDialog valid');
    showDialog(
        useRootNavigator: true,
        barrierDismissible: false,
        context: context,
        builder: (context) => CustomerSearchDialogWithoutSearchField(
              handleCustomerSelectedSearch: this.handleCustomerSelectedSearch,
              closeSearchDialog: this.closeSearchDialog,
              forLookupType: true,
              searchString: searchString,
              type: type,
            ));
    // }
  }

  ///It handles the SearchTextField Search click changes and Loads the new data accordingly
  void handleTextFieldSearch({String searchText, CustomerSearch type}) {
    setState(() {
      switch (type) {
        case CustomerSearch.customerNumber:
          searchFieldContentCompanyNumber = searchText;
          break;
        case CustomerSearch.customerName:
          searchFieldContentCompanyName = searchText;
          break;
        case CustomerSearch.city:
          searchFieldContentCompanyCity = searchText;
          break;
        case CustomerSearch.zip:
          searchFieldContentCompanyZip = searchText;
          break;
      }
    });
    this.showCompanyDialog(searchText, type);
  }

  ///It handles the SearchTextField Cancel/Clear click changes and Loads the new data accordingly
  void clearTextFieldSearch() {
    setState(() {
      searchFieldContentCompanyNumber = '';
      searchFieldContentCompanyName = '';
      searchFieldContentCompanyCity = '';
      searchFieldContentCompanyZip = '';
      searchCompanyNumberController.text = "";
      searchCompanyNameController.text = "";
      searchCompanyCityController.text = "";
      searchCompanyZipController.text = "";
      _selectedCompany = null;
      addressBillingList = buildBillingAddressDropdownList(List<Address>());
      _selectedBillingAddress = addressBillingList[0];
      addressShippingList = buildShippingAddressDropdownList(List<Address>());
      _selectedShippingAddress = addressShippingList[0];
    });
  }

  List<String> buildBillingAddressDropdownList(List<Address> addressList) {
    print("inside buildBillingAddressDropdownList");
    List<String> listItems = List<String>();
    // Map<String, dynamic> listItems = Map<String, dynamic>();
    String city = "";
    bool isCityInitialized = false;
    String zip = "";
    bool isZipInitialized = false;
    if (addressList.isNotEmpty) {
      print("billing address length more 0");
      for (var i = 0; i < addressList.length; i++) {
        String addressString = "";
        if (addressList[i].Address1 != null &&
            addressList[i].Address1.isNotEmpty) {
          addressString += addressList[i].Address1;
        }
        if (addressList[i].City != null && addressList[i].City.isNotEmpty) {
          addressString += ' ' + addressList[i].City;
          if (!isCityInitialized) {
            city = addressList[i].City;
            isCityInitialized = true;
          }
        }
        if (addressList[i].PostCode != null &&
            addressList[i].PostCode.isNotEmpty) {
          addressString += ' ' + addressList[i].PostCode;
          if (!isZipInitialized) {
            zip = addressList[i].PostCode;
            isZipInitialized = true;
          }
        }
        if (addressList[i].State != null && addressList[i].State.isNotEmpty) {
          addressString += ' ' + addressList[i].State;
        }
        if (addressList[i].Country != null &&
            addressList[i].Country.isNotEmpty) {
          addressString += ' ' + addressList[i].Country;
        }
        if (addressString.isNotEmpty) {
          listItems.add(addressString);
          // listItems.addAll({addressString: addressList[i].Code});
        }
      }
    } else {
      print("billing address length less 0");
      listItems.add("Select Address");
      // listItems.addAll({"Select Address": ""});
    }
    searchCompanyCityController.text = city;
    searchCompanyZipController.text = zip;
    searchFieldContentCompanyCity = city;
    searchFieldContentCompanyZip = zip;
    return listItems;
  }

  ///It returns the search bar Widget for the Billing Address list screen
  Widget _buildBillingAddressDropdown() {
    List<DropdownMenuItem<String>> dropDownMenuItems = List();
    addressBillingList.forEach((element) {
      dropDownMenuItems.add(
        DropdownMenuItem(
          child: Text(
            '$element',
            style: TextStyle(color: AppColors.black, fontSize: 15.0),
          ),
          value: element,
        ),
      );
    });

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 0.0),
        child: Card(
          elevation: 0.0,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  'Select Billing Address',
                  style: TextStyle(color: AppColors.grey, fontSize: 15.0),
                ),
                SizedBox(
                  height: 10.0,
                ),
                DropdownButtonHideUnderline(
                  child: DropdownButton(
                    value: _selectedBillingAddress,
                    items: dropDownMenuItems,
                    onChanged: (selectedItem) {
                      if (selectedItem != _selectedBillingAddress) {
                        print('New billing address State Selected ');
                        handleBillingAddressChange(selectedItem);
                      } else {
                        print(
                            'Already Selected Billing Address State Selected ');
                      }
                    },
                    isExpanded: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ///It handles the Billing Address changes and Loads the new data accordingly
  void handleBillingAddressChange(String selectedAddress) {
    setState(() {
      _selectedBillingAddress = selectedAddress;
    });
//    loadNewSearchData();
  }

  Map<String, dynamic> buildShippingAddressDropdownList(
      List<Address> addressList) {
    print("inside buildShippingAddressDropdownList");
    // List<String> listItems = List<String>();
    Map<String, dynamic> listItems = Map<String, dynamic>();
    String city = "";
    bool isCityInitialized = false;
    String zip = "";
    bool isZipInitialized = false;
    if (addressList.isNotEmpty) {
      print("shipping address length more 0");
      for (var i = 0; i < addressList.length; i++) {
        String addressString = "";
        if (addressList[i].Address1 != null &&
            addressList[i].Address1.isNotEmpty) {
          addressString += ' ' + addressList[i].Address1;
        }
        if (addressList[i].City != null && addressList[i].City.isNotEmpty) {
          addressString += ' ' + addressList[i].City;
          if (!isCityInitialized) {
            city = addressList[i].City;
            isCityInitialized = true;
          }
        }
        if (addressList[i].PostCode != null &&
            addressList[i].PostCode.isNotEmpty) {
          addressString += ' ' + addressList[i].PostCode;
          if (!isZipInitialized) {
            zip = addressList[i].PostCode;
            isZipInitialized = true;
          }
        }
        if (addressList[i].State != null && addressList[i].State.isNotEmpty) {
          addressString += ' ' + addressList[i].State;
        }
        if (addressList[i].Country != null &&
            addressList[i].Country.isNotEmpty) {
          addressString += ' ' + addressList[i].Country;
        }
        if (addressString.isNotEmpty) {
          // listItems.add(addressString);
          listItems.addAll({addressString: addressList[i].Code});
        }
      }
    } else {
      print("shipping address length less 0");
      // listItems.add("Select Address");
      listItems.addAll({"Select Address": ""});
    }
    if (searchCompanyCityController.text.isEmpty) {
      searchCompanyCityController.text = city;
      searchFieldContentCompanyCity = city;
    }
    if (searchCompanyZipController.text.isEmpty) {
      searchCompanyZipController.text = zip;
      searchFieldContentCompanyZip = zip;
    }
    return listItems;
  }

  ///It returns the search bar Widget for the Billing Address list screen
  Widget _buildShippingAddressDropdown() {
    List<DropdownMenuItem<String>> dropDownMenuItems = List();
    addressShippingList.entries.forEach((element) {
      dropDownMenuItems.add(
        DropdownMenuItem(
          child: Text(
            '${element.key}',
            style: TextStyle(color: AppColors.black, fontSize: 15.0),
          ),
          value: element.value,
        ),
      );
    });

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 0.0),
        child: Card(
          elevation: 0.0,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  'Select Shipping Address',
                  style: TextStyle(color: AppColors.grey, fontSize: 15.0),
                ),
                SizedBox(
                  height: 10.0,
                ),
                DropdownButtonHideUnderline(
                  child: DropdownButton(
                    value: _selectedShippingAddress,
                    items: dropDownMenuItems,
                    onChanged: (selectedItem) {
                      if (selectedItem != _selectedShippingAddress) {
                        print('New shipping address State Selected ');
                        handleShippingAddressChange(selectedItem);
                      } else {
                        print('Already Selected Shipping State Selected ');
                      }
                    },
                    isExpanded: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ///It handles the Billing Address changes and Loads the new data accordingly
  void handleShippingAddressChange(String selectedAddress) {
    setState(() {
      _selectedShippingAddress = selectedAddress;
      _selectedCompany.DefaultShippAdd = selectedAddress;
    });
//    loadNewSearchData();
  }

  @override
  void initState() {
    isFullScreenLoading = false;
    searchFieldContentCompanyNumber = null;
    _selectedCompany = null;
    _commonWidgets = CommonWidgets();
    addressBillingList = buildBillingAddressDropdownList(List<Address>());
    _selectedBillingAddress = addressBillingList[0];
    addressShippingList = buildShippingAddressDropdownList(List<Address>());
    _selectedShippingAddress = addressShippingList[0];
  }

  void handleAyncPageNavigation() async {
    var result =
        await Navigator.of(widget.parentBuildContext).push(MaterialPageRoute(
            builder: (context) => SearchProduct(
                  selectedCompany: _selectedCompany,
                  PONumber: poNumberController.text,
                  Note: notesController.text,
                  isRedirectFromAddQuote: false,
                )));

    if (result != null) {
      //back to customer selection
      if (result == true) {
        Navigator.pop(widget.parentBuildContext, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isFullScreenLoading,
      opacity: FullScreenLoader.OPACITY,
      progressIndicator: FullScreenLoader.PROGRESS_INDICATOR,
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppBarTitles.SELECT_CUSTOMER),
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                if (widget.isFromQuoteScreen != null &&
                    widget.isFromQuoteScreen == true) {
                  Navigator.of(widget.parentBuildContext).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (BuildContext context) => MainScreen()),
                      (Route<dynamic> route) => false);
                } else {
                  Navigator.pop(widget.parentBuildContext);
                }
              }),
        ),
        body: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: ListView(
                  children: <Widget>[
                    SearchTextField(
                      searchFieldContent: searchFieldContentCompanyNumber,
                      clearTextFieldSearch: clearTextFieldSearch,
                      handleTextFieldSearch: (value) => handleTextFieldSearch(
                          searchText: value,
                          type: CustomerSearch.customerNumber),
                      placeHolder: "Customer Number",
                      searchTFController: searchCompanyNumberController,
                    ),
                    SearchTextField(
                      searchFieldContent: searchFieldContentCompanyName,
                      clearTextFieldSearch: clearTextFieldSearch,
                      handleTextFieldSearch: (value) => handleTextFieldSearch(
                          searchText: value, type: CustomerSearch.customerName),
                      placeHolder: "Customer Name",
                      searchTFController: searchCompanyNameController,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[_buildBillingAddressDropdown()],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[_buildShippingAddressDropdown()],
                    ),
                    SearchTextField(
                      searchFieldContent: searchFieldContentCompanyCity,
                      clearTextFieldSearch: clearTextFieldSearch,
                      handleTextFieldSearch: (value) => handleTextFieldSearch(
                          searchText: value, type: CustomerSearch.city),
                      placeHolder: "City",
                      searchTFController: searchCompanyCityController,
                    ),
                    SearchTextField(
                      searchFieldContent: searchFieldContentCompanyZip,
                      clearTextFieldSearch: clearTextFieldSearch,
                      handleTextFieldSearch: (value) => handleTextFieldSearch(
                          searchText: value, type: CustomerSearch.zip),
                      placeHolder: "Zip",
                      searchTFController: searchCompanyZipController,
                    ),
                    Visibility(
                      visible: widget.pageNameToNavigate == 'Quotes',
                      child: Container(
                        child: Padding(
                          padding:
                              const EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 0.0),
                          child: Card(
                            elevation: 0.0,
                            child: Padding(
                              padding: const EdgeInsets.all(0.0),
                              child: TextField(
                                controller: poNumberController,
                                maxLength:
                                    AddQuoteDefaults.PO_NUMBER_FIELD_MAX_LENGTH,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: 'OpenSans',
                                ),
                                decoration: InputDecoration(
                                  hintText: 'PO Number',
                                  hintStyle: TextStyle(
                                    color: AppColors.grey,
                                    fontFamily: 'OpenSans',
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.all(20.0),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: widget.pageNameToNavigate == 'Quotes',
                      child: Container(
                        child: Padding(
                          padding:
                              const EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 0.0),
                          child: Card(
                            elevation: 0.0,
                            child: Padding(
                              padding: const EdgeInsets.all(0.0),
                              child: TextField(
                                minLines: 2,
                                maxLines: 5,
                                controller: notesController,
                                maxLength:
                                    AddQuoteDefaults.NOTES_FIELD_MAX_LENGTH,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: 'OpenSans',
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Notes',
                                  hintStyle: TextStyle(
                                    color: AppColors.grey,
                                    fontFamily: 'OpenSans',
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.all(20.0),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Expanded(
                      child: RaisedButton(
                        padding: const EdgeInsets.fromLTRB(0.0, 0.0, 5.0, 0.0),
                        color: AppColors.blue,
                        child: Text(
                          'Home',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                          ),
                        ),
                        onPressed: () {
                          if (widget.isFromQuoteScreen != null &&
                              widget.isFromQuoteScreen == true) {
                            Navigator.of(widget.parentBuildContext)
                                .pushAndRemoveUntil(
                                    MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            MainScreen()),
                                    (Route<dynamic> route) => false);
                          } else {
                            Navigator.pop(widget.parentBuildContext);
                          }
                        },
                      ),
                    ),
                    SizedBox(
                      width: 20.0,
                    ),
                    Expanded(
                      child: RaisedButton(
                        padding: const EdgeInsets.fromLTRB(0.0, 0.0, 5.0, 0.0),
                        color: AppColors.blue,
                        child: Text(
                          widget.pageNameToNavigate == "Quotes"
                              ? "Add Product"
                              : "Confirm",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                          ),
                        ),
                        onPressed: () {
                          if (widget.pageNameToNavigate == "Quotes") {
                            //open product search screen and pass _selectedCompany
                            if (_selectedCompany != null) {
                              handleAyncPageNavigation();
                            } else {
                              _commonWidgets.showAlertMsg(
                                  alertMsg: 'Select customer first',
                                  context: context,
                                  MessageType: AlertMessageType.INFO);

//                              _commonWidgets.showFlutterToast(
//                                  toastMsg: 'Select customer first');
                            }
                          } else if (widget.pageNameToNavigate == "Customers") {
                            // Codtomer profile page
                            if (_selectedCompany != null) {
                              Navigator.of(widget.parentBuildContext)
                                  .push(MaterialPageRoute(
                                      builder: (context) => CustomerProfiles(
                                            company: _selectedCompany,
                                          )));
                            } else {
                              _commonWidgets.showFlutterToast(
                                  toastMsg: 'Select customer first');
                            }
                          } else if (widget.pageNameToNavigate ==
                              "Existing Sales Orders") {
                            if (_selectedCompany != null) {
                              Navigator.of(widget.parentBuildContext)
                                  .push(MaterialPageRoute(
                                      builder: (context) => SalesOrder(
                                            company: _selectedCompany,
                                          )));
                            } else {
                              _commonWidgets.showFlutterToast(
                                  toastMsg: 'Select customer first');
                            }
                          } else if (widget.pageNameToNavigate == "Invoices") {
                            if (_selectedCompany != null) {
                              Navigator.of(widget.parentBuildContext)
                                  .push(MaterialPageRoute(
                                      builder: (context) => Invoice(
                                            company: _selectedCompany,
                                          )));
                            } else {
                              _commonWidgets.showFlutterToast(
                                  toastMsg: 'Select customer first');
                            }
                          } else if (widget.pageNameToNavigate ==
                              "Customers Statements") {
                            Navigator.of(widget.parentBuildContext)
                                .push(MaterialPageRoute(
                                    builder: (context) => CustomerStatements(
                                          company: _selectedCompany,
                                          reportType: 1,
                                        )));
                          } else if (widget.pageNameToNavigate == "A/R") {
                            Navigator.of(widget.parentBuildContext)
                                .push(MaterialPageRoute(
                                    builder: (context) => CustomerStatements(
                                          company: _selectedCompany,
                                          reportType: 2,
                                        )));
                            //
                          }
                        },
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
