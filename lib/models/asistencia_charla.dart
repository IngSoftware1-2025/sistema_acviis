class AsistenciaCharla {
  final String id;
  final String charlaId;
  final String nombreArchivo;
  final String urlArchivo;
  final DateTime uploadedAt;

  AsistenciaCharla({
    required this.id,
    required this.charlaId,
    required this.nombreArchivo,
    required this.urlArchivo,
    required this.uploadedAt,
  });

  factory AsistenciaCharla.fromJson(Map<String, dynamic> json) {
    return AsistenciaCharla(
        id: json['id'],
        charlaId: json['charla_id'],
        nombreArchivo: json['nombre_archivo'],
        urlArchivo: json['url_archivo'],
        uploadedAt: DateTime.parse(json['uploaded_at']));
  }
}
