#import "/src/lib.typ" as faktura

// Test faktura function validation and basic structure
// Test with minimal valid data
#let seller = (
  gender: "o",
  name: "Test Seller",
  street-number: "Test Street 1",
  zip: "12345",
  city: "Test City",
  country: "DE",
  iban: "DE89370400440532013000",
  bic: "DEUTDEFF",
  bank: "Test Bank",
  has-vat-exemption: false,
)

#let recipient = (
  gender: "o",
  name: "Test Recipient",
  street-number: "Recipient Street 1",
  zip: "54321",
  city: "Recipient City",
  country: "DE",
)

#let items = (
  (
    description: "Test Item 1",
    unit-price: 100.0,
    quantity: 1,
    vat-rate: 19,
  ),
  (
    description: "Test Item 2",
    unit-price: 50.0,
    quantity: 2,
    vat-rate: 19,
  ),
)

// Test that faktura function accepts valid parameters
// Note: We can't easily test the output without rendering,
// but we can test that it doesn't panic with valid input
#let invoice-doc = faktura.faktura(
  lang: "en",
  region: "DE",
  currency: "EUR",
  type: "invoice",
  subject: "TEST-001",
  date: datetime(year: 2024, month: 1, day: 1),
  items: items,
  seller: seller,
  recipient: recipient,
  vat: 19,
)

// Test that it returns content (not none)
#assert(invoice-doc != none)

// Test offer type
#let offer-doc = faktura.faktura(
  lang: "de",
  region: "DE",
  currency: "EUR",
  type: "offer",
  subject: "OFFER-001",
  date: datetime(year: 2024, month: 1, day: 1),
  items: items,
  seller: seller,
  recipient: recipient,
  vat: 19,
)

#assert(offer-doc != none)

// Test with VAT exemption
#let seller-exempt = (
  ..seller,
  has-vat-exemption: true,
)
#let invoice-exempt = faktura.faktura(
  lang: "en",
  region: "DE",
  currency: "EUR",
  type: "invoice",
  subject: "TEST-002",
  date: datetime(year: 2024, month: 1, day: 1),
  items: items,
  seller: seller-exempt,
  recipient: recipient,
  vat: 19,
)

#assert(invoice-exempt != none)

// Test with different currencies
#let invoice-usd = faktura.faktura(
  lang: "en",
  region: "US",
  currency: "USD",
  type: "invoice",
  subject: "TEST-003",
  date: datetime(year: 2024, month: 1, day: 1),
  items: items,
  seller: seller,
  recipient: recipient,
  vat: 19,
)

#assert(invoice-usd != none)

// Test with different letter formats
#let invoice-format-a = faktura.faktura(
  lang: "en",
  region: "DE",
  currency: "EUR",
  type: "invoice",
  subject: "TEST-004",
  date: datetime(year: 2024, month: 1, day: 1),
  items: items,
  seller: seller,
  recipient: recipient,
  vat: 19,
  format: "DIN-5008-A",
)

#assert(invoice-format-a != none)

#let invoice-format-b = faktura.faktura(
  lang: "en",
  region: "DE",
  currency: "EUR",
  type: "invoice",
  subject: "TEST-005",
  date: datetime(year: 2024, month: 1, day: 1),
  items: items,
  seller: seller,
  recipient: recipient,
  vat: 19,
  format: "DIN-5008-B",
)

#assert(invoice-format-b != none)

[✓ Faktura validation tests passed]
