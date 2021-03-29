import '../providers/approval_request.dart';
import '../widgets/approval_request_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user.dart';

class ApprovalRequestScreen extends StatelessWidget {
  static const routeName = '/approval-request-screen';

  Stream<QuerySnapshot> _approvalRequestData(User userInfo) {
    return Firestore.instance
        .collection('society')
        .document(userInfo.societyId)
        .collection("approvalRequest")
        .orderBy("date", descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    print("In approval Request");
    Provider.of<User>(context).fetchUserData();
    User userInfo = Provider.of<User>(context).userInfo;
    if (userInfo == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Approval Request'),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else if (userInfo.societyId.toString() == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Approval Request'),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    print("Pass");
    return Scaffold(
      appBar: AppBar(
          title: Text('Approval Request'),
        ),
      body: StreamBuilder(
        stream: _approvalRequestData(userInfo),
        builder: (ctx, snapshot) {
          print("snapshot : " + snapshot.data.toString());
          if (snapshot.data == null) {
            return Center(
              child: Text("No request is here!"),
            );
          }
          final data = snapshot.data.documents;
          print("Data : " + data.toString());
          return data.toString() == '[]'
              ? Center(
                  child: Text("No request is here!"),
                )
              : ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (ctx, i) {
                    return ApprovalRequestWidget(
                      ApprovalRequest(
                        id: data[i].documentID,
                        buildingId: data[i]['buildingId'],
                        societyId: data[i]['societyId'],
                        houseNumberId: data[i]['houseNumberId'],
                        userId: data[i]['userId'],
                        status: data[i]['status'],
                        userType: UserType.values[data[i]['userType']],
                      ),
                    );
                  },
                  padding: EdgeInsets.only(bottom: 70),
                );
        },
      ),
    );
  }
}
