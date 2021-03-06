% import re
%
% id_stack = []
%
% def render(e):
	% if not e.name:
		% id_stack.append(str(e.number))
	% else:
		% id_stack.append(e.name)
	% end
	% substeps = getattr(e, 'substeps', [])
	<div class="media" id="{{ '-'.join(id_stack) }}">
		% thumb_path = e.image.thumbnail.as_posix() if e.image else ''
		% full_path = e.image.large.as_posix() if e.image else ''

		% if substeps:
			<a class="pull-left" {{! 'href="' + full_path + '"' if full_path else ''}}>
				<div class="media-object" style="width: 64px; height: 64px; background: gray url({{ thumb_path }}) center; background-size: cover"></div>
			</a>
		%else:
			<a href="{{full_path}}">
				<img src="{{ e.image.medium.as_posix() }}" class="img-responsive"/>
			</a>
		% end
		<div class="media-body">
			<h4 class="media-heading">{{e.name}}</h4>

			% for e2 in substeps:
				% render(e2)
			% end
		</div>
	</div>
	% id_stack.pop()
% end
%
% def render_nav(e):
	% if not e.name:
		% id_stack.append(str(e.number))
	% else:
		% id_stack.append(e.name)
	% end
	<li {{! 'style="display: none"' if not e.name else '' }}>
		<a href="#{{ '-'.join(id_stack) }}">{{e.name}}</a>
		% substeps = getattr(e, 'substeps', [])
		% if any(s.name for s in substeps):
			<ul class="nav">
				% for s in substeps:
					% render_nav(s)
				% end
			</ul>
		% end
	</li>
	% id_stack.pop()
% end
%
<%

def flat_iter(e):
	if not e.name:
		id_stack.append(str(e.number))
	else:
		id_stack.append(e.name)
	end

	yield '-'.join(id_stack), e

	substeps = getattr(e, 'substeps', [])
	for s in substeps:
		yield from flat_iter(s)
	end

	id_stack.pop()
end

def iter_order(d, keys):
	for k in keys:
		if k in d:
			yield k, d[k]
		end
	end
	for k in sorted(d.keys()):
		if k not in keys:
			yield k, d[k]
		end
	end
end

rod_order = ['green', 'white', 'blue', 'yellow', 'red', 'gray']
connector_order = ['tan', 'gray', 'orange', 'lt. gray', 'red', 'green', 'yellow', 'blue', 'white', 'purple']
other_order = [
	'blue gear', 'red gear', 'yellow gear',
	'small hub', 'medium hub', 'small tyre', 'medium tyre'
]


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
	% if not e.parts and not e.parts_image:
		% return
	% end
	<div class="part-list">
		<p>
			% for part, count in iter_order(e.parts.get('rod', {}), rod_order):
				<span class="part">
				% part = part.lower()
				% if part in rod_ids:
					{{count}}
					<span class="knex-icon rod-{{re.sub(r'\W', '', part)}}" title="{{part}}"></span>
				% else:
					{{part}}: {{count}}
				% end
				</span>
			% end
		</p>
		<p>
			% for part, count in iter_order(e.parts.get('connector', {}), connector_order):
				<span class="part">
				% part = part.lower()
				% if part in connector_ids:
					{{count}}
					<span class="knex-icon connector-{{re.sub(r'\W', '', part)}}" title="{{part}}"></span>
				% else:
					{{part}}: {{count}}
				% end
				</span>
			% end
		</p>
		<p>
			% for part, count in iter_order(e.parts.get('other', {}), other_order):
				<span class="part">
				% part = part.lower()
				% if part in other_ids:
					{{count}}
					<span class="knex-icon other-{{re.sub(r'\W', '', part)}}" title="{{part}}"></span>
				% else:
					{{part}}: {{count}}
				% end
				</span>
			% end
		</p>
	</div>

