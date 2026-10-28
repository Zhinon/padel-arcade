"""Original provisional padel impacts; deterministic synthesis, no external samples."""
from pathlib import Path
import math, random, struct, wave
ROOT = Path(__file__).resolve().parents[1]
RATE = 44100
for name, duration, body, decay, level, noise_mix in [
    ('normal', .14, 240, 43, .62, .60),
    ('perfect', .12, 310, 55, .76, .78),
    ('defense', .18, 155, 30, .40, .35),
]:
    rng = random.Random(1200 + int(body))
    samples = []
    low = 0.0
    for index in range(round(duration * RATE)):
        t = index / RATE
        noise = rng.uniform(-1, 1)
        low += .22 * (noise - low)
        transient = (noise - low) * math.exp(-t * (decay * 1.8))
        resonance = (math.sin(2 * math.pi * body * t) + .35 * math.sin(2 * math.pi * body * 2.37 * t)) * math.exp(-t * decay)
        attack = min(1, t / .0008)
        fade = min(1, (duration - t) / .015)
        samples.append((noise_mix * transient + (1-noise_mix) * resonance) * attack * fade)
    peak = max(abs(value) for value in samples)
    pcm = b''.join(struct.pack('<h', round(value / peak * level * 32767)) for value in samples)
    with wave.open(str(ROOT / 'game' / 'audio' / f'impact-{name}.wav'), 'wb') as output:
        output.setparams((1, 2, RATE, 0, 'NONE', 'not compressed'))
        output.writeframes(pcm)
    print(f'{name}: {duration:.2f}s, peak {level:.2f}')
