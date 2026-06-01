#import "@preview/faktura:0.1.0": faktura

#let seller = (
  gender: "O", // "M" or "F"
  name: "Alex Mueller",
  street-number: "Musterstraße 1",
  zip: "12345",
  city: "Musterstadt",
  vat-id: "DE123456789",
  has-vat-exemption: false,
  email: "alex@mustermail.de",
  bank: "Musterbank",
  iban: "AT022081500000698597",
  bic: "MUSTERBANKXXX",
  tel: "+49 123 456789",
  signature: image("signature.png", width: 5em),
)

#show: faktura.with(
  lang: "de",
  vat: 19,
  seller: seller,
  type: "invoice",
  subject: "12/25-001",
  due-duration: 14,
  date: datetime(year: 2025, month: 11, day: 15),
  recipient: (
    name: "Erika Mustermann",
    gender: "F",
    street-number: "Musterstraße 1",
    zip: "12345",
    city: "Musterstadt",
    tel: "+491234567890",
    email: "erika.mustermann@example.com",
    country: none,
    company: none,
    title: none,
  ),
  // Items
  items: (
    (quantity: 1, description: "Gebühr", unit-price: 1200.0),
  ),
  pre-text: "This text is shown *before* the items table.",
  post-text: "This text is shown *after* the items table."
)

This text is shown as *DOC*.
