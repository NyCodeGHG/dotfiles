#!/usr/bin/env python3
import argparse
import subprocess
import json

parser = argparse.ArgumentParser()
parser.add_argument("--skip", action="append", help="inputs to skip", default=[])

args, extra_args = parser.parse_known_args()

with open("flake.lock", "r") as f:
    lockfile = json.load(f)
    inputs = lockfile["nodes"]["root"]["inputs"].keys()

chosen_inputs = set(inputs) - set(args.skip)
cmd = ["nix", "flake", "update"]
cmd.extend(chosen_inputs)
cmd.extend(extra_args)
subprocess.run(cmd)
