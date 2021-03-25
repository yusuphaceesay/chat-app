import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:messanger_clone/helper_functions/shared_pref_helper.dart';
import 'package:messanger_clone/services/database.dart';
import 'package:random_string/random_string.dart';

class ChatScreen extends StatefulWidget {
  final String chatWithUserName, name;

  ChatScreen({this.chatWithUserName, this.name});
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  Stream msgStream;
  String chatRoomId, msgId = '';
  String myName, myProfilePic, myUserName, myEmail;
  TextEditingController msgTextEditingController = TextEditingController();

   getMyInfoFromSharedPreference() async {
     myName = await SharedPrefHelper().getDisplayName();
     myProfilePic = await SharedPrefHelper().getUserProfileUrl();
     myUserName = await SharedPrefHelper().getUserName();
     myEmail = await SharedPrefHelper().getUserEmail();
    chatRoomId = getChatroomIdByUsername(widget.chatWithUserName, myUserName);
  }

  getChatroomIdByUsername(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return '$b\_$a';
    } else {
      return '$a\_$b';
    }
  }

  addMessage(bool sendClick) {
    if(msgTextEditingController.text != ''){
      String msg = msgTextEditingController.text;

      var lastMsgTimeStamp = DateTime.now();

      Map<String, dynamic> msgInfoMap = {
        'message': msg,
        'sendBy': myUserName,
        'timeStamp': lastMsgTimeStamp,
        'imgUrl': myProfilePic,
      };
      //msg id
      if(msgId == ''){
        msgId = randomAlphaNumeric(12);
      }
      DatabaseMethods().addmsg(chatRoomId, msgId, msgInfoMap).then((value) {
        Map<String, dynamic> lastMessageInfoMap = {
          'lastMessage': msg,
          'lastMessageSendTS': lastMsgTimeStamp,
          'lastMessageSendBy': myUserName,
        };

        DatabaseMethods().updateLastMessageSend(chatRoomId, lastMessageInfoMap);

        if(sendClick){
          //remove text from textfield
          msgTextEditingController.text = '';

          //make msg id blank to get regenerated on nextmessage send
          msgId = '';
        }
      });
    }
  }
  Widget chatMsgTile(String msg, bool sendByMe){
    return Row(
      mainAxisAlignment: sendByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: sendByMe ? Radius.circular(24): Radius.circular(24),
              bottomLeft: sendByMe ? Radius.circular(24) : Radius.circular(0),
              topRight: sendByMe ? Radius.circular(24) : Radius.circular(24),
              bottomRight: sendByMe ? Radius.circular(0) : Radius.circular(24),
            ),
            color: sendByMe ? Colors.blue : Colors.grey,
          ),
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          padding: EdgeInsets.all(16),child: Text(msg, style: TextStyle(color: Colors.white),),),
      ],
    );
  }

  Widget chatMsg(){
    return StreamBuilder(
      stream: msgStream,
      builder: (context, snapshot){
        return snapshot.hasData ? ListView.builder(
          padding: EdgeInsets.only(bottom: 70, top: 16),
          reverse: true,
          itemCount: snapshot.data.docs.length,
          itemBuilder: (context, index){
            DocumentSnapshot ds = snapshot.data.docs[index];
            return(chatMsgTile(ds['message'], myUserName == ds['sendBy']));
          },
        ) : Center(child: CircularProgressIndicator());
      },
    );
  }

  getAndSetMessages() async {
    msgStream = await DatabaseMethods().getChatRoomMsg(chatRoomId);
    setState(() {

    });
  }

  doThisOnLaunch() async {
    await getMyInfoFromSharedPreference();
    getAndSetMessages();
  }

  @override
  void initState() {
    // TODO: implement initState
    doThisOnLaunch();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
      ),
      body: Container(
        child: Stack(
          children: [
            chatMsg(),
            Container(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                color: Colors.grey[800].withOpacity(0.6),
                child: Row(
                  children: [
                    Expanded(
                        child: TextField(
                          controller: msgTextEditingController,
                          style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'type a message',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.6))
                      ),
                    )),
                    GestureDetector(onTap: (){
                      addMessage(true);
                    },child: Icon(Icons.send,color: Colors.white,)),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
