// lib/screens/evaluation_page.dart
import 'package:flutter/material.dart';

class EvaluationPage extends StatefulWidget {
  const EvaluationPage({super.key});

  @override
  State<EvaluationPage> createState() => _EvaluationPageState();
}

class _EvaluationPageState extends State<EvaluationPage> {
  // State variables for form values
  double _understandingLevel = 3.0;
  final TextEditingController _feedbackController = TextEditingController();
  String _selectedDifficulty = 'Tidak Ada';

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Evaluasi Pembelajaran"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.assignment_ind_outlined, size: 40, color: Colors.blue),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      "Silakan isi formulir ini untuk mengevaluasi pemahaman Anda terhadap materi arsitektur.",
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Question 1: Slider
            const Text(
              "1. Seberapa paham Anda dengan materi yang telah dipelajari?",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text("Kurang"),
                Expanded(
                  child: Slider(
                    value: _understandingLevel,
                    min: 1,
                    max: 5,
                    divisions: 4,
                    label: _understandingLevel.round().toString(),
                    onChanged: (double value) {
                      setState(() {
                        _understandingLevel = value;
                      });
                    },
                  ),
                ),
                const Text("Sangat Paham"),
              ],
            ),
            const Divider(height: 40),

            // Question 2: Dropdown / Radio
            const Text(
              "2. Bagian mana yang menurut Anda paling sulit?",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children: [
                _buildChoiceChip("Tidak Ada"),
                _buildChoiceChip("Sejarah"),
                _buildChoiceChip("Teknis Struktur"),
                _buildChoiceChip("Visualisasi 3D"),
              ],
            ),
            const Divider(height: 40),

            // Question 3: Text Input
            const Text(
              "3. Saran atau pertanyaan untuk pengajar:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _feedbackController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Tulis saran Anda di sini...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 30),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Terima kasih! Evaluasi Anda telah dikirim."),
                      backgroundColor: Colors.green,
                    ),
                  );
                  // Optional: Navigate back
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Kirim Evaluasi", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceChip(String label) {
    return ChoiceChip(
      label: Text(label),
      selected: _selectedDifficulty == label,
      onSelected: (bool selected) {
        setState(() {
          _selectedDifficulty = label;
        });
      },
    );
  }
}