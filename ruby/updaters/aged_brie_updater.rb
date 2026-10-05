class AgedBrieUpdater < ItemUpdater
  def update_item
    decrease_sell_in
    increase_quality(quality_increase_step)
  end

  private

  def quality_increase_step
    expired? ? 2 : 1
  end
end
