library tekartik_utils.hex_utils_tests;

import 'package:test/test.dart';
import 'package:command/hex_utils.dart';

main() {
  group('hex utils', () {
    test('byteToHex', () {
      expect(byteToHex(0), '00');
      expect(byteToHex(15), '0F');
      expect(byteToHex(16), '10');
      expect(byteToHex(255), 'FF');
      expect(byteToHex(256), '00');
    });

    test('hexToBytes_1byte', () {
      for (int i = 0; i < 256; i++) {
        List<int> bytes = hexToBytes(byteToHex(i));
        expect(bytes.length, 1);
        expect(bytes[0], i);
      }
    });

    test('hexToBytes', () {
      expect(hexToBytes("01 83 3d 79"), [0x01, 0x83, 0x3d, 0x79]);
    });

    test('bytesToHex', () {
      expect(bytesToHex([1, 0x23]), '0123');
      expect(bytesToHex([1, 2, 3, 4, 5]), '0102030405');
    });
  });
}
