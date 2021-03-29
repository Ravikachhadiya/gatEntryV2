import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum UserType {
  Member,
  HigherAuthority,
  SecurityGuard,
}

enum UserStatus {
  Owner,
  Renter,
}

enum OccupancyStatus {
  CurrentlyResiding,
  EmptyHouse,
}

class User extends ChangeNotifier {
  final String id;
  final UserType userType;
  final String mobileNumber;
  final String name;
  final String email;
  final String houseNumberId;
  final String societyId;
  final String buildingId;
  final UserStatus userStatus;
  final OccupancyStatus occupancyStatus;
  final bool approvalStatus;

  User({
    @required this.id,
    @required this.userType,
    @required this.mobileNumber,
    @required this.name,
    @required this.email,
    @required this.buildingId,
    @required this.societyId,
    @required this.houseNumberId,
    @required this.userStatus,
    @required this.occupancyStatus,
    this.approvalStatus,
  });

  User _userInfo;
  bool _checkUser;
  String _userId;
  List<String> _address;

  bool get isUser {
    tryAutoLogin();
    //print("CheckUser : " + _checkUser.toString());

    return (_checkUser == false && _checkUser != null);
  }

  String get userIdOfUser {
    return _userId;
  }

  User get userInfo {
    return _userInfo;
  }

  List<String> get userAddress {
    return _address;
  }

  void addNewUser(User user) {
    //print("New User addded .... => " + user.toString());

    Map<String, dynamic> userData = {
      "userType": user.userType.index,
      "mobileNumber": user.mobileNumber,
      "name": user.name,
      "email": user.email,
      "houseNumberId": user.houseNumberId,
      "userStatus": user.userStatus.index,
      "buildingId": user.buildingId,
      "societyId": user.societyId,
      "occupancyStatus": user.occupancyStatus.index,
      "approvalStatus": user.approvalStatus,
    };

    Map<String, dynamic> memberData = {
      "buildingId": user.buildingId,
      "houseId": user.houseNumberId,
      "userId": user.id,
    };

    CollectionReference collectionReference =
        Firestore.instance.collection('users');

    collectionReference.document(user.id).setData(userData).then((value) {
      CollectionReference collectionReferenceSocietyMember =
          Firestore.instance.collection('society');

      print(
          "----------------------------------------------------------------------------------");
      collectionReferenceSocietyMember
          .document(user.societyId)
          .collection('members')
          .document()
          .setData(memberData);
    });

    //print(collectionReference.document.toString());

    print(
        "===============================================================================");
    notifyListeners();
    // //printUserData();
  }

  Future<bool> isUserNew(String userId) async {
    // Get data from firestore
    //print("User Id : " + userId.toString());

    DocumentSnapshot user;
    try {
      user =
          await Firestore.instance.collection('users').document(userId).get();
    } catch (e) {
      //print("error : " + e.toString());
    }

    //print("User Id: " + userId + " Data : " + user.data.toString());

    // Check whether userId is in collection or not
    _checkUser = (user.data == null) ? true : false;

    notifyListeners();
    //print(_checkUser);
    return _checkUser;
  }

  void fetchUserData() async {
    DocumentSnapshot user =
        await Firestore.instance.collection('users').document(_userId).get();

    _userInfo = User(
      id: _userId,
      userType: UserType.values[user.data['userType']],
      mobileNumber: user.data['mobileNumber'],
      name: user.data['name'],
      email: user.data['email'],
      houseNumberId: user.data['houseNumberId'],
      buildingId: user.data['buildingId'],
      societyId: user.data['societyId'],
      userStatus: UserStatus.values[user.data['userStatus']],
      occupancyStatus: OccupancyStatus.values[user.data['occupancyStatus']],
      approvalStatus: user.data['approvalStatus'],
    );

    String cityId;
    String societyName = '';
    String cityName = '';
    String building = '';
    String houseNumber = '';

    await Firestore.instance
        .collection("society")
        .document(userInfo.societyId)
        .get()
        .then((value) {
      societyName = value.data['name'];
      cityId = value.data['cityId'];
    });

    await Firestore.instance
        .collection("city")
        .document(cityId)
        .get()
        .then((value) => cityName = value.data['name']);
    if (_userInfo.userType != UserType.SecurityGuard) {
      await Firestore.instance
          .collection("building")
          .document(userInfo.buildingId)
          .get()
          .then((value) => building = value.data['name']);

      await Firestore.instance
          .collection("houseNumber")
          .document(userInfo.houseNumberId)
          .get()
          .then((value) => houseNumber = value.data['number'].toString());
    }

    _address = [cityName, societyName, building, houseNumber];

    notifyListeners();
    //printUserData();
  }

