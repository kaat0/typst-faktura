#import "@preview/tiaoma:0.3.0": qrcode
#import "@preview/ibanator:0.1.0": iban

////////////////////////////////
// # typst-faktura
////////////////////////////////
// Used code from:
// https://github.com/Sematre/typst-letter-pro
// https://github.com/erictapen/typst-invoice
// https://github.com/Tiefseetauchner/TiefLetter
////////////////////////////////

// Constants
#let currency-precision = 2
#let default-vat-rate = 19
#let default-due-duration = 30
#let default-locale = "de"
#let default-region = "DE"
#let default-currency = "EUR"
#let default-letter-format = "DIN-5008-B"

////////////////////////////////
// # Locale and Region Configuration
////////////////////////////////

/// Currency configuration with symbol, placement, and ISO code.
#let currency-config = (
  "EUR": (
    symbol: "€",
    placement: "suffix", // suffix or prefix
    iso: "EUR",
    decimal-sep: (",", "."), // (de, en)
    thousands-sep: (".", ","), // (de, en)
  ),
  "USD": (
    symbol: "$",
    placement: "prefix",
    iso: "USD",
    decimal-sep: ("", "."),
    thousands-sep: ("", ","),
  ),
  "GBP": (
    symbol: "£",
    placement: "prefix",
    iso: "GBP",
    decimal-sep: ("", "."),
    thousands-sep: ("", ","),
  ),
  "CHF": (
    symbol: "CHF",
    placement: "prefix",
    iso: "CHF",
    decimal-sep: (",", "."),
    thousands-sep: ("'", "'"),
  ),
  "JPY": (
    symbol: "¥",
    placement: "prefix",
    iso: "JPY",
    decimal-sep: ("", "."),
    thousands-sep: ("", ","),
    precision: 0, // No decimal places for JPY
  ),
)

/// Date format patterns by region.
#let date-formats = (
  "US": "[month]/[day]/[year]",
  "GB": "[day]/[month]/[year]",
  "DE": "[day].[month].[year]",
  "AT": "[day].[month].[year]",
  "CH": "[day].[month].[year]",
  "FR": "[day]/[month]/[year]",
  "IT": "[day]/[month]/[year]",
  "ES": "[day]/[month]/[year]",
  "NL": "[day]-[month]-[year]",
  "BE": "[day].[month].[year]",
  "ISO": "[year]-[month]-[day]",
)

/// Letter format specifications following DIN 5008 standard.
/// Defines positions for folding marks and header sizes.
#let letter-formats = (
  "DIN-5008-A": (
    folding-mark-1-pos: 87mm,
    folding-mark-2-pos: 87mm + 105mm,
    header-size: 27mm,
  ),
  "DIN-5008-B": (
    folding-mark-1-pos: 105mm,
    folding-mark-2-pos: 105mm + 105mm,
    header-size: 45mm,
  ),
)

/// Gets the date format for a given region.
/// Falls back to ISO format if region not found.
#let get-date-format(region) = {
  date-formats.at(region, default: date-formats.at("ISO"))
}

/// Determines locale-specific formatting rules.
/// Returns a dict with decimal-sep, thousands-sep, and other formatting rules.
#let get-locale-formatting(locale, region) = {
  // Extract base language
  let lang = locale.split("-").first()
  
  // Determine number formatting based on locale and region
  let decimal-sep = if lang == "de" or region in ("DE", "AT", "CH") {
    ","
  } else if lang == "fr" or region in ("FR", "BE") {
    ","
  } else {
    "."
  }
  
  let thousands-sep = if lang == "de" or region in ("DE", "AT") {
    "."
  } else if region == "CH" {
    "'"
  } else if lang == "fr" or region in ("FR", "BE") {
    " "
  } else {
    ","
  }
  
  (
    decimal-sep: decimal-sep,
    thousands-sep: thousands-sep,
    date-format: get-date-format(region),
  )
}

////////////////////////////////
// # Utility Functions
////////////////////////////////

