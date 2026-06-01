
#import "entities.typ": seller, recipient

// DIN 5008 Adressfeld
// Position: 20mm von oben, 20mm von links
// Größe: 85mm × 45mm (Fensterbereich)
// Absenderzeile: 17.7mm von oben (Rücksendeangabe)
// Empfängeradresse: 27mm von oben

#let address-field(
  seller: (:),
  recipient: (:),
  return-address: true,
  window-envelope: true
) = { ... }