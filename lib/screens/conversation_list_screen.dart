import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/chat.dart';
import '../services/chat_service.dart';
import '../utils/app_theme.dart';
import 'chat_screen.dart';

class ConversationListScreen extends StatefulWidget {
  const ConversationListScreen({super.key});

  @override
  State<ConversationListScreen> createState() => _ConversationListScreenState();
}

class _ConversationListScreenState extends State<ConversationListScreen> {
  final ChatService _chatService = ChatService();
  List<Conversation> _conversations = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final conversations = await _chatService.getConversations();
      if (mounted) {
        setState(() {
          _conversations = conversations;
          _isLoading = false;
        });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Chat',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFEE4D2D),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // Search conversations
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {
              // More options
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFEE4D2D)),
            )
          : _conversations.isEmpty
              ? _buildEmptyState()
              : Column(
                  children: [
                    // Quick actions bar
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          _buildQuickAction(Icons.support_agent, 'Hỗ trợ', () {}),
                          const SizedBox(width: 24),
                          _buildQuickAction(Icons.notifications_active, 'Thông báo', () {}),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Conversations list
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _loadConversations,
                        color: const Color(0xFFEE4D2D),
                        child: Container(
                          color: Colors.white,
                          child: ListView.separated(
                            itemCount: _conversations.length,
                            separatorBuilder: (context, index) => Divider(
                              height: 1,
                              thickness: 1,
                              color: Colors.grey[100],
                              indent: 72,
                            ),
                            itemBuilder: (context, index) {
                              return _buildConversationItem(_conversations[index]);
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFFEE4D2D), size: 20),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
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
            'Chưa có tin nhắn nào',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bắt đầu trò chuyện với người bán',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationItem(Conversation conversation) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              conversationId: conversation.conversationId,
              otherUserId: conversation.otherUserId,
              otherUserName: conversation.otherUserName,
              otherUserAvatar: conversation.otherUserAvatar,
            ),
          ),
        ).then((_) => _loadConversations());
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: conversation.unreadCount > 0 
            ? const Color(0xFFFFF3E0) 
            : Colors.white,
        child: Row(
          children: [
            // Avatar with online indicator
            Stack(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: const Color(0xFFEE4D2D).withOpacity(0.1),
                  backgroundImage: conversation.otherUserAvatar != null && 
                      conversation.otherUserAvatar!.isNotEmpty
                      ? CachedNetworkImageProvider(conversation.otherUserAvatar!)
                      : null,
                  child: conversation.otherUserAvatar == null || 
                      conversation.otherUserAvatar!.isEmpty
                      ? Text(
                          conversation.otherUserName.isNotEmpty 
                              ? conversation.otherUserName[0].toUpperCase() 
                              : 'U',
                          style: const TextStyle(
                            color: Color(0xFFEE4D2D),
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        )
                      : null,
                ),
                // Online indicator (optional - can be controlled by user status)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.otherUserName,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: conversation.unreadCount > 0 
                                ? FontWeight.bold 
                                : FontWeight.w500,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (conversation.lastMessageTime != null)
                        Text(
                          _formatTime(conversation.lastMessageTime!),
                          style: TextStyle(
                            fontSize: 12,
                            color: conversation.unreadCount > 0 
                                ? const Color(0xFFEE4D2D) 
                                : Colors.grey[600],
                            fontWeight: conversation.unreadCount > 0 
                                ? FontWeight.w500 
                                : FontWeight.normal,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.lastMessage ?? '',
                          style: TextStyle(
                            fontSize: 13,
                            color: conversation.unreadCount > 0 
                                ? Colors.black87 
                                : Colors.grey[600],
                            fontWeight: conversation.unreadCount > 0 
                                ? FontWeight.w500 
                                : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (conversation.unreadCount > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          constraints: const BoxConstraints(minWidth: 20),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: const BoxDecoration(
                            color: Color(0xFFEE4D2D),
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          child: Text(
                            conversation.unreadCount > 99 
                                ? '99+' 
                                : '${conversation.unreadCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
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

  String _formatTime(String timeStr) {
    try {
      final time = DateTime.parse(timeStr);
      final now = DateTime.now();
      final diff = now.difference(time);

      if (diff.inDays == 0) {
        // Today - show time
        return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      } else if (diff.inDays == 1) {
        return 'Hôm qua';
      } else if (diff.inDays < 7) {
        // Within a week - show day of week
        const weekdays = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
        return weekdays[time.weekday % 7];
      } else {
        // Older - show date
        return '${time.day}/${time.month}';
      }
    } catch (e) {
      return '';
    }
  }
}