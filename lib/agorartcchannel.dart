part of masamune.agora;

/// Class for using the real time communication function of Agora.
///
/// First, [AgoraRTC.initialize()] must be executed.
///
/// You can join a room by executing [connect()] with a path.
/// At that time, it is possible to specify the settings for live streaming distribution and
/// the presence or absence of audio and video.
///
/// Members who are in the room including yourself are displayed in the collection.
///
/// Finally, leave the room by executing [disconnect()].
class AgoraRTCChannel extends TaskCollection<DataDocument> implements ITask {
  DataDocument Function(DataDocument userInfo) _filter;

  /// Create a Completer that matches the class.
  ///
  /// Do not use from external class
  @override
  @protected
  Completer createCompleter() => Completer<AgoraRTCChannel>();

  /// Process to create a new instance.
  ///
  /// Do not use from outside the class.
  ///
  /// [path]: Destination path.
  /// [isTemporary]: True if the data is temporary.
  @override
  @protected
  T createInstance<T extends IClonable>(String path, bool isTemporary) =>
      AgoraRTCChannel._(path: path) as T;
  static AgoraRTC get _app {
    if (__app == null) __app = AgoraRTC();
    return __app;
  }

  static AgoraRTC __app;

  /// Class for using the real time communication function of Agora.
  ///
  /// First, [AgoraRTC.initialize()] must be executed.
  ///
  /// You can join a room by executing [connect()] with a path.
  /// At that time, it is possible to specify the settings for live streaming distribution and
  /// the presence or absence of audio and video.
  ///
  /// Members who are in the room including yourself are displayed in the collection.
  ///
  /// Finally, leave the room by executing [disconnect()].
  ///
  /// [path]: Room pass.
  factory AgoraRTCChannel(String path) {
    path = path?.applyTags();
    assert(isNotEmpty(path));
    if (isEmpty(path)) {
      Log.error("The path is invalid.");
      return null;
    }
    AgoraRTCChannel collection = PathMap.get<AgoraRTCChannel>(path);
    if (collection != null) return collection;
    Log.warning(
        "No data was found from the pathmap. Please execute [connect()] first.");
    return null;
  }

  /// Class for using the real time communication function of Agora.
  ///
  /// First, [AgoraRTC.initialize()] must be executed.
  ///
  /// You can join a room by executing [connect()] with a path.
  /// At that time, it is possible to specify the settings for live streaming distribution and
  /// the presence or absence of audio and video.
  ///
  /// Members who are in the room including yourself are displayed in the collection.
  ///
  /// Finally, leave the room by executing [disconnect()].
  ///
  /// [path]: Room pass.
  /// [appId]: Application ID.
  /// Enter to perform initialization processing if it has not been initialized.
  /// [userName]: USER NAME.
  /// [width]: The width of the screen to send to the remote.
  /// [height]: The height of the screen to send to the remote.
  /// [frameRate]: The frame rate of the screen sent to the remote.
  /// [bitRate]: The bit rate of the screen sent to the remote.
  /// [enableAudio]: True to enable audio.
  /// [enableVideo]: True to enable video.
  /// [channelProfile]: Channel profile settings.
  /// [clientRole]: Client role settings.
  /// [timeout]: Timeout setting.
  /// [orientationMode]: Orientation mode.
  /// [filter]: Callback for filtering user data.
  static Future<AgoraRTCChannel> connect(String path,
      {String appId,
      String userName,
      int width = 1280,
      int height = 720,
      VideoFrameRate frameRate = VideoFrameRate.Fps24,
      int bitRate = 0,
      bool enableAudio = true,
      bool enableVideo = true,
      ChannelProfile channelProfile = ChannelProfile.LiveBroadcasting,
      ClientRole clientRole = ClientRole.Broadcaster,
      VideoOutputOrientationMode orientationMode =
          VideoOutputOrientationMode.FixedPortrait,
      Duration timeout = Const.timeout,
      DataDocument Function(DataDocument userInfo) filter}) {
    path = path?.applyTags();
    assert(isNotEmpty(path));
    if (isEmpty(path)) {
      Log.error("The path is invalid.");
      return Future.delayed(Duration.zero);
    }
    AgoraRTCChannel collection = PathMap.get<AgoraRTCChannel>(path);
    if (collection != null) {
      collection._width = width;
      collection._height = height;
      collection._bitRate = bitRate;
      collection._frameRate = frameRate;
      collection._enableAudio = enableAudio;
      collection._enableVideo = enableVideo;
      collection._channelProfile = channelProfile;
      collection._clientRole = clientRole;
      if (filter != null) collection._filter = filter;
      return collection.future;
    }
    collection = AgoraRTCChannel._(
        path: path,
        width: width,
        height: height,
        frameRate: frameRate,
        bitRate: bitRate,
        enableAudio: enableAudio,
        enableVideo: enableVideo,
        orientationMode: orientationMode,
        channelProfile: channelProfile,
        clientRole: clientRole,
        filter: filter);
    collection._joinRoom(appId: appId, userId: userName, timeout: timeout);
    return collection.future;
  }

