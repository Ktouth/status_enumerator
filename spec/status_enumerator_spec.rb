require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe StatusEnumerator do
  it 'is Class' do
    StatusEnumerator.should be_instance_of(Class)
  end
  
  describe 'constructor' do
    it 'obj is enumerable' do
      obj = (1..10).to_a
      StatusEnumerator.new(obj).should be_instance_of(StatusEnumerator)
    end

    it 'raise not parameter' do
      lambda { StatusEnumerator.new }.should raise_error(ArgumentError)
    end

    it 'raise not enumerable parameter' do
      lambda { StatusEnumerator.new(Time.now) }.should raise_error(ArgumentError)
    end

    it 'raise nil parameter' do
      lambda { StatusEnumerator.new(nil) }.should raise_error(ArgumentError)
    end
  end
  
  describe '#each' do
    it 'need block given' do
      lambda { StatusEnumerator.new([]).each }.should raise_error(ArgumentError)
    end

    it 'not carry out blocking when there is not an element' do
      i = 0
      StatusEnumerator.new([]).each { i += 1 }
      i.should == 0
    end

    it 'only a number same as an element carries out blocking' do
      i = 0
      obj = [2648, 'sample', nil, :test, /aaa/]
      StatusEnumerator.new(obj).each { i += 1 }
      i.should == obj.size
    end

    it 'calls #each of the object which I can enumerate once' do
      class << (ary = [2648, 'sample', nil, :test, /aaa/])
        attr_accessor :called
        def each(&block)
          super(&block).tap { self.called += 1 }
        end
      end
      ary.called = 0
      StatusEnumerator.new(ary).each { }
      ary.called.should == 1
    end
    
    describe 'block parameter' do
      before :all do
        @ary_many = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h']
      end

      it 'is not nil' do
        StatusEnumerator.new(@ary_many).each do |i|
          i.should_not be_nil
        end
      end
      
      it 'is not object itself' do
        ary = @ary_many.dup
        StatusEnumerator.new(@ary_many).each do |i|
          i.should_not == ary.shift
        end
        ary.should be_empty
      end

      it '#current is target object' do
        ary = @ary_many.dup
        StatusEnumerator.new(@ary_many).each do |i|
          i.current.should == ary.shift
        end
        ary.should be_empty
      end
      
      it '#prev gives back an element just before that' do
        ary = @ary_many[0 .. -2]
        ary.unshift nil
        ary.size.should == @ary_many.size
        StatusEnumerator.new(@ary_many).each do |i|
          i.prev.should == ary.shift
        end
        ary.should be_empty
      end
      
      it '#next gives back an element just after that' do
        ary = @ary_many[1 .. -1]
        ary.push nil
        ary.size.should == @ary_many.size
        StatusEnumerator.new(@ary_many).each do |i|
          i.next.should == ary.shift
        end
        ary.should be_empty
      end
      
      describe 'The number of elements in the case of one' do
        before do
          @enum = StatusEnumerator.new([1564988])
        end

        it '#first? gives back true' do
          ary = []
          @enum.each {|x| ary.push x.first? }
          ary.should == [true]
        end

        it '#last? gives back true' do
          ary = []
          @enum.each {|x| ary.push x.last? }
          ary.should == [true]
        end
      end
      
      describe 'The number of elements in the case of two' do
        before do
          @enum = StatusEnumerator.new([:symbol, /test/])
        end

        it '#first? gives back true and false' do
          ary = []
          @enum.each {|x| ary.push x.first? }
          ary.should == [true, false]
        end

        it '#last? gives back false and true' do
          ary = []
          @enum.each {|x| ary.push x.last? }
          ary.should == [false, true]
        end
      end

      describe 'The number of elements in the case of a majority' do
        before do
          ary = [:symbol, 'abnormal', 150.55, nil, Enumerable, 'AAAAAAAAAA', 111, /test/]
          @size = ary.size
          @enum = StatusEnumerator.new(ary)
        end

        it '#first? gives back true and any false' do
          ary = []
          @enum.each {|x| ary.push x.first? }
          ary.should == [true, Array.new(@size - 1, false)].flatten
        end

        it '#last? gives back any false and true' do
          ary = []
          @enum.each {|x| ary.push x.last? }
          ary.should == [Array.new(@size - 1, false), true].flatten
        end
      end
    end
  end

  describe '#status_class' do
    it 'gives back Status' do
      StatusEnumerator.new([]).status_class.should == StatusEnumerator::Status
    end
  end
end
