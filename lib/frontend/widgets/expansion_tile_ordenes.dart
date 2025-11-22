import 'package:flutter/material.dart';
import 'package:sistema_acviis/models/ordenes.dart';
import 'package:intl/intl.dart';

class ExpansionTileOrdenes extends StatelessWidget {
  final OrdenCompra orden;

  const ExpansionTileOrdenes({Key? key, required this.orden}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          childrenPadding:
              const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          iconColor: Colors.blueAccent,
          collapsedIconColor: Colors.blueGrey,

          title: Text(
            orden.nombreServicio,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Proveedor: ${orden.proveedor.nombreVendedor}',
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  'Valor: \$${orden.valor}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          children: [
            _buildBodyResponsive(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyResponsive(BuildContext context) {
    // Sección: Datos generales
    final datosGenerales = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Datos generales'),
        _buildInfoRow(
          icon: Icons.confirmation_number,
          label: 'N° orden / cotización',
          value: orden.numeroCotizacion,
        ),
        _buildInfoRow(
          icon: Icons.calendar_month,
          label: 'Fecha de emisión',
          value: DateFormat('yyyy-MM-dd').format(orden.fechaEmision),
        ),
        _buildInfoRow(
          icon: Icons.list_alt,
          label: 'Sección itemizado',
          value: orden.itemizado.nombre,
        ),
        _buildInfoRow(
          icon: Icons.business_center,
          label: 'Centro de costo',
          value: orden.centroCosto,
        ),
        _buildInfoRow(
          icon: Icons.work,
          label: 'Nombre del servicio',
          value: orden.nombreServicio,
        ),
      ],
    );

    // Sección: Datos financieros
    final datosFinancieros = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Datos financieros'),
        _buildInfoRow(
          icon: Icons.payments,
          label: 'Valor',
          value: '\$${orden.valor}',
        ),
        _buildInfoRow(
          icon: Icons.percent,
          label: 'Descuento',
          value: orden.descuento ? 'Sí' : 'No',
        ),
        _buildInfoRow(
          icon: Icons.flag,
          label: 'Estado',
          value: orden.estado,
        ),
      ],
    );

    // Sección: Proveedor
    final datosProveedor = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Proveedor'),
        _buildInfoRow(
          icon: Icons.person,
          label: 'Nombre',
          value: orden.proveedor.nombreVendedor,
        ),
        _buildInfoRow(
          icon: Icons.phone,
          label: 'Contacto',
          value: orden.proveedor.telefonoVendedor,
        ),
        _buildInfoRow(
          icon: Icons.email,
          label: 'Correo',
          value: orden.proveedor.correoVendedor,
        ),
      ],
    );

    // Sección: Notas
    final notas = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Notas'),
        _buildInfoRow(
          icon: Icons.note_alt,
          label: 'Notas adicionales',
          value: orden.notasAdicionales ?? 'Sin notas',
        ),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isThreeCols = width > 1100;
        final isTwoCols = width > 700 && width <= 1100;

        if (!isTwoCols && !isThreeCols) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              datosGenerales,
              const SizedBox(height: 16),
              datosFinancieros,
              const SizedBox(height: 16),
              datosProveedor,
              const SizedBox(height: 16),
              notas,
            ],
          );
        } else if (isTwoCols) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      datosGenerales,
                      const SizedBox(height: 16),
                      datosFinancieros,
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      datosProveedor,
                      const SizedBox(height: 16),
                      notas,
                    ],
                  ),
                ),
              ),
            ],
          );
        } else {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: datosGenerales,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: datosFinancieros,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      datosProveedor,
                      const SizedBox(height: 16),
                      notas,
                    ],
                  ),
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildSectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 24,
            color: Colors.blueAccent.withOpacity(0.8),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
