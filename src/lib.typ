////////////////////////////////
// # typst-faktura
////////////////////////////////

// #import "@preview/ibanator:0.1.0": iban
#import "modules/entities.typ": seller, recipient
#import "modules/epc-qr-code.typ": epr-qr-code
#import "modules/locales.typ": default-lang, default-region
#import "modules/text-blocks.typ": get-text-block

// Constants
#let currency-precision = 2
#let default-vat-rate = 19
#let default-due-duration = 30
#let default-currency = "EUR"
#let default-letter-format = "DIN-5008-B"

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

// Main function
#let faktura(
  // Content
  doc-text,
  items: none,
  pre-text: none,
  post-text: none,
  // basic info
  type: "invoice", // or: "offer"
  subject: none,
  date: datetime.today(offset: auto),
  due-date: none,
  due-duration: default-due-duration,
  // Localization
  lang: default-lang,
  region: default-region,
  currency: default-currency,
  // Format
  format: default-letter-format,
  // Entities
  seller: seller,
  recipient: recipient,
  // Tax
  vat: default-vat-rate,
  // Layout
  margins: (
    left:   25mm,
    right:  20mm,
    top:    20mm,
    bottom: 20mm,
  ),
  header: auto,
  footer: none,
  page-numbering: auto,
  // Visual elements
  folding-marks: true,
  hole-mark: true,
  address-box: none,
  information-box: none,
  annotations: none,
  reference-signs: none,
  stamp: false,
  qr-code: true,
) = {

  // Set document metadata
  set text(lang: default-lang)
  set document(
    title: type + " " + subject,
    author: seller.name,
    date: date,
  )
  
  // Normalize margins with defaults
  margins = (
    left:   margins.at("left",   default: 25mm),
    right:  margins.at("right",  default: 20mm),
    top:    margins.at("top",    default: 20mm),
    bottom: margins.at("bottom", default: 20mm),
  )

  //[ #salutation ]
  v(0.5em)
  [ #pre-text ]

  [ #doc-text ]

  [ #post-text ]

  get-text-block("closing", lang: lang, region: region)

}