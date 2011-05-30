class StatusEnumerator
  def initialize(target)
    raise ArgumentError, '%s is not redpond to #each' % target.class.name if target.nil? or !target.respond_to?(:each)
    @target = target
  end
  
  def each
    raise ArgumentError, 'no block given' unless block_given?
    c, stat = 0, Status.new
    @target.each do |i|
      stat.send(:put_next, i)
      c += 1
      if c == 3
        n = stat.send(:put_prev)
        stat.send(:set_flags, true, false)
        yield stat
        stat.send(:put_next, n)
        yield stat
      elsif c > 2
        yield stat
      end
    end.tap do
      if c > 0
        case c
        when 1
          stat.send(:put_next)
          stat.send(:set_flags, true, true)
          yield stat
        when 2
          stat.send(:set_flags, true, false)
          yield stat
          stat.send(:put_next)
          stat.send(:set_flags, false, true)
          yield stat
        else
          stat.send(:put_next)
          stat.send(:set_flags, false, true)
          yield stat
        end
      end
    end
  end

  class Status # :nodoc:
    attr_reader :current, :prev, :next
    def first?; !!@first_p end
    def last?; !!@last_p end

    private

    def initialize
      @prev = @current = @next = nil
      @first_p = @last_p = true
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