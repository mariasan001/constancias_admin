// lib/data/model_tramite/tramite_full.dart

class TramiteHistory {
  final String fromStatus;
  final String toStatus;
  final String changedBy;
  final String changedAt;
  final String comment;

  TramiteHistory({
    required this.fromStatus,
    required this.toStatus,
    required this.changedBy,
    required this.changedAt,
    required this.comment,
  });

  factory TramiteHistory.fromJson(Map<String, dynamic> json) {
    return TramiteHistory(
      fromStatus: json['fromStatus'] ?? '',
      toStatus: json['toStatus'] ?? '',
      changedBy: json['changedBy'] ?? '',
      changedAt: json['changedAt'] ?? '',
      comment: json['comment'] ?? '',
    );
  }
}

class TramiteFull {
  final String folio;
  final String tramiteType;
  final String userId;
  final String userName;
  final String currentStatus;
  final String createdAt;
  final List<TramiteHistory> history;

  TramiteFull({
    required this.folio,
    required this.tramiteType,
    required this.userId,
    required this.userName,
    required this.currentStatus,
    required this.createdAt,
    required this.history,
  });

  factory TramiteFull.fromJson(Map<String, dynamic> json) {
    return TramiteFull(
      folio: json['folio'] ?? '',
      tramiteType: json['tramiteType'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      currentStatus: json['currentStatus'] ?? '',
      createdAt: json['createdAt'] ?? '',
      history: (json['history'] as List<dynamic>? ?? [])
          .map((h) => TramiteHistory.fromJson(h))
          .toList(),
    );
  }
}
