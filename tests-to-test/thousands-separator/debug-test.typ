#import "/src/lib.typ" as faktura

#let result4 = faktura.format-currency(1234.56, locale: "de", region: "DE", currency: "EUR", show-symbol: false)
[Result: "#result4"]
[Contains "1.234": #result4.contains("1.234")]
[Length: #result4.len()]
