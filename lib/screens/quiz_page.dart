// lib/screens/quiz_page.dart
import 'package:flutter/material.dart';
import '../quiz_data.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

// Helper class to store the shuffled state of a single question
class QuizSessionItem {
  final QuizQuestion question;
  final List<String> shuffledOptions;
  final int correctOptionIndex; 

  QuizSessionItem({
    required this.question, 
    required this.shuffledOptions, 
    required this.correctOptionIndex
  });
}

class _QuizPageState extends State<QuizPage> {
  List<QuizSessionItem> _sessionItems = [];
  
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _isFinished = false;

  @override
  void initState() {
    super.initState();
    _startNewQuiz();
  }

  void _startNewQuiz() {
    // 1. Get random questions
    List<QuizQuestion> allQuestions = List.from(masterQuizList);
    allQuestions.shuffle();
    
    int takeCount = allQuestions.length < 50 ? allQuestions.length : 50;
    List<QuizQuestion> selectedQuestions = allQuestions.sublist(0, takeCount);

    // 2. Shuffle options for each question
    List<QuizSessionItem> processedItems = selectedQuestions.map((q) {
      String correctAnswerText = q.options[q.correctIndex];
      List<String> currentOptions = List.from(q.options);
      currentOptions.shuffle();
      int newCorrectIndex = currentOptions.indexOf(correctAnswerText);

      return QuizSessionItem(
        question: q,
        shuffledOptions: currentOptions,
        correctOptionIndex: newCorrectIndex,
      );
    }).toList();
    
    setState(() {
      _sessionItems = processedItems;
      _currentQuestionIndex = 0;
      _score = 0;
      _isFinished = false;
    });
  }

  void _answerQuestion(int selectedIndex) {
    if (_sessionItems[_currentQuestionIndex].correctOptionIndex == selectedIndex) {
      _score++;
    }

    setState(() {
      if (_currentQuestionIndex < _sessionItems.length - 1) {
        _currentQuestionIndex++;
      } else {
        _isFinished = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kuis Arsitektur"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800), // Limit width for web
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: _sessionItems.isEmpty 
                ? const Center(child: CircularProgressIndicator()) 
                : (_isFinished ? _buildResultScreen() : _buildQuizScreen()),
          ),
        ),
      ),
    );
  }

  Widget _buildQuizScreen() {
    final sessionItem = _sessionItems[_currentQuestionIndex];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Progress
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / _sessionItems.length,
            minHeight: 10,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.secondary),
          ),
        ),
        const SizedBox(height: 20),
        
        Text(
          "Pertanyaan ${_currentQuestionIndex + 1} / ${_sessionItems.length}",
          style: TextStyle(color: Colors.grey[600], fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),

        // Question Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
            ],
          ),
          child: Text(
            sessionItem.question.text,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, height: 1.4),
          ),
        ),
        const SizedBox(height: 25),

        // Options
        Expanded(
          child: ListView.separated(
            itemCount: sessionItem.shuffledOptions.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _buildOptionButton(sessionItem.shuffledOptions[index], index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOptionButton(String text, int index) {
    return ElevatedButton(
      onPressed: () => _answerQuestion(index),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        alignment: Alignment.centerLeft,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            child: Text(
              String.fromCharCode(65 + index), // A, B, C, D
              style: TextStyle(
                fontSize: 12, 
                color: Theme.of(context).colorScheme.primary, 
                fontWeight: FontWeight.bold
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 15)),
          ),
        ],
      ),
    );
  }

  Widget _buildResultScreen() {
    double percentage = (_score / _sessionItems.length) * 100;
    Color resultColor = percentage >= 70 ? Colors.green : Colors.orange;
    String message = percentage >= 70 ? "Luar Biasa!" : "Terus Belajar!";

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            percentage >= 70 ? Icons.emoji_events_rounded : Icons.menu_book_rounded, 
            size: 100, 
            color: resultColor
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            "Skor Anda",
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          Text(
            "$_score / ${_sessionItems.length}",
            style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: resultColor),
          ),
          const SizedBox(height: 40),
          
          ElevatedButton.icon(
            onPressed: _startNewQuiz,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text("Coba Lagi (Soal Baru)"),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              textStyle: const TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Kembali ke Menu Utama"),
          ),
        ],
      ),
    );
  }
}