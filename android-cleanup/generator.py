import os
import sys
import yaml


def main():
    pipeline = {"steps": []}
    host = os.environ.get("HOST", None)
    if not host:
        print("HOST environment variable required")
        sys.exit(-1)

    pipeline["steps"].append(
        {
            "label": f"cleanup for {host}",
            "command": "uptime",
            "agents": [f"host={host}"],
        }
    )

    print(yaml.dump(pipeline))


if __name__ == "__main__":
    main()
