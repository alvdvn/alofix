import 'dart:io';

import 'package:base_project/screens/call_stringee/button/circle_button.dart';
import 'package:base_project/screens/call_stringee/button/rounded_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:stringee_flutter_plugin/stringee_flutter_plugin.dart';

class Room extends StatefulWidget {
  late StringeeVideo _video;
  late String _roomToken;

  Room(StringeeClient client, String roomToken) {
    _video = StringeeVideo(client);
    this._roomToken = roomToken;
  }

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return RoomState();
  }
}

class RoomState extends State<Room> {
  late StringeeVideoRoom _room;
  late StringeeVideoTrack _localTrack;
  late StringeeVideoView _localTrackView;
  final Map<String, StringeeVideoTrack> _remoteTracks = {};
  final Map<String, StringeeVideoView> _remoteTrackViews = {};

  late StringeeVideoTrack _shareTrack;

  bool _hasLocalView = false;
  bool _sharingScreen = false;
  bool _isMute = false;
  bool _isVideoEnable = true;

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    widget._video.joinRoom(widget._roomToken).then((value) {
      if (value['status']) {
        _room = value['body']['room'];
        initRoom(value['body']['videoTrackInfos'], value['body']['users']);
      } else {
        clearDataEndDismiss();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget _localView = (_hasLocalView)
        ? _localTrackView
        : const Placeholder(
            color: Colors.transparent,
          );

    Container _bottomContainer =  Container(
      padding: const EdgeInsets.only(bottom: 30.0),
      alignment: Alignment.bottomCenter,
      child:  Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          CircleButton(
              icon: const Icon(
                Icons.switch_camera,
                color: Colors.white,
                size: 28,
              ),
              primary: Colors.white54,
              onPressed: toggleSwitchCamera),
          CircleButton(
              icon: _isMute
                  ? const Icon(
                      Icons.mic,
                      color: Colors.black,
                      size: 28,
                    )
                  : const Icon(
                      Icons.mic_off,
                      color: Colors.white,
                      size: 28,
                    ),
              primary: _isMute ? Colors.white : Colors.white54,
              onPressed: toggleMicro),
          CircleButton(
              icon: _isVideoEnable
                  ? const Icon(
                      Icons.videocam_off,
                      color: Colors.white,
                      size: 28,
                    )
                  : const Icon(
                      Icons.videocam,
                      color: Colors.black,
                      size: 28,
                    ),
              primary: _isVideoEnable ? Colors.white54 : Colors.white,
              onPressed: toggleVideo),
          CircleButton(
              icon: _sharingScreen
                  ? const Icon(
                      Icons.stop_screen_share,
                      color: Colors.black,
                      size: 28,
                    )
                  : const Icon(
                      Icons.screen_share,
                      color: Colors.white,
                      size: 28,
                    ),
              primary: _sharingScreen ? Colors.white : Colors.white54,
              onPressed: toggleShareScreen),
        ],
      ),
    );

    Widget _btnLeaveRoom = Align(
      alignment: Alignment.topRight,
      child: Container(
        margin: const EdgeInsets.only(
          top: 40.0,
          right: 20.0,
        ),
        child: RoundedButton(
            icon: const Icon(
              Icons.call_end,
              color: Colors.white,
              size: 28,
            ),
            color: Colors.red,
            radius: 10.0,
            onPressed: leaveRoomTapped),
      ),
    );

    Widget _participantView = Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 200.0,
        margin: const EdgeInsets.only(bottom: 100.0),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _remoteTrackViews.values.length,
          itemBuilder: (context, index) {
            return _remoteTrackViews.values.elementAt(index);
          },
        ),
      ),
    );
    return WillPopScope(
        child: Scaffold(
          body: Stack(
            children: [
              _localView,
              _participantView,
              _btnLeaveRoom,
              _bottomContainer,
            ],
          ),
        ),
        onWillPop: () {
          leaveRoomTapped();
          return Future.value(false);
        });
  }

  void initRoom(List<StringeeVideoTrackInfo> videoTrackInfos,
      List<StringeeRoomUser> userList) {
    _room.eventStreamController.stream.listen((event) {
      Map<dynamic, dynamic> map = event;
      print("Room " + map.toString());
      switch (map['eventType']) {
        case StringeeRoomEvents.didJoinRoom:
          handleJoinRoomEvent(map['body']);
          break;
        case StringeeRoomEvents.didLeaveRoom:
          handleLeaveRoomEvent(map['body']);
          break;
        case StringeeRoomEvents.didAddVideoTrack:
          handleAddVideoTrackEvent(map['body']);
          break;
        case StringeeRoomEvents.didRemoveVideoTrack:
          handleRemoveVideoTrackEvent(map['body']);
          break;
        case StringeeRoomEvents.didReceiveRoomMessage:
          handleReceiveRoomMessageEvent(map['body']);
          break;
        case StringeeRoomEvents.trackReadyToPlay:
          handleTrackReadyToPlayEvent(map['body']);
          break;
        default:
          break;
      }
    });

    StringeeVideoTrackOption options = StringeeVideoTrackOption(
      audio: true,
      video: true,
      screen: false,
    );
    widget._video.createLocalVideoTrack(options).then((value) {
      if (value['status']) {
        _room.publish(value['body']).then((value) {
          if (value['status']) {
            setState(() {
              _localTrack = value['body'];
            });
          }
        });
      }
    });

    if (videoTrackInfos.length > 0) {
      videoTrackInfos.forEach((trackInfo) {
        StringeeVideoTrackOption options = StringeeVideoTrackOption(
          audio: trackInfo.audioEnable,
          video: trackInfo.videoEnable,
          screen: trackInfo.isScreenCapture,
        );
        _room.subscribe(trackInfo, options).then((value) {
          if (value['status']) {
            setState(() {
              StringeeVideoTrack videoTrack = value['body'];
              _remoteTracks[videoTrack.id] = videoTrack;
            });
          }
        });
      });
    }
  }

  void handleJoinRoomEvent(StringeeRoomUser joinUser) {}

  void handleLeaveRoomEvent(StringeeRoomUser leaveUser) {}

  void handleAddVideoTrackEvent(StringeeVideoTrackInfo trackInfo) {
    StringeeVideoTrackOption options = StringeeVideoTrackOption(
      audio: trackInfo.audioEnable,
      video: trackInfo.videoEnable,
      screen: trackInfo.isScreenCapture,
    );
    _room.subscribe(trackInfo, options).then((value) {
      if (value['status']) {
        setState(() {
          StringeeVideoTrack videoTrack = value['body'];
          _remoteTracks[videoTrack.id] = videoTrack;
        });
      }
    });
  }

  void handleRemoveVideoTrackEvent(StringeeVideoTrackInfo trackInfo) {
    setState(() {
      _remoteTracks.remove(trackInfo.id);
      _remoteTrackViews.remove(trackInfo.id);
    });
  }

  void handleReceiveRoomMessageEvent(Map<dynamic, dynamic> bodyMap) {}

  void handleTrackReadyToPlayEvent(StringeeVideoTrack track) {
    print("handleTrackReadyToPlayEvent");
    if (track.isLocal) {
      if (track.isScreenCapture) {
        StringeeVideoView videoView = track.attach(
          height: 200.0,
          width: 150.0,
          scalingType: ScalingType.fit,
        );

        setState(() {
          _remoteTrackViews[videoView.trackId!] = videoView;
        });
      } else {
        setState(() {
          _hasLocalView = true;
          _localTrackView = track.attach(
            alignment: Alignment.center,
            scalingType: ScalingType.fit,
          );
        });
      }
    } else {
      StringeeVideoView videoView = track.attach(
        height: 200.0,
        width: 150.0,
        scalingType: ScalingType.fit,
      );

      setState(() {
        _remoteTrackViews[videoView.trackId!] = videoView;
      });
    }
  }

  void createForegroundServiceNotification() {
    flutterLocalNotificationsPlugin.initialize(const InitializationSettings(
      android: AndroidInitializationSettings('ic_launcher'),
    ));

    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.startForegroundService(
          1,
          'Screen capture',
          'Capturing',
          notificationDetails: const AndroidNotificationDetails(
            'Test id',
            'Test name',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
        );
  }

  void toggleShareScreen() {
    if (Platform.isAndroid) {
      if (_sharingScreen) {
        // remove foreground service notification
        flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.stopForegroundService();

        _room.unpublish(_shareTrack).then((result) {
          if (result['status']) {
            setState(() {
              _sharingScreen = false;
              _remoteTracks.remove(_shareTrack.localId);
              _remoteTrackViews.remove(_shareTrack.localId);
            });
          }
        });
      } else {
        createForegroundServiceNotification();
        widget._video.createCaptureScreenTrack().then((result) {
          if (result['status']) {
            _room.publish(result['body']).then((result) {
              if (result['status']) {
                setState(() {
                  _sharingScreen = true;
                  _shareTrack = result['body'];
                  _remoteTracks[_shareTrack.localId] = _shareTrack;
                });
              }
            });
          }
        });
      }
    }
  }

  void toggleSwitchCamera() {
    _localTrack.switchCamera().then((result) {
      bool status = result['status'];
      if (status) {}
    });
  }

  void toggleMicro() {
    _localTrack.mute(!_isMute).then((result) {
      bool status = result['status'];
      if (status) {
        setState(() {
          _isMute = !_isMute;
        });
      }
    });
  }

  void toggleVideo() {
    _localTrack.enableVideo(!_isVideoEnable).then((result) {
      bool status = result['status'];
      if (status) {
        setState(() {
          _isVideoEnable = !_isVideoEnable;
        });
      }
    });
  }

  void leaveRoomTapped() {
    _room.leave(allClient: false).then((result) {
      if (result['status']) {
        if (_sharingScreen) {
          createForegroundServiceNotification();
        }
        clearDataEndDismiss();
      }
    });
  }

  void clearDataEndDismiss() {
    _room.destroy();
    Navigator.pop(context);
  }
}
