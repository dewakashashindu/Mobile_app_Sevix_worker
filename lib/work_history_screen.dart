import 'package:flutter/material.dart';

import 'error_state_view.dart';
import 'shimmer_skeleton.dart';

class WorkHistoryJob {
  final String jobTitle;
  final String customerName;
  final DateTime date;
  final String earnings;
  final String status;

  const WorkHistoryJob({
    required this.jobTitle,
    required this.customerName,
    required this.date,
    required this.earnings,
    required this.status,
  });
}

class WorkHistoryScreen extends StatelessWidget {
  final List<WorkHistoryJob> ongoingJobs;
  final List<WorkHistoryJob> completedJobs;

  const WorkHistoryScreen({
    super.key,
    required this.ongoingJobs,
    required this.completedJobs,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F6FC),
        appBar: AppBar(
          title: const Text('Work History'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Ongoing Jobs'),
              Tab(text: 'Completed Jobs'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _JobListTab(jobs: ongoingJobs, emptyText: 'No ongoing work'),
            _JobListTab(
              jobs: completedJobs,
              emptyText: 'No completed jobs yet',
            ),
          ],
        ),
      ),
    );
  }
}

class _JobListTab extends StatefulWidget {
  final List<WorkHistoryJob> jobs;
  final String emptyText;

  const _JobListTab({required this.jobs, required this.emptyText});

  @override
  State<_JobListTab> createState() => _JobListTabState();
}

class _JobListTabState extends State<_JobListTab> {
  final ScrollController _scrollController = ScrollController();
  int _visibleCount = 8;
  bool _isLoading = true;
  LoadErrorType? _errorType;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final threshold = _scrollController.position.maxScrollExtent - 180;
    if (_scrollController.position.pixels >= threshold &&
        _visibleCount < widget.jobs.length) {
      setState(() {
        _visibleCount = (_visibleCount + 8).clamp(0, widget.jobs.length);
      });
    }
  }

  Color _statusColor(String status) {
    final lower = status.toLowerCase();
    if (lower.contains('complete')) return const Color(0xFF16A34A);
    if (lower.contains('progress') || lower.contains('ongoing')) {
      return const Color(0xFF2563EB);
    }
    if (lower.contains('pending')) return const Color(0xFFF59E0B);
    return const Color(0xFF64748B);
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }

  @override
  Widget build(BuildContext context) {
    if (_errorType != null) {
      return ErrorStateView(type: _errorType!, onRetry: _loadJobs);
    }

    if (_isLoading) {
      return ShimmerSkeleton(
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 18),
          itemCount: 6,
          itemBuilder: (_, index) {
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: SkeletonBox(height: 16)),
                        SizedBox(width: 10),
                        SkeletonBox(width: 72, height: 18),
                      ],
                    ),
                    SizedBox(height: 10),
                    SkeletonBox(width: 180, height: 12),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        SkeletonBox(width: 70, height: 12),
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
      );
    }

    if (widget.jobs.isEmpty) {
      return Center(
        child: Text(
          widget.emptyText,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF64748B),
          ),
        ),
      );
    }

    final visibleJobs = widget.jobs.take(_visibleCount).toList();

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 18),
      itemCount: visibleJobs.length,
      itemBuilder: (context, index) {
        final job = visibleJobs[index];
        final statusColor = _statusColor(job.status);

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        job.jobTitle,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        job.status,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Customer: ${job.customerName}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF334155),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_month_outlined,
                      size: 16,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _formatDate(job.date),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 16,
                      color: Color(0xFF0F172A),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      job.earnings,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF0F172A),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
