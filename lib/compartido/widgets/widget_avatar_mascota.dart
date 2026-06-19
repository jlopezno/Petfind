// Avatar circular para fotos de mascotas.
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class WidgetAvatarMascota extends StatelessWidget {
  const WidgetAvatarMascota({super.key, this.url, this.radio = 28});

  final String? url;
  final double radio;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radio,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      backgroundImage: url == null ? null : CachedNetworkImageProvider(url!),
      child: url == null ? const Icon(Icons.pets) : null,
    );
  }
}
