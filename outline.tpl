% from pathlib import PurePosixPath
% import re

% def render(e):
	<div class="media">
		% path = e.image.as_posix() if e.image else ''
		<a class="pull-left" {{! 'href="' + path + '"' if path else ''}}>
			<div class="media-object" style="width: 64px; height: 64px; background: gray url({{ path }}) center; background-size: cover"></div>
		</a>
		<div class="media-body">
			% if e.parts:
				% parts_table(e)
			% end
			<h4 class="media-heading">{{e.name}}</h4>

			% for e2 in getattr(e, 'substeps', []):
				% render(e2)
			% end
		</div>
	</div>
% end

<%
def iter_order(d, keys):
	for k in keys:
		if k in d:
			yield k, d[k]
		end
	end
	for k in d.keys():
		if k not in keys:
			yield k, d[k]
		end
	end
end

rod_order = ['green', 'white', 'blue', 'yellow', 'red', 'gray']
connector_order = ['tan', 'gray', 'orange', 'lt. gray', 'red', 'green', 'yellow', 'blue', 'white', 'purple']


other_ids = {
	'red gear': 90985,
	'small hub': 90978,
	'medium hub': 90979,
	'washer': 90994,
	'chain': 90987,
	'small tyre': 91975,
	'medium tyre': 91976,
	'joint': 90913,
	'yellow gear': 90998,
	'blue gear': 513130 # slightly wrong!
}

connector_ids = {
	c: i + 90900 for i, c in enumerate(connector_order)
}
connector_ids.update({
	'blue (metallic)': 91907
})

rod_ids = {
	r: i + 90950 for i, r in enumerate(rod_order)
}
rod_ids.update({
	'gray (black)': 919561,
	'white (black)': 90961,
	'red (tan)': 90957, # image derived from red rod
	'orange': 90958
})


%>

% def parts_table(e):
	% parts = e.parts
	<section class="panel panel-default pull-right parts-panel">
		<div class="panel-body" style="white-space: nowrap">
			<div class="row">
				<div class="col-md-4" style="text-align: right; padding: 0 5px">
					% for part, count in iter_order(parts.get('rod', {}), rod_order):
						% part = part.lower()
						% if part in rod_ids:
							{{count}}
							<span class="knex-icon rod-{{re.sub(r'\W', '', part)}}" title="{{part}}"></span>
						% else:
							{{part}}: {{count}}
						% end
						<br />
					% end
				</div>
				<div class="col-md-4" style="text-align: right; padding: 0 5px">
					% for part, count in iter_order(parts.get('connector', {}), connector_order):
						% part = part.lower()
						% if part in connector_ids:
							{{count}}
							<span class="knex-icon connector-{{re.sub(r'\W', '', part)}}" title="{{part}}"></span>
						% else:
							{{part}}: {{count}}
						% end
						<br />
					% end
				</div>
				<div class="col-md-4" style="text-align: right; padding: 0 5px">
					% for part, count in iter_order(parts.get('other', {}), []):
						% part = part.lower()
						% if part in other_ids:
							{{count}}
							<span class="knex-icon other-{{re.sub(r'\W', '', part)}}" title="{{part}}"></span>
						% else:
							{{part}}: {{count}}
						% end
						<br />
					% end
				</div>
			</div>
			% parts_image = e.path / 'parts.jpg'
			% if parts_image.exists():
				<div class="row" style="margin-bottom: -15px; margin-top: 15px;">
					<img style="width: 100%" src="{{ parts_image.as_posix() }}" />
				</div>
			% end
		</div>
	</section>
% end


<!doctype html>
<html>
	<head>
		<meta charset="utf-8">
		<meta http-equiv="X-UA-Compatible" content="IE=edge">
		<meta name="viewport" content="width=device-width, initial-scale=1">
		<script src="http://code.jquery.com/jquery-2.1.0.min.js"></script>

		<link href="http://netdna.bootstrapcdn.com/bootstrap/3.1.1/css/bootstrap.min.css" rel="stylesheet">
		<script src="http://netdna.bootstrapcdn.com/bootstrap/3.1.1/js/bootstrap.min.js"></script>

		<style>

			.parts-panel {
				width: 250px;
			}

			.knex-icon {
				display: inline-block;
				height: 25px;
				width: 25px;
				background-size: contain;
				background-repeat: no-repeat;
				background-position: top right;
				vertical-align: middle;
			}
			% for rod, i in rod_ids.items():
			.knex-icon.rod-{{re.sub(r'\W', '', rod)}} {
				background-image: url(pieces/{{ i }}.gif);
				text-indent: -9999px;
			}
			% end
			% for connector, i in connector_ids.items():
			.knex-icon.connector-{{re.sub(r'\W', '', connector)}} {
				background-image: url(pieces/{{ i }}.gif);
				text-indent: -9999px;
			}
			% end
			% for other, i in other_ids.items():
			.knex-icon.other-{{re.sub(r'\W', '', other)}} {
				background-image: url(pieces/{{ i }}.gif);
				text-indent: -9999px;
			}
			% end
		</style>

		<title>Test</title>
	</head>
	<body data-spy="scroll">
		<div class="container">
			% render(elem)
		</div>
	</body>
</html>
