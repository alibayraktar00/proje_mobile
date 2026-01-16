import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/ai_service.dart';

class AIAssistantScreen extends ConsumerStatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  ConsumerState<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends ConsumerState<AIAssistantScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  // Chat history with local state
  final List<Map<String, String>> _messages = [
    {"role": "assistant", "content": "Merhaba! Ben senin GymBuddy AI asistanın. Antrenman, beslenme veya supplementler hakkında sorular sorabilirsin!"}
  ];
  
  bool _isLoading = false;
  late final AIService _aiService;

  @override
  void initState() {
    super.initState();
    _aiService = ref.read(aiServiceProvider);
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    if (_isLoading) return;

    setState(() {
      _messages.add({"role": "user", "content": text});
      _isLoading = true;
    });
    _controller.clear();
    _scrollToBottom();

    try {
      final responseText = await _aiService.sendMessage(text);

      if (mounted) {
        setState(() {
           _messages.add({"role": "assistant", "content": responseText});
           _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = "Üzgünüm, bir hata oluştu.";
        if (e.toString().contains('API_KEY') || e.toString().contains('401')) {
          errorMessage = "API key hatası. Lütfen .env dosyanızı kontrol edin.";
        } else if (e.toString().contains('network') || e.toString().contains('connection')) {
          errorMessage = "İnternet bağlantınızı kontrol edin.";
        } else if (e.toString().contains('quota') || e.toString().contains('limit')) {
          errorMessage = "API kotası doldu. Lütfen daha sonra tekrar deneyin.";
        } else {
          errorMessage = "Hata: ${e.toString()}";
        }
        
        setState(() {
          _messages.add({"role": "assistant", "content": errorMessage});
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("AI Assistant", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: theme.cardColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) {
                   return const Align(
                     alignment: Alignment.centerLeft,
                     child: Padding(
                       padding: EdgeInsets.only(left: 16, top: 8),
                       child: SizedBox(
                         width: 24, height: 24, 
                         child: CircularProgressIndicator(strokeWidth: 2)
                       ),
                     ),
                   );
                }

                final msg = _messages[index];
                final isUser = msg['role'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blueAccent : theme.cardColor,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(20),
                        topRight: const Radius.circular(20),
                        bottomLeft: isUser ? const Radius.circular(20) : Radius.zero,
                        bottomRight: isUser ? Radius.zero : const Radius.circular(20),
                      ),
                      boxShadow: [
                         if (!isUser) BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg['content']!,
                          style: TextStyle(
                            color: isUser ? Colors.white : theme.textTheme.bodyLarge?.color,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                )
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: "Ask about workouts, diet...",
                      filled: true,
                      fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: _isLoading ? Colors.grey : Colors.blueAccent,
                  radius: 24,
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
