import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:moblesales/helpers/index.dart';

///IT RETURNS THE EXPANDED_WIDGET IT REQUIRES HEADER_TEXT_VALUE AND
///CHILD_WIDGET WHICH WILL BE DISPLAYED IN EXPANDED_PANEL
class ExpandedWidget extends StatelessWidget {
  final bool initialExpanded;
  final String headerValue;
  final Widget childWidget;
  ExpandedWidget({
    @required this.headerValue,
    @required this.childWidget,
    @required this.initialExpanded,
  });

  @override
  Widget build(BuildContext context) {
    return ExpandableNotifier(
      initialExpanded: initialExpanded,
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
                child: Container(child: childWidget),
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
}
