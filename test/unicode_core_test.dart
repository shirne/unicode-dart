// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library utf.unicode_core_test;

import 'package:flutter_test/flutter_test.dart';
import 'package:unicode/src/constants.dart';
import 'package:unicode/src/utils.dart';

void main() {
  test('codepoints to utf16 codepoints', testCodepointsToUtf16CodeUnits);
  test('utf16 bytes to codepoints', testUtf16bytesToCodepoints);
}

void testCodepointsToUtf16CodeUnits() {
  // boundary conditions
  expect([], codepointsToUtf16CodeUnits([]), reason: 'no input');
  expect([0x0], codepointsToUtf16CodeUnits([0x0]), reason: '0');
  expect([0xd800, 0xdc00], codepointsToUtf16CodeUnits([0x10000]),
      reason: '10000');

  expect([0xffff], codepointsToUtf16CodeUnits([0xffff]), reason: 'ffff');
  expect([0xdbff, 0xdfff], codepointsToUtf16CodeUnits([0x10ffff]),
      reason: '10ffff');

  expect([0xd7ff], codepointsToUtf16CodeUnits([0xd7ff]), reason: 'd7ff');
  expect([0xe000], codepointsToUtf16CodeUnits([0xe000]), reason: 'e000');

  expect([
    unicodeReplacementCharacterCodepoint
  ], codepointsToUtf16CodeUnits([0xd800]), reason: 'd800');
  expect([
    unicodeReplacementCharacterCodepoint
  ], codepointsToUtf16CodeUnits([0xdfff]), reason: 'dfff');
}

void testUtf16bytesToCodepoints() {
  // boundary conditions: First possible values
  expect([], utf16CodeUnitsToCodepoints([]), reason: 'no input');
  expect([0x0], utf16CodeUnitsToCodepoints([0x0]), reason: '0');
  expect([0x10000], utf16CodeUnitsToCodepoints([0xd800, 0xdc00]),
      reason: '10000');

  // boundary conditions: Last possible sequence of a certain length
  expect([0xffff], utf16CodeUnitsToCodepoints([0xffff]), reason: 'ffff');
  expect([0x10ffff], utf16CodeUnitsToCodepoints([0xdbff, 0xdfff]),
      reason: '10ffff');

  // other boundary conditions
  expect([0xd7ff], utf16CodeUnitsToCodepoints([0xd7ff]), reason: 'd7ff');
  expect([0xe000], utf16CodeUnitsToCodepoints([0xe000]), reason: 'e000');

  // unexpected continuation bytes
  expect([0xfffd], utf16CodeUnitsToCodepoints([0xdc00]),
      reason: 'dc00 first unexpected continuation byte');
  expect([0xfffd], utf16CodeUnitsToCodepoints([0xdfff]),
      reason: 'dfff last unexpected continuation byte');
  expect([0xfffd], utf16CodeUnitsToCodepoints([0xdc00]),
      reason: '1 unexpected continuation bytes');
  expect([0xfffd, 0xfffd], utf16CodeUnitsToCodepoints([0xdc00, 0xdc00]),
      reason: '2 unexpected continuation bytes');
  expect([0xfffd, 0xfffd, 0xfffd],
      utf16CodeUnitsToCodepoints([0xdc00, 0xdc00, 0xdc00]),
      reason: '3 unexpected continuation bytes');

  // incomplete sequences
  expect([0xfffd], utf16CodeUnitsToCodepoints([0xd800]),
      reason: 'd800 last byte missing');
  expect([0xfffd], utf16CodeUnitsToCodepoints([0xdbff]),
      reason: 'dbff last byte missing');

  // concatenation of incomplete sequences
  expect([0xfffd, 0xfffd], utf16CodeUnitsToCodepoints([0xd800, 0xdbff]),
      reason: 'd800 dbff last byte missing');

  // impossible bytes
  expect([0xfffd], utf16CodeUnitsToCodepoints([0x110000]),
      reason: '110000 out of bounds');

  // overlong sequences not possible in utf16 (nothing < x10000)
  // illegal code positions d800-dfff not encodable (< x10000)
}
