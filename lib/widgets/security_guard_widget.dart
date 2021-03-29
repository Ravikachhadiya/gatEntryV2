import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/person_entry.dart';
import '../providers/user.dart';

class SecurityGuardWidget extends StatefulWidget {
  static const routeName = 'security';

  @override
  _SecurityGuardWidgetState createState() => _SecurityGuardWidgetState();
}

class _SecurityGuardWidgetState extends State<SecurityGuardWidget> {
  final _categoryFocusNode = FocusNode();
  final _entryCodeController = TextEditingController();
  final _form = GlobalKey<FormState>();

  String _name = null;
  String _societyId = null;
  String _building = null;
  String _buildingId = null;
  int _houseNumber = null;
  String _houseNumberId = null;
  Category _category = null;
  String _userId = null;
  Set<String> building = {};

  Set<int> flat = {};

// Validation of Name in  the form
  bool _nameValidtion(String name) {
    const Pattern patternNameOnlyChar = r"(\w+)";
    RegExp regexName = new RegExp(patternNameOnlyChar);
    //print(!regexName.hasMatch(name) ? false : true);
    return !regexName.hasMatch(name) ? false : true;
  }

  DateTime pickedDate;
  TimeOfDay time;

  @override
  void initState() {
    super.initState();
    pickedDate = DateTime.now();
    time = TimeOfDay.now();
    _editedPersonEntry = PersonEntry(
      id: _editedPersonEntry.id,
      userId: _editedPersonEntry.userId,
      name: _editedPersonEntry.name,
      buildingId: _editedPersonEntry.buildingId,
      societyId: _editedPersonEntry.societyId,
      houseId: _editedPersonEntry.houseId,
      category: _editedPersonEntry.category,
      time: time,
      code: _editedPersonEntry.code,
      dateTime: pickedDate,
      status: Status.Pending,
    );
  }

  var _editedPersonEntry = PersonEntry(
    id: null,
    userId: null,
    name: '',
    buildingId: null,
    societyId: null,
    houseId: null,
    category: Category.Relatives,
    time: null,
    code: null,
    dateTime: null,
    status: Status.Pending,
  );

  var _initValues = {
    'name': '',
    'category': Category.Relatives,
    'code': 000000,
    'time': null,
    'dateTime': null,
  };

  var _isLoading = false;

  @override
  void dispose() {
    _categoryFocusNode.dispose();
    super.dispose();
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

    getUserId(_houseNumberId);
  }