  void editUserData(User user) async {
    Map<String, dynamic> userData = {
      "userType": user.userType.index,
      "mobileNumber": user.mobileNumber,
      "name": user.name,
      "email": user.email,
      "houseNumberId": user.houseNumberId,
      "userStatus": user.userStatus.index,
      "buildingId": user.buildingId,
      "societyId": user.societyId,
      "occupancyStatus": user.occupancyStatus.index,
      "approvalStatus": user.approvalStatus,
    };

    CollectionReference collectionReference =
        Firestore.instance.collection('users');

    collectionReference.document(user.id).updateData(userData);

    if (userInfo.houseNumberId != user.houseNumberId) {
      await Firestore.instance
          .collection('society')
          .document(userInfo.societyId)
          .collection('members')
          .where("userId", isEqualTo: userInfo.id)
          .where("houseId", isEqualTo: userInfo.houseNumberId)
          .where("buildingId", isEqualTo: userInfo.buildingId)
          .getDocuments()
          .then((value) {
        Firestore.instance
            .collection('society')
            .document(userInfo.societyId)
            .collection('members')
            .document(value.documents[0].documentID)
            .delete();
      });

      Map<String, dynamic> memberData = {
        "buildingId": user.buildingId,
        "houseId": user.houseNumberId,
        "userId": user.id,
      };

      Firestore.instance
          .collection('society')
          .document(user.societyId)
          .collection('members')
          .add(memberData);
    }

    fetchUserData();
  }

  void printUserData() {
    //print("...............................................................");
    //print("User Id : " + _userInfo.id);
    //print(_userInfo.userType.toString());
    //print(_userInfo.mobileNumber);
    //print(_userInfo.name);
    //print(_userInfo.email);
    //print(_userInfo.password);
    //print(_userInfo.houseNumberId);
    //print(_userInfo.userStatus.toString());
    //print(_userInfo.occupancyStatus.toString());
    //print("...............................................................");
  }

  Future<bool> tryAutoLogin() async {
    //sleep(const Duration(seconds: 1));
    final prefs = await SharedPreferences.getInstance();
    //print("autologin _userId : " + _userId.toString());
    // if (await isUserNew(_userId)) {
    //   _userId = null;
    //   final prefs = await SharedPreferences.getInstance();
    //   prefs.clear();
    //   return false;
    // }

    //print(" Prefs : " + prefs.getString('userId').toString());
    if (!prefs.containsKey('userId')) {
      return false;
    }

    final userId = prefs.getString('userId');
    //print("pref userId : " + userId);
    _userId = userId;

    notifyListeners();
    return true;
  }

  // Future<List> fetchCities() async {
  //   List cityList;
  //   final cities = [];
  //   CollectionReference collectionReference =
  //       Firestore.instance.collection('city');

  //   print('Colle : ' + collectionReference.toString());

  //   collectionReference.snapshots().listen((snapshot) {
  //     //print("snapshot : " + snapshot.documents[0].data.toString());
  //     cityList = snapshot.documents;

  //     for (int i = 0; i < cityList.length; i++) {
  //       cities.add(cityList[i]['name']);
  //     }
  //     print("Cities 1  :" + cityList.toString());
  //     return cities;
  //   });
  // }
}
