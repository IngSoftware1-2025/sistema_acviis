import 'package:flutter/material.dart';
import 'package:sistema_acviis/models/trabajador.dart';
import 'package:sistema_acviis/backend/controllers/get_trabajadores.dart';


class GetTrabajador extends StatefulWidget {
  const GetTrabajador({super.key});

  @override
  State<GetTrabajador> createState() => _GetTrabajadorState();
}

class _GetTrabajadorState extends State<GetTrabajador> {
  Future<List<Trabajador>>? futureTrabajadores;

  @override
  void initState() {
    super.initState();
    futureTrabajadores = fetchTrabajadoresFromApi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trabajadores')),
      body: FutureBuilder<List<Trabajador>>(
        future: futureTrabajadores,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final trabajadores = snapshot.data!;
            return ListView.builder(
              itemCount: trabajadores.length,
              itemBuilder: (context, index) {
                final t = trabajadores[index];
                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text('${t.nombre} ${t.apellido ?? ''}'),
                  subtitle: Text(t.email),
                  trailing: t.edad != null ? Text('${t.edad} años') : null,
                );
              },
            );
          } else {
            return const Center(child: Text('Sin datos'));
          }
        },
      ),

      

    );
  }
}
