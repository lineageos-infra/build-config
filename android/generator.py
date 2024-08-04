#!/usr/bin/env python

from datetime import datetime
import os
import random
import sys
import uuid

import yaml

def main():
    targets = sys.stdin.read()
    pipeline = {"steps": []}
    today = datetime.today()
    ship = os.getenv("SHIP")

    for line in targets.split("\n"):
        if not line or line.startswith("#"):
            continue
        device, build_type, version, cadence = line.split()

        # Build all day 1 devices for given version, otherwise only build monthly
        # builds once a month, and only build weekly builds once a week.
        if ship:
            if ship != version:
                continue
        elif cadence == "M":
            if random.Random(device).randint(1, 28) != today.day:
                continue
        elif cadence == "W":
            if random.Random(device).randint(1, 7) != today.isoweekday():
                continue

        pipeline['steps'].append({
            'label': '{} {}'.format(device, today.strftime("%Y%m%d")),
            'trigger': 'android',
            'build': {
                'env': {
                    'DEVICE': device,
                    'RELEASE_TYPE': 'nightly',
                    'TYPE': build_type,
                    'BUILD_UUID': uuid.uuid4().hex,
                },
                'branch': version
            },
        })
    print(yaml.dump(pipeline))

if __name__ == '__main__':
    main()
