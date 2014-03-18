from pathlib import Path
from bottle import SimpleTemplate
import json

with Path('outline.tpl').open() as f:
	template = SimpleTemplate(f.read())

class Step:
	def __init__(self, name, path):
		self.path = path
		self.name = name
		self.image = None

		parts_file = self.path / 'parts.json'
		if parts_file.exists():
			with parts_file.open() as f:
				self.parts = json.load(f)
		else:
			self.parts = None


	def __repr__(self):
		return "{s.__class__.__name__}({s.name!r}, {s.path!r})".format(s=self)

class ImageStep(Step):
	def __init__(self, name, path):
		super().__init__(name, path)
		self.image = self.path


class CompoundStep(Step):
	def __init__(self, name, path, substeps=None):
		super().__init__(name, path)
		self.substeps = [] if substeps is None else substeps

	def find_substeps(self, depth=float('inf')):
		paths = list(self.path.iterdir())
		steps = []
		for path in paths:
			parts = path.name.split('.')

			if not parts[0].isdigit() or len(parts) < 2:
				continue

			number = int(parts[0])

			if path.is_dir():
				substep = CompoundStep(parts[1], path)

				if depth > 1:
					substep.find_substeps(depth - 1)

			elif parts[-1].lower() == 'jpg':
				substep = ImageStep(parts[1] if len(parts) > 2 else '', path)

			else:
				continue

			substep.number = number

			steps.append(substep)

		steps.sort(key=lambda s: s.number)
		if steps and isinstance(steps[-1], ImageStep):
			self.image = steps[-1].image
			del steps[-1]

		self.substeps = steps

	def __repr__(self):
		if not self.substeps:
			return "{s.__class__.__name__}({s.name!r}, {s.path!r})".format(s=self)
		else:
			return "{s.__class__.__name__}({s.name!r}, {s.path!r}, {s.substeps!r})".format(s=self)


clock = Path('.')

s = CompoundStep('Clock', clock)
s.find_substeps()

print(s)

with Path('index.html').open('w') as f:
	print(template.render(elem=s), file=f)
