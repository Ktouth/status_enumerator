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
  end
end
