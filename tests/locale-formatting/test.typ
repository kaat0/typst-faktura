#import "/src/lib.typ" as faktura

// ============================================================
// Locale Formatting Test Suite
// ============================================================
// This test suite validates the locale and date formatting functions
// (get-date-format and get-locale-formatting) to ensure correct
// formatting rules are applied for different regions, languages,
// and edge cases including fallback behavior.
// ============================================================

// ============================================================
// 1. DATE FORMAT TESTS BY REGION
// ============================================================
// Verify that get-date-format returns correct date format patterns
// for various regions according to regional conventions.

// Test: German date format (DD.MM.YYYY)
#assert(
  faktura.get-date-format("DE") == "[day].[month].[year]",
  message: "German region must use DD.MM.YYYY format"
)

// Test: US date format (MM/DD/YYYY)
#assert(
  faktura.get-date-format("US") == "[month]/[day]/[year]",
  message: "US region must use MM/DD/YYYY format"
)

// Test: British date format (DD/MM/YYYY)
#assert(
  faktura.get-date-format("GB") == "[day]/[month]/[year]",
  message: "British region must use DD/MM/YYYY format"
)

// Test: French date format (DD/MM/YYYY)
#assert(
  faktura.get-date-format("FR") == "[day]/[month]/[year]",
  message: "French region must use DD/MM/YYYY format"
)

// Test: ISO date format (YYYY-MM-DD)
#assert(
  faktura.get-date-format("ISO") == "[year]-[month]-[day]",
  message: "ISO format must use YYYY-MM-DD format"
)

// Test: Dutch date format (DD-MM-YYYY)
#assert(
  faktura.get-date-format("NL") == "[day]-[month]-[year]",
  message: "Dutch region must use DD-MM-YYYY format"
)

// ============================================================
// 2. DATE FORMAT FALLBACK TESTS
// ============================================================
// Verify that unknown or invalid regions fall back to ISO format
// as the default standard.

// Test: Unknown region code fallback
#assert(
  faktura.get-date-format("XX") == "[year]-[month]-[day]",
  message: "Unknown region code must fallback to ISO format"
)

// Test: Invalid region name fallback
#assert(
  faktura.get-date-format("UNKNOWN") == "[year]-[month]-[day]",
  message: "Invalid region name must fallback to ISO format"
)

// ============================================================
// 3. GERMAN-SPEAKING REGIONS
// ============================================================
// Verify locale formatting for German language across different
// German-speaking regions (DE, AT, CH) with their specific rules.

// Test: German locale/region (Germany)
#let de-format = faktura.get-locale-formatting("de", "DE")
#assert(
  de-format.decimal-sep == ",",
  message: "German decimal separator must be comma"
)
#assert(
  de-format.thousands-sep == ".",
  message: "German thousands separator must be period"
)
#assert(
  de-format.date-format == "[day].[month].[year]",
  message: "German date format must match regional format"
)

// Test: Austrian locale/region
#let at-format = faktura.get-locale-formatting("de", "AT")
#assert(
  at-format.decimal-sep == ",",
  message: "Austrian decimal separator must be comma"
)
#assert(
  at-format.thousands-sep == ".",
  message: "Austrian thousands separator must be period"
)
#assert(
  at-format.date-format == "[day].[month].[year]",
  message: "Austrian date format must match regional format"
)

// Test: Swiss locale/region (special thousands separator)
#let ch-format = faktura.get-locale-formatting("de", "CH")
#assert(
  ch-format.decimal-sep == ",",
  message: "Swiss decimal separator must be comma"
)
#assert(
  ch-format.thousands-sep != "",
  message: "Swiss thousands separator must be non-empty (apostrophe)"
)
#assert(
  ch-format.date-format == "[day].[month].[year]",
  message: "Swiss date format must match regional format"
)

// ============================================================
// 4. ENGLISH-SPEAKING REGIONS
// ============================================================
// Verify locale formatting for English language across different
// English-speaking regions with their specific formatting rules.

// Test: English/US locale/region
#let us-format = faktura.get-locale-formatting("en", "US")
#assert(
  us-format.decimal-sep == ".",
  message: "US decimal separator must be period"
)
#assert(
  us-format.thousands-sep == ",",
  message: "US thousands separator must be comma"
)
#assert(
  us-format.date-format == "[month]/[day]/[year]",
  message: "US date format must use MM/DD/YYYY"
)

// Test: English/GB locale/region
#let gb-format = faktura.get-locale-formatting("en", "GB")
#assert(
  gb-format.decimal-sep == ".",
  message: "British decimal separator must be period"
)
#assert(
  gb-format.thousands-sep == ",",
  message: "British thousands separator must be comma"
)
#assert(
  gb-format.date-format == "[day]/[month]/[year]",
  message: "British date format must use DD/MM/YYYY"
)

// ============================================================
// 5. FRENCH-SPEAKING REGIONS
// ============================================================
// Verify locale formatting for French language with its specific
// number formatting conventions (comma decimal, space thousands).

// Test: French locale/region
#let fr-format = faktura.get-locale-formatting("fr", "FR")
#assert(
  fr-format.decimal-sep == ",",
  message: "French decimal separator must be comma"
)
#assert(
  fr-format.thousands-sep == " ",
  message: "French thousands separator must be space"
)
#assert(
  fr-format.date-format == "[day]/[month]/[year]",
  message: "French date format must match regional format"
)

// ============================================================
// 6. EDGE CASES AND FALLBACKS
// ============================================================
// Verify graceful handling of unknown regions and language defaults
// when region-specific rules are not available.

// Test: Unknown region with English language (should use language defaults)
#let unknown-format = faktura.get-locale-formatting("en", "XX")
#assert(
  unknown-format.decimal-sep == ".",
  message: "Unknown region with English must use English decimal separator"
)
#assert(
  unknown-format.thousands-sep == ",",
  message: "Unknown region with English must use English thousands separator"
)
#assert(
  unknown-format.date-format == "[year]-[month]-[day]",
  message: "Unknown region must fallback to ISO date format"
)
