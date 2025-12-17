class ChatMessage {
  final String messageId;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final String receiverId;
  final String content;
  final String? imageUrl;
  final String messageType; // TEXT, IMAGE, etc.
  final bool isRead;
  final String createdAt;

  ChatMessage({
    required this.messageId,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    required this.receiverId,
    required this.content,
    this.imageUrl,
    required this.messageType,
    required this.isRead,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      messageId: json['messageId'] ?? '',
      conversationId: json['conversationId'] ?? '',
      senderId: json['senderId'] ?? '',
      senderName: json['senderName'] ?? '',
      senderAvatar: json['senderAvatar'],
      receiverId: json['receiverId'] ?? '',
      content: json['content'] ?? '',
      imageUrl: json['imageUrl'],
      messageType: json['messageType'] ?? 'TEXT',
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'conversationId': conversationId,
      'senderId': senderId,
      'senderName': senderName,
      if (senderAvatar != null) 'senderAvatar': senderAvatar,
      'receiverId': receiverId,
      'content': content,
      if (imageUrl != null) 'imageUrl': imageUrl,
      'messageType': messageType,
      'isRead': isRead,
      'createdAt': createdAt,
    };
  }
}

class Conversation {
  final String conversationId;
  final String otherUserId;
  final String otherUserName;
  final String? otherUserAvatar;
  final String? lastMessage;
  final String? lastMessageTime;
  final int unreadCount;

  Conversation({
    required this.conversationId,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserAvatar,
    this.lastMessage,
    this.lastMessageTime,
    required this.unreadCount,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      conversationId: json['conversationId'] ?? '',
      otherUserId: json['otherUserId'] ?? '',
      otherUserName: json['otherUserName'] ?? '',
      otherUserAvatar: json['otherUserAvatar'],
      lastMessage: json['lastMessage'],
      lastMessageTime: json['lastMessageTime'],
      unreadCount: json['unreadCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'conversationId': conversationId,
      'otherUserId': otherUserId,
      'otherUserName': otherUserName,
      if (otherUserAvatar != null) 'otherUserAvatar': otherUserAvatar,
      if (lastMessage != null) 'lastMessage': lastMessage,
      if (lastMessageTime != null) 'lastMessageTime': lastMessageTime,
      'unreadCount': unreadCount,
    };
  }
}

class SendMessageRequest {
  final String receiverId;
  final String content;
  final String messageType;

  SendMessageRequest({
    required this.receiverId,
    required this.content,
    this.messageType = 'TEXT',
  });

  Map<String, dynamic> toJson() {
    return {
      'receiverId': receiverId,
      'content': content,
      'messageType': messageType,
    };
  }
}

class StartConversationRequest {
  final String otherUserId;

  StartConversationRequest({
    required this.otherUserId,
  });

  Map<String, dynamic> toJson() {
    return {
      'otherUserId': otherUserId,
    };
  }
}
