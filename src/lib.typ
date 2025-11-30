#import "@preview/tiaoma:0.3.0": qrcode
#import "@preview/ibanator:0.1.0": iban

////////////////////////////////
// # typst-faktura
////////////////////////////////
// used code from:
// https://github.com/Sematre/typst-letter-pro
// https://github.com/erictapen/typst-invoice
// https://github.com/Tiefseetauchner/TiefLetter
// 
////////////////////////////////

// Typst can't format numbers yet, so we use this from here:
// https://github.com/typst/typst/issues/180#issuecomment-1484069775
#let format-currency(number, locale: "de", append_euro: true) = {
  let precision = 2
  assert(precision > 0)
  let s = str(calc.round(number, digits: precision))
  let after_dot = s.find(regex("\..*"))
  if after_dot == none {
    s = s + "."
    after_dot = "."
  }
  for i in range(precision - after_dot.len() + 1){
    s = s + "0"
  }
  if append_euro {
    s = s + " €"
  }
  // fake de locale
  if locale == "de" {
    s.replace(".", ",")
  } else {
    s
  }
}

// This is the content of an https://en.wikipedia.org/wiki/EPC_QR_code version 002
#let epc-qr-content(seller, total, reference) = (
  "BCD\n" +
  "002\n" +
  "1\n" +
  "SCT\n" +
  seller.bic + "\n" +
  seller.name + "\n" +
  seller.iban + "\n" +
  "EUR" + format-currency(total, locale: "en", append_euro: false) + "\n" +
  "\n" +
  reference + "\n" +
  "\n" +
  ""
)

// Languge dict
#let i18n(lang) = if lang == "en" {
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
    vat-exemption-text: [Exempt from VAT in accordance with Section §19(1) of the German VAT Act (small business regulation).],
    invoice: [Invoice],
    offer: [Offer],
    // date: [Invoice Date],
    offer-validity: [The offer is valid until],
    payment-request-part1: [Please pay the amount of],
    payment-request-part2: [into our bank account by],
    payment-request-part3: [at the latest to the following account with reference],
    payment-request-part4: [.],
      //{[Please pay the amount of #format-currency(total-with-vat) until #payment-due-date at the latest to the following account with reference #invoice-number:]},
    payment: (
      recipient: [Recipient:],
      iban: [IBAN:],
      bank: [Bank],
      bic: [BIC:],
      amount: [Amount:],
      reference: [Reference:],
    ),
    // delivery-date: if delivery-date == none {
    //   [The delivery date is, unless otherwise specified, equivalent to the invoice date.]
    // } else { [The delivery date is, unless otherwise specified, on or in #delivery-date.] },
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
    vat-exemption-text: [Gemäß § 19 Abs. 1 UStG (Kleinunternehmerregelung) wird keine Umsatzsteuer berechnet.],
    vat-id: [Wirtschafts-ID:],
    invoice: [Rechnung],
    offer: [Angebot],
    // date: [Rechnungsdatum],
    offer-validity: [Dieses Angebot ist gültig bis],
    payment-request-part1: [Es wird um Leistung der Zahlung von],
    payment-request-part2: [bis spätestens],
    payment-request-part3: [auf das untenstehende Bankkonto unter Angabe der Rechnungsnummer],
    payment-request-part4: [gebeten.],
      // [Es wird um Leistung der Zahlung von #format-currency(total-with-vat) bis spätestens #payment-due-date auf unser Bankkonto unter Angabe der Rechnungsnummer '#invoice-number' gebeten.]},
    payment: (
      recipient: [Empfänger:],
      bank: [Kreditinstitut],
      iban: [IBAN:],
      bic: [BIC:],
      amount: [Betrag:],
      reference: [Verwendungszweck:],
    ),
    // delivery-date: if delivery-date == none {
    //   [Der Lieferzeitpunkt ist, falls nicht anders angegeben, das Rechnungsdatum.]
    // } else { [Der Lieferzeitpunkt/Lieferzeitraum ist, falls nicht anders angegeben, am/im #delivery-date.] },
    closing: [Mit freundlichen Grüßen,],
  )
}


// Global seller dict - can be set globally and used in invoice
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

#let header-simple(seller, lang) = {
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
  if "vat-id" in seller [#i18n(lang).vat-id #seller.vat-id]
}

/// Creates a simple sender box with a name and an address.
/// 
/// - name (content, none): Name of the sender
/// - address (content, none): Address of the sender
#let sender-box(seller) = rect(width: 85mm, height: 5mm, stroke: none, inset: 0pt, {
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

/// Creates a simple annotations box.
/// 
/// - content (content, none): The content
#let annotations-box(content) = {
  set text(size: 7pt)
  set align(bottom)
  
  pad(left: 5mm, bottom: 2mm, content)
}

// Creates a recipient box.
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

/// Creates a simple address box with 2 fields.
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

/// Creates a simple address box with 3 fields and optional repartitioning for a stamp.
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
// # main class
////////////////////////////////

