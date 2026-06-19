// Modela aportes economicos a publicaciones rescatadas.
enum EstadoPago {
  pendiente,
  completado,
  fallido,
  reembolsado;

  static EstadoPago fromString(String valor) => switch (valor) {
        'completed' => completado,
        'failed' => fallido,
        'refunded' => reembolsado,
        _ => pendiente,
      };

  String toJson() => switch (this) {
        pendiente => 'pending',
        completado => 'completed',
        fallido => 'failed',
        reembolsado => 'refunded',
      };
}

class ModeloPatrocinio {
  const ModeloPatrocinio({
    required this.id,
    required this.publicacionId,
    required this.padrinoId,
    required this.monto,
    this.moneda = 'PEN',
    this.estadoPago = EstadoPago.pendiente,
    this.proveedorPago,
    this.transaccionProveedorId,
    this.payloadProveedor,
    required this.creadoEn,
    required this.actualizadoEn,
  });

  final String id;
  final String publicacionId;
  final String padrinoId;
  final double monto;
  final String moneda;
  final EstadoPago estadoPago;
  final String? proveedorPago;
  final String? transaccionProveedorId;
  final Map<String, dynamic>? payloadProveedor;
  final DateTime creadoEn;
  final DateTime actualizadoEn;

  factory ModeloPatrocinio.fromJson(Map<String, dynamic> json) => ModeloPatrocinio(
        id: json['id'] as String,
        publicacionId: json['post_id'] as String,
        padrinoId: json['sponsor_id'] as String,
        monto: (json['amount'] as num).toDouble(),
        moneda: json['currency'] as String? ?? 'PEN',
        estadoPago: EstadoPago.fromString(json['payment_status'] as String? ?? 'pending'),
        proveedorPago: json['payment_provider'] as String?,
        transaccionProveedorId: json['provider_tx_id'] as String?,
        payloadProveedor: json['provider_payload'] as Map<String, dynamic>?,
        creadoEn: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
        actualizadoEn: DateTime.tryParse(json['updated_at'] as String? ?? '') ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'post_id': publicacionId,
        'sponsor_id': padrinoId,
        'amount': monto,
        'currency': moneda,
        'payment_status': estadoPago.toJson(),
        'payment_provider': proveedorPago,
        'provider_tx_id': transaccionProveedorId,
        'provider_payload': payloadProveedor,
        'created_at': creadoEn.toIso8601String(),
        'updated_at': actualizadoEn.toIso8601String(),
      };

  ModeloPatrocinio copyWith({EstadoPago? estadoPago}) => ModeloPatrocinio(
        id: id,
        publicacionId: publicacionId,
        padrinoId: padrinoId,
        monto: monto,
        moneda: moneda,
        estadoPago: estadoPago ?? this.estadoPago,
        proveedorPago: proveedorPago,
        transaccionProveedorId: transaccionProveedorId,
        payloadProveedor: payloadProveedor,
        creadoEn: creadoEn,
        actualizadoEn: DateTime.now(),
      );
}
