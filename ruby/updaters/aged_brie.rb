class AgedBrie < ItemUpdater
  def update_item
    decrease_sell_in
    increase_quality(quality_increase_step)
  end

  private

  def quality_increase_step
    expired? ? QUALITY_STEP * 2 : QUALITY_STEP
  end
end