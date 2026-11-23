import 'package:flutter_test/flutter_test.dart';
import 'package:habla_fluido/dominio/repaso.dart';

void main() {
  group('Repaso espaciado SM-2', () {
    test('convierte el puntaje a calidad de cero a cinco', () {
      expect(calidadDesdePuntaje(.96), 5);
      expect(calidadDesdePuntaje(.86), 4);
      expect(calidadDesdePuntaje(.71), 3);
      expect(calidadDesdePuntaje(.51), 2);
      expect(calidadDesdePuntaje(.31), 1);
      expect(calidadDesdePuntaje(.1), 0);
    });

    test('programa las primeras respuestas correctas a uno y seis días', () {
      final hoy = DateTime(2026, 11, 22);
      final inicial = TarjetaRepaso(
          id: 'a1', frase: 'Hello', traduccion: 'Hola', proxima: hoy);
      final primera = inicial.calificar(5, hoy);
      final segunda = primera.calificar(5, primera.proxima);
      expect(primera.intervaloDias, 1);
      expect(segunda.intervaloDias, 6);
      expect(segunda.repeticiones, 2);
    });

    test('un fallo reinicia las repeticiones', () {
      final hoy = DateTime(2026, 11, 22);
      final tarjeta = TarjetaRepaso(
        id: 'a1',
        frase: 'Hello',
        traduccion: 'Hola',
        proxima: hoy,
        repeticiones: 3,
        intervaloDias: 12,
      ).calificar(2, hoy);
      expect(tarjeta.repeticiones, 0);
      expect(tarjeta.intervaloDias, 1);
    });

    test('el mazo devuelve pendientes ordenadas por fecha', () {
      final hoy = DateTime(2026, 11, 22);
      final mazo = MazoRepaso([
        TarjetaRepaso(id: 'b', frase: 'B', traduccion: 'B', proxima: hoy),
        TarjetaRepaso(
            id: 'a',
            frase: 'A',
            traduccion: 'A',
            proxima: hoy.subtract(const Duration(days: 2))),
        TarjetaRepaso(
            id: 'c',
            frase: 'C',
            traduccion: 'C',
            proxima: hoy.add(const Duration(days: 2))),
      ]);
      expect(mazo.pendientes(hoy).map((t) => t.id), ['a', 'b']);
    });

    test('restaura datos válidos y descarta datos dañados', () {
      final original = TarjetaRepaso(
          id: 'a1',
          frase: 'Hello',
          traduccion: 'Hola',
          proxima: DateTime(2026, 11, 22));
      expect(TarjetaRepaso.desdeJson(original.aJson())!.id, 'a1');
      expect(TarjetaRepaso.desdeJson({'id': 3}), isNull);
    });

    test('rechaza calificaciones fuera de cero a cinco', () {
      final tarjeta = TarjetaRepaso(
          id: 'a1',
          frase: 'Hello',
          traduccion: 'Hola',
          proxima: DateTime(2026));
      expect(() => tarjeta.calificar(6, DateTime(2026)), throwsArgumentError);
    });
  });
}
