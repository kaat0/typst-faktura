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
  iban: "DE00000000000000000000",
  bic: "MUSTERBANKXXX",
  tel: "+49 123 456789",
  signature: image("signature.png", width: 5em),
)

#show: faktura(
  lang: "de",
  type: "offer",
  due-date: datetime(year: 2026, month: 02, day: 28),
  seller: seller,
  subject: "2025-01",
  // date: datetime(year: 2025, month: 09, day: 11),
  // Recipient
  recipient: (
    company: "Example Company GmbH",
    name: "Max Mustermann",
    gender: "M",
    street-number: "Beispielstraße 2",
    zip: "12345",
    city: "Beispielstadt",
  ),
  // Items
  items: (
    (quantity: 10, description: "Beispielposition 1", unit-price: 100.0),
    (quantity:  1, description: "Beispielposition 2", unit-price: 10000.0, vat-rate: 7),
  ),
  pre-text: [
    anbei finden Sie unser Angebot für die gewünschte Dienstleistung.
    - *Leistungsbeschreibung:* Beispielhafte Beschreibung der angebotenen Leistungen.
    - *Umfang:* Details zum Leistungsumfang und ggf. zur Vorgehensweise.
  ],
  post-text: [
    Für Rückfragen stehen wir Ihnen gerne zur Verfügung.
  ],
)
