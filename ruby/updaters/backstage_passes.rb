class BackstagePasses < ItemUpdater
  SELL_IN_5_DAYS = 5
  SELL_IN_10_DAYS = 10
  QUALITY_INCREMENT_ON_5_DAYS = 3
  QUALITY_INCREMENT_ON_10_DAYS = 2

  def update_item
    decrease_sell_in
    return set_quality_to_zero if expired?
    return increase_quality(QUALITY_INCREMENT_ON_5_DAYS) if @item.sell_in < SELL_IN_5_DAYS
    return increase_quality(QUALITY_INCREMENT_ON_10_DAYS) if @item.sell_in < SELL_IN_10_DAYS

    increase_quality
  end

  private

  def set_quality_to_zero
    @item.quality = QUALITY_MIN
  end
end