/// Formats a number as currency with locale-specific formatting.
/// 
/// Typst can't format numbers yet, so we use this workaround:
/// https://github.com/typst/typst/issues/180#issuecomment-1484069775
/// 
/// - number (float): The number to format
/// - locale (str): Locale for formatting (e.g., "de", "en", "fr")
/// - region (str): Region code (e.g., "DE", "US", "GB")
/// - currency (str): Currency code (e.g., "EUR", "USD", "GBP")
/// - show-symbol (bool): Whether to show the currency symbol
#let format-currency(
  number,
  locale: default-locale,
  region: default-region,
  currency: default-currency,
  show-symbol: true
) = {
  assert(currency-precision > 0)
  
  // Get currency configuration
  let curr-config = currency-config.at(currency, default: currency-config.at("EUR"))
  let precision = curr-config.at("precision", default: currency-precision)
  
  // Round to specified precision
  let rounded = calc.round(number, digits: precision)
  let number-str = str(rounded)
  
  // Split into integer and decimal parts
  let parts-initial = number-str.split(".")
  let integer-part-initial = parts-initial.first()
  let decimal-part-initial = if parts-initial.len() > 1 { parts-initial.at(1) } else { "" }
  
  // Ensure decimal part has correct precision
  if precision > 0 {
    // Pad decimal part with zeros if needed
    let decimal-len = decimal-part-initial.len()
    let zeros-needed = precision - decimal-len
    if zeros-needed > 0 {
      for _ in range(zeros-needed) {
        decimal-part-initial = decimal-part-initial + "0"
      }
    }
  } else {
    decimal-part-initial = ""
  }
  
  // Get locale-specific formatting
  let formatting = get-locale-formatting(locale, region)
  
  // Get integer and decimal parts (before applying thousands separators)
  let integer-part = integer-part-initial
  let decimal-part = decimal-part-initial
  
  // Add thousands separators to integer part
  if formatting.thousands-sep != "" and integer-part.len() > 3 {
    let chars = integer-part.split("")
    let len = chars.len()
    // Calculate remainder when dividing by 3
    // Use integer division by calculating how many full groups of 3 we have
    let full-groups = calc.floor(len / 3)
    let remainder = len - (full-groups * 3)
    // First group size is remainder, or 3 if remainder == 0
    let first-group-size = if remainder == 0 { 3 } else { remainder }
    
    // Build result string directly
    let result = ""
    
    // First group
    for j in range(first-group-size) {
      result = result + chars.at(j)
    }
    
    // Remaining groups of 3
    let pos = first-group-size
    while pos < len {
      if result != "" {
        result = result + formatting.thousands-sep
      }
      for j in range(pos, calc.min(pos + 3, len)) {
        result = result + chars.at(j)
      }
      pos = pos + 3
    }
    
    integer-part = result
  }
  
  // Reconstruct number string
  number-str = integer-part + (if decimal-part != "" { formatting.decimal-sep + decimal-part } else { "" })
  
  // Add currency symbol
  if show-symbol {
    let symbol = curr-config.symbol
    let placement = curr-config.placement
    if placement == "prefix" {
      number-str = symbol + (if symbol != "CHF" { " " } else { "" }) + number-str
    } else {
      number-str = number-str + " " + symbol
    }
  }
  
  number-str
}

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
  let amount-formatted = format-currency(total, locale: "en", region: "US", currency: currency, show-symbol: false)
  let amount-str = amount-formatted
    .replace(",", "")
    .replace(".", "")
    .replace(" ", "")
    .replace("'", "")
  
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

////////////////////////////////
// # Internationalization
////////////////////////////////

