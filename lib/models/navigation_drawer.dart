import 'package:flutter/material.dart';
import 'package:messanger_clone/helper_functions/shared_pref_helper.dart';
import 'package:messanger_clone/screens/profile.dart';
import 'package:messanger_clone/services/auth.dart';

class NavigationDrawer extends StatefulWidget {
  @override
  _NavigationDrawerState createState() => _NavigationDrawerState();
}

class _NavigationDrawerState extends State<NavigationDrawer> {
  String myName = '', myProfilePic = '', myUserName = '', myEmail = '', myUid = '';

  getMyInfoFromSharedPreference() async {
    myName = await SharedPrefHelper().getDisplayName();
    myProfilePic = await SharedPrefHelper().getUserProfileUrl();
    myUserName = await SharedPrefHelper().getUserName();
    myEmail = await SharedPrefHelper().getUserEmail();
    myUid = await SharedPrefHelper().getUserId();
    print(myProfilePic);
  }
  onScreenLoaded() async {
    await getMyInfoFromSharedPreference();
  }
  @override
  void initState() {
    onScreenLoaded();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width*0.7,
      child: Drawer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Padding(
                padding: EdgeInsets.all(6.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: myProfilePic != '' ? Image.network(
                              myProfilePic,
                              width: 70.0,
                              height: 70.0,
                            ) : CircleAvatar()),
                      ],
                    ),
                    SizedBox(height: 15.0,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(myName, style: TextStyle(color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.bold),),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(myEmail, style: TextStyle(color: Colors.white60, fontSize: 16.0, fontWeight: FontWeight.bold),),
                      ],
                    ),

                  ],
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Profile'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Profile())),
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Logout'),
              onTap: () => AuthMethod().signOut(),
            ),

          ],
        ),
      ),
    );
  }
}
