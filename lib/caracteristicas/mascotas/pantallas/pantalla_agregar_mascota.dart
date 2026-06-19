// Formulario para registrar una nueva mascota.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../compartido/widgets/widget_boton_primario.dart';
import '../../../nucleo/constantes/mock_data.dart';
import '../modelos/modelo_mascota.dart';
import '../proveedores/proveedor_mascota.dart';

class PantallaAgregarMascota extends ConsumerStatefulWidget {
  const PantallaAgregarMascota({super.key});

  @override
  ConsumerState<PantallaAgregarMascota> createState() => _PantallaAgregarMascotaState();
}

class _PantallaAgregarMascotaState extends ConsumerState<PantallaAgregarMascota> {
  final _nombre = TextEditingController();
  EspecieMascota _especie = EspecieMascota.perro;

  @override
  void dispose() {
    _nombre.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agregar mascota')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(controller: _nombre, decoration: const InputDecoration(labelText: 'Nombre')),
          const SizedBox(height: 12),
          DropdownButtonFormField<EspecieMascota>(
            initialValue: _especie,
            items: EspecieMascota.values.map((e) => DropdownMenuItem(value: e, child: Text(e.name))).toList(),
            onChanged: (valor) => _especie = valor ?? EspecieMascota.perro,
          ),
          const SizedBox(height: 12),
          const ListTile(leading: Icon(Icons.photo_camera_outlined), title: Text('Agregar fotos')),
          WidgetBotonPrimario(
            texto: 'Guardar mascota',
            icono: Icons.save,
            onPressed: () async {
              final mascota = ModeloMascota(
                id: 'mascota-${DateTime.now().millisecondsSinceEpoch}',
                duenoId: usuariosMock.first.id,
                nombre: _nombre.text.isEmpty ? 'Mascota nueva' : _nombre.text,
                especie: _especie,
                genero: 'M',
                creadoEn: DateTime.now(),
                actualizadoEn: DateTime.now(),
              );
              await ref.read(proveedorMascotas.notifier).agregarMascota(mascota);
              if (context.mounted) context.pop();
            },
          ),
        ],
      ),
    );
  }
}
