$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rspec'
require 'status_enumerator'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  
end

class Foo
  def initialize(value, *args)
    @value, @children = value, args
  end
  attr_reader :value, :children
  
  def self.conv(ary, &block)
    ret = ary.map {|x| x.kind_of?(self) ? x.value : x }
    ret = block.call(ret) if block
    ary.each_with_index do |obj, i|
      if obj.kind_of?(self)
        o = conv(obj.children, &block)
        o.unshift ret[i]
        ret[i] = o
      end
    end
    ret.flatten!
    ret
  end
end