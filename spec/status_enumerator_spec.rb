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
end
