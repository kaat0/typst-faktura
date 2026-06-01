////////////////////////////////
// # typst-faktura
////////////////////////////////

// #import "@preview/ibanator:0.1.0": iban
#include "epr-qr-code.typ"

// Constants
#let currency-precision = 2
#let default-vat-rate = 19
#let default-due-duration = 30
#let default-lang = "de"
#let default-region = "DE"
#let default-currency = "EUR"
#let default-letter-format = "DIN-5008-B"
#let default-signature-height = 1.5em

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

/// Default seller dictionary structure.
#let seller = (
  // Company/Organization
  company: none,
  // Personal information
  name: none,
  title: none,
  gender: none,
  // Address
  street-number: none,
  zip: none,
  city: none,
  country: none,
  // Contact
  tel: none,
  email: none,
  // VAT/Tax
  vat-id: none,
  has-vat-exemption: false,
  vat-exemption-text: none,
  // Banking
  bank: none,
  iban: none,
  bic: none,
  // Signature
  signature: none,
  signature-height: default-signature-height,
)

// Global recipient dict - can be set globally and used in invoice
#let recipient = (
  // Company/Organization
  company: none,
  // Personal information
  name: none,
  title: none,
  gender: none,
  // Address
  street-number: none,
  zip: none,
  city: none,
  country: none,
)

#let i18n(lang: default-lang, region: default-region) = {
  
  // Get region-specific VAT exemption text
  let vat-exemption = if region == "DE" {
    [Gemäß § 19 Abs. 1 UStG (Kleinunternehmerregelung) wird keine Umsatzsteuer berechnet.]
  } else if region == "AT" {
    [Gemäß § 6 Abs. 1 Z 27 UStG 1994 (Kleinunternehmerregelung) wird keine Umsatzsteuer berechnet.]
  } else if region == "CH" {
    [Gemäß Art. 21 Abs. 1 MWSTG (Kleinunternehmerregelung) wird keine Mehrwertsteuer berechnet.]
  } else if region == "GB" {
    [Exempt from VAT in accordance with the UK VAT Act (small business exemption).]
  } else if region == "US" {
    [Exempt from sales tax in accordance with applicable state regulations (small business exemption).]
  } else {
    [Exempt from VAT in accordance with applicable regulations (small business exemption).]
  }
  
  if lang == "en" {
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
  } else if lang == "de" {
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

#let closing = {
  // Closing salutation
  translations.closing

  // Signature line
  if "signature" in seller [
    #v(-1em)
    #height(seller.signature-height, seller.signature)
    #line(length: 15em, stroke: 0.5pt)
    #v(-0.4em)
  ] else [
    #v(3em)
    #line(length: 15em, stroke: 0.5pt)
    #v(-0.4em)
  ]
  
  // Seller name and title
  seller.name
  if has-title {
    [\ #emph(seller.title)]
  }
}

// Main function
#let faktura(
  // Document type and basic info
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
  // Content
  items: none,
  pre-text: none,
  post-text: none,
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
) = {

  // Set document metadata
  if seller.name != none {
    set document(
      title: type + " " + subject,
      author: seller.name
    )
  } else {
    set document(title: subject)
  }
  
  // Normalize margins with defaults
  margins = (
    left:   margins.at("left",   default: 25mm),
    right:  margins.at("right",  default: 20mm),
    top:    margins.at("top",    default: 20mm),
    bottom: margins.at("bottom", default: 20mm),
  )

  let translations = i18n(lang, region)

  //[ #salutation ]
  v(0.5em)
  [ #pre-text ]

  [ #post-text ]

  text-fragments.closing

}