#!/usr/bin/python
# a utility for converting YAML files with hex-encoded utf-8 chars into pure utf-8
# thanks to Taggnostr in #unicode!

import re
import glob

def convert(m):
    bytes = m.group(0).replace('\\x', '').decode('hex_codec')
    return bytes.decode('utf-8')

for fname in glob.glob('*.yml'):
    b = open(fname).read().decode('utf-8')
    res = re.sub(r'(?:\\x[0-9A-F]{2})+', convert, b)
    open(fname, 'w').write(res.encode('utf-8'))
