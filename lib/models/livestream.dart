class LiveStream {
  String streamID;
  String userID;
  String streamerName;
  String streamerPhoto;
  int viewerCount = 0;
  int streamerUID = 0;

  LiveStream(
      {this.streamID,
      this.userID,
      this.streamerName,
      this.streamerPhoto,
      this.streamerUID});
  Map<String, dynamic> toMap() {
    var data = Map<String, dynamic>();
    data['stream_id'] = this.streamID;
    data['user_id'] = this.userID;
    data['streamer_name'] = this.streamerName;
    data['streamer_photo'] = this.streamerPhoto;
    data['viewer_count'] = this.viewerCount;
    data['streamer_uid'] = this.streamerUID;
    return data;
  }

  LiveStream.fromJSON(Map<String, dynamic> data) {
    this.streamID = data['stream_id'];
    this.userID = data['user_id'];
    this.streamerName = data['streamer_name'];
    this.streamerPhoto = data['streamer_photo'];
    this.viewerCount = data['viewer_count'] ?? 0;
    this.streamerUID = data['streamer_uid'] ?? 0;
  }
}
