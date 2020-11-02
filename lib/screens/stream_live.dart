import 'package:agora_livestream/models/livestream.dart';
import 'package:agora_livestream/repositories/firebase_repository.dart';
import 'package:agora_livestream/repositories/livestream_repository.dart';
import 'package:agora_livestream/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;

class StreamToLiveScreen extends StatefulWidget {
  @override
  _StreamToLiveScreenState createState() => _StreamToLiveScreenState();
}

class _StreamToLiveScreenState extends State<StreamToLiveScreen> {
  String channelName;
  final ClientRole role = ClientRole.Broadcaster;

  final _users = <int>[];
  final _infoStrings = <String>[];
  bool muted = false;
  RtcEngine _engine;
  bool _joined = false;
  @override
  void dispose() {
    // clear users
    _users.clear();
    // destroy sdk
    _engine.leaveChannel();
    _engine.destroy();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // initialize agora sdk
    channelName = generateUUID();
    initialize();
  }

  Future<void> initialize() async {
    await _initAgoraRtcEngine();
    _addAgoraEventHandlers();
    // await _engine.enableWebSdkInteroperability(true);
    VideoEncoderConfiguration configuration = VideoEncoderConfiguration();
    configuration.dimensions = VideoDimensions(360, 240);
    await _engine.setVideoEncoderConfiguration(configuration);
    // await _engine.setRemoteVideoStreamType(uid, streamType);
    await _engine.joinChannel(null, channelName, null, 0);
  }

  /// Create agora sdk instance and initialize
  Future<void> _initAgoraRtcEngine() async {
    _engine = await RtcEngine.create(APP_ID);
    await _engine.enableVideo();
    await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await _engine.setClientRole(role);
  }

  /// Add agora event handlers
  void _addAgoraEventHandlers() {
    _engine.setEventHandler(
      RtcEngineEventHandler(
        error: (code) {
          setState(() {
            final info = 'onError: $code';
            _infoStrings.add(info);
          });
        },
        joinChannelSuccess: (channel, uid, elapsed) async {
          // TODO add firebase document for livestream;
          FirebaseRepo firebaseRepo = new FirebaseRepo();
          User user = await firebaseRepo.getCurrentUser();
          LiveStream liveStream = new LiveStream(
              streamID: channelName,
              streamerName: user.displayName,
              streamerPhoto: user.photoURL,
              userID: user.uid,
              streamerUID: uid);
          FirebaseFirestore.instance
              .collection('livestreams')
              .doc(channelName)
              .set(liveStream.toMap());
          setState(() {
            final info = 'onJoinChannel: $channel, uid: $uid';
            _joined = true;
            _infoStrings.add(info);
          });
        },
        leaveChannel: (stats) {
          // setState(() {});
          _infoStrings.add('onLeaveChannel');
          _users.clear();
        },
        userJoined: (uid, elapsed) {
          setState(() {
            final info = 'userJoined: $uid';
            _infoStrings.add(info);
            _users.add(uid);
            FirebaseFirestore.instance
                .collection('livestreams')
                .doc(channelName)
                .update({"viewer_count": _users.length});
          });
        },
        userOffline: (uid, elapsed) {
          setState(() {
            final info = 'userOffline: $uid';
            _infoStrings.add(info);
            _users.remove(uid);
            FirebaseFirestore.instance
                .collection('livestreams')
                .doc(channelName)
                .update({"viewer_count": _users.length});
          });
        },
        firstRemoteVideoFrame: (uid, width, height, elapsed) {
          setState(() {
            final info = 'firstRemoteVideo: $uid ${width}x $height';
            _infoStrings.add(info);
          });
        },
      ),
    );
  }

  /// Helper function to get list of native views
  // List<Widget> _getRenderViews() {
  //   final List<StatefulWidget> list = [];
  //   if (role == ClientRole.Broadcaster) {
  //     list.add(RtcLocalView.SurfaceView());
  //   }
  //   // _users.forEach((int uid) => list.add(RtcRemoteView.SurfaceView(uid: uid)));
  //   return list;
  // }

  /// Video view wrapper
  // Widget _videoView(view) {
  //   return Expanded(child: Container(child: view));
  // }

