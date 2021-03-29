import 'package:GatEntry_V2/providers/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/person_entry.dart';

class HistoryWidget extends StatefulWidget {
  final PersonEntry personEntry;

  HistoryWidget(this.personEntry);

  @override
  _HistoryWidgetState createState() => _HistoryWidgetState();
}

class _HistoryWidgetState extends State<HistoryWidget> {
  String building = "";

  String houseNumber = "";
  void userData() async {
    final buildingData = await Firestore.instance
        .collection('building')
        .document(widget.personEntry.buildingId)
        .get();
    building = buildingData.data['name'].toString();

    final houseNumberData = await Firestore.instance
        .collection('houseNumber')
        .document(widget.personEntry.houseId)
        .get();
    houseNumber = houseNumberData.data['number'].toString();
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<User>(context).fetchUserData();
    final userInfo = Provider.of<User>(context).userInfo;
    userData();

    return (building == '' || houseNumber == '')
        ? Center(
            child: CircularProgressIndicator(),
          )
        : userInfo.userType == UserType.SecurityGuard
            ? Card(
                margin: EdgeInsets.all(8),
                elevation: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              '$building $houseNumber',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              widget.personEntry.name,
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 0, bottom: 10, right: 16, left: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              new DateFormat('dd/MM/yyyy')
                                  .format(widget.personEntry.dateTime)
                                  .toString(),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              widget.personEntry.time.format(context),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            : Card(
                margin: EdgeInsets.all(8),
                elevation: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              widget.personEntry.name,
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              new DateFormat('dd/MM/yyyy')
                                  .format(widget.personEntry.dateTime)
                                  .toString(),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              widget.personEntry.time.format(context),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
  }
}
