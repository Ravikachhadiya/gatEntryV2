import 'dart:math';

import '../providers/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum Category {
  DeliveryBoy,
  Relatives,
  MilkMan,
  Servant,
  Colleague,
  Friend,
  Other,
}

enum Status {
  Pending,
  Cancelled,
  Accepted,
}

class PersonEntry {
  final String id;
  final String name;
  final String buildingId;
  final String societyId;
  final String houseId;
  final String userId;
  final DateTime dateTime;
  final TimeOfDay time;
  final Category category;
  final int code;
  final Status status;

  PersonEntry({
    @required this.id,
    @required this.name,
    @required this.buildingId,
    @required this.societyId,
    @required this.houseId,
    @required this.userId,
    @required this.dateTime,
    @required this.time,
    @required this.category,
    this.code,
    @required this.status,
  });
}

class PersonsEntries with ChangeNotifier {
  List<PersonEntry> _personEntriesToday = [];

  List<PersonEntry> _personEntries = [];

  void todayEntryList() {
    for (int i = 0; i < _personEntries.length; i++) {
      String dateUser = new DateFormat("yyyy-MM-dd")
              .format(_personEntries[i].dateTime)
              .toString() +
          " 00:00:00.000";
      DateTime dateTime = DateTime.parse(dateUser);
      String dateToday =
          new DateFormat("yyyy-MM-dd").format(DateTime.now()).toString() +
              " 00:00:00.000";
      DateTime todayDate = DateTime.parse(dateToday);
      if (!dateTime.isBefore(todayDate)) {
        _personEntriesToday.add(_personEntries[i]);
      }
    }
    //print(_personEntriesToday);
  }

  List<PersonEntry> get personEntries {
    return [..._personEntries];
  }

  List<PersonEntry> get personEntriesToday {
    _personEntriesToday = [];
    todayEntryList();
    return [..._personEntriesToday];
  }

  // PersonEntry findById(String id) {
  //   return _personEntries.firstWhere((perEntry) {
  //     return perEntry.id == id;
  //   });
  // }

  // PersonEntry findByIdAndDate(String id) {
  //   return _personEntries.firstWhere((perEntry) {
  //     String dateUser =
  //         new DateFormat("yyyy-MM-dd").format(perEntry.dateTime).toString() +
  //             "00:00:00.000";
  //     DateTime dateTime = DateTime.parse(dateUser);
  //     String dateToday =
  //         new DateFormat("yyyy-MM-dd").format(DateTime.now()).toString() +
  //             "00:00:00.000";
  //     DateTime todayDate = DateTime.parse(dateToday);

  //     return perEntry.id == id && !dateTime.isBefore(todayDate);
  //   });
  // }

  int entryCodeGenerator() {
    return (99999 + Random().nextInt(999999 - 100000)).toInt();
  }

  Future<bool> entryCodeValidater(String code, String societyId) async {
    print("Result...1");
    CollectionReference collectionReference =
        Firestore.instance.collection('society');

    bool result;
    await collectionReference
        .document(societyId)
        .collection('entryCode')
        .document(code)
        .get()
        .then((value) {
      result = (value.data != null);
    });

    print("Result : " + result.toString());
    return result;
  }

  Future<void> addPersonEntry(PersonEntry personEntry) async {
    int entryCode = 000000;
    if (personEntry.status != Status.Accepted) {
      while (true) {
        entryCode = entryCodeGenerator();
        print("Entry Code : " + entryCode.toString());
        CollectionReference collectionReference =
            Firestore.instance.collection('society');

        final entryCodeSnapshot = await collectionReference
            .document(personEntry.societyId)
            .collection('entryCode')
            .document(entryCode.toString())
            .get();

        if (entryCodeSnapshot.data.toString() == null || entryCode == 000000) {
          print(
              "------------------------------- Hello ------------------------------");
          print("entryCode Data =>: " + entryCodeSnapshot.data.toString());
          continue;
        }
        break;
      }
    }
    Map<String, dynamic> entryData = {
      "buildingId": personEntry.buildingId,
      "houseNumberId": personEntry.houseId,
      "societyId": personEntry.societyId,
      "userId": personEntry.userId,
      "name": personEntry.name,
      "code": entryCode,
      "date": personEntry.dateTime,
      "time": [personEntry.time.hour, personEntry.time.minute],
      "category": personEntry.category.index,
      "status": personEntry.status.index,
    };

    print("33333333333333333333333333333333333333333");
    CollectionReference collectionReference =
        Firestore.instance.collection("society");

    print("societyId 1 : " + personEntry.societyId.toString());
    print("societyId : " +
        personEntry.time.hour.toString() +
        " : " +
        personEntry.time.minute.toString());
    collectionReference
        .document(personEntry.societyId)
        .collection("entry")
        .add(entryData);
        
    Map<String, dynamic> entryCodeData = {
      "buildingId": personEntry.buildingId,
      "houseNumberId": personEntry.houseId,
      "userId": personEntry.userId,
      "date": personEntry.dateTime,
      "time": [personEntry.time.hour, personEntry.time.minute],
    };

    collectionReference
        .document(personEntry.societyId)
        .collection('entryCode')
        .document(entryCode.toString())
        .setData(entryCodeData);

    notifyListeners();
  }

