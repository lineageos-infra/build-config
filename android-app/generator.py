#!/usr/bin/env python

from datetime import datetime

import os
import yaml


def main():
    with open(os.path.dirname(__file__) + "/apps.yml") as f:
        apps = yaml.safe_load(f)["apps"]

    pipeline = {"steps": []}
    today = datetime.today()

    for app in apps:
        pipeline["steps"].append(
            {
                "label": "{} {}".format(app["name"], today.strftime("%Y%m%d")),
                "trigger": "android-app",
                "build": {
                    "branch": "main",
                    "env": {
                        "APK_PATH": app["apk_path"],
                        "BRANCH": app["branch"],
                        "NAME": app["name"],
                        "REPO": app["repo"],
                    },
                },
            }
        )

    print(yaml.dump(pipeline))


if __name__ == "__main__":
    main()
