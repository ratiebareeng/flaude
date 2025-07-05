import 'package:claude_chat_clone/models/models.dart';
import 'package:flutter/material.dart';

class ChatItem extends StatelessWidget {
  final Chat chat;
  final Function(String chatId)? onChatSelected;
  const ChatItem({super.key, required this.chat, this.onChatSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => onChatSelected,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              // Chat Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.chat_outlined,
                  color: Colors.grey[400],
                  size: 20,
                ),
              ),

              SizedBox(width: 12),

              // Chat Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Chat Title
                    Text(
                      chat.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: 4),

                    // Last Message Time
                    Text(
                      'Last message ${chat.updatedAt?.asTimeAgo}',
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              // Options Menu
              IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.delete_forever_outlined,
                    color: Colors.grey,
                  )),
              // PopupMenuButton<String>(
              //   icon: Icon(
              //     Icons.more_vert,
              //     color: Colors.grey[400],
              //     size: 20,
              //   ),
              //   color: Color(0xFF3A3A3A),
              //   onSelected: (value) => _handleChatAction(value, chat),
              //   itemBuilder: (context) => [
              //     PopupMenuItem(
              //       value: 'rename',
              //       child: Row(
              //         children: [
              //           Icon(Icons.edit, color: Colors.white, size: 16),
              //           SizedBox(width: 8),
              //           Text('Rename', style: TextStyle(color: Colors.white)),
              //         ],
              //       ),
              //     ),
              //     PopupMenuItem(
              //       value: 'delete',
              //       child: Row(
              //         children: [
              //           Icon(Icons.delete, color: Colors.red, size: 16),
              //           SizedBox(width: 8),
              //           Text('Delete', style: TextStyle(color: Colors.red)),
              //         ],
              //       ),
              //     ),
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
