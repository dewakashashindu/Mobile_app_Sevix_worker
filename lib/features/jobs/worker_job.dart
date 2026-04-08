class WorkerJob {
  final String id;
  final String customerName;
  final String category;
  final String location;
  final double distanceKm;
  final int budgetLkr;
  final String urgency; // low, medium, high
  final String estimatedTime;
  final String customerNote;
  final List<String> photoLabels;
  final double latitude;
  final double longitude;
  final DateTime bidDeadline;

  const WorkerJob({
    required this.id,
    required this.customerName,
    required this.category,
    required this.location,
    required this.distanceKm,
    required this.budgetLkr,
    required this.urgency,
    required this.estimatedTime,
    required this.customerNote,
    required this.photoLabels,
    required this.latitude,
    required this.longitude,
    required this.bidDeadline,
  });
}