  /// Close the connection.
  ///
  /// [path]: The path to disconnect.
  static Future disconnect(String path) async {
    path = path?.applyTags();
    assert(isNotEmpty(path));
    if (isEmpty(path)) {
      Log.error("The path is invalid.");
      return;
    }
    AgoraRTCChannel unit = AgoraRTCChannel(path);
    if (unit == null) return;
    await unit._disconnectIntenal();
  }

  Future _disconnectIntenal() async {
    if (!this.isDone) return;
    this.init();
    await _app._engine.leaveChannel();
    this.done();
  }

  AgoraRTCChannel._(
      {String path,
      int width,
      int height,
      VideoFrameRate frameRate,
      int bitRate,
      bool enableAudio,
      bool enableVideo,
      ChannelProfile channelProfile,
      ClientRole clientRole,
      VideoOutputOrientationMode orientationMode,
      DataDocument Function(DataDocument userInfo) filter})
      : this._width = width,
        this._height = height,
        this._bitRate = bitRate,
        this._orientationMode = orientationMode,
        this._frameRate = frameRate,
        this._enableAudio = enableAudio,
        this._enableVideo = enableVideo,
        this._channelProfile = channelProfile,
        this._clientRole = clientRole,
        this._filter = filter,
        super(
            path: path,
            children: const [],
            isTemporary: false,
            order: 10,
            group: 0);
  void _joinRoom({String userId, String appId, Duration timeout}) async {
    try {
      if (_app == null) {
        __app = await AgoraRTC.initialize(
            appId: appId, userName: userId, timeout: timeout);
      }
      if (_app._engine == null) {
        this.error(
            "The engine is not initialized. Initialize the engine first.");
        return;
      }
      if (this.enableVideo) {
        PermissionStatus status = await Permission.camera.status;
        if (status == PermissionStatus.denied) {
          await Permission.camera.request();
          status = await Permission.camera.status;
          if (status != PermissionStatus.granted) {
            this.error("You are not authorized to use the camera service. "
                    "Check the permission settings."
                .localize());
            return;
          }
        }
      }
      if (this.enableAudio) {
        PermissionStatus status = await Permission.microphone.status;
        if (status == PermissionStatus.denied) {
          await Permission.microphone.request();
          status = await Permission.microphone.status;
          if (status != PermissionStatus.granted) {
            this.error("You are not authorized to use the microphone service. "
                    "Check the permission settings."
                .localize());
            return;
          }
        }
      }
      _app._engine.setEventHandler(
        RtcEngineEventHandler(
          error: (err) {
            this.error("Error: ${err.toString()}");
            this.dispose();
          },
          userInfoUpdated: (uid, info) {
            if (info == null) return;
            String id = uid.toString();
            if (!this.containsID(id)) return;
            DataDocument data = this.data[id];
            if (data == null) return;
            data[Const.name] = info.userAccount;
            if (this._filter != null) this.data[id] = this._filter(data);
            Log.msg("Update user information: $uid, ${info.userAccount}");
            this.notifyUpdate();
          },
          joinChannelSuccess: (channel, uid, elapsed) {
            String id = uid.toString();
            if (!this.containsID(id)) {
              DataDocument data = DataDocument.fromMap(
                  Paths.child(this.path, id),
                  {Const.uid: uid, Const.local: true});
              if (this._filter != null) data = this._filter(data);
              this.add(data);
            }
            Log.msg("Joined the channel: $uid, $channel");
            this.done();
          },
          remoteVideoStateChanged: (uid, state, reason, elapsed) {
            DataDocument data = this.firstWhere(
                (value) => value.getInt(Const.uid) == uid,
                orElse: () => null);
            if (data == null) return;
            data["video"] = state == VideoRemoteState.Stopped ||
                    state == VideoRemoteState.Failed ||
                    state == VideoRemoteState.Frozen
                ? false
                : true;
            this.notifyUpdate();
          },
          userJoined: (uid, elapsed) {
            String id = uid.toString();
            if (this.containsID(id)) return;
            DataDocument data = DataDocument.fromMap(Paths.child(this.path, id),
                {Const.uid: uid, Const.local: false});
            if (this._filter != null) data = this._filter(data);
            this.add(data);
            Log.msg("The user has joined: $uid");
            this.notifyUpdate();
          },
          userOffline: (uid, reason) {
            String id = uid.toString();
            if (!this.containsID(id)) return;
            this.removeBy(id);
            Log.msg("The user has left: $uid");
            this.notifyUpdate();
          },
          leaveChannel: (stats) {
            Log.msg("Left the channel.");
            this.dispose();
          },
          firstRemoteVideoFrame: (
            uid,
            width,
            height,
            elapsed,
          ) {
            Log.msg("First remote video received: $uid, ($width x $height)");
          },
        ),
      );
      if (this.enableAudio)
        await _app._engine.enableAudio().timeout(timeout);
      else
        await _app._engine.disableAudio().timeout(timeout);
      if (this.enableVideo)
        await _app._engine.enableVideo().timeout(timeout);
      else
        await _app._engine.disableVideo().timeout(timeout);
      VideoEncoderConfiguration videoConfig = VideoEncoderConfiguration();
      videoConfig.orientationMode = this.orientationMode;
      videoConfig.dimensions = VideoDimensions(this.width, this.height);
      videoConfig.frameRate = this.frameRate;
      videoConfig.bitrate = this.bitRate;
      await _app._engine
          .setVideoEncoderConfiguration(videoConfig)
          .timeout(timeout);
      await _app._engine.enableDualStreamMode(true).timeout(timeout);
      await _app._engine
          .setRemoteDefaultVideoStreamType(VideoStreamType.High)
          .timeout(timeout);
      await _app._engine
          .setChannelProfile(this.channelProfile)
          .timeout(timeout);
      if (this.channelProfile == ChannelProfile.LiveBroadcasting)
        await _app._engine.setClientRole(this.clientRole).timeout(timeout);
      // await AgoraRtcEngine.setParameters(
      //         '''{\"che.video.lowBitRateStreamParameter\":{\"width\":${this.width},'''
      //         '''\"height\":${this.height},\"frameRate\":${this.frameRate},'''
      //         '''\"bitRate\":${this.bitRate}}}''')
      //     .timeout(timeout);
      await _app._engine
          .joinChannelWithUserAccount(
              "",
              this.path.replaceAll(RegExp(r"[^0-9a-zA-Z]"), Const.empty),
              _app._name)
          .timeout(timeout);
    } catch (e) {
      this.error(e.toString());
    }
  }

