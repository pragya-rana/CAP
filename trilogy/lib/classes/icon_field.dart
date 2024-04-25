import 'package:flutter/material.dart';

// This class identifies icons based on the field that the company specializes in.
class IconField {
  String field;
  IconField(this.field);

  IconData findIcon() {
    if (this.field == 'Information Technology') {
      return Icons.code;
    } else if (this.field == 'Healthcare') {
      return Icons.health_and_safety;
    } else if (this.field == 'Engineering') {
      return Icons.engineering;
    } else if (this.field == 'Agriculture') {
      return Icons.agriculture;
    } else if (this.field == 'Creative Arts') {
      return Icons.movie;
    } else if (this.field == 'Transportation') {
      return Icons.drive_eta;
    } else {
      return Icons.monetization_on;
    }
  }
}