% #	<!-- <section class="panel panel-default parts-panel">
% #		<div class="panel-body" style="white-space: nowrap">
% #			% if e.parts_image:
% #				<div class="row" style="margin-bottom: -15px; margin-top: 15px;">
% #					<img style="width: 100%" src="{{ e.parts_image.as_posix() }}" />
% #				</div>
% #			% end
% #		</div>
% #	</section> -->
% end
%
%
<!doctype html>
<html prefix="og: http://ogp.me/ns#">
	<head>
		<meta charset="utf-8">
		<meta http-equiv="X-UA-Compatible" content="IE=edge">
		<meta name="viewport" content="width=device-width, initial-scale=1">
		<script src="//code.jquery.com/jquery-2.1.0.min.js"></script>

		<link href="//netdna.bootstrapcdn.com/bootstrap/3.1.1/css/bootstrap.min.css" rel="stylesheet">
		<script src="//netdna.bootstrapcdn.com/bootstrap/3.1.1/js/bootstrap.min.js"></script>

		<meta property="og:title" content="Knex Grandfather Clock" />
		<meta property="og:url" content="http://eric-wieser.github.io/knex-clock" />
		<meta property="og:image" content="http://eric-wieser.github.io/knex-clock/{{ elem.substeps[-1].image.large.as_posix() }}" />

		<script>
		(function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
		(i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
		m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
		})(window,document,'script','//www.google-analytics.com/analytics.js','ga');

		ga('create', 'UA-24953524-3', 'eric-wieser.github.io');
		ga('send', 'pageview');
		</script>

		<script>
		ScrollSpy = $.fn.scrollspy.Constructor;

		var old = ScrollSpy.prototype.activate;
		ScrollSpy.prototype.activate = function(direct_target) {
			this.$element.trigger({ type: 'focused.bs.scrollspy', href: direct_target });
			return old.call(this, direct_target);
		}

		$(function() {
			$(window).scrollspy({target: ".the-sidebar", offset: 75 }).on('focused.bs.scrollspy', function(e) {
				var matching = $('.part-lists > div, .part-images > div').removeClass('active').filter(function() {
					return $(this).data('partsfor') == e.href;
				});
				console.log(matching, e.href);
				matching.addClass('active');
				if ('replaceState' in history) {
					history.replaceState('', '', e.href);
				}
			});


			var jumboHeight = $('.jumbotron').outerHeight();
			function parallax(){
				var scrolled = $(window).scrollTop();
				$('.jumbotron').css('background-position-y', Math.min(2*scrolled / jumboHeight, 1) * 100 + '%');
			}

			$(window).scroll(function(e){
				parallax();
			});

			$(".the-sidebar").affix({
				offset: {
					top: function() {
						return $(".the-sidebar").parent().offset().top - 20;
					},
					bottom: 10
				}
			});
			var onResize;
			$(window).on('resize', onResize = function() {
				$(".the-sidebar").css('width', $(".the-sidebar").parent().width() + 'px')
			});
			$(window).on('load', function() {
				$(window).scrollspy("refresh");
				onResize();
			});
		})
		</script>
		<style>

			.the-sidebar.affix {
				position: static
			}


			.the-sidenav {
				margin-top: 20px;
				margin-bottom: 20px
			}

			.the-sidebar .nav>li>a {
				display: block;
				font-size: 13px;
				font-weight: 500;
				color: #999;
				padding: 4px 20px;
			}

			.the-sidebar .nav>li>a:hover,.the-sidebar .nav>li>a:focus {
				padding-left: 19px;
				color: #563d7c;
				text-decoration: none;
				background-color: transparent;
				border-left: 1px solid #563d7c
			}

			.the-sidebar .nav>.active>a,.the-sidebar .nav>.active:hover>a,.the-sidebar .nav>.active:focus>a {
				padding-left: 18px;
				font-weight: 700;
				color: #563d7c;
				background-color: transparent;
				border-left: 2px solid #563d7c
			}

			.the-sidebar .nav .nav {
				display: none;
				padding-bottom: 10px
			}

			.the-sidebar .nav .nav>li>a {
				padding-top: 1px;
				padding-bottom: 1px;
				padding-left: 30px;
				font-size: 12px;
				font-weight: 400
			}

			.the-sidebar .nav .nav>li>a:hover,.the-sidebar .nav .nav>li>a:focus {
				padding-left: 29px
			}

			.the-sidebar .nav .nav>.active>a,.the-sidebar .nav .nav>.active:hover>a,.the-sidebar .nav .nav>.active:focus>a {
				font-weight: 500;
				padding-left: 28px
			}

			.the-sidebar .nav .nav .nav>li>a {
				padding-left: 40px;
			}
			.the-sidebar .nav .nav .nav>li>a:hover,.the-sidebar .nav .nav .nav>li>a:focus {
				padding-left: 39px
			}

			.the-sidebar .nav .nav .nav>.active>a,.the-sidebar .nav .nav .nav>.active:hover>a,.the-sidebar .nav .nav .nav>.active:focus>a {
				padding-left: 38px
			}

			.part-list { text-align: right; }
			.part-lists .part-list {
				display: none;
			}
			.part-images {
				position: absolute;
				bottom: 0;
				left: 0;
				right: 0;
			}
			.part-images .part-image {
				display: none;
			}

			@media (min-width:992px) {
				.the-sidebar .nav>.active>ul {
					display: block
				}

				.the-sidebar.affix,.the-sidebar.affix-bottom {
					width: 213px
				}

				.the-sidebar.affix {
					position: fixed;
					top: 20px;
					bottom: 20px;
				}
				.the-sidebar.affix .part-images .part-image.active {
					display: block;
				}
				.the-sidebar.affix .part-lists .active .part-list {
					display: block;
				}

				.the-sidebar.affix-bottom {
					position: absolute
				}

				.the-sidebar.affix-bottom .the-sidenav,.the-sidebar.affix .the-sidenav {
					margin-top: 0;
					margin-bottom: 0
				}
			}

			@media (min-width:1200px) {
				.the-sidebar.affix-bottom,.the-sidebar.affix {
					width: 263px
				}
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
			% for rod, i in sorted(rod_ids.items()):
			.knex-icon.rod-{{re.sub(r'\W', '', rod)}} {
				background-image: url(pieces/{{ i }}.gif);
				text-indent: -9999px;
			}
			% end
			% for connector, i in sorted(connector_ids.items()):
			.knex-icon.connector-{{re.sub(r'\W', '', connector)}} {
				background-image: url(pieces/{{ i }}.gif);
				text-indent: -9999px;
			}
			% end
			% for other, i in sorted(other_ids.items()):
			.knex-icon.other-{{re.sub(r'\W', '', other)}} {
				background-image: url(pieces/{{ i }}.gif);
				text-indent: -9999px;
			}
			% end

			.part {
				display: block;
			}

			.jumbotron.main {
				background-image: url({{ elem.substeps[-1].image.large.as_posix() }});
				background-position: top;
				background-size: cover;
				height: 100%;
				height: 100vh;
				position: relative;
				margin-bottom: 0;
			}
			.jumbotron.main .container {
				color: white;
				text-shadow:  1px  1px 1px black,
				             -1px  1px 1px black,
				              1px -1px 1px black,
				             -1px -1px 1px black;
			}
			.all-parts {
				margin-bottom: 0;
			}
			.all-parts .part-list {
				text-align: left;
			}
			.all-parts .part-list .part {
				display: inline-block;
				text-align: right;
				width: 75px;
			}
			.footer {
				padding-top: 10px;
				background: #eee;
				text-align: center;
			}
		</style>

		<title>Knex grandfather clock</title>
	</head>
	<body data-spy="scroll">
		<div class="jumbotron main">
			<div style="position: absolute; bottom: 0; left: 0; right: 0">
				<div class="container">
					<h1>Knex grandfather clock</h1>
					<p>A clockwork model capable of keeping time for around 45 minutes</p>
				</div>
			</div>
		</div>
		<div class="jumbotron all-parts">
			<div class="container">
				% parts_table(elem)
				<h1>{{sum(x for y in elem.parts.values() for x in y.values())}} pieces</h1>
			</div>
		</div>
		<img src="parts.jpg" style="width: 100%; display: block; margin-bottoM: 30px"/>
		<div class="container">
			<div class="row">
				<div class="col-md-9">
					% for s in elem.substeps:
						% render(s)
					% end
				</div>
				<div class="col-md-3">
					<div class="the-sidebar" >
						<div class="row">
							<div class="col-lg-8 col-md-6">
								<ul class="nav">
									% for s in elem.substeps:
										% render_nav(s)
									% end
								</ul>
							</div>
							<div class="col-lg-4 col-md-6 part-lists">
								% for s in elem.substeps:
									% for i, e in flat_iter(s):
										<div data-partsfor="#{{i}}">
											% parts_table(e)
										</div>
									% end
								% end
							</div>
						</div>
						<div class="part-images">
							% for s in elem.substeps:
								% for i, e in flat_iter(s):
									% if e.parts_image:
										<div class="part-image" data-partsfor="#{{i}}">
											<a href="{{ e.parts_image.large.as_posix() }}">
												<img style="width: 100%" src="{{ e.parts_image.medium.as_posix() }}" />
											</a>
										</div>
									% end
								% end
							% end
						</div>
					</div>
				</div>
			</div>
		</div>
		<div class="footer">
			<div class="container">
				<p>
					Based off <a href="http://www.balmoralsoftware.com/knex/gclock01.htm">A design by Balmoral Software</a>.
					Built and documented by <a href="http://eric-wieser.tk">Eric Wieser</a>.
					Dismantled in 2008
				</p>
			</div>
		</div>
	</body>
</html>
