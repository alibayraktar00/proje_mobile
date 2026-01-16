import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/ai_service.dart';

class AICoachChatScreen extends ConsumerStatefulWidget {
  const AICoachChatScreen({super.key});

  @override
  ConsumerState<AICoachChatScreen> createState() => _AICoachChatScreenState();
}

class _AICoachChatScreenState extends ConsumerState<AICoachChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessageUI> _messages = [];
  bool _isLoading = false;
  late final AIService _aiService;

  @override
  void initState() {
    super.initState();
    _aiService = ref.read(aiServiceProvider);
    // Welcome message
    _messages.add(ChatMessageUI(
      text: "Merhaba! Ben senin AI Spor Koçun. 💪\n\nSpor, beslenme, egzersiz teknikleri veya fitness hedeflerin hakkında sorular sorabilirsin. Nasıl yardımcı olabilirim?",
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }


  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isLoading) return;

    // Add user message
    setState(() {
      _messages.add(ChatMessageUI(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
    });
    _messageController.clear();
    _scrollToBottom();

    try {
      final responseText = await _aiService.sendMessage(text);

      if (mounted) {
        setState(() {
          _messages.add(ChatMessageUI(
            text: responseText,
            isUser: false,
            timestamp: DateTime.now(),
          ));
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Bir hata oluştu.';
        if (e.toString().contains('API_KEY') || e.toString().contains('401')) {
          errorMessage = 'API Key hatası. Lütfen .env dosyanızı kontrol edin.';
        } else if (e.toString().contains('network') || e.toString().contains('connection')) {
          errorMessage = 'İnternet bağlantınızı kontrol edin.';
        } else if (e.toString().contains('quota') || e.toString().contains('limit')) {
          errorMessage = 'API kotası doldu. Lütfen daha sonra tekrar deneyin.';
        } else {
          errorMessage = 'Hata: ${e.toString()}';
        }

        setState(() {
          _messages.add(ChatMessageUI(
            text: errorMessage,
            isUser: false,
            timestamp: DateTime.now(),
          ));
          _isLoading = false;
        });
        _scrollToBottom();
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
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B141A) : const Color(0xFFECE5DD),
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.green,
              child: const Icon(Icons.fitness_center, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'AI Spor Koçu',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                Text(
                  'Çevrimiçi',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: isDark ? const Color(0xFF202C33) : const Color(0xFF075E54),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {
              // Options menu
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) {
                  // Loading indicator
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(left: 8, top: 8, bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF202C33) : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text('Yazıyor...', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  );
                }

                final message = _messages[index];
                return _buildMessageBubble(message, isDark);
              },
            ),
          ),
          // Input area
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF202C33) : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF2A3942) : Colors.grey[200],
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: "Mesaj yazın...",
                          hintStyle: TextStyle(
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: _isLoading || _messageController.text.trim().isEmpty
                        ? Colors.grey
                        : const Color(0xFF075E54),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white, size: 20),
                      onPressed: _isLoading ? null : _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessageUI message, bool isDark) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: message.isUser
              ? const Color(0xFFDCF8C6)
              : (isDark ? const Color(0xFF202C33) : Colors.white),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(8),
            topRight: const Radius.circular(8),
            bottomLeft: message.isUser ? const Radius.circular(8) : Radius.zero,
            bottomRight: message.isUser ? Radius.zero : const Radius.circular(8),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: message.isUser
                    ? Colors.black87
                    : (isDark ? Colors.white : Colors.black87),
                fontSize: 15,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.timestamp),
              style: TextStyle(
                color: message.isUser
                    ? Colors.black54
                    : (isDark ? Colors.grey[400] : Colors.grey[600]),
                fontSize: 11,
              ),
              textAlign: TextAlign.right,
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class ChatMessageUI {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessageUI({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

