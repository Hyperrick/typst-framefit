#import "../lib.typ": framefit

#set page(width: 140mm, height: 90mm, margin: 10mm)
#set text(font: "DejaVu Sans Mono", size: 12pt)
#set par(leading: 4pt)

#framefit(width: 70mm, height: 30mm, min: 55%, max: none, max-lines: 3)[
  Different font metrics and paragraph leading are included in the measured
  line-height limit.
]

