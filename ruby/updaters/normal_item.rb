class NormalItem < ItemUpdater
  QUALITY_DECREMENT_ON_EXPIRATION = 2

  def update_item
    decrease_sell_in
    return decrease_quality(QUALITY_DECREMENT_ON_EXPIRATION) if expired?

    decrease_quality
  end
end
