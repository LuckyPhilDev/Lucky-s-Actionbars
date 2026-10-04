import math, subprocess, os
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = "#14100c"  # outline ink

def meander_ring(cx, cy, r, n):
    """Greek-key units stamped around a circle, band centred on r."""
    w, h = 2 * math.pi * r / n, 26
    unit = (f"M0,{h} L0,0 L{w*.78:.1f},0 L{w*.78:.1f},{h*.72:.1f} "
            f"L{w*.28:.1f},{h*.72:.1f} L{w*.28:.1f},{h*.36:.1f} L{w*.52:.1f},{h*.36:.1f} "
            f"M0,{h} L{w:.1f},{h}")
    parts = []
    for i in range(n):
        a = 360 * i / n
        parts.append(f'<path d="{unit}" transform="rotate({a:.2f} {cx} {cy}) '
                     f'translate({cx - w/2:.1f} {cy - r - h/2:.1f})"/>')
    return "\n".join(parts)

def button(x, y, s, art, key):
    return f'''
  <g transform="translate({x} {y})">
    <rect x="0" y="0" width="{s}" height="{s}" rx="10" fill="#3a3f4a" stroke="{OUT}" stroke-width="8"/>
    <rect x="12" y="12" width="{s-24}" height="{s-24}" rx="5" fill="url(#slot)" stroke="{OUT}" stroke-width="5"/>
    <g transform="translate(12 12) scale({(s-24)/100})">{art}</g>
    <path d="M14 14 h{s-28} v{(s-28)*.42:.0f} q-{(s-28)/2:.0f} 14 -{s-28} 0z" fill="#fff" opacity=".13"/>
    <text x="{s-16}" y="38" text-anchor="end" font-family="Arial Black,Arial" font-weight="900" font-size="26"
          fill="#fff" stroke="{OUT}" stroke-width="7" paint-order="stroke">{key}</text>
  </g>'''

SWORD = f'''<rect width="100" height="100" fill="#7a1d1d"/>
  <path d="M38 62 L20 80" stroke="{OUT}" stroke-width="15" stroke-linecap="round"/>
  <path d="M38 62 L20 80" stroke="#7a4620" stroke-width="8" stroke-linecap="round"/>
  <path d="M88 12 L84 28 L46 66 L34 54 L72 16Z" fill="#e6edf5" stroke="{OUT}" stroke-width="4" stroke-linejoin="round"/>
  <path d="M86 14 L40 60" stroke="#9fb0c2" stroke-width="3"/>
  <path d="M26 48 L52 74" stroke="{OUT}" stroke-width="16" stroke-linecap="round"/>
  <path d="M26 48 L52 74" stroke="#e8c34a" stroke-width="9" stroke-linecap="round"/>
  <circle cx="17" cy="83" r="8" fill="#e8c34a" stroke="{OUT}" stroke-width="4"/>'''

FIRE = f'''<rect width="100" height="100" fill="#4a1a08"/>
  <path d="M50 10 C62 30 82 40 78 66 C75 84 62 92 50 92 C36 92 22 82 22 64 C22 48 34 42 36 26 C44 36 44 44 46 48 C50 36 52 24 50 10Z"
        fill="#ff8a1c" stroke="{OUT}" stroke-width="4" stroke-linejoin="round"/>
  <path d="M50 44 C58 56 66 62 64 74 C62 84 56 88 50 88 C42 88 36 82 36 72 C36 62 44 58 50 44Z" fill="#ffd84a"/>'''

FROST = f'''<rect width="100" height="100" fill="#123a5c"/>
  <g stroke="{OUT}" stroke-width="13" stroke-linecap="round">
    <path d="M50 14 V86 M19 32 L81 68 M19 68 L81 32"/></g>
  <g stroke="#bfe8ff" stroke-width="7" stroke-linecap="round">
    <path d="M50 14 V86 M19 32 L81 68 M19 68 L81 32"/>
    <path d="M40 20 L50 28 L60 20 M40 80 L50 72 L60 80" fill="none"/></g>
  <circle cx="50" cy="50" r="9" fill="#fff" stroke="{OUT}" stroke-width="3"/>'''

cx = cy = 256
S, G, PAD = 128, 10, 16
bar_w = 3 * S + 2 * G + 2 * PAD
bx, by = (512 - bar_w) / 2, 250
buttons = "".join(button(bx + PAD + i * (S + G), by + PAD, S, art, k)
                  for i, (art, k) in enumerate([(SWORD, 1), (FIRE, 2), (FROST, 3)]))

