#import "/src/lib.typ" as faktura

// ============================================================
// Translation (i18n) Test Suite
// ============================================================
// This test suite validates the i18n translation function's ability
// to provide correct translations for different languages, regions,
// and document types. Tests cover document labels, table headers,
// payment information, VAT-related text, and fallback behavior.
// ============================================================

// ============================================================
// 1. ENGLISH TRANSLATIONS (US REGION)
// ============================================================
// Verify that English translations are correctly provided for
// all document elements including document types, salutations,
// totals, and standard labels.

#let en-trans = faktura.i18n("en", region: "US")

// Test: Document type labels
#assert(
  en-trans.invoice == [Invoice],
  message: "English invoice label must be 'Invoice'"
)
#assert(
  en-trans.offer == [Offer],
  message: "English offer label must be 'Offer'"
)

// Test: Salutation forms (gender-specific and neutral)
#assert(
  en-trans.salutation-f == [Dear Ms.],
  message: "English female salutation must be 'Dear Ms.'"
)
#assert(
  en-trans.salutation-m == [Dear Mr.],
  message: "English male salutation must be 'Dear Mr.'"
)
#assert(
  en-trans.salutation-o == [Dear],
  message: "English neutral salutation must be 'Dear'"
)

// Test: VAT and total labels
#assert(
  en-trans.total-no-vat == [Total excl. VAT],
  message: "English total without VAT label must be 'Total excl. VAT'"
)
#assert(
  en-trans.total-vat == [VAT],
  message: "English VAT label must be 'VAT'"
)
#assert(
  en-trans.total-with-vat == [Total incl. VAT],
  message: "English total with VAT label must be 'Total incl. VAT'"
)
#assert(
  en-trans.vat-id == [VAT-ID:],
  message: "English VAT-ID label must be 'VAT-ID:'"
)

// Test: Document closing and payment request text
#assert(
  en-trans.closing == [With kind regards,],
  message: "English closing must be 'With kind regards,'"
)
#assert(
  en-trans.payment-request-part1 == [Please pay the amount of],
  message: "English payment request part 1 must match expected text"
)
#assert(
  en-trans.offer-validity == [The offer is valid until],
  message: "English offer validity text must match expected format"
)

// ============================================================
// 2. GERMAN TRANSLATIONS (DE REGION)
// ============================================================
// Verify that German translations are correctly provided for
// all document elements with proper German terminology and
// formal business language conventions.

#let de-trans = faktura.i18n("de", region: "DE")

// Test: Document type labels
#assert(
  de-trans.invoice == [Rechnung],
  message: "German invoice label must be 'Rechnung'"
)
#assert(
  de-trans.offer == [Angebot],
  message: "German offer label must be 'Angebot'"
)

// Test: Salutation forms (formal German business style)
#assert(
  de-trans.salutation-f == [Sehr geehrte Frau],
  message: "German female salutation must be 'Sehr geehrte Frau'"
)
#assert(
  de-trans.salutation-m == [Sehr geehrter Herr],
  message: "German male salutation must be 'Sehr geehrter Herr'"
)
#assert(
  de-trans.salutation-o == [Guten Tag],
  message: "German neutral salutation must be 'Guten Tag'"
)

// Test: VAT and total labels (German accounting terminology)
#assert(
  de-trans.total-no-vat == [Netto:],
  message: "German total without VAT must be 'Netto:'"
)
#assert(
  de-trans.total-vat == [USt. Gesamt:],
  message: "German VAT total must be 'USt. Gesamt:'"
)
#assert(
  de-trans.total-with-vat == [Brutto:],
  message: "German total with VAT must be 'Brutto:'"
)
#assert(
  de-trans.vat-id == [Wirtschafts-ID:],
  message: "German VAT-ID label must be 'Wirtschafts-ID:'"
)

// Test: Document closing and payment request text
#assert(
  de-trans.closing == [Mit freundlichen Grüßen,],
  message: "German closing must be 'Mit freundlichen Grüßen,'"
)
#assert(
  de-trans.payment-request-part1 == [Es wird um Leistung der Zahlung von],
  message: "German payment request part 1 must match expected formal text"
)
#assert(
  de-trans.offer-validity == [Dieses Angebot ist gültig bis],
  message: "German offer validity text must match expected format"
)

// ============================================================
// 3. TABLE LABEL TRANSLATIONS
// ============================================================
// Verify that table column headers are correctly translated
// for both English and German, ensuring proper terminology
// for invoice line items, quantities, prices, and VAT rates.

// Test: English table labels
#assert(
  en-trans.table-label.item-number == [*No.*],
  message: "English item number label must be '*No.*'"
)
#assert(
  en-trans.table-label.description == [*Description*],
  message: "English description label must be '*Description*'"
)
#assert(
  en-trans.table-label.quantity == [*Qty.*],
  message: "English quantity label must be '*Qty.*'"
)
#assert(
  en-trans.table-label.single-price == [*per Pcs.*],
  message: "English single price label must be '*per Pcs.*'"
)
#assert(
  en-trans.table-label.vat-rate == [*VAT Rate*],
  message: "English VAT rate label must be '*VAT Rate*'"
)
#assert(
  en-trans.table-label.vat-price == [*VAT*],
  message: "English VAT price label must be '*VAT*'"
)
#assert(
  en-trans.table-label.total-price == [*Total*],
  message: "English total price label must be '*Total*'"
)

