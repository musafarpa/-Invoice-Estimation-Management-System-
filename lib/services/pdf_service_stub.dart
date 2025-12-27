import 'dart:typed_data';

/// Stub implementation for non-web platforms.
/// This function is never called on native platforms because we use
/// Printing.layoutPdf() instead, but it needs to exist for compilation.
void downloadPdf(Uint8List bytes, String filename) {
  // This is a stub - native platforms use Printing.layoutPdf() directly
  throw UnsupportedError('downloadPdf is only supported on web');
}
