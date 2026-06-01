////////////////////////////////
// # typst-faktura
////////////////////////////////
// Used code from:
// https://github.com/Sematre/typst-letter-pro
// https://github.com/erictapen/typst-invoice
// https://github.com/Tiefseetauchner/TiefLetter
////////////////////////////////

#import "@preview/ibanator:0.1.0": iban
#import "utilities.typ": format-currency, get-locale-formatting, default-locale, default-region, default-currency, currency-precision
#import "i18n.typ": i18n
#import "layout.typ": letter-formats, header-simple, sender-box, recipient-box, annotations-box, create-address-box
#import "text-fragments.typ": closing
#import "epr-qr-code.typ": epc-qr-content, epr-qr-code

// Constants
#let default-vat-rate = 19
#let default-due-duration = 30
#let default-letter-format = "DIN-5008-B"
#let default-signature-height = 1.5em

/// Default seller dictionary structure.
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
  signature-height: default-signature-height,
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
  signature-height: default-signature-height, // currently not used
)

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
      align(bottom + right, header-simple(seller, lang, region, translations))
    )
  }

  // Create address box (use custom if provided, otherwise generate)
  let address-box = if address-box != none {
    address-box
  } else {
    // Create address box components
    let sender-box = sender-box(seller)
    let annotations-box = annotations-box(annotations)
    let recipient-box = recipient-box(recipient)
    
    create-address-box(
      align(bottom, pad(bottom: 0.65em, sender-box)),
      recipient-box,
      annotations: annotations-box,
      stamp: stamp
    )
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
    
    // Payment details and QR code (only show QR code for EUR)
    if currency == "EUR" {
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
        epr-qr-code(seller, total-with-vat, subject, currency)
      )
    } else {
      [
        #set par(leading: 0.40em)
        #set text(number-type: "lining")
        #translations.payment.recipient #seller.name \
        #translations.payment.bank #seller.bank \
        #translations.payment.iban #iban(seller.iban) \
        #translations.payment.bic #seller.bic \
        #translations.payment.reference #subject
      ]
    }
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

    // Closing section
    #closing(seller, translations, has-title)
  ]

  // Future: ZUGFeRD/Factur-X support for invoices
  // pdf.attach(
  //   "experiment.csv",
  //   relationship: "supplement",
  //   mime-type: "text/csv",
  //   description: "Raw Oxygen readings from the Arctic experiment",
  // )
}
