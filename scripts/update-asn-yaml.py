#!/usr/bin/env nix-shell
#!nix-shell -i python3 -p python3Packages.aggregate6 python3Packages.requests python3Packages.xdg-base-dirs python3Packages.pyyaml

import argparse
import json
from dataclasses import dataclass
from datetime import datetime, timedelta, timezone
from enum import Enum
from pathlib import Path

import requests
import yaml
from aggregate6 import aggregate
from xdg_base_dirs import xdg_cache_home

parser = argparse.ArgumentParser()
parser.add_argument("file", help="The yaml file to update.")
parser.add_argument("asn", nargs="+", help="The ASNs to use.")
parser.add_argument("--action", default="DENY", help="Anubis action to use.")

args = parser.parse_args()


class CacheResult(Enum):
    UP_TO_DATE = 1
    MISSING = 2
    STALE = 3


def cache_file() -> Path:
    return xdg_cache_home().joinpath("update-asn-yaml").joinpath("table.jsonl")


def bgp_table_needs_update() -> CacheResult:
    table = cache_file()
    if not table.parent.exists():
        return CacheResult.MISSING
    stat_result = table.stat()
    modified_date = datetime.fromtimestamp(stat_result.st_mtime, tz=timezone.utc)
    if modified_date < (datetime.now(tz=timezone.utc) - timedelta(hours=2)):
        return CacheResult.STALE
    else:
        return CacheResult.UP_TO_DATE


def download_bgp_table():
    response = requests.get(
        "https://bgp.tools/table.jsonl",
        headers={"user-agent": "update-asn-yaml - me@nycode.dev"},
    )
    response.raise_for_status()
    table = cache_file()
    table.parent.mkdir(parents=True, exist_ok=True)
    with table.open(mode="wb") as f:
        for chunk in response.iter_content(chunk_size=512):
            f.write(chunk)


def read_entries():
    table = cache_file()
    with table.open("r") as file:
        while line := file.readline():
            yield parse_line(line.rstrip())


@dataclass
class Entry:
    cidr: str
    asn: int


def parse_line(line: str) -> Entry:
    j = json.loads(line)
    return Entry(j["CIDR"], int(j["ASN"]))


def filter_entries(entries, asns: [int]):
    return filter(lambda entry: entry.asn in asns, entries)


result = bgp_table_needs_update()
if result != CacheResult.UP_TO_DATE:
    print("Updating BGP table cache.")
    download_bgp_table()

asns = list(map(int, args.asn))
addresses = aggregate([prefix.cidr for prefix in filter_entries(read_entries(), asns)])
with Path(args.file).open("w+") as f:
    yaml.dump(
        [
            {
                "name": f"asn-{'-'.join(args.asn)}",
                "action": args.action,
                "remote_addresses": addresses,
            }
        ],
        f,
    )
