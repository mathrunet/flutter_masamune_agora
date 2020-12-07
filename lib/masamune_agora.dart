// Copyright 2020 mathru. All rights reserved.

/// Masamune agora framework library.
///
/// To use, import `package:masamune_agora/masamune_agora.dart`.
///
/// [mathru.net]: https://mathru.net
/// [YouTube]: https://www.youtube.com/c/mathrunetchannel
library masamune.agora;

import 'dart:async';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
//import 'package:agora_rtm/agora_rtm.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:masamune_flutter/masamune_flutter.dart';
export 'package:masamune_mobile/masamune_mobile.dart';
export 'package:masamune_flutter/masamune_flutter.dart';

part 'agorartc.dart';
part 'agorartcchannel.dart';
// part 'agorartm.dart';
// part 'agorartmchannel.dart';
