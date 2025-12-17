import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'dart:convert';
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

    _stompClient?.deactivate();
    
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
        // Enable SockJS for Spring Boot compatibility
        useSockJS: true,
        
        // Connection settings
        connectionTimeout: const Duration(seconds: 10),
        reconnectDelay: const Duration(seconds: 3),
     
        
        // Heartbeat to keep connection alive
        heartbeatIncoming: const Duration(seconds: 20),
        heartbeatOutgoing: const Duration(seconds: 20),
        
        // Add authorization headers
        stompConnectHeaders: token != null 
          ? {
              'Authorization': 'Bearer $token',
              'accept-version': '1.1,1.0',
              'heart-beat': '0,0',
            }
          : {
              'accept-version': '1.1,1.0',
              'heart-beat': '0,0',
            },
        webSocketConnectHeaders: token != null ? {'Authorization': 'Bearer $token'} : {},
      ),
    );

    print('🚀 Activating STOMP client with WebSocket URL: ${ApiEndpoints.chatWebSocket}');
    _stompClient?.activate();
    
    // Give it a moment to connect
    await Future.delayed(const Duration(milliseconds: 500));
  }

  void onConnectCallback(StompFrame frame) {
    print('✅ Connected to chat WebSocket at ${DateTime.now()}');
    print('🔗 Connection details - Frame command: ${frame.command}');
    print('👤 Connected with userId: $_currentUserId');
    
    // Add a small delay to ensure connection is stable
    Future.delayed(const Duration(milliseconds: 100), () {
      // Try multiple subscription patterns to ensure compatibility
      // Pattern 1: /user/{userId}/queue/messages (Spring default for convertAndSendToUser)
      final destination1 = '/user/$_currentUserId/queue/messages';
      print('📡 [1] Subscribing to: $destination1');
      
      _stompClient?.subscribe(
        destination: destination1,
        callback: (StompFrame frame) {
          print('🎉🎉🎉 [PATTERN 1] WEBSOCKET CALLBACK TRIGGERED! 🎉🎉🎉');
          _handleIncomingMessage(frame);
        },
      );
      
      // Pattern 2: /queue/messages (Spring might resolve /user prefix automatically)
      final destination2 = '/queue/messages';
      print('📡 [2] Subscribing to: $destination2');
      
      _stompClient?.subscribe(
        destination: destination2,
        callback: (StompFrame frame) {
          print('🎉🎉🎉 [PATTERN 2] WEBSOCKET CALLBACK TRIGGERED! 🎉🎉🎉');
          _handleIncomingMessage(frame);
        },
      );
      
      // Pattern 3: /user/queue/messages (original attempt)
      final destination3 = '/user/queue/messages';
      print('📡 [3] Subscribing to: $destination3');
      
      _stompClient?.subscribe(
        destination: destination3,
        callback: (StompFrame frame) {
          print('🎉🎉🎉 [PATTERN 3] WEBSOCKET CALLBACK TRIGGERED! 🎉🎉🎉');
          _handleIncomingMessage(frame);
        },
      );
      
      // Pattern 4: /topic/messages (alternative)
      final destination4 = '/topic/messages';
      print('📡 [4] Subscribing to: $destination4');
      
      _stompClient?.subscribe(
        destination: destination4,
        callback: (StompFrame frame) {
          print('🎉🎉🎉 [PATTERN 4] WEBSOCKET CALLBACK TRIGGERED! 🎉🎉🎉');
          _handleIncomingMessage(frame);
        },
      );
      
      // Pattern 5: /user/{userId}/messages (without queue)
      final destination5 = '/user/$_currentUserId/messages';
      print('📡 [5] Subscribing to: $destination5');
      
      _stompClient?.subscribe(
        destination: destination5,
        callback: (StompFrame frame) {
          print('🎉🎉🎉 [PATTERN 5] WEBSOCKET CALLBACK TRIGGERED! 🎉🎉🎉');
          _handleIncomingMessage(frame);
        },
      );
      
      // Pattern 6: /topic/messages (alternative)
      final destination6 = '/topic/messages';
      print('📡 [6] Subscribing to: $destination6');
      
      _stompClient?.subscribe(
        destination: destination6,
        callback: (StompFrame frame) {
          print('🎉🎉🎉 [PATTERN 6] WEBSOCKET CALLBACK TRIGGERED! 🎉🎉🎉');
          _handleIncomingMessage(frame);
        },
      );
      
      print('✅ Subscribed to all 6 destination patterns');
    });
  }

  // Handle incoming WebSocket messages
  void _handleIncomingMessage(StompFrame frame) {
    print('🎯🎯🎯 MESSAGE RECEIVED VIA WEBSOCKET! 🎯🎯🎯');
    print('📦 Frame body: ${frame.body}');
    print('📍 Frame destination: ${frame.headers?["destination"] ?? "N/A"}');
    print('📍 Frame subscription: ${frame.headers?["subscription"] ?? "N/A"}');
    print('📍 Frame message-id: ${frame.headers?["message-id"] ?? "N/A"}');
    
    if (frame.body != null && frame.body!.isNotEmpty) {
      try {
        print('🔄 Attempting to parse JSON...');
        final jsonData = jsonDecode(frame.body!);
        print('✅ JSON parsed successfully: $jsonData');
        
        final message = ChatMessage.fromJson(jsonData);
        print('✅ ChatMessage created:');
        print('   - messageId: ${message.messageId}');
        print('   - conversationId: ${message.conversationId}');
        print('   - senderId: ${message.senderId}');
        print('   - senderName: ${message.senderName}');
        print('   - content: ${message.content}');
        print('   - messageType: ${message.messageType}');
        print('   - createdAt: ${message.createdAt}');
        
        print('📞 Calling onMessageReceived callback...');
        _onMessageReceived?.call(message);
        print('✅ Callback called successfully');
        
      } catch (e) {
        print('❌ Error parsing WebSocket message: $e');
        print('❌ Raw frame body: ${frame.body}');
        print('❌ Stack trace: ${e.toString()}');
      }
    } else {
      print('⚠️ Frame body is null or empty');
    }
  }

  // Send message via WebSocket
  Map<String, dynamic> sendMessageViaWebSocket(String receiverId, String content, {String messageType = 'TEXT', String? conversationId}) {
    print('🔍 Checking WebSocket connection status...');
    print('   - _stompClient is null: ${_stompClient == null}');
    print('   - _stompClient connected: ${_stompClient?.connected}');
    
    if (_stompClient == null || !_stompClient!.connected) {
      print('❌ WebSocket not connected, cannot send message');
      throw Exception('WebSocket not connected');
    }

    final messageData = {
      'senderId': _currentUserId,
      'receiverId': receiverId,
      'content': content,
      'messageType': messageType,
    };
    
    print('📤 [FLUTTER] Sending WebSocket message:');
    print('   - Destination: /app/send');
    print('   - Data: $messageData');
    print('   - Current userId: $_currentUserId');
    
    try {
      _stompClient?.send(
        destination: '/app/send',
        body: jsonEncode(messageData),
      );
      print('✅ [FLUTTER] WebSocket message sent successfully');
    } catch (e) {
      print('❌ [FLUTTER] Error sending WebSocket message: $e');
      throw e;
    }
    
    // Return optimistic message data for sender's UI
    return {
      'messageId': 'temp-${DateTime.now().millisecondsSinceEpoch}', // Temporary ID
      'conversationId': conversationId ?? '',
      'senderId': _currentUserId ?? '',
      'senderName': 'You', // Will be updated when real message arrives
      'senderAvatar': null,
      'receiverId': receiverId,
      'content': content,
      'imageUrl': null,
      'messageType': messageType,
      'isRead': false,
      'createdAt': DateTime.now().toIso8601String(),
    };
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

  // REST API: Send image message
  Future<ChatMessage?> sendImageMessage(String receiverId, File imageFile) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      // Create multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiEndpoints.sendImage),
      );

      // Add authorization header
      request.headers['Authorization'] = 'Bearer $token';

      // Add receiverId field
      request.fields['receiverId'] = receiverId;

      // Add image file
      final fileName = path.basename(imageFile.path);
      final mimeType = _getMimeType(fileName);
      
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
          filename: fileName,
          contentType: MediaType.parse(mimeType),
        ),
      );

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true) {
          return ChatMessage.fromJson(jsonResponse['data']);
        } else {
          throw Exception(jsonResponse['message'] ?? 'Failed to send image');
        }
      } else {
        throw Exception('Failed to send image: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error sending image: $e');
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

  // Helper method to get MIME type from file extension
  String _getMimeType(String fileName) {
    final extension = path.extension(fileName).toLowerCase();
    switch (extension) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      case '.webp':
        return 'image/webp';
      default:
        return 'image/jpeg'; // Default fallback
    }
  }
}