  /// Video view row wrapper
  // Widget _expandedVideoRow(List<Widget> views) {
  //   final wrappedViews = views.map<Widget>(_videoView).toList();
  //   return Expanded(
  //     child: Row(
  //       children: wrappedViews,
  //     ),
  //   );
  // }

  /// Video layout wrapper
  // Widget _viewRows() {
  // return Container(
  //   child: RtcLocalView.SurfaceView(),
  // );
  // final views = _getRenderViews();
  // print('faskdjfalskdjflas');
  // print(views);
  // switch (views.length) {
  //   case 1:
  //     return Container(
  //         child: Column(
  //       children: <Widget>[_videoView(RtcLocalView.SurfaceView())],
  //     ));
  //   case 2:
  //     return Container(
  //         child: Column(
  //       children: <Widget>[
  //         _expandedVideoRow([views[0]]),
  //         _expandedVideoRow([views[1]])
  //       ],
  //     ));
  //   case 3:
  //     return Container(
  //         child: Column(
  //       children: <Widget>[
  //         _expandedVideoRow(views.sublist(0, 2)),
  //         _expandedVideoRow(views.sublist(2, 3))
  //       ],
  //     ));
  //   case 4:
  //     return Container(
  //         child: Column(
  //       children: <Widget>[
  //         _expandedVideoRow(views.sublist(0, 2)),
  //         _expandedVideoRow(views.sublist(2, 4))
  //       ],
  //     ));
  //   default:
  // }
  // return Container();
  // }

  /// Toolbar layout
  Widget _toolbar() {
    // if (role == ClientRole.Audience) return Container();
    return Container(
      alignment: Alignment.bottomRight,
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          RawMaterialButton(
            onPressed: _onToggleMute,
            child: Icon(
              muted ? Icons.mic_off : Icons.mic,
              color: muted ? Colors.white : Colors.blueAccent,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: muted ? Colors.blueAccent : Colors.white,
            padding: const EdgeInsets.all(12.0),
          ),
          SizedBox(height: 18),
          RawMaterialButton(
            onPressed: _onSwitchCamera,
            child: Icon(
              Icons.switch_camera,
              color: Colors.blueAccent,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.white,
            padding: const EdgeInsets.all(12.0),
          ),
          SizedBox(height: 25),
          RawMaterialButton(
            onPressed: () => _onCallEnd(context),
            child: Icon(
              Icons.call_end,
              color: Colors.white,
              size: 25.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.redAccent,
            padding: const EdgeInsets.all(15.0),
          )
        ],
      ),
    );
  }

  /// Info panel to show logs
  Widget _panel() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48),
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(
        heightFactor: 0.5,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: ListView.builder(
            reverse: true,
            itemCount: _infoStrings.length,
            itemBuilder: (BuildContext context, int index) {
              if (_infoStrings.isEmpty) {
                return null;
              }
              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 3,
                  horizontal: 10,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 2,
                          horizontal: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black38,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          _infoStrings[index],
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _onCallEnd(BuildContext context) {
    FirebaseFirestore.instance
        .collection('livestreams')
        .doc(channelName)
        .delete();
    Navigator.pop(context);
  }

  void _onToggleMute() {
    setState(() {
      muted = !muted;
    });
    _engine.muteLocalAudioStream(muted);
  }

  void _onSwitchCamera() {
    _engine.switchCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Stack(
            children: <Widget>[
              Container(
                child: RtcLocalView.SurfaceView(),
              ),
              _panel(),
              Container(
                alignment: Alignment.center,
                color: Colors.black54,
                child: Center(
                  child: Text(
                    _joined
                        ? 'You are currently streaming'
                        : 'Starting your stream...',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              _toolbar(),
              _minePanel(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _minePanel() {
    return Container(
      padding: EdgeInsets.all(5),
      alignment: Alignment.topLeft,
      child: Row(
        children: [
          Icon(
            Icons.visibility_sharp,
            color: Colors.white,
          ),
          SizedBox(width: 6),
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('livestreams')
                .doc(channelName)
                .snapshots(),
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.hasData && snapshot.data.data() != null) {
                print('our data');
                print(snapshot.data.data());
                return Text(
                  LiveStream.fromJSON(snapshot.data.data())
                      .viewerCount
                      .toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                );
              }
              return Text(
                _users.length.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
