import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:day_night_time_picker/lib/daynight_timepicker.dart';

import '../providers/person_entry.dart';
import '../providers/user.dart';

class EditPersonEntryScreen extends StatefulWidget {
  static const routeName = '/person-entry-edit';

  @override
  _EditPersonEntryScreenState createState() => _EditPersonEntryScreenState();
}

class _EditPersonEntryScreenState extends State<EditPersonEntryScreen> {
  final _categoryFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();

  Category _value = Category.Relatives;

  // Validation of Name in  the form
  // r'^[A-Za-z ]+(?:[ -][A-Za-z ]+)$'
  // bool _nameValidtion(String name) {
  //   const Pattern patternNameOnlyChar = r'^[A-Za-z ]+(?:[ -][A-Za-z ]+)$';
  //   RegExp regexName = new RegExp(patternNameOnlyChar);

  //   return !regexName.hasMatch(name) ? false : true;
  // }

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

  _pickDate() async {
    DateTime date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(new Duration(days: 5)),
      initialDate: pickedDate,
    );
    if (date != null)
      setState(() {
        pickedDate = date;
        _editedPersonEntry = PersonEntry(
          id: _editedPersonEntry.id,
          userId: _editedPersonEntry.userId,
          name: _editedPersonEntry.name,
          buildingId: _editedPersonEntry.buildingId,
          societyId: _editedPersonEntry.societyId,
          houseId: _editedPersonEntry.houseId,
          category: _editedPersonEntry.category,
          time: _editedPersonEntry.time,
          code: _editedPersonEntry.code,
          dateTime: pickedDate,
          status: _editedPersonEntry.status,
        );
      });
  }

  void onTimeChanged(TimeOfDay newTime) {
    setState(() {
      time = newTime;
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
        dateTime: _editedPersonEntry.dateTime,
        status: _editedPersonEntry.status,
      );
    });
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

  var _isInit = true;
  var _isLoading = false;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final personEntryData =
          ModalRoute.of(context).settings.arguments as PersonEntry;
      //print("Data Of entry : " + personEntryData.name.toString());
      if (personEntryData != null) {
        _editedPersonEntry = personEntryData;
        print("Data 2 : ---------------------------------");
        pickedDate = _editedPersonEntry.dateTime;
        time = _editedPersonEntry.time;
        _initValues = {
          'name': _editedPersonEntry.name,
          'category': _editedPersonEntry.category,
          'code': _editedPersonEntry.code,
          'time': _editedPersonEntry.time,
          'dateTime': _editedPersonEntry.dateTime,
        };
        _value = _editedPersonEntry.category;
      }
      print("Data sub final = " + _initValues.toString());
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _categoryFocusNode.dispose();
    super.dispose();
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
    if (_editedPersonEntry.id != null) {
      Provider.of<PersonsEntries>(context, listen: false)
          .updatePersonEntry( _editedPersonEntry);
      setState(() {
        _isLoading = false;
      });
    } else {
      _editedPersonEntry = PersonEntry(
        id: DateTime.now().toString(),
        userId: _editedPersonEntry.userId,
        buildingId: _editedPersonEntry.buildingId,
        societyId: _editedPersonEntry.societyId,
        houseId: _editedPersonEntry.houseId,
        name: _editedPersonEntry.name,
        category: _editedPersonEntry.category,
        time: time,
        code: 000000,
        dateTime: _editedPersonEntry.dateTime,
        status: _editedPersonEntry.status,
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
      // finally {
      //   setState(() {
      //     _isLoading = false;
      //   });
      //   Navigator.of(context).pop();
      // }
    }
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<User>(context).fetchUserData();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    print("Data final = " + _initValues.toString());
    final userInfo = Provider.of<User>(context, listen: false).userInfo;
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Entry'),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _form,
                      child: ListView(
                        children: <Widget>[
                          TextFormField(
                            initialValue: _initValues['name'],
                            decoration: InputDecoration(labelText: 'Name'),
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) {
                              FocusScope.of(context)
                                  .requestFocus(_categoryFocusNode);
                            },
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please provide a name.';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _editedPersonEntry = PersonEntry(
                                id: _editedPersonEntry.id,
                                userId: userInfo.id,
                                buildingId: userInfo.buildingId,
                                houseId: userInfo.houseNumberId,
                                societyId: userInfo.societyId,
                                name: value,
                                category: _editedPersonEntry.category,
                                time: _editedPersonEntry.time,
                                code: _editedPersonEntry.code,
                                dateTime: _editedPersonEntry.dateTime,
                                status: _editedPersonEntry.status,
                              );
                            },
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          DropdownButtonHideUnderline(
                            child: DropdownButtonFormField<Category>(
                              value: _value,
                              decoration:
                                  InputDecoration(labelText: 'Category'),
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
                                    _value = value;
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
                          ListTile(
                            contentPadding: EdgeInsets.all(0),
                            title: Text(
                              "Date",
                              style:
                                  TextStyle(fontSize: 13, color: Colors.grey),
                            ),
                            subtitle: Text(
                              "${pickedDate.day}-${pickedDate.month}-${pickedDate.year}",
                              style: TextStyle(
                                  fontSize: 16, color: Colors.black87),
                            ),
                            trailing: Icon(Icons.keyboard_arrow_down),
                            onTap: _pickDate,
                          ),
                          ListTile(
                            contentPadding: EdgeInsets.all(0),
                            title: Text(
                              "Time",
                              style:
                                  TextStyle(fontSize: 13, color: Colors.grey),
                            ),
                            subtitle: Text(
                              time.format(context),
                              style: TextStyle(
                                  fontSize: 16, color: Colors.black87),
                            ),
                            trailing: Icon(Icons.keyboard_arrow_down),
                            onTap: () {
                              Navigator.of(context).push(
                                showPicker(
                                  context: context,
                                  value: time,
                                  onChange: onTimeChanged,
                                  // Optional onChange to receive value as DateTime
                                  onChangeDateTime: (DateTime dateTime) {
                                    //print(dateTime);
                                  },
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                RaisedButton(
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
              ],
            ),
    );
  }
}
