import 'dart:async';
import 'dart:wasm';

import '../providers/approval_request.dart';
import '../widgets/security_guard_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/person_entry.dart';
import '../screens/edit_person_entry_screen.dart';
import '../providers/user.dart';
import '../widgets/person_entry_widget.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home-screen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

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
      return true;
    }
    return false;
  }

  var _personEntryList;
  Future<void> buildPersonEntryList(var data) async {
    List<PersonEntry> personEntryList = [];
    for (int i = 0; i < data.length; i++) {
      if (checkDate((data[i]['date'] as Timestamp).toDate())) {
        personEntryList.add(PersonEntry(
          id: data[i].documentID,
          name: data[i]['name'],
          buildingId: data[i]['buildingId'],
          societyId: data[i]['societyId'],
          houseId: data[i]['houseNumberId'],
          code: data[i]['code'],
          userId: data[i]['userId'],
          dateTime: (data[i]['date'] as Timestamp).toDate(),
          time: TimeOfDay(hour: data[i]['time'][0], minute: data[i]['time'][1]),
          category: Category.values[data[i]['category']],
          status: Status.values[data[i]['status']],
        ));
      }
    }
    _personEntryList = personEntryList;
  }

  StreamController _personEntryController = new StreamController();

  loadPosts(BuildContext context, User userInfo) async {
    Stream<QuerySnapshot> snapshot =
        Provider.of<PersonsEntries>(context, listen: false).entryData(userInfo);
    _personEntryController.add(snapshot);
  }

  showSnack() {
    return scaffoldKey.currentState.showSnackBar(
      SnackBar(
        content: Text('New content loaded'),
      ),
    );
  }

  Future<Null> _handleRefresh(BuildContext context, User userInfo) async {
    Stream<QuerySnapshot> snapshot =
        Provider.of<PersonsEntries>(context, listen: false).entryData(userInfo);
    _personEntryController.add(snapshot);
    showSnack();
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<User>(context).fetchUserData();
    User userInfo = Provider.of<User>(context).userInfo;
    if (userInfo == null) {
      print("---------------------------------> 4");
      return Scaffold(
        key: scaffoldKey,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else if (userInfo.societyId.toString() == null) {
      print("---------------------------------> 3");
      return Scaffold(
        key: scaffoldKey,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    //loadPosts(context, userInfo);
    print("user Soc : " + userInfo.societyId.toString());
    print("user id : " + userInfo.id.toString());
    return (userInfo.userType == UserType.SecurityGuard)
        ? SecurityGuardWidget()
        : userInfo.approvalStatus == false
            ? Scaffold(
                key: scaffoldKey,
                body: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    children: [
                      Center(
                        child: Text(
                          "Your request was rejected by higer authority send request again if this was mistake and  ask to higher autority of your society accept your request",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      RaisedButton.icon(
                        onPressed: () {
                          if (userInfo.userType == UserType.Member) {
                            Provider.of<ApprovalRequest>(context, listen: false)
                                .addApprovalRequest(
                              ApprovalRequest(
                                id: '',
                                buildingId: userInfo.buildingId,
                                societyId: userInfo.societyId,
                                houseNumberId: userInfo.houseNumberId,
                                userId: userInfo.id,
                                userType: userInfo.userType,
                              ),
                              true,
                            );
                          } else {
                            Provider.of<ApprovalRequest>(context, listen: false)
                                .addApprovalRequest(
                              ApprovalRequest(
                                id: '',
                                buildingId: userInfo.buildingId,
                                societyId: userInfo.societyId,
                                houseNumberId: userInfo.houseNumberId,
                                userId: userInfo.id,
                                userType: userInfo.userType,
                              ),
                              false,
                            );
                          }
                        },
                        icon: Icon(Icons.send),
                        label: Text('Send Request'),
                      ),
                    ],
                  ),
                ),
              )
            : userInfo.approvalStatus != true
                ? Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Center(
                          child: Text(
                            "Please ask to higher autority of your society for accept your request",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  )
                : Scaffold(
                    key: scaffoldKey,
                    body: StreamBuilder(
                      stream:
                          Provider.of<PersonsEntries>(context, listen: false)
                              .entryData(userInfo),
                      builder: (ctx, snapshot) {
                        print("snapshot home : " + snapshot.data.toString());

                        //print("data : " + snapshot.data.documents.toString());
                        // if (snapshot.connectionState == ConnectionState.waiting) {
                        //   print("---------------------------------> 5");
                        //   return Center(child: CircularProgressIndicator());
                        // }
                        if (snapshot.data == null) {
                          print("---------------------------------> 2");
                          return Center(
                            child: Text("No one is comming in future!"),
                          );
                        }
                        final data = snapshot.data.documents;
                        buildPersonEntryList(data);
                        return (_personEntryList.length != 0)
                            ? Column(
                                children: <Widget>[
                                  Expanded(
                                    child: Scrollbar(
                                      child: RefreshIndicator(
                                        onRefresh: () =>
                                            buildPersonEntryList(data),
                                        child: ListView.builder(
                                          itemCount: _personEntryList.length,
                                          itemBuilder: (ctx, i) {
                                            print("name :  " +
                                                _personEntryList[i].name);
                                            print("userState : " +
                                                _personEntryList[i]
                                                    .status
                                                    .toString());
                                            return PersonEntryWidget(
                                                _personEntryList[i]);
                                          },
                                          padding: EdgeInsets.only(bottom: 70),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Center(
                                child: Text("No one is comming in future!"),
                              );
                      },
                    ),
                    floatingActionButton: FloatingActionButton(
                      backgroundColor: Theme.of(context).accentColor,
                      foregroundColor: Colors.white,
                      child: Icon(Icons.add),
                      onPressed: () async {
                        Navigator.of(context)
                            .pushNamed(EditPersonEntryScreen.routeName);
                        //print("floating button");
                      },
                    ),
                  );
  }
}
