import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user.dart';
import '../widgets/card_data_widget.dart';

class ProfileScreen extends StatelessWidget {
  static const routeName = 'profile-screen';

  @override
  Widget build(BuildContext context) {
    final userInfo = Provider.of<User>(context).userInfo;
    List<String> address =
        Provider.of<User>(context, listen: false).userAddress;
    return Scaffold(
      body: address == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(12),
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    if (userInfo.userType != UserType.SecurityGuard) ...[
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(color: Colors.green, spreadRadius: 1),
                          ],
                        ),
                        padding: EdgeInsets.all(5),
                        width: double.infinity,
                        child: Text(
                          'Personal Infomation',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      ListTile(
                        title: Text(
                          'Name',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          userInfo.name,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        leading: Padding(
                          padding: const EdgeInsets.only(top: 8.0, left: 8),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                    blurRadius: 1,
                                    color: Theme.of(context).primaryColor,
                                    spreadRadius: 1)
                              ],
                            ),
                            child: CircleAvatar(
                              child: Icon(
                                Icons.account_box_rounded,
                                color: Theme.of(context).accentColor,
                              ),
                              backgroundColor: Colors.white,
                              maxRadius: 20,
                            ),
                          ),
                        ),
                      ),
                      ListTile(
                        title: Text(
                          'Mobile Number',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          userInfo.mobileNumber,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        leading: Padding(
                          padding: const EdgeInsets.only(top: 8.0, left: 8),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                    blurRadius: 1,
                                    color: Theme.of(context).primaryColor,
                                    spreadRadius: 1)
                              ],
                            ),
                            child: CircleAvatar(
                              child: Icon(
                                Icons.phone_iphone,
                                color: Theme.of(context).accentColor,
                              ),
                              backgroundColor: Colors.white,
                              maxRadius: 20,
                            ),
                          ),
                        ),
                      ),
                      if (userInfo.email != '')
                        ListTile(
                          title: Text(
                            'Email',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            userInfo.email,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          leading: Padding(
                            padding: const EdgeInsets.only(top: 8.0, left: 8),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                      blurRadius: 1,
                                      color: Theme.of(context).primaryColor,
                                      spreadRadius: 1)
                                ],
                              ),
                              child: CircleAvatar(
                                child: Icon(
                                  Icons.email,
                                  color: Theme.of(context).accentColor,
                                ),
                                backgroundColor: Colors.white,
                                maxRadius: 20,
                              ),
                            ),
                          ),
                        ),
                      SizedBox(
                        height: 15,
                      ),
                    ],
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(color: Colors.green, spreadRadius: 1),
                        ],
                      ),
                      padding: EdgeInsets.all(5),
                      width: double.infinity,
                      child: Text(
                        'Address',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: [
                              CardDataWidget(
                                title: 'City',
                                value:
                                    address[0].substring(0, 1).toUpperCase() +
                                        address[0].substring(1),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              CardDataWidget(
                                title: 'Society',
                                value: address[1],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    if (userInfo.userType != UserType.SecurityGuard) ...[
                      Container(
                        width: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: [
                                CardDataWidget(
                                  title: 'Building/Street',
                                  value: address[2],
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                CardDataWidget(
                                  title: 'House Number',
                                  value: address[3],
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ],
                ),
              ),
            ),
    );
  }
}
