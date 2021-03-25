import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:messanger_clone/helper_functions/shared_pref_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DatabaseMethods {
  Future addUserInfoToDatabase(
      String userId, Map<String, dynamic> userInfoMap) async {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .set(userInfoMap);
  }
  Future addUserInfoToContactsDatabase(
      String userId, String contactId, Map<String, dynamic> userInfoMap) async {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId).collection('contacts').doc(contactId)
        .set(userInfoMap);
  }

  Future<Stream<QuerySnapshot>> getUserByUsername(String username) async {
    return FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .snapshots();
  }
  Future<Stream<QuerySnapshot>> getContactUserByUsername(String username, String Uid) async {
    return FirebaseFirestore.instance
        .collection('users').doc(Uid).collection('contacts')
        .where('username', isEqualTo: username)
        .snapshots();
  }

  Future addmsg(String chatroomId, String msgId, Map msgInfoMap) async {
    return FirebaseFirestore.instance
        .collection('chatrooms')
        .doc(chatroomId)
        .collection('chats')
        .doc(msgId)
        .set(msgInfoMap);
  }

  Future updateLastMessageSend(
      String chatRoomId, Map lastMessageInfoMap) async {
    return FirebaseFirestore.instance
        .collection('chatrooms')
        .doc(chatRoomId)
        .update(lastMessageInfoMap);
  }

  Future createChatRoom(String chatRoomId, Map chatRoomInfoMap) async {
    final snapShot = await FirebaseFirestore.instance
        .collection('chatrooms')
        .doc(chatRoomId)
        .get();
    if (snapShot.exists) {
      return true;
    } else {
      return FirebaseFirestore.instance
          .collection('chatrooms')
          .doc(chatRoomId)
          .set(chatRoomInfoMap);
    }
  }

  Future<Stream<QuerySnapshot>> getChatRoomMsg(chatRoomId) async {
    return FirebaseFirestore.instance
        .collection('chatrooms')
        .doc(chatRoomId)
        .collection('chats')
        .orderBy('timeStamp', descending: true)
        .snapshots();
  }

  Future<Stream<QuerySnapshot>> getChatRooms() async {
    String myUserName = await SharedPrefHelper().getUserName();
    return FirebaseFirestore.instance
        .collection('chatrooms')
        .orderBy('lastMessageSendTS', descending: true)
        .where('users', arrayContains: myUserName)
        .snapshots();
  }
  Future<Stream<QuerySnapshot>> getAllChatRooms() async {
    String myUserName = await SharedPrefHelper().getUserName();
    return FirebaseFirestore.instance
        .collection('chatrooms')
        .snapshots();
  }
  Future<QuerySnapshot> getuserInfo(String username)async{
    return await FirebaseFirestore.instance.collection('users').where('username', isEqualTo: username).get();
  }
  Future<Stream<QuerySnapshot>> getAllContactUserInfo(String uid)async{
    return FirebaseFirestore.instance.collection('users').doc(uid).collection('contacts').snapshots();
  }
  Future<QuerySnapshot> getContactUserInfo(String uid)async{
    return FirebaseFirestore.instance.collection('users').doc(uid).collection('contacts').get();
  }

}
