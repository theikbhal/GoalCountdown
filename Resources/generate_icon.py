#!/usr/bin/env python3
"""Generate app icon PNG for GoalCountdown"""
import struct, zlib, os, math

def create_png(width, height, pixels):
    def chunk(chunk_type, data):
        c = chunk_type + data
        return struct.pack('>I', len(data)) + c + struct.pack('>I', zlib.crc32(c) & 0xffffffff)
    raw = b''
    for y in range(height):
        raw += b'\x00'
        for x in range(width):
            r, g, b, a = pixels[y * width + x]
            raw += struct.pack('BBBB', r, g, b, a)
    sig = b'\x89PNG\r\n\x1a\n'
    ihdr = struct.pack('>IIBBBBB', width, height, 8, 6, 0, 0, 0)
    return sig + chunk(b'IHDR', ihdr) + chunk(b'IDAT', zlib.compress(raw)) + chunk(b'IEND', b'')

W, H = 1024, 1024
pixels = []

for y in range(H):
    for x in range(W):
        cx, cy = x - W//2, y - H//2
        dist = (cx*cx + cy*cy) ** 0.5
        radius = W * 0.45

        if dist < radius:
            t = dist / radius
            r = int(20 + (10 - 20) * t)
            g = int(30 + (10 - 30) * t)
            b = int(80 + (150 - 80) * t)
            a = 255

            inner = radius * 0.35
            if dist < inner:
                r, g, b = 255, 215, 0

            border = abs(dist - radius)
            if border < 4:
                r, g, b, a = 255, 255, 255, 200

            pixels.append((r, g, b, a))
        else:
            pixels.append((0, 0, 0, 0))

png_data = create_png(W, H, pixels)
out_dir = os.path.join(os.path.dirname(os.path.dirname(__file__)), 'Resources')
os.makedirs(out_dir, exist_ok=True)
with open(os.path.join(out_dir, 'AppIcon.png'), 'wb') as f:
    f.write(png_data)
print(f"Icon created: {len(png_data)} bytes")
