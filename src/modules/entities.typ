// Constants
#let default-signature-height = 1.5em

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
