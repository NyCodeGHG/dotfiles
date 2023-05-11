#!/usr/bin/env python3
import os
import subprocess
import sys

figlist = subprocess.run(['figlist'], capture_output = True, encoding = 'utf-8')
fonts = figlist.stdout.splitlines()
fonts = filter(lambda font: ' ' not in font and '-' not in font, fonts)

input = sys.stdin.read()

pager = subprocess.Popen(['less', '-R', '-F', '-X'], stdin=subprocess.PIPE)

def generate_preview(font: str, text: str):
    process = subprocess.run(['figlet', '-t', '-f', font], capture_output = True, input = text.encode('utf-8'))
    if process.returncode == 0:
        return process.stdout
    return None

for font in fonts:
    preview = generate_preview(font, input)
    if preview:
        pager.stdin.write(f"Font: {font}\n".encode('utf-8'))
        pager.stdin.write(preview)
        pager.stdin.write('\n'.encode('utf-8'))

pager.stdin.close()
pager.wait()