  /// Start recording audio.
  ///
  /// [filePath]: Path to save the recording.
  /// [sampleRate]: Sample rate to be recorded.
  /// [quality]: Quality to record.
  Future startAudioRecording(String filePath,
      {AudioSampleRateType sampleRate = AudioSampleRateType.Type44100,
      AudioRecordingQuality quality = AudioRecordingQuality.Medium}) async {
    if (this._isRecordingAudio) return;
    this._isRecordingAudio = true;
    await _app._engine.startAudioRecording(filePath, sampleRate, quality);
  }

  /// Stop Recording.
  Future stopAudioRecording() async {
    if (!this._isRecordingAudio) return;
    this._isRecordingAudio = false;
    await _app._engine.stopAudioRecording();
  }

  bool _isRecordingAudio = false;

  /// Gets the current local screen as a widget.
  Widget localScreen() {
    if (!this.isDone) return Container();
    return RtcLocalView.SurfaceView();
  }

  /// Get all screens as widgets, including remote locals.
  List<Widget> allScreens() {
    if (!this.isDone) return const [];
    return this.data.toList<Widget>((key, value) {
      int uid = value.getInt(Const.uid);
      if (!value.getBool("video", true)) {
        return Container(
            color: Colors.black,
            alignment: Alignment.center,
            child: Icon(Icons.videocam_off, color: Colors.grey, size: 48));
      }
      if (this.localUID == uid) {
        if (this.channelProfile == ChannelProfile.LiveBroadcasting &&
            this.clientRole == ClientRole.Audience) return null;
        return RtcLocalView.SurfaceView();
      }
      return RtcRemoteView.SurfaceView(uid: uid);
    }).removeEmpty();
  }

  /// The name of the local account.
  String get localName => _app.name;

  /// The uid of the local account.
  int get localUID => _app.uid;

  /// The width of the screen to send to the remote.
  int get width => this._width;
  int _width = 320;

  /// The height of the screen to send to the remote.
  int get height => this._height;
  int _height = 180;

  /// The frame rate of the screen sent to the remote.
  VideoFrameRate get frameRate => this._frameRate;
  VideoFrameRate _frameRate = VideoFrameRate.Fps15;

