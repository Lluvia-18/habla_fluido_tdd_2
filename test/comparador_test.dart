

import 'package:flutter_test/flutter_test.dart';
import 'package:habla_fluido/dominio/comparador.dart';

void main() {
  group('Comparador de pronunciación', () {
    test('normaliza mayúsculas, puntuación y conserva apóstrofos', () {
      expect(normalizar("Hello, DON'T stop!"), ['hello', "don't", 'stop']);
    });

    test('calcula distancia y similitud entre palabras', () {
      expect(distanciaLevenshtein('kitten', 'sitting'), 3);
      expect(similitud('hello', 'hello'), 1);
      expect(similitud('', ''), 1);
    });

    test('una frase exacta obtiene puntaje perfecto', () {
      final resultado = comparar('Nice to meet you.', 'Nice to meet you');
      expect(resultado.puntaje, 1);
      expect(resultado.aprobado, isTrue);
      expect(resultado.porPracticar, isEmpty);
    });

    test('detecta palabras omitidas, sustituidas y sobrantes', () {
      final resultado = comparar('I like English', 'I love English today');
      expect(
          resultado.palabras.any((p) => p.estado == EstadoPalabra.sustituida),
          isTrue);
      expect(resultado.palabras.any((p) => p.estado == EstadoPalabra.sobrante),
          isTrue);
      expect(resultado.porPracticar, contains('like'));
    });
  });
}
