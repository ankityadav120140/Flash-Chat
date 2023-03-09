// ignore_for_file: avoid_unnecessary_containers, prefer_const_constructors

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../utilities/global.dart';

class chatScreen extends StatefulWidget {
  final String phone2;
  final String name2;
  const chatScreen({required this.phone2, required this.name2, super.key});

  @override
  State<chatScreen> createState() => _chatScreenState();
}

class _chatScreenState extends State<chatScreen> {
  String? Phone;

  late TextEditingController msg;

  bool loading = false;

  String getChatId(String userId1, String userId2) {
    List<String> users = [userId1, userId2];
    users.sort(); // sort the user IDs alphabetically
    return '${users[0]}_${users[1]}'; // concatenate the user IDs with an underscore
  }

  void getData() {
    Phone = preferences.getString("phone");
  }

  void setData() async {
    String chatID =
        getChatId(preferences.getString("phone").toString(), widget.phone2);
    DocumentReference ref =
        FirebaseFirestore.instance.collection("chats").doc(chatID);
    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(ref);
      if (!snapshot.exists) {
        ref.set({
          "msg": "",
        });
      } else {
        ref.update({
          "msg": "",
        });
      }
    });
  }

  void sendMsg() async {
    String chatID =
        getChatId(preferences.getString("phone").toString(), widget.phone2);
    DocumentReference ref =
        FirebaseFirestore.instance.collection("chats").doc(chatID);
    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(ref);
      if (!snapshot.exists) {
        ref.set({
          "msg": msg.text,
        });
      } else {
        ref.update({
          "msg": msg.text,
        });
      }
    });
  }

  // @override
  void initState() {
    getData();
    setData();
    msg = TextEditingController(text: "");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(widget.name2),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(),
            Container(
              margin: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.08,
                bottom: MediaQuery.of(context).size.height * 0.08,
              ),
              height: MediaQuery.of(context).size.height * 0.6,
              width: MediaQuery.of(context).size.width * 0.8,
              decoration: BoxDecoration(
                  color: Colors.cyan.shade100,
                  borderRadius: BorderRadius.circular(20)),
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('chats')
                    .doc(getChatId(preferences.getString("phone").toString(),
                        widget.phone2))
                    .snapshots(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasError) {
                    // Handle error case
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  } else if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    // Handle loading case
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (!snapshot.hasData) {
                    // Handle empty data case
                    return Center(
                      child: Text("Let's start!"),
                    );
                  } else {
                    // Handle data available case

                    // Replace with your own widget tree
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        snapshot.data['msg'] != ""
                            ? Text(
                                snapshot.data['msg'],
                                style: TextStyle(fontSize: 20),
                              )
                            : Center(
                                child: Text("Let's start!!"),
                              ),
                        SizedBox(height: 16),
                      ],
                    );
                  }
                },
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.cyan.shade300,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.only(left: 20),
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: TextFormField(
                          enableSuggestions: true,
                          controller: msg,
                          decoration: InputDecoration(
                            labelText: 'Enter you message',
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          sendMsg();
                          // sleep(Duration(seconds: 2));
                          // msg.text = '';
                        },
                        icon: Icon(
                          Icons.send,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