/// Returns localized strings for the given language and region.
/// 
/// - lang (str): Language code (e.g., "en", "de", "fr")
/// - region (str): Region code (e.g., "DE", "US", "GB", "AT", "CH")
#let i18n(lang, region: none) = {
  // Extract base language
  let base-lang = lang.split("-").first()
  
  // Get region-specific VAT exemption text
  let vat-exemption = if region == "DE" {
    [Gemäß § 19 Abs. 1 UStG (Kleinunternehmerregelung) wird keine Umsatzsteuer berechnet.]
  } else if region == "AT" {
    [Gemäß § 6 Abs. 1 Z 27 UStG 1994 (Kleinunternehmerregelung) wird keine Umsatzsteuer berechnet.]
  } else if region == "CH" {
    [Gemäß Art. 21 Abs. 1 MWSTG (Kleinunternehmerregelung) wird keine Mehrwertsteuer berechnet.]
  } else if base-lang == "de" {
    [Gemäß § 19 Abs. 1 UStG (Kleinunternehmerregelung) wird keine Umsatzsteuer berechnet.]
  } else if region == "GB" {
    [Exempt from VAT in accordance with the UK VAT Act (small business exemption).]
  } else if region == "US" {
    [Exempt from sales tax in accordance with applicable state regulations (small business exemption).]
  } else {
    [Exempt from VAT in accordance with applicable regulations (small business exemption).]
  }
  
  if base-lang == "en" {
    (
      salutation-f: [Dear Ms.],
      salutation-m: [Dear Mr.],
      salutation-o: [Dear],
      table-label: (
        item-number: [*No.*],
        description: [*Description*],
        quantity: [*Qty.*],
        single-price: [*per Pcs.*],
        vat-rate: [*VAT Rate*],
        vat-price: [*VAT*],
        total-price: [*Total*],
      ),
      total-no-vat: [Total excl. VAT],
      total-vat: [VAT],
      total-with-vat: [Total incl. VAT],
      vat-id: [VAT-ID:],
      vat-exemption-text: vat-exemption,
      invoice: [Invoice],
      offer: [Offer],
      offer-validity: [The offer is valid until],
      payment-request-part1: [Please pay the amount of],
      payment-request-part2: [into our bank account by],
      payment-request-part3: [at the latest to the following account with reference],
      payment-request-part4: [.],
      payment: (
        recipient: [Recipient:],
        iban: [IBAN:],
        bank: [Bank],
        bic: [BIC:],
        amount: [Amount:],
        reference: [Reference:],
      ),
      closing: [With kind regards,],
    )
  } else if base-lang == "de" {
    (
      salutation-f: [Sehr geehrte Frau],
      salutation-m: [Sehr geehrter Herr],
      salutation-o: [Guten Tag],
      table-label: (
        item-number: [*Pos.*],
        description: [*Bezeichnung*],
        quantity: [*Menge*],
        single-price: [*pro Stk*],
        vat-rate: [*USt. Satz*],
        vat-price: [*USt.*],
        total-price: [*Gesamt*],
      ),
      total-no-vat: [Netto:],
      total-vat: [USt. Gesamt:],
      total-with-vat: [Brutto:],
      vat-exemption-text: vat-exemption,
      vat-id: [Wirtschafts-ID:],
      invoice: [Rechnung],
      offer: [Angebot],
      offer-validity: [Dieses Angebot ist gültig bis],
      payment-request-part1: [Es wird um Leistung der Zahlung von],
      payment-request-part2: [bis spätestens],
      payment-request-part3: [auf das untenstehende Bankkonto unter Angabe der Rechnungsnummer],
      payment-request-part4: [gebeten.],
      payment: (
        recipient: [Empfänger:],
        bank: [Kreditinstitut],
        iban: [IBAN:],
        bic: [BIC:],
        amount: [Betrag:],
        reference: [Verwendungszweck:],
      ),
      closing: [Mit freundlichen Grüßen,],
    )
  } else {
    // Fallback to English
    i18n("en", region: region)
  }
}

////////////////////////////////
// # Data Structures
////////////////////////////////

/// Default seller dictionary structure.
/// Can be set globally and used in invoice generation.
#let seller = (
  gender: none,
  name: none,
  title: none,
  street-number: none,
  zip: none,
  city: none,
  country: none,
  tax-id: none, // currently not used
  vat-id: none,
  has-vat-exemption: false,
  vat-exemption-text: none,
  bank: "",
  iban: "",
  bic: "",
  tel: none,
  email: none,
  signature: none,
)

