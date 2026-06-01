#import "@preview/tiaoma:0.3.0": qrcode
#import "entities.typ": seller

/// Generates EPC QR code content for SEPA credit transfers.
/// 
/// This follows the EPC QR code specification version 002:
/// https://en.wikipedia.org/wiki/EPC_QR_code
/// 
/// - seller (dict): Seller information with BIC, name, and IBAN
/// - total (float): Total amount to be paid
/// - reference (str): Payment reference (typically invoice number)
/// - currency (str): Currency code (default: "EUR")
#let epc-qr-content(seller, total, reference, currency: "EUR") = {
  let curr-config = currency-config.at(currency, default: currency-config.at("EUR"))
  
  // Format amount using format-currency with EPC format (dot separator, no thousands, 2 decimals, no symbol)
  let amount-str = format-currency(
    total,
    currency: currency,
    epc-format: true
  )
  
  ("BCD\n" +
  "002\n" +
  "1\n" +
  "SCT\n" +
  seller.bic + "\n" +
  seller.name + "\n" +
  seller.iban + "\n" +
  curr-config.iso + amount-str + "\n" +
  "\n" +
  reference + "\n" +
  "\n" +
  "")
}

#let epr-qr-code(seller, total-with-vat, subject, currency) = {
  qrcode(
    epc-qr-content(seller, total-with-vat, subject, currency: currency),
    options: (
      scale: 1.0,
      bg-color: luma(100%),
      fg-color: luma(0%),
    )
  )
}
