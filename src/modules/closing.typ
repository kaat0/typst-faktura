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
