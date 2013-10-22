#
# Name    : iappear for iScroll
# Author  : Norris, justnorris.com, @justnorris
# Version : 1.0.0
# Repo    : https://github.com/justnorris/iappear.js
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

		@target = 
			top: -1
			bottom: -1
		@position = -1

		self = this

		@status = false
		@appeared = false
		@disappeared = false


		@get_conv_axis = ->
			if @opts.axis is "y" then "top" else "left"
	
		@update_location = ->
			axis = @get_conv_axis()
			target = @$element.offset()[axis] - @position

			@target = 
				top: target 
				bottom: target + @dimensions.element[@opts.axis]

		@gather_dimensions = ->
			@dimensions = 
				window:
					x: self.$window.width()
					y: self.$window.height()
				element: 
					x: self.$element.outerWidth()
					y: self.$element.outerHeight()

		@update_position = ->
			pos = iScroll.getComputedPosition()[self.opts.axis]

			self.position = pos + self.opts.offset
			self.maybe_update_visibility()

			return @position


		@is_visible = ->
			viewport = @dimensions.window[@opts.axis]

			port = 
				top: @position - viewport
				bottom: @position

			top = @target.top + port.top + @opts.offset
			bottom = @target.bottom + port.bottom + @opts.offset

			if top <= 0 and bottom >= 0
			then true
			else false 


		on_scroll = ->
			axis = self.opts.axis
			pos = this[axis] >> 0
			self.position = pos
			self.maybe_update_visibility()
			return pos

		@maybe_update_visibility = ->
			return if @appeared is true and @disappeared is true and @opts.once is true

			visible = @is_visible()
			@update_status( visible ) if @status isnt visible
			return visible

		@update_status = ( status = false ) ->
			if @status is status
				throw new Error "Status was already #{status}"
				return

			@status = status

			if status is true
				@appeared = true if @opts.once is true
				@opts.on_appear.call( @$element ) 
			else
				@disappeared = true if @opts.once is true
				@opts.on_disappear.call( @$element )



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


