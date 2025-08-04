import 'dart:async';

import 'package:flutter/material.dart';
import 'package:weorbis_motion_detector/weorbis_motion_detector.dart';

void main() => runApp(const MotionRecognitionApp());

class MotionRecognitionApp extends StatefulWidget {
  const MotionRecognitionApp({super.key});

  @override
  State<MotionRecognitionApp> createState() => _MotionRecognitionAppState();
}

class _MotionRecognitionAppState extends State<MotionRecognitionApp> {
  StreamSubscription<MotionEvent>? _motionStreamSubscription;
  final List<MotionEvent> _events = [];
  final MotionDetector _motionDetector = MotionDetector();
  MotionEvent? _latestEvent;
  bool _isStreaming = false;

  @override
  void initState() {
    super.initState();
    _checkInitialPermission();
  }

  void _checkInitialPermission() async {
    bool isGranted = await MotionDetector.requestPermission();
    if (!isGranted) {
      // Handle the case where permission is not granted at startup.
      _showSnackbar("Motion permission is required to use this app.");
    }
  }

  @override
  void dispose() {
    _motionStreamSubscription?.cancel();
    super.dispose();
  }

  void _startOrStopStreaming() {
    if (_isStreaming) {
      _motionStreamSubscription?.cancel();
      setState(() {
        _isStreaming = false;
      });
    } else {
      _motionStreamSubscription = _motionDetector
          .motionStream(
            androidUpdateIntervalMillis: 10000, // 10 seconds
            notificationTitle: 'Motion Example',
            notificationText: 'Detecting your motion in the background.',
          )
          .listen(_onMotionEvent, onError: _onError);
      setState(() {
        _isStreaming = true;
      });
    }
  }

  void _getCurrentActivity() async {
    try {
      final event = await _motionDetector.getCurrentActivity();
      _showSnackbar(
          'One-shot Event: ${event.typeString} (${event.confidence}%)');
      setState(() {
        _latestEvent = event;
      });
    } catch (e) {
      _onError(e);
    }
  }

  void _onMotionEvent(MotionEvent event) {
    print(event);
    setState(() {
      _events.add(event);
      _latestEvent = event;
    });
  }

  void _onError(Object error) {
    print('onError: $error');
    if (mounted) {
      _showSnackbar('Error: $error');
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Motion Detector Example'),
        ),
        body: Column(
          children: [
            _buildControlPanel(),
            _buildCurrentStatus(),
            const Divider(),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Event History',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            Expanded(child: _buildEventList()),
          ],
        ),
      ),
    );
  }

  Widget _buildControlPanel() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: _startOrStopStreaming,
            style: ElevatedButton.styleFrom(
              backgroundColor: _isStreaming ? Colors.red : Colors.green,
            ),
            child: Text(_isStreaming ? 'Stop Stream' : 'Start Stream'),
          ),
          ElevatedButton(
            onPressed: _getCurrentActivity,
            child: const Text('Get Current Activity'),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStatus() {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        leading: _motionIcon(_latestEvent?.type ?? MotionType.UNKNOWN),
        title: Text(
          'Latest: ${_latestEvent?.typeString ?? 'N/A'}',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Confidence: ${_latestEvent?.confidence ?? 0}%'),
        trailing: Text(_latestEvent?.timeStamp
                .toIso8601String()
                .split('T')
                .last
                .split('.')
                .first ??
            ''),
      ),
    );
  }

  Widget _buildEventList() {
    return ListView.builder(
      itemCount: _events.length,
      reverse: true,
      itemBuilder: (_, int idx) {
        final motion = _events[idx];
        return ListTile(
          leading: _motionIcon(motion.type),
          title: Text(
              '${motion.type.toString().split('.').last} (${motion.confidence}%)'),
          trailing: Text(motion.timeStamp
              .toIso8601String()
              .split('T')
              .last
              .split('.')
              .first),
        );
      },
    );
  }

  Icon _motionIcon(MotionType type) {
    switch (type) {
      case MotionType.WALKING:
        return const Icon(Icons.directions_walk, color: Colors.blue);
      case MotionType.IN_VEHICLE:
        return const Icon(Icons.car_rental, color: Colors.purple);
      case MotionType.ON_BICYCLE:
        return const Icon(Icons.pedal_bike, color: Colors.green);
      case MotionType.ON_FOOT:
        return const Icon(Icons.directions_walk, color: Colors.orange);
      case MotionType.RUNNING:
        return const Icon(Icons.run_circle, color: Colors.red);
      case MotionType.STILL:
        return const Icon(Icons.cancel_outlined, color: Colors.grey);
      case MotionType.TILTING:
        return const Icon(Icons.redo, color: Colors.brown);
      default:
        return const Icon(Icons.device_unknown);
    }
  }
}
