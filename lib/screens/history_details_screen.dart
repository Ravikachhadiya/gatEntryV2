import '../providers/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/person_entry.dart';
import '../widgets/history_widget.dart';

class HistoryDetailsScreen extends StatelessWidget {
  static const routeName = '/history';

  Stream<QuerySnapshot> _entryData(User userInfo) {
    return Firestore.instance
        .collection('society')
        .document(userInfo.societyId)
        .collection("entry")
        .orderBy("date", descending: true)
        .where("houseNumberId", isEqualTo: userInfo.houseNumberId)
        .snapshots();
  }

  Stream<QuerySnapshot> _entryDataSecurity(User userInfo) {
    return Firestore.instance
        .collection('society')
        .document(userInfo.societyId)
        .collection("entry")
        .orderBy("date", descending: true)
        .snapshots();
  }

  bool checkDate(DateTime entryDateTime) {
    String dateUser =
        new DateFormat("yyyy-MM-dd").format(entryDateTime).toString() +
            " 00:00:00.000";
    DateTime dateTime = DateTime.parse(dateUser);
    String dateToday =
        new DateFormat("yyyy-MM-dd").format(DateTime.now()).toString() +
            " 00:00:00.000";
    DateTime todayDate = DateTime.parse(dateToday);
    if (!dateTime.isBefore(todayDate)) {
      return false;
    }
    return true;
  }

  List<PersonEntry> buildPersonEntryList(var data, User userInfo) {
    List<PersonEntry> personEntryList = [];
    for (int i = 0; i < data.length; i++) {
      print("checkDate((data[i]['date'] as Timestamp).toDate()) : " +
          checkDate((data[i]['date'] as Timestamp).toDate()).toString() +
          (data[i]['date'] as Timestamp).toDate().toString());

      print("Data name : " + data[i]['name'].toString());

      if (checkDate((data[i]['date'] as Timestamp).toDate()) ||
          userInfo.userType == UserType.SecurityGuard) {
        personEntryList.add(PersonEntry(
          id: data[i].documentID,
          name: data[i]['name'],
          buildingId: data[i]['buildingId'],
          societyId: data[i]['societyId'],
          houseId: data[i]['houseNumberId'],
          userId: data[i]['userId'],
          code: data[i]['code'],
          dateTime: (data[i]['date'] as Timestamp).toDate(),
          time: TimeOfDay(hour: data[i]['time'][0], minute: data[i]['time'][1]),
          category: Category.values[data[i]['category']],
          status: Status.values[data[i]['status']],
        ));
      }
    }
    return personEntryList;
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<User>(context).fetchUserData();
    User userInfo = Provider.of<User>(context).userInfo;
    if (userInfo == null) {
      print("---------------------------------> 4");
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else if (userInfo.societyId.toString() == null) {
      print("---------------------------------> 3");
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    print("user Soc : " + userInfo.societyId.toString());
    print("user id : " + userInfo.id.toString());
    return Scaffold(
      body: StreamBuilder(
        stream: userInfo.userType == UserType.SecurityGuard
            ? _entryDataSecurity(userInfo)
            : _entryData(userInfo),
        builder: (ctx, snapshot) {
          //print("data : " + snapshot.data.documents.toString());
          // if (snapshot.connectionState == ConnectionState.waiting) {
          //   print("---------------------------------> 5");
          //   return Center(child: CircularProgressIndicator());
          // }
          if (snapshot.data == null) {
            print("---------------------------------> 2");
            return Center(
              child: Text("Empty History"),
            );
          }
          final data = snapshot.data.documents;
          print("Data length : " + data.length.toString());
          final personEntryList = buildPersonEntryList(data, userInfo);
          return (personEntryList.length != 0)
              ? ListView.builder(
                  itemCount: personEntryList.length,
                  itemBuilder: (ctx, i) {
                    print("name :  " + personEntryList[i].name);
                    return HistoryWidget(personEntryList[i]);
                  },
                  padding: EdgeInsets.only(bottom: 70),
                )
              : Center(
                  child: Text("Empty History"),
                );
        },
      ),
    );
  }
}
