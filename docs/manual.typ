= Faktura Manual

This manual provides comprehensive documentation for the `faktura` Typst package, which enables you to create professional business letters, invoices, and offers with DIN-compliant formatting.

== Table of Contents

#outline(
  title: none,
  depth: 2,
)

== Introduction

The `faktura` package combines the functionality of typst-letter-pro, typst-invoice, and TiefLetter into a unified Typst package. It provides:

- *DIN-compliant formatting*: Follows DIN 5008 standards for business letters
- *Multi-language support*: English, German, and more
- *Multiple document types*: Invoices and offers
- *Internationalization*: Support for different regions, currencies, and date formats
- *EPC QR codes*: Automatic generation of SEPA payment QR codes
- *VAT handling*: Flexible VAT calculation and exemption support
- *Minimal configuration*: Sensible defaults with extensive customization options

== Installation

To use the `faktura` package in your Typst document, import it:

```typ
#import "@preview/faktura:0.1.0": faktura
```

Or import specific functions:

```typ
#import "@preview/faktura:0.1.0": faktura, format-currency, epc-qr-content
```

== Quick Start

Here's a minimal example to create an invoice:

```typ
#import "@preview/faktura:0.1.0": faktura

#let seller = (
  name: "Your Company",
  street-number: "Street 123",
  zip: "12345",
  city: "City",
  iban: "DE89370400440532013000",
  bic: "COBADEFFXXX",
  bank: "Your Bank",
  has-vat-exemption: false,
)

#show: faktura(
  lang: "en",
  seller: seller,
  recipient: (
    name: "Customer Name",
    street-number: "Customer Street 1",
    zip: "54321",
    city: "Customer City",
  ),
  items: (
    (quantity: 1, description: "Service", unit-price: 100.0),
  ),
)
```

== Main Function: `faktura`

The `faktura` function is the main entry point for generating invoices and offers.

=== Function Signature

```typ
#let faktura(
  lang: "de",
  region: "DE",
  currency: "EUR",
  type: "invoice", // or: "offer"
  subject: none,
  date: datetime.today(offset: auto),
  due-date: none,
  due-duration: 30,
  items: none,
  seller: seller,
  recipient: recipient,
  vat: 19,
  format: "DIN-5008-B",
  header: auto,
  footer: none,
  folding-marks: true,
  hole-mark: true,
  address-box: none,
  annotations: none,
  stamp: false,
  information-box: none,
  reference-signs: none,
  page-numbering: auto,
  margins: (
    left: 25mm,
    right: 20mm,
    top: 20mm,
    bottom: 20mm,
  ),
  pre-text: none,
  post-text: none,
  signature-height: 1.5em,
) = { ... }
```

=== Parameters

==== Language and Localization

- `lang` (str, default: `"de"`): Language code (e.g., `"en"`, `"de"`, `"fr"`)
- `region` (str, default: `"DE"`): Region code (e.g., `"DE"`, `"US"`, `"GB"`, `"AT"`, `"CH"`)
- `currency` (str, default: `"EUR"`): Currency code (e.g., `"EUR"`, `"USD"`, `"GBP"`, `"CHF"`, `"JPY"`)

==== Document Type and Content

- `type` (str, default: `"invoice"`): Document type - either `"invoice"` or `"offer"`
- `subject` (str, none): Document subject/number (e.g., invoice number)
- `date` (datetime, default: `datetime.today()`): Document date
- `due-date` (datetime, none): Payment due date (for invoices)
- `due-duration` (int, default: `30`): Days until payment is due (used if `due-date` is `none`)

==== Items

- `items` (array, none): List of invoice/offer items. Each item is a dictionary with:
  - `quantity` (float): Quantity of items
  - `description` (str): Item description
  - `unit-price` (float): Price per unit
  - `vat-rate` (float, optional): VAT rate for this item (defaults to `vat` parameter)

Example:
```typ
items: (
  (quantity: 1, description: "Service A", unit-price: 100.0),
  (quantity: 2, description: "Service B", unit-price: 50.0, vat-rate: 7),
)
```

==== Seller and Recipient

- `seller` (dict): Seller information (see <<data-structures>>)
- `recipient` (dict): Recipient information (see <<data-structures>>)

==== VAT

- `vat` (float, default: `19`): Default VAT rate percentage

==== Formatting

