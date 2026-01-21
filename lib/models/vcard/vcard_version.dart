/// vCard format versions.
///
/// Each version corresponds to a different specification:
/// - [v21]: vCard 2.1 (legacy) - https://web.archive.org/web/20000815081252/http://www.imc.org/pdi/vcard-21.txt
/// - [v3]: vCard 3.0 (most commonly used/supported) - RFC 2425 (https://www.ietf.org/rfc/rfc2425.txt) and RFC 2426 (https://www.ietf.org/rfc/rfc2426.txt)
/// - [v4]: vCard 4.0 (newest standard) - RFC 6350 (https://www.rfc-editor.org/rfc/rfc6350.html)
enum VCardVersion {
  /// vCard version 2.1 (legacy format)
  ///
  /// Specification: https://web.archive.org/web/20000815081252/http://www.imc.org/pdi/vcard-21.txt
  v21,

  /// vCard version 3.0 (most commonly used/supported)
  ///
  /// Specifications:
  /// - https://www.ietf.org/rfc/rfc2425.txt
  /// - https://www.ietf.org/rfc/rfc2426.txt
  v3,

  /// vCard version 4.0 (newest standard)
  ///
  /// Specification: https://www.rfc-editor.org/rfc/rfc6350.html
  v4,
}
