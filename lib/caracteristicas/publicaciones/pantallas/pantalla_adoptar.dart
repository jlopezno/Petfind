// Muestra mascotas disponibles para adopcion en una vista de descubrimiento.
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../mascotas/modelos/modelo_mascota.dart';
import '../modelos/modelo_publicacion.dart';
import '../proveedores/proveedor_publicacion.dart';

class PantallaAdoptar extends ConsumerStatefulWidget {
  const PantallaAdoptar({super.key});

  @override
  ConsumerState<PantallaAdoptar> createState() => _PantallaAdoptarState();
}

class _PantallaAdoptarState extends ConsumerState<PantallaAdoptar> {
  final _controladorScroll = ScrollController();
  String _busqueda = '';
  EspecieMascota? _especieSeleccionada;
  bool _cargandoMas = false;

  @override
  void initState() {
    super.initState();
    _controladorScroll.addListener(_alDesplazarse);
  }

  @override
  void dispose() {
    _controladorScroll
      ..removeListener(_alDesplazarse)
      ..dispose();
    super.dispose();
  }

  void _alDesplazarse() {
    if (!_controladorScroll.hasClients ||
        _cargandoMas ||
        _controladorScroll.position.pixels <
            _controladorScroll.position.maxScrollExtent - 280) {
      return;
    }
    _cargarMas();
  }

