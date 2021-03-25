import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:messanger_clone/helper_functions/shared_pref_helper.dart';
import 'package:messanger_clone/models/navigation_drawer.dart';
import 'package:messanger_clone/screens/chat_screen.dart';
import 'package:messanger_clone/screens/contacts.dart';
import 'package:messanger_clone/screens/sign_in.dart';
import 'package:messanger_clone/services/auth.dart';
import 'package:messanger_clone/services/database.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:random_string/random_string.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isSearching = false;
  String myName, myProfilePic, myUserName, myEmail, myUid, contactId;
  Stream userStream, chatRoomsStream;

  TextEditingController searchUsernameEditingController =
      TextEditingController();
  getMyInfoFromSharedPreference() async {
    myName = await SharedPrefHelper().getDisplayName();
    myProfilePic = await SharedPrefHelper().getUserProfileUrl();
    myUserName = await SharedPrefHelper().getUserName();
    myEmail = await SharedPrefHelper().getUserEmail();
    myUid = await SharedPrefHelper().getUserId();
    //print(myUserName);
  }

  getChatroomIdByUsername(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return '$b\_$a';
    } else {
      return '$a\_$b';
    }
  }

  onSearchBtnVlick() async {
    isSearching = true;
    setState(() {});
    userStream = await DatabaseMethods()
        .getUserByUsername(searchUsernameEditingController.text);
    setState(() {});
  }

  Widget searchListUserTile({String profileUrl, name, username, email}) {
    Map<String, dynamic> userInfoMap = {
      'email': email,
      'username': email.replaceAll('@gmail.com', '').replaceAll('@taybull.com', '').replaceAll('@utg.edu.gm', ''),
      'name': name,
      'profileUrl': profileUrl,
    };
    if(contactId == ''){
      contactId = randomAlphaNumeric(12);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {
            var chatRoomId = getChatroomIdByUsername(myUserName, username);
            Map<String, dynamic> chatRoomInfoMap = {
              'users': [myUserName, username],
            };
            //print(myUserName);
            //print(username);

            DatabaseMethods().createChatRoom(chatRoomId, chatRoomInfoMap);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ChatScreen(
                          chatWithUserName: username,
                          name: name,
                        )));
          },
          child: Row(
            children: [
              ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.network(
                    profileUrl,
                    width: 40.0,
                    height: 40.0,
                  )),
              SizedBox(
                width: 12,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [Text(name, style: TextStyle(fontWeight: FontWeight.bold),), Text(email)],
              ),
            ],
          ),
        ),
        GestureDetector(
           onTap: (){
             if(DatabaseMethods().getContactUserByUsername(username, myUid) != username) {
               DatabaseMethods().addUserInfoToContactsDatabase(
                   myUid,username, userInfoMap);
               print('on button tap');

               // Fluttertoast.showToast(msg: '$name added to contacts',
               //     toastLength: Toast.LENGTH_LONG,
               //     gravity: ToastGravity.BOTTOM,
               //    backgroundColor: Colors.grey[900]
               // );
               Fluttertoast.showToast(
                   msg: "This is Center Short Toast",
                   toastLength: Toast.LENGTH_SHORT,
                   gravity: ToastGravity.CENTER,
                   timeInSecForIosWeb: 1,
                   backgroundColor: Colors.red,
                   textColor: Colors.white,
                   fontSize: 16.0
               );
             }else{
               print('on button tap');
               // Fluttertoast.showToast(msg: '$name already added to contacts',
               //     toastLength: Toast.LENGTH_LONG,
               //     gravity: ToastGravity.BOTTOM,
               //     backgroundColor: Colors.red
               //);
               Fluttertoast.showToast(
                   msg: "This is Center Short Toast",
                   toastLength: Toast.LENGTH_SHORT,
                   gravity: ToastGravity.CENTER,
                   timeInSecForIosWeb: 1,
                   backgroundColor: Colors.red,
                   textColor: Colors.white,
                   fontSize: 16.0
               );
             }
          },
          child: Icon(Icons.add_box_outlined),
        ),
      ],
    );
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
                    lastMsg: ds['lastMessage'],
                    chatRoomId: ds.id,
                    myUserName: myUserName,
                  );
                },
              )
            : Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget searchUsersList() {
    return StreamBuilder(
      stream: userStream,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.docs.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  DocumentSnapshot ds = snapshot.data.docs[index];
                  return searchListUserTile(
                      profileUrl: ds['profileUrl'],
                      name: ds['name'],
                      username: ds['username'],
                      email: ds['email']);
                },
              )
            : Center(
                child: CircularProgressIndicator(),
              );
      },
    );
  }

  getChatRooms() async {
    chatRoomsStream = await DatabaseMethods().getChatRooms();
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
        title: Text('Chat App'),
        actions: [
          InkWell(
              onTap: () {
                AuthMethod().signOut().then((s) {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => SignIn()));
                });
              },
              child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Icon(Icons.exit_to_app))),
        ],
      ),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            Row(
              children: [
                isSearching
                    ? GestureDetector(
                        onTap: () {
                          isSearching = false;
                          searchUsernameEditingController.text = '';
                          setState(() {});
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Icon(Icons.arrow_back),
                        ),
                      )
                    : Container(),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 16.0),
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey,
                        width: 1.0,
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: searchUsernameEditingController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Username',
                            ),
                          ),
                        ),
                        GestureDetector(
                            onTap: () {
                              if (searchUsernameEditingController != '') {
                                onSearchBtnVlick();
                              }
                            },
                            child: Icon(Icons.search))
                      ],
                    ),
                  ),
                ),
              ],
            ),

            isSearching ? searchUsersList() : chatRoomList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.contact_page),
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context) => Contacts()));

        },
      ),
      drawer: NavigationDrawer(),
    );

  }
}

class ChatRoomListTile extends StatefulWidget {
  String chatRoomId;
  String myUserName;
  String lastMsg;

  ChatRoomListTile({this.chatRoomId, this.lastMsg, this.myUserName});
  @override
  _ChatRoomListTileState createState() => _ChatRoomListTileState();
}

class _ChatRoomListTileState extends State<ChatRoomListTile> {
  String profilePicUrl = '',
      name = '',
      lastMsg = '',
      username = '',
      lastSendTs = '';

  getThisUserInfo() async {
    username =
        widget.chatRoomId.replaceAll(widget.myUserName, '').replaceAll('_', '');
    QuerySnapshot querySnapshot = await DatabaseMethods().getuserInfo(username);
    print('something ${querySnapshot.docs[0]['name']}');
    name = '${querySnapshot.docs[0]['name']}';
    profilePicUrl = '${querySnapshot.docs[0]['profileUrl']}';
    setState(() {});
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
                    : CircularProgressIndicator()),
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
                  widget.lastMsg,
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

