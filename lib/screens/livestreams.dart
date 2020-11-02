import 'package:agora_livestream/models/livestream.dart';
import 'package:agora_livestream/repositories/firebase_repository.dart';
import 'package:agora_livestream/screens/login.dart';
import 'package:agora_livestream/screens/stream_live.dart';
import 'package:agora_livestream/screens/watch_stream.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';

class LiveStreamsScreen extends StatelessWidget {
  LiveStreamsScreen({Key key}) : super(key: key);
  FirebaseRepo _firebaseRepo = FirebaseRepo();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Livestreams'),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              showDialog(
                context: context,
                child: AlertDialog(
                  content: Text('Are you sure you want to logout?'),
                  actions: [
                    FlatButton(
                      child: Text('Cancel'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    FlatButton(
                      child: Text('Confirm'),
                      onPressed: () async {
                        Navigator.of(context).pop();
                        await _firebaseRepo.signOut();
                        print('sign out');
                      },
                    )
                  ],
                ),
              );
            },
          )
        ],
      ),
      floatingActionButton: floatingBtn(),
      body: StreamBuilder(
        stream:
            FirebaseFirestore.instance.collection('livestreams').snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshots) {
          if (snapshots.hasData && snapshots.data.docs.length < 1) {
            return Center(
              child: Text('No livestreams here yet'),
            );
          } else if (snapshots.hasData) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.count(
                  childAspectRatio: 0.75,
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 16,
                  children: snapshots.data.docs
                      .map((e) => liveStreamItem(LiveStream.fromJSON(e.data())))
                      .toList()),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  Widget liveStreamItem(LiveStream live) {
    return Builder(builder: (context) {
      return GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => WatchStreamScreen(
                liveStream: live,
              ),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black45,
            borderRadius: BorderRadius.circular(15),
          ),
          height: 260,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(5),
                child: Row(
                  children: [
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: NetworkImage(live.streamerPhoto)),
                          shape: BoxShape.circle),
                    ),
                    SizedBox(width: 5),
                    Expanded(
                        child: Text(live.streamerName,
                            style: TextStyle(
                                fontWeight: FontWeight.w400, fontSize: 13)))
                  ],
                ),
              )
            ],
          ),
        ),
      );
    });
  }

  Widget floatingBtn() {
    return Builder(
      builder: (context) => FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            child: AlertDialog(
              content: Text('Are you sure you want to go live?'),
              actions: [
                FlatButton(
                  child: Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                FlatButton(
                  child: Text('Go Live'),
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await [
                      Permission.camera,
                      Permission.microphone,
                      Permission.storage
                    ].request();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return StreamToLiveScreen();
                        },
                      ),
                    );
                  },
                )
              ],
            ),
          );
        },
        child: Icon(Icons.video_call_outlined),
      ),
    );
  }
}
