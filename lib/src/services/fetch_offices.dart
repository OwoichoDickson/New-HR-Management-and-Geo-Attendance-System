import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:geo_attendance_system/src/models/office.dart';

class OfficeDatabase {
  final _databaseReference = FirebaseDatabase.instance.reference();
  static final OfficeDatabase _instance = OfficeDatabase._internal();

  factory OfficeDatabase() {
    return _instance;
  }

  OfficeDatabase._internal();

  Future<Office> getOfficeBasedOnUID(String uid) async {
    DataSnapshot dataSnapshot = await _databaseReference.child("users").once();
    final userInfo = dataSnapshot.value[uid];
    final office = userInfo["allotted_office"];

    dataSnapshot = await _databaseReference.child("location").once();
    final findOffice = dataSnapshot.value[office];
    final name = findOffice["name"];
    final latitude = findOffice["latitude"];
    final longitude = findOffice["longitude"];
    return Office(name: name, latitude: latitude, longitude: longitude);
  }

  Future<List<Office>> getOfficeList() async {
    DataSnapshot dataSnapshot = await _databaseReference.once();
    Completer<List<Office>> completer;
    final officeList = dataSnapshot.value["location"];
    List<Office> result = [];

    var officeMap = officeList;
    officeMap.forEach((key, map) {
      result.add(Office.fromJson(key, map.cast<String, dynamic>()));
    });

    return result;
  }
}