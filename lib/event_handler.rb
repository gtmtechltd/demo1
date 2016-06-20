module EventHandler
  def _callbacks
    @_callbacks ||= Hash.new { |h, k| h[k] = [] }
  end

  def on(type, &blk)
    _callbacks[type] << blk
    self
  end

  def new_event(type, *args)
    _callbacks[type].each do |blk|
      blk.call(*args)
    end
  end
end
