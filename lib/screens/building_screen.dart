import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BuildingScreen extends StatefulWidget {
  static const routeName = "building-screen";
  @override
  _BuildingScreenState createState() => _BuildingScreenState();
}

class _BuildingScreenState extends State<BuildingScreen> {
  final _form = GlobalKey<FormState>();
  String _buildingName = null;
  String _city = null;
  String _cityId = null;
  String _society = null;
  String _societyId = null;
  String _building = null;
  String _buildingId = null;
  String _houseNumber = null;
  String _houseNumberId = null;

  List<String> city = [];
  List<String> zipcodes = [];

  Set<String> society = {};

  Set<String> building = {};

  List<String> flat = [
    "101",
    "102",
    "201",
    "202",
    "301",
    "302",
    "401",
    "402",
    "501",
    "502",
  ];

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

  void getDocumentIdOfCity(String cityName) {
    Query collectionReference =
        Firestore.instance.collection('city').orderBy('name');

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

  Widget cityDropDown() {
    return new StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('city').orderBy('name').snapshots(),
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
                getDocumentIdOfCity(value);
                society = {};
                _city = value;
                _society = null;
                _building = null;
                _buildingName = null;
                FocusScope.of(context).requestFocus(FocusNode());
              },
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
            getDocumentIdOfSociety(value);
            _society = value;
            _building = null;
            _buildingName = null;
            FocusScope.of(context).requestFocus(FocusNode());
          },
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
      // validator: (value) {
      //   if (value == null) {
      //     return 'Please choose your building/street';
      //   }
      //   return null;
      // },
      onChanged: (value) {
        setState(() {
          getDocumentIdOfBuilding(value);
          _building = value;
          _houseNumber = null;
          FocusScope.of(context).requestFocus(FocusNode());
        });
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

  void addBuilding() {
    Map<String, dynamic> buildingData = {
      "name": _buildingName,
      "societyId": _societyId,
    };

    CollectionReference collectionReference =
        Firestore.instance.collection('building');

    collectionReference.add(buildingData);
  }

  Future<void> _saveForm() async {
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    }
    _form.currentState.save();
    try {
      addBuilding();
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

    if (_submit)
      Navigator.of(context).pushReplacementNamed(BuildingScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Building',
          textAlign: TextAlign.center,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _form,
          child: ListView(
            children: <Widget>[
              cityDropDown(),
              if (_city != null) ...[
                societyDropDown(),
                if (_society != null) ...[
                  buildingDropDown(),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 20, horizontal: 120),
                    padding: EdgeInsets.all(10),
                    width: (MediaQuery.of(context).size.width) / 2.5,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                            color: Theme.of(context).accentColor,
                            spreadRadius: 1),
                      ],
                    ),
                    child: Text(
                      building.length.toString(),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  TextFormField(
                    //initialValue: _initValues['name'],
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                        labelText: 'Name', hintText: "Building Name"),
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      //print(value);
                      if (value.isEmpty) {
                        return 'Please provide a name.';
                      }

                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        _buildingName = value;
                      });
                    },
                    onSaved: (value) {
                      _buildingName = value;
                    },
                  ),
                  SizedBox(height: 20),
                  if (_buildingName != null) ...[
                    signupButton(),
                  ],
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
