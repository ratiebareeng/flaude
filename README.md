# Flutter Claude Chat Clone

A beautiful, responsive Flutter application that provides a chat interface for interacting with Anthropic's Claude AI assistant via the Claude API. Built with modern Flutter practices and a clean, intuitive user interface.

## ✨ Features

- **Real-time Chat Interface** - Smooth, responsive chat experience with Claude AI
- **Claude API Integration** - Direct integration with Anthropic's Claude API
- **Modern UI/UX** - Clean, Material Design-inspired interface
- **Message History** - Persistent conversation history
- **Typing Indicators** - Visual feedback during AI response generation
- **Markdown Support** - Rich text formatting for AI responses
- **Cross-platform** - Runs on iOS, Android, Web, and Desktop
- **Dark/Light Theme** - Adaptive theming support
- **Offline Support** - Graceful handling of network connectivity issues

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK (2.17.0 or higher)
- An Anthropic API key ([Get yours here](https://console.anthropic.com/))

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/flutter-claude-chat.git
   cd flutter-claude-chat
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure API Key**
   
   Create a `.env` file in the root directory and add your Claude API key:
   ```env
   CLAUDE_API_KEY=your_api_key_here
   ```
   
   Alternatively, you can enter your API key directly in the app settings.

4. **Run the app**
   ```bash
   flutter run
   ```

## 📱 Screenshots

[Add screenshots of your app here]

## 🏗️ Architecture

The app follows a clean architecture pattern with:

- **Presentation Layer** - Flutter widgets and state management
- **Domain Layer** - Business logic and use cases
- **Data Layer** - API integration and data persistence

### Key Technologies

- **State Management** - Provider/Riverpod/Bloc (specify which you used)
- **HTTP Client** - Dio for API requests
- **Local Storage** - Hive/SQLite for message persistence
- **Dependency Injection** - GetIt/Provider (specify which you used)

## 🔧 Configuration

### API Configuration

The app uses the Claude API with the following default settings:
- Model: `claude-3-sonnet-20240229`
- Max tokens: 4096
- Temperature: 0.7

You can modify these settings in the app's configuration screen.

### Environment Variables

Create a `.env` file with the following variables:
```env
CLAUDE_API_KEY=your_claude_api_key
API_BASE_URL=https://api.anthropic.com
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

### Development Setup

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Code Style

- Follow Flutter/Dart best practices
- Use meaningful variable and function names
- Add comments for complex logic
- Ensure all tests pass before submitting PR

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## ⚠️ Disclaimer

This is an unofficial Claude chat client. It is not affiliated with, endorsed by, or sponsored by Anthropic. Claude is a trademark of Anthropic.

## 🙏 Acknowledgments

- [Anthropic](https://www.anthropic.com/) for the Claude API
- Flutter team for the amazing framework
- Open source community for inspiration and packages

## 📞 Support

If you have any questions or run into issues, please:
1. Check the [Issues](https://github.com/yourusername/flutter-claude-chat/issues) page
2. Create a new issue if your problem isn't already reported
3. Provide detailed information about your setup and the issue

## 🗺️ Roadmap

- [ ] Voice input/output support
- [ ] Multiple conversation threads
- [ ] Message search functionality
- [ ] Export conversations
- [ ] Custom themes
- [ ] Plugin system for extensions
- [ ] Desktop-specific optimizations

---

**Made with ❤️ by [Your Name]**
