#
# Name    : iappear for iScroll
# Author  : Norris, justnorris.com, @justnorris
# Version : 1.0.0
# Repo    : <repo url>
# Website : http://justnorris.com/iappear-for-iscroll
#

jQuery ->
	$.iappear = ( element, iScroll, options ) ->
	
		if typeof iScroll isnt "object" or iScroll.version == null
			throw new Error "iScroll5 or greater is reqired for this plugin to work."
			return this     

		# plugin settings
		@opts = {}

		# jQuery version of DOM element attached to the plugin
		@$element = $ element
		@element = @$element.get(0)

		@$window = $(window)

		@location = -1
		@position = -1

		self = this

		@get_conv_axis = ->
			if @opts.axis is "y" then "top" else "left"
	
		@update_location = ->
			axis = @get_conv_axis()
			loc = @$element.position()
			@location = loc[axis]

		@gather_dimensions = ->
			@dimensions = 
				window:
					x: @$window.width()
					y: @$window.height()
				element: 
					x: @$element.outerWidth()
					y: @$element.outerHeight()

		@update_position = ->
			pos = iScroll.getComputedPosition()[@opts.axis]

			@position = pos + @opts.offset
			@position


		@is_visible = ->
			win = @dimensions.window[@opts.axis]
			el = @dimensions.element[@opts.axis]
			if 	@location >= @position and 
				( @location + el ) <= ( @position + win) 
			then true
			else false 


		on_scroll = ->
			axis = self.opts.axis
			pos = this[axis] >> 0

			self.position = pos


		@init = ->
			@opts = $.extend( {}, @defaults, options )
			@gather_dimensions()
			@update_location()
			@update_position()

			iScroll.on "scroll", on_scroll
			iScroll.on "scrollEnd", on_scroll

			iScroll.on "refresh", @gather_dimensions
			iScroll.on "refresh", @update_position


		# initialise the plugin
		@init()

		# make the plugin chainable
		return this

	# default plugin settings
	$.iappear::defaults =
		on_appear: ->
		on_disappear: ->
		once: true
		offset: 0
		axis: "y"


	$.fn.iappear = ( iScroll, options ) ->
		this.each ->
			if $( this ).data( 'iappear' ) is undefined
				plugin = new $.iappear( this, iScroll,  options )
				$( this ).data( 'iappear', plugin )

	# this.get_instance = ->
	#     return $(this).data( "iappear" )

	# return this






