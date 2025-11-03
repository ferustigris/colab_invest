import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:portal_ux/widgets/ai_chat_widget.dart';

class AIPopUpChat extends StatefulWidget {
  const AIPopUpChat({super.key});

  @override
  State<AIPopUpChat> createState() => _AIPopUpChatState();
}

class _AIPopUpChatState extends State<AIPopUpChat> {
  bool _isChatOpen = false;

  @override
  Widget build(BuildContext context) {

    return Stack(
      children: [
        // Button
        Positioned(
          bottom: 20,
          right: 20,
          child: PointerInterceptor(
            child: FloatingActionButton(
              onPressed: () {
                setState(() {
                  _isChatOpen = !_isChatOpen;
                });
              },
              child: Icon(_isChatOpen ? Icons.close : Icons.chat),
            ),
          ),
        ),

        if (_isChatOpen)
          Positioned(
            bottom: 80,
            right: 20,
            child: Material(
              elevation: 10,
              borderRadius: BorderRadius.circular(12),
              child: PointerInterceptor(
                child: Container(
                  width: 300,
                  height: 400,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).canvasColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Theme.of(context).primaryColorLight, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).shadowColor,
                        blurRadius: 4,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  child: AIChatWidget(),
                ),
              ),
            ),
          ),
      ],
    );
  }

}