  /// The bit rate of the screen sent to the remote.
  int get bitRate => this._bitRate;
  int _bitRate = 150;

  /// Orientation mode.
  VideoOutputOrientationMode get orientationMode => this._orientationMode;
  VideoOutputOrientationMode _orientationMode =
      VideoOutputOrientationMode.Adaptative;

  /// Set the screen
  Future setScreen(int width, int height,
      {VideoFrameRate frameRate, int bitRate}) async {
    this._width = width;
    this._height = height;
    this._frameRate = frameRate ?? this._frameRate;
    this._bitRate = bitRate ?? this._bitRate;
    VideoEncoderConfiguration videoConfig = VideoEncoderConfiguration();
    videoConfig.orientationMode = this.orientationMode;
    videoConfig.dimensions = VideoDimensions(this.width, this.height);
    videoConfig.frameRate = this.frameRate;
    videoConfig.bitrate = this.bitRate;
    await _app._engine.setVideoEncoderConfiguration(videoConfig);
  }

  /// Channel profile settings.
  ChannelProfile get channelProfile => this._channelProfile;
  ChannelProfile _channelProfile = ChannelProfile.Communication;

  /// Client role settings.
  ClientRole get clientRole => this._clientRole;
  ClientRole _clientRole = ClientRole.Broadcaster;

  /// True to enable audio.
  bool get enableAudio => this._enableAudio;

  /// True to enable audio.
  ///
  /// [enableAudio]: True to enable audio.
  set enableAudio(bool enableAudio) {
    if (this._enableAudio == enableAudio) return;
    this._enableAudio = enableAudio;
    if (this._enableAudio)
      _app._engine.enableAudio();
    else
      _app._engine.disableAudio();
    this.notifyUpdate();
  }

  bool _enableAudio = true;

  /// True to enable video.
  bool get enableVideo => this._enableVideo;

  /// True to enable video.
  ///
  /// [enableVideo]: True to enable video.
  set enableVideo(bool enableVideo) {
    if (this._enableVideo == enableVideo) return;
    this._enableVideo = enableVideo;
    if (this._enableVideo)
      _app._engine.enableVideo();
    else
      _app._engine.disableVideo();
    this.notifyUpdate();
  }

  bool _enableVideo = true;

  /// True to mute the call.
  bool get mute => this._mute;

  /// True to mute the call.
  ///
  /// [mute]: True to mute the call.
  set mute(bool mute) {
    if (!this.isDone) return;
    if (mute == this._mute) return;
    this._mute = mute;
    _app._engine.muteAllRemoteAudioStreams(this._mute);
    this.notifyUpdate();
  }

  bool _mute = false;

  /// Switches the camera in / out.
  void switchCamera() {
    if (!this.isDone) return;
    _app._engine.switchCamera();
    this.notifyUpdate();
  }

  /// Get the protocol of the path.
  @override
  String get protocol => "agora";

  /// True if the object is temporary data.
  @override
  bool get isTemporary => false;

  /// Destroys the object.
  ///
  /// Destroyed objects are not allowed.
  void dispose() {
    if (this.isDisposed || !this.isDisposable) return;
    super.dispose();
    _app._engine.leaveChannel();
    _app._engine.setEventHandler(RtcEngineEventHandler());
  }

  /// Get the toolbar as a widget.
  ///
  /// [context]: BuildContext.
  /// [onDisconnect]: Callback on disconnect.
  Widget toolBar(BuildContext context, {VoidAction onDisconnect}) {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RawMaterialButton(
            onPressed: () {
              this.mute = !this.mute;
            },
            child: Icon(
              this.mute ? Icons.mic_off : Icons.mic,
              color: this.mute ? Colors.white : Colors.blueAccent,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: this.mute ? Colors.blueAccent : Colors.white,
            padding: const EdgeInsets.all(12.0),
          ),
          RawMaterialButton(
            onPressed: () {
              _disconnectIntenal();
              if (onDisconnect != null) onDisconnect();
            },
            child: Icon(
              Icons.call_end,
              color: Colors.white,
              size: 35.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.redAccent,
            padding: const EdgeInsets.all(15.0),
          ),
          RawMaterialButton(
            onPressed: switchCamera,
            child: Icon(
              Icons.switch_camera,
              color: Colors.blueAccent,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.white,
            padding: const EdgeInsets.all(12.0),
          )
        ],
      ),
    );
  }

  /// Callback event when application quit.
  @override
  void onApplicationQuit() {
    _app._engine.leaveChannel();
    _app._engine.setEventHandler(RtcEngineEventHandler());
  }
}