  Future<void> _cargarMas() async {
    setState(() => _cargandoMas = true);
    try {
      await ref.read(proveedorAdopciones.notifier).cargarMas();
    } finally {
      if (mounted) setState(() => _cargandoMas = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final adopciones = ref.watch(proveedorAdopciones);
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F7),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.read(proveedorAdopciones.notifier).refrescar(),
          child: adopciones.when(
            loading: () => const _PantallaCargaAdopciones(),
            error: (_, __) => const _EstadoAdopciones(
              icono: Icons.error_outline,
              titulo: 'No pudimos cargar las adopciones',
              descripcion: 'Desliza hacia abajo para intentarlo nuevamente.',
            ),
            data: (items) {
              final visibles = items.where(_coincideConFiltros).toList();
              return ListView(
                controller: _controladorScroll,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                children: [
                  Text(
                    'Encuentra tu companero',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Una nueva historia puede empezar hoy.',
                    style: TextStyle(
                      color: Color(0xFF949494),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 22),
                  TextField(
                    onChanged: (valor) => setState(() => _busqueda = valor),
                    decoration: InputDecoration(
                      hintText: 'Buscar por nombre o raza',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: const Color(0xFFE8E8E9),
                      border: _bordeBusqueda(),
                      enabledBorder: _bordeBusqueda(),
                      focusedBorder: _bordeBusqueda(
                        const BorderSide(color: Color(0xFF6C4DF6), width: 1.4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Categorias',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 12),
                  _CategoriasAdopcion(
                    publicaciones: items,
                    seleccionada: _especieSeleccionada,
                    onSelected: (especie) => setState(() {
                      _especieSeleccionada =
                          _especieSeleccionada == especie ? null : especie;
                    }),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Mascotas para adoptar',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w900,
                                  ),
                        ),
                      ),
                      Text(
                        '${visibles.length} disponibles',
                        style: const TextStyle(
                          color: Color(0xFF6C4DF6),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (visibles.isEmpty)
                    const _EstadoAdopciones(
                      icono: Icons.pets_outlined,
                      titulo: 'No hay coincidencias',
                      descripcion: 'Prueba con otra categoria o busqueda.',
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: visibles.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: .62,
                      ),
                      itemBuilder: (context, index) => _TarjetaAdopcion(
                        publicacion: visibles[index],
                      ),
                    ),
                  if (_cargandoMas) const _SkeletonTarjetasAdopcion(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  OutlineInputBorder _bordeBusqueda([BorderSide lado = BorderSide.none]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: lado,
    );
  }

  bool _coincideConFiltros(ModeloPublicacion publicacion) {
    if (_especieSeleccionada != null &&
        publicacion.especieMascota != _especieSeleccionada) {
      return false;
    }
    final consulta = _busqueda.trim().toLowerCase();
    if (consulta.isEmpty) return true;
    return '${publicacion.nombreMascota ?? ''} ${publicacion.razaMascota ?? ''} ${publicacion.titulo}'
        .toLowerCase()
        .contains(consulta);
  }
}

class _CategoriasAdopcion extends StatelessWidget {
  const _CategoriasAdopcion({
    required this.publicaciones,
    required this.seleccionada,
    required this.onSelected,
  });

  final List<ModeloPublicacion> publicaciones;
  final EspecieMascota? seleccionada;
  final ValueChanged<EspecieMascota> onSelected;

  @override
  Widget build(BuildContext context) {
    const categorias = [
      (EspecieMascota.gato, 'Gatos', Icons.pets_outlined),
      (EspecieMascota.perro, 'Perros', Icons.pets_rounded),
      (EspecieMascota.pajaro, 'Aves', Icons.flight),
      (EspecieMascota.otro, 'Otros', Icons.cruelty_free_outlined),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categorias.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 2.5,
      ),
      itemBuilder: (context, index) {
        final categoria = categorias[index];
        final activa = seleccionada == categoria.$1;
        final total = publicaciones
            .where((publicacion) => publicacion.especieMascota == categoria.$1)
            .length;
        return Material(
          color: activa ? const Color(0xFFEDE9FF) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            onTap: () => onSelected(categoria.$1),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: activa
                      ? const Color(0xFF6C4DF6)
                      : const Color(0xFFE2E2E4),
                  width: activa ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    categoria.$3,
                    color: activa
                        ? const Color(0xFF6C4DF6)
                        : const Color(0xFF8F8F8F),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          categoria.$2,
                          style: TextStyle(
                            color:
                                activa ? const Color(0xFF6C4DF6) : Colors.black,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          '$total disponibles',
                          style: const TextStyle(
                            color: Color(0xFF949494),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TarjetaAdopcion extends StatelessWidget {
  const _TarjetaAdopcion({required this.publicacion});

  final ModeloPublicacion publicacion;

  @override
  Widget build(BuildContext context) {
    final nombre = publicacion.nombreMascota?.trim().isNotEmpty == true
        ? publicacion.nombreMascota!
        : publicacion.titulo;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/publicacion/${publicacion.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FotoMascota(publicacion: publicacion),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nombre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    publicacion.razaMascota ?? 'Raza no registrada',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF949494),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _DatoMascota(
                    icono: Icons.cake_outlined,
                    texto: publicacion.edadMascota ?? 'Edad no registrada',
                  ),
                  const SizedBox(height: 5),
                  _DatoMascota(
                    icono: Icons.location_on_outlined,
                    texto: publicacion.direccion ?? 'Ciudad no registrada',
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 34,
                    child: FilledButton(
                      onPressed: () =>
                          context.push('/publicacion/${publicacion.id}'),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF6C4DF6),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      child: const Text('Conocer'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FotoMascota extends StatelessWidget {
  const _FotoMascota({required this.publicacion});

  final ModeloPublicacion publicacion;

  @override
  Widget build(BuildContext context) {
    if (publicacion.fotos.isEmpty) {
      return Container(
        height: 120,
        color: const Color(0xFFEDE9FF),
        alignment: Alignment.center,
        child: const Icon(Icons.pets_outlined,
            size: 52, color: Color(0xFF6C4DF6)),
      );
    }
    return CachedNetworkImage(
      imageUrl: publicacion.fotos.first,
      height: 120,
      width: double.infinity,
      fit: BoxFit.cover,
      placeholder: (_, __) => const _Skeleton(bordeRadio: 0),
      errorWidget: (_, __, ___) => Container(
        height: 120,
        color: const Color(0xFFEDE9FF),
        alignment: Alignment.center,
        child: const Icon(Icons.pets_outlined,
            size: 52, color: Color(0xFF6C4DF6)),
      ),
    );
  }
}

class _PantallaCargaAdopciones extends StatelessWidget {
  const _PantallaCargaAdopciones();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      children: [
        const _Skeleton(ancho: 218, alto: 28),
        const SizedBox(height: 9),
        const _Skeleton(ancho: 260, alto: 16),
        const SizedBox(height: 22),
        const _Skeleton(alto: 56, bordeRadio: 18),
        const SizedBox(height: 28),
        const _Skeleton(ancho: 100, alto: 20),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 4,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.5,
          ),
          itemBuilder: (_, __) => const _Skeleton(bordeRadio: 8),
        ),
        const SizedBox(height: 30),
        const _Skeleton(ancho: 190, alto: 20),
        const SizedBox(height: 14),
        const _SkeletonTarjetasAdopcion(),
      ],
    );
  }
}

class _SkeletonTarjetasAdopcion extends StatelessWidget {
  const _SkeletonTarjetasAdopcion();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 2,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: .62,
        ),
        itemBuilder: (_, __) => const _Skeleton(bordeRadio: 8),
      ),
    );
  }
}

class _Skeleton extends StatefulWidget {
  const _Skeleton({this.ancho, this.alto, this.bordeRadio = 8});

  final double? ancho;
  final double? alto;
  final double bordeRadio;

  @override
  State<_Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<_Skeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controlador;

  @override
  void initState() {
    super.initState();
    _controlador = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: .45, end: .85).animate(_controlador),
      child: Container(
        width: widget.ancho,
        height: widget.alto,
        decoration: BoxDecoration(
          color: const Color(0xFFE1E1E4),
          borderRadius: BorderRadius.circular(widget.bordeRadio),
        ),
      ),
    );
  }
}

class _DatoMascota extends StatelessWidget {
  const _DatoMascota({required this.icono, required this.texto});

  final IconData icono;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icono, size: 14, color: const Color(0xFF6C4DF6)),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            texto,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF777779),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _EstadoAdopciones extends StatelessWidget {
  const _EstadoAdopciones({
    required this.icono,
    required this.titulo,
    required this.descripcion,
  });

  final IconData icono;
  final String titulo;
  final String descripcion;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icono, size: 46, color: const Color(0xFF6C4DF6)),
          const SizedBox(height: 12),
          Text(titulo, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 5),
          Text(
            descripcion,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF949494)),
          ),
        ],
      ),
    );
  }
}
