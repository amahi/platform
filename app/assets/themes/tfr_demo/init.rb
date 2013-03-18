
def theme_init
	# Colors
	green = '#339933'
	purple = '#cc99cc'
	blue = '#336699'
	yellow = '#FFF804'
	red = '#ff0000'
	orange = '#cf5910'
	black = 'black'
	# for disk usage pie charts - the first one is the used disk, the second
	# is the free disk
	colors = ['#CA2841', '#333333', green, red, purple, orange, black]

	ret = {}

	ret[:name] = "tfr_demo"
	ret[:version] = "1.0"
	ret[:theme_uri] = "http://www.amahi.org"
	ret[:author] = "Solomon Seal, AKA - slm4996"
	ret[:author_uri] = ""
	ret[:disable_inheritance] = "false"
	ret[:gruff_theme] = {
	  # basic colors for other graphs
	  :colors => colors,
	  :marker_color => 'black',
	  # basic colors for other graphs
	  :font_color => 'black',
	  # if :background_colors is a string, it will be interpreted
	  # as a solid color, if an array, the two first colors define
	  # a gradient (top first, bottom second), which is rendered as
	  # the background
	  # note: you can also specify an image for bg colors in
	  # :background_image, *as long as* :background_colors is
	  # not defined or nil
	  :background_colors => ['#e1e2e1', '#ffffff']
	}

	ret
end

