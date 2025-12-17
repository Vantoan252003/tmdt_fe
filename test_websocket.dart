import 'dart:convert';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

void main() {
  print('🧪 Testing WebSocket connection...');

  final stompClient = StompClient(
    config: StompConfig(
      url: 'http://192.168.31.101:8080/ws',
      onConnect: (frame) {
        print('✅ Connected to WebSocket');
        print('Frame: ${frame.command}');

        // Subscribe to test destination
        stompClient.subscribe(
          destination: '/user/test/queue/messages',
          callback: (frame) {
            print('📨 Received message on /user/test/queue/messages');
            print('Body: ${frame.body}');
          },
        );

        // Send test message
        stompClient.send(
          destination: '/app/send',
          body: jsonEncode({
            'senderId': 'test-user',
            'receiverId': 'test-receiver',
            'content': 'Test message from Flutter',
            'messageType': 'TEXT',
          }),
        );
        print('📤 Sent test message');
      },
      onWebSocketError: (error) => print('❌ WebSocket error: $error'),
      onStompError: (frame) => print('❌ STOMP error: ${frame.body}'),
      onDisconnect: (frame) => print('🔌 Disconnected'),
      useSockJS: true,
      connectionTimeout: const Duration(seconds: 10),
    ),
  );

  stompClient.activate();

  // Keep alive for 30 seconds
  Future.delayed(const Duration(seconds: 30), () {
    stompClient.deactivate();
    print('🛑 Test completed');
  });
}</content>
<parameter name="filePath">/Users/nguyenvantoan/dev/FLUTTER_PROJECTS/student_ecommerce/test_websocket.dart