// part of masamune.agora;

// /// Class for using the real time communication function of Agora.
// ///
// /// First, [AgoraRTM.initialize()] must be executed.
// ///
// /// You can join a room by executing [connect()] with a path.
// /// At that time, it is possible to specify the settings for live streaming distribution and
// /// the presence or absence of audio and video.
// ///
// /// Members who are in the room including yourself are displayed in the collection.
// ///
// /// Finally, leave the room by executing [disconnect()].
// class AgoraRTMChannel extends TaskDocument<DataField>
//     with DataDocumentMixin<DataField>
//     implements ITask, IDataDocument<DataField> {
//   /// Create a Completer that matches the class.
//   ///
//   /// Do not use from external class
//   @override
//   @protected
//   Completer createCompleter() => Completer<AgoraRTMChannel>();

//   /// Process to create a new instance.
//   ///
//   /// Do not use from outside the class.
//   ///
//   /// [path]: Destination path.
//   /// [isTemporary]: True if the data is temporary.
//   @override
//   @protected
//   T createInstance<T extends IClonable>(String path, bool isTemporary) =>
//       AgoraRTMChannel._(path: path) as T;
//   static AgoraRTM get _app {
//     if (__app == null) __app = AgoraRTM();
//     return __app;
//   }

//   static AgoraRTM __app;
//   AgoraRtmChannel get _channel {
//     return this.__channel;
//   }

//   AgoraRtmChannel __channel;

//   TemporaryCollection get timeline => this._timeline;
//   TemporaryCollection _timeline = TemporaryCollection();

//   TemporaryCollection get member => this._member;
//   TemporaryCollection _member = TemporaryCollection();

//   /// Class for using the real time communication function of Agora.
//   ///
//   /// First, [AgoraRTM.initialize()] must be executed.
//   ///
//   /// You can join a room by executing [connect()] with a path.
//   /// At that time, it is possible to specify the settings for live streaming distribution and
//   /// the presence or absence of audio and video.
//   ///
//   /// Members who are in the room including yourself are displayed in the collection.
//   ///
//   /// Finally, leave the room by executing [disconnect()].
//   ///
//   /// [path]: Room pass.
//   factory AgoraRTMChannel(String path) {
//     path = path?.applyTags();
//     assert(isNotEmpty(path));
//     if (isEmpty(path)) {
//       Log.error("The path is invalid.");
//       return null;
//     }
//     AgoraRTMChannel collection = PathMap.get<AgoraRTMChannel>(path);
//     if (collection != null) return collection;
//     Log.warning(
//         "No data was found from the pathmap. Please execute [connect()] first.");
//     return null;
//   }

//   /// Class for using the real time communication function of Agora.
//   ///
//   /// First, [AgoraRTM.initialize()] must be executed.
//   ///
//   /// You can join a room by executing [connect()] with a path.
//   /// At that time, it is possible to specify the settings for live streaming distribution and
//   /// the presence or absence of audio and video.
//   ///
//   /// Members who are in the room including yourself are displayed in the collection.
//   ///
//   /// Finally, leave the room by executing [disconnect()].
//   ///
//   /// [path]: Room pass.
//   /// [appId]: Application ID.
//   /// Enter to perform initialization processing if it has not been initialized.
//   /// [userName]: USER NAME.
//   /// [timeout]: Timeout setting.
//   static Future<AgoraRTMChannel> connect(String path,
//       {String appId, String userName, Duration timeout = Const.timeout}) {
//     path = path?.applyTags();
//     assert(isNotEmpty(path));
//     if (isEmpty(path)) {
//       Log.error("The path is invalid.");
//       return Future.delayed(Duration.zero);
//     }
//     AgoraRTMChannel document = PathMap.get<AgoraRTMChannel>(path);
//     if (document != null) {
//       return document.future;
//     }
//     document = AgoraRTMChannel._(
//       path: path,
//     );
//     document._joinRoom(appId: appId, userId: userName, timeout: timeout);
//     return document.future;
//   }

