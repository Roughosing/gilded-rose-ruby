class ItemUpdater
  QUALITY_MAX = 50
  QUALITY_MIN = 0
  QUALITY_STEP = 1
  SELL_IN_MIN = 0
  SELL_IN_STEP = 1

  def initialize(item)
    @item = item
  end

  def update_item
  end

  private

  def decrease_sell_in
    @item.sell_in -= SELL_IN_STEP
  end

  def increase_quality(step = QUALITY_STEP)
    return if @item.quality >= QUALITY_MAX
  
    @item.quality = [@item.quality + step, QUALITY_MAX].min
  end
  
  def decrease_quality(step = QUALITY_STEP)
    return if @item.quality <= QUALITY_MIN
  
    @item.quality = [@item.quality - step, QUALITY_MIN].max
  end

  def expired?
    @item.sell_in < SELL_IN_MIN
  end
end
