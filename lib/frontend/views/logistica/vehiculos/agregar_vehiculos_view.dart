import 'package:flutter/material.dart';
import 'package:sistema_acviis/backend/controllers/vehiculos/create_vehiculo.dart';
import 'package:sistema_acviis/frontend/widgets/scaffold.dart';

class AgregarVehiculosView extends StatefulWidget {
  const AgregarVehiculosView({super.key});

  @override
  State<AgregarVehiculosView> createState() => _AgregarVehiculosViewState();
}

class _AgregarVehiculosViewState extends State<AgregarVehiculosView> {
  final _formKey = GlobalKey<FormState>();

  // ===================== Patente (formato chileno random, ej: XX-YY-99)
  final TextEditingController _patenteController = TextEditingController(
    text: [
      'AB-CD-${(10 + DateTime.now().millisecondsSinceEpoch % 90)}',
      'XY-ZW-${(10 + DateTime.now().millisecondsSinceEpoch % 90)}',
      'JK-LM-${(10 + DateTime.now().millisecondsSinceEpoch % 90)}',
    ][DateTime.now().millisecondsSinceEpoch % 3],
  );

  // ===================== Permiso de circulación (link PDF random)
  final TextEditingController _permisoController = TextEditingController(
    text: 'https://www.ejemplo.com/permiso_${DateTime.now().millisecondsSinceEpoch}.pdf',
  );

  // ===================== Fecha revisión técnica
  final TextEditingController _revTecnicaController = TextEditingController(
    text: '${2024 + DateTime.now().millisecondsSinceEpoch % 2}-'
          '${(1 + DateTime.now().millisecondsSinceEpoch % 12).toString().padLeft(2, '0')}-'
          '${(1 + DateTime.now().millisecondsSinceEpoch % 28).toString().padLeft(2, '0')}',
  );

  // ===================== Fecha revisión de gases
  final TextEditingController _revGasesController = TextEditingController(
    text: '${2024 + DateTime.now().millisecondsSinceEpoch % 2}-'
          '${(1 + DateTime.now().millisecondsSinceEpoch % 12).toString().padLeft(2, '0')}-'
          '${(1 + DateTime.now().millisecondsSinceEpoch % 28).toString().padLeft(2, '0')}',
  );

  // ===================== Fecha última mantención
  final TextEditingController _ultimaMantencionController = TextEditingController(
    text: '${2024 + DateTime.now().millisecondsSinceEpoch % 2}-'
          '${(1 + DateTime.now().millisecondsSinceEpoch % 12).toString().padLeft(2, '0')}-'
          '${(1 + DateTime.now().millisecondsSinceEpoch % 28).toString().padLeft(2, '0')}',
  );

  // ===================== Fecha próxima mantención
  final TextEditingController _proximaMantencionController = TextEditingController(
    text: '${2025 + DateTime.now().millisecondsSinceEpoch % 2}-'
          '${(1 + DateTime.now().millisecondsSinceEpoch % 12).toString().padLeft(2, '0')}-'
          '${(1 + DateTime.now().millisecondsSinceEpoch % 28).toString().padLeft(2, '0')}',
  );

  // ===================== Observaciones última mantención (opcional)
  final TextEditingController _descMantencionController = TextEditingController(
    text: [
      'Cambio de frenos realizado',
      'Revisión general sin problemas',
      'Se reemplazó batería',
      ''
    ][DateTime.now().millisecondsSinceEpoch % 4],
  );

  // ===================== Capacidad vehículo (kg)
  final TextEditingController _capacidadController = TextEditingController(
    text: '${1000 + DateTime.now().millisecondsSinceEpoch % 5000}',
  );

  // ===================== Tipo de neumáticos
  final TextEditingController _tipoNeumaticoController = TextEditingController(
    text: [
      'Radial',
      'Diagonales',
      'Mixtos',
      'Invierno',
      'Todo terreno'
    ][DateTime.now().millisecondsSinceEpoch % 5],
  );

  // ===================== Tipo de vehículo
  final TextEditingController _tipoController = TextEditingController(
    text: [
      'Camioneta',
      'Camión',
      'Furgón',
      'Automóvil',
      'Maquinaria Pesada'
    ][DateTime.now().millisecondsSinceEpoch % 5],
  );

  // ===================== Observaciones generales (opcional)
  static final List<String> observacionesPrueba = [
    'Vehículo en buen estado, con mantenimiento al día y sin incidencias recientes.',
    'Se recomienda revisar sistema de frenos y cambiar filtros cada 6 meses.',
    'Neumáticos delanteros presentan desgaste leve, mantenimiento preventivo necesario.',
    'Vehículo utilizado principalmente en zona urbana, sin registros de accidentes.',
    'Se recomienda limpieza y lubricación del motor, revisión de niveles de aceite y refrigerante.',
  ];
  final TextEditingController _observacionesController = TextEditingController(
    text: observacionesPrueba[DateTime.now().millisecondsSinceEpoch % observacionesPrueba.length],
  );

  // ===================== Rueda de repuesto (sí/no -> true/false)
  bool _tieneRuedaRepuesto =
      DateTime.now().millisecondsSinceEpoch % 2 == 0 ? true : false;

