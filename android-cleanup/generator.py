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
            "command": "docker volume rm lineage && docker volume create lineage",
            "agents": [f"host={host}", "queue=docker"],
            "priority": 5000,
        }
    )

    print(yaml.dump(pipeline))


if __name__ == "__main__":
    main()