- `format` (str, default: `"DIN-5008-B"`): Letter format - either `"DIN-5008-A"` or `"DIN-5008-B"`
- `header` (content, auto): Custom header content (default: auto-generated)
- `footer` (content, none): Footer content
- `folding-marks` (bool, default: `true`): Show folding marks
- `hole-mark` (bool, default: `true`): Show hole punch mark
- `address-box` (content, none): Custom address box
- `annotations` (content, none): Annotations for address box
- `stamp` (bool, default: `false`): Enable stamp repartitioning
- `information-box` (content, none): Additional information box
- `reference-signs` (array, none): Reference signs to display
- `page-numbering` (str, function, auto, none): Page numbering style
- `margins` (dict): Page margins with `left`, `right`, `top`, `bottom` keys

==== Text Content

- `pre-text` (content, none): Text before item table
- `post-text` (content, none): Text after item table

== Data Structures <data-structures>

=== Seller Dictionary

The seller dictionary contains information about the document sender:

```typ
#let seller = (
  gender: none,           // "M", "F", or "O" (optional)
  name: none,             // Required: Seller name
  title: none,            // Optional: Professional title
  street-number: none,    // Required: Street and number
  zip: none,              // Required: Postal code
  city: none,             // Required: City
  country: none,          // Optional: Country
  tax-id: none,           // Optional: Tax ID (currently not used)
  vat-id: none,           // Optional: VAT ID
  has-vat-exemption: false, // Boolean: VAT exemption status
  vat-exemption-text: none, // Optional: Custom VAT exemption text
  bank: "",               // Bank name
  iban: "",               // IBAN (required for EPC QR code)
  bic: "",                // BIC (required for EPC QR code)
  tel: none,              // Optional: Telephone number
  email: none,            // Optional: Email address
  signature: none,        // Optional: Signature image/content
)
```

=== Recipient Dictionary

The recipient dictionary contains information about the document recipient:

```typ
#let recipient = (
  gender: none,           // "M", "F", or "O" (optional)
  company: none,          // Optional: Company name
  title: none,            // Optional: Title
  name: none,             // Required: Recipient name
  street-number: none,    // Required: Street and number
  zip: none,              // Required: Postal code
  city: none,             // Required: City
  country: none,          // Optional: Country
  vat-id: none,           // Optional: VAT ID
  tel: none,              // Optional: Telephone (currently not used)
  email: none,             // Optional: Email (currently not used)
)
```

== Utility Functions

=== `format-currency`

Formats a number as currency with locale-specific formatting.

```typ
#let format-currency(
  number,
  locale: "de",
  region: "DE",
  currency: "EUR",
  show-symbol: true,
  epc-format: false
) = { ... }
```

*Parameters:*
- `number` (float): The number to format
- `locale` (str): Locale for formatting (e.g., `"de"`, `"en"`, `"fr"`)
- `region` (str): Region code (e.g., `"DE"`, `"US"`, `"GB"`)
- `currency` (str): Currency code (e.g., `"EUR"`, `"USD"`, `"GBP"`)
- `show-symbol` (bool): Whether to show the currency symbol
- `epc-format` (bool): If true, format for EPC QR code (dot as decimal separator, no thousands separators, force 2 decimal places)

*Example:*
```typ
#format-currency(1234.56, locale: "de", region: "DE", currency: "EUR")
// Output: "1.234,56 €"

#format-currency(1234.56, locale: "en", region: "US", currency: "USD")
// Output: "$ 1,234.56"
```

=== `epc-qr-content`

Generates EPC QR code content for SEPA credit transfers.

```typ
#let epc-qr-content(seller, total, reference, currency: "EUR") = { ... }
```

*Parameters:*
- `seller` (dict): Seller information with `bic`, `name`, and `iban`
- `total` (float): Total amount to be paid
- `reference` (str): Payment reference (typically invoice number)
- `currency` (str): Currency code (default: `"EUR"`)

*Example:*
```typ
#let qr-content = epc-qr-content(
  seller: seller,
  total: 119.00,
  reference: "INV-2025-001",
  currency: "EUR"
)
```

=== `i18n`

Returns localized strings for the given language and region.

```typ
#let i18n(lang, region: none) = { ... }
```

*Parameters:*
- `lang` (str): Language code (e.g., `"en"`, `"de"`, `"fr"`)
- `region` (str, optional): Region code (e.g., `"DE"`, `"US"`, `"GB"`, `"AT"`, `"CH"`)

*Returns:* Dictionary with localized strings including:
- `salutation-f`, `salutation-m`, `salutation-o`
- `table-label` (with sub-keys for table headers)
- `total-no-vat`, `total-vat`, `total-with-vat`
- `vat-id`, `vat-exemption-text`
- `invoice`, `offer`
- `payment-request-part1` through `payment-request-part4`
- `payment` (with sub-keys for payment details)
- `closing`

=== `get-date-format`

Gets the date format pattern for a given region.

```typ
#let get-date-format(region) = { ... }
```

