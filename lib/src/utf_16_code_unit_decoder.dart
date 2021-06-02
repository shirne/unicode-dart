// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library utf.utf_16_code_unit_decoder;

import 'constants.dart';
import 'list_range.dart';

/// An Iterator<int> of codepoints built on an Iterator of UTF-16 code units.
/// The parameters can override the default Unicode replacement character. Set
/// the replacementCharacter to null to throw an ArgumentError
/// rather than replace the bad value.
class Utf16CodeUnitDecoder implements Iterator<int?> {
  // TODO(kevmoo): should this field be private?
  final ListRangeIterator utf16CodeUnitIterator;
  final int? replacementCodepoint;
  int? _current;

  Utf16CodeUnitDecoder(List<int> utf16CodeUnits,
      [int offset = 0,
      int? length,
      this.replacementCodepoint = unicodeReplacementCharacterCodepoint])
      : utf16CodeUnitIterator =
            (ListRange(utf16CodeUnits, offset, length)).iterator;

  Utf16CodeUnitDecoder.fromListRangeIterator(
      this.utf16CodeUnitIterator, this.replacementCodepoint);

  Iterator<int?> get iterator => this;

  @override
  int? get current => _current;

  @override
  bool moveNext() {
    _current = null;
    if (!utf16CodeUnitIterator.moveNext()) return false;

    var value = utf16CodeUnitIterator.current!;
    if (value < 0) {
      if (replacementCodepoint != null) {
        _current = replacementCodepoint;
      } else {
        throw ArgumentError(
            'Invalid UTF16 at ${utf16CodeUnitIterator.position}');
      }
    } else if (value < unicodeUtf16ReservedLo ||
        (value > unicodeUtf16ReservedHi && value <= unicodePlaneOneMax)) {
      // transfer directly
      _current = value;
    } else if (value < unicodeUtf16SurrogateUnit1Base &&
        utf16CodeUnitIterator.moveNext()) {
      // merge surrogate pair
      var nextValue = utf16CodeUnitIterator.current!;
      if (nextValue >= unicodeUtf16SurrogateUnit1Base &&
          nextValue <= unicodeUtf16ReservedHi) {
        value = (value - unicodeUtf16SurrogateUnit0Base) << 10;
        value +=
            unicodeUtf16Offset + (nextValue - unicodeUtf16SurrogateUnit1Base);
        _current = value;
      } else {
        if (nextValue >= unicodeUtf16SurrogateUnit0Base &&
            nextValue < unicodeUtf16SurrogateUnit1Base) {
          utf16CodeUnitIterator.backup();
        }
        if (replacementCodepoint != null) {
          _current = replacementCodepoint;
        } else {
          throw ArgumentError(
              'Invalid UTF16 at ${utf16CodeUnitIterator.position}');
        }
      }
    } else if (replacementCodepoint != null) {
      _current = replacementCodepoint;
    } else {
      throw ArgumentError('Invalid UTF16 at ${utf16CodeUnitIterator.position}');
    }
    return true;
  }
}
