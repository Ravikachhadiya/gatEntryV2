import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HouseNumberScreen extends StatefulWidget {
  static const routeName = "house-number-screen";
  @override
  _HouseNumberScreenState createState() => _HouseNumberScreenState();
}

class _HouseNumberScreenState extends State<HouseNumberScreen> {
  final _form = GlobalKey<FormState>();
  int _newHouseNumber = null;
  String _city = null;
  String _cityId = null;
  String _society = null;
  String _societyId = null;
  String _building = null;
  String _buildingId = null;
  int _houseNumber = null;
  String _houseNumberId = null;

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

  void getDocumentIdOfFlat(int flatNumber) {
    Query collectionReference =
        Firestore.instance.collection('houseNumber').orderBy('number');

    collectionReference.snapshots().listen((snapshot) {
      //print("snapshot : " + snapshot.documents[0].data.toString());
      var faltList = snapshot.documents;

      for (int i = 0; i < faltList.length; i++) {
        if (faltList[i]['number'] == flatNumber &&
            faltList[i]['societyId'] == _buildingId) {
          _houseNumberId = faltList[i].documentID;
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
                _newHouseNumber = null;
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
            _newHouseNumber = null;
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
      validator: (value) {
        if (value == null) {
          return 'Please choose your building/street';
        }
        return null;
      },
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
      // validator: (value) {
      //   if (value == null) {
      //     return 'Please choose your House number';
      //   }
      //   return null;
      // },
      onChanged: (value) {
        setState(() {
          _houseNumber = value;
          FocusScope.of(context).requestFocus(FocusNode());
        });
      },
      onSaved: (value) {},
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

  void addHouseNumber() {
    Map<String, dynamic> buildingData = {
      "number": _newHouseNumber,
      "buildingId": _buildingId,
    };

    CollectionReference collectionReference =
        Firestore.instance.collection('houseNumber');

    collectionReference.add(buildingData);
  }

  Future<void> _saveForm() async {
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    }
    _form.currentState.save();
    try {
      addHouseNumber();
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
      Navigator.of(context).pushReplacementNamed(HouseNumberScreen.routeName);
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
                  if (_building != null) ...[
                    houseNumberDropDown(),
                    Container(
                      margin:
                          EdgeInsets.symmetric(vertical: 20, horizontal: 120),
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
                        flat.length.toString(),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    TextFormField(
                        //initialValue: _initValues['name'],
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            labelText: 'House number',
                            hintText: "House Number"),
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          //print(value);
                          if (value.isEmpty) {
                            return 'Please provide a number.';
                          }

                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            _newHouseNumber = int.parse(value);
                          });
                        },
                        onSaved: (value) {
                          _newHouseNumber = int.parse(value);
                        }),
                    SizedBox(height: 20),
                    if (_newHouseNumber != null) ...[
                      signupButton(),
                    ],
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
