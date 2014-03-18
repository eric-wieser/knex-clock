from pathlib import Path
import json

from bottle import SimpleTemplate
from PIL import Image

with Path('outline.tpl').open() as f:
	template = SimpleTemplate(f.read())
def flat( *nums ):
    'Build a tuple of ints from float or integer arguments. Useful because PIL crop and resize require integer points.'
    
    return tuple( int(round(n)) for n in nums )

class Size(object):
    def __init__(self, pair):
        self.width = float(pair[0])
        self.height = float(pair[1])

    @property
    def aspect_ratio(self):
        return self.width / self.height

    @property
    def size(self):
        return flat(self.width, self.height)

def cropped_thumbnail(img, size):
    '''
    Builds a thumbnail by cropping out a maximal region from the center of the original with
    the same aspect ratio as the target size, and then resizing. The result is a thumbnail which is
    always EXACTLY the requested size and with no aspect ratio distortion (although two edges, either
    top/bottom or left/right depending whether the image is too tall or too wide, may be trimmed off.)
    '''

    original = Size(img.size)
    target = Size(size)

    if target.aspect_ratio > original.aspect_ratio:
        # image is too tall: take some off the top and bottom
        scale_factor = target.width / original.width
        crop_size = Size( (original.width, target.height / scale_factor) )
        top_cut_line = (original.height - crop_size.height) / 2
        img = img.crop( flat(0, top_cut_line, crop_size.width, top_cut_line + crop_size.height) )
    elif target.aspect_ratio < original.aspect_ratio:
        # image is too wide: take some off the sides
        scale_factor = target.height / original.height
        crop_size = Size( (target.width/scale_factor, original.height) )
        side_cut_line = (original.width - crop_size.width) / 2
        img = img.crop( flat(side_cut_line, 0,  side_cut_line + crop_size.width, crop_size.height) )

    return img.resize(target.size, Image.ANTIALIAS)


class Step:
	def __init__(self, name, path):
		self.path = path
		self.name = name
		self.thumbnail = None
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
		self.thumbnail = self.path.parent / (self.path.stem + '.thumb' + self.path.suffix)

		im = Image.open(self.path.open('rb'))
		im = cropped_thumbnail(im, (64, 64))
		im.save(self.thumbnail.open('wb'), "JPEG")

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

			elif parts[-1].lower() == 'jpg' and parts[-2] != 'thumb':
				substep = ImageStep(parts[1] if len(parts) > 2 else '', path)

			else:
				continue

			substep.number = number

			steps.append(substep)

		steps.sort(key=lambda s: s.number)
		if steps and isinstance(steps[-1], ImageStep):
			self.thumbnail = steps[-1].thumbnail

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
