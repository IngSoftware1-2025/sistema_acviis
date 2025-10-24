import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sistema_acviis/providers/itemizados_provider.dart';

class ListaItemizados extends StatefulWidget {
  const ListaItemizados({super.key});

  @override
  State<ListaItemizados> createState() => _ListaItemizadosState();
}

class _ListaItemizadosState extends State<ListaItemizados> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ItemizadosProvider>(context, listen: false).fetchItemizados();
    });
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ItemizadosProvider>();
    final items = prov.itemizados;

    return Column(
      children: [
        const ListTile(
          title: Center(
            child: Text(
              'Itemizados',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
        ),
        Expanded(
          child: items.isEmpty
              ? const Center(child: Text('No hay itemizados registrados.'))
              : ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final item = items[i];

                    final nombre = _valorCampo(item, 'nombre') ?? 'Sin nombre';
                    final cantidad = _valorCampo(item, 'cantidad')?.toString() ?? '-';
                    final valorTotal = _valorCampo(item, 'valor_total')?.toString() ?? '-';

                    return ListTile(
                      title: Text(nombre),
                      subtitle: Text('Cantidad: $cantidad  •  Valor estimado: $valorTotal'),
                    );
                  },
                ),
        ),
      ],
    );
  }

  dynamic _valorCampo(dynamic item, String campo) {
    try {
      if (item == null) return null;
      if (item is Map) {
        return item[campo];
      } else {
        final dyn = item as dynamic;
        switch (campo) {
          case 'nombre':
            return dyn.nombre ?? dyn.name;
          case 'cantidad':
            return dyn.cantidad ?? dyn.quantity ?? dyn.cant;
          case 'valor_total':
            return dyn.valorTotal ?? dyn.valor_total ?? dyn.valor;
          default:
            return null;
        }
      }
    } catch (_) {
      return null;
    }
  }
}