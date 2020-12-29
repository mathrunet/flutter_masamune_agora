part of masamune.agora;

/// Manage Agora RTC.
///
/// You can get [uid] and [name] by executing [initialize()].
class AgoraRTC extends TaskUnit implements ITask {
  RtcEngine get _engine => this.__engine;
  RtcEngine __engine;

  /// App ID.
  String get appId => this._appId;
  String _appId;

  /// Customer ID.
  String get customerId => this._customerId;
  String _customerId;
  String _customerSecret;
  AgoraStorageBucketConfig _storageBucketConfig;

  /// Create a Completer that matches the class.
  ///
  /// Do not use from external class
  @override
  @protected
  Completer createCompleter() => Completer<AgoraRTC>();

  /// Process to create a new instance.
  ///
  /// Do not use from outside the class.
  ///
  /// [path]: Destination path.
  /// [isTemporary]: True if the data is temporary.
  @override
  @protected
  T createInstance<T extends IClonable>(String path, bool isTemporary) =>
      AgoraRTC._(path: path) as T;

  /// User UID.
  int get uid => this._uid;
  int _uid;

  /// The user's name.
  String get name => this._name;
  String _name;

  /// Manage Agora RTC.
  ///
  /// You can get [uid] and [name] by executing [initialize()].
  factory AgoraRTC() {
    AgoraRTC unit = PathMap.get<AgoraRTC>(_systemPath);
    if (unit != null) return unit;
    Log.warning(
        "No data was found from the pathmap. Please execute [initialize()] first.");
    return null;
  }

  /// Manage Agora RTC.
  ///
  /// You can get [uid] and [name] by executing [initialize()].
  ///
  /// [appId]: Application ID.
  /// [userName]: USER NAME.
  /// [timeout]: Timeout setting.
  /// [customerId]: Customer ID.
  /// [customerSecret]: Customer Secret.
  static Future<AgoraRTC> initialize(
      {@required String appId,
      @required String userName,
      String customerId,
      String customerSecret,
      Duration timeout = Const.timeout,
      AgoraStorageBucketConfig storageBucketConfig}) {
    assert(isNotEmpty(appId));
    assert(isNotEmpty(userName));
    if (isEmpty(appId)) {
      Log.error("The app id is invalid.");
      return Future.delayed(Duration.zero);
    }
    if (isEmpty(userName)) {
      Log.error("The user name is invalid.");
      return Future.delayed(Duration.zero);
    }
    AgoraRTC unit = PathMap.get<AgoraRTC>(_systemPath);
    if (unit != null) return unit.future;
    unit = AgoraRTC._(path: _systemPath);
    unit._initialize(
        appId: appId,
        userName: userName,
        timeout: timeout,
        customerId: customerId,
        customerSecret: customerSecret,
        storageBucketConfig: storageBucketConfig);
    return unit.future;
  }

  static const String _systemPath = "system://agorartc";
  AgoraRTC._({String path})
      : super(
            path: path, value: null, isTemporary: false, group: -1, order: 10);
  void _initialize(
      {String userName,
      String appId,
      Duration timeout,
      String customerId,
      String customerSecret,
      AgoraStorageBucketConfig storageBucketConfig}) async {
    try {
      this.__engine = await RtcEngine.create(appId).timeout(timeout);
      this._engine.setEventHandler(
          RtcEngineEventHandler(localUserRegistered: (uid, name) {
        this._name = name;
        this._uid = uid;
        this.done();
      }));
      this._engine.registerLocalUserAccount(appId, userName).timeout(timeout);
      this._appId = appId;
      this._customerId = customerId;
      this._customerSecret = customerSecret;
      this._storageBucketConfig = storageBucketConfig;
    } catch (e) {
      this.error(e.toString());
    }
  }

  /// Get the protocol of the path.
  @override
  String get protocol => Protocol.system;

  /// True if the object is temporary data.
  @override
  bool get isTemporary => false;

  /// Destroys the object.
  ///
  /// Destroyed objects are not allowed.
  void dispose() {
    if (this.isDisposed || !this.isDisposable) return;
    super.dispose();
    this._engine.destroy();
  }

  /// Callback event when application quit.
  @override
  void onApplicationQuit() {
    this._engine.destroy();
  }
}
