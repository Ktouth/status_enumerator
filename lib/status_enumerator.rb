class StatusEnumerator
  def initialize(target)
    raise ArgumentError, '%s is not redpond to #each' % target.class.name if target.nil? or !target.respond_to?(:each)
    @target = target
  end
  
  def each
    raise ArgumentError, 'no block given' unless block_given?
    @target.each do |i|
      yield
    end
  end
end