import '../providers/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/approval_request.dart';

class EditProfileScreen extends StatefulWidget {
  static const routeName = 'edit-profile';

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _form = GlobalKey<FormState>();

  User userInfo;
  List<String> address = [];
  String _name = null;
  String _email = null;
  String _city = null;
  String _cityId = null;
  String _society = null;
  String _societyId = null;
  String _building = null;
  String _buildingId = null;
  int _houseNumber = null;
  String _houseNumberId = null;
  UserType _userType = null;
  UserStatus _userStatus = null;
  OccupancyStatus _occupancyStatus = null;

  // Validation of Name in  the form
  bool _nameValidtion(String name) {
    const Pattern patternNameOnlyChar = r"(\w+)";
    RegExp regexName = new RegExp(patternNameOnlyChar);
    //print(!regexName.hasMatch(name) ? false : true);
    return !regexName.hasMatch(name) ? false : true;
  }

  // Validation of email in  the form
  bool _emailValidtion(String email) {
    const Pattern patternEmail =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regexName = new RegExp(patternEmail);
    //print(!regexName.hasMatch(email) ? false : true);
    return !regexName.hasMatch(email) ? false : true;
  }

  var _newUser = User(
    id: null,
    userType: null,
    mobileNumber: null,
    name: null,
    email: null,
    houseNumberId: null,
    buildingId: null,
    societyId: null,
    userStatus: null,
    occupancyStatus: null,
    approvalStatus: null,
  );

  @override
  void initState() {
    super.initState();
    _newUser = Provider.of<User>(context, listen: false).userInfo;
    userInfo = Provider.of<User>(context, listen: false).userInfo;
    address = Provider.of<User>(context, listen: false).userAddress;

    _userType = _newUser.userType;
    _name = _newUser.name;
  }

  List<String> city = [];
  List<String> zipcodes = [];

  Set<String> society = {};

  Set<String> building = {};

  Set<int> flat = {};

  void socityList() {
    Query collectionReference =
        Firestore.instance.collection('society').orderBy('name');

    collectionReference.snapshots().listen((snapshot) {
      var societySnapshot = snapshot.documents;

      for (int i = 0; i < societySnapshot.length; i++) {
        for (int j = 0; j < societySnapshot.length; j++) {
          if (societySnapshot[i]['cityId'] == _cityId) {
            society.add(societySnapshot[i]['name']);
          }
        }
      }
    });
  }

  void buildingList() {
    Query collectionReference =
        Firestore.instance.collection('building').orderBy('name');

    collectionReference.snapshots().listen((snapshot) {
      var buildingSnapshot = snapshot.documents;

      for (int i = 0; i < buildingSnapshot.length; i++) {
        for (int j = 0; j < buildingSnapshot.length; j++) {
          if (buildingSnapshot[i]['societyId'] == _societyId) {
            building.add(buildingSnapshot[i]['name']);
          }
        }
      }
    });
  }

  void flatList() {
    Query collectionReference =
        Firestore.instance.collection('houseNumber').orderBy('number');

    collectionReference.snapshots().listen((snapshot) {
      var flatSnapshot = snapshot.documents;

      for (int i = 0; i < flatSnapshot.length; i++) {
        for (int j = 0; j < flatSnapshot.length; j++) {
          if (flatSnapshot[i]['buildingId'] == _buildingId) {
            flat.add(flatSnapshot[i]['number']);
          }
        }
      }

      print("In for loop : " + flat.toString());
    });
  }

  void getDocumentIdOfCity(String cityName) {
    CollectionReference collectionReference =
        Firestore.instance.collection('city');

    collectionReference.snapshots().listen((snapshot) {
      //print("snapshot : " + snapshot.documents[0].data.toString());
      var cityList = snapshot.documents;

      for (int i = 0; i < cityList.length; i++) {
        if (cityList[i]['name'] == cityName) {
          _cityId = cityList[i].documentID;
        }
      }
    });
  }

  void getDocumentIdOfSociety(String societyName) {
    Query collectionReference =
        Firestore.instance.collection('society').orderBy('name');

    collectionReference.snapshots().listen((snapshot) {
      //print("snapshot : " + snapshot.documents[0].data.toString());
      var societyList = snapshot.documents;

      for (int i = 0; i < societyList.length; i++) {
        if (societyList[i]['name'] == societyName) {
          _societyId = societyList[i].documentID;
        }
      }
    });
  }

