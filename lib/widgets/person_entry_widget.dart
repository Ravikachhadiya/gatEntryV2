import '../screens/tab_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share/share.dart';
import 'package:provider/provider.dart';

import '../providers/person_entry.dart';
import '../screens/edit_person_entry_screen.dart';

class PersonEntryWidget extends StatelessWidget {
  final PersonEntry personEntry;

  PersonEntryWidget(this.personEntry);

  void share(BuildContext context) {
    final RenderBox box = context.findRenderObject();
    Share.share(
        "Name :" +
            personEntry.name +
            "\nDate : " +
            new DateFormat('dd/MM/yyyy')
                .format(personEntry.dateTime)
                .toString() +
            "\nTime : ${personEntry.time.hour}:${personEntry.time.minute} \nEntry Code :" +
            personEntry.code.toString(),
        subject: "Entry Code",
        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: personEntry.status == Status.Cancelled
          ? Color(0xffFFE9E9)
          : personEntry.status == Status.Accepted
              ? Color(0xffF1FFEA)
              : Colors.white,
      margin: EdgeInsets.all(8),
      elevation: 5,
      shadowColor: personEntry.status == Status.Cancelled
          ? Color(0xffF35454)
          : personEntry.status == Status.Accepted
              ? Color(0xff91F281)
              : Colors.black87,
      child: InkWell(
        onTap: () {
          //print("Id : " + personEntry.id);
          Navigator.of(context).pushNamed(EditPersonEntryScreen.routeName,
              arguments: personEntry);
        },
        child: (personEntry.code == 0 || personEntry.status == Status.Accepted)
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            personEntry.name,
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
                                .format(personEntry.dateTime)
                                .toString(),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            personEntry.time.format(context),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : Column(
                children: <Widget>[
                  Padding(
                    padding:
                        const EdgeInsets.only(right: 12.0, left: 15, top: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            '\#${personEntry.code}',
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
                            child: Text(
                              personEntry.name,
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    title: Text(new DateFormat('dd/MM/yyyy')
                        .format(personEntry.dateTime)
                        .toString()),
                    subtitle: Text(personEntry.time.format(context)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        IconButton(
                          icon: Icon(Icons.share),
                          color: Colors.blueAccent,
                          onPressed: () {
                            share(context);
                            //print("Share...>");
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          color: Theme.of(context).errorColor,
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: Text('Are you sure?'),
                                content: Text(
                                  'Do you want to remove the entry?',
                                ),
                                actions: <Widget>[
                                  FlatButton(
                                    child: Text('No'),
                                    onPressed: () {
                                      Navigator.of(ctx).pop(false);
                                    },
                                  ),
                                  FlatButton(
                                    child: Text('Delete'),
                                    onPressed: () {
                                      print(
                                          "delete name : " + personEntry.name);
                                      Provider.of<PersonsEntries>(context,
                                              listen: false)
                                          .deletePersonEntry(personEntry);
                                      Navigator.of(ctx).pop(true);

                                      Navigator.of(ctx).pushReplacementNamed(
                                          TabScreen.routeName);
                                      Scaffold.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Deleted Successfully',
                                            textAlign: TextAlign.center,
                                          ),
                                          duration: Duration(seconds: 3),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
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
