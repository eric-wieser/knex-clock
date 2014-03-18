import csv
import json
from pathlib import Path
from collections import defaultdict

with open('grandfather clock.csv') as f:
	r = csv.reader(f)
	data = list(r)

# Collapse first two columns:
last_header = ''
for row in data:
	if row[0]:
		last_header = row[0]

	row[:2] = [(last_header, row[1])]

# delete last two columns:
for row in data:
	del row[-2:]

# delete first row
del data[0]
# delete last rows
del data[-2:]

# transpose
transposed = zip(*data)
_, *headings = next(transposed)

transposed_dict = {}
for r in transposed:
	section, *part_list = r
	part_dict = defaultdict(dict)
	for h, c in zip(headings, part_list):
		if c:
			part_dict[h[0]][h[1]] = int(c)

	transposed_dict[section] = dict(part_dict)

print( list(transposed_dict))

folders = {
	'Pendulum':         './*Pendulum',
	'Top back':         './*top/*inside/*back',
	'Top mechanism':    './*top/*inside/*mechanism',
	'Top Face':         './*top/*inside/*face',
	'Top right':        './*top/*inside/*right',
	'Top left':         './*top/*inside/*left',
	'Hands':            './*top/*inside/*hands',
	'Top front':        './*top/*inside/*front',
	'Top ball channel': './*top/*inside/*channel',
	'top roof':         './*top/*roof/*top',
	'top triangle':     './*top/*roof/*front',
	'Weight':           './*weight',
	'Spiral':           './*spiral',
	'Base':             './*frame/*base',
	'Tower upper':      './*frame/*tower/*top',
	'tower middle':     './*frame/*tower/*middle',
	'tower lower':      './*frame/*tower/*bottom',
}

p = Path('.')
for k, v in folders.items():
	folders[k] = next(p.glob(v))



for k, row in transposed_dict.items():
	with (folders[k] / 'parts.json').open('w') as f:
		json.dump(row, f)
	print(k)
	print(row)
	print()

