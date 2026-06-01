////////////////////////////////
// # Layout Functions
////////////////////////////////

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

/// Creates a simple header with seller information.
/// 
/// - seller (dict): Seller information
/// - lang (str): Language for VAT ID label
/// - region (str): Region code
/// - translations (dict): Translation dictionary from i18n
#let header-simple(seller, lang, region, translations) = {
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
    [#translations.vat-id #seller.vat-id]
  }
}

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
    pad(left: 5mm, underline(offset: 2pt, [
      #seller.name + ", "
      #if "title" in seller {[#emph(seller.title) + ", "]}
      #seller.street-number + ", "
      #seller.zip + " " + seller.city
      #if "country" in seller {", " + seller.country}
    ]))
  }
)

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
  pad(left: 5mm, 
    (if "company" in recipient {recipient.company + "\n" } else {""}) +
    (if "title" in recipient {recipient.title + "\n" } else {""}) +
    recipient.name + "\n" +
    recipient.street-number + "\n" +
    recipient.zip + " " + recipient.city +
    (if "country" in recipient {"\n" + recipient.country} else {""})
  )
}

/// Creates an address box with 2 or 3 fields (sender, optional annotations, recipient)
/// and optional repartitioning for a stamp.
/// 
/// The width is determined automatically. Row heights:
/// - 2 fields (no annotations): (17.7mm, 27.3mm)
/// - 3 fields (with annotations): (5mm, 12.7mm, 27.3mm) or with stamp: (5mm, 21.16mm, 18.84mm)
/// 
/// - sender (content, none): The sender box
/// - recipient (content, none): The recipient box
/// - annotations (content, none): Optional annotations box. If none, uses 2-field layout.
/// - stamp (boolean): Enable stamp repartitioning (only used with 3-field layout).
///   If enabled, the annotations box and the recipient box divider is moved 8.46mm (about 2 lines) down.
#let create-address-box(sender, recipient, annotations: none, stamp: false) = {
  if annotations == none {
    // Two-box layout (sender + recipient)
    grid(columns: 1, rows: (17.7mm, 27.3mm), sender, recipient)
  } else {
    // Three-box layout (sender + annotations + recipient)
    let rows = if stamp {
      (5mm, 12.7mm + (4.23mm * 2), 27.3mm - (4.23mm * 2))
    } else {
      (5mm, 12.7mm, 27.3mm)
    }
    grid(columns: 1, rows: rows, sender, annotations, recipient)
  }
}
