(function() {
  describe('iAppear', function() {
    var options;
    options = {
      on_appear: function() {
        return console.info("I'm appearing");
      },
      on_disappear: function() {
        return console.info("I'm disappearing");
      },
      once: true
    };
    beforeEach(function() {
      loadFixtures('fragment.html');
      this.$el = $('li:nth-child(48)');
      this.iScroll = new IScroll("#wrapper", {
        probeType: 3,
        mouseWheel: true
      });
      return this.addMatchers({
        toBeFunction: function() {
          if (typeof this.actual === "function") {
            return true;
          } else {
            return false;
          }
        }
      });
    });
    describe('plugin setup', function() {
      it("should be a jQuery Extension", function() {
        return expect($.fn.iappear).toBeDefined();
      });
      it('should be chainable', function() {
        return expect(this.$el.iappear(this.iScroll)).toBe(this.$el);
      });
      it('should offer default values', function() {
        var iappear;
        iappear = new $.iappear(this.$el, this.iScroll);
        return expect(iappear.defaults).toBeDefined();
      });
      it('should accept options', function() {
        var iappear;
        iappear = new $.iappear(this.$el, this.iScroll, options);
        expect(iappear.opts.on_appear).toBeFunction();
        expect(iappear.opts.on_disappear).toBeFunction();
        return expect(iappear.opts.once).toBeDefined();
      });
      return it('should utilize options', function() {
        var iappear;
        iappear = new $.iappear(this.$el, this.iScroll, options);
        expect(iappear.opts.on_appear).toBe(options.on_appear);
        expect(iappear.opts.on_disappear).toBe(options.on_disappear);
        return expect(iappear.opts.once).toBe(options.once);
      });
    });
    describe('plugin dependencies', function() {
      return it("should have a working iScroll instance", function() {
        var after, before;
        before = JSON.stringify(this.iScroll.getComputedPosition());
        this.iScroll.scrollBy(0, -10);
        after = JSON.stringify(this.iScroll.getComputedPosition());
        return expect(before).not.toMatch(after);
      });
    });
    describe('plugin basic behavior', function() {
      beforeEach(function() {
        return this.ia = new $.iappear(this.$el, this.iScroll);
      });
      it('should know where the $element is', function() {
        return expect(this.ia.location).toBeDefined();
      });
      it('should have a position', function() {
        return expect(this.ia.position).toBeDefined();
      });
      it('should update position be able to update position', function() {
        var before;
        before = this.ia.position;
        this.iScroll.scrollBy(0, -150);
        this.iScroll.scrollBy(0, -150);
        this.ia.update_position();
        return expect(this.ia.position).not.toEqual(before);
      });
      it("should update position automatically with iScroll Probe", function() {
        var before;
        this.iScroll.scrollBy(0, 10);
        this.ia.update_position();
        before = this.ia.position;
        this.iScroll.scrollBy(0, -150);
        this.iScroll.scrollBy(0, -150, 1);
        expect(this.ia.position).not.toEqual(before);
        return expect(isNaN(this.ia.position)).toBe(false);
      });
      it('should accept and utilize offset', function() {
        var expected_position, real_position;
        real_position = this.ia.position;
        expected_position = real_position + 100;
        this.ia.opts.offset = 100;
        this.ia.update_position();
        return expect(this.ia.position).toEqual(expected_position);
      });
      return it("should know whether an element is visible", function() {
        var amplified_pos;
        amplified_pos = {
          top: 1000000,
          bottom: -1000000
        };
        this.iScroll.scrollTo(0, amplified_pos.top);
        this.ia.update_position();
        expect(this.ia.is_visible()).toBe(false);
        this.iScroll.scrollTo(0, amplified_pos.bottom);
        this.ia.update_position();
        expect(this.ia.is_visible()).toBe(false);
        this.iScroll.scrollTo(0, this.ia.location);
        this.ia.update_position();
        return expect(this.ia.is_visible()).toBe(true);
      });
    });
    return describe('plugin callback behavior', function() {
      beforeEach(function() {
        var self;
        this.num = 0;
        self = this;
        return this.ia = new $.iappear(this.$el, this.iScroll, {
          on_appear: function() {
            return self.num = self.num + 10;
          },
          on_disappear: function() {
            return self.num = self.num - 20;
          }
        });
      });
      it("should trigger on_appear when an item appears", function() {
        this.iScroll.scrollTo(0, this.ia.location);
        this.ia.update_position();
        return expect(this.num).toBe(10);
      });
      it("shouldn't trigger on_appear again if the element is still visible", function() {
        this.iScroll.scrollTo(0, this.ia.location);
        this.ia.update_position();
        this.ia.update_position();
        return expect(this.num).toBe(10);
      });
      it("shouldn't trigger on_disappear if an element never has been visible", function() {
        this.iScroll.scrollTo(0, 10000);
        this.ia.update_position();
        return expect(this.num).toBe(0);
      });
      it('should trigger on_disappear if an element was visible', function() {
        this.iScroll.scrollTo(0, this.ia.location);
        this.ia.update_position();
        this.iScroll.scrollTo(0, 10000);
        this.ia.update_position();
        return expect(this.num).toBe(-10);
      });
      it('should not trigger on_disappear twice in a row', function() {
        this.iScroll.scrollTo(0, this.ia.location);
        this.ia.update_position();
        expect(this.num).toBe(10);
        this.iScroll.scrollTo(0, 10000);
        this.ia.update_position();
        expect(this.num).toBe(-10);
        this.iScroll.scrollTo(0, 5000);
        this.ia.update_position();
        return expect(this.num).toBe(-10);
      });
      it("should obey 'once' parameter (when true) ", function() {
        this.ia.opts.once = true;
        this.iScroll.scrollTo(0, this.ia.location);
        this.ia.update_position();
        expect(this.num).toBe(10);
        this.iScroll.scrollTo(0, 10000);
        this.ia.update_position();
        expect(this.num).toBe(-10);
        this.iScroll.scrollTo(0, this.ia.location);
        this.ia.update_position();
        expect(this.num).toBe(-10);
        this.iScroll.scrollTo(0, 10000);
        this.ia.update_position();
        return expect(this.num).toBe(-10);
      });
      return it("should obey 'once' parameter (when false) ", function() {
        this.ia.opts.once = false;
        this.iScroll.scrollTo(0, this.ia.location);
        this.ia.update_position();
        expect(this.num).toBe(10);
        this.iScroll.scrollTo(0, 10000);
        this.ia.update_position();
        expect(this.num).toBe(-10);
        this.iScroll.scrollTo(0, this.ia.location);
        this.ia.update_position();
        expect(this.num).toBe(0);
        this.iScroll.scrollTo(0, 10000);
        this.ia.update_position();
        return expect(this.num).toBe(-20);
      });
    });
  });

}).call(this);
