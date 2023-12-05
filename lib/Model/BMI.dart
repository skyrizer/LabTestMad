import 'package:flutter/material.dart';

import '../Controller/sqlite_db.dart';

class BMI {
  static const String SQLiteTable = "bmi";
  int? id;
  String username;
  double height;
  double weight;
  String gender;
  String bmi_status;

  BMI(
      this.username,
      this.height,
      this.weight,
      this.gender,
      this.bmi_status,
      );

  Map<String, dynamic> toJson() =>
      {
        'username': username,
        'height': height,
        'weight': weight,
        'gender': gender,
        'bmi_status': bmi_status,
        'id': id,
      };

  Future<bool> save() async {
    // Save to local SQLite
    if (await SQLiteDB().insert(SQLiteTable, toJson()) != 0){
      return true;
    }
    return false;
  }

  Future<bool> fetchLastRow() async {
    // Save to local SQLite
    if (await SQLiteDB().fetchLastRow(SQLiteTable) != 0){
      return true;
    }
    return false;
  }

}