  void updatePersonEntryStatus(int entryCode, String socId) {
    CollectionReference collectionReference =
        Firestore.instance.collection("society");

    collectionReference
        .document(socId)
        .collection("entry")
        .where("code", isEqualTo: entryCode)
        .where("status", isEqualTo: 0)
        .getDocuments()
        .then((value) {
      print("Doc : " + value.documents[0].documentID.toString());
      Firestore.instance
          .collection("society")
          .document(socId)
          .collection("entry")
          .document(value.documents[0].documentID)
          .updateData({"status": Status.Accepted.index});
    });
  }

  Future<void> fetchPersonEntry(User user) async {
    print("soc : " + user.societyId.toString());
    List<PersonEntry> personEntryList = [];
    await Firestore.instance
        .collection('society')
        .document(user.societyId)
        .collection("entry")
        .where("userId", isEqualTo: user.id)
        .getDocuments()
        .then((personEntrySnapshot) {
      if (personEntrySnapshot == null) {
        print(
            "-------------------------------------DATA IS NULL-------------------------------");
        return null;
      }
      for (int i = 0; i < personEntrySnapshot.documents.length; i++) {
        personEntryList.add(PersonEntry(
            id: personEntrySnapshot.documents[i].documentID,
            name: personEntrySnapshot.documents[i]['name'],
            buildingId: personEntrySnapshot.documents[i]['buildingId'],
            societyId: personEntrySnapshot.documents[i]['societyId'],
            code: personEntrySnapshot.documents[i]['code'],
            houseId: personEntrySnapshot.documents[i]['houseNumberId'],
            userId: personEntrySnapshot.documents[i]['userId'],
            dateTime: (personEntrySnapshot.documents[i]['date'] as Timestamp)
                .toDate(),
            time: TimeOfDay(
                hour: personEntrySnapshot.documents[i]['time'][0],
                minute: personEntrySnapshot.documents[i]['time'][1]),
            category:
                Category.values[personEntrySnapshot.documents[i]['category']],
            status: Status.values[personEntrySnapshot.documents[i]['status']]));
      }
      _personEntries = personEntryList;

      //print("Person Entry Data : " + personEntrySnapshot.documents.toString());

      notifyListeners();
      return personEntrySnapshot;
    });
  }

  void updatePersonEntry(PersonEntry personEntry) {
    print("----------------------- 11111111111111");
    // _personEntries.insert(0, personEntry);
    print("----------------------- 222222222222222");
    Map<String, dynamic> entryData = {
      "buildingId": personEntry.buildingId,
      "houseNumberId": personEntry.houseId,
      "societyId": personEntry.societyId,
      "userId": personEntry.userId,
      "name": personEntry.name,
      "code": personEntry.code,
      "date": personEntry.dateTime,
      "time": [personEntry.time.hour, personEntry.time.minute],
      "category": personEntry.category.index,
      "status": personEntry.status.index,
    };

    print("----------------------- 333333333333333");
    CollectionReference collectionReference =
        Firestore.instance.collection("society");

    collectionReference
        .document(personEntry.societyId)
        .collection("entry")
        .document(personEntry.id)
        .setData(entryData);
    //print("check : " + check.toString());

    notifyListeners();
  }

  void deletePersonEntry(PersonEntry personEntry) {
    print("delete");
    CollectionReference collectionReference =
        Firestore.instance.collection('society');

    collectionReference
        .document(personEntry.societyId)
        .collection('entry')
        .document(personEntry.id)
        .delete();
    notifyListeners();
  }

  Stream<QuerySnapshot> entryData(User userInfo) {
    Stream<QuerySnapshot> entryDt = Firestore.instance
        .collection('society')
        .document(userInfo.societyId)
        .collection("entry")
        .orderBy("date", descending: true)
        .where("houseNumberId", isEqualTo: userInfo.houseNumberId)
        .snapshots();

    return entryDt;
  }
}
