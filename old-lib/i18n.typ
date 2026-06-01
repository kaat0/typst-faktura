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
