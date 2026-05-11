import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

const appId = "dfa6ae43ad674eaeb010c099f6cd1bc8";
const token = "007eJxTYJCc1LdM7l70sV12PbFbn7krvjp/qIL7d+7bLY+f6zaesdFXYEhJSzRLTDUxTkwxMzdJTUxNMjA0SDawtEwzS04xTEq2WLbnYWZDICPDvdeZjIwMEAjiczMk52TmZSbHF+Xn5zIwAABJpSaf";

class CallPage extends StatefulWidget {
  final String channelName;
  const CallPage({super.key, required this.channelName});

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  int? _remoteUid;
  bool _localUserJoined = false;
  bool _muted = false;
  late RtcEngine _engine;

  @override
  void initState() {
    super.initState();
    initAgora();
  }

  Future<void> initAgora() async {
    await [Permission.microphone, Permission.camera].request();

    _engine = createAgoraRtcEngine();
    await _engine.initialize(const RtcEngineContext(
      appId: appId,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    ));

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          setState(() {
            _localUserJoined = true;
          });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          setState(() {
            _remoteUid = remoteUid;
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          setState(() {
            _remoteUid = null;
          });
        },
      ),
    );

    await _engine.enableVideo();
    await _engine.startPreview();

    await _engine.joinChannel(
      token: token,
      channelId: widget.channelName,
      uid: 0,
      options: const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        publishCameraTrack: true,
        publishMicrophoneTrack: true,
      ),
    );
  }

  @override
  void dispose() {
    _dispose();
    super.dispose();
  }

  Future<void> _dispose() async {
    await _engine.leaveChannel();
    await _engine.release();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F1F2E),
      body: Stack(
        children: [
          Center(child: _remoteVideo()),
          Positioned(
            right: 20.w,
            top: 50.h,
            child: Container(
              width: 110.w,
              height: 160.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: Colors.white24, width: 2),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18.r),
                child: _localUserJoined
                    ? AgoraVideoView(
                        controller: VideoViewController(
                          rtcEngine: _engine,
                          canvas: const VideoCanvas(uid: 0),
                        ),
                      )
                    : const Center(child: CircularProgressIndicator(color: Colors.white)),
              ),
            ),
          ),
          _toolbar(),
        ],
      ),
    );
  }

  Widget _remoteVideo() {
    if (_remoteUid != null) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: _engine,
          canvas: VideoCanvas(uid: _remoteUid),
          connection: RtcConnection(channelId: widget.channelName),
        ),
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Color(0xFF2D6CDF)),
          SizedBox(height: 20.h),
          Text(
            'Waiting for user to join...',
            style: TextStyle(color: Colors.white70, fontSize: 15.sp, fontWeight: FontWeight.w500),
          ),
        ],
      );
    }
  }

  Widget _toolbar() {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: EdgeInsets.only(bottom: 40.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _actionButton(
            icon: _muted ? Icons.mic_off : Icons.mic,
            color: _muted ? Colors.redAccent : Colors.white24,
            onTap: () {
              setState(() => _muted = !_muted);
              _engine.muteLocalAudioStream(_muted);
            },
          ),
          SizedBox(width: 20.w),
          _actionButton(
            icon: Icons.call_end,
            color: Colors.red,
            isEnd: true,
            onTap: () => context.pop(),
          ),
          SizedBox(width: 20.w),
          _actionButton(
            icon: Icons.switch_camera,
            color: Colors.white24,
            onTap: () => _engine.switchCamera(),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({required IconData icon, required Color color, required VoidCallback onTap, bool isEnd = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isEnd ? 18.r : 12.r),
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: isEnd ? 32.sp : 24.sp),
      ),
    );
  }
}
