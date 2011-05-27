class StatusEnumerator
  def initialize(target)
    raise ArgumentError, '%s is not redpond to #each' % target.class.name if target.nil? or !target.respond_to?(:each)
    @target = target
  end
end