svg = f'''<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
<defs>
  <radialGradient id="gold" cx="40%" cy="35%" r="75%">
    <stop offset="0" stop-color="#ffe28a"/><stop offset=".55" stop-color="#e3a929"/><stop offset="1" stop-color="#9c6510"/></radialGradient>
  <radialGradient id="face" cx="45%" cy="40%" r="70%">
    <stop offset="0" stop-color="#f7c950"/><stop offset="1" stop-color="#c58718"/></radialGradient>
  <linearGradient id="iron" x1="0" y1="0" x2="0" y2="1">
    <stop offset="0" stop-color="#5d6575"/><stop offset="1" stop-color="#2b2f38"/></linearGradient>
  <linearGradient id="slot" x1="0" y1="0" x2="0" y2="1">
    <stop offset="0" stop-color="#1c1f26"/><stop offset="1" stop-color="#0c0d10"/></linearGradient>
</defs>
<rect width="512" height="512" fill="#010101"/>
<circle cx="{cx}" cy="{cy}" r="206" fill="url(#gold)" stroke="{OUT}" stroke-width="6"/>
<circle cx="{cx}" cy="{cy}" r="190" fill="none" stroke="#8a5a0e" stroke-width="3"/>
<g fill="none" stroke="#9a6812" stroke-width="5" stroke-linejoin="miter">{meander_ring(cx, cy, 166, 30)}</g>
<circle cx="{cx}" cy="{cy}" r="142" fill="url(#face)" stroke="#8a5a0e" stroke-width="4"/>
<!-- back bar peeking above: stacked bars read as "more bars" -->
<g transform="translate({cx} 180) rotate(-8)">
  <rect x="-150" y="-52" width="300" height="104" rx="14" fill="url(#iron)" stroke="{OUT}" stroke-width="8"/>
  {"".join(f'<rect x="{-138 + i*96}" y="-40" width="84" height="80" rx="6" fill="url(#slot)" stroke="{OUT}" stroke-width="5"/>' for i in range(3))}
  <rect x="-126" y="-28" width="60" height="56" fill="#2f6b2a" opacity=".9"/>
  <path d="M-96 -20 C-80 -8 -80 14 -96 22 C-112 14 -112 -8 -96 -20Z" fill="#7be05a" stroke="{OUT}" stroke-width="4"/>
  <rect x="-30" y="-28" width="60" height="56" fill="#4d2a6b"/>
  <path d="M0 -20 L8 -4 L24 0 L8 4 L0 20 L-8 4 L-24 0 L-8 -4Z" fill="#e2b8ff" stroke="{OUT}" stroke-width="4" stroke-linejoin="round"/>
  <rect x="66" y="-28" width="60" height="56" fill="#6b5a1d"/>
  <path d="M96 -20 L116 -10 C116 8 106 18 96 22 C86 18 76 8 76 -10Z" fill="#ffd65a" stroke="{OUT}" stroke-width="4" stroke-linejoin="round"/>
</g>
<rect x="{bx}" y="{by}" width="{bar_w}" height="{S + 2*PAD}" rx="16" fill="url(#iron)" stroke="{OUT}" stroke-width="9"/>
{"".join(f'<circle cx="{x}" cy="{y}" r="6" fill="#9aa3b3" stroke="{OUT}" stroke-width="3"/>' for x in (bx+10, bx+bar_w-10) for y in (by+12, by+S+2*PAD-12))}
{buttons}
</svg>'''

svg_path = os.path.join(HERE, "actionbars.svg")
png512 = os.path.join(HERE, "actionbars-512.png")
with open(svg_path, "w") as f:
    f.write(svg)

chrome = r"C:\Program Files\Google\Chrome\Application\chrome.exe"
subprocess.run([chrome, "--headless", "--disable-gpu", "--hide-scrollbars", "--force-device-scale-factor=1",
                "--window-size=512,512", "--default-background-color=00000000",
                f"--screenshot={png512}", "file:///" + svg_path.replace("\\", "/")], check=True,
               capture_output=True)
Image.open(png512).convert("RGB").resize((256, 256), Image.LANCZOS).save(os.path.join(HERE, "actionbars.png"))
print("ok")
