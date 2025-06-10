import 'package:http/http.dart' as http;
import 'dart:convert';

Future<String> createTrabajador({
  required String nombreCompleto,
  required String estadoCivil,
  required String rut,
  required DateTime fechaNacimiento,
  required String direccion,
  required String correoElectronico,
  required String sistemaDeSalud,
  required String previsionAfp,
  required String obraEnLaQueTrabaja,
  required String rolQueAsumeEnLaObra
}) async {
  final url = Uri.parse('http://localhost:3000/trabajadores');

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'nombre_completo': nombreCompleto,
      'estado_civil': estadoCivil,
      'rut': rut,
      'fecha_de_nacimiento': fechaNacimiento.toIso8601String(),
      'direccion': direccion,
      'correo_electronico': correoElectronico,
      'sistema_de_salud': sistemaDeSalud,
      'prevision_afp': previsionAfp,
      'obra_en_la_que_trabaja': obraEnLaQueTrabaja,
      'rol_que_asume_en_la_obra' : rolQueAsumeEnLaObra
    }),
  );

  if (response.statusCode == 201) {
    final data = jsonDecode(response.body);
    return data['id']; 
  } else {
    throw Exception('Error al crear trabajador: ${response.body}');
  }
}
