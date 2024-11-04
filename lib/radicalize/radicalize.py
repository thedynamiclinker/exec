#!/usr/bin/env python

"""
Generates radicalize.jsonl in the current working directory, using primitives.txt.

Every time I tried to write "good code" to do this, the result sucked.
So let's just do this shit as simply as possible and iterate.
"""

# TODO: This code should *just* be about radicalizing the character,
# not about providing the Heisig keywords, which vary between the
# three series RTK, RTH, and RSH.

import json
from collections import defaultdict

lines = open('primitives.txt').read().splitlines()
kanji_num = 0
kanji_frac = 0
radical_num = 1
kanji = defaultdict(list)
heisig = []

with open('radicalize.jsonl', 'w') as radicalize:
    for line in lines:
        # print(line)
        line_num, idx, char, keyword, alternates, implementation = line.split(':')
        commented = line_num.startswith('#')
        line_num = int(line_num.strip('#'))

        if implementation == '-':
            implementation = []
        else:
            implementation = implementation.split('/')

        if alternates == '-':
            alternates = []
        else:
            alternates = alternates.split('/')

        if line_num == kanji_num+1:
            kanji_num += 1
            d = {
                'kanji_num': f"{str(kanji_num).zfill(4)}.000",
                'char': char,
                'keyword': keyword,
                'alternates': alternates,
                'radical': False,
                'implementation': implementation,
            }
            kanji[char].append(d)
            heisig.append(d)
            kanji_frac = 0
        else:
            kanji_frac += 1
            radical_num = round(kanji_num + (kanji_frac/1000), 3)
            d = {
                'kanji_num': f"{radical_num:08.3f}",
                'char': char,
                'keyword': keyword,
                'alternates': alternates,
                'radical': True,
                'implementation': implementation,
            }
            kanji[char].append(d)
            heisig.append(d)
        print(d)

        radicalize.write(json.dumps(d)+'\n')