// Test: German table labels
#assert(
  de-trans.table-label.item-number == [*Pos.*],
  message: "German item number label must be '*Pos.*'"
)
#assert(
  de-trans.table-label.description == [*Bezeichnung*],
  message: "German description label must be '*Bezeichnung*'"
)
#assert(
  de-trans.table-label.quantity == [*Menge*],
  message: "German quantity label must be '*Menge*'"
)
#assert(
  de-trans.table-label.single-price == [*pro Stk*],
  message: "German single price label must be '*pro Stk*'"
)
#assert(
  de-trans.table-label.vat-rate == [*USt. Satz*],
  message: "German VAT rate label must be '*USt. Satz*'"
)
#assert(
  de-trans.table-label.vat-price == [*USt.*],
  message: "German VAT price label must be '*USt.*'"
)
#assert(
  de-trans.table-label.total-price == [*Gesamt*],
  message: "German total price label must be '*Gesamt*'"
)

// ============================================================
// 4. PAYMENT INFORMATION LABELS
// ============================================================
// Verify that payment-related labels (recipient, IBAN, BIC,
// amount, reference) are correctly translated for both
// English and German payment information sections.

// Test: English payment labels
#assert(
  en-trans.payment.recipient == [Recipient:],
  message: "English payment recipient label must be 'Recipient:'"
)
#assert(
  en-trans.payment.iban == [IBAN:],
  message: "English IBAN label must be 'IBAN:'"
)
#assert(
  en-trans.payment.bank == [Bank],
  message: "English bank label must be 'Bank'"
)
#assert(
  en-trans.payment.bic == [BIC:],
  message: "English BIC label must be 'BIC:'"
)
#assert(
  en-trans.payment.amount == [Amount:],
  message: "English payment amount label must be 'Amount:'"
)
#assert(
  en-trans.payment.reference == [Reference:],
  message: "English payment reference label must be 'Reference:'"
)

// Test: German payment labels
#assert(
  de-trans.payment.recipient == [Empfänger:],
  message: "German payment recipient label must be 'Empfänger:'"
)
#assert(
  de-trans.payment.iban == [IBAN:],
  message: "German IBAN label must be 'IBAN:' (same as English)"
)
#assert(
  de-trans.payment.bank == [Kreditinstitut],
  message: "German bank label must be 'Kreditinstitut'"
)
#assert(
  de-trans.payment.bic == [BIC:],
  message: "German BIC label must be 'BIC:' (same as English)"
)
#assert(
  de-trans.payment.amount == [Betrag:],
  message: "German payment amount label must be 'Betrag:'"
)
#assert(
  de-trans.payment.reference == [Verwendungszweck:],
  message: "German payment reference label must be 'Verwendungszweck:'"
)

// ============================================================
// 5. VAT EXEMPTION TEXT BY REGION
// ============================================================
// Verify that VAT exemption text is available for different
// regions where VAT exemption rules may apply. The presence
// of this field indicates region-specific VAT handling.

// Test: German region (DE) VAT exemption
#let de-vat-exempt = faktura.i18n("de", region: "DE")
#assert(
  "vat-exemption-text" in de-vat-exempt,
  message: "German DE region must have VAT exemption text field"
)

// Test: Austrian region (AT) VAT exemption
#let at-vat-exempt = faktura.i18n("de", region: "AT")
#assert(
  "vat-exemption-text" in at-vat-exempt,
  message: "Austrian AT region must have VAT exemption text field"
)

// Test: Swiss region (CH) VAT exemption
#let ch-vat-exempt = faktura.i18n("de", region: "CH")
#assert(
  "vat-exemption-text" in ch-vat-exempt,
  message: "Swiss CH region must have VAT exemption text field"
)

// Test: British region (GB) VAT exemption
#let gb-vat-exempt = faktura.i18n("en", region: "GB")
#assert(
  "vat-exemption-text" in gb-vat-exempt,
  message: "British GB region must have VAT exemption text field"
)

// Test: US region (US) VAT exemption
#let us-vat-exempt = faktura.i18n("en", region: "US")
#assert(
  "vat-exemption-text" in us-vat-exempt,
  message: "US region must have VAT exemption text field"
)

// ============================================================
// 6. FALLBACK BEHAVIOR
// ============================================================
// Verify that the translation system gracefully handles
// unknown languages and regions by falling back to English
// as the default language.

// Test: Unknown language/region fallback to English
#let unknown-trans = faktura.i18n("xx", region: "XX")
#assert(
  unknown-trans.invoice == [Invoice],
  message: "Unknown language/region must fallback to English translations"
)

// ============================================================
// 7. LOCALE VARIANT HANDLING
// ============================================================
// Verify that extended locale formats (e.g., "de-DE", "en-US")
// are correctly parsed and handled, extracting the base
// language code for translation lookup.

// Test: Extended German locale format (de-DE)
#let de-de-trans = faktura.i18n("de-DE", region: "DE")
#assert(
  de-de-trans.invoice == [Rechnung],
  message: "Extended locale 'de-DE' must be parsed and return German translations"
)

// Test: Extended English locale format (en-US)
#let en-us-trans = faktura.i18n("en-US", region: "US")
#assert(
  en-us-trans.invoice == [Invoice],
  message: "Extended locale 'en-US' must be parsed and return English translations"
)
