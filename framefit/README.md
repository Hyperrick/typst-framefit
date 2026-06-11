# Framefit

Text fitting for fixed Typst frames.

`framefit` adjusts text size between percentage bounds so text fits inside a
fixed frame. It can shrink overflowing text, grow short text, or only shrink
when overflow is detected.

By default, there is no configured maximum. `framefit` grows text until it first
overflows the frame, then backs off to the largest fitting size. Set a
percentage `max` to cap growth, or use `max: -1` as another way to request no
maximum.

Set `max-lines` to limit the fitting result by line count. For example,
`max-lines: 3` grows or shrinks text until it fits the frame while staying
within three measured lines.

## Usage

After publishing to Typst Universe:

```typst
#import "@preview/framefit:0.1.0": framefit, fit-copy
```

While developing locally from this repository:

```typst
#import "lib.typ": framefit, fit-copy
```

Create a fitted frame directly:

```typst
#framefit(
  width: 70mm,
  height: 24mm,
  min: 70%,
  max: none,
  max-lines: 3,
  inset: 6pt,
  stroke: 0.5pt,
)[
  This text grows or shrinks until it fits the frame.
]
```

Fit text inside an existing frame:

```typst
#block(width: 70mm, height: 24mm, stroke: 0.5pt, inset: 6pt)[
  #fit-copy(min: 70%)[
    This uses the surrounding block as the frame.
  ]
]
```

Use `only-if-overflow: true` to prevent growth when the original text already
fits:

```typst
#framefit(
  width: 70mm,
  height: 24mm,
  min: 70%,
  max: 130%,
  only-if-overflow: true,
)[Short text]
```

## API

### `fit-copy`

```typst
#fit-copy(
  min: 70%,
  max: none,
  max-lines: none,
  steps: 24,
  only-if-overflow: false,
  body,
)
```

Fits `body` to the size of the surrounding layout container. This is the core
helper for existing frames.

`max` can be a percentage, `none`, or `-1`. `none` and `-1` mean there is no
configured maximum; the largest fitting size is calculated from the frame.

`max-lines` can be an integer or `none`. Typst does not expose exact laid-out
line boxes, so the line limit is calculated from measured text height in the
current text style. This is intended for ordinary text without hyphenation.

How `max-lines` is calculated:

1. `framefit` measures the body at a candidate font-size percentage and the
   frame's available width.
2. It measures a synthetic line sample with the requested number of lines, for
   example three `Ag` lines for `max-lines: 3`.
3. The candidate size is accepted only if the body fits the physical frame and
   its measured height is not taller than the line sample.

Conceptually, this is the same as calculating the maximum allowed text height
from the requested line count and the current line height. The implementation
lets Typst calculate that height by measurement instead of manually multiplying,
because the real line box also depends on font metrics, text size, top/bottom
edges, and `par(leading:)`.

This means `max-lines` follows the active text style, including font metrics and
configured paragraph leading. It is less exact for content that changes style
inside the body, includes non-text elements, uses manual line breaks, or relies
on hyphenation.

Configure line spacing with Typst's normal paragraph setting:

```typst
#set par(leading: 4pt)

#framefit(width: 70mm, height: 30mm, max-lines: 3)[
  This text is fitted using the active paragraph leading.
]
```

### `framefit`

```typst
#framefit(
  width: auto,
  height: auto,
  min: 70%,
  max: none,
  max-lines: none,
  steps: 24,
  inset: 0pt,
  stroke: none,
  fill: none,
  radius: 0pt,
  only-if-overflow: false,
  body,
)
```

Creates a `block` frame and fits `body` inside it.

`max` accepts the same values as `fit-copy`.

## Overflow Behavior

If text still does not fit at `min`, compilation fails with a clear error.
Reduce the content, make the frame larger, or lower `min`.

## Development

Compile the demo with Docker:

```sh
docker run --rm -v "$PWD":/work -w /work ghcr.io/typst/typst:latest \
  compile --root /work examples/demo.typ examples/demo.pdf
docker run --rm -v "$PWD":/work -w /work ghcr.io/typst/typst:latest \
  compile --root /work examples/grows-to-max.typ examples/grows-to-max.pdf
docker run --rm -v "$PWD":/work -w /work ghcr.io/typst/typst:latest \
  compile --root /work examples/shrinks-to-min.typ examples/shrinks-to-min.pdf
docker run --rm -v "$PWD":/work -w /work ghcr.io/typst/typst:latest \
  compile --root /work examples/no-maximum.typ examples/no-maximum.pdf
docker run --rm -v "$PWD":/work -w /work ghcr.io/typst/typst:latest \
  compile --root /work examples/max-lines.typ examples/max-lines.pdf
docker run --rm -v "$PWD":/work -w /work ghcr.io/typst/typst:latest \
  compile --root /work examples/max-lines-styles.typ examples/max-lines-styles.pdf
```

Run the compile checks:

```sh
docker run --rm -v "$PWD":/work -w /work ghcr.io/typst/typst:latest \
  compile --root /work tests/fit-basic.typ tests/fit-basic.svg
docker run --rm -v "$PWD":/work -w /work ghcr.io/typst/typst:latest \
  compile --root /work tests/grow.typ tests/grow.svg
docker run --rm -v "$PWD":/work -w /work ghcr.io/typst/typst:latest \
  compile --root /work tests/only-if-overflow.typ tests/only-if-overflow.svg
docker run --rm -v "$PWD":/work -w /work ghcr.io/typst/typst:latest \
  compile --root /work tests/no-maximum-none.typ tests/no-maximum-none.svg
docker run --rm -v "$PWD":/work -w /work ghcr.io/typst/typst:latest \
  compile --root /work tests/no-maximum-minus-one.typ tests/no-maximum-minus-one.svg
docker run --rm -v "$PWD":/work -w /work ghcr.io/typst/typst:latest \
  compile --root /work tests/max-lines.typ tests/max-lines.svg
docker run --rm -v "$PWD":/work -w /work ghcr.io/typst/typst:latest \
  compile --root /work tests/max-lines-styles.typ tests/max-lines-styles.svg
```

`tests/impossible.typ` is expected to fail because it verifies the minimum-size
overflow error.

## Limitations

- Designed for paged output: PDF, PNG, and SVG.
- The fitting calculation uses Typst layout measurement, so unusual content may
  need manual checking.
- The MVP focuses on text content. Other content can work, but is not the
  primary target yet.
