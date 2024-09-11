import 'package:cgpt/consts.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {



  final _OpenAI = OpenAI.instance.build(
    token: OPENAI_API_KEY,
     baseOption: HttpSetup(
      receiveTimeout: const Duration(
        seconds: 5,
        ),
        ),
        enableLog: true,
        );



 final ChatUser _currentUser =
   ChatUser(id: '1', firstName: 'Lavanya', lastName: 'inti');

  final ChatUser _gptchatUser =
   ChatUser(id: '2', firstName: 'chat', lastName: 'GPT');

   List<ChatMessage> _messages = <ChatMessage>[];
   List<ChatUser> _typingUsers = <ChatUser>[];
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(
      backgroundColor: const Color.fromRGBO(
        0,166,126,1,
        ),
        title: const Text(
          'GPT Chat',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        ),
        body: DashChat(
          currentUser: _currentUser,
          typingUsers: _typingUsers,
          messageOptions: const MessageOptions(
            currentUserContainerColor: Colors.black,
            containerColor: Color.fromRGBO(
              0,
              166,
              126,
              1,
            ),
            textColor: Colors.white,
          ),
         onSend: (ChatMessage m) {
          getChatResponse(m);

        }, messages: _messages),
        );
  }

  Future<void> getChatResponse(ChatMessage m) async {
   setState(() {
     _messages.insert(0, m);
     _typingUsers.add(_gptchatUser);
   });
  List<Map<String, dynamic>> messagesHistory =
        _messages.reversed.toList().map((m) {
      if (m.user == '_user') {
        return Messages(role: Role.user, content: m.text).toJson();
      } else {
        return Messages(role: Role.assistant, content: m.text).toJson();
      }
    }).toList();
    final request = ChatCompleteText(
      messages: messagesHistory,
      maxToken: 200,
      model: GptTurbo0301ChatModel(),
    );
     final response =await _OpenAI.onChatCompletion(request: request);
     for (var element in response!.choices) {
      if (element.message !=null) {
        setState(() {
          _messages.insert(
            0, 
            ChatMessage(
              user: _gptchatUser,
               createdAt: DateTime.now(),
                text: element.message!.content)
                );
        });
      }
     }
     setState(() {
       _typingUsers.remove(_gptchatUser);
     });
  }
}