import 'package:base_project/screens/call_stringee/ui/agent.dart';
import 'package:base_project/screens/call_stringee/ui/visitor.dart';
import 'package:flutter/material.dart';

class LiveChatTab extends StatefulWidget {
  const LiveChatTab({super.key});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return LiveChatTabState();
  }
}

class LiveChatTabState extends State<LiveChatTab> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Column(
            children: [
              const TabBar(
                  indicatorColor: Colors.indigoAccent,
                  unselectedLabelColor: Colors.black,
                  labelColor: Colors.indigoAccent,
                  tabs: [
                    Tab(
                      child: Text('Visistor'),
                    ),
                    Tab(
                      child: Text('Agent'),
                    )
                  ]),
              Expanded(
                child: TabBarView(children: [
                  VisitorPage(),
                  AgentPage(),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
