import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/chat.dart';
import '../services/chat_service.dart';
import '../services/auth_service.dart';
import '../utils/app_theme.dart';

class ChatScreen extends StatefulWidget {
  final String conversationId;
  final String otherUserId;
  final String otherUserName;
  final String? otherUserAvatar;

  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserAvatar,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isSending = false;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    _currentUserId = await AuthService.getUserId();
    await _loadMessages();
    await _markAsRead();
    
    // Connect WebSocket for real-time messages
    if (_currentUserId != null) {
      _chatService.connect(_currentUserId!, (message) {
        if (message.conversationId == widget.conversationId) {
          setState(() {
            _messages.add(message);
          });
          _scrollToBottom();
        }
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _chatService.disconnect();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final messages = await _chatService.getMessages(widget.conversationId);
      if (mounted) {
        setState(() {
          _messages = messages;
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi tải tin nhắn: $e'),
            backgroundColor: const Color(0xFFEE4D2D),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    }
  }

  Future<void> _markAsRead() async {
    try {
      await _chatService.markAsRead(widget.conversationId);
    } catch (e) {
      // Ignore error
    }
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty || _isSending) return;

    setState(() {
      _isSending = true;
    });

    try {
      final request = SendMessageRequest(
        receiverId: widget.otherUserId,
        content: content,
      );

      final message = await _chatService.sendMessage(request);
      
      if (mounted && message != null) {
        setState(() {
          _messages.add(message);
          _messageController.clear();
          _isSending = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi gửi tin nhắn: $e'),
            backgroundColor: const Color(0xFFEE4D2D),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEE4D2D),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white,
                backgroundImage: widget.otherUserAvatar != null && widget.otherUserAvatar!.isNotEmpty
                    ? CachedNetworkImageProvider(widget.otherUserAvatar!)
                    : null,
                child: widget.otherUserAvatar == null || widget.otherUserAvatar!.isEmpty
                    ? Text(
                        widget.otherUserName.isNotEmpty ? widget.otherUserName[0].toUpperCase() : 'U',
                        style: const TextStyle(
                          color: Color(0xFFEE4D2D),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.otherUserName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Text(
                    'Đang hoạt động',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              // More options
            },
            icon: const Icon(Icons.more_vert, color: Colors.white),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFFEE4D2D)),
                  )
                : _messages.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final showDateHeader = index == 0 || 
                              _shouldShowDateHeader(_messages[index], _messages[index - 1]);
                          return Column(
                            children: [
                              if (showDateHeader)
                                _buildDateHeader(_messages[index].createdAt),
                              _buildMessageBubble(_messages[index]),
                            ],
                          );
                        },
                      ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  bool _shouldShowDateHeader(ChatMessage current, ChatMessage previous) {
    try {
      final currentDate = DateTime.parse(current.createdAt);
      final previousDate = DateTime.parse(previous.createdAt);
      return currentDate.day != previousDate.day ||
             currentDate.month != previousDate.month ||
             currentDate.year != previousDate.year;
    } catch (e) {
      return false;
    }
  }

  Widget _buildDateHeader(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      String displayText;

      if (date.year == now.year && date.month == now.month && date.day == now.day) {
        displayText = 'Hôm nay';
      } else if (date.year == now.year && date.month == now.month && date.day == now.day - 1) {
        displayText = 'Hôm qua';
      } else {
        displayText = '${date.day}/${date.month}/${date.year}';
      }

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            displayText,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    } catch (e) {
      return const SizedBox.shrink();
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFFEE4D2D).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.chat_bubble_outline,
              size: 60,
              color: Color(0xFFEE4D2D),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Bắt đầu cuộc trò chuyện',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Gửi tin nhắn đầu tiên của bạn',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isMe = message.senderId == _currentUserId;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: const Color(0xFFEE4D2D).withOpacity(0.1),
              backgroundImage: message.senderAvatar != null && message.senderAvatar!.isNotEmpty
                  ? CachedNetworkImageProvider(message.senderAvatar!)
                  : null,
              child: message.senderAvatar == null || message.senderAvatar!.isEmpty
                  ? Text(
                      message.senderName.isNotEmpty ? message.senderName[0].toUpperCase() : 'U',
                      style: const TextStyle(
                        color: Color(0xFFEE4D2D),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isMe ? const Color(0xFFEE4D2D) : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isMe ? 18 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 18),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    message.content,
                    style: TextStyle(
                      fontSize: 15,
                      color: isMe ? Colors.white : Colors.black87,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    _formatTime(message.createdAt),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[500],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isMe) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Add attachment button
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  // Add attachment
                },
                icon: Icon(
                  Icons.add,
                  color: Colors.grey[600],
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Text input
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 100),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Nhập tin nhắn...',
                    hintStyle: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                  maxLines: null,
                  textInputAction: TextInputAction.newline,
                  style: const TextStyle(fontSize: 15),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Send button
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFFEE4D2D),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                onPressed: _isSending ? null : _sendMessage,
                icon: _isSending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(String timeStr) {
    try {
      final time = DateTime.parse(timeStr);
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '';
    }
  }
}