  bool _isLoading = false;

  void _submitFormVehiculo() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        // Convertir fechas si existen
        DateTime? revTecnica;
        if (_revTecnicaController.text.isNotEmpty) {
          revTecnica = DateTime.parse(_revTecnicaController.text);
        }
        DateTime? revGases;
        if (_revGasesController.text.isNotEmpty) {
          revGases = DateTime.parse(_revGasesController.text);
        }
        DateTime? ultimaMantencion;
        if (_ultimaMantencionController.text.isNotEmpty) {
          ultimaMantencion = DateTime.parse(_ultimaMantencionController.text);
        }
        DateTime? proximaMantencion;
        if (_proximaMantencionController.text.isNotEmpty) {
          proximaMantencion = DateTime.parse(_proximaMantencionController.text);
        }

        await createVehiculo(
          patente: _patenteController.text,
          permisoCirculacion: _permisoController.text,
          fechaRevisionTecnica: revTecnica,
          fechaRevisionGases: revGases,
          fechaUltimaMantencion: ultimaMantencion,
          fechaProximaMantencion: proximaMantencion,
          desc_mantencion: _descMantencionController.text.isNotEmpty
              ? _descMantencionController.text
              : null,
          capacidadKg: int.parse(_capacidadController.text),
          tipoNeumaticos: _tipoNeumaticoController.text,
          observaciones: _observacionesController.text.isNotEmpty
              ? _observacionesController.text
              : null,
          tieneRuedaRepuesto: _tieneRuedaRepuesto,
          tipo: _tipoController.text,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vehículo creado exitosamente')),
          );
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/home_page/logistica_view/vehiculos_view',
            (Route<dynamic> route) => false,
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al crear vehículo: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }




  @override
  Widget build(BuildContext context) {
    return PrimaryScaffold(
      title: 'Agregar vehículo',
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Patente
              TextFormField(
                controller: _patenteController,
                decoration: const InputDecoration(labelText: 'Patente'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Campo requerido' : null,
              ),

              // Permiso circulación (PDF URL)
              TextFormField(
                controller: _permisoController,
                decoration: const InputDecoration(labelText: 'Permiso de circulación (URL PDF)'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Campo requerido' : null,
              ),

              // Fecha revisión técnica
              TextFormField(
                controller: _revTecnicaController,
                decoration: const InputDecoration(
                  labelText: 'Fecha revisión técnica (YYYY-MM-DD)',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo requerido';
                  try {
                    DateTime.parse(value);
                  } catch (_) {
                    return 'Formato inválido (YYYY-MM-DD)';
                  }
                  return null;
                },
              ),

              // Fecha revisión gases
              TextFormField(
                controller: _revGasesController,
                decoration: const InputDecoration(
                  labelText: 'Fecha revisión de gases (YYYY-MM-DD)',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo requerido';
                  try {
                    DateTime.parse(value);
                  } catch (_) {
                    return 'Formato inválido (YYYY-MM-DD)';
                  }
                  return null;
                },
              ),

              // Última mantención
              TextFormField(
                controller: _ultimaMantencionController,
                decoration: const InputDecoration(
                  labelText: 'Fecha última mantención (YYYY-MM-DD)',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo requerido';
                  try {
                    DateTime.parse(value);
                  } catch (_) {
                    return 'Formato inválido (YYYY-MM-DD)';
                  }
                  return null;
                },
              ),

              // Próxima mantención
              TextFormField(
                controller: _proximaMantencionController,
                decoration: const InputDecoration(
                  labelText: 'Fecha próxima mantención (YYYY-MM-DD)',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo requerido';
                  try {
                    DateTime.parse(value);
                  } catch (_) {
                    return 'Formato inválido (YYYY-MM-DD)';
                  }
                  return null;
                },
              ),

              // descripción (opcional)
              TextFormField(
                controller: _descMantencionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción de última mantención (opcional)',
                ),
              ),

              // Capacidad en kg
              TextFormField(
                controller: _capacidadController,
                decoration: const InputDecoration(labelText: 'Capacidad (kg)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo requerido';
                  if (int.tryParse(value) == null) return 'Debe ser un número';
                  return null;
                },
              ),

              // Tipo de neumáticos
              TextFormField(
                controller: _tipoNeumaticoController,
                decoration: const InputDecoration(labelText: 'Tipo de neumáticos'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Campo requerido' : null,
              ),

              // Tipo de vehículo
              TextFormField(
                controller: _tipoController,
                decoration: const InputDecoration(labelText: 'Tipo de vehículo'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Campo requerido' : null,
              ),

              // observaciones generales (opcional)
              TextFormField(
                controller: _observacionesController,
                decoration: const InputDecoration(
                  labelText: 'Observaciones generales',
                ),
                maxLines: 3, // varias líneas opcionales
              ),

              // Rueda de repuesto (bool)
              SwitchListTile(
                title: const Text('¿Tiene rueda de repuesto?'),
                value: _tieneRuedaRepuesto,
                onChanged: (value) {
                  setState(() => _tieneRuedaRepuesto = value);
                },
              ),

              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitFormVehiculo,
                      child: const Text('Guardar vehículo'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}