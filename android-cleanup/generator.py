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
            "command": "docker rm lineage && docker create lineage",
            "agents": [f"host={host}", "queue=docker"],
        }
    )

    print(yaml.dump(pipeline))


if __name__ == "__main__":
    main()
