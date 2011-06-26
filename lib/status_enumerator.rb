class StatusEnumerator
  def initialize(target)
    raise ArgumentError, '%s is not redpond to #each' % target.class.name if target.nil? or !target.respond_to?(:each)
    @target = target
  end

  def each(&block)
    status_class.send(:new, nil, &block).send(:each_status, @target)
  end

  def status_class; Status end

  class Status
    class <<self
      private :new
    end

    attr_reader :current, :prev, :next, :parent_status
    def first?; !!@first_p end
    def last?; !!@last_p end

    def into(enum, &block)
      raise ArgumentError, '%s is not redpond to #each' % enum.class.name if enum.nil? or !enum.respond_to?(:each)
      self.class.send(:new, self, &block).send(:each_status, enum)
    end
    
    private

    def initialize(parent_status, &block)
      raise ArgumentError, '%s is not kind of StatusEnumerator::Status' % parent_status.inspect unless parent_status.nil? or parent_status.kind_of?(StatusEnumerator::Status)
      raise ArgumentError, 'block not given' if parent_status.nil? and block.nil?
      @parent_status, @block = parent_status, (block || parent_status.instance_variable_get(:@block))

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