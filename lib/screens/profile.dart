import 'package:flutter/material.dart';
import 'package:messanger_clone/helper_functions/shared_pref_helper.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String myName = '', myProfilePic = '', myUserName = '', myEmail = '', myUid = '';
  bool onBtnClick = false;
  getMyInfoFromSharedPreference() async {
    myName = await SharedPrefHelper().getDisplayName();
    myProfilePic = await SharedPrefHelper().getUserProfileUrl();
    myUserName = await SharedPrefHelper().getUserName();
    myEmail = await SharedPrefHelper().getUserEmail();
    myUid = await SharedPrefHelper().getUserId();
    //print(myUserName);
  }
  @override
  void initState() {
    getMyInfoFromSharedPreference();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Column(children: [
        SizedBox(height: 50.0,),
        CircleAvatar(
          radius: 70.0,
          backgroundImage: NetworkImage(myProfilePic),

        ),
        SizedBox(height: 50.0,),
        Row(children: [
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 30.0, horizontal: 20.0),
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white,
                  width: 1.0,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Row(children: [
                    Expanded(
                      child: Text('User Name'),
                    ),
                  ]),
                  Row(children: [
                    Expanded(
                      child: Text(myUserName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
                    ),
                  ]),
                ],
              ),
            ),
          ),

        ]),
        Row(children: [
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 30.0, horizontal: 20.0),
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white,
                  width: 1.0,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Row(children: [
                    Expanded(
                      child: Text('Email'),
                      ),
                  ]),
                  Row(children: [
                    Expanded(
                      child: Text(myEmail, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
                    ),
                  ]),
                ],
              ),
            ),
          ),

        ]),
        Row(children: [
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 30.0, horizontal: 20.0),
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white,
                  width: 1.0,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(children: [
                Expanded(
                  child: Column(
                    children: [
                      Row(children: [
                        Expanded(
                          child: Text('Name'),
                        ),
                      ]),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(children: [
                            Text(myName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
                          ]),
                          GestureDetector(
                            onTap: () => onBtnClick = true,
                              child: Icon(Icons.edit)),
                        ],
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),

        ]),
      ]),
    );
    //       ],
    //     ),
    //   ],
    // ),
  }
}
