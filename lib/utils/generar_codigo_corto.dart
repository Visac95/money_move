import 'dart:math';

String generarCodigoCorto() {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  final random = Random();

  return List.generate(
    6,
    (index) => chars[random.nextInt(chars.length)],
  ).join();
}
