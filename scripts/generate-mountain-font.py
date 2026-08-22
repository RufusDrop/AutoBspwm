#!/usr/bin/env fontforge
"""Build the single-glyph font used by Matterhorn's prompt and Polybar."""
import sys

import fontforge
import psMat


if len(sys.argv) != 3:
    raise SystemExit("usage: generate-mountain-font.py INPUT.svg OUTPUT.ttf")

source, destination = sys.argv[1:]
font = fontforge.font()
font.encoding = "UnicodeFull"
font.em = 1000
font.ascent = 850
font.descent = 150
font.fontname = "AutoBspwmMountain"
font.familyname = "AutoBspwm Mountain"
font.fullname = "AutoBspwm Mountain Regular"
font.weight = "Regular"
font.version = "1.0"

glyph = font.createChar(0xE000, "mountain")
glyph.importOutlines(source)
x_min, y_min, x_max, y_max = glyph.boundingBox()
width = max(x_max - x_min, 1)
height = max(y_max - y_min, 1)
scale = min(820.0 / width, 720.0 / height)
glyph.transform(psMat.scale(scale))
x_min, y_min, x_max, y_max = glyph.boundingBox()
glyph.transform(psMat.translate((1000 - (x_max - x_min)) / 2 - x_min, 40 - y_min))
glyph.removeOverlap()
glyph.correctDirection()
glyph.width = 1000
font.generate(destination)
font.close()
