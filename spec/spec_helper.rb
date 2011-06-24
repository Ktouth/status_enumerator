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

  class <<self
    def conv(ary)
      block = block_given? ? lambda {|x, a| yield x } : nil
      conv_as(ary, [], &block)
    end
    def conv_with_ancestors(ary, &block); conv_as(ary, [], &block) end

    private

    def conv_as(ary, ancestors, &block)
      ret = ary.map {|x| x.kind_of?(self) ? x.value : x }
      ret = block.call(ret, ancestors) if block
      ary.each_with_index do |obj, i|
        if obj.kind_of?(self) and !obj.children.empty?
          o = conv_as(obj.children, ancestors + [obj.value], &block)
          o.unshift ret[i]
          ret[i] = o
        end
      end
      ret.flatten!
      ret
    end
  end
end