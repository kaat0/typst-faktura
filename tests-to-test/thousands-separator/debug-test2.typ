#import "/src/lib.typ" as faktura

// Test the add-thousands-separators function directly
#let test1 = faktura.add-thousands-separators("1234", ".")
[Test "1234" with ".": "#test1"]

#let test2 = faktura.add-thousands-separators("12345", ".")
[Test "12345" with ".": "#test2"]

#let test3 = faktura.add-thousands-separators("1234567", ".")
[Test "1234567" with ".": "#test3"]