// Global recipient dict - can be set globally and used in invoice
#let recipient = (
  gender: none,
  company: none,
  title: none,
  name: none,
  street-number: none,
  zip: none,
  city: none,
  country: none,
  vat-id: none,
  tel: none, // currently not used
  email: none, // currently not used
  signature: false, // currently not used
)

////////////////////////////////
// # Header Functions
////////////////////////////////

/// Creates a simple header with seller information.
/// 
/// - seller (dict): Seller information
/// - lang (str): Language for VAT ID label
/// - region (str): Region code
#let header-simple(seller, lang, region) = {
  set text(size: 10pt)
  strong(seller.name)
  linebreak()
  if "title" in seller {
    emph(seller.title)
    linebreak()
  }
  seller.street-number
  linebreak()
  seller.zip + " " + seller.city
  linebreak()
  if "country" in seller {seller.country}
  parbreak()
  if "email" in seller {
    seller.email
    linebreak()
  }
  if "tel" in seller {seller.tel}
  parbreak()
  if "vat-id" in seller {
    [#i18n(lang, region: region).vat-id #seller.vat-id]
  }
}

////////////////////////////////
// # Address Box Functions
////////////////////////////////

/// Creates a simple sender box with name and address.
/// 
/// - seller (dict): Seller information with name, title, address, etc.
#let sender-box(seller) = rect(
  width: 85mm,
  height: 5mm,
  stroke: none,
  inset: 0pt,
  {
  set text(size: 7pt)
  set align(horizon)
  
  pad(left: 5mm, underline(offset: 2pt, {
    seller.name + ", "
    if "title" in seller {emph(seller.title) + ", "}
    seller.street-number + ", "
    seller.zip + " " + seller.city
    if "country" in seller {", " + seller.country}
  }))
})

/// Creates an annotations box for additional notes.
/// 
/// - content (content, none): The content to display
#let annotations-box(content) = {
  set text(size: 7pt)
  set align(bottom)
  
  pad(left: 5mm, bottom: 2mm, content)
}

/// Creates a recipient address box.
/// 
/// - recipient (dict): Recipient information with company, name, address, etc.
#let recipient-box(recipient) = {
  set text(size: 10pt)
  set align(top)
  pad(
    left: 5mm,
    if "company" in recipient {recipient.company + "\n" } +
    if "title" in recipient {recipient.title + "\n" } +
    recipient.name + "\n" +
    recipient.street-number + "\n" +
    recipient.zip + " " + recipient.city +
    if "country" in recipient {"\n" + recipient.country}
  )
}

/// Creates an address box with 2 fields (sender and recipient).
/// 
/// The width is is determined automatically. Row heights:
/// #table(
///   columns: 3cm,
///   rows: (17.7mm, 27.3mm),
///   stroke: 0.5pt + gray,
///   align: center + horizon,
///   
///   [sender\ 17.7mm],
///   [recipient\ 27.3mm],
/// )
/// 
/// See also: _address-tribox_
/// 
/// - sender (content, none): The sender box
/// - recipient (content, none): The recipient box
#let address-duobox(sender, recipient) = {
  grid(
    columns: 1,
    rows: (17.7mm, 27.3mm),
      
    sender,
    recipient,
  )
}

