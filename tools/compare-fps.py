#!/usr/bin/env python3
"""Compare completed frame schedule runs; never substitutes missing runs."""
import json
import math
from pathlib import Path

report_dir = Path(__file__).resolve().parent.parent / 'docs' / 'previews'
reports = [json.loads((report_dir / f'ball-fps-{fps}.json').read_text()) for fps in (30, 60, 120)]
base = reports[0]
tolerance = 0.00001
checks = []
for report in reports:
    position_error = math.dist(base['position'], report['position'])
    velocity_error = math.dist(base['velocity'], report['velocity'])
    matching = len(base['events']) == len(report['events'])
    if matching:
        matching = all(
            a['surface'] == b['surface']
            and abs(a['time'] - b['time']) <= tolerance
            and math.dist(a['position'], b['position']) <= tolerance
            for a, b in zip(base['events'], report['events'])
        )
    passed = (
        abs(report['elapsed'] - 2.0) <= tolerance
        and report['physics_ticks_per_second'] == 120
        and position_error <= tolerance
        and velocity_error <= tolerance
        and matching
    )
    checks.append({'render_fps': report['render_schedule_fps'], 'position_error_m': position_error,
                   'velocity_error_mps': velocity_error, 'matching_contacts': matching, 'passed': passed})
summary = {'tolerance': tolerance, 'checks': checks, 'passed': all(item['passed'] for item in checks)}
(report_dir / 'ball-fps-comparison.json').write_text(json.dumps(summary, indent=2) + '\n')
print(json.dumps(summary))
raise SystemExit(0 if summary['passed'] else 1)