  void getDocumentIdOfBuilding(String buildingName) {
    Query collectionReference =
        Firestore.instance.collection('building').orderBy('name');

    collectionReference.snapshots().listen((snapshot) {
      //print("snapshot : " + snapshot.documents[0].data.toString());
      var buildingList = snapshot.documents;

      for (int i = 0; i < buildingList.length; i++) {
        if (buildingList[i]['name'] == buildingName &&
            buildingList[i]['societyId'] == _societyId) {
          _buildingId = buildingList[i].documentID;
        }
      }
    });
  }

  void getDocumentIdOfFlat(int flatNumber) {
    Query collectionReference =
        Firestore.instance.collection('houseNumber').orderBy('number');

    collectionReference.snapshots().listen((snapshot) {
      //print("snapshot : " + snapshot.documents[0].data.toString());
      var faltList = snapshot.documents;

      for (int i = 0; i < faltList.length; i++) {
        if (faltList[i]['number'] == flatNumber &&
            faltList[i]['buildingId'] == _buildingId) {
          _houseNumberId = faltList[i].documentID;
        }
      }
    });
  }

  Widget cityDropDown() {
    return new StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('city').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(
            child: const CupertinoActivityIndicator(),
          );
        return DropdownButtonFormField<String>(
          decoration: InputDecoration(labelText: 'City'),
          items: snapshot.data.documents.map((DocumentSnapshot document) {
            //print("----> " + document.documentID);
            return new DropdownMenuItem<String>(
              value: document.data['name'],
              child: new Text(document.data['name']),
            );
          }).toList(),
          validator: (value) {
            if (value == null) {
              return 'Please choose your city';
            }
            return null;
          },
          onChanged: (value) {
            setState(
              () {
                society = {};
                getDocumentIdOfCity(value);
                _city = value;
                _societyId = null;
                _buildingId = null;
                _houseNumberId = null;
                _society = null;
                _building = null;
                _houseNumber = null;
                _userStatus = null;
                _occupancyStatus = null;
                FocusScope.of(context).requestFocus(FocusNode());
              },
            );
          },
          onSaved: (value) {
            _newUser = User(
              id: _newUser.id,
              userType: _newUser.userType,
              mobileNumber: _newUser.mobileNumber,
              name: _newUser.name,
              email: _newUser.email,
              houseNumberId: _newUser.houseNumberId,
              buildingId: _newUser.buildingId,
              approvalStatus: _newUser.approvalStatus,
              societyId: _newUser.societyId,
              userStatus: _newUser.userStatus,
              occupancyStatus: _newUser.occupancyStatus,
            );
          },
        );
      },
    );
  }

  Widget societyDropDown() {
    socityList();
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(labelText: 'Society'),
      items: society.map((String society) {
        return new DropdownMenuItem<String>(
          value: society,
          child: new Text(
            society,
          ),
        );
      }).toList(),
      validator: (value) {
        if (value == null) {
          return 'Please choose your Society';
        }
        return null;
      },
      onChanged: (value) {
        setState(
          () {
            building = {};
            getDocumentIdOfSociety(value);
            _society = value;
            _buildingId = null;
            _houseNumberId = null;
            _userStatus = null;
            _occupancyStatus = null;
            _building = null;
            _houseNumber = null;
            FocusScope.of(context).requestFocus(FocusNode());
          },
        );
      },
      onSaved: (value) {
        _newUser = User(
          id: _newUser.id,
          userType: _newUser.userType,
          mobileNumber: _newUser.mobileNumber,
          name: _newUser.name,
          email: _newUser.email,
          houseNumberId: _newUser.houseNumberId,
          buildingId: _newUser.buildingId,
          societyId: _societyId,
          approvalStatus: _newUser.approvalStatus,
          userStatus: _newUser.userStatus,
          occupancyStatus: _newUser.occupancyStatus,
        );
      },
    );
  }

  Widget buildingDropDown() {
    buildingList();
    return new DropdownButtonFormField<String>(
      decoration: InputDecoration(labelText: 'Building/Street'),
      items: building.map((String value) {
        return new DropdownMenuItem<String>(
          value: value,
          child: new Text(value),
        );
      }).toList(),
      validator: (value) {
        if (value == null) {
          return 'Please choose your building/street';
        }
        return null;
      },
      onChanged: (value) {
        setState(() {
          flat = {};
          getDocumentIdOfBuilding(value);
          _building = value;
          _houseNumberId = null;
          _houseNumber = null;
          _userStatus = null;
          _occupancyStatus = null;
          FocusScope.of(context).requestFocus(FocusNode());
        });
      },
      onSaved: (value) {
        _newUser = User(
          id: _newUser.id,
          userType: _newUser.userType,
          mobileNumber: _newUser.mobileNumber,
          name: _newUser.name,
          email: _newUser.email,
          houseNumberId: _newUser.houseNumberId,
          buildingId: _buildingId,
          societyId: _newUser.societyId,
          approvalStatus: _newUser.approvalStatus,
          userStatus: _newUser.userStatus,
          occupancyStatus: _newUser.occupancyStatus,
        );
      },
    );
  }

  Widget houseNumberDropDown() {
    flatList();
    print('Flat :' + flat.toString());
    return new DropdownButtonFormField<int>(
      decoration: InputDecoration(labelText: 'House No.'),
      items: flat.map((int value) {
        return new DropdownMenuItem<int>(
          value: value,
          child: new Text('$value'),
        );
      }).toList(),
      validator: (value) {
        if (value == null) {
          return 'Please choose your House number';
        }
        return null;
      },
      onChanged: (value) {
        setState(() {
          getDocumentIdOfFlat(value);
          _houseNumber = value;
          _userStatus = null;
          _occupancyStatus = null;
          FocusScope.of(context).requestFocus(FocusNode());
        });
      },
      onSaved: (value) {
        _newUser = User(
          id: _newUser.id,
          userType: _newUser.userType,
          mobileNumber: _newUser.mobileNumber,
          name: _newUser.name,
          email: _newUser.email,
          houseNumberId: _houseNumberId,
          buildingId: _newUser.buildingId,
          societyId: _newUser.societyId,
          approvalStatus: _newUser.approvalStatus,
          userStatus: _newUser.userStatus,
          occupancyStatus: _newUser.occupancyStatus,
        );
      },
    );
  }

  Widget signupButton() {
    return RaisedButton(
      child: Text(
        'SUBMIT',
        style: TextStyle(color: Colors.white),
      ),
      onPressed: _saveForm,
      elevation: 0,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      color: Theme.of(context).accentColor,
    );
  }

  bool _submit = true;

  Future<void> _saveForm() async {
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    }
    _form.currentState.save();

    if (_newUser.userType == UserType.SecurityGuard) {
      _newUser = User(
        id: _newUser.id,
        userType: _newUser.userType,
        mobileNumber: _newUser.mobileNumber,
        name: _newUser.name,
        email: '',
        houseNumberId: '',
        buildingId: '',
        societyId: _newUser.societyId,
        approvalStatus: _newUser.approvalStatus,
        userStatus: UserStatus.Renter,
        occupancyStatus: OccupancyStatus.EmptyHouse,
      );
    } else {
      _newUser = User(
        id: _newUser.id,
        userType: _newUser.userType,
        mobileNumber: _newUser.mobileNumber,
        name: _newUser.name,
        email: _newUser.email,
        houseNumberId: _newUser.houseNumberId,
        buildingId: _newUser.buildingId,
        societyId: _newUser.societyId,
        approvalStatus: _newUser.approvalStatus,
        userStatus: _newUser.userStatus,
        occupancyStatus: _newUser.occupancyStatus,
      );
    }

    final _approvalRequest = ApprovalRequest(
        id: '',
        buildingId: _newUser.buildingId,
        houseNumberId: _newUser.houseNumberId,
        societyId: _newUser.societyId,
        userId: _newUser.id,
        userType: _newUser.userType);
    try {
      // add New User
      Provider.of<User>(context, listen: false).editUserData(_newUser);

      // add approval request
      if (userInfo.houseNumberId != _newUser.houseNumberId) {
        if (_newUser.userType == UserType.Member ||
            _newUser.userType == UserType.SecurityGuard) {
          Provider.of<ApprovalRequest>(context, listen: false)
              .addApprovalRequest(_approvalRequest, true);
        } else {
          Provider.of<ApprovalRequest>(context, listen: false)
              .addApprovalRequest(_approvalRequest, false);
        }
      }
    } catch (error) {
      //print(error);
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('An error occurred!'),
          content: Text('Something went wrong.'),
          actions: <Widget>[
            FlatButton(
              child: Text('Okay'),
              onPressed: () {
                Navigator.of(context).pop();
                _submit = false;
              },
            )
          ],
        ),
      );
    }
    if (_submit) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          textAlign: TextAlign.center,
        ),
      ),
      body: FutureBuilder(
        future: FirebaseAuth.instance.currentUser(),
        builder: (context, snapshot) {
          FirebaseUser firebaseUser = snapshot.data;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: Form(
              key: _form,
              child: ListView(
                children: <Widget>[
                  DropdownButtonFormField<UserType>(
                    value: _newUser.userType,
                    decoration: InputDecoration(labelText: 'User Type'),
                    items: [
                      DropdownMenuItem(
                        child: Text("Resident"),
                        value: UserType.Member,
                      ),
                      DropdownMenuItem(
                        child: Text("Higher Authority"),
                        value: UserType.HigherAuthority,
                      ),
                      DropdownMenuItem(
                        child: Text("Security Guard"),
                        value: UserType.SecurityGuard,
                      ),
                    ],
                    onChanged: (UserType value) {
                      setState(
                        () {
                          _userType = value;
                          _city = null;
                          _society = null;
                          _name = null;
                          _email = null;
                          _building = null;
                          _cityId = null;
                          _buildingId = null;
                          _societyId = null;
                          _houseNumberId = null;
                          _houseNumber = null;
                          _userStatus = null;
                          _occupancyStatus = null;
                        },
                      );
                    },
                    onSaved: (UserType value) {
                      _newUser = User(
                        id: firebaseUser.uid,
                        userType: value,
                        mobileNumber: firebaseUser.phoneNumber,
                        name: _newUser.name,
                        email: _newUser.email,
                        houseNumberId: _newUser.houseNumberId,
                        buildingId: _newUser.buildingId,
                        approvalStatus: _newUser.approvalStatus,
                        societyId: _newUser.societyId,
                        userStatus: _newUser.userStatus,
                        occupancyStatus: _newUser.occupancyStatus,
                      );
                    },
                    elevation: 2,
                  ),
                  if (_userType == UserType.SecurityGuard) ...[
                    cityDropDown(),
                    if (_city != null) ...[
                      societyDropDown(),
                      if (_society != null) ...[
                        signupButton(),
                      ],
                    ],
                  ],
                  if ((_userType != null) &&
                      (_userType == UserType.Member ||
                          _userType == UserType.HigherAuthority)) ...[
                    TextFormField(
                      initialValue: _newUser.name,
                      keyboardType: TextInputType.name,
                      decoration: InputDecoration(labelText: 'Name'),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        //FocusScope.of(context).requestFocus(_categoryFocusNode);
                      },
                      validator: (value) {
                        //print(value);
                        if (value.isEmpty) {
                          return 'Please provide a name.';
                        } else if (!_nameValidtion(value)) {
                          return 'Please provide correct name';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        setState(() {
                          _name = value;
                          _cityId = null;
                          _societyId = null;
                          _buildingId = null;
                          _houseNumberId = null;
                        });
                      },
                      onSaved: (value) {
                        _newUser = User(
                          id: _newUser.id,
                          userType: _newUser.userType,
                          mobileNumber: _newUser.mobileNumber,
                          name: value,
                          email: _newUser.email,
                          houseNumberId: _newUser.houseNumberId,
                          buildingId: _newUser.buildingId,
                          approvalStatus: _newUser.approvalStatus,
                          societyId: _newUser.societyId,
                          userStatus: _newUser.userStatus,
                          occupancyStatus: _newUser.occupancyStatus,
                        );
                      },
                    ),
                    TextFormField(
                      initialValue: _newUser.email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'Email (Optional)',
                      ),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        //FocusScope.of(context).requestFocus(_categoryFocusNode);
                      },
                      validator: (value) {
                        //print(value);
                        if (value == null || value == "") {
                          return null;
                        } else if (!_emailValidtion(value)) {
                          return 'Please provide correct email';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        setState(() {
                          _email = value;
                        });
                      },
                      onSaved: (value) {
                        _newUser = User(
                          id: _newUser.id,
                          userType: _newUser.userType,
                          mobileNumber: _newUser.mobileNumber,
                          name: _newUser.name,
                          email: value,
                          houseNumberId: _newUser.houseNumberId,
                          buildingId: _newUser.buildingId,
                          societyId: _newUser.societyId,
                          approvalStatus: _newUser.approvalStatus,
                          userStatus: _newUser.userStatus,
                          occupancyStatus: _newUser.occupancyStatus,
                        );
                      },
                    ),
                    if (_name != null) ...[
                      cityDropDown(),
                      if (_city != null) ...[
                        societyDropDown(),
                        if (_society != null) ...[
                          buildingDropDown(),
                          if (_building != null) ...[
                            houseNumberDropDown(),
                            if (_houseNumber != null) ...[
                              DropdownButtonFormField<UserStatus>(
                                value: _newUser.userStatus,
                                decoration:
                                    InputDecoration(labelText: 'You are'),
                                items: [
                                  DropdownMenuItem(
                                    child: Text("Owner"),
                                    value: UserStatus.Owner,
                                  ),
                                  DropdownMenuItem(
                                    child: Text("Renter"),
                                    value: UserStatus.Renter,
                                  ),
                                ],
                                validator: (UserStatus value) {
                                  if (value == null) {
                                    return 'Please choose your status';
                                  }
                                  return null;
                                },
                                onChanged: (UserStatus value) {
                                  setState(
                                    () {
                                      _userStatus = value;
                                      _occupancyStatus = null;
                                      FocusScope.of(context)
                                          .requestFocus(FocusNode());
                                    },
                                  );
                                },
                                onSaved: (UserStatus value) {
                                  _newUser = User(
                                    id: _newUser.id,
                                    userType: _newUser.userType,
                                    mobileNumber: _newUser.mobileNumber,
                                    name: _newUser.name,
                                    email: _newUser.email,
                                    houseNumberId: _newUser.houseNumberId,
                                    buildingId: _newUser.buildingId,
                                    societyId: _newUser.societyId,
                                    approvalStatus: _newUser.approvalStatus,
                                    userStatus: value,
                                    occupancyStatus: _newUser.occupancyStatus,
                                  );
                                },
                                elevation: 2,
                              ),
                              if (_userStatus != null) ...[
                                DropdownButtonFormField<OccupancyStatus>(
                                  value: _newUser.occupancyStatus,
                                  decoration: InputDecoration(
                                      labelText: 'Occupancy Status'),
                                  items: [
                                    DropdownMenuItem(
                                      child: Text("Currently Residing"),
                                      value: OccupancyStatus.CurrentlyResiding,
                                    ),
                                    DropdownMenuItem(
                                      child: Text("Empty House"),
                                      value: OccupancyStatus.EmptyHouse,
                                    ),
                                  ],
                                  validator: (OccupancyStatus value) {
                                    if (value == null) {
                                      return 'Please choose occupancy status';
                                    }
                                    return null;
                                  },
                                  onChanged: (OccupancyStatus value) {
                                    setState(
                                      () {
                                        _occupancyStatus = value;
                                        FocusScope.of(context)
                                            .requestFocus(FocusNode());
                                      },
                                    );
                                  },
                                  onSaved: (OccupancyStatus value) {
                                    _newUser = User(
                                      id: _newUser.id,
                                      userType: _newUser.userType,
                                      mobileNumber: _newUser.mobileNumber,
                                      name: _newUser.name,
                                      email: _newUser.email,
                                      houseNumberId: _newUser.houseNumberId,
                                      buildingId: _newUser.buildingId,
                                      societyId: _newUser.societyId,
                                      approvalStatus: _newUser.approvalStatus,
                                      userStatus: _newUser.userStatus,
                                      occupancyStatus: _occupancyStatus,
                                    );
                                  },
                                  elevation: 2,
                                ),
                                SizedBox(height: 20),
                                if (_occupancyStatus != null) ...[
                                  signupButton(),
                                ],
                              ],
                            ],
                          ],
                        ],
                      ],
                    ],
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
