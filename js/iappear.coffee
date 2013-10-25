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

		@offset = 0


		@status = false
		@appeared = false
		@disappeared = false
		
		self = @

		@get_conv_axis = ->
			if @opts.axis is "y" then "top" else "left"
	
		@update_offset = ->
			@offset = if typeof @opts.offset is 'function'
			then @opts.offset.call( @$element )
			else @opts.offset
			return

		@update_target = ->
			axis = @get_conv_axis()
			target = @$element.offset()[axis] - @position

			@target = 
				top: target 
				bottom: target + @dimensions.element[@opts.axis]

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

			@position = pos + @offset
			@maybe_update_visibility()

			return @position


		@is_visible = ->
			viewport = @dimensions.window[@opts.axis]

			port = 
				top: @position - viewport
				bottom: @position

			top = @target.top + port.top + @offset
			bottom = @target.bottom + port.bottom + @offset

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

		@refresh = ->
			self.gather_dimensions()
			self.update_offset()
			self.update_target()
			self.update_position()

		@init = ->
			@opts = $.extend( {}, @defaults, options )

			do @refresh

			iScroll.on "scroll", on_scroll
			iScroll.on "scrollEnd", on_scroll
			iScroll.on "refresh", @refresh

		# initialise the plugin
		@init()

		# make the plugin chainable
		return this

	# default plugin settings
	$.iappear::defaults =
		on_appear: ->
		on_disappear: ->
		offset: 0
		once: true
		axis: "y"


	$.fn.iappear = ( iScroll, options ) ->
		this.each ->
			if $( this ).data( 'iappear' ) is undefined
				plugin = new $.iappear( this, iScroll,  options )
				$( this ).data( 'iappear', plugin )


