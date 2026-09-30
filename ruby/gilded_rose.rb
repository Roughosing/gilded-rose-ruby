require_relative 'config'

class GildedRose
  def initialize(items)
    @items = items
  end

  def update_quality
    @items.each do |item|
      ItemUpdaterFactory.build(item).update_item
    end
  end
end
