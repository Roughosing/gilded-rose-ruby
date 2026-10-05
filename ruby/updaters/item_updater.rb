class ItemUpdater
  QUALITY_MAX = 50
  QUALITY_MIN = 0

  def initialize(item)
    @item = item
  end

  def update_item
    raise NotImplementedError, "#{self.class} must implement update_item"
  end

  private

  def decrease_sell_in
    @item.sell_in -= 1
  end

  def increase_quality(step = 1)
    return if @item.quality >= QUALITY_MAX

    @item.quality = [@item.quality + step, QUALITY_MAX].min
  end

  def decrease_quality(step = 1)
    return if @item.quality <= QUALITY_MIN

    @item.quality = [@item.quality - step, QUALITY_MIN].max
  end

  def expired?
    @item.sell_in < 0
  end
end
