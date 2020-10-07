// part of masamune.agora;

// /// Manage Agora RTC.
// ///
// /// You can get [uid] and [name] by executing [initialize()].
// class AgoraRTM extends TaskDocument<DataField>
//     with DataDocumentMixin<DataField>
//     implements ITask, IDataDocument<DataField> {
//   /// Create a Completer that matches the class.
//   ///
//   /// Do not use from external class
//   @override
//   @protected
//   Completer createCompleter() => Completer<AgoraRTM>();

//   /// Process to create a new instance.
//   ///
//   /// Do not use from outside the class.
//   ///
//   /// [path]: Destination path.
//   /// [isTemporary]: True if the data is temporary.
//   @override
//   @protected
//   T createInstance<T extends IClonable>(String path, bool isTemporary) =>
//       AgoraRTM._(path: path) as T;
//   static AgoraRtmClient get _client => __client;
//   static AgoraRtmClient __client;

//   /// The user's name.
//   String get name => this._name;
//   String _name;

//   TemporaryCollection get timeline => this._timeline;
//   TemporaryCollection _timeline = TemporaryCollection();

//   /// Manage Agora RTC.
//   ///
//   /// You can get [uid] and [name] by executing [initialize()].
//   factory AgoraRTM() {
//     AgoraRTM unit = PathMap.get<AgoraRTM>(_systemPath);
//     if (unit != null) return unit;
//     Log.warning(
//         "No data was found from the pathmap. Please execute [initialize()] first.");
//     return null;
//   }

//   /// Manage Agora RTC.
//   ///
//   /// You can get [uid] and [name] by executing [initialize()].
//   ///
//   /// [appId]: Application ID.
//   /// [userName]: USER NAME.
//   /// [timeout]: Timeout setting.
//   static Future<AgoraRTM> initialize(
//       {@required String appId,
//       @required String userName,
//       Duration timeout = Const.timeout}) {
//     assert(isNotEmpty(appId));
//     assert(isNotEmpty(userName));
//     if (isEmpty(appId)) {
//       Log.error("The app id is invalid.");
//       return Future.delayed(Duration.zero);
//     }
//     if (isEmpty(userName)) {
//       Log.error("The user name is invalid.");
//       return Future.delayed(Duration.zero);
//     }
//     AgoraRTM document = PathMap.get<AgoraRTM>(_systemPath);
//     if (document != null) return document.future;
//     document = AgoraRTM._(path: _systemPath);
//     document._initialize(appId: appId, userName: userName, timeout: timeout);
//     return document.future;
//   }

//   static const String _systemPath = "system://agorartm";
//   AgoraRTM._({String path})
//       : super(
//             path: path,
//             children: const [],
//             isTemporary: false,
//             group: -1,
//             order: 10);
//   void _initialize({String userName, String appId, Duration timeout}) async {
//     try {
//       if (_client == null) {
//         __client = await AgoraRtmClient.createInstance(appId).timeout(timeout);
//       }
//       _client.onError = () {
//         this.error("Illegal processing.");
//       };
//       _client.onMessageReceived = (AgoraRtmMessage message, String peerId) {
//         if (message == null || isEmpty(message.text)) return;
//         TemporaryDocument document = TemporaryDocument.fromJson(message.text)
//           ..[Const.id] = peerId;
//         this.timeline.add(document);
//         Log.msg("Message recieved: $peerId, ${message.text}");
//         this.notifyUpdate();
//       };
//       _client.onConnectionStateChanged = (int state, int reason) {
//         Log.msg("Connection state changed: $state, $reason");
//         if (state == 5) this.logout();
//       };
//       await _client.login(null, userName).timeout(timeout);
//       this._name = userName;
//       Map<String, dynamic> data =
//           await _client.getUserAttributes(userName).timeout(timeout);
//       data?.forEach((key, value) => this.setInternal(DataField(key, value)));
//       this.done();
//     } catch (e) {
//       this.error(e.toString());
//     }
//   }

//   void logout() async {
//     if (!this.isDone || _client == null) return;
//     this.dispose();
//   }

//   /// Get the protocol of the path.
//   @override
//   String get protocol => Protocol.system;

//   /// True if the object is temporary data.
//   @override
//   bool get isTemporary => false;

//   /// Destroys the object.
//   ///
//   /// Destroyed objects are not allowed.
//   void dispose() {
//     if (this.isDisposed || !this.isDisposable) return;
//     if (_client != null && this.isDone) _client.logout();
//     super.dispose();
//   }

//   /// Callback event when application quit.
//   @override
//   void onApplicationQuit() {
//     if (_client != null && this.isDone) _client.logout();
//   }

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
//     if (!this.isDone || _client == null) return this as T;
//     if (this.data.length <= 0) return this as T;
//     await _client.setLocalUserAttributes(
//         [this.data.map((key, value) => MapEntry(key, value.data?.toString()))]);
//     return this as T;
//   }

//   Future<AgoraRTM> send(String target, Map<String, String> data) async {
//     if (!this.isDone || isEmpty(target) || _client == null) return this;
//     await _client.sendMessageToPeer(
//         target, AgoraRtmMessage.fromText(Json.encode(data)), false);
//     return this;
//   }

//   /// Delete the data.
//   ///
//   /// Used when deleting data when there is a remote or when data needs to be saved.
//   Future delete() => Future.delayed(Duration.zero);
// }