*Parameters:*
- `region` (str): Region code (e.g., `"DE"`, `"US"`, `"GB"`)

*Returns:* Date format pattern string (e.g., `"[day].[month].[year]"` for DE)

=== `get-locale-formatting`

Determines locale-specific formatting rules.

```typ
#let get-locale-formatting(locale, region) = { ... }
```

*Parameters:*
- `locale` (str): Locale code
- `region` (str): Region code

*Returns:* Dictionary with `decimal-sep`, `thousands-sep`, and `date-format`

== Configuration

=== Supported Currencies

The package supports the following currencies with proper formatting:

- *EUR* (€): European Euro
- *USD* (`$`): US Dollar
- *GBP* (£): British Pound
- *CHF*: Swiss Franc
- *JPY* (¥): Japanese Yen (no decimal places)

=== Supported Regions

Date formats are configured for:
- `US`: MM/DD/YYYY
- `GB`: DD/MM/YYYY
- `DE`, `AT`, `CH`: DD.MM.YYYY
- `FR`, `IT`, `ES`: DD/MM/YYYY
- `NL`: DD-MM-YYYY
- `BE`: DD.MM.YYYY
- `ISO`: YYYY-MM-DD

=== Letter Formats

Two DIN 5008 formats are supported:

- *DIN-5008-A*: Smaller header (27mm), folding marks at 87mm and 192mm
- *DIN-5008-B*: Larger header (45mm), folding marks at 105mm and 210mm

== Examples

=== Basic Invoice

```typ
#import "@preview/faktura:0.1.0": faktura

#let seller = (
  name: "My Company",
  street-number: "Main Street 123",
  zip: "12345",
  city: "Berlin",
  country: "DE",
  vat-id: "DE123456789",
  has-vat-exemption: false,
  email: "info@mycompany.de",
  bank: "My Bank",
  iban: "DE89370400440532013000",
  bic: "COBADEFFXXX",
  tel: "+49 30 123456",
)

#show: faktura(
  lang: "de",
  region: "DE",
  currency: "EUR",
  type: "invoice",
  subject: "RE-2025-001",
  date: datetime(year: 2025, month: 1, day: 15),
  due-duration: 14,
  seller: seller,
  recipient: (
    name: "Customer Name",
    gender: "M",
    street-number: "Customer Street 1",
    zip: "54321",
    city: "Hamburg",
    country: "DE",
  ),
  items: (
    (quantity: 1, description: "Consulting Services", unit-price: 1000.0),
    (quantity: 2, description: "Development Hours", unit-price: 150.0),
  ),
  pre-text: [Vielen Dank für Ihren Auftrag.],
  post-text: [Bitte überweisen Sie den Betrag innerhalb von 14 Tagen.],
)
```

=== Offer with Custom VAT Rates

```typ
#import "@preview/faktura:0.1.0": faktura

#let seller = (
  name: "My Company",
  street-number: "Main Street 123",
  zip: "12345",
  city: "Berlin",
  iban: "DE89370400440532013000",
  bic: "COBADEFFXXX",
  bank: "My Bank",
  has-vat-exemption: false,
)

#show: faktura(
  lang: "de",
  type: "offer",
  subject: "OFFER-2025-001",
  due-date: datetime(year: 2025, month: 3, day: 31),
  seller: seller,
  recipient: (
    company: "Customer Company GmbH",
    name: "Max Mustermann",
    street-number: "Customer Street 1",
    zip: "54321",
    city: "Hamburg",
  ),
  items: (
    (quantity: 10, description: "Standard Service", unit-price: 100.0),
    (quantity: 1, description: "Premium Service", unit-price: 1000.0, vat-rate: 7),
  ),
  pre-text: [
    anbei finden Sie unser Angebot für die gewünschte Dienstleistung.
  ],
)
```

=== Invoice with VAT Exemption

```typ
#import "@preview/faktura:0.1.0": faktura

#let seller = (
  name: "Small Business",
  street-number: "Street 1",
  zip: "12345",
  city: "City",
  iban: "DE89370400440532013000",
  bic: "COBADEFFXXX",
  bank: "Bank",
  has-vat-exemption: true,  // Enable VAT exemption
)

#show: faktura(
  lang: "de",
  region: "DE",
  seller: seller,
  recipient: (
    name: "Customer",
    street-number: "Street 2",
    zip: "54321",
    city: "City",
  ),
  items: (
    (quantity: 1, description: "Service", unit-price: 100.0),
  ),
)
```

=== English Invoice

