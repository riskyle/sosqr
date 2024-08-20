// navigation_utils.dart
import 'package:flutter/material.dart';
import 'package:untitled1/screens/logs/logsTab.dart';
import 'package:untitled1/screens/account/accountTab.dart';
import 'package:untitled1/screens/admin_dashboard/adminDashboard.dart';
import 'package:untitled1/screens/other/second_screen.dart';

class NavigationUtils {
  static void navigateToScreen(BuildContext context, int index, {
    required String username,
    required String firstName,
    required String lastName,
    required String pictureURL,
    required String accessKey,
    required String userDocID,
    required String password,
    required String department,
    required String role,
  }) {
    Widget screen;
    if (accessKey == 'admin') {
      switch (index) {
        case 0:
          screen = AdminDashboard(
            username: username,
            firstName: firstName,
            lastName: lastName,
            pictureURL: pictureURL,
            accessKey: accessKey,
            userDocID: userDocID,
            password: password,
            department: department,
            role: role,
          );
          break;
        case 1:
          screen = LogsTab(
            username: username,
            firstName: firstName,
            lastName: lastName,
            pictureURL: pictureURL,
            accessKey: accessKey,
            userDocID: userDocID,
            password: password,
            department: department,
            role: role,
          );
          break;
        case 2:
          screen = AccountTab(
            username: username,
            firstName: firstName,
            lastName: lastName,
            pictureURL: pictureURL,
            accessKey: accessKey,
            userDocID: userDocID,
            password: password,
            department: department,
            role: role,
          );
          break;
        default:
          return;
      }
    } else {
      switch (index) {
        case 0:
          screen = SecondScreen(
            username: username,
            firstName: firstName,
            lastName: lastName,
            pictureURL: pictureURL,
            accessKey: accessKey,
            userDocID: userDocID,
            password: password,
            department: department,
            role: role,
          );
          break;
        case 1:
          screen = LogsTab(
            username: username,
            firstName: firstName,
            lastName: lastName,
            pictureURL: pictureURL,
            accessKey: accessKey,
            userDocID: userDocID,
            password: password,
            department: department,
            role: role,
          );
          break;
        case 2:
          screen = AccountTab(
            username: username,
            firstName: firstName,
            lastName: lastName,
            pictureURL: pictureURL,
            accessKey: accessKey,
            userDocID: userDocID,
            password: password,
            department: department,
            role: role,
          );
          break;
        default:
          return;
      }
    }
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }
}