// Generates an invoice
#let faktura(
  lang: "de",
  region: "DE",
  type: "invoice", // or: "offer"
  subject: none,
  date: datetime.today(offset:auto),
  due-date: none,
  due-duration: 30,
  items: none, // A list of items
  seller: seller, // Global seller dict
  recipient: recipient, // Global recipient dict
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
    left:   25mm,
    right:  20mm,
    top:    20mm,
    bottom: 20mm,
  ),
  pre-text: none,
  post-text: none,
) = {
  ////////////////////////////////
  //// assertation 
  ////////////////////////////////
  if not letter-formats.keys().contains(format) {
    panic("Invalid letter format! Options: " + letter-formats.keys().join(", "))
  }
  margins = (
    left:   margins.at("left",   default: 25mm),
    right:  margins.at("right",  default: 20mm),
    top:    margins.at("top",    default: 20mm),
    bottom: margins.at("bottom", default: 20mm),
  )
  // Configure page and text properties.
  if seller.name != none {
    set document(
      title: type + " " + subject,
      author: seller.name
    )
  }
  else {
    set document(
      title: subject,
    )
  }
  assert(
    lang in ("en", "de"), message: "Currently, only en and de are supported."
  )
  assert(
    seller.gender in ("f", "F", "m", "M", "o", "O"),
    message: "seller gender Marker not recognized. Use only [fFmMoO] - Default is 'o'.",
  )
  assert(
    recipient.gender in ("f", "F", "m", "M", "o", "O"),
    message: "recipient gender Marker not recognized. Use only [fFmMoO] - Default is 'o'.",
  )

  let has-vat-exemption = seller.at("has-vat-exemption", default: false)
  
  let has-title = if "title" in seller { true } else { false}

  ////////////////////////////////
  //// Letter 
  ////////////////////////////////

  set text(lang: lang, region: region)
  set text(number-type: "old-style")
  set page(
    paper: "a4",
    flipped: false,
    margin: margins,
    background: {
      if folding-marks {
        // folding mark 1
        place(top + left, dx: 5mm, dy: letter-formats.at(format).folding-mark-1-pos, line(
            length: 2.5mm,
            stroke: 0.25pt + black
        ))
        
        // folding mark 2
        place(top + left, dx: 5mm, dy: letter-formats.at(format).folding-mark-2-pos, line(
            length: 2.5mm,
            stroke: 0.25pt + black
        ))
      }
      
      if hole-mark {
        // hole mark
        place(left + top, dx: 5mm, dy: 148.5mm, line(
          length: 4mm,
          stroke: 0.25pt + black
        ))
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
        
        if page-count > 1 {
          if page-numbering == auto {
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
            panic("Unsupported option type!")
          }
        },
        
        if current-page == 1 {
          footer
        }
      )
    },
  )

  let address = {
    seller.street-number + ", " + seller.zip + " " + seller.city
  }
  if header == auto {
    header = pad(
      left:   margins.left,
      right:  margins.right,
      top:    margins.top,
      bottom: 5mm,
      align( bottom + right, header-simple(seller, lang))
    )
  }

  let sender-box      = sender-box(seller)
  let annotations-box = annotations-box(annotations)

  let recipient-box   = recipient-box(recipient)

  let address-box     = address-tribox(sender-box, annotations-box, recipient-box, stamp: stamp)
  if (annotations == none) and (stamp == false) {
    address-box = address-duobox(align(bottom, pad(bottom: 0.65em, sender-box)), recipient-box)
  }

  // Reverse the margin for the header, the address box and the information box
  pad(top: -margins.top, left: -margins.left, right: -margins.right, {
    grid(
      columns: 100%,
      rows: (letter-formats.at(format).header-size, 45mm),
      
      // Header box
      header,
      
      // Address / Information box
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
  })

  v(12pt)

  // Reference signs
  if (reference-signs != none) and (reference-signs.len() > 0) {
    grid(
      // Total width: 175mm
      // Delimiter: 4.23mm
      // Cell width: 50mm - 4.23mm = 45.77mm
      
      columns: (45.77mm, 45.77mm, 45.77mm, 25mm),
      rows: 12pt * 2,
      gutter: 12pt,
      
      ..reference-signs.map(sign => {
        let (key, value) = sign
        
        text(size: 8pt, key)
        linebreak()
        text(size: 10pt, value)
      })
    )
  }
  

  ////////////////////////////////
  //// Pre Text
  ////////////////////////////////

  grid(columns: (1fr, 1fr), align: bottom, heading[
    #if type == "offer" { 
      [#i18n(lang).offer \##subject]
    } else {
      [#i18n(lang).invoice \##subject]
    }
  ], [
    #set align(right)
    #seller.city, #date.display("[day].[month].[year]")
  ])
  line(start: (1cm, 0cm), length: 100% - 2cm, stroke: 0.5pt)
  [
    #if recipient.gender == "f" or recipient.gender == "F" {
      i18n(lang).salutation-f
    } else if recipient.gender == "m" or recipient.gender == "M" {
      i18n(lang).salutation-m
    } else {
      i18n(lang).salutation-o
    }
    #if "short-name" in recipient [#recipient.short-name] else [#recipient.name],
    #v(0.5em)
    #pre-text
  ]
    
  ////////////////////////////////
  //// Table of items
  ////////////////////////////////
  
  set table(stroke: none)

  let has-vat-exemption = seller.at("has-vat-exemption", default: false)
  let default-vat-rate = if has-vat-exemption { 0 } else { vat }

  table(
    columns: if has-vat-exemption {
      (auto, 1fr, auto, auto, auto)
    } else {
      (auto, 1fr, auto, auto, auto, auto, auto)
    },
    align: (col, row) => if row == 0 {
      (right, left, center, center, center, center, center).at(col)
    } else {
      (right, left, right, right, right, right, right).at(col)
    },
    inset: 6pt,
    if has-vat-exemption {
      table.header(
        table.hline(stroke: 0.5pt),
        i18n(lang).table-label.item-number,
        i18n(lang).table-label.description,
        i18n(lang).table-label.quantity,
        i18n(lang).table-label.single-price,
        i18n(lang).table-label.total-price,
        table.hline(stroke: 0.5pt),
      )
    } else {
      table.header(
        table.hline(stroke: 0.5pt),
        i18n(lang).table-label.item-number,
        i18n(lang).table-label.description,
        i18n(lang).table-label.quantity,
        i18n(lang).table-label.single-price,
        i18n(lang).table-label.vat-rate,
        i18n(lang).table-label.vat-price,
        i18n(lang).table-label.total-price,
        table.hline(stroke: 0.5pt),
      )
    },
    ..items
      .enumerate()
      .map(((index, row)) => {
        let item-vat-rate = row.at("vat-rate", default: default-vat-rate)

        if has-vat-exemption {
          (
            index + 1,
            row.description,
            str(row.at("quantity", default: "1")),
            format-currency(row.unit-price),
            format-currency((row.unit-price + (item-vat-rate / 100) * row.unit-price) * row.quantity),
          )
        } else {
          (
            index + 1,
            row.description,
            str(row.at("quantity", default: "1")),
            format-currency(row.unit-price),
            str(item-vat-rate) + "%",
            format-currency(row.at("quantity", default: 1) * (item-vat-rate / 100) * row.unit-price),
            format-currency((row.unit-price + (item-vat-rate / 100) * row.unit-price) * row.quantity),
          )
        }
      })
      .flatten()
      .map(str),
    table.hline(stroke: 0.5pt),
  )

  let total-no-vat = items.map(row => row.unit-price * row.at("quantity", default: 1)).sum()
  let total-vat = (
    items
      .map(row => (
        row.unit-price * row.at("quantity", default: 1) * row.at("vat-rate", default: default-vat-rate) / 100
      ))
      .sum()
  )
  let total-with-vat = total-no-vat + total-vat

  align(right, table(
    columns: 2,
    i18n(lang).total-no-vat, format-currency(total-no-vat),
    ..if not has-vat-exemption {
      (
        i18n(lang).total-vat,
        format-currency(total-vat),
        table.hline(stroke: 0.5pt),
        i18n(lang).total-with-vat,
        format-currency(total-with-vat),
      )
    },
  ))

  ////////////////////////////////
  //// End of table of items
  ////////////////////////////////  

  [ #post-text ]

  let request-date = if due-date == none {
    date+duration(days: due-duration)
  } else {
    due-date
  }
  if type == "offer" {
    [#i18n(lang).offer-validity #request-date.display("[day].[month].[year]").]
  } else {
    [#i18n(lang).payment-request-part1 #format-currency(total-with-vat) #i18n(lang).payment-request-part2 #request-date.display("[day].[month].[year]") #i18n(lang).payment-request-part3 #subject #i18n(lang).payment-request-part4]
    grid(columns: (1fr, 1fr), gutter: 1em, align: top, [
      #set par(leading: 0.40em)
      #set text(number-type: "lining")
      #i18n(lang).payment.recipient #seller.name \
      #i18n(lang).payment.bank #seller.bank \
      #i18n(lang).payment.iban #iban(seller.iban) \
      #i18n(lang).payment.bic #seller.bic \
      #i18n(lang).payment.reference #subject
    ], qrcode(epc-qr-content(seller, total-with-vat, subject), options: (
                scale: 1.0,
                bg-color: luma(100%),
                fg-color: luma(0%),
              )))
  }

  [
    #if seller.has-vat-exemption [
      #parbreak()
      #seller.at("vat-exemption-text", default: i18n(lang).vat-exemption-text)
    ]

    #v(0.5em)

    #i18n(lang).closing

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
    #seller.name
    #if has-title{[\ #emph(seller.title)]}
  ]

  // // ZUGFeRD/Factur-X for invoices
  // pdf.attach(
  //   "experiment.csv",
  //   relationship: "supplement",
  //   mime-type: "text/csv",
  //   description: "Raw Oxygen readings from the Arctic experiment",
  // )

}

