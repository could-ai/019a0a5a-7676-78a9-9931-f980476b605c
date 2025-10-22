import 'package:flutter/material.dart';
import 'package:agora_uikit/agora_uikit.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Video Call',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _channelController = TextEditingController();
  bool _validateError = false;

  @override
  void dispose() {
    _channelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Call Chat'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 40),
              SizedBox(
                height: 200,
                child: Image.network('https://img.freepik.com/free-vector/video-call-conference-illustration_23-2148624133.jpg'),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _channelController,
                decoration: InputDecoration(
                  errorText: _validateError ? 'Channel name is mandatory' : null,
                  border: const OutlineInputBorder(
                    borderSide: BorderSide(width: 1),
                  ),
                  hintText: 'Enter Channel Name',
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: onJoin,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Join Call'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> onJoin() async {
    setState(() {
      _channelController.text.isEmpty
          ? _validateError = true
          : _validateError = false;
    });
    if (_channelController.text.isNotEmpty) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CallScreen(
            channelName: _channelController.text,
          ),
        ),
      );
    }
  }
}

class CallScreen extends StatefulWidget {
  final String channelName;
  const CallScreen({Key? key, required this.channelName}) : super(key: key);

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  late final AgoraClient _client;

  // IMPORTANT: You must get your own App ID from agora.io and replace it here.
  final String _agoraAppId = "<-- Insert Your Agora App ID Here -->";

  @override
  void initState() {
    super.initState();
    _client = AgoraClient(
      agoraConnectionData: AgoraConnectionData(
        appId: _agoraAppId,
        channelName: widget.channelName,
        // A temp token is fine for testing. For production, you should generate a token from your server.
        tempToken: null, 
      ),
      enabledPermission: [
        Permission.camera,
        Permission.microphone,
      ],
    );
    _initAgora();
  }

  void _initAgora() async {
    await _client.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              AgoraVideoViewer(
                client: _client,
                layoutType: Layout.floating,
                showNumberOfUsers: true,
                enableHostControls: true, // Add host controls
              ),
              AgoraVideoButtons(
                client: _client,
                onDisconnect: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
