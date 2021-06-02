# Unicode

utf-16 and utf-32 Encoding and Decoding Library for Dart Language

Arrange from [utf](https://github.com/dart-archive/utf)

## Examples

```dart
import 'package:unicode/unicode.dart';

main() {
  // default
  print(ut16.decode([254, 255, 78, 10, 85, 132, 130, 229, 108, 52]));

  print(utf16.encode("上善若水"));

  // detect
  print(hasUtf16Bom([0xFE, 0xFF, 0x6C, 0x34]));

  // advance
  Utf16Encoder encoder = utf16.encoder as Utf16Encoder;
  print(encoder.encodeUtf16Be("上善若水", false));
  print(encoder.encodeUtf16Le("上善若水", true));
}
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/shirne/unicode/issues
