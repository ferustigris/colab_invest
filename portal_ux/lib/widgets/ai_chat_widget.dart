import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:portal_ux/data/app_constants.dart';
import 'package:portal_ux/data/app_styles.dart';
import 'package:portal_ux/l10n/app_localizations.dart';
import 'package:portal_ux/data/state_notifiers.dart';
import 'package:portal_ux/utils/is_mobile_view_port.dart';

class AIChatWidget extends StatefulWidget {
  const AIChatWidget({super.key});

  @override
  State<AIChatWidget> createState() => _AIChatWidgetState();
}

class _AIChatWidgetState extends State<AIChatWidget> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;
  late FocusNode inputFocusNode;
  bool _isLoadingHistory = false;
  Timer? _historyTimer;

  @override
  void initState() {
    super.initState();
    inputFocusNode = FocusNode();
    _loadChatHistory();
    _startHistoryTimer();
  }

  @override
  void dispose() {
    _historyTimer?.cancel();
    inputFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String userMarker =
        AppLocalizations.of(context)!.aiAssistantChatUserMarker;

    return Column(
      children: [
        Text(
          AppLocalizations.of(context)!.aiAssistantPageTitle,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const Divider(),
        Expanded(
          child: ListView(
            controller: scrollController,
            children:
                _messages
                    .map(
                      (msg) => Text(
                        "${msg['author']}: ${msg['content']}",
                        style:
                            msg['author']!.startsWith(userMarker)
                                ? AppStyles.aiUserTextStyle
                                : AppStyles.aiAssistantTextStyle,
                      ),
                    )
                    .toList() +
                [
                  isMobileViewPort(context) ? Text("") : (Text("\n\n\n")),
                ], // crutch mitigating autoscroll flaw in corner-popup chat display
          ),
        ),
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(8),
            child: CircularProgressIndicator(),
          ),
        Row(
          children: [
            Expanded(
              child: TextField(
                autofocus: true,
                focusNode: inputFocusNode,
                controller: _controller,
                decoration: InputDecoration(
                  hintText:
                      AppLocalizations.of(
                        context,
                      )!.aiAssistantChatInputPlaceholder,
                ),
                onSubmitted: _sendMessage,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: () => _sendMessage(_controller.text),
            ),
          ],
        ),
      ],
    );
  }

  void _startHistoryTimer() {
    _historyTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _loadChatHistory();
    });
  }

  Future<void> _loadChatHistory() async {
    if (_isLoading || _isLoadingHistory) return; // Prevent multiple requests

    setState(() {
      _isLoadingHistory = true;
    });

    try {
      final idToken = await StateNotifiers.user.value!.getIdToken();

      final response = await http.get(
        Uri.parse(
          "${AppConstants.aiChatHistoryUrl}/chat_history.${StateNotifiers.user.value!.uid}.json",
        ),
        headers: {
          'Content-Type': 'application/json',
          'Accept': '*/*',
          'Authorization': 'Bearer $idToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));

        if (data['chat_history'] != null) {
          final List<dynamic> historyMessages = data['chat_history'];

          setState(() {
            _messages.clear();
            _messages.addAll(
              historyMessages
                  .map(
                    (msg) => {
                      'author': msg['role']?.toString() ?? 'Unknown',
                      'content': msg['content']?.toString() ?? '',
                      'timestamp':
                          msg['timestamp']?.toString() ??
                          DateTime.now().millisecondsSinceEpoch.toString(),
                    },
                  )
                  .toList(),
            );
          });

          // Scroll to end when updating messages
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (scrollController.hasClients) {
              scrollController.jumpTo(
                scrollController.position.maxScrollExtent,
              );
            }
          });
        }
      } else {
        // Log error but don't show to user
        debugPrint('Failed to load chat history: ${response.statusCode}');
        debugPrint('Response body: ${utf8.decode(response.bodyBytes)}');
      }
    } catch (e) {
      // Log error but don't show to user
      debugPrint('Error loading chat history: $e');
    } finally {
      setState(() {
        _isLoadingHistory = false;
      });
    }
  }

  Future<void> _sendMessage(String userInput) async {
    final String userMarker =
        AppLocalizations.of(context)!.aiAssistantChatUserMarker;

    if (userInput.trim().isEmpty) return;

    setState(() {
      _messages.add({"author": userMarker, "content": userInput});
      _controller.clear();
      _isLoading = true;
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
    });

    try {
      final idToken = await StateNotifiers.user.value!.getIdToken();
      final response = await http.post(
        Uri.parse(AppConstants.aiModelEndpointUrl),
        headers: {
          'Content-Type': 'application/json',
          "Accept": "*/*",
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({
          "messages": [
            ..._messages.map(
              (msg) => {
                "role": msg["author"] == userMarker ? "user" : "assistant",
                "content": msg["content"],
              },
            ),
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = utf8.decode(response.bodyBytes);
        setState(() {
          _messages.add({"author": "Natalia", "content": data});
          atResponse();
        });
      } else {
        setState(() {
          _messages.add({
            "author": "System",
            "content":
                'Decode error: ${utf8.decode(response.bodyBytes)}', // Decode error
          });
          atResponse();
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({
          "author": "System",
          "content": 'Request error: ${utf8.decode(utf8.encode(e.toString()))}',
        }); // Decode exception
        atResponse();
      });
    }
  }

  void atResponse() {
    _isLoading = false;
    scrollController.jumpTo(scrollController.position.maxScrollExtent);
    inputFocusNode.requestFocus();
  }
}
