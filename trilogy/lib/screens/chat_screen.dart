import 'dart:developer';
import '../providers/chats_provider.dart';
import '../widgets/chat_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import '../providers/models_provider.dart';
import '../widgets/text_widget.dart';

// This class is a widget that represents the screen that the user and chatbot exchange messages.
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool _isTyping = false;
  late TextEditingController textEditingController;
  late ScrollController _listScrollController;
  late FocusNode focusNode;

  @override
  void initState() {
    _listScrollController = ScrollController();
    textEditingController = TextEditingController();
    focusNode = FocusNode();
    super.initState();
  }

  // Called when this object is removed from the tree permanently.
  @override
  void dispose() {
    _listScrollController.dispose();
    textEditingController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  // This represents the actual layout of the chat screen.
  @override
  Widget build(BuildContext context) {
    final modelsProvider = Provider.of<ModelsProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context);
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 253, 253),
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 32, top: 32),
              child: Text(
                'Helix Helper',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 32,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 70),
                child: ListView.builder(
                    controller: _listScrollController,
                    itemCount: chatProvider.getChatList.length,
                    itemBuilder: (context, index) {
                      return ChatWidget(
                        msg: chatProvider.getChatList[index].msg,
                        chatIndex: chatProvider.getChatList[index].chatIndex,
                        shouldAnimate:
                            chatProvider.getChatList.length - 1 == index,
                      );
                    }),
              ),
            ),
            if (_isTyping) ...[
              const SpinKitThreeBounce(
                color: Colors.black,
                size: 18,
              ),
            ],
            const SizedBox(
              height: 10,
            ),
            Material(
              color: Color.fromARGB(255, 248, 248, 248),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    18, 18, 18, 120), // Adjust bottom padding here
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        focusNode: focusNode,
                        style: const TextStyle(color: Colors.black),
                        controller: textEditingController,
                        onSubmitted: (value) async {
                          await sendMessageFCT(
                              modelsProvider: modelsProvider,
                              chatProvider: chatProvider);
                        },
                        decoration: const InputDecoration.collapsed(
                            hintText: "How can I help you?",
                            hintStyle: TextStyle(color: Colors.grey)),
                      ),
                    ),
                    IconButton(
                        onPressed: () async {
                          await sendMessageFCT(
                              modelsProvider: modelsProvider,
                              chatProvider: chatProvider);
                        },
                        icon: const Icon(
                          Icons.send,
                          color: Colors.black,
                        ))
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // The latest message is always shown first.
  void scrollListToEND() {
    _listScrollController.animateTo(
        _listScrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 2),
        curve: Curves.easeOut);
  }

  // Requires pauses in between sending of messages, so that chatbot has time to respond.
  Future<void> sendMessageFCT(
      {required ModelsProvider modelsProvider,
      required ChatProvider chatProvider}) async {
    if (_isTyping) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: TextWidget(
            label: "You cant send multiple messages at a time",
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    // Input validation.
    if (textEditingController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: TextWidget(
            label: "Please type a message",
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    } else {
      try {
        String msg = textEditingController.text;
        setState(() {
          _isTyping = true;
          chatProvider.addUserMessage(msg: msg);
          textEditingController.clear();
          focusNode.unfocus();
        });
        await chatProvider.sendMessageAndGetAnswers(
            msg: msg, chosenModelId: modelsProvider.getCurrentModel);
        setState(() {});
      } catch (error) {
        log("error $error");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: TextWidget(
            label: error.toString(),
          ),
          backgroundColor: Colors.red,
        ));
      } finally {
        setState(() {
          scrollListToEND();
          _isTyping = false;
        });
      }
    }
  }
}
