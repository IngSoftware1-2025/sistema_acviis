class NotificacionConfig {
  final int id;
  final int diasAntes;
  final int diasDespues;

  NotificacionConfig({
    required this.id,
    required this.diasAntes,
    required this.diasDespues,
  });

  factory NotificacionConfig.fromJson(Map<String, dynamic> json) {
    return NotificacionConfig(
      id: json['id'] ?? 0,
      diasAntes: json['diasantes'] ?? 3,
      diasDespues: json['diasdespues'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "diasantes": diasAntes,
      "diasdespues": diasDespues,
    };
  }
}
