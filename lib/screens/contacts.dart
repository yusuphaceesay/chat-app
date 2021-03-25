import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:messanger_clone/helper_functions/shared_pref_helper.dart';
import 'package:messanger_clone/services/database.dart';

import 'chat_screen.dart';
import 'home.dart';

class Contacts extends StatefulWidget {
  @override
  _ContactsState createState() => _ContactsState();
}

class _ContactsState extends State<Contacts> {
  String myName, myProfilePic, myUserName, myEmail, myUid;
  Stream userStream, chatRoomsStream;
  getMyInfoFromSharedPreference() async {
    myName = await SharedPrefHelper().getDisplayName();
    myProfilePic = await SharedPrefHelper().getUserProfileUrl();
    myUserName = await SharedPrefHelper().getUserName();
    myEmail = await SharedPrefHelper().getUserEmail();
    myUid = await SharedPrefHelper().getUserId();
    //print(myUserName);
  }

  Widget chatRoomList() {
    return StreamBuilder(
      stream: chatRoomsStream,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
          itemCount: snapshot.data.docs.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            DocumentSnapshot ds = snapshot.data.docs[index];
            return ChatRoomListTile(
              chatRoomId: ds.id,
              myUserName: myUserName,
              myUid: myUid,
            );
          },
        )
            : Center(child: CircularProgressIndicator());
      },
    );
  }
  getChatRooms() async {
    chatRoomsStream = await DatabaseMethods().getAllContactUserInfo(myUid);
    setState(() {});
  }

  onScreenLoaded() async {
    await getMyInfoFromSharedPreference();
    getChatRooms();
  }

  @override
  void initState() {
    onScreenLoaded();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contacts'),

      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        child: chatRoomList(),
      ),
    );
  }
}
class ChatRoomListTile extends StatefulWidget {
  String chatRoomId;
  String myUserName;
  String myUid;

  ChatRoomListTile({this.chatRoomId, this.myUserName, this.myUid});
  @override
  _ChatRoomListTileState createState() => _ChatRoomListTileState();
}

class _ChatRoomListTileState extends State<ChatRoomListTile> {
  String profilePicUrl = '',
      name = '',
      email = '',
      username = '',
      lastSendTs = '';

  getThisUserInfo() async {
    username =
        widget.chatRoomId.replaceAll(widget.myUserName, '').replaceAll('_', '');
    QuerySnapshot querySnapshot = await DatabaseMethods().getContactUserInfo( widget.myUid);
    print('something ${querySnapshot.docs[0]['name']}');
    name = '${querySnapshot.docs[0]['name']}';
    email = '${querySnapshot.docs[0]['email']}';
    profilePicUrl = '${querySnapshot.docs[0]['profileUrl']}';
    setState(() {});
    print('something something $profilePicUrl ');
  }

  @override
  void initState() {
    getThisUserInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChatScreen(
                  chatWithUserName: username,
                  name: name,
                )));
      },
      child: Container(
        margin: EdgeInsets.only(top: 5.0, bottom: 15.0, right: 20.0),
        child: Row(
          children: [
            ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: profilePicUrl != ''
                    ? Image.network(
                  profilePicUrl,
                  height: 50.0,
                  width: 50.0,
                )
                    : Text('')),
            SizedBox(
              width: 8,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(
                  height: 3,
                ),
                Text(
                  email,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

