import 'package:GatEntry_V2/providers/user.dart';

import '../providers/approval_request.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class ApprovalRequestWidget extends StatefulWidget {
  final ApprovalRequest approvalRequest;

  ApprovalRequestWidget(this.approvalRequest);

  @override
  _ApprovalRequestWidgetState createState() => _ApprovalRequestWidgetState();
}

class _ApprovalRequestWidgetState extends State<ApprovalRequestWidget> {
  String name = "";

  String building = "";

  String houseNumber = "";

  String mobileNumber = "";

  void userData() async {
    final nameData = await Firestore.instance
        .collection('users')
        .document(widget.approvalRequest.userId)
        .get();
    name = nameData.data['name'];
    mobileNumber = nameData.data['mobileNumber'];

    if (widget.approvalRequest.userType != UserType.SecurityGuard) {
      final buildingData = await Firestore.instance
          .collection('building')
          .document(widget.approvalRequest.buildingId)
          .get();
      building = buildingData.data['name'].toString();

      final houseNumberData = await Firestore.instance
          .collection('houseNumber')
          .document(widget.approvalRequest.houseNumberId)
          .get();
      houseNumber = houseNumberData.data['number'].toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    userData();
    return Card(
      margin: EdgeInsets.all(8),
      elevation: 8,
      shadowColor: widget.approvalRequest.status == false
          ? Colors.red
          : widget.approvalRequest.status == true
              ? Colors.greenAccent
              : Colors.black87,
      child: (name == '' || mobileNumber == '')
          ? Center(
              child: CircularProgressIndicator(),
            )
          : widget.approvalRequest.status != null
              ? Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              widget.approvalRequest.userType ==
                                      UserType.SecurityGuard
                                  ? '$mobileNumber'
                                  : '$name',
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              widget.approvalRequest.userType ==
                                      UserType.SecurityGuard
                                  ? 'Security Guard'
                                  : '$building $houseNumber',
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
                  ],
                )
              : widget.approvalRequest.userType == UserType.SecurityGuard
                  ? InkWell(
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(
                                right: 15, left: 15, top: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    '$mobileNumber',
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 15),
                                    child: OutlineButton(
                                      borderSide: BorderSide(
                                          width: 2.5,
                                          color: Colors.greenAccent),
                                      child: Text(
                                        "Accept",
                                        style: TextStyle(fontSize: 18.0),
                                      ),
                                      highlightedBorderColor:
                                          Colors.greenAccent,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                      onPressed: () {
                                        Provider.of<ApprovalRequest>(context,
                                                listen: false)
                                            .updateApprovalRequest(
                                                ApprovalRequest(
                                          id: widget.approvalRequest.id,
                                          buildingId:
                                              widget.approvalRequest.buildingId,
                                          societyId:
                                              widget.approvalRequest.societyId,
                                          houseNumberId: widget
                                              .approvalRequest.houseNumberId,
                                          userId: widget.approvalRequest.userId,
                                          userType:
                                              widget.approvalRequest.userType,
                                          status: true,
                                        ));
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    'Security Guard',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 15),
                                    child: OutlineButton(
                                      child: Text(
                                        "Reject",
                                        style: TextStyle(fontSize: 18.0),
                                      ),
                                      borderSide: BorderSide(
                                          width: 2.5, color: Colors.red),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                      onPressed: () {
                                        Provider.of<ApprovalRequest>(context,
                                                listen: false)
                                            .updateApprovalRequest(
                                                ApprovalRequest(
                                          id: widget.approvalRequest.id,
                                          buildingId:
                                              widget.approvalRequest.buildingId,
                                          societyId:
                                              widget.approvalRequest.societyId,
                                          houseNumberId: widget
                                              .approvalRequest.houseNumberId,
                                          userId: widget.approvalRequest.userId,
                                          userType:
                                              widget.approvalRequest.userType,
                                          status: false,
                                        ));
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  : InkWell(
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(
                                right: 15, left: 15, top: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    '$name',
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 15),
                                    child: OutlineButton(
                                      borderSide: BorderSide(
                                          width: 2.5,
                                          color: Colors.greenAccent),
                                      child: Text(
                                        "Accept",
                                        style: TextStyle(fontSize: 18.0),
                                      ),
                                      highlightedBorderColor:
                                          Colors.greenAccent,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                      onPressed: () {
                                        Provider.of<ApprovalRequest>(context,
                                                listen: false)
                                            .updateApprovalRequest(
                                                ApprovalRequest(
                                          id: widget.approvalRequest.id,
                                          buildingId:
                                              widget.approvalRequest.buildingId,
                                          societyId:
                                              widget.approvalRequest.societyId,
                                          houseNumberId: widget
                                              .approvalRequest.houseNumberId,
                                          userId: widget.approvalRequest.userId,
                                          userType:
                                              widget.approvalRequest.userType,
                                          status: true,
                                        ));
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 10),
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
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 15),
                                    child: OutlineButton(
                                      child: Text(
                                        "Reject",
                                        style: TextStyle(fontSize: 18.0),
                                      ),
                                      borderSide: BorderSide(
                                          width: 2.5, color: Colors.red),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                      onPressed: () {
                                        Provider.of<ApprovalRequest>(context,
                                                listen: false)
                                            .updateApprovalRequest(
                                                ApprovalRequest(
                                          id: widget.approvalRequest.id,
                                          buildingId:
                                              widget.approvalRequest.buildingId,
                                          societyId:
                                              widget.approvalRequest.societyId,
                                          houseNumberId: widget
                                              .approvalRequest.houseNumberId,
                                          userId: widget.approvalRequest.userId,
                                          userType:
                                              widget.approvalRequest.userType,
                                          status: false,
                                        ));
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }
}
