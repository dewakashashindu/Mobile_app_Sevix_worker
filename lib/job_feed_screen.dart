import 'dart:async';

import 'package:flutter/material.dart';

import 'bid_status_screen.dart';
import 'error_state_view.dart';
import 'job_detail_screen.dart';
import 'shimmer_skeleton.dart';
import 'worker_job.dart';

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
  bool _isLoading = true;
  LoadErrorType? _errorType;

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  Future<void> _loadJobs() async {
    setState(() {
      _isLoading = true;
      _errorType = null;
    });

    try {
      await Future<void>.delayed(const Duration(milliseconds: 900));
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorType = LoadErrorType.data;
      });
    }
  }

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

  double _recommendationScore(WorkerJob job) {
    final urgencyBoost = switch (job.urgency) {
      'high' => 30.0,
      'medium' => 20.0,
      _ => 10.0,
    };

    final distanceScore = (30 - job.distanceKm).clamp(0, 30);
    final budgetScore = (job.budgetLkr / 1000).clamp(0, 40).toDouble();

    return urgencyBoost + distanceScore + budgetScore;
  }

  List<WorkerJob> get _recommendedJobs {
    final sorted = List<WorkerJob>.from(_filteredJobs)
      ..sort(
        (a, b) => _recommendationScore(b).compareTo(_recommendationScore(a)),
      );
    return sorted.take(3).toList();
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

  void _openBidStatus() {
    final source = _filteredJobs.isNotEmpty
        ? _filteredJobs.first
        : (widget.jobs.isNotEmpty ? widget.jobs.first : null);

    if (source == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No jobs available for bid status yet.')),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BidStatusScreen(
          job: source,
          bidAmount: source.budgetLkr,
          eta: source.estimatedTime,
          note: '',
          status: 'Pending',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final jobs = _filteredJobs;
    final recommendedIds = _recommendedJobs.map((e) => e.id).toSet();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Feed'),
        actions: [
          TextButton.icon(
            onPressed: _openBidStatus,
            icon: const Icon(Icons.assignment_turned_in_outlined, size: 18),
            label: const Text('Bid Status'),
          ),
          const SizedBox(width: 8),
        ],
      ),
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
          if (!_isLoading && _errorType == null && _recommendedJobs.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _recommendedJobs
                      .map(
                        (job) => Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECF3FF),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: const Color(0xFFCFE0FF)),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.auto_awesome,
                                size: 14,
                                color: Color(0xFF1D4ED8),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                '${job.category} • Recommended for you',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF1E3A8A),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          const SizedBox(height: 6),
          Expanded(
            child: _isLoading
                ? ShimmerSkeleton(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                      itemCount: 6,
                      itemBuilder: (_, index) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    SkeletonBox(width: 190, height: 16),
                                    Spacer(),
                                    SkeletonBox(width: 56, height: 20),
                                  ],
                                ),
                                SizedBox(height: 10),
                                SkeletonBox(width: 220, height: 12),
                                SizedBox(height: 8),
                                SkeletonBox(width: 180, height: 12),
                                SizedBox(height: 12),
                                Row(
                                  children: [
                                    SkeletonBox(width: 90, height: 12),
                                    Spacer(),
                                    SkeletonBox(width: 80, height: 12),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : _errorType != null
                ? ErrorStateView(type: _errorType!, onRetry: _loadJobs)
                : jobs.isEmpty
                ? const Center(
                    child: Text('No matching jobs. Try changing filters.'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                    itemCount: jobs.length,
                    itemBuilder: (context, index) {
                      final job = jobs[index];
                      final isRecommended = recommendedIds.contains(job.id);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(
                            color: isRecommended
                                ? const Color(0xFFC7DAFF)
                                : Colors.transparent,
                          ),
                        ),
                        color: isRecommended
                            ? const Color(0xFFF8FBFF)
                            : Colors.white,
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
                                if (isRecommended)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEAF2FF),
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                      ),
                                      child: const Text(
                                        'Recommended for you',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF1D4ED8),
                                        ),
                                      ),
                                    ),
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
