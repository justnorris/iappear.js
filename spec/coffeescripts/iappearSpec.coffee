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





	describe 'plugin basic behavior', -> 
		
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




	describe 'plugin callback behavior', ->
		beforeEach ->
			@num = 0
			self = @
			
			@ia = new $.iappear @$el, @iScroll, 
				on_appear: ->
					# console.info "Adding 10 to #{self.num}\nTotal: #{self.num + 10}"
					self.num = self.num + 10

				on_disappear: ->
					# console.info "Removing 10 from #{self.num}\nTotal: #{self.num - 20}"
					self.num = self.num - 20			


		it "should trigger on_appear when an item appears", ->
			@iScroll.scrollTo(0, @ia.location )
			@ia.update_position()

			expect( @num ).toBe( 10 )

		it "shouldn't trigger on_appear again if the element is still visible", ->
			@iScroll.scrollTo(0, @ia.location )
			
			@ia.update_position()
			@ia.update_position()

			expect( @num ).toBe( 10 )

		it "shouldn't trigger on_disappear if an element never has been visible", ->
			@iScroll.scrollTo(0, 10000 )
			@ia.update_position()
			
			expect( @num ).toBe( 0 )

		it 'should trigger on_disappear if an element was visible', ->
		  
			@iScroll.scrollTo(0, @ia.location )
			@ia.update_position()

			@iScroll.scrollTo(0, 10000 )
			@ia.update_position()
			
			expect( @num ).toBe( -10 )

		it 'should not trigger on_disappear twice in a row', ->

			@iScroll.scrollTo(0, @ia.location )
			@ia.update_position()

			expect( @num ).toBe( 10 )

			@iScroll.scrollTo(0, 10000 )
			@ia.update_position()

			expect( @num ).toBe( -10 )
			
			@iScroll.scrollTo(0, 5000 )
			@ia.update_position()

			expect( @num ).toBe( -10 )

		it "should obey 'once' parameter (when true) ", ->
			@ia.opts.once = true

			@iScroll.scrollTo(0, @ia.location )
			@ia.update_position()

			expect( @num ).toBe( 10 )

			@iScroll.scrollTo(0, 10000 )
			@ia.update_position()

			expect( @num ).toBe( -10 )
			
			@iScroll.scrollTo(0, @ia.location )
			@ia.update_position()

			expect( @num ).toBe( -10 )

			@iScroll.scrollTo(0, 10000 )
			@ia.update_position()
			
			expect( @num ).toBe( -10 )


		it "should obey 'once' parameter (when false) ", ->
			@ia.opts.once = false

			@iScroll.scrollTo(0, @ia.location )
			@ia.update_position()

			expect( @num ).toBe( 10 )

			@iScroll.scrollTo(0, 10000 )
			@ia.update_position()

			expect( @num ).toBe( -10 )
			
			@iScroll.scrollTo(0, @ia.location )
			@ia.update_position()

			expect( @num ).toBe( 0 )

			@iScroll.scrollTo(0, 10000 )
			@ia.update_position()
			
			expect( @num ).toBe( -20 )


		# it "should call back a function when an element disappears", ->
























