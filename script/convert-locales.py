#!/usr/bin/python
# a utility for converting YAML files with hex-encoded utf-8 chars into pure utf-8
# thanks to Taggnostr in #unicode!

import re
import glob
import codecs

def convert(m):
    """Convert from \xXX-escape to the corresponding chars"""
    # this is a bit hackish but it works
    bytes = m.group(0).decode('unicode_escape')
    return bytes.decode('utf-8')

for fname in glob.glob('*.yml'):
    with codecs.open(fname, encoding='utf-8') as f:
        text = f.read()
    # find&replace all the \xXX sequences
    res = re.sub(r'(?:\\x[0-9A-Fa-f]{2})+', convert, text)
    with codecs.open(fname, 'w', encoding='utf-8') as f:
        f.write(res)
