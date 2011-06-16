require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe StatusEnumerator::Status do
  it 'is Class' do
    StatusEnumerator::Status.should be_instance_of(Class)
  end
  
  describe '.new(owner, &block)' do
    def status_new(*args, &block); StatusEnumerator::Status.send(:new, *args, &block) end
    
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
end
