#import "/src/lib.typ" as faktura

// Test thousands separator formatting
// Test that thousands separators are placed correctly every 3 digits from the right

// Test 4 digits (should have 1 separator: 1.234)
#let result4 = faktura.format-currency(1234.56, locale: "de", region: "DE", currency: "EUR", show-symbol: false)
#assert(result4.contains("1.234"))
#assert(not result4.contains("1.2.3.4")) // Should not have separator after each digit

// Test 5 digits (should have 1 separator: 12.345)
#let result5 = faktura.format-currency(12345.67, locale: "de", region: "DE", currency: "EUR", show-symbol: false)
#assert(result5.contains("12.345"))
#assert(not result5.contains("1.2.3.4.5"))

// Test 6 digits (should have 1 separator: 123.456)
#let result6 = faktura.format-currency(123456.78, locale: "de", region: "DE", currency: "EUR", show-symbol: false)
#assert(result6.contains("123.456"))
#assert(not result6.contains("1.2.3.4.5.6"))

// Test 7 digits (should have 2 separators: 1.234.567)
#let result7 = faktura.format-currency(1234567.89, locale: "de", region: "DE", currency: "EUR", show-symbol: false)
#assert(result7.contains("1.234.567"))
#assert(not result7.contains("1.2.3.4.5.6.7"))
// Verify it has exactly 2 separators in the integer part (German uses . for thousands, , for decimal)
#let parts7 = result7.split(",")
#let integer-part-7 = parts7.first()
// Count occurrences of "." in integer part (should be 2 for thousands separators)
#let separator-count-7 = integer-part-7.split(".").len() - 1
#assert(separator-count-7 == 2)

// Test 8 digits (should have 2 separators: 12.345.678)
#let result8 = faktura.format-currency(12345678.90, locale: "de", region: "DE", currency: "EUR", show-symbol: false)
#assert(result8.contains("12.345.678"))
#let parts8 = result8.split(",")
#let integer-part-8 = parts8.first()
#let separator-count-8 = integer-part-8.split(".").len() - 1
#assert(separator-count-8 == 2)

// Test 9 digits (should have 2 separators: 123.456.789)
#let result9 = faktura.format-currency(123456789.01, locale: "de", region: "DE", currency: "EUR", show-symbol: false)
#assert(result9.contains("123.456.789"))
#let parts9 = result9.split(",")
#let integer-part-9 = parts9.first()
#let separator-count-9 = integer-part-9.split(".").len() - 1
#assert(separator-count-9 == 2)

// Test 10 digits (should have 3 separators: 1.234.567.890)
#let result10 = faktura.format-currency(1234567890.12, locale: "de", region: "DE", currency: "EUR", show-symbol: false)
#assert(result10.contains("1.234.567.890"))
#let parts10 = result10.split(",")
#let integer-part-10 = parts10.first()
#let separator-count-10 = integer-part-10.split(".").len() - 1
#assert(separator-count-10 == 3)

// Test with English/US locale (should use comma as thousands separator)
#let result-us = faktura.format-currency(1234567.89, locale: "en", region: "US", currency: "USD", show-symbol: false)
#assert(result-us.contains("1,234,567"))
#assert(not result-us.contains("1,2,3,4,5,6,7"))

// Test with Swiss locale (should use apostrophe as thousands separator)
#let result-ch = faktura.format-currency(1234567.89, locale: "de", region: "CH", currency: "CHF", show-symbol: false)
#assert(result-ch.contains("1'234'567"))
#assert(not result-ch.contains("1'2'3'4'5'6'7"))

// Test that numbers with 3 or fewer digits don't have separators
#let result3 = faktura.format-currency(123.45, locale: "de", region: "DE", currency: "EUR", show-symbol: false)
#assert(not result3.contains(".") or result3.split(",").first().split(".").len() == 1) // Only decimal separator, no thousands separator

[✓ Thousands separator formatting tests passed]

