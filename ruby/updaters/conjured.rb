class Conjured < ItemUpdater
  QUALITY_DECREMENT = 2
  QUALITY_DECREMENT_ON_EXPIRATION = 4

  def update_item
    decrease_sell_in
    return decrease_quality(QUALITY_DECREMENT_ON_EXPIRATION) if expired?

    decrease_quality(QUALITY_DECREMENT)
  end
end