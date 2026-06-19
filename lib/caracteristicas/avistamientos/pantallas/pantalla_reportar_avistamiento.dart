// Formulario para reportar avistamientos de mascotas.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../compartido/widgets/widget_boton_primario.dart';
import '../../publicaciones/proveedores/proveedor_publicacion.dart';
import '../modelos/modelo_avistamiento.dart';
import '../proveedores/proveedor_avistamiento.dart';

class PantallaReportarAvistamiento extends ConsumerStatefulWidget {
  const PantallaReportarAvistamiento({super.key, required this.postId});

  final String postId;

  @override
  ConsumerState<PantallaReportarAvistamiento> createState() => _PantallaReportarAvistamientoState();
}

class _PantallaReportarAvistamientoState extends ConsumerState<PantallaReportarAvistamiento> {
  final _notas = TextEditingController();
  final _direccion = TextEditingController(text: 'Lima, Peru');

  @override
  void dispose() {
    _notas.dispose();
    _direccion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final publicacion = ref.watch(proveedorDetallePublicacion(widget.postId));
    return Scaffold(
      appBar: AppBar(title: const Text('Reportar avistamiento')),
      body: publicacion.when(
        data: (post) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(initialValue: DateTime.now().toString(), decoration: const InputDecoration(labelText: 'Fecha y hora')),
            const SizedBox(height: 12),
            TextField(controller: _direccion, decoration: const InputDecoration(labelText: 'Direccion referencial')),
            const SizedBox(height: 12),
            Container(
              height: 180,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(8)),
              child: const Text('Mapa con pin arrastrable'),
            ),
            const SizedBox(height: 12),
            TextField(controller: _notas, maxLines: 4, decoration: const InputDecoration(labelText: 'Descripcion')),
            const ListTile(leading: Icon(Icons.attach_file), title: Text('Adjuntar foto')),
            const SizedBox(height: 20),
            WidgetBotonPrimario(
              texto: 'Guardar avistamiento',
              icono: Icons.save,
              onPressed: post == null
                  ? null
                  : () async {
                      final avistamiento = ModeloAvistamiento(
                        id: 'avis-${DateTime.now().millisecondsSinceEpoch}',
                        publicacionId: widget.postId,
                        reportanteId: 'usuario-1',
                        vistoEn: DateTime.now(),
                        latitud: -12.0464,
                        longitud: -77.0428,
                        direccion: _direccion.text,
                        notas: _notas.text,
                        creadoEn: DateTime.now(),
                      );
                      await ref.read(proveedorAvistamientos(widget.postId).notifier).reportarAvistamiento(post, avistamiento);
                      if (context.mounted) context.pop();
                    },
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
      ),
    );
  }
}
