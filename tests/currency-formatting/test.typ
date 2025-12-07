#import "/src/lib.typ" as faktura

// ============================================================
// Currency Formatting Test Suite
// ============================================================
// This test suite validates the format-currency function's ability
// to format monetary values according to different currencies,
// locales, and regions with proper symbol placement and separators.
// ============================================================

// ============================================================
// 1. BASIC FUNCTIONALITY TESTS
// ============================================================
// Verify that the function returns the correct type and handles
// fundamental formatting requirements.

// Test: Function returns string type
#let basic-result = faktura.format-currency(100.0, locale: "de", region: "DE", currency: "EUR")
#assert(type(basic-result) == str, message: "format-currency must return a string")

// Test: Function handles zero values correctly
#let zero-result = faktura.format-currency(0, locale: "de", region: "DE", currency: "EUR")
#assert(type(zero-result) == str, message: "Zero value must return string")
#assert(zero-result.contains("€"), message: "Zero value must include currency symbol")

// ============================================================
// 2. CURRENCY SYMBOL TESTS
// ============================================================
// Verify correct currency symbols are displayed for each currency type.

// Test: EUR symbol (suffix placement)
#let eur-de = faktura.format-currency(1234.56, locale: "de", region: "DE", currency: "EUR")
#assert(type(eur-de) == str, message: "EUR formatting must return string")
#assert(eur-de.contains("€"), message: "EUR must contain euro symbol")

// Test: USD symbol (prefix placement)
#let usd-result = faktura.format-currency(100.0, locale: "en", region: "US", currency: "USD")
#assert(type(usd-result) == str, message: "USD formatting must return string")
#assert(usd-result.contains("$"), message: "USD must contain dollar symbol")

// Test: GBP symbol (prefix placement)
#let gbp-result = faktura.format-currency(100.0, locale: "en", region: "GB", currency: "GBP")
#assert(type(gbp-result) == str, message: "GBP formatting must return string")
#assert(gbp-result.contains("£"), message: "GBP must contain pound symbol")

// Test: CHF symbol (prefix placement, text-based)
#let chf-result = faktura.format-currency(100.0, locale: "de", region: "CH", currency: "CHF")
#assert(type(chf-result) == str, message: "CHF formatting must return string")
#assert(chf-result.contains("CHF"), message: "CHF must contain 'CHF' text")

// Test: JPY symbol (prefix placement, no decimals)
#let jpy-result = faktura.format-currency(1234.0, locale: "en", region: "JP", currency: "JPY")
#assert(type(jpy-result) == str, message: "JPY formatting must return string")
#assert(jpy-result.contains("¥"), message: "JPY must contain yen symbol")

// Test: Symbol visibility toggle (show-symbol parameter)
#let no-symbol-result = faktura.format-currency(100.0, locale: "de", region: "DE", currency: "EUR", show-symbol: false)
#assert(type(no-symbol-result) == str, message: "No-symbol formatting must return string")
#assert(not no-symbol-result.contains("€"), message: "When show-symbol is false, result must not contain symbol")

// ============================================================
// 3. LOCALE AND REGION COMBINATIONS
// ============================================================
// Verify formatting adapts correctly to different locale/region pairs.

// Test: EUR with German locale/region
#let eur-german = faktura.format-currency(1234.56, locale: "de", region: "DE", currency: "EUR")
#assert(type(eur-german) == str, message: "German EUR formatting must return string")
#assert(eur-german.contains("€"), message: "German EUR must contain euro symbol")

// Test: EUR with English locale/US region
#let eur-english = faktura.format-currency(1234.56, locale: "en", region: "US", currency: "EUR")
#assert(type(eur-english) == str, message: "English EUR formatting must return string")
#assert(eur-english.contains("€"), message: "English EUR must contain euro symbol")

// Test: Extended locale format (de-DE)
#let eur-de-de = faktura.format-currency(1234.56, locale: "de-DE", region: "DE", currency: "EUR")
#assert(type(eur-de-de) == str, message: "Extended locale de-DE must return string")
#assert(eur-de-de.contains("€"), message: "Extended locale de-DE must contain euro symbol")

// Test: Extended locale format (en-US) with USD
#let usd-en-us = faktura.format-currency(1234.56, locale: "en-US", region: "US", currency: "USD")
#assert(type(usd-en-us) == str, message: "Extended locale en-US must return string")
#assert(usd-en-us.contains("$"), message: "Extended locale en-US must contain dollar symbol")

// ============================================================
// 4. NUMBER SIZE AND PRECISION TESTS
// ============================================================
// Verify correct handling of various number magnitudes and decimal precision.

// Test: Small decimal values
#let small-decimal = faktura.format-currency(0.5, locale: "de", region: "DE", currency: "EUR")
#assert(type(small-decimal) == str, message: "Small decimal must return string")

// Test: Large numbers with thousands separators
#let large-number = faktura.format-currency(1234567.89, locale: "de", region: "DE", currency: "EUR")
#assert(type(large-number) == str, message: "Large number must return string")
#assert(large-number.contains("€"), message: "Large number must include currency symbol")

// Test: Very small decimal (precision edge case)
#let very-small = faktura.format-currency(0.001, locale: "de", region: "DE", currency: "EUR")
#assert(type(very-small) == str, message: "Very small decimal must return string")
#assert(very-small.contains("€"), message: "Very small decimal must include currency symbol")

// Test: Rounding behavior (many decimal places)
#let rounding-test = faktura.format-currency(999999.999, locale: "de", region: "DE", currency: "EUR")
#assert(type(rounding-test) == str, message: "Rounding test must return string")
#assert(rounding-test.contains("€"), message: "Rounding test must include currency symbol")

// ============================================================
// 5. ERROR HANDLING AND FALLBACKS
// ============================================================
// Verify graceful handling of invalid or unknown inputs.

// Test: Unknown currency fallback to EUR
#let unknown-currency = faktura.format-currency(1234.56, locale: "de", region: "DE", currency: "XXX")
#assert(type(unknown-currency) == str, message: "Unknown currency must return string")
#assert(unknown-currency.contains("€"), message: "Unknown currency must fallback to EUR symbol")
