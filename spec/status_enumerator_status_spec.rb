require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe StatusEnumerator::Status do
  def status_new(*args, &block); StatusEnumerator::Status.send(:new, *args, &block) end
  
  it 'is Class' do
    StatusEnumerator::Status.should be_instance_of(Class)
  end

  describe '.new(parent_status, &block)' do
    it 'is private' do
      StatusEnumerator::Status.tap do |x|
        x.should be_respond_to(:new, true)
        x.should_not be_respond_to(:new)
      end
    end
    
    it 'stores parent_status in @parent_status' do
      owner = status_new(nil) {}
      status_new(owner) {}.instance_variable_get(:@parent_status).should == owner
    end

    it 'permits parent_status of nil' do
      lambda { status_new(nil) {} }.should_not raise_error
    end

    it 'when parent_status is not kind of Status, it raises an ArgumentError' do
      lambda { status_new(:symbol) {} }.should raise_error(ArgumentError)
    end
    
    it 'stores block in @block' do
      func = lambda {|e| e == :ok }
      status_new(nil, &func).instance_variable_get(:@block).should == func
    end
    
    it 'in case of owner is not nil and block is nil, it store @block of owner in @block' do
      func = lambda {|e| e == :ok }
      status_new(status_new(nil, &func)).instance_variable_get(:@block).should == func
    end

    it 'in the case of parent_status and block is nil, it raises an ArgumentError' do
      lambda { status_new(nil) }.should raise_error(ArgumentError)
    end
  end
  
  describe '(#each_status(enum))' do
    before do
      @count = 0
      @call = nil
      @each = status_new(nil) do |e|
        @call.call(e) if @call
        @count += 1
      end
    end
    def do_each(enum); @each.send(:each_status, enum) end 

    it 'calls a block set by @block' do
      flag = false
      @each.instance_variable_set(:@block, lambda { flag = true })
      do_each([1,2,3])
      flag.should == true
    end

    it 'in the case of 0, a number of element of enum does not call a block' do
      do_each([])
      @count.should == 0
    end
    
    it 'calls an element of enum once' do
      obj = [:dfa, 1532, /reg/, 'sample', Enumerable, 55.5]
      do_each(obj)
      @count.should == obj.size
    end
  end

  describe '#into(enum, &block)' do
    before :all do
      @enum = [:sas, :res, 132.5, 'test', [1, [2, 3, 4, 5]], /sample/, [100, 99, 98, 90, 80, 50], true, [nil, Class], false]
      @enum_values = @enum.flatten
    end
    before do
      @array = []
      @call = lambda {}
      @root_caller = lambda do |e|
        e.current.tap {|x| @array.push(x.is_a?(Array) ? x[0] : x) }
        @call.call(e) if @call
      end
      @each = status_new(nil, &@root_caller)
    end

    it 'raise not parameter' do
      lambda { @each.into }.should raise_error(ArgumentError)
    end

    it 'raise not enumerable parameter' do
      lambda { @each.into(Time.now) }.should raise_error(ArgumentError)
    end

    it 'raise nil parameter' do
      lambda { @each.into(nil) }.should raise_error(ArgumentError)
    end
    
    it 'call a handed block' do
      block, func = nil, lambda {|e| block = e.instance_variable_get(:@block) }
      @each.into((2..10).to_a, &func)
      block.should == func
    end
    
    it 'call @block when a block is omitted' do
      block = nil
      @call = lambda {|e| block = e.instance_variable_get(:@block) }
      @each.into((2..10).to_a)
      block.should == @root_caller
    end

    it 'is call #each_status' do
      arg, status, result = (2..10).to_a, status_new(nil) {}, :ok!
      StatusEnumerator::Status.should_receive(:new).with(@each).and_return(status)
      status.should_receive(:each_status).with(arg).and_return(result)
      @each.into(arg).should == :ok!
    end
    
    it 'The instance of the block argument is different from it' do
      obj = nil
      @each.into([1]) {|x| obj = x }
      obj.should be_kind_of(StatusEnumerator::Status)
      obj.should_not == @each
    end
  end
  
  describe do
    before :all do
      @enum_single = [1]
      @enum_double = [156.3, :ee]
      @enum_triple = ['sam', /ple/, true]
      @enum_many = [:a, 2, 3.0, 'd', /e/, true, nil, false, 'sample', 10]
      @enum_hierarchical = [
        Foo.new(15232, 
          Foo.new('bad', 'test', :que, 1562, nil, true),
          Foo.new(:clean)
        ),
        Foo.new(Enumerable,
          Foo.new(111,
            Foo.new(/Win/, 222, 333, 444)
          ),
          'e', 'f', 'g',
          Foo.new('a', 'b', 'c', 'd')
        ),
        999,
        :a,
        Foo.new(:b, false, nil, true)
      ]
      @enum_hierarchical_flatten = [
        15232,
          'bad', 'test', :que, 1562, nil, true,
          :clean,
        Enumerable,
          111,
            /Win/, 222, 333, 444,
          'e', 'f', 'g',
          'a', 'b', 'c', 'd',
        999,
        :a,
        :b, false, nil, true
      ]
      Foo.conv(@enum_hierarchical).should == @enum_hierarchical_flatten
      @enum_hierarchical_flatten_size = @enum_hierarchical_flatten.size
    end
    before do
      @count, @result, @call = 0, [], lambda { }
      @each = status_new(nil) do |e|
        @result.push @call.call(e)
        @count += 1
        e.into(e.current.children) if e.current.is_a?(Foo)
      end
    end
    def do_each(enum, into = nil)
      @each.send(:each_status, enum)
      @count.should == (into || enum.size)
      @result
    end

    describe '#first?' do
      before do
        @call = lambda {|x| x.first? }
      end
      def make_result(enum)
        Array.new(enum.size, false).tap {|x| x[0] = true }
      end

      it 'initalized true' do
        @each.first?.should == true
      end
      
      it 'puts back true to only the first value(single ary)' do
        do_each(@enum_single).should == [true]
      end
      
      it 'puts back true to only the first value(double ary)' do
        do_each(@enum_double).should == make_result(@enum_double)
      end
      
      it 'puts back true to only the first value(triple ary)' do
        do_each(@enum_triple).should == make_result(@enum_triple)
      end
      
      it 'puts back true to only the first value(many ary)' do
        do_each(@enum_many).should == make_result(@enum_many)
      end

      it 'puts back true to only the first value(hierarchical ary)' do
        do_each(@enum_hierarchical, @enum_hierarchical_flatten_size).should == Foo.conv(@enum_hierarchical) {|x| make_result(x) }
      end
    end

    describe '#last?' do
      before do
        @call = lambda {|x| x.last? }
      end
      def make_result(enum)
        Array.new(enum.size, false).tap {|x| x[-1] = true }
      end

      it 'initalized true' do
        @each.last?.should == true
      end
      
      it 'puts back true to only the last value(single ary)' do
        do_each(@enum_single).should == [true]
      end
      
      it 'puts back true to only the last value(double ary)' do
        do_each(@enum_double).should == make_result(@enum_double)
      end
      
      it 'puts back true to only the last value(triple ary)' do
        do_each(@enum_triple).should == make_result(@enum_triple)
      end
      
      it 'puts back true to only the last value(many ary)' do
        do_each(@enum_many).should == make_result(@enum_many)
      end

      it 'puts back true to only the last value(hierarchical ary)' do
        do_each(@enum_hierarchical, @enum_hierarchical_flatten_size).should == Foo.conv(@enum_hierarchical) {|x| make_result(x) }
      end
    end

    describe '#current' do
      before do
        @call = lambda {|x| x.current.is_a?(Foo) ? x.current.value : x.current }
      end
      def make_result(enum)
        enum
      end

      it 'initalized nil' do
        @each.current.should be_nil
      end
      
      it 'puts back true to only the current value(single ary)' do
        do_each(@enum_single).should == make_result(@enum_single)
      end
      
      it 'puts back true to only the current value(double ary)' do
        do_each(@enum_double).should == make_result(@enum_double)
      end
      
      it 'puts back true to only the current value(triple ary)' do
        do_each(@enum_triple).should == make_result(@enum_triple)
      end
      
      it 'puts back true to only the current value(many ary)' do
        do_each(@enum_many).should == make_result(@enum_many)
      end

      it 'puts back true to only the current value(hierarchical ary)' do
        do_each(@enum_hierarchical, @enum_hierarchical_flatten_size).should == @enum_hierarchical_flatten
      end

      it 'puts back true to only the current value(hierarchical ary)' do
        do_each(@enum_hierarchical, @enum_hierarchical_flatten_size).should == Foo.conv(@enum_hierarchical) {|x| make_result(x) }
      end
    end

    describe '#prev' do
      before do
        @call = lambda {|x| x.prev.is_a?(Foo) ? x.prev.value : x.prev }
      end
      def make_result(enum)
        enum.dup.tap {|x| x.pop; x.unshift nil }
      end

      it 'initalized nil' do
        @each.prev.should be_nil
      end
      
      it 'puts back true to only the prev value(single ary)' do
        do_each(@enum_single).should == make_result(@enum_single)
      end
      
      it 'puts back true to only the prev value(double ary)' do
        do_each(@enum_double).should == make_result(@enum_double)
      end
      
      it 'puts back true to only the prev value(triple ary)' do
        do_each(@enum_triple).should == make_result(@enum_triple)
      end
      
      it 'puts back true to only the prev value(many ary)' do
        do_each(@enum_many).should == make_result(@enum_many)
      end

      it 'puts back true to only the prev value(hierarchical ary)' do
        do_each(@enum_hierarchical, @enum_hierarchical_flatten_size).should == Foo.conv(@enum_hierarchical) {|x| make_result(x) }
      end
    end

    describe '#next' do
      before do
        @call = lambda {|x| x.next.is_a?(Foo) ? x.next.value : x.next }
      end
      def make_result(enum)
        enum.dup.tap {|x| x.shift; x.push nil }
      end

      it 'initalized nil' do
        @each.next.should be_nil
      end
      
      it 'puts back true to only the next value(single ary)' do
        do_each(@enum_single).should == make_result(@enum_single)
      end
      
      it 'puts back true to only the next value(double ary)' do
        do_each(@enum_double).should == make_result(@enum_double)
      end
      
      it 'puts back true to only the next value(triple ary)' do
        do_each(@enum_triple).should == make_result(@enum_triple)
      end
      
      it 'puts back true to only the next value(many ary)' do
        do_each(@enum_many).should == make_result(@enum_many)
      end

      it 'puts back true to only the next value(hierarchical ary)' do
        do_each(@enum_hierarchical, @enum_hierarchical_flatten_size).should == Foo.conv(@enum_hierarchical) {|x| make_result(x) }
      end
    end

    describe '#parent_status' do
      before do
        @call = lambda do |x|
          if y = x.parent_status
            y.current.is_a?(Foo) ? y.current.value : y.current
          else
            nil
          end
        end
      end
      def make_result(enum)
        Array.new(enum.size, nil)
      end

      it 'initalized nil' do
        @each.parent_status.should be_nil
      end
      
      it 'gives back the status information of the pro-element(single ary)' do
        do_each(@enum_single).should == make_result(@enum_single)
      end
      
      it 'gives back the status information of the pro-element(double ary)' do
        do_each(@enum_double).should == make_result(@enum_double)
      end
      
      it 'gives back the status information of the pro-element(triple ary)' do
        do_each(@enum_triple).should == make_result(@enum_triple)
      end
      
      it 'gives back the status information of the pro-element(many ary)' do
        do_each(@enum_many).should == make_result(@enum_many)
      end

      it 'gives back the status information of the pro-element(hierarchical ary)' do
        result = Foo.conv_with_ancestors(@enum_hierarchical) do |x, ary|
          Array.new(x.size, ary.last)
        end
        do_each(@enum_hierarchical, @enum_hierarchical_flatten_size).should == result
      end
      
      it 'gives back a thing unlike x in instance of StatusEnumerator::Status or nil' do
        mode = Foo.conv_with_ancestors(@enum_hierarchical) do |x, ary|
          Array.new(x.size, !ary.empty?)
        end
        @call = lambda do |x|
          if mode.shift
            x.parent_status.should be_kind_of(StatusEnumerator::Status)
            x.parent_status.should_not == x
          else
            x.parent_status.should be_nil
          end
        end
        do_each(@enum_hierarchical, @enum_hierarchical_flatten_size)
      end
    end
  end
end