//   AgoraRTMChannel._({String path})
//       : super(
//             path: path,
//             children: const [],
//             isTemporary: false,
//             order: 10,
//             group: 0);
//   void _joinRoom({
//     String userId,
//     String appId,
//     Duration timeout,
//   }) async {
//     try {
//       if (_app == null) {
//         __app = await AgoraRTM.initialize(
//             appId: appId, userName: userId, timeout: timeout);
//       }
//       if (this._channel == null) {
//         this.__channel = await AgoraRTM._client
//             ?.createChannel(
//                 this.path.replaceAll(RegExp(r"[^0-9a-zA-Z]"), Const.empty))
//             ?.timeout(timeout);
//       }
//       this._channel.onError = (error) {
//         this.error("Illegal processing: ${error.toString()}");
//       };
//       this._channel.onMemberJoined = (AgoraRtmMember member) {
//         if (this.member.any((element) => element?.uid == member.userId)) return;
//         TemporaryDocument data =
//             TemporaryDocument.fromMap({Const.uid: member.userId});
//         this.member.add(data);
//         Log.msg("Member joined: ${member.userId}");
//       };
//       this._channel.onMemberCountUpdated = (count) {};
//       this._channel.onMemberLeft = (AgoraRtmMember member) {
//         if (!this.member.any((element) => element?.uid == member.userId))
//           return;
//         this.member.removeWhere((element) => element?.uid == member.userId);
//         Log.msg("Member left: ${member.userId}");
//       };
//       this._channel.onMessageReceived =
//           (AgoraRtmMessage message, AgoraRtmMember member) {
//         if (message == null || isEmpty(message.text)) return;
//         TemporaryDocument document = TemporaryDocument.fromJson(message.text)
//           ..[Const.id] = member.userId;
//         this.timeline.add(document);
//         Log.msg("Message recieved: ${member.userId}, ${message.text}");
//       };
//       this._channel.onAttributesUpdated = (data) {
//         data?.forEach((value) {
//           if (isEmpty(value.userId)) {
//             this.setInternal(DataField(value.key, value.value));
//           } else {
//             TemporaryDocument document = this
//                 .member
//                 .firstWhere((element) => element?.uid == value.userId);
//             if (document == null) return;
//             document[value.key] = value.value;
//           }
//         });
//       };
//       await this._channel.join();
//       List<AgoraRtmMember> member =
//           await this._channel.getMembers().timeout(timeout);
//       member?.forEach((element) {
//         if (this.member.containsID(element.userId)) return;
//         TemporaryDocument data =
//             TemporaryDocument.fromMap({Const.uid: element.userId});
//         this.member.add(data);
//         Log.msg("Member joined: ${element.userId}");
//       });
//       List<AgoraRtmChannelAttribute> data = await AgoraRTM._client
//           .getChannelAttributes(this._channel.channelId)
//           .timeout(timeout);
//       data?.forEach((value) {
//         if (isEmpty(value.userId)) {
//           this.setInternal(DataField(value.key, value.value));
//         } else {
//           TemporaryDocument document =
//               this.member.firstWhere((element) => element?.uid == value.userId);
//           if (document == null) return;
//           document[value.key] = value.value;
//         }
//       });
//       this.done();
//     } catch (e) {
//       this.error(e.toString());
//     }
//   }

//   /// Disconnect from the room.
//   Future disconnect() async {
//     if (!this.isDone || this._channel == null) return;
//     this.init();
//     await this._channel.leave();
//     this.done();
//   }

//   Future close() async {
//     if (!this.isDone || this._channel == null) return;
//     this.init();
//     await this._channel.close();
//     this.done();
//   }

//   /// Get the protocol of the path.
//   @override
//   String get protocol => "agora";

//   /// True if the object is temporary data.
//   @override
//   bool get isTemporary => false;

//   /// Create a new field.
//   ///
//   /// [path]: Field path.
//   /// [value]: Field value.
//   @override
//   DataField createField([String path, value]) => DataField(path, value);

//   /// Save the data.
//   ///
//   /// Run if you have a remote or need to save data.
//   @override
//   Future<T> save<T extends IDataDocument>() async {
//     if (!this.isDone || this._channel == null) return this as T;
//     if (this.data.length <= 0) return this as T;
//     List<AgoraRtmChannelAttribute> tmp = ListPool.get();
//     for (MapEntry<String, DataField> item in this.data.entries) {
//       tmp.add(AgoraRtmChannelAttribute(item.key, item.value.data.toString()));
//     }
//     for (TemporaryDocument doc in this.member) {
//       if (doc == null || isEmpty(doc.uid)) continue;
//       for (MapEntry<String, TemporaryField> item in doc.entries) {
//         if (item == null) continue;
//         tmp.add(AgoraRtmChannelAttribute(item.key, item.value.data.toString(),
//             userId: doc.uid));
//       }
//     }
//     await AgoraRTM._client
//         .setChannelAttributes(this._channel.channelId, tmp, true);
//     return this as T;
//   }

//   Future<AgoraRTMChannel> send(Map<String, String> data) async {
//     if (!this.isDone || this._channel == null) return this;
//     await this
//         ._channel
//         .sendMessage(AgoraRtmMessage.fromText(Json.encode(data)));
//     return this;
//   }

//   /// Destroys the object.
//   ///
//   /// Destroyed objects are not allowed.
//   void dispose() {
//     if (this.isDisposed || !this.isDisposable) return;
//     super.dispose();
//     if (this._channel != null && this.isDone) this._channel.leave();
//   }

//   /// Callback event when application quit.
//   @override
//   void onApplicationQuit() {
//     if (this._channel == null || !this.isDone) return;
//     this._channel.leave();
//   }
// }
