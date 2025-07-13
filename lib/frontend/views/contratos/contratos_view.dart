import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sistema_acviis/providers/contratos_provider.dart';
import 'package:sistema_acviis/test/mongo_connection.dart';
import 'package:sistema_acviis/frontend/utils/constants/constants.dart';
import 'package:sistema_acviis/frontend/widgets/scaffold.dart';

class ContratosView extends StatefulWidget {
  const ContratosView({super.key});

  @override
  State<ContratosView> createState() => _ContratosViewState();
}

class _ContratosViewState extends State<ContratosView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ContratosProvider>(context, listen: false).fetchContratos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PrimaryScaffold(
      title: 'Contratos',
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () => createContratoTest(), 
            child: Center(child: Text('Contrato Create Testing'))
          ),

          SizedBox(height: normalPadding),

          ElevatedButton(
            onPressed: () => showContrato(context, '6845587e8659fab493d5e06a.pdf'),
            child: Center(child: Text('Contrato get Testing'))
          ),

          SizedBox(height: normalPadding),

          Consumer<ContratosProvider>(
            builder: (context, contratosProvider, child) {
              if (contratosProvider.isLoading) {
                return Center(child: CircularProgressIndicator());
              }
              if (contratosProvider.contratos.isEmpty) {
                return Center(child: Text('No hay contratos'));
              }
              return ListView.builder(
                itemCount: contratosProvider.contratos.length,
                itemBuilder: (context, index) {
                  final contrato = contratosProvider.contratos[index];
                  return ListTile(
                    title: Text('Contrato ID: ${contrato.id}'),
                    subtitle: Text('Trabajador: ${contrato.idTrabajadores}'),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}