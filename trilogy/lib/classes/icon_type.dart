import 'package:flutter/material.dart';

// This class identifies an icon based on the type of company.
class IconType {
  String type;
  IconType(this.type);

  IconData findIcon() {
    if (this.type == 'Business') {
      return Icons.business;
    } else if (this.type == 'Nonprofit') {
      return Icons.volunteer_activism;
    } else {
      return Icons.account_balance;
    }
  }
}
