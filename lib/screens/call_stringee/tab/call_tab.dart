import 'package:base_project/screens/call_stringee/ui/call.dart';
import 'package:flutter/material.dart';
import 'package:stringee_flutter_plugin/stringee_flutter_plugin.dart';

StringeeClient client = StringeeClient();

class CallTab extends StatefulWidget {
  const CallTab({super.key});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return CallTabState();
  }
}

class CallTabState extends State<CallTab> {
  String myUserId = 'user2';
  String token = 'eyJjdHkiOiJzdHJpbmdlZS1hcGk7dj0xIiwidHlwIjoiSldUIiwiYWxnIjoiSFMyNTYifQ.eyJqdGkiOiJTSy4wLnRXdjU2SG00azFNQkVJTWc4SmE5MmE1UWpWWEFrUkpULTE2NzUxNDg0MTMiLCJpc3MiOiJTSy4wLnRXdjU2SG00azFNQkVJTWc4SmE5MmE1UWpWWEFrUkpUIiwiZXhwIjoxNjc3NzQwNDEzLCJ1c2VySWQiOiJ1c2VyMSJ9.JM6drUHiVD_NgwHcyoo6wKbc-3HXbxQ8hjwWsmGTyQs';
  String toUser = 'user1';
  String tokenUser2 = 'eyJjdHkiOiJzdHJpbmdlZS1hcGk7dj0xIiwidHlwIjoiSldUIiwiYWxnIjoiSFMyNTYifQ.eyJqdGkiOiJTSy4wLnRXdjU2SG00azFNQkVJTWc4SmE5MmE1UWpWWEFrUkpULTE2NzUxNDg4NDkiLCJpc3MiOiJTSy4wLnRXdjU2SG00azFNQkVJTWc4SmE5MmE1UWpWWEFrUkpUIiwiZXhwIjoxNjc3NzQwODQ5LCJ1c2VySWQiOiJ1c2VyMiJ9.INlqpeksevsmJRxT8Jm7Y9Z3mCtxZXD-4qwY7LT1r8g';


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    /// Lắng nghe sự kiện của StringeeClient(kết nối, cuộc gọi đến...)
    client.eventStreamController.stream.listen((event) {
      Map<dynamic, dynamic> map = event;
      switch (map['eventType']) {
        case StringeeClientEvents.didConnect:
          handleDidConnectEvent();
          break;
        case StringeeClientEvents.didDisconnect:
          handleDiddisconnectEvent();
          break;
        case StringeeClientEvents.didFailWithError:
          handleDidFailWithErrorEvent(
              map['body']['code'], map['body']['message']);
          break;
        case StringeeClientEvents.requestAccessToken:
          handleRequestAccessTokenEvent();
          break;
        case StringeeClientEvents.didReceiveCustomMessage:
          handleDidReceiveCustomMessageEvent(map['body']);
          break;
        case StringeeClientEvents.incomingCall:
          StringeeCall call = map['body'];
          handleIncomingCallEvent(call);
          break;
        case StringeeClientEvents.incomingCall2:
          StringeeCall2 call = map['body'];
          handleIncomingCall2Event(call);
          break;
        default:
          break;
      }
    });

    /// Connect
    if (token.isNotEmpty) {
      client.connect(token);
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(left: 10.0, top: 10.0),
              child: Text(
                'Connected as: $myUserId',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 20.0,
                ),
              ),
            ),
            Form(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(20.0),
                    child: TextField(
                      onChanged: (String value) {
                        setState(() {
                          toUser = value;
                        });
                      },
                      decoration: const InputDecoration(
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.red),
                        ),
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 40.0,
                                width: 175.0,
                                child: ElevatedButton(
                                  onPressed: () {
                                    callTapped(
                                        false, StringeeObjectEventType.call);
                                  },
                                  child: const Text('CALL'),
                                ),
                              ),
                              Container(
                                height: 40.0,
                                width: 175.0,
                                margin: const EdgeInsets.only(top: 20.0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    callTapped(
                                        true, StringeeObjectEventType.call);
                                  },
                                  child: const Text('VIDEOCALL'),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 40.0,
                                width: 175.0,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.only(
                                          left: 20.0, right: 20.0)),
                                  onPressed: () {
                                    callTapped(
                                        false, StringeeObjectEventType.call2);
                                  },
                                  child: const Text('CALL2'),
                                ),
                              ),
                              Container(
                                height: 40.0,
                                width: 175.0,
                                margin: const EdgeInsets.only(top: 20.0),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.only(
                                          left: 20.0, right: 20.0)),
                                  onPressed: () {
                                    callTapped(
                                        true, StringeeObjectEventType.call2);
                                  },
                                  child: const Text('VIDEOCALL2'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  //region Handle Client Event
  void handleDidConnectEvent() {
    setState(() {
      myUserId = client.userId!;
    });
  }

  void handleDiddisconnectEvent() {
    setState(() {
      myUserId = 'Not connected';
    });
  }

  void handleDidFailWithErrorEvent(int code, String message) {
    print('code: $code\nmessage: $message');
  }

  void handleRequestAccessTokenEvent() {
    print('Request new access token');
  }

  void handleDidReceiveCustomMessageEvent(Map<dynamic, dynamic> map) {
    print('${'from: ' +
        map['fromUserId']}\nmessage: ${map['message']}');
  }

  void handleIncomingCallEvent(StringeeCall call) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Call(
          client,
          call.from!,
          call.to!,
          true,
          call.isVideoCall,
          StringeeObjectEventType.call,
          stringeeCall: call,
        ),
      ),
    );
  }

  void handleIncomingCall2Event(StringeeCall2 call) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Call(
          client,
          call.from!,
          call.to!,
          true,
          call.isVideoCall,
          StringeeObjectEventType.call2,
          stringeeCall2: call,
        ),
      ),
    );
  }

  void callTapped(bool isVideoCall, StringeeObjectEventType callType) {
    if (toUser.isEmpty || !client.hasConnected) return;

    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => Call(
                client,
                client.userId ?? 'user1',
                toUser,
                false,
                isVideoCall,
                callType,
              )),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
