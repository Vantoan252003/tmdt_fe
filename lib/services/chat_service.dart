import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'api_endpoints.dart';
import 'auth_service.dart';
import '../models/chat.dart';

class ChatService {
  StompClient? _stompClient;
  Function(ChatMessage)? _onMessageReceived;
  String? _currentUserId;

  // Initialize WebSocket connection
  Future<void> connect(String userId, Function(ChatMessage) onMessageReceived) async {
    _currentUserId = userId;
    _onMessageReceived = onMessageReceived;

    final token = await AuthService.getToken();
    
    _stompClient = StompClient(
      config: StompConfig(
        url: ApiEndpoints.chatWebSocket,
        onConnect: onConnectCallback,
        onWebSocketError: (dynamic error) {
          print('❌ WebSocket error: $error');
        },
        onStompError: (StompFrame frame) {
          print('❌ STOMP error: ${frame.body}');
        },
        onDisconnect: (StompFrame frame) {
          print('🔌 Disconnected from WebSocket');
        },
        beforeConnect: () async {
          print('🔄 Connecting to WebSocket...');
        },
        onWebSocketDone: () {
          print('✅ WebSocket connection closed');
        },
        // SockJS fallback - quan trọng!
        useSockJS: true,
        
        // Reconnect settings
        reconnectDelay: const Duration(seconds: 5),
        heartbeatIncoming: const Duration(seconds: 10),
        heartbeatOutgoing: const Duration(seconds: 10),
        
        stompConnectHeaders: token != null ? {'Authorization': 'Bearer $token'} : {},
        webSocketConnectHeaders: token != null ? {'Authorization': 'Bearer $token'} : {},
      ),
    );

    _stompClient?.activate();
  }

  void onConnectCallback(StompFrame frame) {
    print('✅ Connected to chat WebSocket');
    
    // Subscribe to user's message queue
    _stompClient?.subscribe(
      destination: '/user/queue/messages',
      callback: (StompFrame frame) {
        if (frame.body != null) {
          try {
            final message = ChatMessage.fromJson(jsonDecode(frame.body!));
            print('📩 New message received: ${message.content}');
            _onMessageReceived?.call(message);
          } catch (e) {
            print('❌ Error parsing message: $e');
          }
        }
      },
    );
  }

  // Send message via WebSocket
  void sendMessageViaWebSocket(String receiverId, String content, {String messageType = 'TEXT'}) {
    if (_stompClient == null || !_stompClient!.connected) {
      throw Exception('WebSocket not connected');
    }

    _stompClient?.send(
      destination: '/app/send',
      body: jsonEncode({
        'senderId': _currentUserId,
        'receiverId': receiverId,
        'content': content,
        'messageType': messageType,
      }),
    );
  }

  // Disconnect WebSocket
  void disconnect() {
    _stompClient?.deactivate();
    _stompClient = null;
  }

  // REST API: Get conversations
  Future<List<Conversation>> getConversations() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.get(
        Uri.parse(ApiEndpoints.conversations),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true) {
          final data = jsonResponse['data'];
          if (data is List) {
            return data.map((conv) => Conversation.fromJson(conv)).toList();
          } else {
            return [];
          }
        } else {
          throw Exception(jsonResponse['message'] ?? 'Failed to get conversations');
        }
      } else {
        throw Exception('Failed to get conversations: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting conversations: $e');
    }
  }

  // REST API: Get messages in a conversation
  Future<List<ChatMessage>> getMessages(String conversationId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.get(
        Uri.parse(ApiEndpoints.conversationMessages(conversationId)),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true) {
          final data = jsonResponse['data'];
          if (data is List) {
            return data.map((msg) => ChatMessage.fromJson(msg)).toList();
          } else {
            return [];
          }
        } else {
          throw Exception(jsonResponse['message'] ?? 'Failed to get messages');
        }
      } else {
        throw Exception('Failed to get messages: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting messages: $e');
    }
  }

  // REST API: Send message
  Future<ChatMessage?> sendMessage(SendMessageRequest request) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.post(
        Uri.parse(ApiEndpoints.sendMessage),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true) {
          return ChatMessage.fromJson(jsonResponse['data']);
        } else {
          throw Exception(jsonResponse['message'] ?? 'Failed to send message');
        }
      } else {
        throw Exception('Failed to send message: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error sending message: $e');
    }
  }

  // REST API: Mark conversation as read
  Future<void> markAsRead(String conversationId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.post(
        Uri.parse(ApiEndpoints.markAsRead(conversationId)),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to mark as read: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error marking as read: $e');
    }
  }

  // REST API: Start/get conversation
  Future<Conversation?> startConversation(String otherUserId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final request = StartConversationRequest(otherUserId: otherUserId);

      final response = await http.post(
        Uri.parse(ApiEndpoints.startConversation),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true) {
          return Conversation.fromJson(jsonResponse['data']);
        } else {
          throw Exception(jsonResponse['message'] ?? 'Failed to start conversation');
        }
      } else {
        throw Exception('Failed to start conversation: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error starting conversation: $e');
    }
  }
}
