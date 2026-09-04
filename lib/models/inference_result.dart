class PredictionCandidate {
  final String label;
  final double confidence; // 0.0 to 1.0

  const PredictionCandidate({
    required this.label,
    required this.confidence,
  });

  double get confidencePercentage => confidence * 100.0;
}

class InferenceResult {
  final String topLabel;
  final double topConfidence; // 0.0 to 1.0
  final List<PredictionCandidate> topCandidates;
  final bool isConfident; // >= threshold (0.6)
  final Duration inferenceLatency;

  const InferenceResult({
    required this.topLabel,
    required this.topConfidence,
    required this.topCandidates,
    required this.isConfident,
    required this.inferenceLatency,
  });

  double get confidencePercentage => topConfidence * 100.0;
}