```typ
#import "@preview/faktura:0.1.0": faktura

#let seller = (
  name: "My Company Ltd.",
  street-number: "123 Business Street",
  zip: "SW1A 1AA",
  city: "London",
  country: "GB",
  vat-id: "GB123456789",
  has-vat-exemption: false,
  email: "info@mycompany.co.uk",
  bank: "Bank of England",
  iban: "GB82WEST12345698765432",
  bic: "NWBKGB2L",
)

#show: faktura(
  lang: "en",
  region: "GB",
  currency: "GBP",
  type: "invoice",
  subject: "INV-2025-001",
  seller: seller,
  recipient: (
    name: "John Doe",
    street-number: "456 Customer Road",
    zip: "M1 1AA",
    city: "Manchester",
    country: "GB",
  ),
  items: (
    (quantity: 1, description: "Consulting", unit-price: 500.0),
  ),
)
```

== Advanced Usage

=== Custom Header

You can provide a custom header instead of the auto-generated one:

```typ
#show: faktura(
  // ... other parameters ...
  header: [
    #align(center)[
      #text(size: 24pt, weight: "bold")[My Company]
      #linebreak()
      #text(size: 10pt)[Custom Tagline]
    ]
  ],
)
```

=== Custom Address Box

For more control over the address layout:

```typ
#show: faktura(
  // ... other parameters ...
  address-box: [
    // Your custom address box layout
  ],
)
```

=== Custom Margins

Adjust page margins:

```typ
#show: faktura(
  // ... other parameters ...
  margins: (
    left: 30mm,
    right: 25mm,
    top: 25mm,
    bottom: 25mm,
  ),
)
```

=== Annotations

Add annotations to the address box:

```typ
#show: faktura(
  // ... other parameters ...
  annotations: [
    *Important:* Please handle with care.
  ],
)
```

=== Custom Footer

Add footer content:

```typ
#show: faktura(
  // ... other parameters ...
  footer: [
    #align(center)[
      #text(size: 8pt)[Terms and Conditions apply]
    ]
  ],
)
```

=== Page Numbering

Customize page numbering:

```typ
#show: faktura(
  // ... other parameters ...
  page-numbering: (page) => {
    [Page #page]
  },
)
```

Or use a string pattern:

```typ
#show: faktura(
  // ... other parameters ...
  page-numbering: "1 / 1",  // For single page documents
)
```

=== Reference Signs

Add reference signs (e.g., "Re:", "Betr:"):

```typ
#show: faktura(
  // ... other parameters ...
  reference-signs: (
    ("Re:", "Invoice 2025-001"),
    ("Betr:", "Project XYZ"),
  ),
)
```

=== Information Box

Add an additional information box:

```typ
#show: faktura(
  // ... other parameters ...
  information-box: [
    *Payment Terms:* Net 30 days
    #linebreak()
    *Delivery:* Within 2 weeks
  ],
)
```

=== Stamp Repartitioning

Enable stamp repartitioning for the address box (moves the divider down to make room for a stamp):

```typ
#show: faktura(
  // ... other parameters ...
  stamp: true,
  annotations: [Your annotations here],
)
```

== Tips and Best Practices

1. *Reuse Seller Data*: Define your seller information once and reuse it across multiple documents.

2. *Use Pre-text and Post-text*: Add context before and after the item table for better communication.

3. *Item Descriptions*: Keep item descriptions clear and concise for better readability.

4. *VAT Rates*: You can specify different VAT rates per item if needed.

5. *EPC QR Codes*: Ensure your seller has valid `iban` and `bic` for automatic QR code generation.

6. *Date Handling*: Use `datetime.today()` for current date or specify a specific date with `datetime(year: 2025, month: 1, day: 15)`.

7. *Multi-page Documents*: The package handles multi-page documents automatically with proper page numbering.

8. *Localization*: Choose the appropriate `lang` and `region` for correct formatting of dates, numbers, and currency.

== Troubleshooting

=== Common Issues

1. *Missing Required Fields*: Ensure all required fields in `seller` and `recipient` are provided (name, street-number, zip, city).

2. *Currency Formatting*: If currency formatting looks wrong, check that `locale` and `region` match your intended format.

3. *VAT Calculation*: Verify that `vat` parameter and item-specific `vat-rate` values are correct percentages (e.g., 19 for 19%).

4. *EPC QR Code*: For EPC QR codes to work, `seller.iban` and `seller.bic` must be valid.

5. *Date Format*: If dates appear in wrong format, ensure `region` matches your locale expectations.

== License

This package is licensed under the ISC License. See the LICENSE file for details.

== Contributing

Contributions are welcome! Please refer to the project repository for contribution guidelines.

== Support

For issues, questions, or feature requests, please visit the project repository on GitHub.