/// Creates an address box with 3 fields (sender, annotations, recipient)
/// and optional repartitioning for a stamp.
/// 
/// The width is is determined automatically. Row heights:
/// #table(
///   columns: 2,
///   stroke: none,
///   align: center + horizon,
///   
///   text(weight: "semibold")[Without _stamp_],
///   text(weight: "semibold")[With _stamp_],
///   
///   table(
///     columns: 3cm,
///     rows: (5mm, 12.7mm, 27.3mm),
///     stroke: 0.5pt + gray,
///     align: center + horizon,
///     
///     [_sender_ 5mm],
///     [_annotations_\ 12.7mm],
///     [_recipient_\ 27.3mm],
///   ),
///   
///   table(
///     columns: 3cm,
///     rows: (5mm, 21.16mm, 18.84mm),
///     stroke: 0.5pt + gray,
///     align: center + horizon,
///     
///     [_sender_ 5mm],
///     [_stamp_ +\ _annotations_\ 21.16mm],
///     [_recipient_\ 18.84mm],
///   )
/// )
/// 
/// See also: _address-duobox_
/// 
/// - sender (content, none): The sender box
/// - annotations (content, none): The annotations box
/// - recipient (content, none): The recipient box
/// - stamp (boolean): Enable stamp repartitioning. If enabled, the annotations box and the recipient box divider is moved 8.46mm (about 2 lines) down.
#let address-tribox(sender, annotations, recipient, stamp: false) = {
  if stamp {
    grid(
      columns: 1,
      rows: (5mm, 12.7mm + (4.23mm * 2), 27.3mm - (4.23mm * 2)),
      
      sender,
      annotations,
      recipient,
    )
  } else {
    grid(
      columns: 1,
      rows: (5mm, 12.7mm, 27.3mm),
      
      sender,
      annotations,
      recipient,
    )
  }
}


////////////////////////////////
// # Main Invoice/Offer Generator
////////////////////////////////

