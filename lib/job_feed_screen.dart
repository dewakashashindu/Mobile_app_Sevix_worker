import 'dart:async';

import 'package:flutter/material.dart';

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

class JobFeedScreen extends StatefulWidget {
  final List<WorkerJob> jobs;

  const JobFeedScreen({super.key, required this.jobs});

  @override
  State<JobFeedScreen> createState() => _JobFeedScreenState();
}

class _JobFeedScreenState extends State<JobFeedScreen> {
  double _maxDistance = 15;
  RangeValues _budgetRange = const RangeValues(1000, 10000);
  String _selectedCategory = 'All';
  String _selectedUrgency = 'All';

  List<String> get _categories {
    final set = <String>{'All', ...widget.jobs.map((e) => e.category)};
    return set.toList();
  }

  List<WorkerJob> get _filteredJobs {
    return widget.jobs.where((job) {
      final distanceMatch = job.distanceKm <= _maxDistance;
      final budgetMatch =
          job.budgetLkr >= _budgetRange.start &&
          job.budgetLkr <= _budgetRange.end;
      final categoryMatch =
          _selectedCategory == 'All' || job.category == _selectedCategory;
      final urgencyMatch =
          _selectedUrgency == 'All' || job.urgency == _selectedUrgency;

      return distanceMatch && budgetMatch && categoryMatch && urgencyMatch;
    }).toList();
  }