  void getUserId(String houseNumberId) {
    Firestore.instance
        .collection("society")
        .document(_societyId)
        .collection("member")
        .where("houseId", isEqualTo: houseNumberId)
        .getDocuments()
        .then((value) {
      _userId = value.documents[0]["userId"];
    });
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
          _houseNumberId = null;
          _houseNumber = null;
          FocusScope.of(context).requestFocus(FocusNode());
        });
      },
      onSaved: (value) {
        _editedPersonEntry = PersonEntry(
          id: DateTime.now().toString(),
          userId: _editedPersonEntry.userId,
          buildingId: _buildingId,
          societyId: _societyId,
          houseId: _editedPersonEntry.houseId,
          name: _editedPersonEntry.name,
          category: _editedPersonEntry.category,
          time: time,
          code: 000000,
          dateTime: _editedPersonEntry.dateTime,
          status: _editedPersonEntry.status,
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
          FocusScope.of(context).requestFocus(FocusNode());
        });
      },
      onSaved: (value) {
        _editedPersonEntry = PersonEntry(
          id: DateTime.now().toString(),
          userId: _editedPersonEntry.userId,
          buildingId: _editedPersonEntry.buildingId,
          societyId: _editedPersonEntry.societyId,
          houseId: _houseNumberId,
          name: _editedPersonEntry.name,
          category: _editedPersonEntry.category,
          time: time,
          code: 000000,
          dateTime: _editedPersonEntry.dateTime,
          status: _editedPersonEntry.status,
        );
      },
    );
  }

  Future<void> _saveForm() async {
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    }
    _form.currentState.save();
    setState(() {
      _isLoading = true;
    });

    _editedPersonEntry = PersonEntry(
      id: DateTime.now().toString(),
      userId: _userId,
      buildingId: _editedPersonEntry.buildingId,
      societyId: _editedPersonEntry.societyId,
      houseId: _editedPersonEntry.houseId,
      name: _editedPersonEntry.name,
      category: _editedPersonEntry.category,
      time: TimeOfDay.now(),
      code: 000000,
      dateTime: DateTime.now(),
      status: Status.Accepted,
    );
    try {
      print("Here .... try");
      Provider.of<PersonsEntries>(context, listen: false)
          .addPersonEntry(_editedPersonEntry);
    } catch (error) {
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('An error occurred!'),
          content: Text('Something went wrong.'),
          actions: <Widget>[
            FlatButton(
              child: Text('Okay'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            )
          ],
        ),
      );
    }

    setState(() {
      _isLoading = false;
    });

    _name = '';
    _building = null;
    _houseNumber = null;
    _category = null;
    _userId = null;
  }

  void validateEntryCode(
      BuildContext context, String socId) async {
    bool checkEntryCode;

    if (_entryCodeController.text.length < 6 ||
        _entryCodeController.text.isEmpty) {
      checkEntryCode = false;
    }

    checkEntryCode = await Provider.of<PersonsEntries>(context, listen: false)
        .entryCodeValidater(_entryCodeController.text, socId);

    if (checkEntryCode != true) {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor:  Color(0xffffcdd2),
          content: Text(
            'Please enter valid code',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xffff1744),
              fontSize: 17,
            ),
          ),
          duration: Duration(seconds: 3),
        ),
      );
    } else {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Color(0xffc8e6c9),
          content: Text(
            'Permission Granted'.toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xff00695c),
              fontSize: 17,
            ),
          ),
          duration: Duration(seconds: 3),
        ),
      );
      Provider.of<PersonsEntries>(context, listen: false)
          .updatePersonEntryStatus(int.parse(_entryCodeController.text), socId);
    }

    _entryCodeController.clear();
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<User>(context).fetchUserData();
    final userInfo = Provider.of<User>(context).userInfo;
    _societyId = userInfo.societyId;
    return Scaffold(
      body: Builder(
        builder: (context) => SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.60,
                      child: TextField(
                        style: TextStyle(fontSize: 20),
                        controller: _entryCodeController,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: "#123456",
                          hintStyle: TextStyle(fontSize: 20),
                          border: new OutlineInputBorder(
                            borderSide: new BorderSide(
                                color: Color(0xff0DAA1D), width: 1),
                            borderRadius: const BorderRadius.all(
                              const Radius.circular(3),
                            ),
                          ),
                        ),
                        onSubmitted: (_) =>
                            validateEntryCode(context, _societyId),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        FocusScope.of(context).requestFocus(FocusNode());
                        validateEntryCode(context, _societyId);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(0xff421818),
                          borderRadius: BorderRadius.all(
                            Radius.circular(5.0),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            "CHECK",
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(),
              Container(
                height: MediaQuery.of(context).size.height * 0.50,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  child: Form(
                    key: _form,
                    child: ListView(
                      children: <Widget>[
                        TextFormField(
                          initialValue: _name,
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
                              _buildingId = null;
                              _houseNumberId = null;
                            });
                          },
                          onSaved: (value) {
                            _editedPersonEntry = PersonEntry(
                              id: '',
                              userId: userInfo.id,
                              buildingId: _editedPersonEntry.buildingId,
                              societyId: userInfo.societyId,
                              houseId: _editedPersonEntry.houseId,
                              name: value,
                              category: _editedPersonEntry.category,
                              time: time,
                              code: 000000,
                              dateTime: _editedPersonEntry.dateTime,
                              status: _editedPersonEntry.status,
                            );
                          },
                        ),
                        DropdownButtonHideUnderline(
                          child: DropdownButtonFormField<Category>(
                            value: _category,
                            decoration: InputDecoration(labelText: 'Category'),
                            items: [
                              DropdownMenuItem(
                                child: Text("Relatives"),
                                value: Category.Relatives,
                              ),
                              DropdownMenuItem(
                                child: Text("Milk Man"),
                                value: Category.MilkMan,
                              ),
                              DropdownMenuItem(
                                child: Text("Delivery Boy"),
                                value: Category.DeliveryBoy,
                              ),
                              DropdownMenuItem(
                                child: Text("Servant"),
                                value: Category.Servant,
                              ),
                              DropdownMenuItem(
                                child: Text("Colleague"),
                                value: Category.Colleague,
                              ),
                              DropdownMenuItem(
                                child: Text("Friend"),
                                value: Category.Friend,
                              ),
                              DropdownMenuItem(
                                child: Text("Other"),
                                value: Category.Other,
                              ),
                            ],
                            onChanged: (Category value) {
                              setState(
                                () {
                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());
                                  _category = value;
                                },
                              );
                            },
                            onSaved: (Category value) {
                              _editedPersonEntry = PersonEntry(
                                id: _editedPersonEntry.id,
                                userId: _editedPersonEntry.userId,
                                buildingId: _editedPersonEntry.buildingId,
                                houseId: _editedPersonEntry.houseId,
                                societyId: _editedPersonEntry.societyId,
                                name: _editedPersonEntry.name,
                                category: value,
                                time: _editedPersonEntry.time,
                                code: _editedPersonEntry.code,
                                dateTime: _editedPersonEntry.dateTime,
                                status: _editedPersonEntry.status,
                              );
                            },
                            elevation: 2,
                          ),
                        ),
                        if (_name != null && _societyId != null) ...[
                          buildingDropDown(),
                          if (_building != null) ...[
                            houseNumberDropDown(),
                          ],
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              if (_houseNumber != null) ...[
                Container(
                  margin: EdgeInsets.all(15),
                  width: double.infinity,
                  child: RaisedButton(
                    child: Text(
                      'SAVE ENTRY',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    onPressed: _saveForm,
                    elevation: 0,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    color: Theme.of(context).accentColor,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
