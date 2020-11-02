import 'package:agora_livestream/models/livestream.dart';
import 'package:agora_livestream/repositories/livestream_repository.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;

class WatchStreamScreen extends StatefulWidget {
  final LiveStream liveStream;
  WatchStreamScreen({Key key, @required this.liveStream}) : super(key: key);

  @override
  _WatchStreamScreenState createState() => _WatchStreamScreenState();
}

class _WatchStreamScreenState extends State<WatchStreamScreen> {
  @override
  final ClientRole role = ClientRole.Audience;

  RtcEngine _engine;
  final _users = <int>[];
  final _infoStrings = <String>['fasdfasd'];

  @override
  void dispose() {
    _engine.leaveChannel();
    _engine.destroy();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    await _initAgoraRtcEngine();
    _addAgoraEventHandlers();
// VideoEncoderConfiguration configuration = VideoEncoderConfiguration();
//     configuration.dimensions = VideoDimensions(1920, 1080);
//     await _engine.setVideoEncoderConfiguration(configuration);
    await _engine.joinChannel(null, widget.liveStream.streamID, null, 0);
  }

  Future<void> _initAgoraRtcEngine() async {
    _engine = await RtcEngine.create(APP_ID);

    // TODO comment out
    await _engine.enableVideo();
    await _engine.enableLocalAudio(false);
    await _engine.enableLocalVideo(false);
    await _engine.muteLocalAudioStream(true);
    // await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await _engine.setClientRole(role);
  }

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
          setState(() {
            final info = 'onJoinChannel: $channel, uid: $uid';
            _infoStrings.add(info);
            _users.add(uid);
          });
        },
        leaveChannel: (stats) {
          setState(() {
            _infoStrings.add('onLeaveChannel');
            _users.clear();
          });
        },
        userOffline: (uid, elapsed) {
          setState(() {
            final info = 'userOffline: $uid';
            _infoStrings.add(info);
            _users.remove(uid);
            if (uid == widget.liveStream.streamerUID) {
              Navigator.pop(context);
            }
          });
        },
        userJoined: (uid, elapsed) {
          print('a user joined');
          final info = 'userJoined: $uid';
          _infoStrings.add(info);
          setState(() {
            _users.add(uid);
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Center(
            child: Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: Container(
                          child: RtcRemoteView.SurfaceView(
                              uid: widget.liveStream.streamerUID)),
                    ),
                    // Expanded(
                    //   child: Container(
                    //     child: RtcLocalView.SurfaceView(),
                    //   ),
                    // )
                  ],
                ),
                _panel(),
                _minePanel(),
                _toolbar()
              ],
            ),
          ),
        ));
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

  Widget _toolbar() {
    return Container(
        alignment: Alignment.bottomLeft,
        padding: const EdgeInsets.all(28),
        child: RaisedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('END'),
        ));
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
                .doc(widget.liveStream.streamID)
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
