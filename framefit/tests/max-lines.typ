#import "../lib.typ": framefit

#set page(width: 120mm, height: 80mm, margin: 10mm)
#set text(size: 12pt)

#framefit(width: 60mm, height: 24mm, min: 60%, max: none, max-lines: 3)[
  This text is fitted while staying within three measured lines.
]

