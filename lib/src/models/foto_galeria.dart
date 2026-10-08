import 'package:flutter/foundation.dart';

/// Fotografía de la galería pública, subida desde el panel administrativo.
///
/// La imagen se guarda en base64 dentro de Realtime Database (`panel/galeria`)
/// para no requerir Firebase Storage. [datosBase64] es el payload listo para
/// `Image.memory(base64Decode(...))`.
@immutable
class FotoGaleria {
  const FotoGaleria({
    required this.id,
    required this.titulo,
    required this.datosBase64,
    this.descripcion = '',
    this.fechaSubida,
  });

  /// Identificador único (p. ej. `FOTO-001`).
  final String id;

  /// Título corto mostrado bajo la foto.
  final String titulo;

  /// Descripción opcional (pie de foto largo).
  final String descripcion;

  /// Imagen codificada en base64 (sin el prefijo `data:`).
  final String datosBase64;

  /// Marca de tiempo de la subida (epoch ms), si está disponible.
  final int? fechaSubida;

  FotoGaleria copiarCon({String? titulo, String? descripcion}) => FotoGaleria(
        id: id,
        titulo: titulo ?? this.titulo,
        descripcion: descripcion ?? this.descripcion,
        datosBase64: datosBase64,
        fechaSubida: fechaSubida,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'titulo': titulo,
        'descripcion': descripcion,
        'datosBase64': datosBase64,
        if (fechaSubida != null) 'fechaSubida': fechaSubida,
      };

  factory FotoGaleria.fromJson(Map<String, dynamic> m) => FotoGaleria(
        id: '${m['id'] ?? ''}',
        titulo: '${m['titulo'] ?? ''}',
        descripcion: '${m['descripcion'] ?? ''}',
        datosBase64: '${m['datosBase64'] ?? ''}',
        fechaSubida: int.tryParse('${m['fechaSubida'] ?? ''}'),
      );
}
