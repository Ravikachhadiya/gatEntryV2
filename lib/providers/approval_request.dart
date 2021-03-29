import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import './user.dart';

class ApprovalRequest extends ChangeNotifier {
  final String id;
  final String userId;
  final String buildingId;
  final String houseNumberId;
  final String societyId;
  final UserType userType;
  final bool status;

  ApprovalRequest({
    @required this.id,
    @required this.userId,
    @required this.buildingId,
    @required this.houseNumberId,
    @required this.societyId,
    @required this.userType,
    this.status,
  });

  void addApprovalRequest(ApprovalRequest approvalRequest, bool userType) {
    Map<String, dynamic> approvalRequestData = {
      "userId": approvalRequest.userId,
      "houseNumberId": approvalRequest.houseNumberId,
      "status": approvalRequest.status,
      "buildingId": approvalRequest.buildingId,
      "societyId": approvalRequest.societyId,
      "userType": approvalRequest.userType.index,
      "date": DateTime.now(),
    };

    if (userType) {
      CollectionReference collectionReference =
          Firestore.instance.collection('society');

      collectionReference
          .document(approvalRequest.societyId)
          .collection('approvalRequest')
          .add(approvalRequestData);
    } else {
      Firestore.instance.collection('approvalRequest').add(approvalRequestData);
    }

    notifyListeners();
  }

  void updateApprovalRequest(ApprovalRequest approvalRequest) {
    Map<String, dynamic> approvalRequestData = {
      "userId": approvalRequest.userId,
      "houseNumberId": approvalRequest.houseNumberId,
      "status": approvalRequest.status,
      "buildingId": approvalRequest.buildingId,
      "societyId": approvalRequest.societyId,
      "userType": approvalRequest.userType.index,
      "date": DateTime.now(),
    };

    CollectionReference collectionReference =
        Firestore.instance.collection("society");

    print("societyId 1 : " + approvalRequest.societyId.toString());

    collectionReference
        .document(approvalRequest.societyId)
        .collection("approvalRequest")
        .document(approvalRequest.id)
        .setData(approvalRequestData);

    CollectionReference collectionReferenceUser =
        Firestore.instance.collection('users');

    collectionReferenceUser
        .document(approvalRequest.userId)
        .updateData({'approvalStatus': approvalRequest.status});
    notifyListeners();
  }
}
