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
  final String selectedLanguage;

  const WorkHistoryScreen({
    super.key,
    required this.ongoingJobs,
    required this.completedJobs,
    this.selectedLanguage = 'en',
  });

  String _t(String en, String si, String ta) {
    switch (selectedLanguage) {
      case 'si':
        return si;
      case 'ta':
        return ta;
      case 'en':
      default:
        return en;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F6FC),
        appBar: AppBar(
          title: Text(_t('Work History', 'වැඩ ඉතිහාසය', 'வேலை வரலாறு')),
          bottom: TabBar(
            tabs: [
              Tab(
                text: _t(
                  'Ongoing Jobs',
                  'දැනට සිදු වන වැඩ',
                  'நடைபெறும் வேலைகள்',
                ),
              ),
              Tab(text: _t('Completed Jobs', 'නිම කළ වැඩ', 'முடிந்த வேலைகள்')),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _JobListTab(
              jobs: ongoingJobs,
              emptyText: _t(
                'No ongoing work',
                'දැනට සිදු වන වැඩ නොමැත',
                'நடைபெறும் வேலை இல்லை',
              ),
              selectedLanguage: selectedLanguage,
            ),
            _JobListTab(
              jobs: completedJobs,
              emptyText: _t(
                'No completed jobs yet',
                'තවම නිම කළ වැඩ නොමැත',
                'இன்னும் முடிந்த வேலை இல்லை',
              ),
              selectedLanguage: selectedLanguage,
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
  final String selectedLanguage;

  const _JobListTab({
    required this.jobs,
    required this.emptyText,
    required this.selectedLanguage,
  });

  @override
  State<_JobListTab> createState() => _JobListTabState();
}

class _JobListTabState extends State<_JobListTab> {
  String _t(String en, String si, String ta) {
    switch (widget.selectedLanguage) {
      case 'si':
        return si;
      case 'ta':
        return ta;
      case 'en':
      default:
        return en;
    }
  }

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

  String _statusLabel(String status) {
    final lower = status.toLowerCase();
    if (lower.contains('complete')) {
      return _t('Completed', 'අවසන්', 'முடிந்தது');
    }
    if (lower.contains('ongoing') || lower.contains('progress')) {
      return _t('Ongoing', 'දැනට සිදු වන', 'நடைபெறும்');
    }
    if (lower.contains('pending')) {
      return _t('Pending', 'පොරොත්තු', 'நிலுவையில்');
    }
    return status;
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
      return RefreshIndicator(
        onRefresh: _loadJobs,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 18),
          children: [
            const SizedBox(height: 60),
            ErrorStateView(
              type: _errorType!,
              onRetry: _loadJobs,
              selectedLanguage: widget.selectedLanguage,
            ),
          ],
        ),
      );
    }

    if (_isLoading) {
      return RefreshIndicator(
        onRefresh: _loadJobs,
        child: ShimmerSkeleton(
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
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
        ),
      );
    }

    if (widget.jobs.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadJobs,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 18),
          children: [
            const SizedBox(height: 80),
            Center(
              child: Text(
                widget.emptyText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF64748B),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final visibleJobs = widget.jobs.take(_visibleCount).toList();

    return RefreshIndicator(
      onRefresh: _loadJobs,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
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
                          _statusLabel(job.status),
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
                    '${_t('Customer', 'පාරිභෝගිකයා', 'வாடிக்கையாளர்')}: ${job.customerName}',
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
      ),
    );
  }
}