  Color _urgencyColor(String urgency) {
    switch (urgency) {
      case 'high':
        return const Color(0xFFEF4444);
      case 'medium':
        return const Color(0xFFF59E0B);
      case 'low':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF6B7280);
    }
  }

  @override
  Widget build(BuildContext context) {
    final jobs = _filteredJobs;

    return Scaffold(
      appBar: AppBar(title: const Text('Job Feed')),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filters',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                Text('Distance: up to ${_maxDistance.toStringAsFixed(1)} km'),
                Slider(
                  value: _maxDistance,
                  min: 1,
                  max: 30,
                  onChanged: (v) => setState(() => _maxDistance = v),
                ),
                Text(
                  'Budget: Rs. ${_budgetRange.start.round()} - Rs. ${_budgetRange.end.round()}',
                ),
                RangeSlider(
                  values: _budgetRange,
                  min: 500,
                  max: 20000,
                  divisions: 39,
                  onChanged: (v) => setState(() => _budgetRange = v),
                ),
                const SizedBox(height: 6),
                const Text('Category'),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  children: _categories
                      .map(
                        (category) => ChoiceChip(
                          label: Text(category),
                          selected: _selectedCategory == category,
                          onSelected: (_) {
                            setState(() {
                              _selectedCategory = category;
                            });
                          },
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 10),
                const Text('Urgency'),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  children: ['All', 'low', 'medium', 'high']
                      .map(
                        (urgency) => ChoiceChip(
                          label: Text(urgency.toUpperCase()),
                          selected: _selectedUrgency == urgency,
                          onSelected: (_) {
                            setState(() {
                              _selectedUrgency = urgency;
                            });
                          },
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Nearby Matching Jobs',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                Text('${jobs.length} results'),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: jobs.isEmpty
                ? const Center(
                    child: Text('No matching jobs. Try changing filters.'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                    itemCount: jobs.length,
                    itemBuilder: (context, index) {
                      final job = jobs[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => JobDetailScreen(job: job),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${job.category} • ${job.customerName}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _urgencyColor(
                                          job.urgency,
                                        ).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        job.urgency.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: _urgencyColor(job.urgency),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(job.location),
                                const SizedBox(height: 4),
                                Text(
                                  '${job.distanceKm.toStringAsFixed(1)} km • Rs. ${job.budgetLkr} • ${job.estimatedTime}',
                                  style: const TextStyle(color: Colors.black54),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    const Icon(Icons.timer_outlined, size: 16),
                                    const SizedBox(width: 6),
                                    _InlineCountdownText(
                                      deadline: job.bidDeadline,
                                    ),
                                    const Spacer(),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                JobDetailScreen(job: job),
                                          ),
                                        );
                                      },
                                      child: const Text('View Details'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class JobDetailScreen extends StatefulWidget {
  final WorkerJob job;

  const JobDetailScreen({super.key, required this.job});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateRemaining();
    });
  }

  void _updateRemaining() {
    final now = DateTime.now();
    final diff = widget.job.bidDeadline.difference(now);
    setState(() {
      _remaining = diff.isNegative ? Duration.zero : diff;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _durationText(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final h = d.inHours.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job;

    return Scaffold(
      appBar: AppBar(title: const Text('Job Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${job.category} Request',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text('Customer: ${job.customerName}'),
                    const SizedBox(height: 4),
                    Text('Budget: Rs. ${job.budgetLkr}'),
                    const SizedBox(height: 4),
                    Text('Estimated Time: ${job.estimatedTime}'),
                    const SizedBox(height: 4),
                    Text('Distance: ${job.distanceKm.toStringAsFixed(1)} km'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    const Icon(Icons.timer, color: Color(0xFFEF4444)),
                    const SizedBox(width: 8),
                    const Text(
                      'Bid window closes in:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    Text(
                      _durationText(_remaining),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFEF4444),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Map',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 160,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFDDE8FF), Color(0xFFF6FAFF)],
                        ),
                        border: Border.all(color: const Color(0xFFCFD8EA)),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.map_outlined,
                              size: 44,
                              color: Color(0xFF0B1533),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${job.latitude.toStringAsFixed(4)}, ${job.longitude.toStringAsFixed(4)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text('Map integration placeholder'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Customer Note',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(job.customerNote),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Photos',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 100,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (_, i) {
                          final label = job.photoLabels[i];
                          return Container(
                            width: 120,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: const LinearGradient(
                                colors: [Color(0xFFEDEFF5), Color(0xFFF8F9FC)],
                              ),
                              border: Border.all(
                                color: const Color(0xFFDFE2EA),
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.photo_camera_back_outlined),
                                const SizedBox(height: 6),
                                Text(
                                  label,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          );
                        },
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemCount: job.photoLabels.length,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (_remaining == Duration.zero) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Bid window has closed for this job request.',
                        ),
                      ),
                    );
                    return;
                  }

                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SubmitBidScreen(job: job),
                    ),
                  );
                },
                icon: const Icon(Icons.gavel),
                label: Text(
                  _remaining == Duration.zero
                      ? 'Bid Window Closed'
                      : 'Place Bid',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SubmitBidScreen extends StatefulWidget {
  final WorkerJob job;

  const SubmitBidScreen({super.key, required this.job});

  @override
  State<SubmitBidScreen> createState() => _SubmitBidScreenState();
}

class _SubmitBidScreenState extends State<SubmitBidScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _etaController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.job.budgetLkr.toString();
    _etaController.text = widget.job.estimatedTime;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _etaController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submitBid() async {
    final amount = int.tryParse(_amountController.text.trim());
    final eta = _etaController.text.trim();
    final note = _noteController.text.trim();

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter a valid bid amount')));
      return;
    }

    if (eta.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter ETA / completion duration')),
      );
      return;
    }

    setState(() {
      _submitting = true;
    });

    await Future.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;

    setState(() {
      _submitting = false;
    });

    final statuses = ['Pending', 'Accepted', 'Rejected'];
    final status = statuses[DateTime.now().second % 3];

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => BidStatusScreen(
          job: widget.job,
          bidAmount: amount,
          eta: eta,
          note: note,
          status: status,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Submit Bid')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.job.category} - ${widget.job.customerName}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text('Customer budget: Rs. ${widget.job.budgetLkr}'),
                    const SizedBox(height: 4),
                    Text('Location: ${widget.job.location}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Bid Amount (LKR)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _etaController,
              decoration: const InputDecoration(
                labelText: 'ETA / Completion Duration',
                hintText: 'e.g. 1-2 hours',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _noteController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Optional Note',
                hintText: 'Add details for the customer',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _submitting ? null : _submitBid,
                icon: _submitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
                label: Text(_submitting ? 'Submitting...' : 'Confirm & Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BidStatusScreen extends StatelessWidget {
  final WorkerJob job;
  final int bidAmount;
  final String eta;
  final String note;
  final String status;

  const BidStatusScreen({
    super.key,
    required this.job,
    required this.bidAmount,
    required this.eta,
    required this.note,
    required this.status,
  });

  Color _statusColor() {
    switch (status) {
      case 'Accepted':
        return const Color(0xFF10B981);
      case 'Rejected':
        return const Color(0xFFEF4444);
      case 'Pending':
      default:
        return const Color(0xFFF59E0B);
    }
  }

  IconData _statusIcon() {
    switch (status) {
      case 'Accepted':
        return Icons.check_circle;
      case 'Rejected':
        return Icons.cancel;
      case 'Pending':
      default:
        return Icons.schedule;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor();

    return Scaffold(
      appBar: AppBar(title: const Text('Bid Status')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(_statusIcon(), color: color, size: 36),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Current Bid Status',
                          style: TextStyle(color: Colors.black54),
                        ),
                        Text(
                          status,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${job.category} • ${job.customerName}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Your Bid: Rs. $bidAmount'),
                    const SizedBox(height: 4),
                    Text('ETA: $eta'),
                    const SizedBox(height: 4),
                    if (note.isNotEmpty) Text('Note: $note'),
                  ],
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text('Back To Home'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InlineCountdownText extends StatefulWidget {
  final DateTime deadline;

  const _InlineCountdownText({required this.deadline});

  @override
  State<_InlineCountdownText> createState() => _InlineCountdownTextState();
}

class _InlineCountdownTextState extends State<_InlineCountdownText> {
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _sync();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _sync());
  }

  void _sync() {
    final now = DateTime.now();
    final diff = widget.deadline.difference(now);
    setState(() {
      _remaining = diff.isNegative ? Duration.zero : diff;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = _remaining.inMinutes;
    final seconds = _remaining.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');

    if (_remaining == Duration.zero) {
      return const Text(
        'Bid closed',
        style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w700),
      );
    }

    return Text(
      '$minutes:$seconds left',
      style: const TextStyle(
        color: Color(0xFFEF4444),
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
