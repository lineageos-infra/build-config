#!/usr/bin/env python

from datetime import datetime
import os
import random
import sys
import uuid

import yaml

def main():
    devices = os.environ.get("DEVICES", "").split(",")
    targets = sys.stdin.read()
    pipeline = {"steps": []}
    today = datetime.today()

    for line in targets.split("\n"):
        if not line or line.startswith("#"):
            continue
        device, build_type, version, cadence = line.split()
        if device not in devices:
            continue
        pipeline['steps'].append({
            'label': '{} {}'.format(device, today.strftime("%Y%m%d")),
            'trigger': 'android',
            'build': {
                'env': {
                    'DEVICE': device,
                    'RELEASE_TYPE': 'nightly',
                    'TYPE': build_type,
                    'VERSION': version,
                    'BUILD_UUID': uuid.uuid4().hex,
                },
                'branch': version
            },
        })
    print(yaml.dump(pipeline))

if __name__ == '__main__':
    main()
