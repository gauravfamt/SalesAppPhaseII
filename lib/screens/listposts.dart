import 'package:flutter/material.dart';
import 'package:moblesales/models/index.dart';

class ListViewPosts extends StatelessWidget {
  final List<Company> companies;

  ListViewPosts({Key key, this.companies}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView.builder(
          itemCount: companies.length,
          padding: const EdgeInsets.all(15.0),
          itemBuilder: (context, position) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Expanded(
                  child: Container(
                    child: Text('${companies[position].Name}'),
                    alignment: Alignment.centerLeft,
                  ),
                ),
                Expanded(
                  child: Container(
                    child: Text('${companies[position].CustomerNo}'),
                    alignment: Alignment.centerLeft,
                  ),
                ),
//                Divider(height: 5.0),
//                ListTile(
//                  title: Text(
//                    '${companies[position].Name}',
//                    style: TextStyle(
//                      fontSize: 22.0,
//                      color: Colors.deepOrangeAccent,
//                    ),
//                  ),
//                  subtitle: Text(
//                    '${companies[position].CustomerNo}',
//                    style: new TextStyle(
//                      fontSize: 18.0,
//                      fontStyle: FontStyle.italic,
//                    ),
//                  ),
//                  onTap: () => _onTapItem(context, companies[position]),
//                ),
              ],
            );
          }),
    );
  }

  void _onTapItem(BuildContext context, Company company) {
    Scaffold.of(context).showSnackBar(new SnackBar(
        content: new Text(company.CustomerNo + ' - ' + company.Name)));
  }
}