/// Generates an invoice or offer document.
/// 
/// - lang (str): Language code (e.g., "en", "de", "fr")
/// - region (str): Region code (e.g., "DE", "US", "GB", "AT", "CH")
/// - currency (str): Currency code (e.g., "EUR", "USD", "GBP", "CHF")
/// - type (str): Document type ("invoice" or "offer")
/// - subject (str, none): Document subject/number
/// - date (datetime): Document date
/// - due-date (datetime, none): Payment due date
/// - due-duration (int): Days until payment is due (if due-date is none)
/// - items (array, none): List of invoice items
/// - seller (dict): Seller information
/// - recipient (dict): Recipient information
/// - vat (float): Default VAT rate percentage
/// - format (str): Letter format ("DIN-5008-A" or "DIN-5008-B")
/// - header (content, auto): Custom header content
/// - footer (content, none): Footer content
/// - folding-marks (bool): Show folding marks
/// - hole-mark (bool): Show hole punch mark
/// - address-box (content, none): Custom address box
/// - annotations (content, none): Annotations for address box
/// - stamp (bool): Enable stamp repartitioning
/// - information-box (content, none): Additional information box
/// - reference-signs (array, none): Reference signs to display
/// - page-numbering (str, function, auto, none): Page numbering style
/// - margins (dict): Page margins
/// - pre-text (content, none): Text before item table
/// - post-text (content, none): Text after item table
#let faktura(
  lang: default-locale,
  region: default-region,
  currency: default-currency,
  type: "invoice", // or: "offer"
  subject: none,
  date: datetime.today(offset: auto),
  due-date: none,
  due-duration: default-due-duration,
  items: none,
  seller: seller,
  recipient: recipient,
  vat: default-vat-rate,
  format: default-letter-format,
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
    left:   25mm,
    right:  20mm,
    top:    20mm,
    bottom: 20mm,
  ),
  pre-text: none,
  post-text: none,
) = {
  ////////////////////////////////
  //// Validation and Setup
  ////////////////////////////////
  
  // Validate letter format
  if not letter-formats.keys().contains(format) {
    let valid-formats = letter-formats.keys().join(", ")
    panic("Invalid letter format! Options: " + valid-formats)
  }
  
  // Normalize margins with defaults
  margins = (
    left:   margins.at("left",   default: 25mm),
    right:  margins.at("right",  default: 20mm),
    top:    margins.at("top",    default: 20mm),
    bottom: margins.at("bottom", default: 20mm),
  )
  
  // Set document metadata
  if seller.name != none {
    set document(
      title: type + " " + subject,
      author: seller.name
    )
  } else {
    set document(title: subject)
  }
  
  // Extract base language for validation
  let base-lang = lang.split("-").first()
  
  // Get locale-specific formatting
  let formatting = get-locale-formatting(lang, region)
  
  // Get translations
  let translations = i18n(lang, region: region)
  
  // Validate seller gender
  assert(
    seller.gender in ("f", "F", "m", "M", "o", "O"),
    message: "Seller gender marker not recognized. Use only [fFmMoO] - Default is 'o'."
  )
  
  // Validate recipient gender
  assert(
    recipient.gender in ("f", "F", "m", "M", "o", "O"),
    message: "Recipient gender marker not recognized. Use only [fFmMoO] - Default is 'o'."
  )

  // Extract VAT exemption status
  let has-vat-exemption = seller.at("has-vat-exemption", default: false)
  let has-title = "title" in seller

  ////////////////////////////////
  //// Page Setup
  ////////////////////////////////

  set text(lang: lang, region: region)
  set text(number-type: "old-style")
  
  set page(
    paper: "a4",
    flipped: false,
    margin: margins,
    background: {
      // Folding marks for DIN 5008 compliance
      if folding-marks {
        let format-spec = letter-formats.at(format)
        let mark-offset = 5mm
        let mark-length = 2.5mm
        let mark-stroke = 0.25pt + black
        
        // First folding mark
        place(
          top + left,
          dx: mark-offset,
          dy: format-spec.folding-mark-1-pos,
          line(length: mark-length, stroke: mark-stroke)
        )
        
        // Second folding mark
        place(
          top + left,
          dx: mark-offset,
          dy: format-spec.folding-mark-2-pos,
          line(length: mark-length, stroke: mark-stroke)
        )
      }
      
      // Hole punch mark for filing
      if hole-mark {
        let hole-offset-x = 5mm
        let hole-position-y = 148.5mm
        let hole-length = 4mm
        let hole-stroke = 0.25pt + black
        
        place(
          left + top,
          dx: hole-offset-x,
          dy: hole-position-y,
          line(length: hole-length, stroke: hole-stroke)
        )
      }
    },
    footer-descent: 0%,
    footer: context {
      show: pad.with(top: 12pt, bottom: 12pt)
      
      let current-page = counter(page).get().first()
      let page-count = counter(page).final().first()
      
      grid(
        columns: 1fr,
        rows: (0.65em, 1fr),
        row-gutter: 12pt,
        
        // Page numbering (only show if more than one page)
        if page-count > 1 {
          if page-numbering == auto {
            // Auto page numbering with language support
            if text.lang == "de" {
              align(right)[Seite #current-page von #page-count]
            } else {
              align(right)[Page #current-page of #page-count]
            }
          } else if type(page-numbering) == str {
            align(right, numbering(page-numbering, current-page, page-count))
          } else if type(page-numbering) == function {
            align(right, page-numbering(current-page, page-count))
          } else if page-numbering != none {
            panic("Unsupported page-numbering option type!")
          }
        },
        
        // Footer content (only on first page)
        if current-page == 1 {
          footer
        }
      )
    },
  )

  ////////////////////////////////
  //// Header and Address Box Setup
  ////////////////////////////////
  
  // Generate header if auto
  if header == auto {
    header = pad(
      left:   margins.left,
      right:  margins.right,
      top:    margins.top,
      bottom: 5mm,
      align(bottom + right, header-simple(seller, lang, region))
    )
  }

  // Create address box components
  let sender-box = sender-box(seller)
  let annotations-box = annotations-box(annotations)
  let recipient-box = recipient-box(recipient)

  // Choose address box layout based on annotations and stamp
  let address-box = if (annotations == none) and (stamp == false) {
    // Two-box layout (sender + recipient)
    address-duobox(
      align(bottom, pad(bottom: 0.65em, sender-box)),
      recipient-box
    )
  } else {
    // Three-box layout (sender + annotations + recipient)
    address-tribox(sender-box, annotations-box, recipient-box, stamp: stamp)
  }

  // Place header and address/information boxes
  // Reverse margins to allow full-width layout
  pad(
    top: -margins.top,
    left: -margins.left,
    right: -margins.right,
    {
      grid(
        columns: 100%,
        rows: (letter-formats.at(format).header-size, 45mm),
        
        // Header box
        header,
        
        // Address and information box
        pad(left: 20mm, right: 10mm, {
          grid(
            columns: (85mm, 75mm),
            rows: 45mm,
            column-gutter: 20mm,
            
            // Address box
            address-box,
            
            // Information box
            pad(top: 5mm, information-box)
          )
        }),
      )
    }
  )

  v(12pt)

  // Reference signs section
  if (reference-signs != none) and (reference-signs.len() > 0) {
    // Layout calculation:
    // Total width: 175mm
    // Delimiter: 4.23mm
    // Cell width: 50mm - 4.23mm = 45.77mm
    grid(
      columns: (45.77mm, 45.77mm, 45.77mm, 25mm),
      rows: 12pt * 2,
      gutter: 12pt,
      
      ..reference-signs.map(sign => {
        let (key, value) = sign
        [
          #text(size: 8pt, key)
          #linebreak()
          #text(size: 10pt, value)
        ]
      })
    )
  }
  
  ////////////////////////////////
  //// Document Header and Salutation
  ////////////////////////////////

  // Title and date
  grid(
    columns: (1fr, 1fr),
    align: bottom,
    heading[
      #if type == "offer" {
        [#translations.offer \##subject]
      } else {
        [#translations.invoice \##subject]
      }
    ],
    [
      #set align(right)
      #seller.city, #date.display(formatting.date-format)
    ]
  )
  
  line(start: (1cm, 0cm), length: 100% - 2cm, stroke: 0.5pt)
  
  // Salutation based on recipient gender
  let salutation = if recipient.gender in ("f", "F") {
    translations.salutation-f
  } else if recipient.gender in ("m", "M") {
    translations.salutation-m
  } else {
    translations.salutation-o
  }
  
  [
    #salutation
    #if "short-name" in recipient {
      recipient.short-name
    } else {
      recipient.name
    },
    #v(0.5em)
    #pre-text
  ]
    
  ////////////////////////////////
  //// Items Table
  ////////////////////////////////
  
  set table(stroke: none)

  // Determine default VAT rate (0 if seller has VAT exemption)
  let default-vat-rate = if has-vat-exemption { 0 } else { vat }

  // Determine table structure based on VAT exemption
  let table-columns = if has-vat-exemption {
    (auto, 1fr, auto, auto, auto)  // 5 columns without VAT
  } else {
    (auto, 1fr, auto, auto, auto, auto, auto)  // 7 columns with VAT
  }
  
  let table-align = (col, row) => if row == 0 {
    // Header row: center alignment for numeric columns
    (right, left, center, center, center, center, center).at(col)
  } else {
    // Data rows: right alignment for numeric columns
    (right, left, right, right, right, right, right).at(col)
  }
  
  // Build table header
  let table-header = if has-vat-exemption {
    table.header(
      table.hline(stroke: 0.5pt),
      translations.table-label.item-number,
      translations.table-label.description,
      translations.table-label.quantity,
      translations.table-label.single-price,
      translations.table-label.total-price,
      table.hline(stroke: 0.5pt),
    )
  } else {
    table.header(
      table.hline(stroke: 0.5pt),
      translations.table-label.item-number,
      translations.table-label.description,
      translations.table-label.quantity,
      translations.table-label.single-price,
      translations.table-label.vat-rate,
      translations.table-label.vat-price,
      translations.table-label.total-price,
      table.hline(stroke: 0.5pt),
    )
  }
  
  // Process items into table rows
  let table-rows = items
    .enumerate()
    .map(((index, row)) => {
      let item-vat-rate = row.at("vat-rate", default: default-vat-rate)
      let item-quantity = row.at("quantity", default: 1)
      let unit-price = row.unit-price
      let item-total = (unit-price + (item-vat-rate / 100) * unit-price) * item-quantity

      if has-vat-exemption {
        // Without VAT columns
        (
          index + 1,
          row.description,
          str(item-quantity),
          format-currency(unit-price, locale: lang, region: region, currency: currency),
          format-currency(item-total, locale: lang, region: region, currency: currency),
        )
      } else {
        // With VAT columns
        let vat-amount = item-quantity * (item-vat-rate / 100) * unit-price
        (
          index + 1,
          row.description,
          str(item-quantity),
          format-currency(unit-price, locale: lang, region: region, currency: currency),
          str(item-vat-rate) + "%",
          format-currency(vat-amount, locale: lang, region: region, currency: currency),
          format-currency(item-total, locale: lang, region: region, currency: currency),
        )
      }
    })
    .flatten()
    .map(str)

  // Render table
  table(
    columns: table-columns,
    align: table-align,
    inset: 6pt,
    table-header,
    ..table-rows,
    table.hline(stroke: 0.5pt),
  )

  // Calculate totals
  let total-no-vat = items
    .map(row => row.unit-price * row.at("quantity", default: 1))
    .sum()
  
  let total-vat = items
    .map(row => (
      row.unit-price *
      row.at("quantity", default: 1) *
      row.at("vat-rate", default: default-vat-rate) / 100
    ))
    .sum()
  
  let total-with-vat = total-no-vat + total-vat

  // Display totals table
  align(right, table(
    columns: 2,
    translations.total-no-vat,
    format-currency(total-no-vat, locale: lang, region: region, currency: currency),
    ..if not has-vat-exemption {
      (
        translations.total-vat,
        format-currency(total-vat, locale: lang, region: region, currency: currency),
        table.hline(stroke: 0.5pt),
        translations.total-with-vat,
        format-currency(total-with-vat, locale: lang, region: region, currency: currency),
      )
    },
  ))

  ////////////////////////////////
  //// Post-Text and Payment Information
  ////////////////////////////////

  [ #post-text ]

  // Calculate payment due date
  let request-date = if due-date == none {
    date + duration(days: due-duration)
  } else {
    due-date
  }
  
  // Payment/offer validity information
  if type == "offer" {
    [#translations.offer-validity #request-date.display(formatting.date-format).]
  } else {
    // Payment request text
    [
      #translations.payment-request-part1
      #format-currency(total-with-vat, locale: lang, region: region, currency: currency)
      #translations.payment-request-part2
      #request-date.display(formatting.date-format)
      #translations.payment-request-part3
      #subject
      #translations.payment-request-part4
    ]
    
    // Payment details and QR code
    grid(
      columns: (1fr, 1fr),
      gutter: 1em,
      align: top,
      [
        #set par(leading: 0.40em)
        #set text(number-type: "lining")
        #translations.payment.recipient #seller.name \
        #translations.payment.bank #seller.bank \
        #translations.payment.iban #iban(seller.iban) \
        #translations.payment.bic #seller.bic \
        #translations.payment.reference #subject
      ],
      qrcode(
        epc-qr-content(seller, total-with-vat, subject, currency: currency),
        options: (
          scale: 1.0,
          bg-color: luma(100%),
          fg-color: luma(0%),
        )
      )
    )
  }

  ////////////////////////////////
  //// Closing and Signature
  ////////////////////////////////

  [
    // VAT exemption notice
    #if seller.has-vat-exemption [
      #parbreak()
      #seller.at("vat-exemption-text", default: translations.vat-exemption-text)
    ]

    #v(0.5em)

    // Closing salutation
    #translations.closing

    // Signature line
    #if "signature" in seller [
      #v(-1em)
      #scale(origin: left, x: 300%, y: 300%, seller.signature)
      #line(length: 15em, stroke: 0.5pt)
      #v(-0.4em)
    ] else [
      #v(3em)
      #line(length: 15em, stroke: 0.5pt)
      #v(-0.4em)
    ]
    
    // Seller name and title
    #seller.name
    #if has-title {
      [\ #emph(seller.title)]
    }
  ]

  // Future: ZUGFeRD/Factur-X support for invoices
  // pdf.attach(
  //   "experiment.csv",
  //   relationship: "supplement",
  //   mime-type: "text/csv",
  //   description: "Raw Oxygen readings from the Arctic experiment",
  // )
}


