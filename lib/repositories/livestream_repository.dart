import 'package:agora_livestream/models/livestream.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const APP_ID = "";

class LiveStreamRepo {
  final CollectionReference liveStreamCollection =
      FirebaseFirestore.instance.collection('livestreams');

  Future<void> startLiveStream(LiveStream liveStream) async {
    await liveStreamCollection.add(liveStream.toMap());
  }

  Future<void> endLiveStream(LiveStream liveStream) async {
    await liveStreamCollection.doc(liveStream.streamID).delete();
    //   .where('stream_id', isEqualTo: liveStream.streamID)
    //   .get()
    //   .then(
    // (QuerySnapshot value) {
    //   value.docs.forEach(
    //     (doc) {
    //       doc.reference.delete();
    //     },
    //   );
    // },
    // );
  }
}
