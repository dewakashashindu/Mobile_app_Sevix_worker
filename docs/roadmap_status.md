# SEVIX Worker Roadmap Status

## Scope of Evaluation

This assessment mapped requested roadmap features against the current Flutter workspace and identified immediate implementation actions.

## Status Matrix

- Trust Score Badge: Implemented (profile now computes and displays a badge tier).
- SOS Emergency Button: Implemented in active job navigation flow.
- Smart Price Recommender: Partially implemented (local heuristic only, no backend AI yet).
- Automated ETA Updates: Implemented (auto notification trigger at <= 5 minutes estimate).
- Offline State Buffer: Implemented for completion proof queue and retry sync.
- In-App Expense Tracker: Not implemented.
- Skeleton Loading: Implemented in core and used in feed-style UX paths.
- Haptic Feedback: Implemented for bid success and job phase progression.

## Technical Notes

- Offline buffering currently stores completion payload metadata in shared preferences and retries uploads when possible.
- Firestore status includes completed_offline_pending_sync for visibility when connectivity is unstable.
- Full production readiness will require backend ownership for queue reconciliation and duplicate prevention.

## Recommended Next Sprint

1. Build features/expenses with receipt capture and reimbursement approval states.
2. Add server-confirmed ETA message dispatch instead of local UI-only notifications.
3. Add backend endpoint for AI pricing recommendations and confidence score.
4. Add analytics events for SOS usage, offline queue retries, and bid conversion.
5. Add widget/integration tests around execution flow regressions.
