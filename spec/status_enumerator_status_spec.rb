require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe StatusEnumerator::Status do
  def status_new(*args, &block); StatusEnumerator::Status.send(:new, *args, &block) end
  
  it 'is Class' do
    StatusEnumerator::Status.should be_instance_of(Class)
  end

  describe '.new(owner, &block)' do
    it 'is private' do
      StatusEnumerator::Status.tap do |x|
        x.should be_respond_to(:new, true)
        x.should_not be_respond_to(:new)
      end
    end
    
    it 'stores owner in @owner' do
      owner = status_new(nil) {}
      status_new(owner) {}.instance_variable_get(:@owner).should == owner
    end

    it 'permits owner of nil' do
      lambda { status_new(nil) {} }.should_not raise_error
    end

    it 'when owner is not kind of Status, it raises an ArgumentError' do
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

    it 'in the case of owner and block is nil, it raises an ArgumentError' do
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
    end
    before do
      @count, @result, @call = 0, [], lambda { }
      @each = status_new(nil) do |e|
        @result.push @call.call(e)
        @count += 1
      end
    end
    def do_each(enum)
      @each.send(:each_status, enum)
      @count.should == enum.size
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
    end

    describe '#current' do
      before do
        @call = lambda {|x| x.current }
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
    end

    describe '#prev' do
      before do
        @call = lambda {|x| x.prev }
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
    end

    describe '#next' do
      before do
        @call = lambda {|x| x.next }
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
    end
  end
end
