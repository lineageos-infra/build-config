#!/usr/bin/env python

from datetime import datetime
import random
import sys
import uuid

import yaml

def main():
    targets = sys.stdin.read()
    pipeline = {"steps": []}
    today = datetime.today()

    for line in targets.split("\n"):
        if not line or line.startswith("#"):
            continue
        device, build_type, version = line.split()

        pipeline['steps'].append({
            'label': ':rotating_light: EXPERIMENTAL :rotating_light: {} {}'.format(device, today.strftime("%Y%m%d")),
            'trigger': 'android',
            'build': {
                'env': {
                    'DEVICE': device,
                    'RELEASE_TYPE': 'experimental',
                    'TYPE': build_type,
                    'BUILD_UUID': uuid.uuid4().hex,
                },
                'branch': version
            },
        })
    print(yaml.dump(pipeline))

if __name__ == '__main__':
    main()
