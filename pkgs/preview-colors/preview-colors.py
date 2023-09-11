#!/usr/bin/env python3

from sty import bg, rs
import argparse
import sys

def parse_color(text: str) -> (int, int, int):
    color_string = text[1:]
    color = int(color_string, base=16)
    return (
        (color >> 16) & 0xFF,
        (color >> 8) & 0xFF,
        color & 0xFF,
    )

parser = argparse.ArgumentParser("preview-colors")
parser.add_argument(
    "file",
    help="The file to read. Defaults to stdin",
    nargs='?',
    type=argparse.FileType('r'),
    default=sys.stdin,
)

args = parser.parse_args()
file = args.file

lines = file.readlines()
for line in lines:
    [r, g, b] = parse_color(line)
    print(f"{line.strip()} {bg(r, g, b)}                    {rs.all}")
