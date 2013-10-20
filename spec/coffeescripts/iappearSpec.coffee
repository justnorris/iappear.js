describe 'iAppear', ->
  
	options =
		on_appear: ->
			console.info "I'm appearing"
		on_disappear: ->
			console.info "I'm disappearing"
		once: true

	beforeEach ->
		loadFixtures 'fragment.html'
		@$el = $('li:nth-child(48)')
		@iScroll = new IScroll "#wrapper",
			probeType: 3
			mouseWheel: true

		@addMatchers(
			toBeFunction: ->
				if typeof(@actual) is "function"
				then true
				else false
		)





	describe 'plugin setup', ->
		it "should be a jQuery Extension", ->
			expect( $.fn.iappear ).toBeDefined()

		it 'should be chainable', ->
			expect( @$el.iappear( @iScroll ) ).toBe @$el

		it 'should offer default values', ->
			iappear = new $.iappear( @$el, @iScroll )
			expect( iappear.defaults ).toBeDefined()

		it 'should accept options', ->
			iappear = new $.iappear( @$el, @iScroll, options )

			expect( iappear.opts.on_appear ).toBeFunction()
			expect( iappear.opts.on_disappear ).toBeFunction()
			expect( iappear.opts.once ).toBeDefined()

		it 'should utilize options', ->
			iappear = new $.iappear( @$el, @iScroll, options )

			expect( iappear.opts.on_appear ).toBe( options.on_appear )
			expect( iappear.opts.on_disappear ).toBe( options.on_disappear )
			expect( iappear.opts.once ).toBe( options.once )





	describe 'plugin dependencies', ->
		it "should have a working iScroll instance", ->

			before = JSON.stringify @iScroll.getComputedPosition()
			@iScroll.scrollBy(0, -10)
			after = JSON.stringify @iScroll.getComputedPosition()

			expect(before).not.toMatch(after)





	describe 'plugin behavior', -> 
		
		beforeEach ->
			@ia = new $.iappear( @$el, @iScroll )

		it 'should know where the $element is', ->
			expect( @ia.location ).toBeDefined()
		
		it 'should have a position', ->
			expect( @ia.position ).toBeDefined()

		it 'should update position be able to update position', ->
			before = @ia.position
			
			@iScroll.scrollBy( 0, -150 )
			@iScroll.scrollBy( 0, -150 )			
			@ia.update_position()	

			expect( @ia.position ).not.toEqual(before)

		it "should update position automatically with iScroll Probe", ->
			@iScroll.scrollBy( 0, 10 )
			@ia.update_position()	

			before = @ia.position
			
			@iScroll.scrollBy( 0, -150 )
			
			# Animating triggers the iScroll scroll events
			@iScroll.scrollBy( 0, -150, 1 ) # Animate in 1ms
			
			expect( @ia.position ).not.toEqual( before )
			expect( isNaN( @ia.position ) ).toBe( false )


		it 'should accept and utilize offset', ->
			real_position = @ia.position
			expected_position = real_position + 100

			@ia.opts.offset = 100
			@ia.update_position()
			
			expect( @ia.position ).toEqual( expected_position )

		it "should know whether an element is visible", ->
			amplified_pos =
				top: 1000000
				bottom: -1000000

			@iScroll.scrollTo(0, amplified_pos.top )
			@ia.update_position()
			expect( @ia.is_visible() ).toBe false

			@iScroll.scrollTo(0, amplified_pos.bottom )
			@ia.update_position()
			expect( @ia.is_visible() ).toBe false
			
			@iScroll.scrollTo(0, @ia.location )
			@ia.update_position()
			expect( @ia.is_visible() ).toBe true


		# it "should call back a function when an element appears", ->

		# it "should call back a function only once, if specified", ->

		# it "should call back a function when an element disappears", ->
























