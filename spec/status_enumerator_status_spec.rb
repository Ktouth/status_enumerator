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

  describe do
    before :all do
      @enum_single = [1]
      @enum_double = [156.3, :ee]
      @enum_triple = ['sam', /ple/, true]
      @enum_many = [:a, 2, 3.0, 'd', /e/, true, nil, false, 'sample', 10]
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