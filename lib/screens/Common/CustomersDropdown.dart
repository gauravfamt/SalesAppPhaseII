import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:moblesales/helpers/index.dart';
import 'dart:convert';

import 'package:moblesales/models/index.dart';

class CustomerDropdown extends StatefulWidget {
  final Function(Company selectedCompany) handleCompanyChange;
  CustomerDropdown({
    this.handleCompanyChange,
  });
  @override
  _CustomerDropdownState createState() => _CustomerDropdownState();
}

class _CustomerDropdownState extends State<CustomerDropdown> {
  ///IT HOLDS ALL COMPANY_DROPDOWN_MENU_ITEMS FOR DROPDOWN
  List<DropdownMenuItem<Company>> dropDownMenuItems;

  ///IT HOLDS THE SELECTED COMPANY FROM THE DROPDOWN
  Company _selectedCompany;

  ///IT HOLDS ALL THE COMPANIES LIST
  List<Company> _companies;

  @override
  void initState() {
    super.initState();
    _selectedCompany = getDefaultCompany();
    dropDownMenuItems = List<DropdownMenuItem<Company>>();
    _companies = List<Company>();
    fetchCompanies();
  }

  @override
  void dispose() {
    super.dispose();
  }

  ///IT RETURNS THE DEFAULT COMPANY WITH TEXT SELECT CUSTOMER FOR THE DROPDOWN
  Company getDefaultCompany() {
//    return Company(Name: 'Select Customer ', CustomerNo: null);
    return Company();
  }

  ///IT FETCHES ALL THE COMPANIES LIST FOR THE DROPDOWN
  void fetchCompanies() async {
    try {
      var companyData = List<Company>();
      String url =
          '${await Session.getData(Session.apiDomain)}/${URLs.GET_COMPANIES}';
      print('$url');
      http.Client client = http.Client();
      final response = await client.get(url, headers: {
        "token": await Session.getData(Session.accessToken),
        "Username": await Session.getUserName()
      }).timeout(duration);
      print('fetchCompanies() response received ');

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        companyData =
            data.map<Company>((json) => Company.fromJson(json)).toList();
        List<DropdownMenuItem<Company>> _tempDropDownMenuItems =
            List<DropdownMenuItem<Company>>();
        companyData.forEach((element) {
          _tempDropDownMenuItems.add(
            DropdownMenuItem(
              child: Text(
                '${element.Name} ( ${element.CustomerNo} )',
                style: TextStyle(color: AppColors.black, fontSize: 15.0),
              ),
              value: element,
            ),
          );
        });
        setState(() {
          _companies.addAll(companyData);
          dropDownMenuItems.addAll(_tempDropDownMenuItems);
          _selectedCompany = companyData[0];
        });
      }
    } catch (e) {
      print('Error while fetching Companies list for the Dropdown');
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.0,
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            0.0, 10.0, 0.0, 0.0), //Padding on top of dropdown
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Customer',
              style: TextStyle(color: AppColors.blue, fontSize: 15.0),
            ),
            SizedBox(
              height: 10.0,
            ),
            DropdownButton(
              hint: Text('--Select Customer--'),
//              value: _selectedCompany,
              items: dropDownMenuItems,
              onChanged: (selectedItem) {
                print('Inisde Customer OnChange fn ');
                if (_selectedCompany == null &&
                    _selectedCompany.CustomerNo != null) {
                  setState(() {
                    _selectedCompany = selectedItem;
                  });
                  widget.handleCompanyChange(selectedItem);
                } else if (selectedItem.CustomerNo !=
                    _selectedCompany.CustomerNo) {
                  print('New Company Selected Selected ');
                  setState(() {
                    _selectedCompany = selectedItem;
                  });
                  widget.handleCompanyChange(selectedItem);
                } else {
                  print('Already Selected Company Selected ');
                }
              },
              isExpanded: true,
            ),
          ],
        ),
      ),
    );
  }
}
