require 'forwardable'

class StatusEnumerator
  def initialize(target)
    raise ArgumentError, '%s is not redpond to #each' % target.class.name if target.nil? or !target.respond_to?(:each)
    @target = target
  end
  
  def each
    raise ArgumentError, 'no block given' unless block_given?
    c = 0
    @target.each do |i|
      put_next i
      c += 1
      if c == 3
        n = put_prev
        set_flags true, false
        yield element_status
        put_next n
        yield element_status
      elsif c > 2
        yield element_status
      end
    end.tap do
      if c > 0
        case c
        when 1
          put_next
          set_flags true, true
          yield element_status
        when 2
          set_flags true, false
          yield element_status
          put_next
          set_flags false, true
          yield element_status
        else
          put_next
          set_flags false, true
          yield element_status
        end
      end
    end
  end

  extend Forwardable
  def element_status; @status ||= Status.send(:new, nil) { } end
  def_delegators :element_status, :put_next, :put_prev, :set_flags
  private :put_next, :put_prev, :set_flags

  class Status
    class <<self
      private :new
    end

    attr_reader :current, :prev, :next
    def first?; !!@first_p end
    def last?; !!@last_p end

    private

    def initialize(owner, &block)
      raise ArgumentError, '%s is not kind of StatusEnumerator::Status' % owner.inspect unless owner.nil? or owner.kind_of?(StatusEnumerator::Status)
      raise ArgumentError, 'block not given' if owner.nil? and block.nil?
      @owner, @block = owner, block || owner.instance_variable_get(:@block)

      @prev = @current = @next = nil
      @first_p = @last_p = true
    end

    def each_status(enum)
      c = 0
      enum.each do |i|
        put_next i
        c += 1
        if c == 3
          n = put_prev
          set_flags true, false
          @block.call(self)
          put_next n
          @block.call(self)
        elsif c > 2
          @block.call(self)
        end
      end.tap do
        if c > 0
          case c
          when 1
            put_next
            set_flags true, true
            @block.call(self)
          when 2
            set_flags true, false
            @block.call(self)
            put_next
            set_flags false, true
            @block.call(self)
          else
            put_next
            set_flags false, true
            @block.call(self)
          end
        end
      end
    end
    
    def put_next(obj = nil)
      _prev, @prev, @current, @next = @prev, @current, @next, obj
      @first_p = false
      _prev
    end
    def put_prev(obj = nil)
      @prev, @current, @next, _next = obj, @prev, @current, @next
      @last_p = false
      _next
    end
    def set_flags(first, last)
      @first_p, @last_p = first, last
    end
  end
end